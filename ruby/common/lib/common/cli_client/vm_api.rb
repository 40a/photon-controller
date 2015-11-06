# Copyright 2015 VMware, Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed
# under the License is distributed on an "AS IS" BASIS, without warranties or
# conditions of any kind, EITHER EXPRESS OR IMPLIED. See the License for the
# specific language governing permissions and limitations under the License.

module EsxCloud
  class CliClient
    module VmApi

      # @param [String] project_id
      # @param [Hash] payload
      # @return [Vm]
      def create_vm(project_id, payload)
        project = find_project_by_id(project_id)
        tenant = @project_to_tenant[project.id]

        cmd = "vm create -t '#{tenant.name}' -p '#{project.name}' -n '#{payload[:name]}' -f '#{payload[:flavor]}' -i '#{payload[:sourceImageId]}'"

        disks = payload[:attachedDisks].map do |disk|
          disk_string = disk[:name] + " " + disk[:flavor]
          disk_string += " boot=true" if disk[:bootDisk]
          disk_string += " " + disk[:capacityGb].to_s if disk[:capacityGb]
          disk_string
        end.join(", ")

        cmd += " -d '#{disks}'"

        if payload[:environment]
          env = payload[:environment].map do |(k, v)|
            "#{k}=#{v}"
          end.join(", ")

          cmd += " -e '#{env}'"
        end

        if payload[:affinities] && !payload[:affinities].empty?
          affinities = payload[:affinities].map do |affinities|
            "#{affinities[:kind]} #{affinities[:id]}"
          end.join(", ")
          cmd += " -a '#{affinities}'"
        end

        run_cli(cmd)
        vms = find_vms_by_name(project_id, payload[:name]).items
        if vms.size > 1
          raise EsxCloud::CliError, "There are more than one VM having the same name '#{payload[:name]}' in the project."
        end

        vm = vms[0]
        @vm_to_project[vm.id] = project

        vm
      end

      # @param [String] id
      # @return [Boolean]
      def delete_vm(id)
        run_cli("vm delete '#{id}'")

        true
      end

      # @param [String] project_id
      # @return [VmList]
      def find_all_vms(project_id)
        @api_client.find_all_vms(project_id)
      end

      # @param [String] id
      # @return [Vm]
      def find_vm_by_id(id)
        @api_client.find_vm_by_id(id)
      end

      # @param [String] project_id
      # @param [String] name
      # @return [VmList]
      def find_vms_by_name(project_id, name)
        @api_client.find_vms_by_name(project_id, name)
      end

      # @param [String] id
      # @param [String] state
      # @return [TaskList]
      def get_vm_tasks(id, state = nil)
        @api_client.get_vm_tasks(id, state)
      end

      # @param [String] id
      # @return [VmNetworks]
      def get_vm_networks(id)
        @api_client.get_vm_networks(id)
      end

      # @param [String] id
      # @return [MksTicket]
      def get_vm_mks_ticket(id)
        @api_client.get_vm_mks_ticket(id)
      end

      # @param [String] id
      # @return [Vm]
      def start_vm(id)
        run_cli("vm start '#{id}'")
        find_vm_by_id(id)
      end

      # @param [String] id
      # @return [Vm]
      def stop_vm(id)
        run_cli("vm stop '#{id}'")
        find_vm_by_id(id)
      end

      # @param [String] id
      # @return [Vm]
      def restart_vm(id)
        run_cli("vm restart '#{id}'")
        find_vm_by_id(id)
      end

      # @param [String] id
      # @return [Vm]
      def resume_vm(id)
        run_cli("vm resume '#{id}'")
        find_vm_by_id(id)
      end

      # @param [String] id
      # @return [Vm]
      def suspend_vm(id)
        run_cli("vm suspend '#{id}'")
        find_vm_by_id(id)
      end

      # @param [String] id
      # @param [String] operation
      # @param [String] disk_id
      # @param [Hash] _
      # @return [Vm]
      def perform_vm_disk_operation(id, operation, disk_id, _ = {})
        operation_cmd = operation.downcase
        run_cli("vm #{operation_cmd} '#{id}' -d '#{disk_id}'")

        find_vm_by_id(id)
      end

      # @param [String] id
      # @param [String] iso_path
      # @param [String] iso_name
      # @return [Vm]
      def perform_vm_iso_attach(id, iso_path, iso_name = nil)
        if iso_name.nil?
          iso_name = random_name("image-")
        end

        run_cli("vm attach_iso '#{id}' -p '#{iso_path}' -n '#{iso_name}'")

        find_vm_by_id(id)
      end

      # @param [String] id
      # @return [Vm]
      def perform_vm_iso_detach(id)
        @api_client.perform_vm_iso_detach(id)
      end

      # @param [String] id
      # @param [Hash] payload
      # @return [Vm]
      def perform_vm_metadata_set(id, payload)
        @api_client.perform_vm_metadata_set(id, payload)
      end
    end
  end
end
