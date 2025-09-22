package fr.yasemin.movem8.service.impl;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import fr.yasemin.movem8.entity.Category;
import fr.yasemin.movem8.entity.Sport;
import fr.yasemin.movem8.repository.ICategoryRepository;
import fr.yasemin.movem8.repository.ISportRepository;
import fr.yasemin.movem8.service.ISportService;

@Service
public class SportServiceImpl implements ISportService {

	@Autowired
	private ISportRepository sportRepository;

	@Autowired
	ICategoryRepository categoryRepository;
	
	@Override
	public Sport  getSportById(Long id) throws Exception {
		return sportRepository.findById(id).orElse(null);
	}
	

	@Override
	public Sport create(Sport sport, MultipartFile file) throws IOException {
	    try {
	        if (file != null && !file.isEmpty()) {
	            // 🔥 Chemin absolu dynamique basé sur le répertoire de l'application
	            String uploadDir = System.getProperty("user.dir") + "/upload/sports";

	            // Création du dossier si inexistant
	            File directory = new File(uploadDir);
	            if (!directory.exists()) {
	                directory.mkdirs();
	            }

	            //  Nom unique pour éviter les conflits
	            String fileName = UUID.randomUUID() + "_" + file.getOriginalFilename();

	            //  Chemin final du fichier
	            Path filePath = Paths.get(uploadDir, fileName);

	            //  Sauvegarde du fichier
	            file.transferTo(filePath.toFile());

	            //  URL d'accès public (à adapter si tu es en prod)
	            String fileUrl = "http://localhost:8080/upload/sports/" + fileName;
	            sport.setIconUrl(fileUrl);
	        }

	        return sportRepository.save(sport);

	    } catch (IOException e) {
	        e.printStackTrace();
	        throw new RuntimeException("Erreur lors de l’enregistrement de l’icône", e);
	    }
	}




	@Override
	public boolean deleteSport(Long id) throws Exception {
	    if (sportRepository.existsById(id)) {
	        Sport sport = sportRepository.findById(id).orElse(null);
	        if (sport != null && sport.getIconUrl() != null) {
	            // 🔥 Supprime aussi le fichier image
	            String filePath = sport.getIconUrl().replace("http://localhost:8080/upload/sports/", "");
	            Path path = Paths.get(System.getProperty("user.dir") + "/upload/sports/" + filePath);
	            Files.deleteIfExists(path);
	        }
	        sportRepository.deleteById(id);
	        return true;
	    }
	    return false;
	}


	@Override
	public List<Sport> getAllSports() throws Exception {
		return sportRepository.findAll();
	}

	@Override
	public List<Sport> getSportsByCategoryId(Long categoryId) {
		return sportRepository.findByCategoryId(categoryId);
	}
	
	@Override
	public Sport update(Long id, String sportName, MultipartFile iconFile)  throws IOException{
	    Sport sport = sportRepository.findById(id)
	        .orElseThrow(() -> new RuntimeException("Sport introuvable avec l'id: " + id));

	    // 🔤 Mise à jour du nom
	    if (sportName != null && !sportName.isEmpty()) {
	        sport.setSportName(sportName);
	    }

	    // 🖼 Mise à jour de l’icône si fournie
	    if (iconFile != null && !iconFile.isEmpty()) {
	        try {
	            String uploadDir = System.getProperty("user.dir") + "/upload/sports";
	            File directory = new File(uploadDir);
	            if (!directory.exists()) {
	                directory.mkdirs();
	            }

	            String fileName = UUID.randomUUID() + "_" + iconFile.getOriginalFilename();
	            Path filePath = Paths.get(uploadDir, fileName);

	            // 💾 Sauvegarde
	            iconFile.transferTo(filePath.toFile());

	            // 🌐 Mise à jour de l'URL
	            String fileUrl = "http://localhost:8080/upload/sports/" + fileName;
	            sport.setIconUrl(fileUrl);

	        } catch (IOException e) {
	            e.printStackTrace();
	            throw new RuntimeException("Erreur lors de l’enregistrement de l’icône", e);
	        }
	    }

	    return sportRepository.save(sport);
	}

	
	@Override
	public Sport patchSport(Sport partialSport) throws Exception {
		Sport existing = sportRepository.findById(partialSport.getId())
				.orElseThrow(() -> new Exception("Sport not found"));

		if (partialSport.getSportName() != null) {
			existing.setSportName(partialSport.getSportName());
		}
		return sportRepository.save(existing);
	}

}
