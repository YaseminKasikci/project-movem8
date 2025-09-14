package fr.yasemin.movem8.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import fr.yasemin.movem8.entity.Friendship;

@Repository
public interface IFriendshipRepository extends JpaRepository<Friendship, Long> {
    Friendship findByUser1IdAndUser2Id(Long user1Id, Long user2Id);  // Trouver l'amitié entre deux utilisateurs
    List<Friendship> findByUser1IdOrUser2Id(Long userId1, Long userId2);  // Trouver toutes les amitiés d'un utilisateur

}