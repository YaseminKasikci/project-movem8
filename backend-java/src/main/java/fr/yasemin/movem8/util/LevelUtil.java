package fr.yasemin.movem8.util;

import fr.yasemin.movem8.enums.Level;

public class LevelUtil {
    // Méthode pour obtenir la couleur associée à un niveau
    public static String getLevelColor(Level level) {
        return level.getColor();  // Retourne la couleur associée à un niveau
    }

    // Exemple d'utilisation
    public static void main(String[] args) {
        Level level = Level.D;  // Exemple avec le niveau "Discovery"
        System.out.println("La couleur du niveau est : " + getLevelColor(level));
    }
}