// src/main/java/fr/yasemin/movem8/dto/RegisterRequest.java
package fr.yasemin.movem8.dto;


import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;
@Getter
@Setter
public class RegisterRequestDTO {
	
	
    @Email(message = "Format d'email invalide") 
    @NotBlank(message = "L'email est requis")
    private String email;

    @NotBlank(message = "Le mot de passe est requis")
    @Size(min = 12, message = "Le mot de passe doit faire au moins 12 caractères")
    @Pattern(
      regexp = "^(?=.*[0-9])(?=.*[A-Z])(?=.*[^A-Za-z0-9]).+$",
      message = "Le mot de passe doit contenir au moins une majuscule, un chiffre et un symbole"
    )
    private String password;

    @NotBlank
    private String confirmPassword;
    
    // declanche automatiquement err 400
    @AssertTrue(message = "Les mots de passe doivent correspondre")
    public boolean isPasswordMatching() {
        return password != null && password.equals(confirmPassword);
    }
}
