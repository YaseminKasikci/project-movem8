
package fr.yasemin.movem8.service.impl;


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
import java.time.format.DateTimeFormatter;
import java.util.Locale;
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

    /**
     * Inscription d’un nouvel utilisateur.
     * - Vérifie que l’email n’est pas déjà utilisé.
     * - Crée un User minimal (actif, rôle USER, date d’inscription).
     * - Crée un Auth associé (email + mot de passe encodé).
     * 
     * @param email    l’adresse email unique
     * @param password le mot de passe brut (sera encodé)
     * @return l’entité User nouvellement créée
     * @throws EmailAlreadyUsedException si l’email existe déjà
     */
    @Override
    public User register(String email, String password) {
        // Vérifie si un compte existe déjà avec cet email
        if (authRepository.findByEmail(email).isPresent()) {
            throw new EmailAlreadyUsedException();
        }

        // Création de l’utilisateur minimal
        User user = new User();
        user.setActive(true);
        user.setRole(Role.USER);
        user.setRegisterDate(LocalDateTime.now());
        userRepository.save(user);

        // Création de l’authentification liée au user
        Auth auth = new Auth();
        auth.setEmail(email);
        auth.setPasswordHash(passwordEncoder.encode(password)); // hash du mot de passe
        auth.setUser(user);
        authRepository.save(auth);

        return user;
    }

    /**
     * Authentifie un utilisateur avec email et mot de passe.
     * 
     * @param email    email saisi
     * @param password mot de passe saisi
     * @return l’entité Auth correspondante si succès
     * @throws RuntimeException si email inconnu ou mot de passe incorrect
     */
    @Override
    public Auth login(String email, String password) {
        Auth auth = authRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("Email ou mot de passe incorrect."));
        
        // Vérifie le hash du mot de passe
        if (!passwordEncoder.matches(password, auth.getPasswordHash())) {
            throw new RuntimeException("Email ou mot de passe incorrect.");
        }
        return auth;
    }

  
    /**
     * Étape 1 du login à deux facteurs :
     * - Vérifie email + mot de passe
     * - Génère un code OTP à 6 chiffres valide 5 minutes
     * - Sauvegarde le code + expiration
     * - Envoie le code par email
     *
     * @param email    identifiant utilisateur
     * @param password mot de passe brut
     * @throws RuntimeException si credentials invalides
     */
    @Override
    public void initiateLogin(String email, String password) {
    	  Auth auth = login(email, password);
    	    // si 2FA non activé pour cet utilisateur, tu peux directement émettre le JWT ici
    	    // sinon : générer l’OTP

        // Génère un OTP aléatoire à 6 chiffres
        String code = String.format("%06d", new Random().nextInt(1_000_000));
        auth.setTwoFactorCode(code);
        auth.setTwoFactorExpiry(LocalDateTime.now().plusMinutes(5));
        authRepository.save(auth);

        // Envoi du code par email
        mailService.sendSimpleMail(
            email,
            "Votre code de connexion Movem8",
            "Votre code à 6 chiffres est : " + code + "\nIl expire dans 5 minutes."
        );
    }

    /**
     * Étape 2 du login à deux facteurs :
     * - Vérifie que le code est correct et non expiré
     * - Invalide le code (supprime de la DB)
     * - Génère un JWT et l’associe à l’utilisateur
     *
     * @param email email de l’utilisateur
     * @param code  code OTP reçu par mail
     * @return le JWT généré
     * @throws RuntimeException si code invalide ou expiré
     */
    @Override
    public String verifyLogin(String email, String code) {
        Auth auth = authRepository.findByEmail(email)
                     .orElseThrow(() -> new RuntimeException("Code invalide"));

        // Vérification code/expiration
        if (auth.getTwoFactorCode() == null
         || !auth.getTwoFactorCode().equals(code)
         || auth.getTwoFactorExpiry().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("Code invalide ou expiré");
        }

        // Invalidation du code
        auth.setTwoFactorCode(null);
        auth.setTwoFactorExpiry(null);

        // Génération + sauvegarde du JWT
        String jwt = jwtUtil.generateToken(email);
        auth.setToken(jwt);
        authRepository.save(auth);
        
        // 🔔 Mail de connexion réussie
        LocalDateTime now = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter
            .ofPattern("dd MMMM yyyy 'à' HH:mm", Locale.FRENCH);
        String dateFormatee = now.format(formatter);

        String message = """
            Bonjour,

            Vous venez de vous connecter à votre compte le %s.

            Si ce n'était pas vous, changez immédiatement votre mot de passe.
            """.formatted(dateFormatee);

        mailService.sendSimpleMail(
            email,
            "Connexion à votre compte Movem8",
            message
        );
        
        return jwt;
    }
    
    /**
     * Sauvegarde un JWT dans l’entité Auth.
     *
     * @param auth l’entité Auth concernée
     * @param jwt  le token JWT généré
     */
    @Override
    public void saveToken(Auth auth, String jwt) {
        auth.setToken(jwt);
        authRepository.save(auth);
    }


    /**
     * Génère un token de réinitialisation de mot de passe.
     *
     * @param email email de l’utilisateur
     * @return le token généré ou null si aucun compte trouvé
     */
    @Override
    public String generateResetToken(String email) {
        Optional<Auth> opt = authRepository.findByEmail(email);
        if (opt.isEmpty()) return null;

        Auth auth = opt.get();
        String token = UUID.randomUUID().toString(); // token unique
        auth.setResetToken(token);
        authRepository.save(auth);
        return token;
    }

    /**
     * Réinitialise le mot de passe à partir d’un token valide.
     *
     * @param token       le token de reset reçu par l’utilisateur
     * @param newPassword le nouveau mot de passe brut
     * @return true si succès, false si token invalide
     */
    @Override
    @Transactional
    public boolean resetPassword(String token, String newPassword) {
        return authRepository.findByResetToken(token)
            .map(auth -> {
                // Mise à jour du mot de passe et invalidation du token
                auth.setPasswordHash(passwordEncoder.encode(newPassword));
                auth.setResetToken(null);
                authRepository.save(auth);
                return true;
            }).orElse(false);
    }
}
