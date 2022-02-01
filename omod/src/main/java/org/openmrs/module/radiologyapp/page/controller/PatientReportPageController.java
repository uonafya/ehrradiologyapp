package org.openmrs.module.radiologyapp.page.controller;

import org.apache.commons.io.IOUtils;
import org.apache.commons.lang.StringUtils;
import org.openmrs.Encounter;
import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.PersonAttributeType;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.hospitalcore.HospitalCoreService;
import org.openmrs.module.hospitalcore.RadiologyService;
import org.openmrs.module.hospitalcore.model.RadiologyTest;
import org.openmrs.module.kenyaui.annotation.AppPage;
import org.openmrs.module.metadatadeploy.MetadataUtils;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.page.PageModel;
import org.openmrs.ui.framework.page.PageRequest;
import org.openmrs.util.OpenmrsUtil;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.stream.ImageInputStream;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.util.Iterator;
import java.util.Set;


/**
 * @author Stanslaus Odhiambo
 *         Created on 7/20/2016.
 */
@AppPage("radiologyapp.main")
public class PatientReportPageController {
    public static final String ROOT = "complex_obs";

    public String get(
            UiSessionContext sessionContext, @RequestParam(value = "testId") Integer testId,
            PageModel model, @RequestParam(value = "encounterId") Integer encounterId,
            UiUtils ui,
            PageRequest pageRequest) {
        /*pageRequest.getSession().setAttribute(ReferenceApplicationWebConstants.SESSION_ATTRIBUTE_REDIRECT_URL, ui.thisUrl());
        sessionContext.requireAuthentication();*/
        /*Boolean isPriviledged = Context.hasPrivilege("Access Laboratory");
        if (!isPriviledged) {
            return "redirect: index.htm";
        }*/
        PersonAttributeType personAttributeType14 = MetadataUtils.existing(PersonAttributeType.class, "09cd268a-f0f5-11ea-99a8-b3467ddbf779");
        PersonAttributeType personAttributeType43 = MetadataUtils.existing(PersonAttributeType.class, "858781dc-282f-11eb-8741-8ff5ddd45b7c");
        RadiologyService rs = Context.getService(RadiologyService.class);
        RadiologyTest radiologyTest = rs.getRadiologyTestById(testId);
        Patient patient = radiologyTest.getPatient();
        HospitalCoreService hcs = Context.getService(HospitalCoreService.class);

        model.addAttribute("patient", patient);
        model.addAttribute("radiologyTest", radiologyTest.getConcept().getName().getName());
        model.addAttribute("patientIdentifier", patient.getPatientIdentifier());
        model.addAttribute("age", patient.getAge());
        model.addAttribute("gender", patient.getGender());
        model.addAttribute("name", patient.getNames());
        model.addAttribute("category", patient.getAttribute(personAttributeType14));
        model.addAttribute("previousVisit", hcs.getLastVisitTime(patient));
        model.addAttribute("_100126232", "");
        if (patient.getAttribute(personAttributeType43) == null) {
            model.addAttribute("fileNumber", "");
        } else if (StringUtils.isNotBlank(patient.getAttribute(personAttributeType43).getValue())) {
            model.addAttribute("fileNumber", "(File: " + patient.getAttribute(personAttributeType43) + ")");
        } else {
            model.addAttribute("fileNumber", "");
        }

        Encounter encounter = Context.getEncounterService().getEncounter(encounterId);
        Set<Obs> allObs = encounter.getAllObs();

        for (Obs obs : allObs) {
            model.addAttribute("_" + obs.getConcept().getConceptId(),
                    obs.getValueText() == null ? obs.getValueCoded().getName().getName() : obs.getValueText());
            if (obs.getConcept().getConceptId() == 1000169) {
                MultipartFile toLoad = null;
//               load the image file
                File imgDir = new File(OpenmrsUtil.getApplicationDataDirectory(), ROOT);
                File imgFile = new File(imgDir, obs.getValueText());
                model.addAttribute("fileName",imgFile.getName());
                Image img = null;
                BufferedImage image = null;
                try {
                    ImageIO.scanForPlugins();
                    Iterator<ImageReader> iter = ImageIO.getImageReadersByFormatName("DICOM");
                    BufferedImage imagetry = ImageIO.read(imgFile);
                    image = getPixelDataAsBufferedImage(IOUtils.toByteArray(new FileInputStream(imgFile)));
                    byte[] content = Files.readAllBytes(imgFile.toPath());
                    String contentType = "application/dicom";
                    toLoad = new MockMultipartFile(imgFile.getName(), imgFile.getName(), contentType, content);
                } catch (IOException e) {
                    System.out.println("\nError: couldn't read dicom image!" + e.getMessage());
                } catch (Exception e) {
                    e.printStackTrace();
                }
                model.addAttribute("imgFileRaw", toLoad);
            }
            else {
                model.addAttribute("imgFileRaw", "");
            }
        }
        return null;
    }


    public static BufferedImage getPixelDataAsBufferedImage(byte[] dicomData)
            throws IOException {
        ImageIO.scanForPlugins();
        ByteArrayInputStream bais = new ByteArrayInputStream(dicomData);
        BufferedImage buff = null;
        Iterator<ImageReader> iter = ImageIO.getImageReadersByFormatName("DICOM");
        ImageReader reader = iter.next();
//        DicomImageReadParam param = (DicomImageReadParam) reader.getDefaultReadParam();
        ImageInputStream iis = null;
//        TODO check plugin for specific dicom processor header
        iis = ImageIO.createImageInputStream(bais);
        reader.setInput(iis, false);
//        buff = reader.read(0, param);
        iis.close();
        if (buff == null) {
            throw new IOException("Could not read Dicom file. Maybe pixel data is invalid.");
        }
        return buff;
    }
}
