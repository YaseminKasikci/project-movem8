package fr.yasemin.movem8.entity;

import fr.yasemin.movem8.enums.Level;
import fr.yasemin.movem8.enums.StatusParticipant;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
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
@Table(name = "participant")
@Getter @Setter @AllArgsConstructor @ToString @NoArgsConstructor
@Builder
public class Participant {

	@Id
	 @Column(name = "id_participant")
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	
	@Enumerated(EnumType.STRING)
    @Column(name = "participant", nullable = false)
    private StatusParticipant statusParticipant; // Indique si la participation a été validée
	
	@Enumerated(EnumType.STRING)
    @Column(name = "level", nullable = false, length = 50)
    private Level level; // Niveau choisi pour l'activité (par exemple "débutant", "intermédiaire", "avancé")
	
    
    //participant relier a un utilisateur
    @ManyToOne
    @JoinColumn(name = "user_id")  // Référence à l'utilisateur
    private User user;
    
    // participant relier a une activité
    @ManyToOne
    @JoinColumn(name = "activity_id", nullable = false)
    private Activity activity; // Référence à l'activité à laquelle le participant participe

    
    
    
}