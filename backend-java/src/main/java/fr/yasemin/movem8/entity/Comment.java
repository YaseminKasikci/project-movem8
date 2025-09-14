package fr.yasemin.movem8.entity;

import java.time.LocalDateTime;

import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
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
@Table(name = "comment")
@Getter @Setter @AllArgsConstructor @ToString @NoArgsConstructor
@Builder
public class Comment {

	@Id
	 @Column(name = "id_comment")
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	
	private Long id;

    @Column(name = "content", nullable = false, length = 500)
    private String content;

    @Column(name = "date", nullable = false)
    private LocalDateTime date;

    // notes sur l'activité 
    @Column(name = "rating")
    private Float rating;
  
    // l'autheur du commentaire
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    @OnDelete(action = OnDeleteAction.CASCADE)

    private User author;

//    l'activité en question 
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "activity_id")
    private Activity activity;
}
