package fr.yasemin.movem8.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Entity
@Table(name = "sports")
@Getter @Setter @AllArgsConstructor @ToString @NoArgsConstructor
@Builder

public class Sport {
	
	@Id
	 @Column(name = "id_sport")
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@Column(name = "name", nullable = false, length = 100, unique = true)
	private String sportName;
	
	@Column(name = "icon", nullable = true)
	private String iconUrl;
	

    @ManyToOne
    @JoinColumn(name = "category_id")
    private Category category;


}
