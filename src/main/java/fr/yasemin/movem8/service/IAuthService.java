// src/main/java/fr/yasemin/movem8/service/IAuthService.java
package fr.yasemin.movem8.service;


import fr.yasemin.movem8.entity.Auth;
import fr.yasemin.movem8.entity.User;

/**
 * Service d'authentification pour MoveM8.
 */
public interface IAuthService {

    /**
     * Enregistrement initial d'un utilisateur (email + mot de passe).
     *
     * @param email    l'email de l'utilisateur
     * @param password le mot de passe en clair
     * @return l'entité User créée
     */
    User register(String email, String password);

    /**
     * Authentification d'un utilisateur (email + mot de passe).
     *
     * @param email    l'email de l'utilisateur
     * @param password le mot de passe en clair
     * @return l'entité Auth associée
     */
    Auth login(String email, String password);

    /**
     * Stocke le JWT généré dans l'entité Auth de l'utilisateur.
     *
     * @param auth l'entité Auth existante
     * @param jwt  le token JWT valide
     */
    void saveToken(Auth auth, String jwt);
    

    // 2FA
    void initiateLogin(String email, String password);
    String verifyLogin(String email, String code);

    /**
     * Génère un token de réinitialisation de mot de passe et le stocke.
     *
     * @param email l'email de l'utilisateur
     * @return le token de réinitialisation, ou null si l'email n'existe pas
     */
    String generateResetToken(String email);

    /**
     * Réinitialise le mot de passe d'un utilisateur à partir d'un token.
     *
     * @param token       le token de réinitialisation fourni
     * @param newPassword le nouveau mot de passe en clair
     * @return true si la réinitialisation a réussi, false sinon
     */
    boolean resetPassword(String token, String newPassword);

    /**
     * Récupère l'email associé à un token de réinitialisation.
     *
     * @param token le token de réinitialisation
     * @return l'email correspondant, ou null si non trouvé
     */
    default String getEmailByResetToken(String token) {
        // Méthode default à surcharger si nécessaire dans l'implémentation
        throw new UnsupportedOperationException("getEmailByResetToken non implémenté");
    }

    
}
