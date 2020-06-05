package ch.uzh.seal.detectors.maven.pom;

import ch.uzh.seal.detectors.maven.versioning.entities.Dependency;
import ch.uzh.seal.detectors.maven.versioning.entities.VersionSpecifier;
import ch.uzh.seal.detectors.maven.versioning.parsers.VersionSpecifierParser;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathFactory;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


public class POMParser {

    private POM pom;
    private Document doc;
    private XPath xpath;

    /**
     * Parse the content of a pom.xml file.
     * @param content The content of a pom.xml file.
     * @return The POM instance.
     */
    public POM parse(String content) throws Exception {
        pom = new POM();
        pom.setRaw(content);

        if (!content.equals("")) {
            doc = getDocument(content);
            XPathFactory xPathfactory = XPathFactory.newInstance();
            xpath = xPathfactory.newXPath();
            addProjectAttributes();
            addParentPOM();
            addProperties();
            addModules();
            addDependencies();
        }

        return pom;
    }

    private Document getDocument(String content) throws Exception{
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        DocumentBuilder builder = factory.newDocumentBuilder();
        InputSource inputSource = new InputSource(new StringReader(content));
        return builder.parse(inputSource);
    }

    private String replaceProperties(String string) throws Exception {
        String patternString = "(.*?)\\$\\{(.+?)}([^$]*)";
        Pattern pattern = Pattern.compile(patternString);
        Matcher matcher = pattern.matcher(string);

        String replaced = "";

        while(matcher.find()) {
            String prefix = matcher.group(1);
            String propertyName = matcher.group(2);
            String propertyValue = getProperty(propertyName);
            String suffix = matcher.group(3);
            replaced = replaced + prefix + propertyValue + suffix;
        }

        if (!replaced.equals("")) {
            return replaced;
        }

        return string;
    }

    private String getProperty(String name) throws Exception {
        String value;

        // A dot (.) notated path in the POM
        String path1 = "/" + name.replace('.', '/');
        String path1Value = getValue(path1);

        // Set within a <properties /> element in the POM
        String path2 = "/project/properties/" + name;
        String path2Value = getValue(path2);

        if (!path1Value.equals("")) {
            value = path1Value;
        }
        else {
            value = path2Value;
        }

        return value;
    }

    private void addProjectAttributes() throws Exception {
        String groupId = getValue("/project/groupId");
        pom.setGroupId(groupId);
        String artifactId = getValue("/project/artifactId");
        pom.setArtifactId(artifactId);
        String version = getValue("/project/version");
        pom.setVersion(version);
    }

    private void addParentPOM() throws Exception {
        POM parentPOM = new POM();
        String groupId = getValue("/project/parent/groupId");
        parentPOM.setGroupId(groupId);
        String artifactId = getValue("/project/parent/artifactId");
        parentPOM.setArtifactId(artifactId);
        String version = getValue("/project/parent/version");
        parentPOM.setVersion(version);
        pom.setParent(parentPOM);
    }

    private void addModules() throws Exception {
        for (Node node : getNodes("/project/modules/module")) {
            String value = node.getTextContent();
            pom.addModule(value);
        }
    }

    private void addProperties() throws Exception{
        for (Node node : getNodes("/project/properties/*")) {
            String name = node.getNodeName();
            String value = node.getTextContent();
            pom.addProperty(name, value);
        }
    }

    private void addDependencies() throws Exception{
        for (Node node : getNodes(
                "/project/dependencies/dependency|/project/dependencyManagement/dependencies/dependency")) {
            NodeList childNodes = node.getChildNodes();

            String groupID = "";
            String artificatID = "";
            String version = "";

            for (int i=0; i < childNodes.getLength(); i++) {
                Node childNode = childNodes.item(i);
                if (Node.ELEMENT_NODE == childNode.getNodeType()) {

                    String tag = childNode.getNodeName();

                    if (tag.equals("groupId")) {
                        groupID = childNode.getTextContent().strip();
                        groupID = replaceProperties(groupID);
                    } else if (tag.equals("artifactId")) {
                        artificatID = childNode.getTextContent().strip();
                    } else if (tag.equals("version")) {
                        version = childNode.getTextContent().strip();
                        version = replaceProperties(version);
                    }
                }
            }

            String name = groupID + '/' + artificatID;

            VersionSpecifier versionSpecifier = new VersionSpecifierParser().parse(version);

            Dependency dependency = new Dependency(name, versionSpecifier);
            dependency.setGroupID(groupID);
            dependency.setArtifactID(artificatID);

            pom.addDependency(dependency);
        }
    }

    private ArrayList<Node> getNodes(String name) throws Exception {
        XPathExpression expr = xpath.compile(name);
        NodeList nodes = (NodeList) expr.evaluate(doc, XPathConstants.NODESET);
        ArrayList<Node> result = new ArrayList<>();

        for (int i=0; i < nodes.getLength(); i++) {
            Node childNode = nodes.item(i);
            if (Node.ELEMENT_NODE == childNode.getNodeType()) {
                result.add(childNode);
            }
        }

        return result;
    }

    private String getValue(String name) throws Exception {
        XPathExpression expr = xpath.compile(name);
        return expr.evaluate(doc);
    }
}
