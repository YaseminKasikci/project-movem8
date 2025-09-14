package fr.yasemin.movem8.dto;

import java.time.LocalDate;

import com.fasterxml.jackson.annotation.JsonFormat;

import fr.yasemin.movem8.enums.Gender;
import fr.yasemin.movem8.enums.Role;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserProfileDTO {
	 private Long id;
	    private String firstName;
	    private String lastName;
	    private Gender gender;
	    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "dd-MM-yyyy")
	    private LocalDate birthday;
	    private String description;
	    private String pictureProfile;
	    private boolean verifiedProfile;
	    private boolean paymentMade;
	    private Role role;
}
