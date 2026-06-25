package br.com.cnabvalidador.resource;

import br.com.cnabvalidador.model.ValidationResult;
import br.com.cnabvalidador.service.CnabService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api")
public class FileResource {

    @Autowired
    private CnabService cnabService;

    @PostMapping(value = "/validate", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> validate(@RequestParam("file") MultipartFile file,
                                      @RequestParam("category") String category,
                                      @RequestParam("layout") String layout) {
        try {
            if (file == null || file.isEmpty() || category == null || layout == null) {
                return ResponseEntity.badRequest().body("Missing required parameters");
            }

            ValidationResult result = cnabService.validate(
                    file.getInputStream(),
                    file.getOriginalFilename(),
                    category,
                    layout
            );

            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(e.getMessage());
        }
    }

    @PostMapping(value = "/export", consumes = MediaType.APPLICATION_JSON_VALUE,
                 produces = MediaType.APPLICATION_OCTET_STREAM_VALUE)
    public ResponseEntity<byte[]> export(@RequestBody ValidationResult result) {
        try {
            byte[] content = cnabService.export(result);

            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION,
                            "attachment; filename=\"" + result.getFileName() + "\"")
                    .contentType(MediaType.APPLICATION_OCTET_STREAM)
                    .body(content);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
}
