package ch.uzh.seal.utils;

public class LineNumberPathConstructor {

    public static String getPath(String path, String lineNumber) {
        return path + "#L" + lineNumber;
    }
}
