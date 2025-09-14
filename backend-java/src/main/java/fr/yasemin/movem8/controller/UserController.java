package fr.yasemin.movem8.controller;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import fr.yasemin.movem8.entity.Activity;
import fr.yasemin.movem8.entity.Auth;
import fr.yasemin.movem8.entity.Participant;
import fr.yasemin.movem8.entity.User;
import fr.yasemin.movem8.repository.IAuthRepository;
import fr.yasemin.movem8.repository.ICommunityRepository;
import fr.yasemin.movem8.repository.IUserRepository;
import fr.yasemin.movem8.security.JwtUtil;
import fr.yasemin.movem8.service.IActivityService;
import fr.yasemin.movem8.service.IParticipantService;
import fr.yasemin.movem8.service.IUserService;
import fr.yasemin.movem8.dto.UserProfileDTO;
import jakarta.transaction.Transactional;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/users")
@CrossOrigin("http://localhost:8080")

public class UserController {

	@Autowired
	private IUserService userService;
	
    @Autowired
    private IActivityService activityService;
	
    @Autowired
    private IParticipantService participantService;
    
    @Autowired
    private IUserRepository userRepository;
    
    @Autowired
    private ICommunityRepository communityRepository;
    
    @Autowired
    private IAuthRepository authRepository;
    
    @Autowired
    private JwtUtil jwtUtil;




    @PutMapping("/complete-profile")
    public ResponseEntity<?> completeProfileFromToken(
            @RequestBody  UserProfileDTO update,
            @RequestHeader("Authorization") String authHeader) {

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Token manquant ou invalide.");
        }
        try {
            String email = jwtUtil.getEmailFromJwt(authHeader.substring(7));
            Auth auth = authRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Authentification introuvable."));
            User user = auth.getUser();
            if (user == null) return ResponseEntity.status(404).body("Utilisateur introuvable.");

            user.setFirstName(update.getFirstName());
            user.setLastName(update.getLastName());
            user.setGender(update.getGender());
            user.setDescription(update.getDescription());
            user.setBirthday(update.getBirthday());
            user.setPictureProfile(update.getPictureProfile()); // URL renvoyée par /files/upload
            userRepository.save(user);
            
            return ResponseEntity.ok("Profil mis à jour avec succès.");
        } catch (Exception e) {
            return ResponseEntity.status(401).body("Token invalide.");
        }
    }


    @GetMapping("/me")
    public ResponseEntity<?> getCurrentUser(@RequestHeader("Authorization") String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Token manquant ou invalide.");
        }
        try {
            String email = jwtUtil.getEmailFromJwt(authHeader.substring(7));

            Auth auth = authRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Authentification introuvable."));
            User user = auth.getUser();
            if (user == null) return ResponseEntity.status(404).body("Utilisateur introuvable.");

            UserProfileDTO dto = new UserProfileDTO();
            dto.setId(user.getId());
            dto.setFirstName(user.getFirstName());
            dto.setLastName(user.getLastName());
            dto.setGender(user.getGender());
            dto.setBirthday(user.getBirthday());
            dto.setDescription(user.getDescription());
            dto.setPictureProfile(user.getPictureProfile());
            dto.setVerifiedProfile(user.isVerifiedProfile());
            dto.setPaymentMade(user.isPaymentMade());
            dto.setRole(user.getRole());
            return ResponseEntity.ok(dto);

        } catch (Exception e) {
            return ResponseEntity.status(401).body("Token invalide.");
        }
    }

    
	@GetMapping("/all")
	// => http://localhost:8080/api/user/all
	public ResponseEntity<List<User>> getAllUsers(){
		try {
			List<User> users = userService.getAllUser();
			return ResponseEntity.ok(users);  // Renvoie la liste des utilisateurs
		} catch (Exception e) {
			System.out.println("Erreur sur renvoies de liste getAllUsers");
			return ResponseEntity.status(500).body(null);  // En cas d'erreur, renvoie un code 500
		}
	}
	
	@GetMapping("/{id}")
	public ResponseEntity<UserProfileDTO> getUserById(@PathVariable Long id) {
	    Optional<User> userOpt = userRepository.findById(id);
	    if (userOpt.isEmpty()) {
	        return ResponseEntity.notFound().build();
	    }

	    User user = userOpt.get();
	    UserProfileDTO dto = new UserProfileDTO();
	    dto.setId(user.getId());
	    dto.setFirstName(user.getFirstName());
	    dto.setLastName(user.getLastName());
	    dto.setGender(user.getGender());
	    dto.setBirthday(user.getBirthday());
	    dto.setDescription(user.getDescription());
	    dto.setPictureProfile(user.getPictureProfile());
	    dto.setVerifiedProfile(user.isVerifiedProfile());
	    dto.setPaymentMade(user.isPaymentMade());
	   

	    return ResponseEntity.ok(dto);
	}

	@DeleteMapping("/remove/{id}")
	// => http://localhost:8080/api/user/remove/1
	public ResponseEntity<String> deleteUser(@PathVariable Long id) {
		try {
			if (userService.deleteUser(id)) {
				return new ResponseEntity<>("Utilisateur supprimée avec succès", HttpStatus.OK);
			} else {
				return new ResponseEntity<>("Échec de la suppression", HttpStatus.NOT_FOUND);
			}
		} catch (Exception e) {
			return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
		}
	}
	

	
	 // Récupérer l'historique des activités créées par l'utilisateur
    @GetMapping("/{userId}/created-activities")
	// => http://localhost:8080/api/user
    public ResponseEntity<List<Activity>> getCreatedActivities(@PathVariable Long userId) {
        List<Activity> createdActivities = activityService.getCreatedActivities(userId);
        return ResponseEntity.ok(createdActivities);
    }

    // Récupérer l'historique des participations de l'utilisateur
    @GetMapping("/{userId}/participations")
	// => http://localhost:8080/api/user
    public ResponseEntity<List<Participant>> getParticipationHistory(@PathVariable Long userId) {
        List<Participant> participations = participantService.getParticipationHistory(userId);
        return ResponseEntity.ok(participations);
    }

    
    
    
}
