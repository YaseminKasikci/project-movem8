package fr.yasemin.movem8.security;

import fr.yasemin.movem8.entity.Auth;
import fr.yasemin.movem8.enums.Role;
import fr.yasemin.movem8.repository.IAuthRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.*;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    @Autowired
    private IAuthRepository authRepository;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        Auth auth = authRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("Utilisateur introuvable avec email : " + email));

        Role role = auth.getUser().getRole();

        // Mappe tes rôles personnalisés vers Spring Security roles
        String springRole = switch (role) {
            case USER -> "ROLE_USER";
            case PREMIUM -> "ROLE_PREMIUM";
            case ADMIN -> "ROLE_ADMIN";
        };

        return new org.springframework.security.core.userdetails.User(
                auth.getEmail(),
                auth.getPasswordHash(),
                List.of(new SimpleGrantedAuthority(springRole))
        );
    }
}
