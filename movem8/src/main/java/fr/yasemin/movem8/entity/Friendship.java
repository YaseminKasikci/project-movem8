package fr.yasemin.movem8.entity;

import java.time.LocalDateTime;

import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

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
@Table(name = "friendships")
@Getter @Setter @AllArgsConstructor @ToString @NoArgsConstructor
@Builder
public class Friendship {

	@Id 
	 @Column(name = "id_friend")
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;
	
    @ManyToOne
    @JoinColumn(name = "user1_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private User user1; // Premier utilisateur de l'amitié

    @ManyToOne
    @JoinColumn(name = "user2_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)

    private User user2; // Deuxième utilisateur de l'amitié

    @Column(name = "friendship_date", nullable = false)
    private LocalDateTime friendshipDate; // Date de l'amitié
}
