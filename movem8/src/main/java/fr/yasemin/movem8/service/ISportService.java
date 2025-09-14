package fr.yasemin.movem8.service;

import java.io.IOException;
import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import fr.yasemin.movem8.entity.Sport;

public interface ISportService {
	
	// CRUD ROLE ADMIN 
		Sport getSportById(Long id) throws Exception;
	
	//	Sport createSport(Long categoryId, String sportName, MultipartFile icon) throws  IOException;
		
//		Sport updateSport(Sport sport) throws Exception;
		
		Sport patchSport(Sport partialSport) throws Exception;
		
		boolean deleteSport(Long id) throws Exception;
		
		List<Sport> getAllSports() throws Exception;
		
		List<Sport> getSportsByCategoryId(Long categoryId) throws Exception;
		
		Sport update(Long id, String sportName, MultipartFile iconFile) throws IOException;

		Sport create(Sport sport, MultipartFile file) throws IOException;


}
