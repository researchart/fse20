package ch.uzh.seal.app;

import static ch.uzh.seal.platform.parsers.AntiPattern2IssueConverter.convert;
import static org.apache.commons.codec.Charsets.UTF_8;
import static org.glassfish.jersey.client.authentication.HttpAuthenticationFeature.basic;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.Entity;
import javax.ws.rs.client.WebTarget;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import org.apache.commons.io.FileUtils;
import org.glassfish.jersey.client.authentication.HttpAuthenticationFeature;

import ch.uzh.seal.antipattern.entities.CIAntiPattern;
import ch.uzh.seal.antipattern.readers.CIAntiPatternCSVReader;
import ch.uzh.seal.platform.entities.Issue;
import ch.uzh.seal.utils.ProcessedEntitiesReader;
import ch.uzh.seal.utils.ProcessedEntitiesWriter;
import ch.uzh.seal.utils.ResourceReader;
import me.tongfei.progressbar.ProgressBar;

public class VampirePusher {

	// public static final String VAMPIRE_URL =
	// "http://build.kave.cc/vampire/api/issues";
	public static final String URL_VAMPIRE = "http://localhost:8080/api/review/";
	public static final String PATH_CREDENTIALS = "vampire-credentials"; // put it into src/main/resources
	public static final String PATH_ANTI_PATTERN_CSV = "target/cd-smell-report.csv";
	public static final String PATH_PUSHED_ISSUES = "target/pushedIssues.txt";

	private final WebTarget webTarget = getWebTarget(URL_VAMPIRE);

	public static void main(String[] args) throws IOException {

		File pushedIssues = new File(PATH_PUSHED_ISSUES);
		if (!pushedIssues.exists()) {
			pushedIssues.createNewFile();
		}
		System.out.printf("Pushing issues to: %s\n", URL_VAMPIRE);
		new VampirePusher().push();
	}

	public static WebTarget getWebTarget(String url) {
		String[] credentials = getCredentials();
		HttpAuthenticationFeature auth = basic(credentials[0], credentials[1]);
		Client client = ClientBuilder.newClient();
		client.register(auth);
		WebTarget webTarget = client.target(url);
		return webTarget;
	}

	public static String[] getCredentials() {
		try {
			File f = ResourceReader.getFileFromResources(PATH_CREDENTIALS);
			List<String> lines = FileUtils.readLines(f, UTF_8);
			return new String[] { lines.get(0).trim(), lines.get(1).trim() };
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
	}

	private void push() {
		List<Issue> issues = getIssues();

		Set<String> pushedIssues = ProcessedEntitiesReader.getProcessedEntities(PATH_PUSHED_ISSUES);
		ProcessedEntitiesWriter pushedIssuesWriter = new ProcessedEntitiesWriter(PATH_PUSHED_ISSUES);

		ProgressBar pb = new ProgressBar("Pushing issues", issues.size());
		pb.start();

		for (Issue issue : issues) {

			String id = issue.id;

			if (!pushedIssues.contains(id)) {
				int status = postIssue(issue);

				if (status == 200) {
					pushedIssuesWriter.write(id);
				} else {
					System.err.println("\n`" + id + "` could not be pushed");
				}
			}

			pb.step();
		}

		pb.stop();
	}

	private int postIssue(Issue i) {
		Entity<Issue> e = Entity.entity(i, MediaType.APPLICATION_JSON);
		Response r = webTarget.request(MediaType.APPLICATION_JSON).accept(MediaType.APPLICATION_JSON).post(e);
		return r.getStatus();
	}

	private List<Issue> getIssues() {
		Set<CIAntiPattern> cias = new CIAntiPatternCSVReader(PATH_ANTI_PATTERN_CSV).read();
		List<Issue> issues = cias.stream().map(cia -> convert(cia)).collect(Collectors.toList());
		return issues;
	}
}