package fr.yasemin.movem8.controller;

import fr.yasemin.movem8.service.IFriendshipService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController

@CrossOrigin("http://localhost:8080")
@RequestMapping("/api/friends")
public class FriendshipController {

    @Autowired
    private IFriendshipService friendshipService;

    // Ajouter un ami
    @PostMapping("/add/{user1Id}/{user2Id}")
	// => http://localhost:8080/api/friends/add/1/2
    public ResponseEntity<String> addFriend(@PathVariable Long user1Id, @PathVariable Long user2Id) {
        if (friendshipService.addFriend(user1Id, user2Id)) {
            return ResponseEntity.ok("Amitié ajoutée avec succès");
        } else {
            return ResponseEntity.status(400).body("Impossible d'ajouter cette amitié");
        }
    }

    // Supprimer un ami
    @DeleteMapping("/remove/{user1Id}/{user2Id}")
	// => http://localhost:8080/api/friends/remove/1/2
    public ResponseEntity<String> removeFriend(@PathVariable Long user1Id, @PathVariable Long user2Id) {
        if (friendshipService.removeFriend(user1Id, user2Id)) {
            return ResponseEntity.ok("Amitié supprimée avec succès");
        } else {
            return ResponseEntity.status(400).body("Impossible de supprimer cette amitié");
        }
    }

    // Obtenir la liste des amis d'un utilisateur
    @GetMapping("/{userId}/friends")
	// => http://localhost:8080/api/friends/1/friends
    public ResponseEntity<Object> getUserFriends(@PathVariable Long userId) {
        return ResponseEntity.ok(friendshipService.getUserFriends(userId));
    }

    // Vérifier si deux utilisateurs sont amis
    @GetMapping("/are-friends/{user1Id}/{user2Id}")
	// => http://localhost:8080/api/friends/are-friends/1/2
    public ResponseEntity<String> areFriends(@PathVariable Long user1Id, @PathVariable Long user2Id) {
        if (friendshipService.areFriends(user1Id, user2Id)) {
            return ResponseEntity.ok("Les utilisateurs sont amis");
        } else {
            return ResponseEntity.ok("Les utilisateurs ne sont pas amis");
        }
    }
}
