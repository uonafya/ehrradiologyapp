package org.openmrs.module.radiologyapp.page.controller;

import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.openmrs.Concept;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.RadiologyService;
import org.openmrs.module.hospitalcore.model.RadiologyTest;
import org.openmrs.module.hospitalcore.util.RadiologyUtil;
import org.openmrs.module.hospitalcore.util.TestModel;
import org.openmrs.module.radiologyapp.util.RadiologyAppUtil;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.page.FileDownload;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.RequestParam;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * @author Stanslaus Odhiambo
 * Created on 7/20/2016.
 */
public class ReportExportPageController {
    private static Logger logger = LoggerFactory.getLogger(ReportExportPageController.class);

    public FileDownload get(
            @RequestParam(value = "worklistDate", required = false) String worklistDateString,
            @RequestParam(value = "phrase", required = false) String phrase,
            @RequestParam(value = "investigation", required = false) Integer investigationId,
            @RequestParam(value = "includeResults", required = false) String includeResults,
            UiUtils ui) {

//        RadiologyService radiologyService = Context.getService(RadiologyService.class);
//        Concept investigation = Context.getConceptService().getConcept(investigationId);
//        SimpleDateFormat dateFormatter = new SimpleDateFormat("dd/MM/yyyy");
//        Date acceptedDate = null;
//        try {
//            acceptedDate = dateFormatter.parse(acceptedDateString);
//            Map<Concept, Set<Concept>> allowedInvestigations = RadiologyAppUtil.getAllowedInvestigations();
//            Set<Concept> allowableTests = new HashSet<Concept>();
//            if (investigation != null) {
//                allowableTests = allowedInvestigations.get(investigation);
//            } else {
//                for (Concept concept : allowedInvestigations.keySet()) {
//                    allowableTests.addAll(allowedInvestigations.get(concept));
//                }
//            }
//            List<RadiologyTest> radiologyTests = radiologyService.getAcceptedRadiologyTests(acceptedDate, phrase, allowableTests, 1);
//            List<TestModel> tests = RadiologyUtil.generateModelsFromTests(radiologyTests, allowedInvestigations);
//            Collections.sort(tests);
//            return SimpleObject.create("status", "success",
//                    "data",
//                    SimpleObject.fromCollection(tests, ui, "startDate", "patientIdentifier", "patientName", "gender",
//                            "age", "testName", "investigation", "testId", "orderId", "status", "givenFormId", "notGivenFormId", "givenEncounterId", "notGivenEncounterId", "xray"));
//        } catch (ParseException e) {
//            logger.error("An error occured while parsing date '{}'", acceptedDateString, e);
//            return SimpleObject.create("status", "fail");
//        }


        RadiologyService radiologyService = Context.getService(RadiologyService.class);
        Date worklistDate;
        try {
            worklistDate = new SimpleDateFormat("dd/MM/yyyy").parse(worklistDateString);
            Map<Concept, Set<Concept>> allowedInvestigations = RadiologyAppUtil.getAllowedInvestigations();
            Set<Concept> allowableTests = new HashSet<Concept>();
            Concept investigation = Context.getConceptService().getConcept(investigationId);
            if (investigation != null) {
                allowableTests = allowedInvestigations.get(investigation);
            } else {
                for (Concept c : allowedInvestigations.keySet()) {
                    allowableTests.addAll(allowedInvestigations.get(c));
                }
            }
            List<RadiologyTest> radiologyTests = radiologyService.getAllRadiologyTestsByDate(worklistDate,phrase,investigation);


            List<TestModel> formattedRadiologyTests = RadiologyUtil.generateModelsFromTests(radiologyTests, allowedInvestigations);
            String filename = "Radiology Worklist for " + ui.formatDatePretty(worklistDate) + ".xls";
            String contentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
            return new FileDownload(filename, contentType, buildExcelDocument(formattedRadiologyTests));
        } catch (ParseException e) {
            logger.error("Error when parsing order date!", e.getMessage());
        } catch (IOException e) {
            logger.error("Error while generating excel document", e.getMessage());
        }
        return null;
    }

    private byte[] buildExcelDocument(List<TestModel> tests) throws IOException {
        HSSFWorkbook worklistBook = new HSSFWorkbook();
        HSSFSheet worklistSheet = worklistBook.createSheet("Lab worklist");
        setExcelHeader(worklistSheet);
        setExcelRows(worklistSheet, tests);
        ByteArrayOutputStream excelOutput = new ByteArrayOutputStream();

        worklistBook.write(excelOutput);
        return excelOutput.toByteArray();
    }

    private void setExcelHeader(HSSFSheet excelSheet) {
        HSSFRow excelHeader = excelSheet.createRow(0);
        excelHeader.createCell(0).setCellValue("Accepted Date");
        excelHeader.createCell(1).setCellValue("Patient Identifier");
        excelHeader.createCell(2).setCellValue("Name");
        excelHeader.createCell(3).setCellValue("Age");
        excelHeader.createCell(4).setCellValue("Gender");
        excelHeader.createCell(5).setCellValue("Test No.");
        excelHeader.createCell(6).setCellValue("Department");
        excelHeader.createCell(7).setCellValue("Investigation");
        excelHeader.createCell(8).setCellValue("Test Status");
    }

    private void setExcelRows(HSSFSheet excelSheet, List<TestModel> tests){
        int record = 1;
        for (TestModel test : tests) {
            HSSFRow excelRow = excelSheet.createRow(record++);
            excelRow.createCell(0).setCellValue(test.getAcceptedDate());
            excelRow.createCell(1).setCellValue(test.getPatientIdentifier());
            excelRow.createCell(2).setCellValue(test.getPatientName());
            excelRow.createCell(3).setCellValue(test.getAge());
            excelRow.createCell(4).setCellValue(test.getGender());
            excelRow.createCell(5).setCellValue(test.getTestId());
            excelRow.createCell(6).setCellValue(test.getInvestigation());
            excelRow.createCell(7).setCellValue(test.getTestName());
            excelRow.createCell(8).setCellValue(test.getStatus());
        }
    }
}
