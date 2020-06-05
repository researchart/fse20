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

public class Issue {

	private String id, iid, state, created_at, closed_at;
	private User[] assignees;
	private User assignee;
	private int upvotes, downvotes, user_notes_count, merge_requests_count;
	private boolean has_tasks;
	private String[] labels;
	public String getId() {
		return id;
	}
	public String getIid() {
		return iid;
	}
	public void setIid(String iid) {
		this.iid = iid;
	}
	public void setId(String id) {
		this.id = id;
	}
	public String getState() {
		return state;
	}
	public void setState(String state) {
		this.state = state;
	}
	public String getCreated_at() {
		return created_at;
	}
	public void setCreated_at(String created_at) {
		this.created_at = created_at;
	}
	public String getClosed_at() {
		return closed_at;
	}
	public void setClosed_at(String closed_at) {
		this.closed_at = closed_at;
	}
	public String[] getLabels() {
		return labels;
	}
	public void setLabels(String[] labels) {
		this.labels = labels;
	}
	
	public User[] getAssignees() {
		return assignees;
	}
	public void setAssignees(User[] assignees) {
		this.assignees = assignees;
	}
	public User getAssignee() {
		return assignee;
	}
	public void setAssignee(User assignee) {
		this.assignee = assignee;
	}
	public int getUpvotes() {
		return upvotes;
	}
	public void setUpvotes(int upvotes) {
		this.upvotes = upvotes;
	}
	public int getDownvotes() {
		return downvotes;
	}
	public void setDownvotes(int downvotes) {
		this.downvotes = downvotes;
	}
	public int getUser_notes_count() {
		return user_notes_count;
	}
	public void setUser_notes_count(int user_notes_count) {
		this.user_notes_count = user_notes_count;
	}
	public int getMerge_requests_count() {
		return merge_requests_count;
	}
	public void setMerge_requests_count(int merge_requests_count) {
		this.merge_requests_count = merge_requests_count;
	}
	public boolean isHas_tasks() {
		return has_tasks;
	}
	public void setHas_tasks(boolean has_tasks) {
		this.has_tasks = has_tasks;
	}
	public String toString() {
		String labels_s = "";
		
		for(String label : labels)
			labels_s = labels_s + "&" + label;
		
		return id + "," + labels_s + "," + created_at + "," +
		closed_at + "," + state;
	}
	
}
