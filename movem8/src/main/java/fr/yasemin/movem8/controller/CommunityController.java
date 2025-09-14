package fr.yasemin.movem8.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import fr.yasemin.movem8.entity.Community;
import fr.yasemin.movem8.service.ICommunityService;
import fr.yasemin.movem8.service.IUserService;

@RestController

@CrossOrigin("http://localhost:8080")
@RequestMapping("/api/communities")
public class CommunityController {

	@Autowired
	private IUserService userService;

	@Autowired
	private ICommunityService communityService;
    // --- Actions utilisateur (auth) ---
	 /** Rejoindre */
    @PostMapping("/users/{userId}/join-community/{communityId}")
    public ResponseEntity<?> join(@PathVariable Long userId, @PathVariable Long communityId) {
        try {
            communityService.joinCommunity(userId, communityId);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    /** Sélectionner */
    @PostMapping("/users/{userId}/choose-community/{communityId}")
    public ResponseEntity<?> choose(@PathVariable Long userId, @PathVariable Long communityId) {
        try {
            communityService.chooseCommunity(userId, communityId);
            return ResponseEntity.ok().body("Communauté active mise à jour");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
	// recupere toute les communités
    // --- Lecture publique ---
	@GetMapping("/all")
	   // => http://localhost:8080/api/communities/all
	public ResponseEntity<List<Community>> getAllCommunities() {
		try {
			return ResponseEntity.ok(communityService.getAllCommunity());
		} catch (Exception e) {
			return ResponseEntity.status(500).body(null);
		}
	}

	@PostMapping("save")
	   // => http://localhost:8080/api/communities/save
	public ResponseEntity<Community> createCommunity(@RequestBody Community community) {
		try {
			Community created = communityService.addCommunity(community);
			return new ResponseEntity<>(created, HttpStatus.CREATED);
		} catch (Exception e) {
			return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
		}
	}

	@PreAuthorize("hasRole('ADMIN')")
	@PatchMapping("/update/{id}")
	   // => http://localhost:8080/api/communities/update/1
    public ResponseEntity<Community> updateCommunity(@PathVariable Long id, @RequestBody Community community) {
        try {
            community.setId(id); // 👈 important si l'ID n'est pas dans le body
            Community updatedCommunity = communityService.updateCommunity(community);
            return new ResponseEntity<>(updatedCommunity, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }
	
	@PreAuthorize("hasRole('ADMIN')")
	@GetMapping("/{id}")
	   // => http://localhost:8080/api/communities/1
	public ResponseEntity<Community> getCommunityById(@PathVariable Long id) throws Exception {
		try {
			Community community = communityService.getCommunityById(id);
			if (community != null) {
				return new ResponseEntity<>(community, HttpStatus.OK);
			} else {
				return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
			}
		} catch (Exception e) {
			return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
		}
	}
	
	@PreAuthorize("hasRole('ADMIN')")
	@DeleteMapping("/delete/{id}")
	   // => http://localhost:8080/api/communities/delete/1
	public ResponseEntity<Void> deleteCommunity(@PathVariable Long id) {
	    try {
	        boolean deleted = communityService.deleteCommunity(id);
	        return deleted ? ResponseEntity.noContent().build()
	                       : ResponseEntity.notFound().build();
	    } catch (Exception e) {
	        return ResponseEntity.internalServerError().build();
	    }
	}
}

//@GetMapping("/communities")
//public List<Community> getAllCommunities() { ... }
//
//@PostMapping("/communities")
//public Community createCommunity(@RequestBody Community c) { ... }
//
//@PutMapping("/users/{userId}/community/{communityId}")
//public ResponseEntity<?> assignUserToCommunity(...) { ... }