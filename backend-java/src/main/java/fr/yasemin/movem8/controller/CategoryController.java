package fr.yasemin.movem8.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import fr.yasemin.movem8.entity.Activity;
import fr.yasemin.movem8.entity.Category;
import fr.yasemin.movem8.service.ICategoryService;


@CrossOrigin("http://localhost:8080")
@RestController
@RequestMapping("/api/categories")
public class CategoryController {

    @Autowired
    private ICategoryService categoryService;

    @PostMapping("/save")
    // => http://localhost:8080/api/categories/save
    public ResponseEntity<Category> createCategory(@RequestBody Category category) {
        try {
            Category created = categoryService.createCategory(category);
            return new ResponseEntity<>(created, HttpStatus.CREATED);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }

    // 📋 Obtenir toutes les catégories
    @GetMapping("all")
    // => http://localhost:8080/api/categories/all
    public ResponseEntity<List<Category>> getAllCategories() {
        try {
            return ResponseEntity.ok(categoryService.getAllCategories());
        } catch (Exception e) {
            return ResponseEntity.status(500).body(null);
        }
    }

    // 🔍 Obtenir une catégorie par son ID
    @GetMapping("/{id}")
    // => http://localhost:8080/api/categories/1
    public ResponseEntity<Category> getCategoryById(@PathVariable Long id) throws Exception {
        Category category = categoryService.getCategoryById(id);
        if (category != null) {
            return new ResponseEntity<>(category, HttpStatus.OK);
        } else {
            return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
        }
    }
    

    @PatchMapping("update/{id}")
    // => http://localhost:8080/api/categories/update/1
    public ResponseEntity<Category> patchCategory(@PathVariable Long id, @RequestBody Category category) {
        try {
        	 category.setId(id);
            Category updatedCategory = categoryService.updateCategory(category);
            return new ResponseEntity<>(updatedCategory, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }
    
    @DeleteMapping("/delete/{id}")
    // => http://localhost:8080/api/categories/remove/1
    	public ResponseEntity<Void> deleteCategory(@PathVariable Long id) {
    	    try {
    	        boolean deleted = categoryService.deleteCategory(id);
    	        if (deleted) {
    	            return ResponseEntity.noContent().build(); // 204
    	        } else {
    	            return ResponseEntity.notFound().build();  // 404
    	        }
    	    } catch (Exception e) {
    	        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build(); // 500
    	    }
    	}

}
