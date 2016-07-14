package org.openmrs.module.radiologyapp.fragment.controller;

import org.openmrs.ui.framework.SimpleObject;

/**
 * @author Stanslaus Odhiambo
 * Created on 7/13/2016.
 */
public class RadiationResultsFragmentController {

    public SimpleObject saveScanResults(){
        //process save scan results


        return SimpleObject.create("status","success","message","Saved Successfully");
    }


}
