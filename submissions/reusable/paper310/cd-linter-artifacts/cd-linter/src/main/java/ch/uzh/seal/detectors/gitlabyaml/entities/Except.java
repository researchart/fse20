package ch.uzh.seal.detectors.gitlabyaml.entities;

import java.util.ArrayList;
import java.util.List;

public class Except {
    private Refs refs = new Refs();
    private Boolean kubernetes = false;
    private List<String> variables = new ArrayList<>();
    private List<String> changes = new ArrayList<>();

    public Except(){
        refs.setBranches(false);
        refs.setTags(false);
    }

    public Refs getRefs() {
        return refs;
    }

    public Boolean getKubernetes() {
        return kubernetes;
    }

    public void setKubernetes(Boolean kubernetes) {
        this.kubernetes = kubernetes;
    }

    public List<String> getVariables() {
        return variables;
    }

    public void addVariable(String variable){
        variables.add(variable);
    }

    public List<String> getChanges() {
        return changes;
    }

    public void addChange(String change){
        changes.add(change);
    }
}
