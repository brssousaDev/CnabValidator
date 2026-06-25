package br.com.cnabvalidador.resource;

import br.com.cnabvalidador.model.LayoutCategory;
import br.com.cnabvalidador.service.LayoutService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/layouts")
public class LayoutResource {

    @Autowired
    private LayoutService layoutService;

    @GetMapping
    public List<LayoutCategory> list() {
        return layoutService.listCategories();
    }
}
