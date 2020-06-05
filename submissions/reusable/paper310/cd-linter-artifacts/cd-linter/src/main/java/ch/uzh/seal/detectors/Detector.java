package ch.uzh.seal.detectors;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.project.entities.LintProject;

import java.util.List;

public abstract class Detector {

    protected LintProject project;

    public Detector(LintProject project) {
        this.project = project;
    }

    public abstract List<CIAntiPattern> lint() throws Exception;

    public static String removeIllegalCharsInID(String id) {
        return id.replaceAll("[ <>#%\"{}|^'`;\\[\\]/?:@&=+$,.()\\\\]", "-");
    }
}
