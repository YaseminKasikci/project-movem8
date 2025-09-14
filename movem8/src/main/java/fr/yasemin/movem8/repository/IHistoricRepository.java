package fr.yasemin.movem8.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import fr.yasemin.movem8.entity.Historic;
import fr.yasemin.movem8.enums.RoleHistoric;

@Repository
public interface IHistoricRepository extends JpaRepository<Historic, Long>  {
	List<Historic> findByUserIdAndRole(Long userId, RoleHistoric role);


}
