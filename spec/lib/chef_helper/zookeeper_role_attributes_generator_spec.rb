require 'rails_helper'

module ChefHelper
  RSpec.describe ZookeeperRoleAttributesGenerator do
    before(:each) do
      @zookeeper_manifest = {
                    "name" => "haza-zookeeper",
                    "cluster_name" => "barito",
                    "deployment_cluster_name"=>"guja",
                    "type" => "zookeeper",
                    "desired_num_replicas" => 1,
                    "min_available_replicas" => 0,
                    "definition" => {
                      "container_type" => "stateless",
                      "strategy" => "RollingUpdate",
                      "allow_failure" => "false",
                      "resource" => {
                        "cpu_limit" => "0-2",
                        "mem_limit" => "5GB"
                      },
                      "source" => {
                        "mode" => "pull",
                        "alias" => "lxd-ubuntu-minimal-zookeeper-3.4.12-3",
                        "remote" => {
                          "name" => "barito-registry"
                        },
                        "fingerprint" => "",
                        "source_type" => "image"                      
                      },
                      "bootstrappers" => [{
                        "bootstrap_type" => "chef-solo",
                        "bootstrap_attributes" => {
                          "consul" => {
                            "hosts" => [

                            ],
                            "run_as_server" => false
                          },
                          "run_list" => [

                          ],
                          "zookeeper" => {
                            "hosts" => [
                              ""
                            ],
                            "my_id" => ""
                          }
                        },
                        "bootstrap_cookbooks_url" => "https://github.com/BaritoLog/chef-repo/archive/master.tar.gz"
                      }],
                      "healthcheck" => {
                        "type" => "tcp",
                        "port" => 9500,
                        "endpoint" => "",
                        "payload" => "",
                        "timeout" => ""
                      }
                    }
                  }
      @consul_manifest = {
                    "name" => "guja-consul",
                    "cluster_name" => "barito",
                    "deployment_cluster_name"=>"guja",
                    "type" => "consul",
                    "desired_num_replicas" => 1,
                    "min_available_replicas" => 0,
                    "definition" => {
                      "container_type" => "stateless",
                      "strategy" => "RollingUpdate",
                      "allow_failure" => "false",
                      "source" => {
                        "mode" => "pull",
                        "alias" => "lxd-ubuntu-minimal-consul-1.1.0-8",
                        "remote" => {
                          "name" => "barito-registry"
                        },
                        "fingerprint" => "",
                        "source_type" => "image"                      
                      },
                      "resource" => {
                        "cpu_limit" => "0-2",
                        "mem_limit" => "500MB"
                      },
                      "bootstrappers" => [{
                        "bootstrap_type" => "chef-solo",
                        "bootstrap_attributes" => {
                          "consul" => {
                            "hosts" => []
                          },
                          "run_list" => []
                        },
                        "bootstrap_cookbooks_url" => "https://github.com/BaritoLog/chef-repo/archive/master.tar.gz"
                      }],
                      "healthcheck" => {
                        "type" => "tcp",
                        "port" => 9500,
                        "endpoint" => "",
                        "payload" => "",
                        "timeout" => ""
                      }
                    }
                  }
      @manifests = [@zookeeper_manifest, @consul_manifest]
      @my_id = 1
    end

    describe '#generate' do
      it 'should generate zookeeper attributes' do
        zookeeper_attributes = ZookeeperRoleAttributesGenerator.new(
          @zookeeper_manifest,
          @manifests
        )
        
        attrs = zookeeper_attributes.generate

        expect(attrs).to eq({
            "consul"=>{
              "hosts"=>"$pf-meta:deployment_ip_addresses?deployment_name=guja-consul", 
              "run_as_server"=>false
            },
            "datadog" => {
              "zk"=>{
                "instances"=>[{"host"=>"localhost", "port"=>2181, "tags"=>[], "cluster_name"=>""}]
              }, 
              "datadog_api_key"=>"", 
              "datadog_hostname"=>""
            },
            "run_list"=>["role[zookeeper]"], 
            "zookeeper"=>{
              "hosts"=>"$pf-meta:deployment_host_sequences?host=zookeeper.service.consul", 
              "my_id"=>"$pf-meta:container_id?"
            }
          }
        )
      end
    end
  end
end
