package br.com.cnabvalidador.model;

import java.util.List;

public class LayoutCategory {
    private String category;
    private List<String> layouts;

    public LayoutCategory() {
    }

    public LayoutCategory(String category, List<String> layouts) {
        this.category = category;
        this.layouts = layouts;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public List<String> getLayouts() {
        return layouts;
    }

    public void setLayouts(List<String> layouts) {
        this.layouts = layouts;
    }
}
