package fr.yasemin.movem8.service;

public interface IMailService {
    void sendSimpleMail(String to, String subject, String content);
    void sendHtmlMail(String to, String subject, String htmlBody);
}
