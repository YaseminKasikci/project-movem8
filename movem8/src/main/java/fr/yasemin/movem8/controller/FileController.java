// src/main/java/fr/yasemin/movem8/controller/FileController.java
package fr.yasemin.movem8.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.nio.file.*;
import java.util.Set;
import java.util.UUID;

@RestController
@RequestMapping("/api/files")
@CrossOrigin // ajuste selon ton front
public class FileController {

  private final Path root = Paths.get("upload");

  @Value("${app.base-url:http://localhost:8080}")
  private String baseUrl;

  private static final Set<String> ALLOWED = Set.of(
		    "image/png", "image/jpeg", "image/webp", "image/svg+xml",
		    "image/heic", "image/heif", "application/octet-stream"
		);

  @PostMapping("/upload")
  public ResponseEntity<?> upload(
      @RequestParam("file") MultipartFile file,
      @RequestParam(name = "type", defaultValue = "misc") String type
  ) {
    try { 
      if (file.isEmpty()) return ResponseEntity.badRequest().body("Fichier vide");
      
      System.out.println("UPLOAD Content-Type = " + file.getContentType());
      
      if (!ALLOWED.contains(file.getContentType()))
        return ResponseEntity.badRequest().body("Type non supporté");

      String safeType = switch (type.toLowerCase()) {
        case "profiles" -> "profiles";
        case "activities" -> "activities";
        case "sports" -> "sports";
       
        default -> "misc";
      };

      Path folder = root.resolve(safeType);
      Files.createDirectories(folder);

      String original = StringUtils.cleanPath(file.getOriginalFilename());
      String filename = UUID.randomUUID() + "_" + original.replace(" ", "_");
      Path filePath = folder.resolve(filename);
      Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

      String publicUrl = String.format("%s/upload/%s/%s", baseUrl, safeType, filename);
      return ResponseEntity.ok(publicUrl);

    } catch (Exception e) {
      return ResponseEntity.internalServerError().body("Erreur upload: " + e.getMessage());
    }
  }
}
