package org.openmrs.module.radiologyapp.fragment.controller;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang.StringUtils;
import org.openmrs.*;
import org.openmrs.api.PatientService;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.BillingConstants;
import org.openmrs.module.hospitalcore.RadiologyService;
import org.openmrs.module.hospitalcore.form.RadiologyForm;
import org.openmrs.module.hospitalcore.model.RadiologyTest;
import org.openmrs.module.hospitalcore.util.GlobalPropertyUtil;
import org.openmrs.module.hospitalcore.util.RadiologyUtil;
import org.openmrs.obs.ComplexData;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.converter.MultipartFileToInputStreamConverter;
import org.openmrs.util.OpenmrsUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.util.*;

/**
 * @author Stanslaus Odhiambo
 *         Created on 7/13/2016.
 */
public class RadiationResultsFragmentController {
    public static final String ROOT = "upload-dir";
    private static final Logger log = LoggerFactory.getLogger(RadiationResultsFragmentController.class);


    public SimpleObject saveXrayResults(UiUtils uiUtils,
                                        @RequestParam(value = "file", required = false) MultipartFile file,
                                        HttpServletRequest request) {
        InputStream stream = null;
        //process save scan/xray results
        RadiologyService rs = (RadiologyService) Context.getService(RadiologyService.class);
        String testId = request.getParameter("testId");
        String type = "Not Given";
        boolean isXray = Boolean.parseBoolean(request.getParameter("isXray"));
        if (!isXray) {
            type = "Given";
        }
        RadiologyTest test = rs.getRadiologyTestById(Integer.parseInt(testId));
        String encounterTypeStr = GlobalPropertyUtil.getString(BillingConstants.GLOBAL_PROPRETY_RADIOLOGY_ENCOUNTER_TYPE, "RADIOLOGYENCOUNTER");
        EncounterType encounterType = Context.getEncounterService().getEncounterType(encounterTypeStr);
        Encounter enc = new Encounter();
        enc.setCreator(Context.getAuthenticatedUser());
        enc.setDateCreated(new Date());
        Location loc = Context.getLocationService().getLocation(1);
        enc.setLocation(loc);
        enc.setPatient(test.getPatient());
        enc.setPatientId(test.getPatient().getId());
        enc.setEncounterType(encounterType);
        enc.setVoided(false);
        enc.setProvider(Context.getAuthenticatedUser().getPerson());
        enc.setUuid(UUID.randomUUID().toString());
        enc.setEncounterDatetime(new Date());
        enc = Context.getEncounterService().saveEncounter(enc);
        RadiologyForm form = rs.getDefaultForm();
        Integer formId = null;
        if (type.equalsIgnoreCase(RadiologyForm.GIVEN)) {
            test.setEncounter(enc);
            if (form != null)
                formId = form.getId();
        }

        String completeStatus = "fail";
        Map<String, String> parameters = buildParameterList(request);
        if (enc != null) {
            test.setEncounter(enc);
            rs.saveRadiologyTest(test);

            Obs obs;
            for (String key : parameters.keySet()) {
                Concept concept = RadiologyUtil.searchConcept(key);
                obs = insertValue(enc, concept, parameters.get(key), test);
                if (obs.getId() == null)
                    enc.addObs(obs);
            }
            Context.getEncounterService().saveEncounter(enc);
            if (!file.isEmpty()) {
                try {
                    File imgDir = new File(OpenmrsUtil.getApplicationDataDirectory(), "complex_obs");
                    if (!imgDir.exists()) {
                        FileUtils.forceMkdir(imgDir);
                    }
                    MultipartFileToInputStreamConverter converter = new MultipartFileToInputStreamConverter();
                    stream = converter.convert(file);
                    File f = new File(imgDir, file.getOriginalFilename());
                    Files.copy(stream, f.toPath());

                    Concept imageConcept = Context.getConceptService().getConceptByUuid("09d3d8c7-d4e4-443c-8bac-7ef87870ed76");
                    obs = insertValue(enc, imageConcept, f.getName(), test);
                    enc.addObs(obs);
                    Context.getEncounterService().saveEncounter(enc);
                } catch (IOException e) {
                    e.printStackTrace();
                } catch (RuntimeException e) {
                    e.printStackTrace();
                } finally {
                    try {
                        stream.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            } else {
                System.out.println("Failed to upload " + file.getOriginalFilename() + " because it was empty");
                log.info("message", "Failed to upload " + file.getOriginalFilename() + " because it was empty");
            }

            completeStatus = rs.completeTest(test);
            return SimpleObject.create("status", "success", "message", "Xray Results Saved Successfully", "completeStatus", completeStatus);
        }
        return SimpleObject.create("status", "fail", "message", "Error Saving Xray Results", "completeStatus", "Error");
    }


    @SuppressWarnings("rawtypes")
    private Map<String, String> buildParameterList(HttpServletRequest request) {
        Map<String, String> parameters = new HashMap<String, String>();
        for (Enumeration e = request.getParameterNames(); e.hasMoreElements(); ) {
            String parameterName = (String) e.nextElement();
            if (!parameterName.equalsIgnoreCase("id")) {
                if (!parameterName.equalsIgnoreCase("testId")) {
                    if (!parameterName.equalsIgnoreCase("mode")) {
                        if (!parameterName.equalsIgnoreCase("encounterId")) {
                            if (!parameterName.equalsIgnoreCase("successUrl")) {
                                if (!parameterName.equalsIgnoreCase("redirectUrl")) {
                                    if (!parameterName.equalsIgnoreCase("file")) {
                                        if (!parameterName.equalsIgnoreCase("isXray")) {
                                            parameters.put(parameterName,
                                                    request.getParameter(parameterName));
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

        }
        return parameters;
    }


    private Obs insertValue(Encounter encounter, Concept concept, String value, RadiologyTest test) {
        Obs obs = getObs(encounter, concept);
        obs.setConcept(concept);
        obs.setOrder(test.getOrder());
        if (concept.getDatatype().getName().equalsIgnoreCase("Text")) {
            value = value.replace("\n", "\\n");
            obs.setValueText(value);
        } else if (concept.getDatatype().getName().equalsIgnoreCase("Numeric")) {
            obs.setValueNumeric(new Double(value));
        } else if (concept.getDatatype().getName().equalsIgnoreCase("Coded")) {
            Concept answerConcept = RadiologyUtil.searchConcept(value);
            obs.setValueCoded(answerConcept);
        }
        return obs;
    }

    private Obs storeComplexValue(Encounter encounter, ConceptComplex concept, InputStream f, String title, RadiologyTest test) {
        Obs obs = getObs(encounter, concept);
        obs.setConcept(concept);
        ComplexData complexData;
        if (StringUtils.isEmpty(concept.getHandler())) {
            concept.setHandler("ImageHandler");
        }

        try {
            if (f != null) {
                complexData = new ComplexData(title, f);
                obs.setOrder(test.getOrder());
                obs.setComplexData(complexData);
            } else {
                System.out.println("The file name:" + title + "does not exist!");
                f.close();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return obs;
    }

    private Obs getObs(Encounter encounter, Concept concept) {
        for (Obs obs : encounter.getAllObs()) {
            if (obs.getConcept().equals(concept))
                return obs;
        }
        return new Obs();
    }

    public SimpleObject saveXrayImage(HttpServletRequest request, HttpServletResponse response) {
        try {
            processRequest(request);
        } catch (ServletException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

        return SimpleObject.create("status", "Success");
    }

    protected void processRequest(HttpServletRequest request) throws ServletException,
            IOException {
        try {
//            String id = request.getParameter("identifier").equals("null") ? request.getParameter("patientId") : request
//                    .getParameter("identifier");
            String id = "12";
            if (id != null && !id.isEmpty()) {
                int patientId = Integer.parseInt(id);
                boolean isMultipart = ServletFileUpload.isMultipartContent(request);
                if (isMultipart) {
                    File imgDir = new File(OpenmrsUtil.getApplicationDataDirectory(), "patient_images");
                    if (!imgDir.exists()) {
                        FileUtils.forceMkdir(imgDir);
                    }
                    FileItemFactory factory = new DiskFileItemFactory();
                    ServletFileUpload upload = new ServletFileUpload(factory);
                    List<FileItem> items = upload.parseRequest(request);
                    Iterator iter = items.iterator();
                    while (iter.hasNext()) {
                        FileItem item = (FileItem) iter.next();
                        if (item.isFormField()) {
                        } else {

                            PatientService patientService = Context.getPatientService();
                            Patient patient = patientService.getPatient(patientId);
                            if (patient != null) {
                                item.write(new File(imgDir, patient.getPatientIdentifier().getIdentifier() + ".jpg"));
                                PersonAttribute attribute = patient.getAttribute(Context.getPersonService()
                                        .getPersonAttributeTypeByName("Patient Image"));
                                if (attribute == null) {
                                    attribute = new PersonAttribute(Context.getPersonService().getPersonAttributeTypeByName(
                                            "Patient Image"), "");
                                }
                                attribute.setValue(patient.getPatientIdentifier().getIdentifier() + ".jpg");
                                patient.addAttribute(attribute);
                                patientService.savePatient(patient);
                            }
                        }
                    }
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }


}
