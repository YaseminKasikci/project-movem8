package fr.yasemin.movem8.mapper;

import fr.yasemin.movem8.dto.ActivityCardDTO;
import fr.yasemin.movem8.dto.ActivityDetailDTO;
import fr.yasemin.movem8.entity.Activity;
import fr.yasemin.movem8.entity.User;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Period;

public final class ActivityMapper {

  private ActivityMapper() {}

  public static ActivityDetailDTO toDetailDTO(Activity a) {
    ActivityDetailDTO dto = new ActivityDetailDTO();
    dto.setId(a.getId());
    dto.setTitle(a.getTitle());
    dto.setPhoto(a.getPhoto());
    dto.setDescription(a.getDescription());
    dto.setLocation(a.getLocation());
    dto.setDateHour(a.getDateHour());
    dto.setPrice(a.getPrice());
    dto.setNote(a.getNote());
    dto.setNumberOfParticipant(a.getNumberOfParticipant());
    dto.setLevel(a.getLevel());
    dto.setStatusActivity(a.getStatusActivity());

    if (a.getSport() != null) {
      dto.setSportId(a.getSport().getId());
      dto.setSportName(a.getSport().getSportName()); // adapte si nom différent
      dto.setSportIconUrl(a.getSport().getIconUrl());
    }

    User c = a.getCreator();
    if (c != null) {
      dto.setCreatorId(c.getId());
      dto.setCreatorFirstName(c.getFirstName());
      dto.setCreatorLastName(c.getLastName());
      dto.setCreatorPhotoUrl(c.getPictureProfile());
      dto.setCreatorAge(calcAge(c.getBirthday(), a.getDateHour())); // birthday = LocalDate
    }

    if (a.getCommunity() != null) {
      dto.setCommunityId(a.getCommunity().getId());
    }
    return dto;
  }

  public static ActivityCardDTO toCardDTO(Activity a) {
	  User c = a.getCreator();

	  return ActivityCardDTO.builder()
	      .id(a.getId())
	      .title(a.getTitle())
	      .photo(a.getPhoto())
	      .location(a.getLocation())
	      .dateHour(a.getDateHour())
	      .note(a.getNote()) // ou .note(a.getNote()) si tu veux afficher la note
	      .numberOfParticipant(a.getNumberOfParticipant())
	      .level(a.getLevel())
	      .sportId(a.getSport() != null ? a.getSport().getId() : null)
	      .sportName(a.getSport() != null ? a.getSport().getSportName() : null)
	      .communityId(a.getCommunity() != null ? a.getCommunity().getId() : null)
	      .creatorId(c != null ? c.getId() : null)
	      .creatorFirstName(c != null ? c.getFirstName() : null)
	      .creatorPhotoUrl(c != null ? c.getPictureProfile() : null)
	      .creatorAge(c != null ? calcAge(c.getBirthday(), a.getDateHour()) : null)
	      .build();
	}
  private static Integer calcAge(LocalDate birth, LocalDateTime refDateTime) {
    if (birth == null) return null;
    LocalDate ref = (refDateTime != null) ? refDateTime.toLocalDate() : LocalDate.now();
    return Period.between(birth, ref).getYears();
  }
}
