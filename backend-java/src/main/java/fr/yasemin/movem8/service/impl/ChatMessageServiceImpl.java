package fr.yasemin.movem8.service.impl;

import fr.yasemin.movem8.dto.ChatMessageDTO;
import java.util.Date; 
import fr.yasemin.movem8.entity.ChatMessage;
import fr.yasemin.movem8.repository.IActivityRepository;
import fr.yasemin.movem8.repository.ISportRepository;
import fr.yasemin.movem8.service.IChatMessageService;
import lombok.RequiredArgsConstructor;

import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.stereotype.Service;

import java.time.Instant;

import java.util.List;


import org.springframework.data.domain.Sort;

import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.bson.Document;

import org.springframework.data.mongodb.core.aggregation.Aggregation;
import org.springframework.data.mongodb.core.aggregation.AggregationResults;
import org.springframework.data.mongodb.core.aggregation.GroupOperation;
import org.springframework.data.mongodb.core.aggregation.LimitOperation;
import org.springframework.data.mongodb.core.aggregation.MatchOperation;
import org.springframework.data.mongodb.core.aggregation.SortOperation;






@Service
@RequiredArgsConstructor
public class ChatMessageServiceImpl implements IChatMessageService {
    
    private final MongoTemplate mongoTemplate;
    private final IActivityRepository activityRepository;
    private final ISportRepository sportRepository;
    // 1. Historique
    public List<ChatMessageDTO> history(String conversationId, int limit) {
        Query q = new Query(Criteria.where("conversationId").is(conversationId))
                .with(Sort.by(Sort.Direction.ASC, "sentAt"))
                .limit(limit);
        return mongoTemplate.find(q, ChatMessage.class).stream()
                .map(m -> new ChatMessageDTO(
                        m.getId(), m.getConversationId(), m.getSenderId(),
                        m.getContent(), m.getSentAt(),
                        null, null, null, null, null, null
                ))
                .toList();
    }

    // 2. Envoi
    public ChatMessageDTO send(ChatMessageDTO dto) {
        ChatMessage entity = new ChatMessage(
            null, dto.conversationId(), dto.senderId(),
            dto.content(), Instant.now()
        );
        entity = mongoTemplate.save(entity);
        return new ChatMessageDTO(
            entity.getId(), entity.getConversationId(), entity.getSenderId(),
            entity.getContent(), entity.getSentAt(),
            null, null, null, null, null, null
        );
    }

    // 3. Liste des conversations par communauté

    @Override
    public List<ChatMessageDTO> listByCommunity(Long communityId, int limit) {
        // 1) Pipeline Mongo : derniers messages par conversation pour cette communauté
        MatchOperation match = Aggregation.match(
                Criteria.where("conversationId").regex("^community-" + communityId + "-")
        );

        // On trie par date pour que "last" prenne bien le dernier
        SortOperation sortBySentAsc = Aggregation.sort(Sort.by(Sort.Direction.ASC, "sentAt"));

        // Group by conversationId et on récupère le dernier message (content/sender/sentAt)
        GroupOperation group = Aggregation.group("conversationId")
                .last("sentAt").as("lastSentAt")
                .last("content").as("lastContent")
                .last("senderId").as("lastSenderId");

        // Trie par dernier message décroissant + limite
        SortOperation sortByLastDesc = Aggregation.sort(Sort.by(Sort.Direction.DESC, "lastSentAt"));
        LimitOperation limitOp = Aggregation.limit(limit);

        Aggregation agg = Aggregation.newAggregation(match, sortBySentAsc, group, sortByLastDesc, limitOp);
        AggregationResults<Document> results =
                mongoTemplate.aggregate(agg, ChatMessage.class, Document.class);

        // 2) Enrichissement côté Java : extraire activityId & creatorId depuis conversationId
        Pattern convPattern = Pattern.compile("^community-(\\d+)-activity-(\\d+)-creator-(\\d+)$");

        return results.getMappedResults().stream().map(doc -> {
            String convId = doc.getString("_id");
            String lastContent = doc.getString("lastContent");
            String lastSenderId = doc.getString("lastSenderId");
         // APRÈS
//            java.util.Date lastDate = doc.getDate("lastSentAt");
            Date lastDate = doc.getDate("lastSentAt");
            Instant lastSentAt = (lastDate != null) ? lastDate.toInstant() : null;


            Long actId = null;
            Long creatorId = null;

            Matcher m = convPattern.matcher(convId);
            if (m.matches()) {
                // String commIdStr = m.group(1); // on ne s'en sert pas ici
                actId = Long.parseLong(m.group(2));
                creatorId = Long.parseLong(m.group(3));
            }

            // Valeurs affichage (sport, créateur)
            String sportName = null;
            String creatorFirst = null;
            String creatorLast  = null;
            String creatorPhoto = null;

            if (actId != null) {
                var opt = activityRepository.findById(actId);
                if (opt.isPresent()) {
                    var a = opt.get();

                    // sport
                    if (a.getSport() != null && a.getSport().getSportName() != null) {
                        sportName = a.getSport().getSportName();
                    } else {
                        sportName = a.getTitle(); // fallback
                    }

                    // créateur
                    if (a.getCreator() != null) {
                        creatorFirst = a.getCreator().getFirstName();
                        creatorLast  = a.getCreator().getLastName();
                        creatorPhoto = a.getCreator().getPictureProfile();
                    }
                }
            }


            return new ChatMessageDTO(
                    null,                    // id (optionnel pour la liste)
                    convId,                  // conversationId
                    lastSenderId,            // senderId du dernier message
                    lastContent,             // content du dernier message
                    lastSentAt,              // sentAt du dernier message
                    communityId,             // communityId (filtre courant)
                    actId,                   // activityId
                    sportName,               // sportName
                    creatorFirst,            // creatorFirstName
                    creatorLast,             // creatorLastName
                    creatorPhoto             // creatorPhotoUrl
            );
        }).toList();
    }


}
