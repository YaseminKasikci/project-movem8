package fr.yasemin.movem8.entity;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Date;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import fr.yasemin.movem8.enums.Gender;
import fr.yasemin.movem8.enums.Role;
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
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Entity
@Table(name = "users")
@Getter
@Setter
@AllArgsConstructor
@ToString
@NoArgsConstructor
@Builder
@JsonIgnoreProperties({"participant", "createdActivities"})
public class User {

	@Id
	@Column(name = "id_user")
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@Column(name = "lastName", nullable = true, length = 100)
	private String lastName;
 
	@Column(name = "firstName", nullable = true, length = 100)
	private String firstName;
	

	@Column(name = "gender", nullable = true)
	@Enumerated(EnumType.STRING)
	private Gender gender;

	@Column(name = "description", nullable = true, length = 200)
	private String description;
	
	@Column(name = "birthday", nullable = true)
	private  LocalDate  birthday;

	@Column(name = "picture_profile", columnDefinition = "LONGTEXT",nullable = true, length = 255)
	private String pictureProfile;

	@Column(name = "verifiedProfile", nullable = true)
	private boolean verifiedProfile;

	@Column(name = "paymentMade", nullable = false)
	private boolean paymentMade;

	@Column(name = "registerDate", nullable = false)
	private LocalDateTime registerDate;

	@Column(name = "role", nullable = false)
	@Enumerated(EnumType.STRING)
	private Role role;
	
	@Column(name = "active", nullable = false)
	private boolean active = true; // Par défaut actif


	// Liste des participations de l'utilisateur (table de liaison)
	@OneToMany(mappedBy = "user" , fetch = FetchType.LAZY)
	private List<Participant> participant; 
	

	// Relation avec les activités créées par l'utilisateur
	@OneToMany(mappedBy = "creator", fetch = FetchType.LAZY)
	private List<Activity> createdActivities;

	// Relation avec la communauté à laquelle l'utilisateur appartient
	@ManyToOne
	@JoinColumn(name = "community_id")
	private Community community;
	
	@OneToOne(mappedBy = "user", cascade = CascadeType.ALL)
	@JsonBackReference
	private Auth auth;
	

}
