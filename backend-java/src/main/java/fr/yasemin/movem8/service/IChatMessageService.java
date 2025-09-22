package fr.yasemin.movem8.service;

import java.util.List;

import org.springframework.stereotype.Repository;

import fr.yasemin.movem8.dto.ChatMessageDTO;
import fr.yasemin.movem8.entity.ChatMessage;

@Repository
public interface IChatMessageService {
	
	 
	    List<ChatMessageDTO> history(String conversationId, int limit);
	    ChatMessageDTO send(ChatMessageDTO dto);
	    List<ChatMessageDTO> listByCommunity(Long communityId, int limit);
	    

	    
}
