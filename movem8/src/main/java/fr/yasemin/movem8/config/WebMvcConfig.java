package fr.yasemin.movem8.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.http.CacheControl;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Paths;
import java.time.Duration;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

  @Override
  public void addResourceHandlers(ResourceHandlerRegistry registry) {
    // Sert tout le dossier local "upload" sous l’URL /upload/**
    // "file:" + absolutePath + "/" évite les soucis de slash manquant
    String uploadPath = Paths.get("upload").toAbsolutePath().toString();

    registry.addResourceHandler("/upload/**")
        .addResourceLocations("file:" + uploadPath + "/")
        .setCacheControl(CacheControl.maxAge(Duration.ofDays(7)).cachePublic()) // cache côté client (optionnel)
        .resourceChain(true);
  }
}
