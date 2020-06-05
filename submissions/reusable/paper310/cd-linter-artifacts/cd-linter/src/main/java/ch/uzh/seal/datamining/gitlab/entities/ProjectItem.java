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

public class ProjectItem {

	private String avatar_url;

	private String last_activity_at;

	private String ssh_url_to_repo;

	private String web_url;

	private String readme_url;

	private String id;

	private String default_branch;

	private String star_count;

	private String path_with_namespace;

	private String[] tag_list;

	private String description;

	private String name;

	private String path;

	private String created_at;

	private String http_url_to_repo;

	private String name_with_namespace;

	private String forks_count;
	
	private Object forked_from_project;

	public String getAvatar_url ()
	{
		return avatar_url;
	}

	public void setAvatar_url (String avatar_url)
	{
		this.avatar_url = avatar_url;
	}

	public String getLast_activity_at ()
	{
		return last_activity_at;
	}

	public void setLast_activity_at (String last_activity_at)
	{
		this.last_activity_at = last_activity_at;
	}

	public String getSsh_url_to_repo ()
	{
		return ssh_url_to_repo;
	}

	public void setSsh_url_to_repo (String ssh_url_to_repo)
	{
		this.ssh_url_to_repo = ssh_url_to_repo;
	}

	public String getWeb_url ()
	{
		return web_url;
	}

	public void setWeb_url (String web_url)
	{
		this.web_url = web_url;
	}

	public String getReadme_url ()
	{
		return readme_url;
	}

	public void setReadme_url (String readme_url)
	{
		this.readme_url = readme_url;
	}

	public String getId ()
	{
		return id;
	}

	public void setId (String id)
	{
		this.id = id;
	}

	public String getDefault_branch ()
	{
		return default_branch;
	}

	public void setDefault_branch (String default_branch)
	{
		this.default_branch = default_branch;
	}

	public String getStar_count ()
	{
		return star_count;
	}

	public void setStar_count (String star_count)
	{
		this.star_count = star_count;
	}

	public String getPath_with_namespace ()
	{
		return path_with_namespace;
	}

	public void setPath_with_namespace (String path_with_namespace)
	{
		this.path_with_namespace = path_with_namespace;
	}

	public String[] getTag_list ()
	{
		return tag_list;
	}

	public void setTag_list (String[] tag_list)
	{
		this.tag_list = tag_list;
	}

	public String getDescription ()
	{
		return description;
	}

	public void setDescription (String description)
	{
		this.description = description;
	}

	public String getName ()
	{
		return name;
	}

	public void setName (String name)
	{
		this.name = name;
	}

	public String getPath ()
	{
		return path;
	}

	public void setPath (String path)
	{
		this.path = path;
	}

	public String getCreated_at ()
	{
		return created_at;
	}

	public void setCreated_at (String created_at)
	{
		this.created_at = created_at;
	}

	public String getHttp_url_to_repo ()
	{
		return http_url_to_repo;
	}

	public void setHttp_url_to_repo (String http_url_to_repo)
	{
		this.http_url_to_repo = http_url_to_repo;
	}

	public String getName_with_namespace ()
	{
		return name_with_namespace;
	}

	public void setName_with_namespace (String name_with_namespace)
	{
		this.name_with_namespace = name_with_namespace;
	}

	public String getForks_count ()
	{
		return forks_count;
	}

	public void setForks_count (String forks_count)
	{
		this.forks_count = forks_count;
	}

	@Override
	public String toString()
	{
		return "ClassPojo [avatar_url = "+avatar_url+", last_activity_at = "+last_activity_at+", ssh_url_to_repo = "+ssh_url_to_repo+", web_url = "+web_url+", readme_url = "+readme_url+", id = "+id+", default_branch = "+default_branch+", star_count = "+star_count+", path_with_namespace = "+path_with_namespace+", tag_list = "+tag_list+", description = "+description+", name = "+name+", path = "+path+", created_at = "+created_at+", http_url_to_repo = "+http_url_to_repo+", name_with_namespace = "+name_with_namespace+", forks_count = "+forks_count+"]";
	}

	public Object getForked_from_project() {
		return forked_from_project;
	}

	public void setForked_from_project(Object forked_from_project) {
		this.forked_from_project = forked_from_project;
	}
}


