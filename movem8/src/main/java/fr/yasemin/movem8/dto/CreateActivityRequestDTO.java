package fr.yasemin.movem8.dto;

import fr.yasemin.movem8.enums.Level;
import jakarta.validation.constraints.*;
import java.time.LocalDateTime;

public record CreateActivityRequestDTO(
    @NotBlank String title,
    String photo,
    @NotBlank String description,
    @NotBlank String location,
    @NotNull LocalDateTime dateHour,
    @NotNull @PositiveOrZero Float price,
    @NotNull @Positive Integer numberOfParticipant,
    @NotNull Level level,
    @NotNull Long sportId
) {}

