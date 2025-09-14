package fr.yasemin.movem8.repository;




import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import fr.yasemin.movem8.entity.User;


@Repository
public interface IUserRepository extends JpaRepository<User, Long> {
	
	// IUserRepository
	List<User> findAllByCommunityId(Long communityId);
	List<User> findByCommunityId(Long communityId);
	
	
	//redefinition SOLID
	// creéer ses  propres methode 
	// mettre <List> si element non unique
	//List<User> findByRole(Role role);
	// List<User> findByRole(Role.ADMIN); 
	//List<User> findByLastNameContaining(String text);
	//List<User> findByBirthdayBetween(Date dateInf, Date dateSup);
	
	//List<User> findParticipantsByActivity(Activity activity);
	
	// methode a moi find mais pas findBY
	//@Query(value = "SELECT COUNT(u) FROM User u WHERE u.gender  = ?1", nativeQuery = false)
	
	//@Query(value = "SELECT COUNT(*) FROM users  WHERE gender  = ?1", nativeQuery = true)
	// false = SQL, True = JPQL
	
	//User countUsersByGenderS(String gender);
	//long countUsersByGender(String gender);
	
	
}
