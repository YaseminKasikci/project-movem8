package fr.yasemin.movem8.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import fr.yasemin.movem8.entity.Community;
import fr.yasemin.movem8.entity.User;

@Repository
public interface ICommunityRepository extends JpaRepository<Community, Long>{


}
