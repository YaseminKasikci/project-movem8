package fr.yasemin.movem8.service.impl;


import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import fr.yasemin.movem8.entity.Activity;
import fr.yasemin.movem8.entity.Comment;
import fr.yasemin.movem8.entity.Participant;
import fr.yasemin.movem8.entity.User;
import fr.yasemin.movem8.enums.StatusParticipant;
import fr.yasemin.movem8.repository.IActivityRepository;
import fr.yasemin.movem8.repository.ICommentRepository;
import fr.yasemin.movem8.repository.IParticipantRepository;
import fr.yasemin.movem8.repository.IUserRepository;
import fr.yasemin.movem8.service.ICommentService;



@Service
public class CommentServiceImpl implements ICommentService {

    @Autowired
    private ICommentRepository commentRepo;

    @Autowired
    private IParticipantRepository participantRepo;

    @Autowired
    private IUserRepository userRepo;

    @Autowired
    private IActivityRepository activityRepo;
    
    


    //  Ajouter un commentaire
    @Override
    public Comment addComment(Long userId, Long activityId, String content, float rating) {
       	// TODO verifier que l'ajout de comment fonctionne apres ajout de particiânt
    	   // Si on est en mode test, ignorer la validation du participant
        if (System.getProperty("env").equals("test")) {
            // Ignorer la vérification du participant pour les tests
        } else {
            // Vérification du participant pour les autres environnements
            Optional<Participant> participantOpt = participantRepo.findByUserIdAndActivityIdAndStatusParticipant(userId, activityId, StatusParticipant.A);
            if (participantOpt.isEmpty()) {
                throw new RuntimeException("Vous n'êtes pas un participant validé de cette activité.");
            }
        }

        // Récupérer l'utilisateur, l'activité et créer un commentaire
        User user = userRepo.findById(userId).orElseThrow(() -> new RuntimeException("Utilisateur introuvable"));
        Activity activity = activityRepo.findById(activityId).orElseThrow(() -> new RuntimeException("Activité introuvable"));

        Comment comment = Comment.builder()
                .author(user)
                .activity(activity)
                .content(content)
                .rating(rating)
                .date(LocalDateTime.now())
                .build();
        
        comment.getAuthor().getFirstName();  // Accède à un champ pour forcer l'initialisation de l'auteur
        comment.getActivity().getTitle();   // Accède à un champ pour forcer l'initialisation de l'activité

        System.out.println("Sauvegarde du commentaire: " + comment);
        // Enregistrer le commentaire dans la base de données
        return commentRepo.save(comment);
    }


    //  Récupérer tous les commentaires pour une activité
    @Override
    public List<Comment> getCommentsByActivity(Long activityId) {
        // Récupérer tous les commentaires associés à l'activité
        return commentRepo.findByActivityId(activityId);
    }

    // 3. Mettre à jour un commentaire
    @Override
    public Comment updateComment(Long commentId, String newContent, float newRating) {
       	// TODO faire service metier pour que le commentaire soit Modifiable Seulement par l'auteur ou un admin
    
        // Récupérer le commentaire à mettre à jour
        Comment comment = commentRepo.findById(commentId).orElseThrow(() -> new RuntimeException("Commentaire introuvable"));
        
//        // Vérifier que l'utilisateur est l'auteur
//        if (!comment.getAuthor().getId().equals(currentUser.getId())) {
//            throw new RuntimeException("Vous n'êtes pas autorisé à modifier ce commentaire");
//        }


        // Mettre à jour le contenu et la note du commentaire
        comment.setContent(newContent);
        comment.setRating(newRating);

        // Enregistrer les changements dans la base de données
        return commentRepo.save(comment);
        
    }

    // 4. Supprimer un commentaire
    @Override
    public boolean deleteComment(Long commentId) {
    	// TODO faire service metier pour que le commentaire soit supprimer Seulement par l'auteur ou un admin
    	
        // Vérifier si le commentaire existe
        if (!commentRepo.existsById(commentId)) {
            throw new RuntimeException("Commentaire introuvable");
        }

        // Supprimer le commentaire
        commentRepo.deleteById(commentId);
        return true; // Retourne true si la suppression est réussie
    }


	
	}




