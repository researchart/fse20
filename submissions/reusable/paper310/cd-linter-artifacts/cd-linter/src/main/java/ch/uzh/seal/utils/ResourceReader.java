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
package ch.uzh.seal.utils;

import static java.lang.String.format;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.nio.charset.Charset;

import org.apache.commons.io.FileUtils;

import ch.uzh.seal.templates.TemplateGeneration;

public class ResourceReader {

	public static File getFileFromResources(String fileName) {

		ClassLoader classLoader = TemplateGeneration.class.getClassLoader();

		URL resource = classLoader.getResource(fileName);
		if (resource == null) {
			throw new IllegalArgumentException(format("file '%s' not found!", fileName));
		}
		return new File(resource.getFile());
	}

	public static String readContents(File template) {
		try {
			return FileUtils.readFileToString(template, Charset.defaultCharset());
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
	}
}