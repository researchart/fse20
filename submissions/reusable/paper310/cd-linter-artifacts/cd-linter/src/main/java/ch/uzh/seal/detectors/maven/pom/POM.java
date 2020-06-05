package ch.uzh.seal.detectors.maven.pom;

import ch.uzh.seal.detectors.maven.versioning.entities.Dependency;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Objects;

public class POM {

    private String raw;
    private String groupId;
    private String artifactId;
    private String version;
    private String path;
    private POM parent;

    private HashMap<String,String> properties = new HashMap<>();

    private ArrayList<Dependency> dependencies = new ArrayList<>();

    private ArrayList<String> modules = new ArrayList<>();

    public String getRaw() {
        return raw;
    }

    public void setRaw(String raw) {
        this.raw = raw;
    }

    public void addProperty(String name, String value) {
        properties.put(name, value);
    }

    public HashMap<String, String> getProperties() {
        return properties;
    }

    public String getProperty(String name) {
        return properties.get(name);
    }

    public void addDependency(Dependency dep) {
        dependencies.add(dep);
    }

    public ArrayList<Dependency> getDependencies() {

        ArrayList<Dependency> deps = new ArrayList<>();

        for (Dependency dep : dependencies) {
            // resolve version if missing
            if (dep.getVersionSpecifier().getRaw().equals("")) {
                if (hasParent()) {
                    POM parentPOM = getParent();
                    for (Dependency parentDep : parentPOM.getDependencies()) {
                        if (dep.getName().equals(parentDep.getName())) {
                            dep.setVersionSpecifier(parentDep.getVersionSpecifier());
                        }
                    }
                }

                deps.add(dep);
            }
            else
                deps.add(dep);
        }

        return deps;
    }

    public void addModule(String module) {
        modules.add(module);
    }

    public ArrayList<String> getModules() {
        return modules;
    }

    public void setGroupId(String groupId) {
        this.groupId = groupId;
    }

    public void setArtifactId(String artifactId) {
        this.artifactId = artifactId;
    }

    public void setVersion(String version) {
        this.version = version;
    }

    public String getGroupId() {
        return groupId;
    }

    public String getArtifactId() {
        return artifactId;
    }

    public String getVersion() {
        return version;
    }

    public POM getParent() {
        return parent;
    }

    public void setParent(POM parent) {
        this.parent = parent;
    }

    public Boolean hasParent() {
        return parent != null
                && parent.getGroupId() != null
                && parent.getArtifactId() != null
                && parent.getVersion() != null;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    @Override
    public String toString() {
        return "POM{" +
                "groupId='" + groupId + '\'' +
                ", artifactId='" + artifactId + '\'' +
                ", version='" + version + '\'' +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        POM pom = (POM) o;
        return Objects.equals(groupId, pom.groupId) &&
                Objects.equals(artifactId, pom.artifactId) &&
                Objects.equals(version, pom.version);
    }

    @Override
    public int hashCode() {
        return Objects.hash(groupId, artifactId, version);
    }
}
