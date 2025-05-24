locals {
  resource_location = "North Europe"
  virtual_network={
    name = "app-network"
    address_space = ["10.0.0.0/16"]
    }
  subnet_address_prefix = ["10.0.0.0/24", "10.0.1.0/24"]
  subnets=[
    {
      name = "websubnet1"
      address_prefixes = [local.subnet_address_prefix[0]]
    },
    {
      name = "websubnet2"
      address_prefixes = [local.subnet_address_prefix[1]]
    }
  ]
}