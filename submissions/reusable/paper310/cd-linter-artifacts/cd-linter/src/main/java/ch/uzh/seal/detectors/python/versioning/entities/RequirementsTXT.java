package ch.uzh.seal.detectors.python.versioning.entities;

import java.util.ArrayList;

public class RequirementsTXT {

    private ArrayList<Dependency> dependencies = new ArrayList<>();

    public void addDependency(Dependency dependency) {
        dependencies.add(dependency);
    }

    public ArrayList<Dependency> getDependencies() {
        return dependencies;
    }
}
