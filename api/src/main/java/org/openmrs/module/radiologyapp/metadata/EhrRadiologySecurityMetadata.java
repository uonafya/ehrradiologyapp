package org.openmrs.module.radiologyapp.metadata;

import org.openmrs.module.metadatadeploy.bundle.AbstractMetadataBundle;
import org.openmrs.module.metadatadeploy.bundle.Requires;
import org.springframework.stereotype.Component;

import static org.openmrs.module.metadatadeploy.bundle.CoreConstructors.idSet;
import static org.openmrs.module.metadatadeploy.bundle.CoreConstructors.privilege;
import static org.openmrs.module.metadatadeploy.bundle.CoreConstructors.role;

/**
 * Implementation of access control to the app.
 */
@Component
@Requires(org.openmrs.module.kenyaemr.metadata.SecurityMetadata.class)
public class EhrRadiologySecurityMetadata extends AbstractMetadataBundle {

    public static class _Privilege {

        public static final String APP_RADIOLOGY_MODULE_APP = "App: radiologyapp.main";
    }

    public static final class _Role {

        public static final String APPLICATION_RADIOLOGY_MODULE = "EHR Radiology";
    }

    /**
     * @see AbstractMetadataBundle#install()
     */
    @Override
    public void install() {

        install(privilege(_Privilege.APP_RADIOLOGY_MODULE_APP, "Able to access Key patient EHR radiology module "));
        install(role(_Role.APPLICATION_RADIOLOGY_MODULE, "Can access Key EHR radiology module",
                idSet(org.openmrs.module.kenyaemr.metadata.SecurityMetadata._Role.API_PRIVILEGES_VIEW_AND_EDIT),
                idSet(_Privilege.APP_RADIOLOGY_MODULE_APP)));

    }
}
