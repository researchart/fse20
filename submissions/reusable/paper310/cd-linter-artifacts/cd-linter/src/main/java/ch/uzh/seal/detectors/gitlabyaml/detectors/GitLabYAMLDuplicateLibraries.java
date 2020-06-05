/**
 * Copyright 2018 University of Zurich
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package ch.uzh.seal.detectors.gitlabyaml.detectors;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.detectors.gitlabyaml.entities.GitLabYAML;
import ch.uzh.seal.detectors.gitlabyaml.entities.Job;
import ch.uzh.seal.project.entities.LintProject;

public class GitLabYAMLDuplicateLibraries extends GitLabYAMLDetector{

	private String category = "Duplicate-Libraries";

	public GitLabYAMLDuplicateLibraries(LintProject project) {
        super(project);
    }
	
    private List<String> identifyExamples(Map<String, Job> jobs) {
       // Map<String, Job> filteredJobs = new HashMap<>();

    	List<String> libraries = new ArrayList<>();
    	
        for (String name : jobs.keySet()) {
            Job job = jobs.get(name);
            List<String> before_script = job.getBefore_script();
            List<String> script = job.getScript();
            List<String> after_script = job.getAfter_script();
            
            String example1 = identifyLocalDependencies(before_script);
            String example2 = identifyLocalDependencies(script);
            String example3 = identifyLocalDependencies(after_script);
            
            if(example1 != null)
            	libraries.add(example1);
            
            if(example2 != null)
            	libraries.add(example2);
            
            if(example3 != null)
            	libraries.add(example3);
            
        }

        return libraries;
    }
	
	@Override
	public List<CIAntiPattern> lint() throws Exception {
		
		List<CIAntiPattern> antiPatterns = new ArrayList<>();
        GitLabYAML gitLabYAML = getGitLabYAML(project);
        Map<String, Job> jobs = gitLabYAML.getJobs();
        List<String> examples = identifyExamples(jobs);
		
		String cfgFileName = ".gitlab-ci.yml";
        String projectName = project.getName();
        String remoteRepoPath = project.getRemotePath();
        String remoteCfgLink = project.getFullRemotePath(cfgFileName, true);
        String localCfgLink = project.getFullLocalPath(cfgFileName);
		
        for(String ex: examples) {
        	CIAntiPattern antiPattern = new CIAntiPattern();
        	String stage = "null";
        	String lineNumber = "null";
        	String jobName = "null";
        	
        	antiPattern.setId(generateID(projectName, jobName));
            antiPattern.setProject(projectName);
            antiPattern.setRemoteRepoLink(remoteRepoPath);
            antiPattern.setRemoteCfgLink(remoteCfgLink);
            antiPattern.setLocalCfgLink(localCfgLink);
            antiPattern.setStage(stage);
            antiPattern.setCategory(category);
            antiPattern.setEntity(jobName);
            antiPattern.setMessage(ex);
            antiPattern.setContext(gitLabYAML.getRaw());
            antiPattern.setLineNumber(lineNumber);
            antiPattern.setCfgFileName(cfgFileName);
            antiPatterns.add(antiPattern);
        }
        
   /*     
		String id;
		String remoteRepoLink;
		String stage;
		String subCategory;
		String entity;
		String message;
		String context;
		String lineNumber;
		CIAntiPattern antiPattern = new CIAntiPattern(id, remoteRepoLink, 
				remoteCfgLink, localCfgLink, projectName, stage, category, 
				subCategory, entity, message, context, 
				lineNumber, cfgFileName);*/
		
		return antiPatterns;
	}
	
	private String identifyLocalDependencies(List<String> script) {
		
		String goal1 = "install:install-file";
		String goal2 = "deploy:deploy-file";
		
		for(String line : script) {
			if(line.contains(goal1) || line.contains(goal2))
				return line;
		}
		return null;
	}
	
    public String generateID(String projectName, String jobName) {
        return removeIllegalCharsInID(projectName + "__" + category + "__" + jobName);
    }

}
