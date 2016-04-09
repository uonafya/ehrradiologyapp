package org.openmrs.module.radiologyapp.fragment.controller;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.openmrs.Concept;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.RadiologyService;
import org.openmrs.module.hospitalcore.concept.TestTree;
import org.openmrs.module.hospitalcore.model.RadiologyDepartment;
import org.openmrs.module.hospitalcore.model.RadiologyTest;
import org.openmrs.module.hospitalcore.util.RadiologyUtil;
import org.openmrs.module.hospitalcore.util.TestModel;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.RequestParam;

public class WorklistFragmentController {

	private Logger logger = LoggerFactory.getLogger(getClass());

	public SimpleObject searchWorkList(
			@RequestParam(value = "date") String acceptedDateString,
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
			Map<Concept, Set<Concept>> allowedInvestigations = getAllowedInvestigations();
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
					SimpleObject.fromCollection(tests, ui, "startDate", "patientIdentifier", "patientName", "gender", "age", "test.name", "investigation", "testId", "orderId", "sampleId", "status", "value"));
		} catch (ParseException e) {
			logger.error("An error occured while parsing date '{}'", acceptedDateString, e);
			return SimpleObject.create("status", "error");
		}
	}
	
	private Map<Concept, Set<Concept>> getAllowedInvestigations() {
		RadiologyService rs = (RadiologyService) Context
				.getService(RadiologyService.class);
		RadiologyDepartment department = rs.getCurrentRadiologyDepartment();
		Map<Concept, Set<Concept>> investigationTests = new HashMap<Concept, Set<Concept>>();
		if (department != null) {
			Set<Concept> investigations = department.getInvestigations();
			for (Concept investigation : investigations) {
				TestTree tree = new TestTree(investigation);
				if (tree.getRootNode() != null) {
					investigationTests.put(tree.getRootNode().getConcept(),
							tree.getConceptSet());
				}
			}			
		}
		return investigationTests;
	}

}
