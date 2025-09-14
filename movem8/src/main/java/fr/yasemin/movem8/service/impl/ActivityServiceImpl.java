package fr.yasemin.movem8.service.impl;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import fr.yasemin.movem8.dto.ActivityUpdateDTO;
import fr.yasemin.movem8.dto.CreateActivityRequestDTO;
import fr.yasemin.movem8.entity.Activity;
import fr.yasemin.movem8.entity.Auth;
import fr.yasemin.movem8.entity.Category;
import fr.yasemin.movem8.entity.Participant;
import fr.yasemin.movem8.entity.Sport;
import fr.yasemin.movem8.entity.User;
import fr.yasemin.movem8.enums.Level;
import fr.yasemin.movem8.enums.StatusActivity;
import fr.yasemin.movem8.enums.StatusParticipant;
import fr.yasemin.movem8.repository.IActivityRepository;
import fr.yasemin.movem8.repository.IAuthRepository;
import fr.yasemin.movem8.repository.ICategoryRepository;
import fr.yasemin.movem8.repository.IParticipantRepository;
import fr.yasemin.movem8.repository.ISportRepository;
import fr.yasemin.movem8.repository.IUserRepository;
import fr.yasemin.movem8.service.IActivityService;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;

@Service
public class ActivityServiceImpl implements IActivityService {

	@Autowired
	private IActivityRepository activityRepository;

	@Autowired
	private IParticipantRepository participantRepository;

	@Autowired
	private IUserRepository userRepository;

	@Autowired
	private ICategoryRepository categoryRepository;

	@Autowired
	private ISportRepository sportRepository;
	
	@Autowired
	private IAuthRepository authRepository;
	

	@Override
	public Activity getActivitiById(Long id) throws Exception {
	    return activityRepository.findById(id)
	        .orElseThrow(() -> new Exception("Activité introuvable: " + id));
	}
	
	
	  @Transactional
	  @Override
	  public Activity createActivity(CreateActivityRequestDTO req) {
	    if (req == null) throw new IllegalArgumentException("Requête vide.");
	    if (req.sportId() == null) throw new IllegalArgumentException("sportId est requis.");
	    if (req.dateHour() == null) throw new IllegalArgumentException("dateHour est requis.");
	    if (req.level() == null) throw new IllegalArgumentException("level est requis.");
	    if (req.price() != null && req.price() < 0) throw new IllegalArgumentException("Le prix doit être ≥ 0.");
	    if (req.numberOfParticipant() == null || req.numberOfParticipant() < 0) throw new IllegalArgumentException("Le nombre de participants doit être ≥ 0.");

	    Authentication authCtx = SecurityContextHolder.getContext().getAuthentication();
	    if (authCtx == null || authCtx.getName() == null) {
	      throw new IllegalArgumentException("Non authentifié.");
	    }
	    String email = authCtx.getName();

	    Auth auth = authRepository.findByEmail(email)
	        .orElseThrow(() -> new IllegalArgumentException("Utilisateur introuvable"));
	    User creator = auth.getUser();
	    if (creator == null) throw new IllegalArgumentException("Utilisateur introuvable.");
	    if (creator.getCommunity() == null) throw new IllegalArgumentException("Vous devez appartenir à une communauté.");

	    Sport sport = sportRepository.findById(req.sportId())
	        .orElseThrow(() -> new EntityNotFoundException("Sport introuvable"));
	    Category category = sport.getCategory();
	    if (category == null) throw new IllegalStateException("Le sport n'est lié à aucune catégorie.");

	    Activity activity = Activity.builder()
	        .title((req.title() != null && !req.title().isBlank()) ? req.title() : sport.getSportName())
	        .photo(req.photo())
	        .description(req.description())
	        .location(req.location())
	        .dateHour(req.dateHour())
	        .price(req.price() == null ? 0f : req.price())
	        .note(0f)
	        .numberOfParticipant(req.numberOfParticipant())
	        .level(req.level())
	        .statusActivity(StatusActivity.C)
	        .creator(creator)
	        .community(creator.getCommunity())
	        .category(category)
	        .sport(sport)
	        .build();

	    return activityRepository.save(activity);
	  }


	  @Override
	  public Activity updateActivityPartial(Long id, ActivityUpdateDTO dto) throws Exception {
	      Activity a = activityRepository.findById(id)
	          .orElseThrow(() -> new Exception("Activité non trouvée."));

	      if (dto.getTitle() != null) a.setTitle(dto.getTitle());
	      if (dto.getPhoto() != null) a.setPhoto(dto.getPhoto());
	      if (dto.getDescription() != null) a.setDescription(dto.getDescription());
	      if (dto.getLocation() != null) a.setLocation(dto.getLocation());
	      if (dto.getDateHour() != null) a.setDateHour(dto.getDateHour());
	      if (dto.getPrice() != null) {
	          if (dto.getPrice() < 0) throw new IllegalArgumentException("Le prix doit être ≥ 0.");
	          a.setPrice(dto.getPrice());
	      }
	      if (dto.getNumberOfParticipant() != null) {
	          if (dto.getNumberOfParticipant() < 0) throw new IllegalArgumentException("Le nombre de participants doit être ≥ 0.");
	          a.setNumberOfParticipant(dto.getNumberOfParticipant());
	      }
	      if (dto.getLevel() != null) a.setLevel(dto.getLevel());
	      if (dto.getStatusActivity() != null) a.setStatusActivity(dto.getStatusActivity());

	      if (dto.getSportId() != null) {
	          var sport = sportRepository.findById(dto.getSportId())
	              .orElseThrow(() -> new IllegalArgumentException("Sport introuvable."));
	          a.setSport(sport);
	          a.setCategory(sport.getCategory()); // garde la cohérence
	          if (a.getTitle() == null || a.getTitle().isBlank()) {
	              a.setTitle(sport.getSportName());
	          }
	      }

	      return activityRepository.save(a);
	  }
	  

