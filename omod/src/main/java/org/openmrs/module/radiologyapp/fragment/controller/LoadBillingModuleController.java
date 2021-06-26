package org.openmrs.module.radiologyapp.fragment.controller;

import org.openmrs.module.billing.web.conroller.LoadBillingTestModuleServiceController;

@conroller
public class LoadBillingModuleController {

private LoadBillingModuleController billingtestmodule;

//display a list of billing test modules
    @GetMapping("/openmrs/radiologyapp/")
     public String viewtestBillingModules(Model model) {
        model.addAttribute("queue", billingtestmodule.getAllTestModules());
        return "webapp/pages/main.gsp"
    }

}
