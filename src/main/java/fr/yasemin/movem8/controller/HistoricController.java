package fr.yasemin.movem8.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import fr.yasemin.movem8.entity.Historic;
import fr.yasemin.movem8.enums.RoleHistoric;
import fr.yasemin.movem8.service.IHistoricService;
@RestController
@CrossOrigin("http://localhost:8080")
@RequestMapping("/api/histories")
public class HistoricController {
	
	
	@Autowired
	private IHistoricService historicService;
	
	@GetMapping("/{userId}/historic/{role}")
	// => http://localhost:8080/api/histories/1/historic/C
	public ResponseEntity<List<Historic>> getHistoricByRole(@PathVariable Long userId, @PathVariable RoleHistoric role ) {
	    List<Historic> history = historicService.getUserHistoricByRole(userId, role);
	    return ResponseEntity.ok(history);
	}

}

//GET /api/users/45/historic/role/C  → récupère les activités créées
//GET /api/users/45/historic/role/P  → récupère les participations