	  @Override
	  public boolean deleteActivity(Long id) throws Exception {
	    if (!activityRepository.existsById(id)) {
	      throw new Exception("Activité non trouvée pour suppression.");
	    }
	    activityRepository.deleteById(id);
	    return true;
	  }

	  @Override
	  public List<Activity> getAllActivities() throws Exception {
	    List<Activity> activities = activityRepository.findAll();
	    LocalDateTime now = LocalDateTime.now();
	    for (Activity activity : activities) {
	      if (activity.getDateHour() != null && activity.getDateHour().isAfter(now)) {
	        activity.setNote(0f); // cache la note tant que l'activité est future
	      }
	    }
	    return activities;
	  }

	 @Override
	  public boolean requestParticipant(Long activityId, Long userId, Level level) {
	    Activity activity = activityRepository.findById(activityId)
	        .orElseThrow(() -> new EntityNotFoundException("Activity not found: " + activityId));

	    User user = userRepository.findById(userId)
	        .orElseThrow(() -> new EntityNotFoundException("User not found: " + userId));

	    // déjà demandé ?
	    if (participantRepository.existsByActivityIdAndUserId(activityId, userId)) {
	      // à toi de décider : renvoyer false, ou OK idempotent.
	      return true; // idempotent: on considère OK.
	    }

	    Participant p = new Participant();
	    p.setActivity(activity);
	    p.setUser(user);
	    p.setLevel(level); // ✅ IMPORTANT: plus null
	    p.setStatusParticipant(StatusParticipant.W); // ou le statut que tu veux par défaut

	    participantRepository.save(p);
	    return true;
	  }

	@Override
	public Participant validateParticipation(Long participantId, Long creatorId) throws Exception {
		Optional<Participant> participantOpt = participantRepository.findById(participantId);

		if (participantOpt.isEmpty()) {
			throw new Exception("Participation introuvable.");
		}

		Participant participant = participantOpt.get();

		if (participant.getActivity().getCreator().getId() != creatorId) {
			throw new Exception("Vous n’êtes pas autorisé à valider cette demande.");
		}

		participant.setStatusParticipant(StatusParticipant.A); // Validation de la participation
		participantRepository.save(participant);
		return participant; // Retourne l'utilisateur validé
	}

	// Participant déjà inscrit
	@Override
	public boolean removeParticipant(Long activityId, Long userId) throws Exception {
		Optional<Activity> activityOpt = activityRepository.findById(activityId);
		Optional<User> userOpt = userRepository.findById(userId);

		if (activityOpt.isEmpty() || userOpt.isEmpty()) {
			throw new Exception("Activité ou utilisateur introuvable.");
		}

		// Recherche de la participation
		Optional<Participant> participantOpt = participantRepository.findByActivityIdAndUserId(activityId, userId);
		if (participantOpt.isEmpty()) {
			throw new Exception("L'utilisateur n'est pas inscrit à cette activité.");
		}

		participantRepository.delete(participantOpt.get());
		return true;
	}

	// refus de la demande pour participer
	@Override
	public Participant refuseParticipant(Long participantId, Long creatorId) throws Exception {
		Optional<Participant> participantOpt = participantRepository.findById(participantId);

		if (participantOpt.isEmpty()) {
			throw new Exception("Participant introuvable");
		}

		Participant participant = participantOpt.get();

		if (participant.getActivity().getCreator().getId() != creatorId) {
			throw new Exception("Vous n’êtes pas autorisé à valider cette demande.");
		}

		// Si la participation est déjà acceptée ou refusée, on ne fait rien
		if (participant.getStatusParticipant() != StatusParticipant.W) {
			throw new Exception("Cette demande a déjà été traitée.");
		}

		participant.setStatusParticipant(StatusParticipant.R); // refuse la participation
		participantRepository.save(participant);
		return participant;

	}

	@Override
	public float rateActivity(Long activityId, float rating) throws Exception {
		Optional<Activity> activityOpt = activityRepository.findById(activityId);

		if (activityOpt.isEmpty()) {
			throw new Exception("Activité introuvable.");
		}

		Activity activity = activityOpt.get();
		if (rating < 1 || rating > 5) {
			throw new Exception("La note doit être entre 1 et 5.");
		}

		activity.setNote(rating); // Mise à jour de la note de l'activité
		activityRepository.save(activity);
		return activity.getNote(); // Retourne la note de l'activité mise à jour
	}

	public List<Participant> getParticipantsByActivityId(Long activityId) {
		Optional<Activity> activity = activityRepository.findById(activityId);
		if (activity.isPresent()) {
			return activity.get().getParticipants();
		} else {
			throw new EntityNotFoundException("Activity not found");
		}
	}


	  @Override
	  public List<Activity> findAllByCommunity(Long communityId) throws Exception {
	    if (communityId == null) throw new IllegalArgumentException("communityId est requis.");
	    List<Activity> activities = activityRepository.findAllByCommunityIdOrderByDateHourDesc(communityId);
	    LocalDateTime now = LocalDateTime.now();
	    for (Activity a : activities) {
	      if (a.getDateHour() != null && a.getDateHour().isAfter(now)) {
	        a.setNote(0f);
	      }
	    }
	    return activities;
	  }

	  @Override
	  public List<Activity> getCreatedActivities(Long userId) {
	    return activityRepository.findByCreatorId(userId);
	  }

}
