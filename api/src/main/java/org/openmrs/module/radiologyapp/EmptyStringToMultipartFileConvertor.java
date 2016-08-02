package org.openmrs.module.radiologyapp;

import org.springframework.core.convert.converter.Converter;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

/**
 * @author Stanslaus Odhiambo
 * Created on 8/2/2016.
 */
@Component
public class EmptyStringToMultipartFileConvertor implements Converter<String[],MultipartFile>{
    @Override
    public MultipartFile convert(String[] strings) {
        return null;
    }
}
