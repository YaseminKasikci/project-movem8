package fr.yasemin.movem8.repository;

import fr.yasemin.movem8.entity.ChatMessage;

import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;


import java.time.Instant;
import java.util.List;

public interface IChatMessageRepository extends MongoRepository<ChatMessage, String> {
	// Tous les messages d’une conversation (ordre chronologique)
    List<ChatMessage> findByConversationIdOrderBySentAtAsc(String conversationId);

    // Limité aux X derniers messages (ordre décroissant)
    List<ChatMessage> findByConversationIdOrderBySentAtDesc(String conversationId, Pageable pageable);

}
