package ch.uzh.seal.detectors.gitlabyaml.entities;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

public class Refs {
    // user-defined names of branches and tags
    private List<String> names = new ArrayList<>();

    // special keywords
    private Boolean branches = true;
    private Boolean tags = true;
    private Boolean api = false;
    private Boolean external = false;
    private Boolean pipelines = false;
    private Boolean pushes = false;
    private Boolean schedules = false;
    private Boolean triggers = false;
    private Boolean web = false;
    private Boolean merge_requests = false;
    private Boolean chats = false;

    // if no keywords are set, then branches and tags are true
    // the first time a keyword is set, branches and tags are set to false
    private Boolean reset = false;

    private Set<String> keywords = Set.of(
            "branches",
            "tags",
            "api",
            "external",
            "pipelines",
            "pushes",
            "schedules",
            "triggers",
            "web",
            "merge_requests",
            "chats"
            );

    public void addRef(String ref){
        if (!reset && keywords.contains(ref)) {
            reset = true;
            branches = false;
            tags = false;
        }

        switch (ref){
            case "branches":
                branches = true;
                break;
            case "tags":
                tags = true;
                break;
            case "api":
                api = true;
                break;
            case "external":
                external = true;
                break;
            case "pipelines":
                pipelines = true;
                break;
            case "pushes":
                pushes = true;
                break;
            case "schedules":
                schedules = true;
                break;
            case "triggers":
                triggers = true;
                break;
            case "web":
                web = true;
                break;
            case "merge_requests":
                merge_requests = true;
                break;
            case "chats":
                chats = true;
                break;
            default:
                names.add(ref);
        }
    }

    public List<String> getNames() {
        return names;
    }

    public Boolean hasBranches() {
        return branches;
    }

    public Boolean hasTags() {
        return tags;
    }

    public Boolean hasAPI() {
        return api;
    }

    public Boolean hasExternal() {
        return external;
    }

    public Boolean hasPipelines() {
        return pipelines;
    }

    public Boolean hasPushes() {
        return pushes;
    }

    public Boolean hasSchedules() {
        return schedules;
    }

    public Boolean hasTriggers() {
        return triggers;
    }

    public Boolean hasWeb() {
        return web;
    }

    public Boolean hasMergeRequests() {
        return merge_requests;
    }

    public Boolean hasChats() {
        return chats;
    }

    public void setBranches(Boolean branches) {
        this.branches = branches;
    }

    public void setTags(Boolean tags) {
        this.tags = tags;
    }

    public void setApi(Boolean api) {
        this.api = api;
    }

    public void setExternal(Boolean external) {
        this.external = external;
    }

    public void setPipelines(Boolean pipelines) {
        this.pipelines = pipelines;
    }

    public void setPushes(Boolean pushes) {
        this.pushes = pushes;
    }

    public void setSchedules(Boolean schedules) {
        this.schedules = schedules;
    }

    public void setTriggers(Boolean triggers) {
        this.triggers = triggers;
    }

    public void setWeb(Boolean web) {
        this.web = web;
    }

    public void setMerge_requests(Boolean merge_requests) {
        this.merge_requests = merge_requests;
    }

    public void setChats(Boolean chats) {
        this.chats = chats;
    }
}
