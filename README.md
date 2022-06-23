# terraform-small-app
Terraform module and instantiation used to create a VPC with an EC2 which serves a web app.


# Module repo and live repo

For simplicity I used one repository, but ideally you will have 2 repositories.
One for `modules` which will have the contents of the modules folder and one for `live` which will define the live infrastructure running in each environment (dev, stage, prod...) 

# TODO: 

Instantiate module in `live` directory.