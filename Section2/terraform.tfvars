app_environment = {
  "production" = {
    virtual_machine_name = "webvm01"
    virtual_machine_size = "Standard_B2s"
    virtual_network_name = "app-network"
    network_interface_name = "webinterface01"
    public_ip_address_name = "webip01"
    virtual_network_cidr_block = "10.0.0.0/16"
    tenant_id = "bf6319b5-74f6-4a8a-9fd3-5dc84223e990"
    subnets = {
      "websubnet01" = {cidr_block = "10.0.0.0/24"
        machines = {
          "webvm01" = {
            network_interface_name = "webinterface01"
            public_ip_address_name = "webip01"
          }
        }
      }
      "appsubnet01" = {cidr_block = "10.0.1.0/24"
       machines = {
          "appvm01" = {
            network_interface_name = "appinterface01"
            public_ip_address_name = "appip01"
          }
        }
      }
}
  }
  
}
