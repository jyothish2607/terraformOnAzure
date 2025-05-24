variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "admin_username" {
  description = "Admin username for the virtual machine"
  type        = string
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_F2"
  
}
variable "admin_password" {
  description = "Admin password for the virtual machine"
  type        = string
  sensitive   = true
}