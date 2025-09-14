package fr.yasemin.movem8.entity;




import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonManagedReference;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Entity
@Table(name = "auth")
@Getter
@Setter
@AllArgsConstructor
@ToString
@NoArgsConstructor
@Builder
public class Auth {
    @Id
	@Column(name = "id_auth")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

	@Column(name = "email", nullable = false, length = 100, unique = true)
	private String email;
	
	@Column(name = "password", nullable = false, length = 255)
	private String passwordHash;

	@Column(name = "reset_token", length = 100)
	private String resetToken;

    
    @Column(name = "token", nullable = true, length = 255)
    private String token;

    @Column(name = "twofa_code", length = 10)
    private String twoFactorCode;

    @Column(name = "twofa_expiry")
    private LocalDateTime twoFactorExpiry;

    
    @OneToOne
    @JoinColumn(name = "user_id")
    @JsonManagedReference
    private User user;
}

