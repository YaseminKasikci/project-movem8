package fr.yasemin.movem8.service;

import fr.yasemin.movem8.entity.Auth;
import fr.yasemin.movem8.entity.User;
import fr.yasemin.movem8.enums.Role;
import fr.yasemin.movem8.exception.EmailAlreadyUsedException;
import fr.yasemin.movem8.repository.IAuthRepository;
import fr.yasemin.movem8.repository.IUserRepository;
import fr.yasemin.movem8.security.JwtUtil;
import fr.yasemin.movem8.service.impl.AuthServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Optional;
import java.util.regex.Pattern;

import static org.assertj.core.api.Assertions.*;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.*;

class AuthServiceImplTest {

	@Mock
	private IAuthRepository authRepository;
	@Mock
	private IUserRepository userRepository;
	@Mock
	private PasswordEncoder passwordEncoder;
	@Mock
	private fr.yasemin.movem8.service.IMailService mailService;
	@Mock
	private JwtUtil jwtUtil;
	@Mock AuthServiceImpl authService;
	

	@InjectMocks
	private AuthServiceImpl service;

	@BeforeEach
	void setUp() {
		MockitoAnnotations.openMocks(this);
	}

	@Test
	void loginTestSuccess() {
	    // Arrange
	    String email = "test@example.com";
	    String rawPassword = "password123";
	    String hashedPassword = "hashedPassword";

	    Auth auth = new Auth();
	    auth.setEmail(email);
	    auth.setPasswordHash(hashedPassword);

	    // On mock la recherche par email
	    when(authRepository.findByEmail(email)).thenReturn(Optional.of(auth));
	    // On mock la comparaison de mots de passe
	    when(passwordEncoder.matches(rawPassword, hashedPassword)).thenReturn(true);

	    // Act
	    Auth result = service.login(email, rawPassword);

	    // Assert
	    assertNotNull(result);
	    assertEquals(email, result.getEmail());
	    verify(authRepository, times(1)).findByEmail(email);
	    verify(passwordEncoder, times(1)).matches(rawPassword, hashedPassword);
	}
	
	@Test
	void loginTest_incorrectPassword_throwsException() {
	    // Arrange
	    String email = "test@example.com";
	    String correctPassword = "password123";
	    String wrongPassword = "wrongPassword";
	    String hashedPassword = "hashedPassword";

	    Auth auth = new Auth();
	    auth.setEmail(email);
	    auth.setPasswordHash(hashedPassword);

	    when(authRepository.findByEmail(email)).thenReturn(Optional.of(auth));
	    when(passwordEncoder.matches(wrongPassword, hashedPassword)).thenReturn(false);

	    // Act & Assert
	    RuntimeException exception = assertThrows(RuntimeException.class, () -> {
	        service.login(email, wrongPassword); // ✅ clair et logique
	    });

	    assertEquals("Email ou mot de passe incorrect.", exception.getMessage());
	    verify(authRepository, times(1)).findByEmail(email);
	    verify(passwordEncoder, times(1)).matches(wrongPassword, hashedPassword);
	}

	@Test
	void loginTest_emailNotFound_throwsException() {
	    // Arrange
	    String email = "unknown@example.com";
	    String rawPassword = "password123";

	    when(authRepository.findByEmail(email)).thenReturn(Optional.empty());

	    // Act & Assert
	    RuntimeException exception = assertThrows(RuntimeException.class, () -> {
	        service.login(email, rawPassword);
	    });

	    assertEquals("Email ou mot de passe incorrect.", exception.getMessage());
	    verify(authRepository, times(1)).findByEmail(email);
	    verify(passwordEncoder, never()).matches(any(), any());
	}


	
	@Test
	void register_ok_createsUserAndAuth() {
		String email = "john@example.com";
		String rawPwd = "StrongPwd#1234";

		when(authRepository.findByEmail(email)).thenReturn(Optional.empty());
		when(passwordEncoder.encode(rawPwd)).thenReturn("ENC");

		User savedUser = new User();
		savedUser.setId(7L);
		when(userRepository.save(any(User.class))).thenReturn(savedUser);
		when(authRepository.save(any(Auth.class))).thenAnswer(inv -> inv.getArgument(0));

		User res = service.register(email, rawPwd);

		// Le service renvoie l'objet User créé (avant le save retour), donc l'ID peut
		// être null.
		assertThat(res).isNotNull();
		verify(userRepository).save(argThat(u -> u.getRole() == Role.USER && u.isActive()));
		verify(authRepository).save(argThat(a -> email.equals(a.getEmail()) && "ENC".equals(a.getPasswordHash())));
	}

	@Test
	void register_throws_whenEmailAlreadyUsed() {
		when(authRepository.findByEmail("exists@x.com")).thenReturn(Optional.of(new Auth()));
		assertThatThrownBy(() -> service.register("exists@x.com", "pwd")).isInstanceOf(EmailAlreadyUsedException.class);
		verify(userRepository, never()).save(any());
		verify(authRepository, never()).save(any());
	}

