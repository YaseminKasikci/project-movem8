package fr.yasemin.movem8.service;

import java.util.List;
import java.util.Optional;

import fr.yasemin.movem8.dto.UserProfileDTO;
import fr.yasemin.movem8.entity.User;

public interface IUserService {
	// JAVA DOC ET ANNOTATION

	User getUserById(Long id) throws Exception;

	User updateUser(User user) throws Exception;

	boolean deleteUser(Long id) throws Exception;
	
	List<User> getAllUser() throws Exception;
	
	void chooseCommunity(Long userId, Long communityId) throws Exception;

    void completeProfile(String email, UserProfileDTO dto);

}
