package fr.yasemin.movem8.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import fr.yasemin.movem8.entity.Participant;
import fr.yasemin.movem8.repository.IParticipantRepository;
import fr.yasemin.movem8.service.IParticipantService;
@Service
public class ParticipantServiceImpl implements IParticipantService {
	@Autowired
	private IParticipantRepository participantRepository;
	
	

	@Override
	public List<Participant> getParticipationHistory(Long userId) {
		return participantRepository.findByUserId(userId);
	}

}