	@Test
	void initiateLogin_ok_sendsCodeAndPersists() {
		String email = "a@b.c";
		String raw = "secret";
		Auth auth = new Auth();
		auth.setEmail(email);
		auth.setPasswordHash("HASH");
		when(authRepository.findByEmail(email)).thenReturn(Optional.of(auth));
		when(passwordEncoder.matches(raw, "HASH")).thenReturn(true);

		service.initiateLogin(email, raw);

		verify(authRepository).save(argThat(a -> a.getTwoFactorCode() != null && a.getTwoFactorExpiry() != null));
		verify(mailService).sendSimpleMail(eq(email), contains("Votre code"), contains("expire"));
	}

	@Test
	void initiateLogin_wrongPassword_throws() {
		String email = "a@b.c";
		String raw = "bad";
		Auth auth = new Auth();
		auth.setEmail(email);
		auth.setPasswordHash("HASH");
		when(authRepository.findByEmail(email)).thenReturn(Optional.of(auth));
		when(passwordEncoder.matches(raw, "HASH")).thenReturn(false);
		assertThatThrownBy(() -> service.initiateLogin(email, raw)).isInstanceOf(RuntimeException.class)
				.hasMessageContaining("incorrect");
		verify(mailService, never()).sendSimpleMail(any(), any(), any());
	}

    @Test
	void verifyLogin_invalidOrExpired_throws() {
		String email = "u@x.fr";
		String code = "000111";
		Auth auth = new Auth();
		auth.setEmail(email);
		auth.setTwoFactorCode(code);
		auth.setTwoFactorExpiry(LocalDateTime.now().minusSeconds(1)); // expired
		when(authRepository.findByEmail(email)).thenReturn(Optional.of(auth));

		assertThatThrownBy(() -> service.verifyLogin(email, code)).isInstanceOf(RuntimeException.class);
	}

    @Test
	void generateResetToken_returnsNull_whenEmailUnknown() {
		when(authRepository.findByEmail("nobody@x.com")).thenReturn(Optional.empty());
		assertThat(service.generateResetToken("nobody@x.com")).isNull();
	}
    
   @Test
	void generateResetToken_setsAndPersists_whenEmailExists() {
		Auth auth = new Auth();
		auth.setEmail("a@b.c");
		when(authRepository.findByEmail("a@b.c")).thenReturn(Optional.of(auth));

		String token = service.generateResetToken("a@b.c");

		assertThat(token).isNotBlank();
		verify(authRepository).save(auth);
		assertThat(auth.getResetToken()).isEqualTo(token);
	}

	@Test
	void resetPassword_ok_returnsTrue_andClearsToken() {
		Auth auth = new Auth();
		auth.setResetToken("T");
		when(authRepository.findByResetToken("T")).thenReturn(Optional.of(auth));
		when(passwordEncoder.encode("new")).thenReturn("ENC");

		boolean ok = service.resetPassword("T", "new");
		assertThat(ok).isTrue();
		assertThat(auth.getPasswordHash()).isEqualTo("ENC");
		assertThat(auth.getResetToken()).isNull();
		verify(authRepository).save(auth);
	}

	@Test
	void resetPassword_tokenUnknown_returnsFalse() {
		when(authRepository.findByResetToken("X")).thenReturn(Optional.empty());
		assertThat(service.resetPassword("X", "new")).isFalse();
	}
	
	// ---------- saveToken ----------
	
    @Test
    void saveToken_setsTokenAndPersists() {
        Auth auth = new Auth();
        String jwt = "jwt-123";

        when(authRepository.save(any(Auth.class))).thenAnswer(inv -> inv.getArgument(0));

        service.saveToken(auth, jwt);

        assertEquals(jwt, auth.getToken());
        ArgumentCaptor<Auth> captor = ArgumentCaptor.forClass(Auth.class);
        verify(authRepository, times(1)).save(captor.capture());
        assertEquals(jwt, captor.getValue().getToken());
    }
    
    // ---------- initiateLogin ----------
    
