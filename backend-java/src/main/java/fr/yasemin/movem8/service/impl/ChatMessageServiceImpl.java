package fr.yasemin.movem8.service.impl;

import fr.yasemin.movem8.dto.ChatMessageDTO;
import fr.yasemin.movem8.entity.ChatMessage;
import fr.yasemin.movem8.repository.IActivityRepository;
import fr.yasemin.movem8.repository.IChatMessageRepository;
import fr.yasemin.movem8.service.IChatMessageService;
import lombok.RequiredArgsConstructor;
import org.bson.Document;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.aggregation.Aggregation;
import org.springframework.data.mongodb.core.aggregation.AggregationResults;
import org.springframework.data.mongodb.core.aggregation.GroupOperation;
import org.springframework.data.mongodb.core.aggregation.LimitOperation;
import org.springframework.data.mongodb.core.aggregation.MatchOperation;
import org.springframework.data.mongodb.core.aggregation.SortOperation;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
@RequiredArgsConstructor
public class ChatMessageServiceImpl implements IChatMessageService {

    private final MongoTemplate mongoTemplate;             // conservé pour l’agrégation
    private final IChatMessageRepository chatMessageRepository; // utilisé pour read/write simples
    private final IActivityRepository activityRepository;  // utilisé pour enrichissement

    // 1) Historique : on récupère les X derniers en DESC via repo + on remet en ASC pour l’affichage
    @Override
    public List<ChatMessageDTO> history(String conversationId, int limit) {
        Pageable page = PageRequest.of(0, Math.max(1, limit));
        var lastDesc = chatMessageRepository
                .findByConversationIdOrderBySentAtDesc(conversationId, page);

        var asc = lastDesc.stream().sorted((a, b) -> a.getSentAt().compareTo(b.getSentAt())).toList();

        return asc.stream()
                .map(m -> new ChatMessageDTO(
                        m.getId(), m.getConversationId(), m.getSenderId(),
                        m.getContent(), m.getSentAt(),
                        null, null, null, null, null, null
                ))
                .toList();
    }

    // 2) Envoi : écriture via repository
    @Override
    public ChatMessageDTO send(ChatMessageDTO dto) {
        ChatMessage entity = new ChatMessage(
                null, dto.conversationId(), dto.senderId(),
                dto.content(), Instant.now()
        );
        entity = chatMessageRepository.save(entity);
        return new ChatMessageDTO(
                entity.getId(), entity.getConversationId(), entity.getSenderId(),
                entity.getContent(), entity.getSentAt(),
                null, null, null, null, null, null
        );
    }

    // 3) Liste des conversations par communauté : agrégation Mongo (MongoTemplate)
    @Override
    public List<ChatMessageDTO> listByCommunity(Long communityId, int limit) {
        MatchOperation match = Aggregation.match(
                Criteria.where("conversationId").regex("^community-" + communityId + "-")
        );
        SortOperation sortBySentAsc = Aggregation.sort(Sort.by(Sort.Direction.ASC, "sentAt"));
        GroupOperation group = Aggregation.group("conversationId")
                .last("sentAt").as("lastSentAt")
                .last("content").as("lastContent")
                .last("senderId").as("lastSenderId");
        SortOperation sortByLastDesc = Aggregation.sort(Sort.by(Sort.Direction.DESC, "lastSentAt"));
        LimitOperation limitOp = Aggregation.limit(limit);

        Aggregation agg = Aggregation.newAggregation(match, sortBySentAsc, group, sortByLastDesc, limitOp);
        AggregationResults<Document> results =
                mongoTemplate.aggregate(agg, ChatMessage.class, Document.class);

        Pattern convPattern = Pattern.compile("^community-(\\d+)-activity-(\\d+)-creator-(\\d+)$");

        return results.getMappedResults().stream().map(doc -> {
            String convId = doc.getString("_id");
            String lastContent = doc.getString("lastContent");
            String lastSenderId = doc.getString("lastSenderId");
            Date lastDate = doc.getDate("lastSentAt");
            Instant lastSentAt = (lastDate != null) ? lastDate.toInstant() : null;

            Long actId = null;
            Long creatorId = null;

            Matcher m = convPattern.matcher(convId);
            if (m.matches()) {
                actId = Long.parseLong(m.group(2));
                creatorId = Long.parseLong(m.group(3));
            }

            String sportName = null;
            String creatorFirst = null;
            String creatorLast  = null;
            String creatorPhoto = null;

            if (actId != null) {
                var opt = activityRepository.findById(actId);
                if (opt.isPresent()) {
                    var a = opt.get();
                    sportName = (a.getSport() != null && a.getSport().getSportName() != null)
                            ? a.getSport().getSportName()
                            : a.getTitle();
                    if (a.getCreator() != null) {
                        creatorFirst = a.getCreator().getFirstName();
                        creatorLast  = a.getCreator().getLastName();
                        creatorPhoto = a.getCreator().getPictureProfile();
                    }
                }
            }

            return new ChatMessageDTO(
                    null,
                    convId,
                    lastSenderId,
                    lastContent,
                    lastSentAt,
                    communityId,
                    actId,
                    sportName,
                    creatorFirst,
                    creatorLast,
                    creatorPhoto
            );
        }).toList();
    }
}
