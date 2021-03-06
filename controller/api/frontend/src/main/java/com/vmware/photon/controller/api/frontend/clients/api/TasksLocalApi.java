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
package com.vmware.photon.controller.api.frontend.clients.api;

import com.vmware.photon.controller.api.client.resource.TasksApi;
import com.vmware.photon.controller.api.frontend.clients.TaskFeClient;
import com.vmware.photon.controller.api.frontend.exceptions.external.ExternalException;
import com.vmware.photon.controller.api.model.Task;

import com.google.common.util.concurrent.FutureCallback;

import java.io.IOException;
import java.util.concurrent.ExecutorService;

/**
 * This class implements Tasks API for communicating with APIFE locally.
 */
public class TasksLocalApi implements TasksApi {
  private final TaskFeClient taskFeClient;
  private final ExecutorService executorService;

  public TasksLocalApi(TaskFeClient taskFeClient, ExecutorService executorService) {
    this.taskFeClient = taskFeClient;
    this.executorService = executorService;
  }

  @Override
  public String getBasePath() {
    return null;
  }

  @Override
  public Task getTask(String taskId) throws IOException {
    try {
      return taskFeClient.get(taskId);
    } catch (ExternalException e) {
      throw new RuntimeException(e);
    }
  }

  @Override
  public void getTaskAsync(String taskId, FutureCallback<Task> responseCallback) throws IOException {
    executorService.submit(() -> {
      try {
        Task task = getTask(taskId);
        responseCallback.onSuccess(task);
      } catch (Exception e) {
        responseCallback.onFailure(e);
      }
    });
  }
}
