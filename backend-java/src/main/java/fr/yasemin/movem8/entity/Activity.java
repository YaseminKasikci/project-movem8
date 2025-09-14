package fr.yasemin.movem8.entity;

import java.time.LocalDateTime;
import java.util.List;

import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import fr.yasemin.movem8.enums.Level;
import fr.yasemin.movem8.enums.StatusActivity;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Entity
@Table(name = "activity")
@Getter @Setter @AllArgsConstructor @ToString @NoArgsConstructor
@Builder
@JsonIgnoreProperties({"participants"})
public class Activity {
	
	@Id 
	@Column(name = "id_activity")
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@Column(name = "title", nullable = true, length = 100)
	private String title;

	@Column(name = "photo", nullable = true, length = 255)
	private String photo;

	@Column(name = "description", nullable = true, length = 500)
	private String description;

	@Column(name = "location", nullable = true, length = 255)
	private String location;
	
	@JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
	@Column(name = "date_hour", nullable = false)
	private LocalDateTime dateHour;
	
	@Column(name = "price", nullable = false)
	private Float price;
	
	@Column(name="note", nullable = false)
	private Float note;

	@Column(name = "number_of_participants", nullable = true)
	private int numberOfParticipant;
	
	@Column(name = "creator_level", nullable = false, length = 50)
	@Enumerated(EnumType.STRING)
	private Level level;


	@Column(name = "status_activity", nullable = false)
	@Enumerated(EnumType.STRING)
	private StatusActivity statusActivity;
	
	//Activité est creer par un utilisateur
	@JsonIgnore
	@ManyToOne
	@JoinColumn(name = "creator_id", nullable = false)
	@OnDelete(action = OnDeleteAction.CASCADE)
	private User creator;

	// une activité peut avoir plusieurs participants lier par table participant
	@OneToMany(
		    mappedBy = "activity",
		    fetch = FetchType.LAZY,
		    cascade = CascadeType.REMOVE,   
		    orphanRemoval = true
		)
		private List<Participant> participants;


	// L’activité appartient à une communauté
	@ManyToOne
	@JoinColumn(name = "community_id")
	private Community community;

	@ManyToOne
	@JoinColumn(name = "category_id")
	private Category category;
	
	@ManyToOne
	@JoinColumn(name = "sport_id")
	private Sport sport;
}
