package fr.yasemin.movem8.service;

import java.util.List;

import fr.yasemin.movem8.entity.Community;



public interface ICommunityService {

	
	void joinCommunity(Long userId, Long communityId) throws Exception;
	
	void chooseCommunity(Long userId, Long communityId) throws Exception;
	
	Community addCommunity(Community community) throws Exception;
	
	
	Community updateCommunity(Community community) throws Exception;
	
	boolean deleteCommunity(Long id) throws Exception;
	
	List<Community> getAllCommunity() throws Exception;

	 Community getCommunityById(Long id) throws Exception ;


	
}
