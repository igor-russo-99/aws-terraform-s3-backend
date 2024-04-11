variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "ExampleAppServerInstance"
}


variable "terraform-state-bucket-name" {
  description = "Name of the bucket used to store Terraform state"
  type        = string
  default     = "igorsr-dev-terraform-state-bucket"
}
