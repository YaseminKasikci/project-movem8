package fr.yasemin.movem8.service.impl;

import java.time.LocalDateTime;
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
import fr.yasemin.movem8.service.IMailService;
import fr.yasemin.movem8.service.IUserService;

@Service
public class UserServiceImpl implements IUserService {

	@Autowired
	private IUserRepository userRepository;

	@Autowired
	private ICommunityRepository communityRepository;
	
	@Autowired IAuthRepository authRepository;
	
    @Autowired
    private IMailService mailService;



	

    /**
     * Met à jour les informations d’un utilisateur.
     * 
     * @param user l’utilisateur à mettre à jour
     * @return l’utilisateur mis à jour et sauvegardé
     * @throws Exception en cas d’erreur de persistence
     */
	@Override
	public User updateUser(User user) throws Exception {

		return userRepository.save(user);
	}
	
	
	 /**
     * Supprime un utilisateur par son identifiant.
     * 
     * @param id identifiant de l’utilisateur
     * @return true si la suppression a eu lieu
     * @throws Exception si la suppression échoue
     */
	@Override
	public boolean deleteUser(Long id) throws Exception {
		userRepository.deleteById(id);
		return true;

	}

	/**
    * Récupère tous les utilisateurs en base.
    * 
    * @return liste de tous les utilisateurs
    * @throws Exception si la récupération échoue
    */
	@Override
	public List<User> getAllUser() throws Exception {
		return userRepository.findAll();
	}
	
	
	   /**
     * Complète le profil d’un utilisateur déjà existant.
     * - Recherche l’utilisateur par son email via l’entité Auth.
     * - Met à jour les champs du User avec les données du DTO.
     * 
     * @param email email de l’utilisateur connecté
     * @param dto   données de profil (prénom, nom, description, genre, date de naissance, photo)
     * @throws RuntimeException si aucun utilisateur trouvé pour cet email
     */
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
	        
	        // 🔔 Mail de modification de profil
	        mailService.sendSimpleMail(
	            email,
	            "Profil mis à jour",
	            "Bonjour " + (user.getFirstName() != null ? user.getFirstName() : "") 
	            + ",\n\nVotre profil a été modifié le " + LocalDateTime.now() + "."
	        );
	    }

	   /**
	     * Permet à un utilisateur de choisir une communauté.
	     * - Vérifie que l’utilisateur existe.
	     * - Vérifie que la communauté existe.
	     * - Vérifie que l’utilisateur est déjà membre de la communauté.
	     * - Si oui, associe l’utilisateur à la communauté.
	     * 
	     * @param userId      identifiant de l’utilisateur
	     * @param communityId identifiant de la communauté
	     * @throws Exception si l’utilisateur ou la communauté est introuvable, 
	     *                   ou si l’utilisateur n’est pas membre de la communauté
	     */
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

	 /**
     * Récupère un utilisateur par son identifiant.
     * 
     * @param id identifiant de l’utilisateur
     * @return l’utilisateur correspondant ou null si inexistant
     * @throws Exception si la récupération échoue
     */
	@Override
	public User getUserById(Long id) throws Exception {

		return userRepository.findById(id).orElse(null);
	}

}
