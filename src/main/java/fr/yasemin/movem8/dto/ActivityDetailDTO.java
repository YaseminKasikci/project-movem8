package fr.yasemin.movem8.dto;

import java.time.LocalDateTime;

import fr.yasemin.movem8.enums.Level;
import fr.yasemin.movem8.enums.StatusActivity;
import lombok.Getter;
import lombok.Setter;

//src/main/java/fr/yasemin/movem8/dto/ActivityDTO.java
@Getter @Setter
public class ActivityDetailDTO {
 private Long id;
 private String title;
 private String photo;
 private String description;
 private String location;
 private LocalDateTime dateHour;
 private Float price;
 private Float note;
 private int numberOfParticipant;
 private Level level;
 private StatusActivity statusActivity;
 
 private Long sportId;
 private String sportName;
 private String sportIconUrl;
 

 private Long   creatorId;
 private String creatorFirstName;
 private String creatorLastName;  
 private String creatorPhotoUrl;
 private Integer creatorAge;      

 private Long communityId;

}
