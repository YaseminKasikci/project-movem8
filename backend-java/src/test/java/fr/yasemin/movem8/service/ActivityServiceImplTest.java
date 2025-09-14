//package fr.yasemin.movem8.service;
//
//
//
//
//import org.junit.jupiter.api.BeforeEach;
//import org.junit.jupiter.api.Test;
//import org.mockito.*;
//
//import org.springframework.security.core.context.SecurityContextHolder;
//
//import java.time.LocalDateTime;
//import java.util.*;
//
//import static org.junit.jupiter.api.Assertions.*;
//import static org.mockito.Mockito.*;
//
//import fr.yasemin.movem8.dto.ActivityUpdateDTO;
//import fr.yasemin.movem8.dto.CreateActivityRequestDTO;
//import fr.yasemin.movem8.entity.Activity;
//import fr.yasemin.movem8.entity.Auth;
//import fr.yasemin.movem8.entity.Category;
//import fr.yasemin.movem8.entity.Community;
//import fr.yasemin.movem8.entity.Sport;
//import fr.yasemin.movem8.entity.User;
//import fr.yasemin.movem8.enums.Level;
//import fr.yasemin.movem8.repository.IActivityRepository;
//import fr.yasemin.movem8.repository.IAuthRepository;
//import fr.yasemin.movem8.repository.ICategoryRepository;
//import fr.yasemin.movem8.repository.IParticipantRepository;
//import fr.yasemin.movem8.repository.ISportRepository;
//import fr.yasemin.movem8.repository.IUserRepository;
//import fr.yasemin.movem8.service.impl.ActivityServiceImpl;
//
//
//
//
//class ActivityServiceImplTest {
//
//    @Mock private IActivityRepository activityRepository;
//    @Mock private IParticipantRepository participantRepository;
//    @Mock private IUserRepository userRepository;
//    @Mock private ICategoryRepository categoryRepository;
//    @Mock private ISportRepository sportRepository;
//    @Mock private IAuthRepository authRepository;
//
//    @InjectMocks private ActivityServiceImpl service;
//
//    @BeforeEach
//    void setup() {
//        SecurityContextHolder.clearContext();
//    }
//
//    // -------- getActivitiById --------
//    @Test
//    void getActivitiById_found_returnsActivity() throws Exception {
//        Activity a = new Activity();
//        a.setId(1L);
//        when(activityRepository.findById(1L)).thenReturn(Optional.of(a));
//
//        Activity result = service.getActivitiById(1L);
//
//        assertNotNull(result);
//        assertEquals(1L, result.getId());
//    }
//
//    @Test
//    void getActivitiById_notFound_throws() {
//        when(activityRepository.findById(1L)).thenReturn(Optional.empty());
//
//        Exception ex = assertThrows(Exception.class, () -> service.getActivitiById(1L));
//        assertTrue(ex.getMessage().contains("Activité introuvable"));
//    }
//
//    // -------- createActivity --------
//    @Test
//    void createActivity_success_savesActivity() {
//        // Arrange
//        String email = "user@example.com";
//
//        User user = new User();
//        user.setId(10L);
//        user.setCommunity(new Community());
//
//        Auth auth = new Auth();
//        auth.setEmail(email);
//        auth.setUser(user);
//
//        Sport sport = new Sport();
//        sport.setId(5L);
//        sport.setSportName("Football");
//        Category cat = new Category();
//        sport.setCategory(cat);
//
//        CreateActivityRequestDTO dto = new CreateActivityRequestDTO(
//                "Match", null, "desc", "Paris",
//                LocalDateTime.now().plusDays(1),
//                10f, 5, Level.B, 5L
//        );
//
//        Authentication authCtx = mock(Authentication.class);
//        when(authCtx.getName()).thenReturn(email);
//        SecurityContextHolder.getContext().setAuthentication(authCtx);
//
//        when(authRepository.findByEmail(email)).thenReturn(Optional.of(auth));
//        when(sportRepository.findById(5L)).thenReturn(Optional.of(sport));
//        when(activityRepository.save(any(Activity.class))).thenAnswer(inv -> inv.getArgument(0));
//
//        // Act
//        Activity created = service.createActivity(dto);
//
//        // Assert
//        assertNotNull(created);
//        assertEquals("Match", created.getTitle());
//        assertEquals(user, created.getCreator());
//        assertEquals(cat, created.getCategory());
//        verify(activityRepository).save(any(Activity.class));
//    }
//
//    @Test
//    void createActivity_nullRequest_throws() {
//        assertThrows(IllegalArgumentException.class, () -> service.createActivity(null));
//    }
//
//    @Test
//    void createActivity_noSportId_throws() {
//        CreateActivityRequestDTO dto = new CreateActivityRequestDTO("t", null, null, null,
//                LocalDateTime.now(), 0f, 1, Level.B, null, null);
//
//        assertThrows(IllegalArgumentException.class, () -> service.createActivity(dto));
//    }
//
//    @Test
//    void createActivity_noDateHour_throws() {
//        CreateActivityRequestDTO dto = new CreateActivityRequestDTO("t", null, null, null,
//                null, 0f, 1, Level.B, 1L, null);
//        assertThrows(IllegalArgumentException.class, () -> service.createActivity(dto));
//    }
//
//    @Test
//    void createActivity_noLevel_throws() {
//        CreateActivityRequestDTO dto = new CreateActivityRequestDTO("t", null, null, null,
//                LocalDateTime.now(), 0f, 1, null, 1L, null);
//        assertThrows(IllegalArgumentException.class, () -> service.createActivity(dto));
//    }
//
//    @Test
//    void createActivity_negativePrice_throws() {
//        CreateActivityRequestDTO dto = new CreateActivityRequestDTO("t", null, null, null,
//                LocalDateTime.now(), -5f, 1, Level.B, 1L, null);
//        assertThrows(IllegalArgumentException.class, () -> service.createActivity(dto));
//    }
//
//    @Test
//    void createActivity_negativeParticipants_throws() {
//        CreateActivityRequestDTO dto = new CreateActivityRequestDTO("t", null, null, null,
//                LocalDateTime.now(), 0f, -2, Level.B, 1L, null);
//        assertThrows(IllegalArgumentException.class, () -> service.createActivity(dto));
//    }
//
//    @Test
//    void createActivity_noAuthContext_throws() {
//        CreateActivityRequestDTO dto = new CreateActivityRequestDTO("t", null, null, null,
//                LocalDateTime.now(), 0f, 1, Level.B, 1L, null);
//
//        SecurityContextHolder.clearContext();
//
//        assertThrows(IllegalArgumentException.class, () -> service.createActivity(dto));
//    }
//
//    @Test
//    void createActivity_userNotInCommunity_throws() {
//        String email = "user@example.com";
//        User user = new User(); // pas de communauté
//        Auth auth = new Auth();
//        auth.setUser(user);
//
//        Authentication authCtx = mock(Authentication.class);
//        when(authCtx.getName()).thenReturn(email);
//        SecurityContextHolder.getContext().setAuthentication(authCtx);
//
//        when(authRepository.findByEmail(email)).thenReturn(Optional.of(auth));
//
//        CreateActivityRequestDTO dto = new CreateActivityRequestDTO("t", null, null, null,
//                LocalDateTime.now(), 0f, 1, Level.B, 1L, null);
//
//        assertThrows(IllegalArgumentException.class, () -> service.createActivity(dto));
//    }
//
////     -------- updateActivityPartial --------
//    @Test
//    void updateActivityPartial_success_updatesFields() throws Exception {
//        Activity a = new Activity();
//        a.setId(1L);
//
//        ActivityUpdateDTO dto = new ActivityUpdateDTO();
//        dto.setTitle("New");
//        dto.setPrice(20f);
//
//        when(activityRepository.findById(1L)).thenReturn(Optional.of(a));
//        when(activityRepository.save(any(Activity.class))).thenAnswer(inv -> inv.getArgument(0));
//
//        Activity updated = service.updateActivityPartial(1L, dto);
//
//        assertEquals("New", updated.getTitle());
//        assertEquals(20f, updated.getPrice());
//    }
//
//    @Test
//    void updateActivityPartial_negativePrice_throws() {
//        Activity a = new Activity();
//        when(activityRepository.findById(1L)).thenReturn(Optional.of(a));
//
//        ActivityUpdateDTO dto = new ActivityUpdateDTO();
//        dto.setPrice(-1f);
//
//        assertThrows(IllegalArgumentException.class, () -> service.updateActivityPartial(1L, dto));
//    }
//
//    // -------- deleteActivity --------
//    @Test
//    void deleteActivity_found_deletes() throws Exception {
//        when(activityRepository.existsById(1L)).thenReturn(true);
//
//        boolean result = service.deleteActivity(1L);
//
//        assertTrue(result);
//        verify(activityRepository).deleteById(1L);
//    }
//
//    @Test
//    void deleteActivity_notFound_throws() {
//        when(activityRepository.existsById(1L)).thenReturn(false);
//
//        assertThrows(Exception.class, () -> service.deleteActivity(1L));
//    }
//
//    // -------- getAllActivities --------
//    @Test
//    void getAllActivities_futureActivity_noteReset() throws Exception {
//        Activity future = new Activity();
//        future.setDateHour(LocalDateTime.now().plusDays(1));
//        future.setNote(5f);
//
//        when(activityRepository.findAll()).thenReturn(List.of(future));
//
//        List<Activity> result = service.getAllActivities();
//
//        assertEquals(0f, result.get(0).getNote());
//    }
//
//    @Test
//    void getAllActivities_pastActivity_keepsNote() throws Exception {
//        Activity past = new Activity();
//        past.setDateHour(LocalDateTime.now().minusDays(1));
//        past.setNote(4f);
//
//        when(activityRepository.findAll()).thenReturn(List.of(past));
//
//        List<Activity> result = service.getAllActivities();
//
//        assertEquals(4f, result.get(0).getNote());
//    }
//}
