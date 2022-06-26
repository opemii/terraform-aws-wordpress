resource "tls_private_key" "key2" {
  algorithm = "RSA"
}
resource "aws_key_pair" "key2" {
  key_name = "key2"
  public_key = tls_private_key.key2.public_key_openssh
}
resource "local_file" "key2" {
  content = tls_private_key.key2.private_key_pem
  filename = "key2.pem"
  
}