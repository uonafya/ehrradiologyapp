package org.openmrs.module.radiologyapp.fragment.controller;


import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import org.openmrs.Patient;
import org.openmrs.PersonAttribute;
import org.openmrs.PersonAttributeType;
import org.openmrs.User;
import org.openmrs.api.PatientService;
import org.openmrs.api.PersonService;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.BillingService;
import org.openmrs.module.hospitalcore.HospitalCoreService;
import org.openmrs.module.hospitalcore.model.OpdTestOrder;
import org.openmrs.module.hospitalcore.model.PatientSearch;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

@Controller("GetAllProcessedRadiologyOrdersController")
@RequestMapping("/module/billing/listoforder.form")
public class ListOfOrderController {
   @RequestMapping(method = RequestMethod.GET)
   public String main(Model model, @RequestParam("patientId") Integer patientId,
         @RequestParam("paid") Integer paid,
         @RequestParam(value = "date", required = false) String dateStr) {
      BillingService billingService = Context
            .getService(BillingService.class);
      PatientService patientService = Context.getPatientService();
      Patient patient = patientService.getPatient(patientId);
      SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
      Date date = null;
         try {
            date = sdf.parse(dateStr);
         } catch (ParseException e) {
            e.printStackTrace();
         }
      List<OpdTestOrder> listOfOrders = billingService.listOfOrder(patientId,date);
      // Kesavulu loka 25-06-2013, Add Patient Details on the page where Order ID is clicked
      HospitalCoreService hospitalCoreService = Context.getService(HospitalCoreService.class);
      PatientSearch patientSearch = hospitalCoreService.getPatientByPatientId(patientId);
      PersonService personService = Context.getPersonService();
      PersonAttributeType category = personService.getPersonAttributeTypeByUuid("09cd268a-f0f5-11ea-99a8-b3467ddbf779");//14
      PersonAttributeType fileNumber = personService.getPersonAttributeTypeByUuid("09cd268a-f0f5-11ea-99a8-b3467ddbf779");//43
                
      model.addAttribute("age",patient.getAge());
      
      if(patient.getGender().equals("M"))
      {
         model.addAttribute("gender","Male");
      }
      if(patient.getGender().equals("F"))
      {
         model.addAttribute("gender","Female");
      }
      model.addAttribute("category",patient.getAttribute(category.getPersonAttributeTypeId()));
      model.addAttribute("fileNumber",patient.getAttribute(fileNumber.getPersonAttributeTypeId()));
      /*
      if(patient.getAttribute(14).getValue() == "Waiver"){
         model.addAttribute("exemption", patient.getAttribute(32));
      }
      else if(patient.getAttribute(14).getValue()!="General" && patient.getAttribute(14).getValue()!="Waiver"){
         model.addAttribute("exemption", patient.getAttribute(36));
      }
      else {
         model.addAttribute("exemption", " ");
      }
      */
      model.addAttribute("patientSearch", patientSearch);
      model.addAttribute("listOfOrders", listOfOrders);
      //model.addAttribute("serviceOrderSize", serviceOrderList.size());
      model.addAttribute("patientId", patientId);
      model.addAttribute("date", dateStr);   
                
                
      return "/module/billing/queue/listOfOrder";
   }
}
