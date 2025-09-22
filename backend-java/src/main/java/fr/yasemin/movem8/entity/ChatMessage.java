package fr.yasemin.movem8.entity;

import lombok.*;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

@Document(collection = "messages")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ChatMessage {
  @Id private String id;

  @Indexed               // pour requêtes rapides par conversation
  private String conversationId;

  private String senderId;  // id user (String/Long selon ton modèle)
  private String content;   // texte
  private Instant sentAt;   // Instant.now()
}