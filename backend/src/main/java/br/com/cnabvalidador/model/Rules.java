package br.com.cnabvalidador.model;

import java.util.List;

public class Rules {
    private List<KeyLength> keyLength;

    public Rules() {
    }

    public Rules(List<KeyLength> keyLength) {
        this.keyLength = keyLength;
    }

    public List<KeyLength> getKeyLength() {
        return keyLength;
    }

    public void setKeyLength(List<KeyLength> keyLength) {
        this.keyLength = keyLength;
    }
}
