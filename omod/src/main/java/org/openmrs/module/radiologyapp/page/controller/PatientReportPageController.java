package org.openmrs.module.radiologyapp.page.controller;

import org.apache.commons.lang.StringUtils;
import org.openmrs.Encounter;
import org.openmrs.Obs;
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

import java.util.Set;

/**
 * @author Stanslaus Odhiambo
 *         Created on 7/20/2016.
 */
public class PatientReportPageController {

    public String get(
            UiSessionContext sessionContext, @RequestParam(value = "testId") Integer testId,
            PageModel model, @RequestParam(value = "encounterId") Integer encounterId,
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
        model.addAttribute("radiologyTest", radiologyTest.getConcept().getName().getName());
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

        Encounter encounter = Context.getEncounterService().getEncounter(encounterId);
        Set<Obs> allObs = encounter.getAllObs();

        for (Obs obs : allObs) {
            model.addAttribute("_"+obs.getConcept().getConceptId(),
                    obs.getValueText() == null ? obs.getValueCoded().getName().getName() : obs.getValueText());
            System.out.printf("%s:%s",obs.getConcept().getConceptId().toString(),
                    obs.getValueText() == null ? obs.getValueCoded().getName().getName() : obs.getValueText());
        }


        return null;
    }

}
