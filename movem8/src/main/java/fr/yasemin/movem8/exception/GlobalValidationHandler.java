package fr.yasemin.movem8.exception;

import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalValidationHandler extends ResponseEntityExceptionHandler {

    @Override
    protected ResponseEntity<Object> handleMethodArgumentNotValid(
            MethodArgumentNotValidException ex,
            HttpHeaders headers,
            HttpStatusCode status,        
            WebRequest request) {

        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult()
          .getFieldErrors()
          .forEach(err -> errors.put(err.getField(), err.getDefaultMessage()));

        return ResponseEntity
                .status(status)
                .body(errors);
    }
}
