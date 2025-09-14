package fr.yasemin.movem8.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import fr.yasemin.movem8.dto.UserProfileDTO;
import fr.yasemin.movem8.entity.Auth;
import fr.yasemin.movem8.entity.Community;
import fr.yasemin.movem8.entity.User;
import fr.yasemin.movem8.repository.IAuthRepository;
import fr.yasemin.movem8.repository.ICommunityRepository;
import fr.yasemin.movem8.repository.IUserRepository;
import fr.yasemin.movem8.service.IUserService;

@Service
public class UserServiceImpl implements IUserService {

	@Autowired
	private IUserRepository userRepository;

	@Autowired
	private ICommunityRepository communityRepository;
	
	@Autowired IAuthRepository authRepository;



	@Override
	public User updateUser(User user) throws Exception {

		return userRepository.save(user);
	}

	@Override
	public boolean deleteUser(Long id) throws Exception {
		userRepository.deleteById(id);
		return true;

	}

	@Override
	public List<User> getAllUser() throws Exception {
		return userRepository.findAll();
	}
	
	   @Override
	    public void completeProfile(String email, UserProfileDTO dto) {
	        Auth auth = authRepository.findByEmail(email)
	            .orElseThrow(() -> new RuntimeException("Utilisateur introuvable."));
	        User user = auth.getUser();
	        user.setFirstName(dto.getFirstName());
	        user.setLastName(dto.getLastName());
	        user.setDescription(dto.getDescription());
	        user.setGender(dto.getGender());
	        user.setBirthday(dto.getBirthday());
	        user.setPictureProfile(dto.getPictureProfile());
	        userRepository.save(user);
	    }


	public void chooseCommunity(Long userId, Long communityId) throws Exception {
		User user = userRepository.findById(userId).orElseThrow(() -> new Exception("Utilisateur non trouvé"));
		Community community = communityRepository.findById(communityId)
				.orElseThrow(() -> new Exception("Communauté non trouvée"));

		// Vérifie si l'utilisateur est membre de la communauté
		if (!community.getMembers().contains(user)) {
			throw new Exception("L'utilisateur ne fait pas partie de cette communauté.");
		}

		user.setCommunity(community);
		userRepository.save(user);
	}

	@Override
	public User getUserById(Long id) throws Exception {

		return userRepository.findById(id).orElse(null);
	}

}
