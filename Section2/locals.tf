locals {
  resource_location = "North Europe"
  storageaccount_name = "appstorage400009078"
  network_security_group_rules = [
    {
      priority = 300
      destination_port_range = "3389"
    },
    {
      priority = 310
      destination_port_range = "80"
    },
    {
      priority = 320
      destination_port_range = "22"
    }
  ]
}