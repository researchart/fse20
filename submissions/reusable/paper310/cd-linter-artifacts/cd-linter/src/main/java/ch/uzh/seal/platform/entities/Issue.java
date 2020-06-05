package ch.uzh.seal.platform.entities;

import java.net.URL;
import java.util.LinkedList;
import java.util.List;

public class Issue {
	public String id;
	public String title;
	public String desc;
	public String category;
	public List<String> tags = new LinkedList<String>();
	public URL linkToRepository;
}