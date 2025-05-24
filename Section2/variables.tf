# Variables for the  virtual machines app_environment
variable "app_environment" {
  description = "Application environment"
  type        = map(object(
    {
    virtual_machine_name = string
    virtual_machine_size = string
    virtual_network_name    = string
    virtual_network_cidr_block = string
    network_interface_name = string
    public_ip_address_name = string
    tenant_id = string
    subnets=map(object(
        {
            cidr_block = string
        }))
  }))
}

variable "admin_password" {
  description = "Admin password for the virtual machine"
  type        = string
  sensitive   = true
}