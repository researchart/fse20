package ch.uzh.seal.detectors.gitlabyaml.parsers;

import ch.uzh.seal.detectors.gitlabyaml.entities.GitLabYAML;
import ch.uzh.seal.detectors.gitlabyaml.entities.Job;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.yaml.snakeyaml.Yaml;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Set;

public class GitLabYAMLParser {

	private GitLabYAML gitLabYAML;

	public static final String STAGES = "stages";
	public static final String INCLUDE = "include"; 

	private Set<String> nonJobs = Set.of(
			"image",
			"services",
			"stages",
			"types",
			"before_script",
			"after_script",
			"variables",
			"cache",
			"include"
			);

	private Boolean isJob(String job) {
		return !(nonJobs.contains(job));
	}

	public GitLabYAML parse(String content) {

		gitLabYAML = new GitLabYAML();

		gitLabYAML.setRaw(content);

		if (!content.equals("")) {

			Yaml yaml = new Yaml();

			LinkedHashMap<String, Object> pipeline = (LinkedHashMap<String, Object>) yaml.load(content);

			for (String jobName : pipeline.keySet()) {

				if (jobName.equals("variables")) {
					LinkedHashMap<String, String> variables = (LinkedHashMap<String, String>) pipeline.get(jobName);
					gitLabYAML.setVariables(variables);
				}

				if(jobName.equals(STAGES)) {
					List<String> stages = (ArrayList<String>) pipeline.get(STAGES);
					gitLabYAML.setStages(stages);
				}

				if(jobName.equals(INCLUDE)) {
					ArrayList<Object> includes = (ArrayList<Object>) pipeline.get(INCLUDE);

					ArrayList<String> include_deps = new ArrayList<String>();

					for(Object in: includes) {
						if(in instanceof String) {
							include_deps.add((String)in);
							System.out.println("local found");
							}
						else {
							LinkedHashMap<String,String> locations = (LinkedHashMap<String,String>)in;
							for(String key : locations.keySet()) {
								if(key.equals("local")) {
									String location = locations.get(key);
									include_deps.add(location);
									System.out.println("local found");
								}
							}
							
						}
					}
					gitLabYAML.setInclude(include_deps);
				}

				else if (isJob(jobName)) {

					Object val = pipeline.get(jobName);

					ObjectMapper oMapper = new ObjectMapper();
					oMapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
					oMapper.configure(DeserializationFeature.ACCEPT_SINGLE_VALUE_AS_ARRAY, true);

					Job job;

					try {
						job = oMapper.convertValue(val, Job.class);
					}
					catch (IllegalArgumentException e) {
						System.out.println("Job "+jobName+" cannot be parsed");
						continue;
					}

					job.setName(jobName);

					gitLabYAML.addJob(jobName, job);
				}
			}
		}

		return gitLabYAML;
	}
}