    @Test
    void initiateLogin_success_sendsSixDigitCode_andPersistsWithExpiry() {
        String email = "user@example.com";
        String rawPassword = "pw";
        String hash = "hash";

        Auth auth = new Auth();
        auth.setEmail(email);
        auth.setPasswordHash(hash);

        when(authRepository.findByEmail(email)).thenReturn(Optional.of(auth));
        when(passwordEncoder.matches(rawPassword, hash)).thenReturn(true);
        when(authRepository.save(any(Auth.class))).thenAnswer(inv -> inv.getArgument(0));

        LocalDateTime beforeCall = LocalDateTime.now();
        service.initiateLogin(email, rawPassword);
        LocalDateTime afterCall = LocalDateTime.now();

        // 1) code 6 chiffres
        assertNotNull(auth.getTwoFactorCode());
        assertTrue(Pattern.matches("\\d{6}", auth.getTwoFactorCode()));

        // 2) expiry dans ~5 minutes (tolérance 4..6 min)
        assertNotNull(auth.getTwoFactorExpiry());
        Duration until = Duration.between(beforeCall, auth.getTwoFactorExpiry());
        assertTrue(until.toMinutes() >= 4 && until.toMinutes() <= 6,
            "expiry doit être ≈ 5 minutes après maintenant");

        // 3) persistence + mail envoyés
        verify(authRepository).save(auth);
        verify(mailService).sendSimpleMail(
                eq(email),
                contains("code"),
                argThat(body -> body.contains(auth.getTwoFactorCode()) && body.contains("5 minutes")));
    }
    @Test
    void initiateLogin_wrongPassword_throws_andDoesNotSendMail() {
        String email = "user@example.com";
        String rawPassword = "wrong";
        String hash = "hash";

        Auth auth = new Auth();
        auth.setEmail(email);
        auth.setPasswordHash(hash);

        when(authRepository.findByEmail(email)).thenReturn(Optional.of(auth));
        when(passwordEncoder.matches(rawPassword, hash)).thenReturn(false);

        RuntimeException ex = assertThrows(RuntimeException.class,
                () -> service.initiateLogin(email, rawPassword));
        assertEquals("Email ou mot de passe incorrect", ex.getMessage());

        verify(mailService, never()).sendSimpleMail(anyString(), anyString(), anyString());
        verify(authRepository, never()).save(any());
    }

    @Test
    void initiateLogin_emailNotFound_throws() {
        when(authRepository.findByEmail("nope@example.com")).thenReturn(Optional.empty());

        RuntimeException ex = assertThrows(RuntimeException.class,
                () -> service.initiateLogin("nope@example.com", "pw"));
        assertEquals("Email ou mot de passe incorrect", ex.getMessage());

        verify(mailService, never()).sendSimpleMail(anyString(), anyString(), anyString());
        verify(authRepository, never()).save(any());
    }
    
    
    
    // ---------- verifyLogin ----------
    
    @Test
    void verifyLogin_success_generatesJwt_clearsCode_savesAuth_andSendsMail() {
        String email = "user@example.com";
        String code = "123456";
        String jwt = "jwt-token";

        Auth auth = new Auth();
        auth.setEmail(email);
        auth.setTwoFactorCode(code);
        auth.setTwoFactorExpiry(LocalDateTime.now().plusMinutes(3));

        when(authRepository.findByEmail(email)).thenReturn(Optional.of(auth));
        when(jwtUtil.generateToken(email)).thenReturn(jwt);
        when(authRepository.save(any(Auth.class))).thenAnswer(inv -> inv.getArgument(0));

        String returned = service.verifyLogin(email, code);

        assertEquals(jwt, returned);
        assertEquals(jwt, auth.getToken());
        assertNull(auth.getTwoFactorCode());
        assertNull(auth.getTwoFactorExpiry());

        verify(authRepository).save(auth);
        verify(jwtUtil).generateToken(email);

        // ✅ Nouvelle vérification : mail envoyé
        verify(mailService).sendSimpleMail(
                eq(email),
                contains("Connexion"),
                contains("vous connecter")); // matcher souple, pas besoin du texte exact
    }

 
    @Test
    void verifyLogin_wrongCode_throws() {
        String email = "user@example.com";

        Auth auth = new Auth();
        auth.setEmail(email);
        auth.setTwoFactorCode("654321");
        auth.setTwoFactorExpiry(LocalDateTime.now().plusMinutes(5));

        when(authRepository.findByEmail(email)).thenReturn(Optional.of(auth));

        RuntimeException ex = assertThrows(RuntimeException.class,
                () -> service.verifyLogin(email, "123456"));
        assertEquals("Code invalide ou expiré", ex.getMessage());

        verify(jwtUtil, never()).generateToken(anyString());
        verify(authRepository, never()).save(any());
    }

    @Test
    void verifyLogin_expiredCode_throws() {
        String email = "user@example.com";

        Auth auth = new Auth();
        auth.setEmail(email);
        auth.setTwoFactorCode("123456");
        auth.setTwoFactorExpiry(LocalDateTime.now().minusSeconds(1)); // expiré

        when(authRepository.findByEmail(email)).thenReturn(Optional.of(auth));

        RuntimeException ex = assertThrows(RuntimeException.class,
                () -> service.verifyLogin(email, "123456"));
        assertEquals("Code invalide ou expiré", ex.getMessage());

        verify(jwtUtil, never()).generateToken(anyString());
        verify(authRepository, never()).save(any());
    }

    @Test
    void verifyLogin_emailNotFound_throws() {
        when(authRepository.findByEmail("nope@example.com")).thenReturn(Optional.empty());

        RuntimeException ex = assertThrows(RuntimeException.class,
                () -> service.verifyLogin("nope@example.com", "000000"));
        assertEquals("Code invalide", ex.getMessage());

        verify(jwtUtil, never()).generateToken(anyString());
        verify(authRepository, never()).save(any());
    }

}