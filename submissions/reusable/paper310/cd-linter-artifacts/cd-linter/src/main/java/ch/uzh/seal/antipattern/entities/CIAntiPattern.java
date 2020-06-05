package ch.uzh.seal.antipattern.entities;

public class CIAntiPattern {

	private String id = "";
	private String remoteRepoLink = "";
	private String remoteCfgLink = "";
	private String localCfgLink = "";
	private String project = "";
	private String stage = "";
	private String category = "";
	private String subCategory = "";
	private String entity = "";
	private String message = "";
	private String context = "";
	private String lineNumber = "";
	private String cfgFileName = "";

	public CIAntiPattern(String id, String remoteRepoLink, String remoteCfgLink, String localCfgLink, String project,
			String stage, String category, String subCategory, String entity, String message, String context,
			String lineNumber, String cfgFileName) {
		super();
		this.id = id;
		this.remoteRepoLink = remoteRepoLink;
		this.remoteCfgLink = remoteCfgLink;
		this.localCfgLink = localCfgLink;
		this.project = project;
		this.stage = stage;
		this.category = category;
		this.subCategory = subCategory;
		this.entity = entity;
		this.message = message;
		this.context = context;
		this.lineNumber = lineNumber;
		this.cfgFileName = cfgFileName;
	}

	public CIAntiPattern() {

	}

	public String getId() {
		if (id == null) {
			throw new RuntimeException("wtf");
		}
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getRemoteRepoLink() {
		return remoteRepoLink;
	}

	public void setRemoteRepoLink(String remoteRepoLink) {
		this.remoteRepoLink = remoteRepoLink;
	}

	public String getRemoteCfgLink() {
		return remoteCfgLink;
	}

	public void setRemoteCfgLink(String remoteCfgLink) {
		this.remoteCfgLink = remoteCfgLink;
	}

	public String getLocalCfgLink() {
		return localCfgLink;
	}

	public void setLocalCfgLink(String localCfgLink) {
		this.localCfgLink = localCfgLink;
	}

	public String getProject() {
		return project;
	}

	public void setProject(String project) {
		this.project = project;
	}

	public String getStage() {
		return stage;
	}

	public void setStage(String stage) {
		this.stage = stage;
	}

	public String getCategory() {
		return category;
	}

	public void setCategory(String category) {
		this.category = category;
	}

	public String getSubCategory() {
		return subCategory;
	}

	public void setSubCategory(String subCategory) {
		this.subCategory = subCategory;
	}

	public String getEntity() {
		return entity;
	}

	public void setEntity(String entity) {
		this.entity = entity;
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	public String getContext() {
		return context;
	}

	public void setContext(String context) {
		this.context = context;
	}

	public String getLineNumber() {
		return lineNumber;
	}

	public void setLineNumber(String lineNumber) {
		this.lineNumber = lineNumber;
	}

	public String getCfgFileName() {
		return cfgFileName;
	}

	public void setCfgFileName(String cfgFileName) {
		this.cfgFileName = cfgFileName;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((category == null) ? 0 : category.hashCode());
		result = prime * result + ((cfgFileName == null) ? 0 : cfgFileName.hashCode());
		result = prime * result + ((context == null) ? 0 : context.hashCode());
		result = prime * result + ((entity == null) ? 0 : entity.hashCode());
		result = prime * result + ((id == null) ? 0 : id.hashCode());
		result = prime * result + ((lineNumber == null) ? 0 : lineNumber.hashCode());
		result = prime * result + ((localCfgLink == null) ? 0 : localCfgLink.hashCode());
		result = prime * result + ((message == null) ? 0 : message.hashCode());
		result = prime * result + ((project == null) ? 0 : project.hashCode());
		result = prime * result + ((remoteCfgLink == null) ? 0 : remoteCfgLink.hashCode());
		result = prime * result + ((remoteRepoLink == null) ? 0 : remoteRepoLink.hashCode());
		result = prime * result + ((stage == null) ? 0 : stage.hashCode());
		result = prime * result + ((subCategory == null) ? 0 : subCategory.hashCode());
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
		CIAntiPattern other = (CIAntiPattern) obj;
		if (category == null) {
			if (other.category != null)
				return false;
		} else if (!category.equals(other.category))
			return false;
		if (cfgFileName == null) {
			if (other.cfgFileName != null)
				return false;
		} else if (!cfgFileName.equals(other.cfgFileName))
			return false;
		if (context == null) {
			if (other.context != null)
				return false;
		} else if (!context.equals(other.context))
			return false;
		if (entity == null) {
			if (other.entity != null)
				return false;
		} else if (!entity.equals(other.entity))
			return false;
		if (id == null) {
			if (other.id != null)
				return false;
		} else if (!id.equals(other.id))
			return false;
		if (lineNumber == null) {
			if (other.lineNumber != null)
				return false;
		} else if (!lineNumber.equals(other.lineNumber))
			return false;
		if (localCfgLink == null) {
			if (other.localCfgLink != null)
				return false;
		} else if (!localCfgLink.equals(other.localCfgLink))
			return false;
		if (message == null) {
			if (other.message != null)
				return false;
		} else if (!message.equals(other.message))
			return false;
		if (project == null) {
			if (other.project != null)
				return false;
		} else if (!project.equals(other.project))
			return false;
		if (remoteCfgLink == null) {
			if (other.remoteCfgLink != null)
				return false;
		} else if (!remoteCfgLink.equals(other.remoteCfgLink))
			return false;
		if (remoteRepoLink == null) {
			if (other.remoteRepoLink != null)
				return false;
		} else if (!remoteRepoLink.equals(other.remoteRepoLink))
			return false;
		if (stage == null) {
			if (other.stage != null)
				return false;
		} else if (!stage.equals(other.stage))
			return false;
		if (subCategory == null) {
			if (other.subCategory != null)
				return false;
		} else if (!subCategory.equals(other.subCategory))
			return false;
		return true;
	}

	public String getOwner() {
		String[] parts = getRepo().split("/");
		String owner = parts[0];
		return owner;
	}

	public String getRepo() {
		String repo = remoteRepoLink.substring("https://gitlab.com/".length());
		return repo;
	}
}