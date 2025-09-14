// src/main/java/fr/yasemin/movem8/controller/AuthController.java
package fr.yasemin.movem8.controller;

import fr.yasemin.movem8.dto.AuthResponseDTO;
import fr.yasemin.movem8.dto.LoginRequestDTO;
import fr.yasemin.movem8.dto.RegisterRequestDTO;
import fr.yasemin.movem8.entity.Auth;
import fr.yasemin.movem8.repository.IAuthRepository;
import fr.yasemin.movem8.service.IAuthService;
import fr.yasemin.movem8.service.IMailService;
import fr.yasemin.movem8.security.JwtUtil;
import jakarta.mail.MessagingException;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.Map;

@RestController
@CrossOrigin("http://localhost:8080")
@RequestMapping("/api/auth")
public class AuthController {

    private final IAuthService authService;
    private final JwtUtil jwtUtil;
    private final IMailService mailService;
    private final IAuthRepository authRepository;

    @Autowired
    public AuthController(IAuthService authService,
                          JwtUtil jwtUtil,
                          IMailService mailService,
                          IAuthRepository authRepository) {
        this.authService    = authService;
        this.jwtUtil        = jwtUtil;
        this.mailService    = mailService;
        this.authRepository = authRepository;
    }

    /** Inscription minimale (email + mot de passe + confirmation) */
    @PostMapping("/register")
    public ResponseEntity<Void> register(@Valid @RequestBody RegisterRequestDTO req) {
        authService.register(req.getEmail(), req.getPassword());
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    /** 1) Première étape : entrée email+mdp → envoi du code 2FA */
    @PostMapping("/login")
    public ResponseEntity<Void> initiateLogin(@Valid @RequestBody LoginRequestDTO req) {
        try {
            authService.initiateLogin(req.getEmail(), req.getPassword());
            return ResponseEntity.noContent().build(); // 204
        } catch (RuntimeException ex) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                                 .header("Error", "Email ou mot de passe incorrect")
                                 .build();
        }
    }

    /** 2) Deuxième étape : vérification du code → renvoi du JWT + activeCommunityId */
    @PostMapping("/login/verify")
    public ResponseEntity<AuthResponseDTO> verifyLogin(@RequestBody Map<String,String> payload) {
        String email = payload.get("email");
        String code  = payload.get("code");
        try {
            // Vérifie code, génère + stocke le JWT
            String jwt = authService.verifyLogin(email, code);

            // Récupère l’Auth complet pour extraire userId et activeCommunityId
            Auth auth  = authRepository.findByEmail(email)
                                       .orElseThrow();

            Long userId         = auth.getUser().getId();
            Long activeCommId   = auth.getUser().getCommunity() != null
                                  ? auth.getUser().getCommunity().getId()
                                  : null;

            AuthResponseDTO dto = new AuthResponseDTO(
                jwt,
                email,
                userId,
                activeCommId
            );
            return ResponseEntity.ok(dto);

        } catch (RuntimeException ex) {
            // Code invalide ou expiré
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
    }


    /** Intercepte le GET via lien HTTP et redirige vers movem8://… */
    @GetMapping("/reset-password")
    public ResponseEntity<Void> redirectToApp(@RequestParam("token") String token)
            throws URISyntaxException {

        URI uri = new URI("movem8://reset-password?token=" + token);
        HttpHeaders headers = new HttpHeaders();
        headers.setLocation(uri);
        return new ResponseEntity<>(headers, HttpStatus.FOUND);
    }

    /** Oubli de mot de passe (envoi mail HTML avec bouton + fallback lien) */
    @PostMapping("/forgot-password")
    public ResponseEntity<Void> forgotPassword(@RequestBody Map<String, String> payload)
            throws MessagingException {

        String email      = payload.get("email");
        String resetToken = authService.generateResetToken(email);

        // Toujours 200 pour ne pas révéler l'existence de l’email
        if (resetToken == null) {
            return ResponseEntity.ok().build();
        }

        String deepLink = "movem8://reset-password?token=" + resetToken;
        String httpLink = "http://192.168.1.31:8080/api/auth/reset-password?token=" + resetToken;

        String html = """
            <p>Bonjour,</p>
            <p>Pour réinitialiser votre mot de passe, cliquez :</p>
            <p>
              <a href="%s"
                 style="display:inline-block;padding:12px 24px;
                        background:#60C8B3;color:#fff;text-decoration:none;
                        border-radius:10px;font-weight:bold;">
                Réinitialiser mon mot de passe
              </a>
            </p>
            <p>Si le deep-link ne s’ouvre pas, copiez/collez :</p>
            <p><code>%s</code></p>
            """.formatted(httpLink, deepLink);

        mailService.sendHtmlMail(email,
                                 "Réinitialisation de votre mot de passe",
                                 html);

        return ResponseEntity.ok().build();
    }

    /** Reset via token (POST) */
    @PostMapping("/reset-password")
    public ResponseEntity<Void> resetPassword(@RequestBody Map<String,String> payload) {
        String token       = payload.get("token");
        String newPassword = payload.get("newPassword");
        if (token == null || newPassword == null) {
            return ResponseEntity.badRequest().build();
        }
        boolean ok = authService.resetPassword(token, newPassword);
        return ok
            ? ResponseEntity.ok().build()
            : ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
    }
}
