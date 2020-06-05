package ch.uzh.seal.utils;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

public class ProcessedEntitiesWriter {

    private FileOutputStream fos;

    public ProcessedEntitiesWriter(String processedEntitiesPath) {
        this.fos = getFileOutputStream(processedEntitiesPath);
    }

    private FileOutputStream getFileOutputStream(String processedEntitiesPath) {
        try {
            fos = new FileOutputStream(processedEntitiesPath, true);
        }
        catch (
                FileNotFoundException e) {
            System.out.println("Path to processed entities not found: "+ processedEntitiesPath);
            return null;
        }

        return fos;
    }

    public void write(String entityName) {
        try {
            fos.write(entityName.getBytes());
            fos.write("\n".getBytes());
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void close() {
        try {
            fos.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
