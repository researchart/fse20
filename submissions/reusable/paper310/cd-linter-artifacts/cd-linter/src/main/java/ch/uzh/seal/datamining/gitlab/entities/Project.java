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
package ch.uzh.seal.datamining.gitlab.entities;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class Project {

	private String id, pathWithNamespace;
	private Date createdAt, lastActivityAt;
	private int starsCount, forksCount;
	private String defaultBranch;
	private List<Language> languages;
	private String language;
	

	public Project(String id, String pathWithNamespace, Date createdAt, Date lastActivityAt, int starsCount,
			int forksCount) {
		super();
		this.id = id;
		this.pathWithNamespace = pathWithNamespace;
		this.createdAt = createdAt;
		this.lastActivityAt = lastActivityAt;
		this.starsCount = starsCount;
		this.forksCount = forksCount;
		this.languages = new ArrayList<>();
	}
	
	public Project(String pathWithNamespace, int starsCount, String language) {
		this.pathWithNamespace = pathWithNamespace;
		this.starsCount = starsCount;
		this.language= language;
	}
	
	
	public Project(String id, String pathWithNamespace, Date createdAt, Date lastActivityAt, int starsCount,
			int forksCount, String default_branch) {
		super();
		this.id = id;
		this.pathWithNamespace = pathWithNamespace;
		this.createdAt = createdAt;
		this.lastActivityAt = lastActivityAt;
		this.starsCount = starsCount;
		this.forksCount = forksCount;
		this.setDefaultBranch(default_branch);
		this.languages = new ArrayList<>();
	}
	
	public Project(String id, String pathWithNamespace, Date createdAt, Date lastActivityAt, int starsCount,
			int forksCount, List<Language> languages) {
		super();
		this.id = id;
		this.pathWithNamespace = pathWithNamespace;
		this.createdAt = createdAt;
		this.lastActivityAt = lastActivityAt;
		this.starsCount = starsCount;
		this.forksCount = forksCount;
		this.languages = languages;
	}
	
	/**
	 * empty constructor
	 */
	public Project() {
		this.id = "-4";
		this.pathWithNamespace = "random";
		this.createdAt = new Date();
		this.lastActivityAt = new Date();
		this.starsCount = -3;
		this.forksCount = -4;
		this.languages = new ArrayList<>();
	}
	
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	public String getPathWithNamespace() {
		return pathWithNamespace;
	}
	public void setPathWithNamespace(String pathWithNamespace) {
		this.pathWithNamespace = pathWithNamespace;
	}
	public Date getCreatedAt() {
		return createdAt;
	}
	public void setCreatedAt(Date createdAt) {
		this.createdAt = createdAt;
	}
	public Date getLastActivityAt() {
		return lastActivityAt;
	}
	public void setLastActivityAt(Date lastActivityAt) {
		this.lastActivityAt = lastActivityAt;
	}
	public int getStarsCount() {
		return starsCount;
	}
	public void setStarsCount(int starsCount) {
		this.starsCount = starsCount;
	}
	public int getForksCount() {
		return forksCount;
	}
	public void setForksCount(int forksCount) {
		this.forksCount = forksCount;
	}
	public List<Language> getLanguages() {
		return languages;
	}
	public void setLanguages(List<Language> languages) {
		this.languages = languages;
	}
	public void addLangugage(Language lang) {
		languages.add(lang);
	}
	
	public String getMaxLanguageName() {
		if(languages.size() == 0)
			return null;
		
		String maxLanguage = null;
		double maxValue = 0;
		
		for(Language lang: languages) {
			String name = lang.getName();
			double percentage = lang.getPercentage();
			
			if(percentage >= maxValue) {
				maxLanguage = name;
				maxValue = percentage;
			}
		}
		
		return maxLanguage;
		
	}
	
/*	public String toString() {
		
		String res =  id + "," + pathWithNamespace +  "," + createdAt +  "," + lastActivityAt +  "," + starsCount
				+  "," + forksCount;
		
		if(languages.size() == 0)
			return res;
		else {
			res = res + "," + languages.get(0).getName() + ",";
			
			
			for(Language l : languages) {
				res = res +  "&" + l.getName() +  ":" + l.getPercentage();
			}
		}
		
		
		return res;
	}*/

	public String getDefaultBranch() {
		return defaultBranch;
	}

	public void setDefaultBranch(String defaultBranch) {
		this.defaultBranch = defaultBranch;
	}


	public String getLanguage() {
		return language;
	}


	public void setLanguage(String language) {
		this.language = language;
	}

	
	
}
