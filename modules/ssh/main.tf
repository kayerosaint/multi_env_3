resource "tls_private_key" "test" {
  algorithm = "RSA"
}

resource "local_file" "private_key" {
  content         = tls_private_key.test.private_key_pem
  filename        = "ssh_keys/${var.env}.pem"
  file_permission = "0700"
}

resource "null_resource" "key" {
  provisioner "local-exec" {
    command     = "./fix.sh"
    interpreter = ["/bin/bash"]
  }
  depends_on = [local_file.private_key]
}
