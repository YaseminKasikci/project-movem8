package fr.yasemin.movem8.service;

import java.util.List;

import fr.yasemin.movem8.entity.Historic;
import fr.yasemin.movem8.enums.RoleHistoric;

public interface IHistoricService {
	
	 List<Historic> getUserHistoricByRole(Long userId, RoleHistoric role); 
}
