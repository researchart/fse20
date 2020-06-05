package ch.uzh.seal.detectors.gitlabyaml.entities;

public class Environment {

    private String name = "";
    private String url = "";
    private String on_stop = "";
    private String action = "";

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getOn_stop() {
        return on_stop;
    }

    public void setOn_stop(String on_stop) {
        this.on_stop = on_stop;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }
}
