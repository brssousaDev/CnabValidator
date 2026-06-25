package br.com.cnabvalidador.model;

import java.util.List;
import java.util.Map;

public class Layout {
    private boolean seqShow;
    private Rules rules;
    private Map<String, String> keyMap;
    private Map<String, RegisterDefinition> layoutDefinition;

    public Layout() {
    }

    public Layout(boolean seqShow, Rules rules, Map<String, String> keyMap, 
                  Map<String, RegisterDefinition> layoutDefinition) {
        this.seqShow = seqShow;
        this.rules = rules;
        this.keyMap = keyMap;
        this.layoutDefinition = layoutDefinition;
    }

    public boolean isSeqShow() {
        return seqShow;
    }

    public void setSeqShow(boolean seqShow) {
        this.seqShow = seqShow;
    }

    public Rules getRules() {
        return rules;
    }

    public void setRules(Rules rules) {
        this.rules = rules;
    }

    public Map<String, String> getKeyMap() {
        return keyMap;
    }

    public void setKeyMap(Map<String, String> keyMap) {
        this.keyMap = keyMap;
    }

    public Map<String, RegisterDefinition> getLayoutDefinition() {
        return layoutDefinition;
    }

    public void setLayoutDefinition(Map<String, RegisterDefinition> layoutDefinition) {
        this.layoutDefinition = layoutDefinition;
    }
}
