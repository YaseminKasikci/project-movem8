package fr.yasemin.movem8.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;

@Component
public class JwtUtil {

    private final SecretKey jwtSecretKey = Keys.hmacShaKeyFor(
        "yaseminSecretKeyyaseminSecretKeyyaseminSecretKeyyaseminSecretKeyyaseminSecretKeyyaseminSecretKey"
            .getBytes(StandardCharsets.UTF_8)
    );
    private final long jwtExpirationMs = 86_400_000; // 24h

    public String generateToken(String email) {
        return Jwts.builder()
                .setSubject(email)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + jwtExpirationMs))
                .signWith(jwtSecretKey, SignatureAlgorithm.HS512)
                .compact();
    }

    // méthode existante, récupère le subject (votre email)
    public String getEmailFromJwt(String token) {
        return extractAllClaims(token).getSubject();
    }

    // alias pour compatibilité avec les anciens noms de méthode
    public String extractUsername(String token) {
        return getEmailFromJwt(token);
    }

    public boolean validateJwtToken(String token) {
        try {
            extractAllClaims(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }

    // helper privé
    private Claims extractAllClaims(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(jwtSecretKey)
                .build()
                .parseClaimsJws(token)
                .getBody();
    }
}
