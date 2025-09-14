package fr.yasemin.movem8.service;

import java.util.List;

import fr.yasemin.movem8.entity.Category;

public interface ICategoryService {

	// CRUD


	Category getCategoryById(Long id) throws Exception;
	
	Category createCategory(Category category) throws Exception;

	Category updateCategory(Category category) throws Exception;

	boolean deleteCategory(Long id) throws Exception;

	List<Category> getAllCategories() throws Exception;


}
