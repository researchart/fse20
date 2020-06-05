package ch.uzh.seal.detectors.gitlabyaml.entities;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class GitLabYAML {

    private String raw;

    public String getRaw() {
        return raw;
    }

    public void setRaw(String raw) {
        this.raw = raw;
    }

    private Map<String, String> variables = new HashMap<>();

    public Map<String, String> getVariables() {
        return variables;
    }

    public void setVariables(Map<String, String> variables) {
        this.variables = variables;
    }
    
    private ArrayList<String> include = new ArrayList<>();
    
	public ArrayList<String> getInclude() {
		return include;
	}

	public void setInclude(ArrayList<String> include) {
		this.include = include;
	}  
    
    List<String> stages = new ArrayList<>();
    
    public List<String> getStages() {
		return stages;
	}

	public void setStages(List<String> stages) {
		this.stages = stages;
	}

	private Map<String, Job> jobs = new HashMap<>();

    public Map<String, Job> getJobs() {
        return jobs;
    }

    public void addJob(String name, Job job) {
        jobs.put(name, job);
    }

    public Job getJob(String name) {
        return jobs.get(name);
    }
    
    public void addVariable(String key, String value) {
    	variables.put(key, value);
    }
    
    public void addStage(String s) {
    	boolean found = false;
    	
    	for(String stage: stages) {
    		if(stage.equalsIgnoreCase(s))
    			found = true;
    	}
    	
    	if(!found)
    		stages.add(s);
    }
}
