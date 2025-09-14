// src/main/java/fr/yasemin/movem8/dto/ActivityUpdateDTO.java
package fr.yasemin.movem8.dto;

import fr.yasemin.movem8.enums.Level;
import fr.yasemin.movem8.enums.StatusActivity;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter @Setter
public class ActivityUpdateDTO {
  private String title;
  private String photo;
  private String description;
  private String location;
  private LocalDateTime dateHour;
  private Float price;
  private Integer numberOfParticipant;
  private Level level;
  private StatusActivity statusActivity;

  private Long sportId; 
}
