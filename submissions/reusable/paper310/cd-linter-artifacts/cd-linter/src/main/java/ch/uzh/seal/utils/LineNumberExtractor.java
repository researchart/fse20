package ch.uzh.seal.utils;

public class LineNumberExtractor {

    private static final String COMMENT_KEYWORD = "#";
	private String[] lines;

    public LineNumberExtractor(String fileContent) {
        this.lines = fileContent.split("\\r?\\n", -1);
    }

    public String getLineNumber(String search) {
        int counter = 1;

        for (String line : lines) {
        	
        	if(line.contains("run " + search)) {
        		counter++;
        		continue;
        	}
        	
        	line = line.replaceAll("\"", "");
            if (line.contains(search) && !line.contains("_" +search+ "_") && !line.trim().startsWith(COMMENT_KEYWORD)) {
                return Integer.toString(counter);
            }

            counter++;
        }

        return "-1";
    }
}
