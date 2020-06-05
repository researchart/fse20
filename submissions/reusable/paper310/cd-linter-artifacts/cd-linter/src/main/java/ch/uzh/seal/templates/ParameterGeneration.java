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

import java.util.HashMap;
import java.util.Map;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;

public class ParameterGeneration {

	public enum Variables {
		JOB_NAME, STAGE_NAME, SHORT_FILE_NAME, LINK_TO_FILE, LINE_NUMBER, RETRIES_NUMBER, LINE_TEXT, MESSAGE, DEP_NAME
	};

	public Map<Variables, String> get(CIAntiPattern cia) {
		String category = cia.getCategory();

		Map<Variables, String> parameters = new HashMap<>();

		if (category.equalsIgnoreCase(TemplateGeneration.ALLOW_FAILURE)) {
			parameters = setBasicParameters(cia);
		} else if (category.equalsIgnoreCase(TemplateGeneration.JOB_RETRY)) {
			parameters = setParametersForJobRetry(cia);
		} else if (category.equalsIgnoreCase(TemplateGeneration.JOB_MANUAL)) {
			parameters = setBasicParameters(cia);
		} else if (category.equalsIgnoreCase(TemplateGeneration.VERSIONING)) {
			parameters = setParametersForVersioning(cia);
		} else if (category.equalsIgnoreCase(TemplateGeneration.VULNERABILITY)) {
			parameters = setParametersForVulnerability(cia);
		}

		return parameters;
	}

	public static Map<Variables, String> setBasicParameters(CIAntiPattern antipattern) {

		Map<Variables, String> parameters = new HashMap<>();

		String jobName = antipattern.getEntity();
		String stageName = antipattern.getStage();
		String fileName = antipattern.getCfgFileName();
		String remoteCfgLink = antipattern.getRemoteCfgLink();
		String lineNumber = antipattern.getLineNumber();

		parameters.put(Variables.JOB_NAME, jobName);
		parameters.put(Variables.STAGE_NAME, stageName);
		parameters.put(Variables.SHORT_FILE_NAME, fileName);
		parameters.put(Variables.LINK_TO_FILE, remoteCfgLink);
		parameters.put(Variables.LINE_NUMBER, lineNumber);

		return parameters;
	}

	public static Map<Variables, String> setParametersForJobRetry(CIAntiPattern antipattern) {

		Map<Variables, String> parameters = new HashMap<>();

		String jobName = antipattern.getEntity();
		String stageName = antipattern.getStage();
		String fileName = antipattern.getCfgFileName();
		String remoteCfgLink = antipattern.getRemoteCfgLink();
		String lineNumber = antipattern.getLineNumber();
		String retryNum = antipattern.getMessage();

		parameters.put(Variables.JOB_NAME, jobName);
		parameters.put(Variables.STAGE_NAME, stageName);
		parameters.put(Variables.SHORT_FILE_NAME, fileName);
		parameters.put(Variables.LINK_TO_FILE, remoteCfgLink);
		parameters.put(Variables.LINE_NUMBER, lineNumber);
		parameters.put(Variables.RETRIES_NUMBER, retryNum);

		return parameters;
	}

	public static Map<Variables, String> setParametersForVulnerability(CIAntiPattern antipattern) {

		Map<Variables, String> parameters = new HashMap<>();

		String fileName = antipattern.getCfgFileName();
		String remoteCfgLink = antipattern.getRemoteCfgLink();
		String lineNumber = antipattern.getLineNumber();
		String lineText = antipattern.getMessage();

		parameters.put(Variables.SHORT_FILE_NAME, fileName);
		parameters.put(Variables.LINK_TO_FILE, remoteCfgLink);
		parameters.put(Variables.LINE_NUMBER, lineNumber);
		parameters.put(Variables.LINE_TEXT, lineText);

		return parameters;
	}

	public static Map<Variables, String> setParametersForVersioning(CIAntiPattern antipattern) {

		Map<Variables, String> parameters = new HashMap<>();

		String fileName = antipattern.getCfgFileName();
		String remoteCfgLink = antipattern.getRemoteCfgLink();
		String lineNumber = antipattern.getLineNumber();
		String dependency = antipattern.getEntity();
		String message = antipattern.getMessage();
		
		parameters.put(Variables.SHORT_FILE_NAME, fileName);
		parameters.put(Variables.LINK_TO_FILE, remoteCfgLink);
		parameters.put(Variables.LINE_NUMBER, lineNumber);
		parameters.put(Variables.DEP_NAME, dependency);
		parameters.put(Variables.MESSAGE, message);

		return parameters;
	}
}