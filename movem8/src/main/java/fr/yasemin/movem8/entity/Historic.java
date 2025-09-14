package fr.yasemin.movem8.entity;

import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import fr.yasemin.movem8.enums.RoleHistoric;
import fr.yasemin.movem8.enums.StatusActivity;
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
@Table(name = "historic")
@Getter @Setter @AllArgsConstructor @NoArgsConstructor @ToString 
@Builder
public class Historic {

	@Id
	 @Column(name = "id_historic")
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

    @Column(name = "role", nullable = false)
    @Enumerated(EnumType.STRING) // Utilisation de EnumType.STRING pour stocker les valeurs sous forme de chaînes
    private RoleHistoric role; // Enumération pour le rôle historique
 
    @Column(name = "status", nullable = false)
    @Enumerated(EnumType.STRING) // Utilisation de EnumType.STRING pour stocker les valeurs sous forme de chaînes
    private StatusActivity status; // Enumération pour le statut historique
    
    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private User user;

    @ManyToOne
    @JoinColumn(name = "activity_id", nullable = false)
    private Activity activity;
    
    
}