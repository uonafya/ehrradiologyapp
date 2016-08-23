package org.openmrs.module.radiologyapp.api;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemHeaders;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
/**
 * @author Stanslaus Odhiambo
 * Created on 8/22/2016.
 */
public class LocalFileItem implements FileItem {

    private static final long serialVersionUID = 2467880290855097332L;

    private final Path localFile;

    public LocalFileItem(Path localFile) {
        this.localFile = localFile;
    }

    @Override
    public void write(File file) throws Exception {
        Files.move(localFile, file.toPath(), StandardCopyOption.REPLACE_EXISTING);
    }

    @Override
    public long getSize() {

        // Spring's CommonsMultipartFile caches the file size and uses it to determine availability.
        long size = -1L;
        try {
            size = Files.size(localFile);
        } catch (IOException ignored) {}
        return size;
    }

    @Override
    public void delete() {
        localFile.toFile().delete();
    }

    /* *** properties and unsupported methods *** */

    private FileItemHeaders headers;
    private String contentType;
    private String fieldName;
    private boolean formField;

    @Override
    public FileItemHeaders getHeaders() {
        return headers;
    }

    @Override
    public void setHeaders(FileItemHeaders headers) {
        this.headers = headers;
    }

    @Override
    public InputStream getInputStream() throws IOException {
        throw new IOException("Only method write(File) is supported.");
    }

    public void setContentType(String contentType) {
        this.contentType = contentType;
    }

    @Override
    public String getContentType() {
        return contentType;
    }

    @Override
    public String getName() {
        return localFile.getFileName().toString();
    }

    @Override
    public boolean isInMemory() {
        return false;
    }

    @Override
    public byte[] get() {
        throw new RuntimeException("Only method write(File) is supported.");
    }

    @Override
    public String getString(String encoding)
            throws UnsupportedEncodingException {
        throw new RuntimeException("Only method write(File) is supported.");
    }

    @Override
    public String getString() {
        throw new RuntimeException("Only method write(File) is supported.");
    }

    @Override
    public String getFieldName() {
        return fieldName;
    }

    @Override
    public void setFieldName(String name) {
        this.fieldName = name;
    }

    @Override
    public boolean isFormField() {
        return formField;
    }

    @Override
    public void setFormField(boolean state) {
        this.formField = state;
    }

    @Override
    public OutputStream getOutputStream() throws IOException {
        throw new IOException("Only method write(File) is supported.");
    }

}