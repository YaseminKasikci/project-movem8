//package fr.yasemin.movem8.controller;
//
//
//import com.fasterxml.jackson.databind.ObjectMapper;
//import fr.yasemin.movem8.dto.AuthResponseDTO;
//import fr.yasemin.movem8.dto.RegisterRequestDTO;
//import fr.yasemin.movem8.entity.Auth;
//import fr.yasemin.movem8.entity.User;
//import fr.yasemin.movem8.repository.IAuthRepository;
//import fr.yasemin.movem8.security.JwtUtil;
//import fr.yasemin.movem8.service.IAuthService;
//import fr.yasemin.movem8.service.IMailService;
//import org.junit.jupiter.api.BeforeEach;
//import org.junit.jupiter.api.Test;
//import org.mockito.Mock;
//import org.mockito.MockitoAnnotations;
//import org.springframework.http.MediaType;
//import org.springframework.test.web.servlet.MockMvc;
//import org.springframework.test.web.servlet.setup.MockMvcBuilders;
//
//
//import java.util.HashMap;
//import java.util.Map;
//import java.util.Optional;
//
//
//import static org.hamcrest.Matchers.*;
//import static org.mockito.ArgumentMatchers.*;
//import static org.mockito.Mockito.*;
//import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
//import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
//
//
//class AuthControllerTest {
//
//
//private MockMvc mvc;
//private ObjectMapper om = new ObjectMapper();
//
//
//@Mock private IAuthService authService;
//@Mock private JwtUtil jwtUtil; // unused directly but kept for constructor completeness
//@Mock private IMailService mailService;
//@Mock private IAuthRepository authRepository;
//
//
//@BeforeEach
//void setup() {
//MockitoAnnotations.openMocks(this);
//AuthController controller = new AuthController(authService, jwtUtil, mailService, authRepository);
//mvc = MockMvcBuilders.standaloneSetup(controller).build();
//}
//
//
//@Test
//void register_created_whenPasswordsMatch() throws Exception {
//RegisterRequestDTO dto = new RegisterRequestDTO();
//dto.setEmail("john@x.com");
//dto.setPassword("StrongPwd#1234");
//dto.setConfirmPassword("StrongPwd#1234");
//
//
//mvc.perform(post("/api/auth/register")
//.contentType(MediaType.APPLICATION_JSON)
//.content(om.writeValueAsString(dto)))
//.andExpect(status().isCreated());
//
//
//verify(authService).register("john@x.com", "StrongPwd#1234");
//}
//@Test
//void register_badRequest_whenPasswordsDoNotMatch() throws Exception {
//// Avec @AssertTrue sur RegisterRequestDTO, la validation échoue AVANT d'entrer dans le contrôleur,
//// donc pas d'en-tête "Error" ajouté. On vérifie uniquement le 400.
//RegisterRequestDTO dto = new RegisterRequestDTO();
//dto.setEmail("john@x.com");
//dto.setPassword("StrongPwd#1234");
//dto.setConfirmPassword("NOPE");
//
//
//mvc.perform(post("/api/auth/register")
//.contentType(MediaType.APPLICATION_JSON)
//.content(om.writeValueAsString(dto)))
//.andExpect(status().isBadRequest());
//
//
//verify(authService, never()).register(any(), any());
//}
//
//
//@Test
//void initiateLogin_noContent_onSuccess_else401() throws Exception {
//Map<String, String> payload = Map.of("email", "a@b.c", "password", "pass");
//
//
//// success path
//mvc.perform(post("/api/auth/login")
//.contentType(MediaType.APPLICATION_JSON)
//.content(om.writeValueAsString(payload)))
//.andExpect(status().isNoContent());
//
//
//verify(authService).initiateLogin("a@b.c", "pass");
//
//
//// failure path
//doThrow(new RuntimeException("bad")).when(authService).initiateLogin("x@y.z", "bad");
//Map<String, String> bad = Map.of("email", "x@y.z", "password", "bad");
//
//
//mvc.perform(post("/api/auth/login")
//.contentType(MediaType.APPLICATION_JSON)
//.content(om.writeValueAsString(bad)))
//.andExpect(status().isUnauthorized());
//}
//
//
//@Test
//void verifyLogin_ok_returnsAuthResponseDTO() throws Exception {
//Map<String, String> payload = new HashMap<>();
//payload.put("email", "john@x.com");
//payload.put("code", "123456");
//
//
//when(authService.verifyLogin("john@x.com", "123456")).thenReturn("JWT");
//
//
//// mock repository to return an Auth with User + Community (null ici)
//User user = new User(); user.setId(42L);
//Auth auth = new Auth(); auth.setEmail("john@x.com"); auth.setUser(user);
//when(authRepository.findByEmail("john@x.com")).thenReturn(Optional.of(auth));
//
//
//mvc.perform(post("/api/auth/login/verify")
//.contentType(MediaType.APPLICATION_JSON)
//.content(om.writeValueAsString(payload)))
//.andExpect(status().isOk())
//.andExpect(jsonPath("$.token", is("JWT")))
//.andExpect(jsonPath("$.email", is("john@x.com")))
//.andExpect(jsonPath("$.userId", is(42)))
//.andExpect(jsonPath("$.communityId").doesNotExist());
//}
//
//@Test
//void verifyLogin_forbidden_whenInvalid() throws Exception {
//Map<String, String> payload = Map.of("email", "a@b.c", "code", "000111");
//when(authService.verifyLogin(anyString(), anyString())).thenThrow(new RuntimeException("invalid"));
//
//
//mvc.perform(post("/api/auth/login/verify")
//.contentType(MediaType.APPLICATION_JSON)
//.content(om.writeValueAsString(payload)))
//.andExpect(status().isForbidden());
//}
//
//
//@Test
//void redirectToApp_returns302_andLocationIsDeepLink() throws Exception {
//mvc.perform(get("/api/auth/reset-password").param("token", "ABC"))
//.andExpect(status().isFound())
//.andExpect(header().string("Location", "movem8://reset-password?token=ABC"));
//}
//
//
//@Test
//void forgotPassword_returns200_andSendsEmailOnlyIfTokenNotNull() throws Exception {
//Map<String, String> payload = Map.of("email", "john@x.com");
//
//
//// branch 1: token null -> no mail
//when(authService.generateResetToken("john@x.com")).thenReturn(null);
//mvc.perform(post("/api/auth/forgot-password")
//.contentType(MediaType.APPLICATION_JSON)
//.content(om.writeValueAsString(payload)))
//.andExpect(status().isOk());
//verify(mailService, never()).sendHtmlMail(anyString(), anyString(), anyString());
//
//
//// branch 2: token present -> send mail
//reset(mailService);
//when(authService.generateResetToken("john@x.com")).thenReturn("TOKEN");
//mvc.perform(post("/api/auth/forgot-password")
//.contentType(MediaType.APPLICATION_JSON)
//.content(om.writeValueAsString(payload)))
//.andExpect(status().isOk());
//verify(mailService).sendHtmlMail(eq("john@x.com"), contains("Réinitialisation"), contains("movem8://reset-password?token=TOKEN"));
//}
//
//
//@Test
//void resetPassword_returns200_or401_or400() throws Exception {
//// 400 when fields missing
//mvc.perform(post("/api/auth/reset-password")
//.contentType(MediaType.APPLICATION_JSON)
//.content("{}"))
//.andExpect(status().isBadRequest());
//
//
//// 200 when ok
//Map<String, String> ok = Map.of("token", "T", "newPassword", "N");
//when(authService.resetPassword("T", "N")).thenReturn(true);
//mvc.perform(post("/api/auth/reset-password")
//.contentType(MediaType.APPLICATION_JSON)
//.content(om.writeValueAsString(ok)))
//.andExpect(status().isOk());
//
//
//// 401 when service returns false
//Map<String, String> ko = Map.of("token", "BAD", "newPassword", "N");
//when(authService.resetPassword("BAD", "N")).thenReturn(false);
//mvc.perform(post("/api/auth/reset-password")
//.contentType(MediaType.APPLICATION_JSON)
//.content(om.writeValueAsString(ko)))
//.andExpect(status().isUnauthorized());
//}
//}