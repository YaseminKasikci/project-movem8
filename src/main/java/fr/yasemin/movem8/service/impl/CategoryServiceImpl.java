package fr.yasemin.movem8.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import fr.yasemin.movem8.entity.Category;
import fr.yasemin.movem8.repository.ICategoryRepository;
import fr.yasemin.movem8.service.ICategoryService;

@Service
public class CategoryServiceImpl implements ICategoryService {
	@Autowired
	private ICategoryRepository categoryRepository;

	@Override
	public Category createCategory(Category category) throws Exception {
		return categoryRepository.save(category);
	}

	@Override
	public Category updateCategory(Category incoming) throws Exception {
	    Category existing = categoryRepository.findById(incoming.getId())
	        .orElseThrow(() -> new Exception("Catégorie introuvable"));

	    if (incoming.getCategoryName() != null) {
	        existing.setCategoryName(incoming.getCategoryName());
	    }

	    if (incoming.getIcon() != null) {
	        existing.setIcon(incoming.getIcon());
	    }

	    return categoryRepository.save(existing);
	}


	@Override
	public boolean deleteCategory(Long id) throws Exception {
		if (categoryRepository.existsById(id)) {
			categoryRepository.deleteById(id);
			return true;
		} else {
			return false;
		}
	}

	@Override
	public List<Category> getAllCategories() throws Exception {
		return categoryRepository.findAll();
	}

	@Override
	public Category getCategoryById(Long id) throws Exception {
		return categoryRepository.findById(id).orElse(null);
	}

//	@Override
//	public Category patchCategory(Category partialCategory) throws Exception {
//		Category existing = categoryRepository.findById(partialCategory.getId())
//				.orElseThrow(() -> new Exception("Category not found"));
//
//		if (partialCategory.getCategoryName() != null) {
//			existing.setCategoryName(partialCategory.getCategoryName());
//		}
//
//		return categoryRepository.save(existing);
//	}

}
