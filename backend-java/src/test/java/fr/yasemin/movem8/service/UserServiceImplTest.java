package fr.yasemin.movem8.service;

import fr.yasemin.movem8.dto.UserProfileDTO;
import fr.yasemin.movem8.entity.Auth;
import fr.yasemin.movem8.entity.Community;
import fr.yasemin.movem8.entity.User;
import fr.yasemin.movem8.enums.Gender;
import fr.yasemin.movem8.repository.IAuthRepository;
import fr.yasemin.movem8.repository.ICommunityRepository;
import fr.yasemin.movem8.repository.IUserRepository;
import fr.yasemin.movem8.service.impl.UserServiceImpl;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.*;
import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class UserServiceImplTest {

    @Mock
    private IUserRepository userRepository;

    @Mock
    private ICommunityRepository communityRepository;

    @Mock
    private IAuthRepository authRepository;
    
    @Mock
    private IMailService mailService;

    @InjectMocks
    private UserServiceImpl service;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    // -------- updateUser --------
    @Test
    void updateUser_savesAndReturns() throws Exception {
        User u = new User();
        u.setId(1L);
        u.setFirstName("A");

        when(userRepository.save(any(User.class))).thenAnswer(inv -> inv.getArgument(0));

        User out = service.updateUser(u);

        assertNotNull(out);
        assertEquals(1L, out.getId());
        verify(userRepository, times(1)).save(u);
    }

    // -------- deleteUser --------
    @Test
    void deleteUser_callsRepositoryAndReturnsTrue() throws Exception {
        doNothing().when(userRepository).deleteById(10L);

        boolean ok = service.deleteUser(10L);

        assertTrue(ok);
        verify(userRepository).deleteById(10L);
    }

    // -------- getAllUser --------
    @Test
    void getAllUser_returnsList() throws Exception {
        List<User> list = Arrays.asList(new User(), new User());
        when(userRepository.findAll()).thenReturn(list);

        List<User> result = service.getAllUser();

        assertEquals(2, result.size());
        verify(userRepository).findAll();
    }

    // -------- completeProfile --------
 // -------- completeProfile --------
    @Test
    void completeProfile_success_updatesFieldsAndSaves() {
        String email = "user@example.com";

        User user = new User();
        user.setId(1L);

        Auth auth = new Auth();
        auth.setEmail(email);
        auth.setUser(user);

        UserProfileDTO dto = new UserProfileDTO();
        dto.setFirstName("Jane");
        dto.setLastName("Doe");
        dto.setDescription("Hi");
        dto.setGender(Gender.F); // ✅ enum, pas "F"
        dto.setBirthday(java.time.LocalDate.of(1990, 1, 1));
        dto.setPictureProfile("http://img");

        when(authRepository.findByEmail(email)).thenReturn(Optional.of(auth));
        when(userRepository.save(any(User.class))).thenAnswer(inv -> inv.getArgument(0));

        // Act
        service.completeProfile(email, dto); // 🔴 devient vert si mailService est mocké

        // Assert via ArgumentCaptor (plus sûr que comparer l'instance)
        ArgumentCaptor<User> captor = ArgumentCaptor.forClass(User.class);
        verify(userRepository).save(captor.capture());
        User saved = captor.getValue();

        assertEquals("Jane", saved.getFirstName());
        assertEquals("Doe", saved.getLastName());
        assertEquals("Hi", saved.getDescription());
        assertEquals(Gender.F, saved.getGender());
        assertEquals(java.time.LocalDate.of(1990, 1, 1), saved.getBirthday());
        assertEquals("http://img", saved.getPictureProfile());

        // Vérifie l’envoi de mail (sans figer la date)
        verify(mailService, times(1)).sendSimpleMail(
                eq(email),
                eq("Profil mis à jour"),
                argThat(body -> body.contains("Votre profil a été modifié"))
        );
    }


    @Test
    void completeProfile_userNotFound_throws() {
        when(authRepository.findByEmail("nope@example.com")).thenReturn(Optional.empty());

        RuntimeException ex = assertThrows(RuntimeException.class,
                () -> service.completeProfile("nope@example.com", new UserProfileDTO()));

        assertEquals("Utilisateur introuvable.", ex.getMessage());
        verify(userRepository, never()).save(any());
    }

    // -------- chooseCommunity --------
    @Test
    void chooseCommunity_success_setsCommunityAndSaves() throws Exception {
        Long userId = 1L, communityId = 2L;

        User user = new User();
        user.setId(userId);

        Community community = new Community();
        community.setId(communityId);
        // l’utilisateur est déjà membre → autoriser le choix
        community.setMembers(new ArrayList<>(Collections.singletonList(user)));


        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(communityRepository.findById(communityId)).thenReturn(Optional.of(community));
        when(userRepository.save(any(User.class))).thenAnswer(inv -> inv.getArgument(0));

        service.chooseCommunity(userId, communityId);

        assertEquals(community, user.getCommunity());
        verify(userRepository).save(user);
    }

    @Test
    void chooseCommunity_userNotFound_throws() {
        when(userRepository.findById(1L)).thenReturn(Optional.empty());

        Exception ex = assertThrows(Exception.class, () -> service.chooseCommunity(1L, 2L));
        assertTrue(ex.getMessage().contains("Utilisateur non trouvé"));
        verify(communityRepository, never()).findById(anyLong());
        verify(userRepository, never()).save(any());
    }

    @Test
    void chooseCommunity_communityNotFound_throws() {
        User user = new User();
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(communityRepository.findById(2L)).thenReturn(Optional.empty());

        Exception ex = assertThrows(Exception.class, () -> service.chooseCommunity(1L, 2L));
        assertTrue(ex.getMessage().contains("Communauté non trouvée"));
        verify(userRepository, never()).save(any());
    }

    @Test
    void chooseCommunity_userNotMember_throws() {
        Long userId = 1L, communityId = 2L;

        User user = new User();
        user.setId(userId);

        Community community = new Community();
        community.setId(communityId);
        // pas membre → doit lever
        community.setMembers(new ArrayList<>());

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(communityRepository.findById(communityId)).thenReturn(Optional.of(community));

        Exception ex = assertThrows(Exception.class, () -> service.chooseCommunity(userId, communityId));
        assertTrue(ex.getMessage().contains("ne fait pas partie"));
        verify(userRepository, never()).save(any());
    }

    // -------- getUserById --------
    @Test
    void getUserById_found_returnsUser() throws Exception {
        User user = new User();
        user.setId(42L);
        when(userRepository.findById(42L)).thenReturn(Optional.of(user));

        User out = service.getUserById(42L);

        assertNotNull(out);
        assertEquals(42L, out.getId());
        verify(userRepository).findById(42L);
    }

    @Test
    void getUserById_notFound_returnsNull() throws Exception {
        when(userRepository.findById(99L)).thenReturn(Optional.empty());

        User out = service.getUserById(99L);

        assertNull(out);
        verify(userRepository).findById(99L);
    }
}
