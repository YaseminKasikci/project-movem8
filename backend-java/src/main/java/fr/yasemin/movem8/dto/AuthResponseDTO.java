// src/main/java/fr/yasemin/movem8/dto/AuthResponse.java
package fr.yasemin.movem8.dto;

import lombok.Getter;

@Getter
public class AuthResponseDTO {
    private String token;
    private String email;
    private Long   userId;
    private Long   communityId;  

    public AuthResponseDTO(String token, String email, Long userId, Long communityId) {
        this.token = token;
        this.email = email;
        this.userId = userId;
        this.communityId = communityId;
    }

}
