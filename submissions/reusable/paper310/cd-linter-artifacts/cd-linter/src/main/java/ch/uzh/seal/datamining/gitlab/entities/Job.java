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

public class Job
{
    private String id;
    
	private String status;

    private String tag;

    private String web_url;

    private String stage;

    private Object artifacts;

    private String artifacts_expire_at;

    private String ref;

    private String duration;

    private Commit commit;

    private String coverage;

    private Pipeline pipeline;

    private String name;

    private String created_at;

    private String started_at;

    private Object runner;

    private String finished_at;

    private User user;

    public String getStatus ()
    {
        return status;
    }

    public void setStatus (String status)
    {
        this.status = status;
    }

    public String getTag ()
    {
        return tag;
    }

    public void setTag (String tag)
    {
        this.tag = tag;
    }

    public String getWeb_url ()
    {
        return web_url;
    }

    public void setWeb_url (String web_url)
    {
        this.web_url = web_url;
    }

    public String getStage ()
    {
        return stage;
    }

    public void setStage (String stage)
    {
        this.stage = stage;
    }



    public String getId ()
    {
        return id;
    }

    public void setId (String id)
    {
        this.id = id;
    }

    public String getRef ()
    {
        return ref;
    }

    public void setRef (String ref)
    {
        this.ref = ref;
    }

    public String getDuration ()
    {
        return duration;
    }

    public void setDuration (String duration)
    {
        this.duration = duration;
    }

    public Commit getCommit ()
    {
        return commit;
    }

    public void setCommit (Commit commit)
    {
        this.commit = commit;
    }


    public Pipeline getPipeline ()
    {
        return pipeline;
    }

    public void setPipeline (Pipeline pipeline)
    {
        this.pipeline = pipeline;
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

    public String getStarted_at ()
    {
        return started_at;
    }

    public void setStarted_at (String started_at)
    {
        this.started_at = started_at;
    }

    public String getFinished_at ()
    {
        return finished_at;
    }

    public void setFinished_at (String finished_at)
    {
        this.finished_at = finished_at;
    }

    public User getUser ()
    {
        return user;
    }

    public void setUser (User user)
    {
        this.user = user;
    }

    @Override
    public String toString()
    {
        return "ClassPojo [status = "+status+", "
        		+ "tag = "+tag+", "
        				+ "web_url = "+web_url+", "
        						+ "stage = "+stage+", "
        								+ "artifacts_expire_at = "+getArtifacts_expire_at()+", "
        										+ "id = "+id+", ref = "+ref+", duration = "+duration+", "
        												+ "commit = "+commit.getId()+", coverage = "+getCoverage()+", "
        														+ "pipeline = "+pipeline.getId()+", name = "+name+", created_at = "+created_at+", started_at = "+started_at+", finished_at = "+finished_at+"]";
    }


	public String getArtifacts_expire_at() {
		return artifacts_expire_at;
	}

	public void setArtifacts_expire_at(String artifacts_expire_at) {
		this.artifacts_expire_at = artifacts_expire_at;
	}

	public String getCoverage() {
		return coverage;
	}

	public void setCoverage(String coverage) {
		this.coverage = coverage;
	}
}
