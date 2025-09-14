//package fr.yasemin.movem8.service;
//
//
//import fr.yasemin.movem8.entity.Auth;
//import fr.yasemin.movem8.entity.User;
//import fr.yasemin.movem8.enums.Role;
//import fr.yasemin.movem8.exception.EmailAlreadyUsedException;
//import fr.yasemin.movem8.repository.IAuthRepository;
//import fr.yasemin.movem8.repository.IUserRepository;
//import fr.yasemin.movem8.security.JwtUtil;
//import fr.yasemin.movem8.service.impl.AuthServiceImpl;
//import org.junit.jupiter.api.BeforeEach;
//import org.junit.jupiter.api.Test;
//import org.mockito.ArgumentCaptor;
//import org.mockito.InjectMocks;
//import org.mockito.Mock;
//import org.mockito.MockitoAnnotations;
//import org.springframework.security.crypto.password.PasswordEncoder;
//
//
//import java.time.LocalDateTime;
//import java.util.Optional;
//
//
//import static org.assertj.core.api.Assertions.*;
//import static org.mockito.Mockito.*;
//
//class AuthServiceImplTest {
//	
//	
//	
//	@Mock private IAuthRepository authRepository;
//	@Mock private IUserRepository userRepository;
//	@Mock private PasswordEncoder passwordEncoder;
//	@Mock private fr.yasemin.movem8.service.IMailService mailService;
//	@Mock private JwtUtil jwtUtil;
//
//
//	@InjectMocks private AuthServiceImpl service;
//
//
//	@BeforeEach
//	void setUp() { MockitoAnnotations.openMocks(this); }
//
//
//	@Test
//	void register_ok_createsUserAndAuth() {
//	String email = "john@example.com";
//	String rawPwd = "StrongPwd#1234";
//
//
//	when(authRepository.findByEmail(email)).thenReturn(Optional.empty());
//	when(passwordEncoder.encode(rawPwd)).thenReturn("ENC");
//
//
//	User savedUser = new User();
//	savedUser.setId(7L);
//	when(userRepository.save(any(User.class))).thenReturn(savedUser);
//	when(authRepository.save(any(Auth.class))).thenAnswer(inv -> inv.getArgument(0));
//
//
//	User res = service.register(email, rawPwd);
//
//
//	// Le service renvoie l'objet User créé (avant le save retour), donc l'ID peut être null.
//	assertThat(res).isNotNull();
//	verify(userRepository).save(argThat(u -> u.getRole() == Role.USER && u.isActive()));
//	verify(authRepository).save(argThat(a -> email.equals(a.getEmail()) && "ENC".equals(a.getPasswordHash())));
//	}
//
//
//	@Test
//	void register_throws_whenEmailAlreadyUsed() {
//	when(authRepository.findByEmail("exists@x.com")).thenReturn(Optional.of(new Auth()));
//	assertThatThrownBy(() -> service.register("exists@x.com", "pwd"))
//	.isInstanceOf(EmailAlreadyUsedException.class);
//	verify(userRepository, never()).save(any());
//	verify(authRepository, never()).save(any());
//	}
//
//
//	@Test
//	void initiateLogin_ok_sendsCodeAndPersists() {
//	String email = "a@b.c"; String raw = "secret";
//	Auth auth = new Auth(); auth.setEmail(email); auth.setPasswordHash("HASH");
//	when(authRepository.findByEmail(email)).thenReturn(Optional.of(auth));
//	when(passwordEncoder.matches(raw, "HASH")).thenReturn(true);
//
//
//	service.initiateLogin(email, raw);
//
//
//	verify(authRepository).save(argThat(a -> a.getTwoFactorCode() != null && a.getTwoFactorExpiry() != null));
//	verify(mailService).sendSimpleMail(eq(email), contains("Votre code"), contains("expire"));
//	}
//
//
//	@Test
//	void initiateLogin_wrongPassword_throws() {
//	String email = "a@b.c"; String raw = "bad";
//	Auth auth = new Auth(); auth.setEmail(email); auth.setPasswordHash("HASH");
//	when(authRepository.findByEmail(email)).thenReturn(Optional.of(auth));
//	when(passwordEncoder.matches(raw, "HASH")).thenReturn(false);
//	assertThatThrownBy(() -> service.initiateLogin(email, raw))
//	.isInstanceOf(RuntimeException.class)
//	.hasMessageContaining("incorrect");
//	verify(mailService, never()).sendSimpleMail(any(), any(), any());
//	}
//
//
//@Test
//void verifyLogin_invalidOrExpired_throws() {
//String email = "u@x.fr"; String code = "000111";
//Auth auth = new Auth();
//auth.setEmail(email);
//auth.setTwoFactorCode(code);
//auth.setTwoFactorExpiry(LocalDateTime.now().minusSeconds(1)); // expired
//when(authRepository.findByEmail(email)).thenReturn(Optional.of(auth));
//
//
//assertThatThrownBy(() -> service.verifyLogin(email, code))
//.isInstanceOf(RuntimeException.class);
//}
//
//
//@Test
//void generateResetToken_returnsNull_whenEmailUnknown() {
//when(authRepository.findByEmail("nobody@x.com")).thenReturn(Optional.empty());
//assertThat(service.generateResetToken("nobody@x.com")).isNull();
//}
//
//
//@Test
//void generateResetToken_setsAndPersists_whenEmailExists() {
//Auth auth = new Auth(); auth.setEmail("a@b.c");
//when(authRepository.findByEmail("a@b.c")).thenReturn(Optional.of(auth));
//
//
//String token = service.generateResetToken("a@b.c");
//
//
//assertThat(token).isNotBlank();
//verify(authRepository).save(auth);
//assertThat(auth.getResetToken()).isEqualTo(token);
//}
//
//
//@Test
//void resetPassword_ok_returnsTrue_andClearsToken() {
//Auth auth = new Auth(); auth.setResetToken("T");
//when(authRepository.findByResetToken("T")).thenReturn(Optional.of(auth));
//when(passwordEncoder.encode("new"))
//.thenReturn("ENC");
//
//
//boolean ok = service.resetPassword("T", "new");
//assertThat(ok).isTrue();
//assertThat(auth.getPasswordHash()).isEqualTo("ENC");
//assertThat(auth.getResetToken()).isNull();
//verify(authRepository).save(auth);
//}
//
//
//@Test
//void resetPassword_tokenUnknown_returnsFalse() {
//when(authRepository.findByResetToken("X")).thenReturn(Optional.empty());
//assertThat(service.resetPassword("X", "new")).isFalse();
//}
//}