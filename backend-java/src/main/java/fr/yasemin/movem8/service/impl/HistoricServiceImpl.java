package fr.yasemin.movem8.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import fr.yasemin.movem8.entity.Historic;
import fr.yasemin.movem8.enums.RoleHistoric;
import fr.yasemin.movem8.repository.IHistoricRepository;
import fr.yasemin.movem8.service.IHistoricService;
@Service
public class HistoricServiceImpl implements IHistoricService{
@Autowired
	private IHistoricRepository historicRepository;
	@Override
	public List<Historic> getUserHistoricByRole(Long userId, RoleHistoric role) {

		return historicRepository.findByUserIdAndRole(userId, role);
	}

}
