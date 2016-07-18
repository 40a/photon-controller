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

require "spec_helper"

describe "virtual_network_lifecyle", :virtual_network => true do
  let(:networks_to_delete) { [] }
  let(:spec) {
    EsxCloud::VirtualNetworkCreateSpec.new(random_name("network-"), "virtual network", "ROUTED", 128, 16)
  }

  before(:all) do
    @seeder = EsxCloud::SystemSeeder.instance
    @project = @seeder.project!
  end

  after(:each) do
    networks_to_delete.each do |network|
      ignoring_all_errors { network.delete } unless network.nil?
    end
  end

  it "Creates a virtual network, and then delete it" do
    network = create_network(spec)

    retrieved_network = EsxCloud::VirtualNetwork.get(network.id)
    expect(retrieved_network.id).to eq(network.id)

    retrieved_network_list = client.get_project_networks(@project.id, spec.name)
    expect(retrieved_network_list.items.count).to eq(1)
    expect(retrieved_network_list.items.first.id).to eq(network.id)

    retrieved_network_list = client.get_project_networks(@project.id)
    expect(retrieved_network_list.items.count).to be >= 1

    network.delete
  end

  private

  def create_network(spec)
    begin
      EsxCloud::VirtualNetwork.create(@project.id, spec)
    rescue
      client.get_project_networks(@project.id, spec.name).items.each { |net| networks_to_delete << net }
      raise
    end
  end
end
