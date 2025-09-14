// src/main/java/fr/yasemin/movem8/service/impl/AuthService.java
package fr.yasemin.movem8.service.impl;

import fr.yasemin.movem8.dto.UserProfileDTO;
import fr.yasemin.movem8.entity.Auth;
import fr.yasemin.movem8.entity.User;
import fr.yasemin.movem8.enums.Role;
import fr.yasemin.movem8.exception.EmailAlreadyUsedException;
import fr.yasemin.movem8.repository.IAuthRepository;
import fr.yasemin.movem8.repository.IUserRepository;
import fr.yasemin.movem8.service.IAuthService;
import fr.yasemin.movem8.service.IMailService;
import fr.yasemin.movem8.security.JwtUtil;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Optional;
import java.util.Random;
import java.util.UUID;

@Service
public class AuthServiceImpl implements IAuthService {

    @Autowired
    private IAuthRepository authRepository;

    @Autowired
    private IUserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private IMailService mailService;

    @Autowired
    private JwtUtil jwtUtil;

    private final SecureRandom random = new SecureRandom();

    @Override
    public User register(String email, String password) {
        if (authRepository.findByEmail(email).isPresent()) {
            throw new EmailAlreadyUsedException();
        }
        // Création de l’utilisateur minimal
        User user = new User();
        user.setActive(true);
        user.setRole(Role.USER);
        user.setRegisterDate(LocalDateTime.now());
        userRepository.save(user);

        // Création de l’Auth
        Auth auth = new Auth();
        auth.setEmail(email);
        auth.setPasswordHash(passwordEncoder.encode(password));
        auth.setUser(user);
        authRepository.save(auth);
        return user;
    }

    @Override
    public Auth login(String email, String password) {
        Auth auth = authRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("Email ou mot de passe incorrect."));
        if (!passwordEncoder.matches(password, auth.getPasswordHash())) {
            throw new RuntimeException("Email ou mot de passe incorrect.");
        }
        return auth;
    }

    @Override
    public void saveToken(Auth auth, String jwt) {
        auth.setToken(jwt);
        authRepository.save(auth);
    }

    /**
     * Étape 1 : vérifie email+mdp, génère et envoie un OTP à 6 chiffres.
     * Retourne void, en cas d’erreur lève RuntimeException("Email ou mot de passe incorrect").
     */
    @Override
    public void initiateLogin(String email, String password) {
        Auth auth = authRepository.findByEmail(email)
                     .orElseThrow(() -> new RuntimeException("Email ou mot de passe incorrect"));
        if (!passwordEncoder.matches(password, auth.getPasswordHash())) {
            throw new RuntimeException("Email ou mot de passe incorrect");
        }
        // Génère un code 6-chiffres
        String code = String.format("%06d", new Random().nextInt(1_000_000));
        auth.setTwoFactorCode(code);
        auth.setTwoFactorExpiry(LocalDateTime.now().plusMinutes(5));
        authRepository.save(auth);

        // Envoi du code par mail
        mailService.sendSimpleMail(
            email,
            "Votre code de connexion Movem8",
            "Votre code à 6 chiffres est : " + code + "\nIl expire dans 5 minutes."
        );
    }

    @Override
    public String verifyLogin(String email, String code) {
        Auth auth = authRepository.findByEmail(email)
                     .orElseThrow(() -> new RuntimeException("Code invalide"));
        if (auth.getTwoFactorCode() == null
         || !auth.getTwoFactorCode().equals(code)
         || auth.getTwoFactorExpiry().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("Code invalide ou expiré");
        }
        // On invalide le code
        auth.setTwoFactorCode(null);
        auth.setTwoFactorExpiry(null);

        // Génération du JWT
        String jwt = jwtUtil.generateToken(email);
        auth.setToken(jwt);
        authRepository.save(auth);
        return jwt;
    }


    @Override
    public String generateResetToken(String email) {
        Optional<Auth> opt = authRepository.findByEmail(email);
        if (opt.isEmpty()) return null;
        Auth auth = opt.get();
        String token = UUID.randomUUID().toString();
        auth.setResetToken(token);
        authRepository.save(auth);
        return token;
    }

    @Override
    @Transactional
    public boolean resetPassword(String token, String newPassword) {
        return authRepository.findByResetToken(token)
            .map(auth -> {
                auth.setPasswordHash(passwordEncoder.encode(newPassword));
                auth.setResetToken(null);
                authRepository.save(auth);
                return true;
            }).orElse(false);
    }

 
}
