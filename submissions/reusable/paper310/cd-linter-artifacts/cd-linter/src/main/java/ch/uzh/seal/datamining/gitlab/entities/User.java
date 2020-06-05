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

public class User {

	private String avatar_url;

	private String location;

	private String linkedin;

	private String web_url;

	private String state;

	private String id;

	private String twitter;

	private String organization;

	private String username;

	private String bio;

	private String name;

	private String created_at;

	private String website_url;

	private String public_email;

	private String skype;

	public String getAvatar_url ()
	{
		return avatar_url;
	}

	public void setAvatar_url (String avatar_url)
	{
		this.avatar_url = avatar_url;
	}

	public String getLocation ()
	{
		return location;
	}

	public void setLocation (String location)
	{
		this.location = location;
	}

	public String getLinkedin ()
	{
		return linkedin;
	}

	public void setLinkedin (String linkedin)
	{
		this.linkedin = linkedin;
	}

	public String getWeb_url ()
	{
		return web_url;
	}

	public void setWeb_url (String web_url)
	{
		this.web_url = web_url;
	}

	public String getState ()
	{
		return state;
	}

	public void setState (String state)
	{
		this.state = state;
	}

	public String getId ()
	{
		return id;
	}

	public void setId (String id)
	{
		this.id = id;
	}

	public String getTwitter ()
	{
		return twitter;
	}

	public void setTwitter (String twitter)
	{
		this.twitter = twitter;
	}

	public String getOrganization ()
	{
		return organization;
	}

	public void setOrganization (String organization)
	{
		this.organization = organization;
	}

	public String getUsername ()
	{
		return username;
	}

	public void setUsername (String username)
	{
		this.username = username;
	}

	public String getBio ()
	{
		return bio;
	}

	public void setBio (String bio)
	{
		this.bio = bio;
	}

	public String getName ()
	{
		return name;
	}

	public void setName (String name)
	{
		this.name = name;
	}

	public String getCreated_at ()
	{
		return created_at;
	}

	public void setCreated_at (String created_at)
	{
		this.created_at = created_at;
	}

	public String getWebsite_url ()
	{
		return website_url;
	}

	public void setWebsite_url (String website_url)
	{
		this.website_url = website_url;
	}

	public String getPublic_email ()
	{
		return public_email;
	}

	public void setPublic_email (String public_email)
	{
		this.public_email = public_email;
	}

	public String getSkype ()
	{
		return skype;
	}

	public void setSkype (String skype)
	{
		this.skype = skype;
	}

	@Override
	public String toString()
	{
		return "ClassPojo [avatar_url = "+avatar_url+", location = "+location+", linkedin = "+linkedin+", web_url = "+web_url+", state = "+state+", id = "+id+", twitter = "+twitter+", organization = "+organization+", username = "+username+", bio = "+bio+", name = "+name+", created_at = "+created_at+", website_url = "+website_url+", public_email = "+public_email+", skype = "+skype+"]";
	}
}
