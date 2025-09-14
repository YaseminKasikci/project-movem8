package fr.yasemin.movem8.service.impl;

import fr.yasemin.movem8.entity.Friendship;
import fr.yasemin.movem8.entity.User;
import fr.yasemin.movem8.repository.IFriendshipRepository;
import fr.yasemin.movem8.repository.IUserRepository;
import fr.yasemin.movem8.service.IFriendshipService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class FriendshipServiceImpl implements IFriendshipService {

    @Autowired
    private IFriendshipRepository friendshipRepository;

    @Autowired
    private IUserRepository userRepository;

    @Override
    public boolean addFriend(Long user1Id, Long user2Id) {
        // Vérifier que les utilisateurs existent
        User user1 = userRepository.findById(user1Id).orElse(null);
        User user2 = userRepository.findById(user2Id).orElse(null);
        
        if (user1 == null || user2 == null) {
            return false;  // Un des utilisateurs n'existe pas
        }

        // Vérifier si les utilisateurs sont déjà amis
        if (areFriends(user1Id, user2Id)) {
            return false;  // Ils sont déjà amis
        }

        // Créer une nouvelle amitié
        Friendship friendship = new Friendship();
        friendship.setUser1(user1);
        friendship.setUser2(user2);
        friendship.setFriendshipDate(LocalDateTime.now());

        // Sauvegarder l'amitié
        friendshipRepository.save(friendship);
        return true;
    }

    @Override
    public boolean removeFriend(Long user1Id, Long user2Id) {
        // Vérifier si les utilisateurs sont amis
        Friendship friendship = friendshipRepository.findByUser1IdAndUser2Id(user1Id, user2Id);
        if (friendship == null) {
            return false;  // Ils ne sont pas amis
        }

        // Supprimer l'amitié
        friendshipRepository.delete(friendship);
        return true;
    }

    @Override
    public List<Friendship> getUserFriends(Long userId) {
        // Récupérer toutes les amitiés pour un utilisateur
        return friendshipRepository.findByUser1IdOrUser2Id(userId, userId);
    }

    @Override
    public boolean areFriends(Long user1Id, Long user2Id) {
        // Vérifier si une amitié existe entre deux utilisateurs
        Friendship friendship1 = friendshipRepository.findByUser1IdAndUser2Id(user1Id, user2Id);
        Friendship friendship2 = friendshipRepository.findByUser1IdAndUser2Id(user2Id, user1Id);

        return friendship1 != null || friendship2 != null;  // L'un ou l'autre de ces deux enregistrements doit exister
    }
}
