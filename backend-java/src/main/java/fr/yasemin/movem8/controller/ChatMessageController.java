package fr.yasemin.movem8.controller;

import fr.yasemin.movem8.dto.ChatMessageDTO;
import fr.yasemin.movem8.service.IChatMessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
public class ChatMessageController {

    private final IChatMessageService service;

    @GetMapping("/history/{conversationId}")
    public ResponseEntity<List<ChatMessageDTO>> history(
            @PathVariable String conversationId,
            @RequestParam(defaultValue = "50") int limit
    ) {
        return ResponseEntity.ok(service.history(conversationId, limit));
    }

    @PostMapping("/send")
    public ResponseEntity<ChatMessageDTO> send(@RequestBody ChatMessageDTO dto) {
        return ResponseEntity.ok(service.send(dto));
    }

    @GetMapping("/conversations")
    public ResponseEntity<List<ChatMessageDTO>> conversations(
            @RequestParam Long communityId,
            @RequestParam(defaultValue = "50") int limit
    ) {
        return ResponseEntity.ok(service.listByCommunity(communityId, limit));
    }
}
