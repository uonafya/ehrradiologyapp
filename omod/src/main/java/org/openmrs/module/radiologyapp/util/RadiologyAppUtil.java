package org.openmrs.module.radiologyapp.util;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import org.openmrs.Concept;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.RadiologyService;
import org.openmrs.module.hospitalcore.concept.TestTree;
import org.openmrs.module.hospitalcore.model.RadiologyDepartment;

public class RadiologyAppUtil {

	public static Map<Concept, Set<Concept>> getAllowedInvestigations() {
        RadiologyService radiologyService = (RadiologyService) Context.getService(RadiologyService.class);
        RadiologyDepartment department = radiologyService.getCurrentRadiologyDepartment();
        Map<Concept, Set<Concept>> allowedInvestigations = new HashMap<Concept, Set<Concept>>();
        if (department != null) {
            Set<Concept> investigations = department.getInvestigations();
            for (Concept investigation : investigations) {
                TestTree tree = new TestTree(investigation);
                if (tree.getRootNode() != null) {
                    allowedInvestigations.put(tree.getRootNode().getConcept(),
                            tree.getConceptSet());
                }
            }
        }
        return allowedInvestigations;
    }

}
