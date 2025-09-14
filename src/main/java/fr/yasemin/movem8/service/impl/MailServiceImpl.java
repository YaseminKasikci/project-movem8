package fr.yasemin.movem8.service.impl;

import fr.yasemin.movem8.service.IMailService;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.MailException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.*;
import org.springframework.stereotype.Service;

@Service
public class MailServiceImpl implements IMailService {

    private final JavaMailSender mailSender;
    private final String fromAddress;

    public MailServiceImpl(JavaMailSender mailSender,
                           @Value("${spring.mail.username}") String fromAddress) {
        this.mailSender   = mailSender;
        this.fromAddress  = fromAddress;
    }

    @Override
    public void sendSimpleMail(String to, String subject, String text) {
        SimpleMailMessage msg = new SimpleMailMessage();
        msg.setFrom(fromAddress);
        msg.setTo(to);
        msg.setSubject(subject);
        msg.setText(text);
        mailSender.send(msg);
    }

    @Override
    public void sendHtmlMail(String to, String subject, String htmlBody) {
        try {
            MimeMessage mime = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(mime, "UTF-8");
            helper.setFrom(fromAddress);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(htmlBody, true);  // true = HTML
            mailSender.send(mime);
        } catch (MessagingException | MailException e) {
            // log et/ou rethrow si vous voulez propager l’erreur
            throw new RuntimeException("Échec de l’envoi du mail HTML", e);
        }
    }
}
