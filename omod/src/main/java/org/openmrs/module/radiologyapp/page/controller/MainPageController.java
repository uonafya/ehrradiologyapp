package org.openmrs.module.radiologyapp.page.controller;

import java.util.Set;

import org.openmrs.Concept;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.hospitalcore.RadiologyService;
import org.openmrs.module.hospitalcore.model.RadiologyDepartment;
import org.openmrs.module.hospitalcore.model.RadiologyDepartment;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.page.PageModel;
import org.openmrs.ui.framework.page.PageRequest;

public class MainPageController {
	
	public void get(
			UiSessionContext sessionContext,
			PageModel model,
			PageRequest pageRequest,
			UiUtils ui) {
		/*pageRequest.getSession().setAttribute(ReferenceApplicationWebConstants.SESSION_ATTRIBUTE_REDIRECT_URL,ui.thisUrl());
		sessionContext.requireAuthentication();*/
		
		RadiologyService radiologyService = Context.getService(RadiologyService.class);
		RadiologyDepartment department = radiologyService.getCurrentRadiologyDepartment();

		model.addAttribute("investigations", null);

		if(department!=null){
			Set<Concept> investigations = department.getInvestigations();
			model.addAttribute("investigations", investigations);
		}
	}

}
