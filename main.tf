resource "aws_instance" "example" {
  ami           = "ami-0ec0514235185af79"  # Change to your desired AMI ID
  instance_type = "t2.micro"      # Change to your desired instance type
  key_name      = "jaggi"
  tags = {
    Name = "testing-2024"
  }
}
