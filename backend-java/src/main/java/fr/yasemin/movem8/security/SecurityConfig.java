package fr.yasemin.movem8.security;

import jakarta.servlet.http.HttpServletResponse;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.*;

import java.util.List;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private final JwtAuthFilter jwtAuthFilter;

    public SecurityConfig(JwtAuthFilter jwtAuthFilter) {
        this.jwtAuthFilter = jwtAuthFilter;
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .sessionManagement(sess -> sess.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                // Preflight CORS
                .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()

                // Auth publique
                .requestMatchers("/api/auth/**").permitAll()

                // ⚠️ IMAGES/ICÔNES en accès public
                .requestMatchers("/upload/**").permitAll()

                // Lecture publique que TU souhaites exposer (à ajuster)
                .requestMatchers(HttpMethod.GET,
                		"/api/auth/**",
                        "/api/communities/**",
                        "/api/categories/**",
                        "/api/sports/**",
                        "/api/activities",
                        "/api/activities/all",
                        "/api/activities/*"
                ).permitAll()

                // Upload d'images: nécessite être connecté
                .requestMatchers(HttpMethod.POST, "/api/files/upload").authenticated()

                // Utilisateur (protégé)
                .requestMatchers("/api/users/me", "/api/users/complete-profile").authenticated()

                // Communautés: actions utilisateur
                .requestMatchers(HttpMethod.POST, "/api/communities/users/*/join-community/*").authenticated()
                .requestMatchers(HttpMethod.POST, "/api/communities/users/*/choose-community/*").authenticated()

                // Admin (si tes GrantedAuthorities sont du type ROLE_ADMIN, garde hasRole("ADMIN"))
                .requestMatchers(HttpMethod.POST,   "/api/communities/**", "/api/categories/**", "/api/sports/**").hasRole("ADMIN")
                .requestMatchers(HttpMethod.PATCH,  "/api/communities/**", "/api/categories/**", "/api/sports/**").hasRole("ADMIN")
                .requestMatchers(HttpMethod.DELETE, "/api/communities/**", "/api/categories/**", "/api/sports/**").hasRole("ADMIN")

                // Le reste: authentifié
                .anyRequest().authenticated()
            )
            .exceptionHandling(ex -> ex
                .authenticationEntryPoint((req, res, e) -> res.sendError(HttpServletResponse.SC_UNAUTHORIZED))
                .accessDeniedHandler((req, res, e) -> res.sendError(HttpServletResponse.SC_FORBIDDEN))
            )
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration cfg = new CorsConfiguration();

        // Si tu veux whitelister précisément :
        cfg.setAllowedOrigins(List.of(
            "http://localhost:3000",
            "http://localhost:5173",
            "http://127.0.0.1:5173",
            "http://192.168.1.198:5173",  // ← ta machine en LAN pour Flutter Web
            "http://localhost"
        ));
        // OU, si tu préfères matcher des IPs LAN variables, utilise plutôt :
        // cfg.setAllowedOriginPatterns(List.of("*"));

        cfg.setAllowedMethods(List.of("GET","POST","PUT","PATCH","DELETE","OPTIONS"));
        cfg.setAllowedHeaders(List.of("Authorization","Content-Type","Accept"));
        cfg.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", cfg);
        return source;
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration cfg) throws Exception {
        return cfg.getAuthenticationManager();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
