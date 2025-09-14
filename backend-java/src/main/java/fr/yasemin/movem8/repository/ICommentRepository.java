package fr.yasemin.movem8.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import fr.yasemin.movem8.entity.Comment;
import fr.yasemin.movem8.entity.Participant;
import fr.yasemin.movem8.enums.StatusParticipant;

@Repository
public interface ICommentRepository extends JpaRepository<Comment, Long> {
    List<Comment> findByActivityId(Long activityId);
  
}
//je voudrais aussi affiché les historiques de creation d'activité et les historique de participation sur le profil des utilisateur