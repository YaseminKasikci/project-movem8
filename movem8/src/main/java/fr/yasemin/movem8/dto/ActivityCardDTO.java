// dto/ActivityCardDTO.java
package fr.yasemin.movem8.dto;

import fr.yasemin.movem8.enums.Level;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter @Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ActivityCardDTO {
  private Long id;
  private String title;
  private String photo;
  private String location;
  private LocalDateTime dateHour;
  private Float note;
  private Integer numberOfParticipant;
  private Level level;
  private Long sportId;
  private String sportName;
  private Long communityId;
  
  private Long   creatorId;
  private String creatorFirstName;
  private String creatorPhotoUrl;
  private Integer creatorAge;  
}
