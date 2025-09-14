package fr.yasemin.movem8.entity;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Entity
@Table(name = "category_sport")
@Getter @Setter @AllArgsConstructor @ToString @NoArgsConstructor
@Builder

@JsonIgnoreProperties({"activities", "sports"})
public class Category {
	
	@Id 
	@Column(name = "id_category")
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	
	private long id;
	
	@Column(name = "category_name", nullable = false, length = 100, unique = true)
	private String categoryName;
	
	@Column(name = "icon", nullable = true)
	private String icon;
	
    @OneToMany(mappedBy = "category", cascade = CascadeType.ALL)
    private List<Activity> activities;

    @OneToMany(mappedBy = "category", cascade = CascadeType.ALL)
    private List<Sport> sports;

	
}
