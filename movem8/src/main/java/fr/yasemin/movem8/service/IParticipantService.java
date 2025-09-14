package fr.yasemin.movem8.service;

import java.util.List;

import fr.yasemin.movem8.entity.Participant;

public interface IParticipantService {
	
	   List<Participant> getParticipationHistory(Long userId);
}
