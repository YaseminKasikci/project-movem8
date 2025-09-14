package fr.yasemin.movem8.repository;

import fr.yasemin.movem8.entity.Auth;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
@Repository
public interface IAuthRepository extends JpaRepository<Auth, Long> {
    Optional<Auth> findByEmail(String email);
    Optional<Auth> findByResetToken(String resetToken);
    Optional<Auth> findByTwoFactorCode(String twoFactorCode);
}
