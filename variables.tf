variable "region" {
  default = "ap-south-1"
}

variable "aws_ami" {
  default = "ami-03f4878755434977f"

}

# Instance Type
variable "instance_type" {
  default = "t2.micro"
}

# Key Pair to access
variable "aws_key_pair" {
  default = "Test_projects"
}

variable "ami" {
  default = "ami-03f4878755434977f"
