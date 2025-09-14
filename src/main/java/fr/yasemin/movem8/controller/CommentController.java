package fr.yasemin.movem8.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import fr.yasemin.movem8.entity.Comment;
import fr.yasemin.movem8.service.ICommentService;

@RestController

@CrossOrigin("http://localhost:8080")
@RequestMapping("/api/comments")
public class CommentController {

    @Autowired
    private ICommentService commentService;

    //  Ajouter un commentaire
    @PostMapping("/save/{activityId}/user/{userId}")
// =>    http://localhost:8080/api/comments/save/1/user/1
    public ResponseEntity<Comment> addComment(
    		@PathVariable  Long activityId,
    		@PathVariable  Long userId,
    	    @RequestBody Map<String, Object> request) { 

        String content = (String) request.get("content");
        Float rating = Float.valueOf(request.get("rating").toString());

        System.out.println("Received comment: " + content + " with rating: " + rating);

        try {
            // Appel du service pour ajouter le commentaire
            Comment comment = commentService.addComment(userId, activityId, content, rating);
            return new ResponseEntity<>(comment, HttpStatus.CREATED);
        } catch (Exception e) {
        	 e.printStackTrace(); 
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }

    // Récupérer les commentaires d'une activité
    @GetMapping("/activity{activityId}")
 // =>    http://localhost:8080/api/comments/activity1
    public ResponseEntity<List<Comment>> getCommentsByActivityId(@PathVariable Long activityId) {
        try {
            List<Comment> comments = commentService.getCommentsByActivity(activityId);
            return new ResponseEntity<>(comments, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }

    //  Mettre à jour un commentaire
    @PatchMapping("/update/{commentId}")
 // =>    http://localhost:8080/api/update/comments/1
    public ResponseEntity<Comment> updateComment(
            @PathVariable Long commentId,
            @RequestParam String newContent,
            @RequestParam float newRating) {
        try {
            Comment updatedComment = commentService.updateComment(commentId, newContent, newRating);
            return new ResponseEntity<>(updatedComment, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }

    // Supprimer un commentaire
    @DeleteMapping("/remove/{commentId}")
    // =>    http://localhost:8080/api/comments/remove/1
    public ResponseEntity<String> deleteComment(@PathVariable Long commentId) {
        try {
            if (commentService.deleteComment(commentId)) {
                return new ResponseEntity<>("Commentaire supprimé avec succès", HttpStatus.OK);
            } else {
                return new ResponseEntity<>("Erreur dans la suppression du commentaire", HttpStatus.BAD_REQUEST);
            }
        } catch (Exception e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }
}
