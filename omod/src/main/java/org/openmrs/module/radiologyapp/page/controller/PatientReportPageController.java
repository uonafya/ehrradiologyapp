package org.openmrs.module.radiologyapp.page.controller;

import org.apache.commons.lang.StringUtils;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.hospitalcore.HospitalCoreService;
import org.openmrs.module.hospitalcore.RadiologyService;
import org.openmrs.module.hospitalcore.model.RadiologyTest;
import org.openmrs.module.referenceapplication.ReferenceApplicationWebConstants;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.page.PageModel;
import org.openmrs.ui.framework.page.PageRequest;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * @author Stanslaus Odhiambo
 *         Created on 7/20/2016.
 */
public class PatientReportPageController {

    public String get(
            UiSessionContext sessionContext, @RequestParam(value = "testId") Integer testId,
            PageModel model,
            UiUtils ui,
            PageRequest pageRequest) {
        pageRequest.getSession().setAttribute(ReferenceApplicationWebConstants.SESSION_ATTRIBUTE_REDIRECT_URL, ui.thisUrl());
        sessionContext.requireAuthentication();
        Boolean isPriviledged = Context.hasPrivilege("Access Laboratory");
        if (!isPriviledged) {
            return "redirect: index.htm";
        }
        RadiologyService rs = Context.getService(RadiologyService.class);
        RadiologyTest radiologyTest = rs.getRadiologyTestById(testId);
        Patient patient = radiologyTest.getPatient();
        HospitalCoreService hcs = Context.getService(HospitalCoreService.class);

        model.addAttribute("patient", patient);
        model.addAttribute("patientIdentifier", patient.getPatientIdentifier());
        model.addAttribute("age", patient.getAge());
        model.addAttribute("gender", patient.getGender());
        model.addAttribute("name", patient.getNames());
        model.addAttribute("category", patient.getAttribute(14));
        model.addAttribute("previousVisit", hcs.getLastVisitTime(patient));

        if (patient.getAttribute(43) == null) {
            model.addAttribute("fileNumber", "");
        } else if (StringUtils.isNotBlank(patient.getAttribute(43).getValue())) {
            model.addAttribute("fileNumber", "(File: " + patient.getAttribute(43) + ")");
        } else {
            model.addAttribute("fileNumber", "");
        }



//        if (patient != null) {
//            RadiologyTest radiologyTest = rs.getRadiologyTestById(testId);
//            if (radiologyTest != null) {
//                Map<Concept, Set<Concept>> allowedInvestigations = RadiologyAppUtil.getAllowedInvestigations();
//                List<TestModel> trms = renderTests(labTest, testTreeMap);
//                trms = formatTestResult(trms);
//
//                List<SimpleObject> results = SimpleObject.fromCollection(trms, ui,
//                        "investigation", "set", "test", "value", "hiNormal",
//                        "lowNormal", "lowAbsolute", "hiAbsolute", "hiCritical", "lowCritical",
//                        "unit", "level", "concept", "encounterId", "testId");
//                SimpleObject currentResults = SimpleObject.create("data", results);
//                model.addAttribute("currentResults", currentResults);
//                model.addAttribute("test", ui.formatDatePretty(labTest.getOrder().getStartDate()));
//            }
//        }
        return null;
    }

}
