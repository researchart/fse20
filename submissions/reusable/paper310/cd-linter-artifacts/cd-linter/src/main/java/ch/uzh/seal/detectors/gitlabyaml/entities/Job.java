package ch.uzh.seal.detectors.gitlabyaml.entities;

import com.fasterxml.jackson.annotation.JsonSetter;
import com.fasterxml.jackson.databind.JsonNode;

import java.util.ArrayList;
import java.util.List;

public class Job {

	public static final String TEST= "test";
	public static final String BUILD= "build";
	public static final String DEPLOY= "deploy";
	
	public static final String DEFAULT_STAGE= TEST;
	
    private String name;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    // https://docs.gitlab.com/ee/ci/yaml/#allow_failure
    private Boolean allow_failure = false;

    public Boolean getAllow_failure() {
        return allow_failure;
    }

    public void setAllow_failure(Boolean allow_failure) {
        this.allow_failure = allow_failure;
    }

    // https://docs.gitlab.com/ee/ci/yaml/#retry
    private Retry retry = new Retry();

    @JsonSetter("retry")
    public void setRetryInternal(JsonNode retryInternal) {
        if (retryInternal != null) {
            if (retryInternal.isInt()) {
                retry.setMax(retryInternal.asInt());
            }
            else if (retryInternal.isObject()) {
                if (retryInternal.has("max")) {
                    int max = retryInternal.get("max").asInt();
                    retry.setMax(max);
                }

                if (retryInternal.has("when")) {
                    String when = retryInternal.get("when").asText();
                    retry.setWhen(when);
                }
            }
        }
    }

    public Retry getRetry() {
        return retry;
    }

    public List<String> getScript() {
        return script;
    }

    public void setScript(List<String> script) {
        this.script = script;
    }

    private List<String> script = new ArrayList<>();

    // overwrites the globally defined before_script and after_script
    // https://docs.gitlab.com/ee/ci/yaml/#before_script-and-after_script
    private List<String> before_script = new ArrayList<>();
    private List<String> after_script = new ArrayList<>();

    public List<String> getBefore_script() {
        return before_script;
    }

    public void setBefore_script(List<String> before_script) {
        this.before_script = before_script;
    }

    public List<String> getAfter_script() {
        return after_script;
    }

    public void setAfter_script(List<String> after_script) {
        this.after_script = after_script;
    }

    private String stage = DEFAULT_STAGE;

    public String getStage() {
        return stage;
    }

    public void setStage(String stage) {
        this.stage = stage;
    }

    // https://docs.gitlab.com/ee/ci/yaml/#when
    private When when = When.on_success;

    public When getWhen() {
        return when;
    }

    public void setWhen(String when) {
        this.when = When.valueOf(when);
    }

    private Only only = new Only();

    @JsonSetter("only")
    public void setOnlyInternal(JsonNode onlyInternal) {
        if (onlyInternal != null) {
            // simple structure
            // https://docs.gitlab.com/ee/ci/yaml/README.html#onlyexcept-basic
            if (onlyInternal.isArray()) {
                int i;
                for (i=0; i<onlyInternal.size(); i++) {
                    String value = onlyInternal.get(i).asText();
                    only.getRefs().addRef(value);
                }
            }
            // complex structure
            // https://docs.gitlab.com/ee/ci/yaml/README.html#onlyexcept-advanced
            else if (onlyInternal.isObject()) {
                if (onlyInternal.has("refs")) {
                    JsonNode node = onlyInternal.get("refs");
                    int i;
                    for (i=0; i<node.size(); i++) {
                        String value = node.get(i).asText();
                        only.getRefs().addRef(value);
                    }
                }

                if (onlyInternal.has("kubernetes")) {
                    only.setKubernetes(true);
                }

                if (onlyInternal.has("variables")) {
                    JsonNode node = onlyInternal.get("variables");
                    int i;
                    for (i=0; i<node.size(); i++) {
                        String value = node.get(i).asText();
                        only.addVariable(value);
                    }
                }

                if (onlyInternal.has("changes")) {
                    JsonNode node = onlyInternal.get("changes");
                    int i;
                    for (i=0; i<node.size(); i++) {
                        String value = node.get(i).asText();
                        only.addChange(value);
                    }
                }
            }
        }
    }

    public Only getOnly() {
        return only;
    }

    private Except except = new Except();

    @JsonSetter("except")
    public void setExceptInternal(JsonNode exceptInternal) {
        if (exceptInternal != null) {
            // simple structure
            // https://docs.gitlab.com/ee/ci/yaml/README.html#onlyexcept-basic
            if (exceptInternal.isArray()) {
                int i;
                for (i=0; i<exceptInternal.size(); i++) {
                    String value = exceptInternal.get(i).asText();
                    except.getRefs().addRef(value);
                }
            }
            // complex structure
            // https://docs.gitlab.com/ee/ci/yaml/README.html#onlyexcept-advanced
            else if (exceptInternal.isObject()) {
                if (exceptInternal.has("refs")) {
                    JsonNode node = exceptInternal.get("refs");
                    int i;
                    for (i=0; i<node.size(); i++) {
                        String value = node.get(i).asText();
                        except.getRefs().addRef(value);
                    }
                }

                if (exceptInternal.has("kubernetes")) {
                    except.setKubernetes(true);
                }

                if (exceptInternal.has("variables")) {
                    JsonNode node = exceptInternal.get("variables");
                    int i;
                    for (i=0; i<node.size(); i++) {
                        String value = node.get(i).asText();
                        except.addVariable(value);
                    }
                }

                if (exceptInternal.has("changes")) {
                    JsonNode node = exceptInternal.get("changes");
                    int i;
                    for (i=0; i<node.size(); i++) {
                        String value = node.get(i).asText();
                        except.addChange(value);
                    }
                }
            }
        }
    }

    public Except getExcept() {
        return except;
    }

    private  Environment environment = new Environment();

    public Environment getEnvironment() {
        return environment;
    }

    public void setEnvironment(Environment environment) {
        this.environment = environment;
    }

    // TODO: decide on suitable data structure later
    /*// keys: name, entrypoint
    // https://docs.gitlab.com/ee/ci/docker/using_docker_images.html#available-settings-for-image
    private HashMap<String, String> image = new HashMap<>();
    // keys: name, entrypoint, command, alias
    // https://docs.gitlab.com/ee/ci/docker/using_docker_images.html#available-settings-for-services
    private HashMap<String, String> services;
    // https://docs.gitlab.com/ee/ci/yaml/#tags
    private List<String> tags = new ArrayList<>();
    // keys: name, url
    // https://docs.gitlab.com/ee/ci/environments.html
    private HashMap<String, String> environment = new HashMap<>();
    // names of jobs from which the artifacts are downloaded
    // https://docs.gitlab.com/ee/ci/yaml/#dependencies
    private List<String> dependencies = new ArrayList<>();
    private String coverage;
    private String cache;
    private String artifacts;
    private int parallel;
    private String trigger;
    private String include;
    private String _extends;
    private String pages;
    private String variables;*/

}
