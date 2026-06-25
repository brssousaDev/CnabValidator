package br.com.cnabvalidador.resource;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/health")
public class HealthResource {

    @GetMapping
    public HealthResponse health() {
        return new HealthResponse("UP", "CNAB Validador Backend is running");
    }

    public static class HealthResponse {
        public String status;
        public String message;

        public HealthResponse(String status, String message) {
            this.status = status;
            this.message = message;
        }
    }
}
