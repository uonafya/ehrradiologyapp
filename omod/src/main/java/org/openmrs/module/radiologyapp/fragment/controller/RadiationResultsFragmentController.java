package org.openmrs.module.radiologyapp.fragment.controller;

import org.openmrs.*;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.BillingConstants;
import org.openmrs.module.hospitalcore.RadiologyService;
import org.openmrs.module.hospitalcore.form.RadiologyForm;
import org.openmrs.module.hospitalcore.model.RadiologyTest;
import org.openmrs.module.hospitalcore.util.GlobalPropertyUtil;
import org.openmrs.module.hospitalcore.util.RadiologyUtil;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import java.util.*;

/**
 * @author Stanslaus Odhiambo
 *         Created on 7/13/2016.
 */
public class RadiationResultsFragmentController {

    public SimpleObject saveXrayResults(UiUtils uiUtils, @RequestParam(value = "testId") String testId, HttpServletRequest request) {
        //process save scan results
        RadiologyService rs = (RadiologyService) Context
                .getService(RadiologyService.class);
        RadiologyTest test = rs.getRadiologyTestById(Integer.parseInt(testId));
        String encounterTypeStr = GlobalPropertyUtil.getString(
                BillingConstants.GLOBAL_PROPRETY_RADIOLOGY_ENCOUNTER_TYPE,
                "RADIOLOGYENCOUNTER");
        EncounterType encounterType = Context.getEncounterService()
                .getEncounterType(encounterTypeStr);
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

        String completeStatus = "fail";
        Map<String, String> parameters = buildParameterList(request);
        if (enc != null) {
            test.setEncounter(enc);
            rs.saveRadiologyTest(test);
            RadiologyForm form = rs.getDefaultForm();
            for (String key : parameters.keySet()) {
                Concept concept = RadiologyUtil.searchConcept(key);
                Obs obs = insertValue(enc, concept, parameters.get(key), test);
                if (obs.getId() == null)
                    enc.addObs(obs);
            }
            Context.getEncounterService().saveEncounter(enc);
            completeStatus = rs.completeTest(test);
            return SimpleObject.create("status", "success", "message", "Saved Successfully", "completeStatus", completeStatus);
        }
        return SimpleObject.create("status", "fail", "message", "Error Saving Results", "completeStatus", completeStatus);
    }


    @SuppressWarnings("rawtypes")
    private Map<String, String> buildParameterList(HttpServletRequest request) {
        Map<String, String> parameters = new HashMap<String, String>();
        for (Enumeration e = request.getParameterNames(); e.hasMoreElements(); ) {
            String parameterName = (String) e.nextElement();
            if (!parameterName.equalsIgnoreCase("id"))
                if (!parameterName.equalsIgnoreCase("testId"))
                    if (!parameterName.equalsIgnoreCase("mode"))
                        if (!parameterName.equalsIgnoreCase("encounterId"))
                            if (!parameterName.equalsIgnoreCase("successUrl"))
                                if (!parameterName.equalsIgnoreCase("redirectUrl"))
                                    parameters.put(parameterName,
                                            request.getParameter(parameterName));

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

    private Obs getObs(Encounter encounter, Concept concept) {
        for (Obs obs : encounter.getAllObs()) {
            if (obs.getConcept().equals(concept))
                return obs;
        }
        return new Obs();
    }

}
