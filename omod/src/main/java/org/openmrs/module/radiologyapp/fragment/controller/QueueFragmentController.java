package org.openmrs.module.radiologyapp.fragment.controller;


import org.openmrs.Concept;
import org.openmrs.Order;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.RadiologyService;
import org.openmrs.module.hospitalcore.concept.TestTree;
import org.openmrs.module.hospitalcore.model.RadiologyDepartment;
import org.openmrs.module.hospitalcore.util.RadiologyUtil;
import org.openmrs.module.hospitalcore.util.TestModel;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.RequestParam;


import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * Created by USER on 2/3/2016.
 */
public class QueueFragmentController {
    private static Logger logger = LoggerFactory.getLogger(QueueFragmentController.class);
    public void controller(FragmentModel model) {
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        String dateStr = sdf.format(new Date());
        model.addAttribute("currentDate", dateStr);

        RadiologyService ls = (RadiologyService) Context.getService(RadiologyService.class);
        RadiologyDepartment department = ls.getCurrentRadiologyDepartment();
        if(department!=null){
            Set<Concept> investigations = department.getInvestigations();
            model.addAttribute("investigations", investigations);
        }
    }
    private Map<Concept, Set<Concept>> getAllowableTests() {
        RadiologyService ls = (RadiologyService) Context.getService(RadiologyService.class);
        RadiologyDepartment department = ls.getCurrentRadiologyDepartment();
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
    public List<SimpleObject> searchQueue(
            @RequestParam(value = "date", required = false) String dateStr,
            @RequestParam(value = "phrase", required = false) String phrase,
            @RequestParam(value = "investigation", required = false) Integer investigationId,
            @RequestParam(value = "currentPage", required = false) Integer currentPage,
            UiUtils ui) {
        RadiologyService ls = Context.getService(RadiologyService.class);
        Concept investigation = Context.getConceptService().getConcept(investigationId);
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        Date date = null;
        List<SimpleObject> simpleObjects = new ArrayList<SimpleObject>();
        try {
            date = sdf.parse(dateStr);
            Map<Concept, Set<Concept>> testTreeMap = getAllowableTests();
            Set<Concept> allowableTests = new HashSet<Concept>();
            if (investigation != null) {
                allowableTests = testTreeMap.get(investigation);
            } else {
                for (Concept c : testTreeMap.keySet()) {
                    allowableTests.addAll(testTreeMap.get(c));
                }
            }
            if (currentPage == null)
                currentPage = 1;
            List<Order> orders = ls.getOrders(date, phrase, allowableTests,
                    currentPage);
            List<TestModel> tests = RadiologyUtil.generateModelsFromOrders(
                    orders, testTreeMap);
            simpleObjects = SimpleObject.fromCollection(tests, ui, "startDate", "patientIdentifier", "patientName", "gender", "age", "testName", "orderId","status");
        } catch (ParseException e) {
            e.printStackTrace();
            logger.error("Error when parsing order date!", e.getMessage());
        }
        return simpleObjects;
    }

}
