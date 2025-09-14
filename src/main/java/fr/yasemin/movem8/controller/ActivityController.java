package fr.yasemin.movem8.controller;

import fr.yasemin.movem8.dto.ActivityCardDTO;
import fr.yasemin.movem8.dto.ActivityDetailDTO;
import fr.yasemin.movem8.dto.ActivityUpdateDTO;
import fr.yasemin.movem8.dto.CreateActivityRequestDTO;
import fr.yasemin.movem8.entity.Activity;
import fr.yasemin.movem8.entity.Category;
import fr.yasemin.movem8.entity.Community;
import fr.yasemin.movem8.entity.Participant;
import fr.yasemin.movem8.entity.User;
import fr.yasemin.movem8.enums.Level;
import fr.yasemin.movem8.mapper.ActivityMapper;
import fr.yasemin.movem8.repository.IUserRepository;
import fr.yasemin.movem8.service.IActivityService;
import jakarta.persistence.EntityNotFoundException;
import jakarta.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.time.LocalDateTime;
import java.util.List;

@RestController

@CrossOrigin("http://localhost:8080")
@RequestMapping("/api/activities")
public class ActivityController {

    @Autowired
    private IActivityService activityService;
    
    @Autowired 
    private IUserRepository userRepository;
//    @GetMapping("/search")
//    public List<Activity> searchActivities(
//            @RequestParam(required = false) String activityName,
//            @RequestParam(required = false) String category,
//            @RequestParam(required = false) String sportName,
//            @RequestParam(required = false) LocalDateTime activityDate,
//            @RequestParam(required = false) String location,
//            @RequestParam(required = false) String creatorName,
//            @RequestParam(required = false) Level level) {
//
//        return activityService.searchActivities(activityName, category, sportName, activityDate, location, creatorName, level);
//    //GET /activities/search?activityName=Yoga&category=Fitness&sportName=Yoga&activityDate=2025-04-12T10:00:00&location=Paris&creatorName=Yasemin&activityLevel=BEGINNER
//
//    }
    

    

    //Récupérer activité par id 
    
 // GET détail
    @GetMapping("/{id}")
    public ResponseEntity<?> getById(@PathVariable Long id) {
      try {
        Activity a = activityService.getActivitiById(id);
        return ResponseEntity.ok(ActivityMapper.toDetailDTO(a));
      } catch (Exception e) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
      }
    }

    // POST création -> retourne détail
    @PostMapping("/save")
    public ResponseEntity<?> createActivity(@Valid @RequestBody CreateActivityRequestDTO req) {
      try {
        Activity created = activityService.createActivity(req);
        ActivityDetailDTO body = ActivityMapper.toDetailDTO(created);
        return ResponseEntity
            .created(URI.create("/api/activities/" + body.getId()))
            .body(body);
      } catch (EntityNotFoundException e) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
      } catch (IllegalArgumentException e) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
      } catch (Exception e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Erreur serveur");
      }
    }

    // GET liste (mini-cartes) — globale ou filtrée par communauté
    @GetMapping()
    public ResponseEntity<?> list(@RequestParam(required = false) Long communityId) {
      try {
        List<Activity> list = (communityId == null)
            ? activityService.getAllActivities()
            : activityService.findAllByCommunity(communityId);

        List<ActivityCardDTO> cards = list.stream()
            .map(ActivityMapper::toCardDTO)
            .toList();

        return ResponseEntity.ok(cards);
      } catch (Exception e) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
      }
    }


    // Mettre à jour une activité existante
 // src/main/java/fr/yasemin/movem8/controller/ActivityController.java

 // PATCH partiel propre
 @PatchMapping("/update/{id}")
 public ResponseEntity<?> updateActivity(
     @PathVariable Long id,
     @RequestBody ActivityUpdateDTO dto
 ) {
   try {
     Activity updated = activityService.updateActivityPartial(id, dto);
     // Retourne le détail (ou la card) selon ton besoin ; ici détail :
     ActivityDetailDTO body = ActivityMapper.toDetailDTO(updated);
     return ResponseEntity.ok(body);
   } catch (IllegalArgumentException e) {
     return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
   } catch (Exception e) {
     return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
   }
 }

    
    // Supprimer une activité
    @DeleteMapping("/delete/{id}")
    // => http://localhost:8080/api/remove/1
    public ResponseEntity<String> deleteActivity(@PathVariable Long id) {
        try {
            if (activityService.deleteActivity(id)) {
                return new ResponseEntity<>("Activité supprimée avec succès", HttpStatus.OK);
            } else {
                return new ResponseEntity<>("Échec de la suppression", HttpStatus.NOT_FOUND);
            }
        } catch (Exception e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }
    

 
    @GetMapping("/all")
    public ResponseEntity<List<ActivityCardDTO>> getAllActivitiesDto() {
        try {
            List<Activity> activities = activityService.getAllActivities();
            List<ActivityCardDTO> dtos = activities.stream()
            	.map(ActivityMapper::toCardDTO)
                .toList();
            return ResponseEntity.ok(dtos);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(null);
        }
    }


    
    // Demander à participer à une activité
    @PostMapping("/{activityId}/request/{userId}")
    // => http://localhost:8080/api/activities/1/request/1
    public ResponseEntity<String> requestParticipant(@PathVariable Long activityId, @PathVariable Long userId) {
        try {
            if (activityService.requestParticipant(activityId, userId)) {
                return new ResponseEntity<>("Demande envoyée avec succès", HttpStatus.OK);
            } else {
                return new ResponseEntity<>("Erreur dans l'envoi de la demande", HttpStatus.BAD_REQUEST);
            }
        } catch (Exception e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

    
    // Valider la participation d'un utilisateur à une activité
    @PatchMapping("/{activityId}/validate/{participantId}")
    public ResponseEntity<Participant> validateParticipation(
        @PathVariable Long activityId,
        @PathVariable Long participantId,
        @RequestParam Long creatorId) {
      try {
        Participant p = activityService.validateParticipation(participantId, creatorId);
        return ResponseEntity.ok(p);
      } catch (Exception e) {
        return ResponseEntity.badRequest().build();
      }
    }

    // Supprimer un participant d'une activité
    @DeleteMapping("/{activityId}/remove/{userId}")
    // => http://localhost:8080/api/activities/1/remove/1
    public ResponseEntity<String> removeParticipant(@PathVariable Long activityId, @PathVariable Long userId) {
        try {
            if (activityService.removeParticipant(activityId, userId)) {
                return new ResponseEntity<>("Participant retiré avec succès", HttpStatus.OK);
            } else {
                return new ResponseEntity<>("Erreur dans la suppression du participant", HttpStatus.BAD_REQUEST);
            }
        } catch (Exception e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

    
    // Noter une activité
    @PostMapping("/{activityId}/rate")
    // => http://localhost:8080/api/activities/1/rate
    public ResponseEntity<Float> rateActivity(@PathVariable Long activityId, @RequestParam float rating) {
        try {
            float updatedRating = activityService.rateActivity(activityId, rating);
            return new ResponseEntity<>(updatedRating, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }

    // Obtenir la liste des participants d'une activité
    @GetMapping("/{id}/participants")
    // => http://localhost:8080/api/activities/1/participants
    public ResponseEntity<List<Participant>> getParticipants(@PathVariable Long id) {
        try {
            List<Participant> participants = activityService.getParticipantsByActivityId(id);
            return ResponseEntity.ok(participants);
        } catch (EntityNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        }
    }
}













