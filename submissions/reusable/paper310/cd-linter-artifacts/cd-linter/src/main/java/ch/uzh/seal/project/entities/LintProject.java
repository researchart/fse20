package ch.uzh.seal.project.entities;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;

import ch.uzh.seal.utils.HTTPConnector;

public class LintProject {

	private String accessToken = "";

	private String name = "";

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	private String remotePath = "";

	public String getRemotePath() {
		return remotePath;
	}

	public void setRemotePath(String remotePath) {
		this.remotePath = remotePath;
	}

	private String localPath = "";

	public String getLocalPath() {
		return localPath;
	}

	public void setLocalPath(String localPath) {
		this.localPath = localPath;
	}

	private String language;

	public void setLanguage(String language) {
		this.language = language;
	}

	public String getLanguage() {
		return language;
	}

	public String getFullPath(String path) {
		if (isLocal())
			return getFullLocalPath(path);
		else
			return getFullRemotePath(path, false);
	}

	public String getFullRemotePath(String path, Boolean blob) {
		if (blob) {
			return remotePath + "/blob/master/" + path;
		} else {
			return remotePath + "/raw/master/" + path;
		}
	}

	public String getFullLocalPath(String path) {
		return localPath + "/" + path;
	}

	public void setAccessToken(String accessToken) {
		this.accessToken = accessToken;
	}

	public Boolean isLocal() {
		return !localPath.equals("");
	}

	public String getFileContent(String path) {
		if (isLocal())
			return getLocalFile(path);
		else
			return getRemoteFile(path);
	}

	public String getLocalFile(String filePath) {
		Path path = Paths.get(getFullPath(filePath));
		byte[] encoded;

		try {
			encoded = Files.readAllBytes(path);
		} catch (IOException e) {
			return "";
		}

		return new String(encoded, StandardCharsets.UTF_8);
	}

	public String getRemoteFile(String path) {
		String mimeType = "text/plain";
		String url = getFullPath(path);
		Map<String, String> requests_header = new HashMap<>();
		requests_header.put("Content-Type", mimeType + "; charset=utf-8");
		requests_header.put("Private-Token", accessToken);
		String[] responseResults = HTTPConnector.connectAndGetResponse(url, requests_header);
		int responseCode = Integer.parseInt(responseResults[0]);

		if (responseCode == HTTPConnector.STATUS_OK) {
			return responseResults[1];
		} else {
			return "";
		}
	}
	
	public String getRemoteFileOnly(String path) {
		String mimeType = "text/plain";
		String url = "https://gitlab.com/" + repository + "/raw/master"+ path;
		System.out.println(url);
		Map<String, String> requests_header = new HashMap<>();
		requests_header.put("Content-Type", mimeType + "; charset=utf-8");
		requests_header.put("Private-Token", accessToken);
		String[] responseResults = HTTPConnector.connectAndGetResponse(url, requests_header);
		int responseCode = Integer.parseInt(responseResults[0]);

		if (responseCode == HTTPConnector.STATUS_OK) {
			return responseResults[1];
		} else {
			return "";
		}
	}

	public String getBuildToolName() {
		HashMap<String, String> knownBuildTools = new HashMap<>();
		knownBuildTools.put("Maven", "pom.xml");
		knownBuildTools.put("Gradle", "build.gradle");

		for (String name : knownBuildTools.keySet()) {
			String fileName = knownBuildTools.get(name);
			String content = getFileContent(fileName);

			if (!content.equals("")) {
				return name;
			}
		}

		return "unknown";
	}

	public int getNumCommitsInLastThreeMonths() {
		return numCommitsInLastThreeMonths;
	}

	public void setNumCommitsInLastThreeMonths(int numCommitsInLastThreeMonths) {
		this.numCommitsInLastThreeMonths = numCommitsInLastThreeMonths;
	}

	public int getNumIssuesOpenedInLastThreeMonths() {
		return numIssuesOpenedInLastThreeMonths;
	}

	public void setNumIssuesOpenedInLastThreeMonths(int numIssuesOpenedInLastThreeMonths) {
		this.numIssuesOpenedInLastThreeMonths = numIssuesOpenedInLastThreeMonths;
	}

	public String getOwner() {
		return owner;
	}

	public void setOwner(String owner) {
		this.owner = owner;
	}

	public String getRepository() {
		return repository;
	}

	public void setRepository(String repository) {
		this.repository = repository;
	}
	
	

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((accessToken == null) ? 0 : accessToken.hashCode());
		result = prime * result + ((language == null) ? 0 : language.hashCode());
		result = prime * result + ((localPath == null) ? 0 : localPath.hashCode());
		result = prime * result + ((name == null) ? 0 : name.hashCode());
		result = prime * result + numCommitsInLastThreeMonths;
		result = prime * result + numIssuesOpenedInLastThreeMonths;
		result = prime * result + ((owner == null) ? 0 : owner.hashCode());
		result = prime * result + ((remotePath == null) ? 0 : remotePath.hashCode());
		result = prime * result + ((repository == null) ? 0 : repository.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		LintProject other = (LintProject) obj;
		if (accessToken == null) {
			if (other.accessToken != null)
				return false;
		} else if (!accessToken.equals(other.accessToken))
			return false;
		if (language == null) {
			if (other.language != null)
				return false;
		} else if (!language.equals(other.language))
			return false;
		if (localPath == null) {
			if (other.localPath != null)
				return false;
		} else if (!localPath.equals(other.localPath))
			return false;
		if (name == null) {
			if (other.name != null)
				return false;
		} else if (!name.equals(other.name))
			return false;
		if (numCommitsInLastThreeMonths != other.numCommitsInLastThreeMonths)
			return false;
		if (numIssuesOpenedInLastThreeMonths != other.numIssuesOpenedInLastThreeMonths)
			return false;
		if (owner == null) {
			if (other.owner != null)
				return false;
		} else if (!owner.equals(other.owner))
			return false;
		if (remotePath == null) {
			if (other.remotePath != null)
				return false;
		} else if (!remotePath.equals(other.remotePath))
			return false;
		if (repository == null) {
			if (other.repository != null)
				return false;
		} else if (!repository.equals(other.repository))
			return false;
		return true;
	}

	private int numCommitsInLastThreeMonths, numIssuesOpenedInLastThreeMonths;
	private String owner, repository;
}