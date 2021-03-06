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

package com.vmware.photon.controller.api.frontend.exceptions.internal;

/**
 * Thrown when the OVF file cannot be parsed or has invalid data.
 */
public class InvalidOvfException extends InternalException {

  public InvalidOvfException(String message) {
    super(message);
  }

  public InvalidOvfException(String message, Throwable e) {
    super(message, e);
  }
}
