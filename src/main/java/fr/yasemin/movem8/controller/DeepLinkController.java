//package fr.yasemin.movem8.controller;
//
//import org.springframework.http.*;
//import org.springframework.web.bind.annotation.*;
//import org.springframework.web.util.UriUtils;
//
//@RestController
//public class DeepLinkController {
//
//    /**
//     * Reçoit les clics sur le lien HTTPS et renvoie un 302 vers ton URI custom
//     * Ex. https://your.domain.com/deep-link/reset?token=XYZ
//     * Redirige vers movem8://reset-password?token=XYZ
//     */
//    @GetMapping("/deep-link/reset")
//    public ResponseEntity<Void> redirectToApp(@RequestParam String token) {
//        // on encode bien le token pour éviter les problèmes de caractères spéciaux
//        String uri = "movem8://reset-password?token="
//                   + UriUtils.encode(token, "UTF-8");
//        return ResponseEntity
//                 .status(HttpStatus.FOUND)          // 302
//                 .header(HttpHeaders.LOCATION, uri)  // Location: movem8://...
//                 .build();
//    }
//}
