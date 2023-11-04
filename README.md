# Terraform-project1
# Terraform-project1
# Multi-Tier Web Application Deployment using Terraform on AWS

This project demonstrates how to design and deploy a multi-tier web application on Amazon Web Services (AWS) using Terraform. The solution includes the creation of a custom Virtual Private Cloud (VPC), launching EC2 instances, setting up an Application Load Balancer, configuring auto-scaling, and deploying an RDS database. This comprehensive infrastructure is designed to ensure scalability, high availability, and security.

## Table of Contents
- [Project Overview](#project-overview)
- [Getting Started](#getting-started)
- [Prerequisites](#prerequisites)
- [Deployment](#deployment)
- [Testing](#testing)
- [Contributing](#contributing)
- [License](#license)

## Project Overview
The project comprises the following key components and steps:

1. **Custom VPC Setup:**
   - Create a custom VPC with a CIDR block of 10.0.0.0/16.
   - Configure two public subnets in different availability zones (AZs) and two private subnets in the same AZs.
   - Set up NAT Gateways for private subnets to enable internet access.
   - Create separate route tables for private subnets.

2. **EC2 Instances:**
   - Launch two EBS-backed EC2 instances in the private subnets.
   - Configure instance user data script to set up Apache and display a web page.
   - Ensure EBS volumes are encrypted at rest.
   - Apply security group rules for SSH, HTTP, and HTTPS.

3. **Load Balancer Setup:**
   - Create a target group for the EC2 instances.
   - Launch an Application Load Balancer in the public subnets.
   - Adjust security groups to allow inbound traffic only from the load balancer.
   - Configure the Application Load Balancer security group for outbound and inbound traffic.

4. **Auto Scaling:**
   - Set up a target tracking Auto Scaling group to ensure elasticity and cost-effectiveness.
   - Monitor the two instances and add or replace failed instances as needed.

5. **RDS Database:**
   - Launch a Multi-AZ RDS database.
   - Configure the RDS security group to only allow access from the web/app tier security group.

## Getting Started

### Prerequisites
Before you begin, make sure you have the following prerequisites in place:

- [Terraform](https://www.terraform.io/) installed on your local machine.
- AWS CLI configured with appropriate IAM credentials.
- An AWS account with sufficient permissions to create the required resources.

## Deployment

1. Clone this GitHub repository to your local machine.

2. Modify the Terraform code as needed, such as custom VPC settings, region, and resource configurations.

3. Initialize Terraform in the project directory:
   ```bash
   terraform init
   ```

4. Review the execution plan:
   ```bash
   terraform plan
   ```

5. Apply the changes to create the infrastructure:
   ```bash
   terraform apply
   ```

6. Confirm the changes by typing 'yes' when prompted.

## Testing

After successful deployment, access your web application through the Application Load Balancer's DNS name. If you can view the index.html message on the instances via the load balancer, congratulations on completing this project on AWS.

## Contributing

If you'd like to contribute to this project or report issues, please open a new GitHub issue or submit a pull request.

## License

This project is licensed under the [MIT License](LICENSE) - feel free to use, modify, and distribute it as needed.
