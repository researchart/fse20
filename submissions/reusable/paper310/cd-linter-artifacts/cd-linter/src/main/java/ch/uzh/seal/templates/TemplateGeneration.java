/**
 * Copyright 2019 Sebastian Proksch
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */
package ch.uzh.seal.templates;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

import org.stringtemplate.v4.ST;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.templates.ParameterGeneration.Variables;
import ch.uzh.seal.utils.ResourceReader;

public class TemplateGeneration {

	public static final String ALLOW_FAILURE = "Job-Allow-Failure";
	public static final String JOB_RETRY = "Job-Retry";
	public static final String JOB_CREATION_POLICY = "Job-Creation-Policy";
	public static final String JOB_MANUAL = "Manual-Job";
	public static final String VERSIONING = "Versioning";
	public static final String VULNERABILITY = "Vulnerability";

	private final ParameterGeneration params = new ParameterGeneration();
	private final Map<String, String> templates = new HashMap<>();

	public TemplateGeneration() {
		addTemplate(ALLOW_FAILURE, "issue-templates/allow_failures.md");
		addTemplate(JOB_RETRY, "issue-templates/job_retry.md");
		addTemplate(JOB_MANUAL, "issue-templates/manual_job.md");
		addTemplate(JOB_CREATION_POLICY, "issue-templates/job_creation.md");
		addTemplate(VERSIONING, "issue-templates/missing_version.md");
		addTemplate(VULNERABILITY, "issue-templates/insecure-credentials.md");
	}

	private void addTemplate(String category, String fileTemplate) {
		File f = ResourceReader.getFileFromResources(fileTemplate);
		String template = ResourceReader.readContents(f);
		templates.put(category, template);
	}

	public String[] generateReport(CIAntiPattern cia) {
		ST template = new ST(getTemplate(cia));
		Map<Variables, String> parameters = params.get(cia);

		for (Variables param : parameters.keySet()) {
			String value = parameters.get(param);
			template.add(param.toString(), value);
		}

		String renderedTemplate = template.render();
		String[] titleDesc = splitTitle(cia.getCategory(), renderedTemplate);
		return titleDesc;
	}

	private String getTemplate(CIAntiPattern cia) {
		if (!templates.containsKey(cia.getCategory())) {
			throw new RuntimeException("unknown category: " + cia.getCategory());
		}
		return templates.get(cia.getCategory());
	}

	private static String[] splitTitle(String category, String s) {
		if (s.startsWith("\n")) {
			throw new RuntimeException(String.format("Template '%s' cannot start with a new line!", category));
		}

		int titleEnd = s.indexOf('\n');
		int separatorEnd = s.indexOf('\n', titleEnd + 1);
		String title = s.substring(0, titleEnd);
		String desc = s.substring(separatorEnd + 1);
		return new String[] { title.trim(), desc.trim() };
	}
}