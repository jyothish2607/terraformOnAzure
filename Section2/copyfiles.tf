resource "null_resource" "addfiles" {
    
    provisioner "file" {
        source      = "Defualt.html"
        destination = "/home/adminuser/Defualt.html"
        connection {
        type        = "ssh"
        host        = "${azurerm_public_ip.appip["appvm01"].ip_address}"
        user        = "linuxadmin"
        password    = var.admin_password
        }
    }
    
    provisioner "remote-exec" {
        inline = [
        "sudo mv /home/linuxadmin/Defualt.html /var/www/html/index.html"
        ]
        connection {
        type        = "ssh"
        host        = "${azurerm_public_ip.appip["appvm01"].ip_address}"
        user        = "linuxadmin"
        password    = var.admin_password
        }
        }
        depends_on = [ azurerm_network_security_group.app_nsg ]
    }
  
