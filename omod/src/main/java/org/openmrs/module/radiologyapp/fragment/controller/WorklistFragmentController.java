package org.openmrs.module.radiologyapp.fragment.controller;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.openmrs.Concept;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.RadiologyService;
import org.openmrs.module.hospitalcore.model.RadiologyTest;
import org.openmrs.module.hospitalcore.util.RadiologyUtil;
import org.openmrs.module.hospitalcore.util.TestModel;
import org.openmrs.module.radiologyapp.util.RadiologyAppUtil;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.RequestParam;

public class WorklistFragmentController {

	private Logger logger = LoggerFactory.getLogger(getClass());

	public void controller() {}

	public SimpleObject searchWorkList(
			@RequestParam(value = "orderedDate") String acceptedDateString,
			@RequestParam(value = "investigation") Integer investigationId,
			@RequestParam(value = "phrase", required = false) String phrase,
			UiUtils ui
			) {
		RadiologyService radiologyService = Context.getService(RadiologyService.class);
		Concept investigation = Context.getConceptService().getConcept(investigationId);
		SimpleDateFormat dateFormatter = new SimpleDateFormat("dd/MM/yyyy");
		Date acceptedDate = null;
		try {
			acceptedDate = dateFormatter.parse(acceptedDateString);
			Map<Concept, Set<Concept>> allowedInvestigations = RadiologyAppUtil.getAllowedInvestigations();
			Set<Concept> allowableTests = new HashSet<Concept>();
			if (investigation != null) {
				allowableTests = allowedInvestigations.get(investigation);
			} else {
				for (Concept concept : allowedInvestigations.keySet()) {
					allowableTests.addAll(allowedInvestigations.get(concept));
				}
			}
			List<RadiologyTest> radiologyTests = radiologyService.getAcceptedRadiologyTests(acceptedDate, phrase, allowableTests, 1);			
			List<TestModel> tests = RadiologyUtil.generateModelsFromTests(radiologyTests, allowedInvestigations);
			Collections.sort(tests);
			return SimpleObject.create("status", "success",
					"data",
					SimpleObject.fromCollection(tests, ui, "startDate", "patientIdentifier", "patientName", "gender", "age", "testName", "investigation", "testId", "orderId", "status", "givenFormId", "notGivenFormId", "givenEncounterId", "notGivenEncounterId"));
		} catch (ParseException e) {
			logger.error("An error occured while parsing date '{}'", acceptedDateString, e);
			return SimpleObject.create("status", "fail");
		}
	}

}
