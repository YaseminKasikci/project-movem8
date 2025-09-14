package fr.yasemin.movem8.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import fr.yasemin.movem8.entity.Community;
import fr.yasemin.movem8.entity.User;
import fr.yasemin.movem8.repository.ICommunityRepository;
import fr.yasemin.movem8.repository.IUserRepository;
import fr.yasemin.movem8.service.ICommunityService;
import jakarta.transaction.Transactional;
@Service
public class CommunityServiceImpl implements ICommunityService {
	@Autowired
	private IUserRepository userRepository;
	@Autowired
	private ICommunityRepository communityRepository;
	
	
	
	@Override
	public List<Community> getAllCommunity() throws Exception {
		return communityRepository.findAll();
	}

	@Override
	public Community getCommunityById(Long id) throws Exception {
		return communityRepository.findById(id).orElse(null);
	}

	@Override
	public Community addCommunity(Community community) throws Exception {

		return communityRepository.save(community);
	}

	@Override
	public Community updateCommunity(Community community) throws Exception {
			return communityRepository.save(community);
	}

	@Override
	@Transactional
	public boolean deleteCommunity(Long id) throws Exception {
	    Community c = communityRepository.findById(id)
	        .orElseThrow(() -> new Exception("Communauté introuvable"));

	    // détacher tous les users
	    List<User> users = userRepository.findAllByCommunityId(id);
	    for (User u : users) {
	        u.setCommunity(null);
	    }
	    userRepository.saveAll(users);

	    communityRepository.delete(c);
	    return true;
	}

	

	 @Override
	    @Transactional
	    public void joinCommunity(Long userId, Long communityId) throws Exception {
	        User user = userRepository.findById(userId)
	            .orElseThrow(() -> new Exception("Utilisateur introuvable."));
	        Community community = communityRepository.findById(communityId)
	            .orElseThrow(() -> new Exception("Communauté introuvable."));
	        if (!community.getMembers().contains(user)) {
	            community.getMembers().add(user);
	            communityRepository.save(community);
	        }
	    }

	    @Override
	    @Transactional
	    public void chooseCommunity(Long userId, Long communityId) throws Exception {
	        User user = userRepository.findById(userId)
	            .orElseThrow(() -> new Exception("Utilisateur introuvable."));
	        Community community = communityRepository.findById(communityId)
	            .orElseThrow(() -> new Exception("Communauté introuvable."));

	        user.setCommunity(community);
	        userRepository.save(user);
	    }




}
