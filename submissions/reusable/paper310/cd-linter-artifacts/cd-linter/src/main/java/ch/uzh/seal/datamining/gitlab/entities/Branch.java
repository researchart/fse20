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

import com.google.gson.annotations.SerializedName;

public class Branch {

	private String name;
	
	@SerializedName("default")
	private boolean d_efault;

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public boolean getDefault() {
		return d_efault;
	}

	public void setDefault(boolean d_efault) {
		this.d_efault = d_efault;
	}

	@Override
	public String toString() {
		return "Branch [name=" + name + ", d_efault=" + d_efault + "]";
	}
	
	
}
