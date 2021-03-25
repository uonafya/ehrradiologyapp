package org.openmrs.module.radiologyapp.fragment.controller;


import org.openmrs.Concept;
import org.openmrs.Order;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.RadiologyService;
import org.openmrs.module.hospitalcore.model.RadiologyDepartment;
import org.openmrs.module.hospitalcore.util.RadiologyUtil;
import org.openmrs.module.hospitalcore.util.TestModel;
import org.openmrs.module.radiologyapp.util.RadiologyAppUtil;
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
        RadiologyService radiologyService = (RadiologyService) Context.getService(RadiologyService.class);
        RadiologyDepartment department = radiologyService.getCurrentRadiologyDepartment();
        if(department != null){
            Set<Concept> investigations = department.getInvestigations();
            model.addAttribute("investigations", investigations);
        }
    }

    public List<SimpleObject> searchQueue(
            @RequestParam(value = "orderDate", required = false) String orderDateString,
            @RequestParam(value = "phrase", required = false) String phrase,
            @RequestParam(value = "investigation", required = false) Integer investigationId,
            @RequestParam(value = "currentPage", required = false) Integer currentPage,
            UiUtils ui) {

        RadiologyService radiologyService = Context.getService(RadiologyService.class);
        Concept investigation = Context.getConceptService().getConcept(investigationId);
        SimpleDateFormat dateFormatter = new SimpleDateFormat("dd/MM/yyyy");
        Date orderDate = null;
        List<SimpleObject> testOrdersInQueue = new ArrayList<SimpleObject>();

		try {
            orderDate = dateFormatter.parse(orderDateString);
            Map<Concept, Set<Concept>> allowedInvestigations = RadiologyAppUtil.getAllowedInvestigations();
            Set<Concept> allowableTests = new HashSet<Concept>();
            if (investigation != null) {
                allowableTests = allowedInvestigations.get(investigation);
            } else {
                for (Concept c : allowedInvestigations.keySet()) {
                    allowableTests.addAll(allowedInvestigations.get(c));
                }
            }

            if (currentPage == null)
                currentPage = 1;
            List<Order> orders = radiologyService.getOrders(orderDate, phrase, allowableTests,
                    currentPage);
            List<TestModel> tests = RadiologyUtil.generateModelsFromOrders(
                    orders, allowedInvestigations);
            testOrdersInQueue = SimpleObject.fromCollection(tests, ui, "startDate", "patientIdentifier", "patientName", "gender", "age", "testName", "orderId","status");
        } catch (ParseException e) {
            e.printStackTrace();
            logger.error("Error when parsing order date!", e.getMessage());
        }
        return testOrdersInQueue;
    }

	public SimpleObject acceptOrder(@RequestParam("orderId") Integer orderId) {
		@SuppressWarnings("deprecation")
		Order order = Context.getOrderService().getOrder(orderId);
		if (order != null) {
			try {
				RadiologyService radiologyService = (RadiologyService) Context
						.getService(RadiologyService.class);
				Integer acceptedTestId = radiologyService.acceptTest(order);
				return SimpleObject.create("status", "success",
						"acceptedTestId", acceptedTestId);
			} catch (Exception e) {
				logger.error("Error while accepting order {}", orderId, e);
				return SimpleObject
						.create("status", "fail", "message", e.getMessage());
			}
		}
		return SimpleObject.create("status", "fail", "message", "Order '"
				+ orderId + "' not found.");
	}
	
	public SimpleObject rescheduleOrder(
			@RequestParam("orderId") Integer orderId,
			@RequestParam("rescheduledDate") String rescheduledDateString
			) {

		@SuppressWarnings("deprecation")
		Order order = Context.getOrderService().getOrder(orderId);
		if (order != null) {
			RadiologyService radiologyService = Context.getService(RadiologyService.class);
			SimpleDateFormat dateFormatter = new SimpleDateFormat("dd/MM/yyyy");
			Date rescheduledDate;
			try {
				rescheduledDate = dateFormatter.parse(rescheduledDateString);
				String status = radiologyService.rescheduleTest(order, rescheduledDate);
				return SimpleObject.create("status", status, "message", "Order has been rescheduled.");
			} catch (ParseException e) {
				e.printStackTrace();
				return SimpleObject.create("status", "fail", "message", "Invalid date: " + rescheduledDateString);
			}
		}
		return SimpleObject.create("status", "fail", "message", "Order '" + orderId +"' not found.");
	}

}
