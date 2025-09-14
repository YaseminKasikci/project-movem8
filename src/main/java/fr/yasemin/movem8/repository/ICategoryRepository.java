package fr.yasemin.movem8.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import fr.yasemin.movem8.entity.Category;

@Repository
public interface ICategoryRepository extends JpaRepository<Category, Long> {
	// getAllSportFromWaterCategory ? ect..

}