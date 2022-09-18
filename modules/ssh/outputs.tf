output "private_key_pem" {
  value = tls_private_key.test.private_key_pem
}

output "public_key_pem" {
  value = tls_private_key.test.public_key_pem
}

output "public_key_openssh" {
  value = tls_private_key.test.public_key_openssh
}
