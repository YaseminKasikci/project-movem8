package fr.yasemin.movem8.dto;

import java.time.Instant;

public record ChatMessageDTO(
	    String id,
	    String conversationId,
	    String senderId,
	    String content,
	    Instant sentAt,

	    // Champs utilisés uniquement dans la liste de conversations
	    Long communityId,
	    Long activityId,
	    String sportName,
	    String creatorFirstName,
	    String creatorLastName,
	    String creatorPhotoUrl
	) {}
