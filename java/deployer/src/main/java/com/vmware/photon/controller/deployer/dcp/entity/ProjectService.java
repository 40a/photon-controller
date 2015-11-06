/*
 * Copyright 2015 VMware, Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License.  You may obtain a copy of
 * the License at http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed
 * under the License is distributed on an "AS IS" BASIS, without warranties or
 * conditions of any kind, EITHER EXPRESS OR IMPLIED.  See the License for the
 * specific language governing permissions and limitations under the License.
 */

package com.vmware.photon.controller.deployer.dcp.entity;

import com.vmware.dcp.common.Operation;
import com.vmware.dcp.common.ServiceDocument;
import com.vmware.dcp.common.StatefulService;
import com.vmware.photon.controller.common.dcp.InitializationUtils;
import com.vmware.photon.controller.common.dcp.ServiceUtils;
import com.vmware.photon.controller.common.dcp.ValidationUtils;
import com.vmware.photon.controller.common.dcp.validation.Immutable;
import com.vmware.photon.controller.common.dcp.validation.NotNull;

/**
 * This class implements a DCP micro-service which provides a plain data object
 * representing a project.
 */
public class ProjectService extends StatefulService {

  /**
   * This class defines the document state associated with a single {@link ProjectService} instance.
   */
  public static class State extends ServiceDocument {

    /**
     * This value represents the name of the project.
     */
    @NotNull
    @Immutable
    public String projectName;

    /**
     * This value represents the relative path to the REST endpoint of the
     * ResourceTicketService object to which the current project belongs.
     */
    @NotNull
    @Immutable
    public String resourceTicketServiceLink;

    /**
     * This value represents the ID of the project object in APIFE.
     */
    @NotNull
    @Immutable
    public String projectId;
  }

  public ProjectService() {
    super(State.class);
    super.toggleOption(ServiceOption.OWNER_SELECTION, true);
    super.toggleOption(ServiceOption.PERSISTENCE, true);
    super.toggleOption(ServiceOption.REPLICATION, true);
  }

  @Override
  public void handleStart(Operation startOperation) {
    ServiceUtils.logInfo(this, "Starting service %s", getSelfLink());
    State startState = startOperation.getBody(State.class);
    InitializationUtils.initialize(startState);
    validateState(startState);
    startOperation.complete();
  }

  private void validateState(State currentState) {
    ValidationUtils.validateState(currentState);
    ValidationUtils.validateEntitySelfLink(this, currentState.projectId);
  }
}
