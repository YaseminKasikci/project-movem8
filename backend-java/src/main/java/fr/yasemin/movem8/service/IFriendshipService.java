package fr.yasemin.movem8.service;

import java.util.List;

import fr.yasemin.movem8.entity.Friendship;

public interface IFriendshipService {
    boolean addFriend(Long user1Id, Long user2Id);  // Ajouter un ami
    boolean removeFriend(Long user1Id, Long user2Id);  // Supprimer un ami
    List<Friendship> getUserFriends(Long userId);  // Récupérer la liste des amis
    boolean areFriends(Long user1Id, Long user2Id);  // Vérifier si deux utilisateurs sont amis
}
