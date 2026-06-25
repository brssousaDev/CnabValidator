package br.com.cnabvalidador.service;

import br.com.cnabvalidador.model.Layout;
import br.com.cnabvalidador.model.LayoutCategory;
import br.com.cnabvalidador.parser.LayoutParser;

import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.io.InputStream;
import java.util.*;

@Service
public class LayoutService {

    private static final String[] CATEGORY_NAMES = {
        "Cartoes", "cobranca_bco_corresp", "cobranca_bradesco", "cobranca_cartorio",
        "cobranca_grafica", "cobranca_itau", "cobranca_matera", "cobranca_paulista_softban",
        "cobranca_Santander", "cobranca_terceiros", "Compensacao", "Convenios",
        "Convenios_bradesco_pagamentos", "Emprestimo_Apar", "Emprestimo_auditoria_bacen",
        "Emprestimo_pac", "emprestimo_plista", "Emprestimo_vendor", "JUD",
        "Migra_dados_legado"
    };

    public List<LayoutCategory> listCategories() {
        List<LayoutCategory> categories = new ArrayList<>();

        for (String categoryName : CATEGORY_NAMES) {
            try {
                List<String> layouts = listLayoutsForCategory(categoryName);
                if (!layouts.isEmpty()) {
                    categories.add(new LayoutCategory(categoryName, layouts));
                }
            } catch (Exception e) {
                // Skip if category not found or has no layouts
            }
        }

        return categories;
    }

    private List<String> listLayoutsForCategory(String categoryName) throws IOException {
        List<String> layouts = new ArrayList<>();

        // PathMatchingResourcePatternResolver: equivalente ao ClassPathUtils.consumeAsPaths() do Quarkus.
        // Funciona corretamente tanto em execução standalone quanto dentro de JAR.
        PathMatchingResourcePatternResolver resolver = new PathMatchingResourcePatternResolver();
        Resource[] resources = resolver.getResources("classpath:layouts/" + categoryName + "/*.yml");

        Arrays.stream(resources)
                .map(r -> {
                    String filename = r.getFilename();
                    return filename != null ? filename.replace(".yml", "") : null;
                })
                .filter(Objects::nonNull)
                .sorted()
                .forEach(layouts::add);

        return layouts;
    }

    public Layout loadLayout(String category, String layoutName) throws IOException {
        String resourcePath = "layouts/" + category + "/" + layoutName + ".yml";

        // ClassLoader.getResourceAsStream() é independente de framework — funciona igual no Spring Boot.
        ClassLoader classLoader = Thread.currentThread().getContextClassLoader();
        InputStream layoutStream = classLoader.getResourceAsStream(resourcePath);

        if (layoutStream == null) {
            throw new IOException("Layout not found: " + resourcePath);
        }

        LayoutParser parser = new LayoutParser();
        return parser.parse(layoutStream);
    }
}
