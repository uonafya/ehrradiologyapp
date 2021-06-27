es
    @GetMapping("/openmrs/radiologyapp/")
     public String viewtestBillingModules(Model model) {
        model.addAttribute("queue", billingtestmodule.getAllTestModules());
        return "webapp/fragments/queue"
    }

}
