package ch.uzh.seal.detectors.maven.versioning.entities;


import java.util.Objects;

public class Dependency {

    private String groupID = "";
    private String artifactID = "";

    private String name;

    private VersionSpecifier versionSpecifier;

    public Dependency(String name, VersionSpecifier versionSpecifier) {
        this.name = name;
        this.versionSpecifier = versionSpecifier;
    }

    public void setVersionSpecifier(VersionSpecifier versionSpecifier) {
        this.versionSpecifier = versionSpecifier;
    }

    public String getName() {
        return name;
    }

    public String getGroupID() {
        return groupID;
    }

    public void setGroupID(String groupID) {
        this.groupID = groupID;
    }

    public String getArtifactID() {
        return artifactID;
    }

    public void setArtifactID(String artifactID) {
        this.artifactID = artifactID;
    }

    public VersionSpecifier getVersionSpecifier() {
        return versionSpecifier;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Dependency that = (Dependency) o;
        return name.equals(that.name) &&
                versionSpecifier.equals(that.versionSpecifier);
    }

    @Override
    public int hashCode() {
        return Objects.hash(name, versionSpecifier);
    }

    @Override
    public String toString() {
        return "Name: " + name + ", Version Specifier: " + versionSpecifier;
    }
}
