package fr.yasemin.movem8.util;

import java.time.LocalDateTime;
//import java.time.ZonedDateTime;
//import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.format.FormatStyle;
import java.util.Locale;

import org.springframework.context.i18n.LocaleContextHolder;

public class DateTimeFormatterUtil {

    public static String formatDateTime(LocalDateTime dateTime) {
        Locale locale = LocaleContextHolder.getLocale();
        DateTimeFormatter formatter = DateTimeFormatter
                .ofLocalizedDateTime(FormatStyle.MEDIUM)
                .withLocale(locale);
        return dateTime.format(formatter);
    }

//    // Optionnel : avec timezone
//    public static String formatDateTimeWithTimezone(LocalDateTime dateTime, ZoneId userZone) {
//        ZonedDateTime zonedDateTime = dateTime.atZone(ZoneId.of("UTC")).withZoneSameInstant(userZone);
//        Locale locale = LocaleContextHolder.getLocale();
//        DateTimeFormatter formatter = DateTimeFormatter
//                .ofLocalizedDateTime(FormatStyle.MEDIUM)
//                .withLocale(locale);
//        return formatter.format(zonedDateTime);
//    }
}

