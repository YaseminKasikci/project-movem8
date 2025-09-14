package fr.yasemin.movem8.entity;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnore;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
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
@Table(name = "community")
@Getter @Setter @AllArgsConstructor @ToString @NoArgsConstructor
@Builder
public class Community {
	
	@Id
	 @Column(name = "id_community")
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@Column(name = "community_name", nullable = false, length = 100)
	private String communityName;
	
	@OneToMany(mappedBy = "community", fetch = FetchType.LAZY)
    @JsonIgnore
    private List<User> members;

   

}
