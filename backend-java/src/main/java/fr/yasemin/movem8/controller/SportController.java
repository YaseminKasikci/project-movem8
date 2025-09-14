package fr.yasemin.movem8.controller;

import java.io.IOException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import fr.yasemin.movem8.entity.Category;
import fr.yasemin.movem8.entity.Sport;
import fr.yasemin.movem8.service.ISportService;

@RestController
@CrossOrigin("http://localhost:8080")
@RequestMapping("/api/sports")
public class SportController {

    @Autowired
    private ISportService sportService;


    @PostMapping(value = "/save", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Sport> saveSport(
            @RequestParam("sportName") String sportName,
            @RequestParam("categoryId") Long categoryId,
            @RequestPart(value = "icon", required = false) MultipartFile file
    ) {
        try {
            Sport sport = new Sport();
            sport.setSportName(sportName);

            Category category = new Category();
            category.setId(categoryId);
            sport.setCategory(category);

            System.out.println("✅ Fichier reçu: " + (file != null ? file.getOriginalFilename() : "aucun"));
            System.out.println("✅ Type MIME: " + (file != null ? file.getContentType() : "aucun"));

            
            Sport saved = sportService.create(sport, file);
            return ResponseEntity.status(HttpStatus.CREATED).body(saved);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .build();
        }
    }

    
    // 🔍 Obtenir une catégorie par son ID
    @GetMapping("/{id}")
 // => http://localhost:8080/api/sports/1
    public ResponseEntity<Sport> getCategoryById(@PathVariable Long id) throws Exception {
    	Sport sport = sportService.getSportById(id);
        if (sport != null) {
            return new ResponseEntity<>(sport, HttpStatus.OK);
        } else {
            return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
        }
    }
    
    // 📋 Obtenir tous les sports
    @GetMapping("/all")
    public ResponseEntity<List<Sport>> getAllSports() {
        try {
            return ResponseEntity.ok(sportService.getAllSports());
        } catch (Exception e) {
            return ResponseEntity.status(500).body(null);
        }
    }
    
    // 🔍 Obtenir les sports par ID de catégorie
    @GetMapping("/category/{categoryId}")
    // => http://localhost:8080/api/sports/category/1
    public ResponseEntity<List<Sport>> getSportsByCategory(@PathVariable Long categoryId) {
        try {
            List<Sport> sports = sportService.getSportsByCategoryId(categoryId);
            return new ResponseEntity<>(sports, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }
    
    @PatchMapping("/update/{id}")
    public ResponseEntity<Sport> updateSport(
            @PathVariable Long id,
            @RequestParam(required = false) String sportName,
            @RequestParam(required = false) MultipartFile icon
    ) throws IOException {
        Sport updated = sportService.update(id, sportName, icon);
        return ResponseEntity.ok(updated);
    }


//    @PatchMapping(value = "/update/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
//    public ResponseEntity<?> updateSport(
//        @PathVariable Long id,
//        @RequestPart("sportName") String sportName,
//        @RequestPart(value = "icon", required = false) MultipartFile iconFile
//    ) {
//        try {
//            sportService.updateSportUrl(id, sportName, iconFile);
//            return ResponseEntity.ok().build();
//        } catch (Exception e) {
//            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
//        }
//    }


    
    @DeleteMapping("/delete/{id}")
    // => http://localhost:8080/api/sports/remove/1
    public ResponseEntity<Void> deleteSport(@PathVariable Long id) {
	    try {
	        boolean deleted = sportService.deleteSport(id);
	        if (deleted) {
	            return ResponseEntity.noContent().build(); // 204
	        } else {
	            return ResponseEntity.notFound().build();  // 404
	        }
	    } catch (Exception e) {
	        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build(); // 500
	    }
	}

    
}
