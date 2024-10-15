# Deploying a Highly Available Flask Web Application on AWS with Terraform

## Project Overview

This project involves creating and deploying a simple Flask web application to AWS using Terraform. The focus is on using Infrastructure as Code (IaC) to provision and configure the required cloud resources, including networking, security, and scaling mechanisms. To view the end product access the JPEG images  and view the OUTPUT files.

## Key Objectives

- **Leverage AWS Services**: Utilize EC2, RDS (Relational Database Service), S3, and ALB (Application Load Balancer) for deployment.
- **Infrastructure Automation**: Use Terraform to manage and automate the entire infrastructure deployment process.
- **Implement Best Practices**: Ensure scalability, security, and availability using AWS services.
- **Version Control**: Utilize Git to track changes to the infrastructure.

## Project Architecture

The architecture consists of the following components:

- **VPC (Virtual Private Cloud)**: Comprises multiple public and private subnets.
- **EC2 Instances**: Running the Flask app in an auto-scaling group.
- **Application Load Balancer (ALB)**: Distributes traffic across the EC2 instances.
- **RDS MySQL Database**: Provides persistence in the private subnet.
- **S3 Bucket**: Stores static assets like images and logs.
- **IAM Roles and Policies**: Secures access between AWS resources.
- **CloudWatch**: Monitors and sets up alarms for key metrics (e.g., CPU usage).
- **Terraform**: Automates the deployment of the entire infrastructure.
  
## Getting Started

### Prerequisites

Before you begin, ensure you have:

- **AWS Account**: Sign up for an account on [AWS](https://aws.amazon.com/).
- **Terraform**: Install Terraform from [terraform.io](https://www.terraform.io/downloads.html).
- **AWS CLI**: Install the AWS Command Line Interface.
## Steps Involved

### 1. Create the Flask Web Application
   ```
from flask import Flask
app = Flask(__name__)

@app.route('/')
def home():
    return "Hello, this is a Highly Available Flask app on AWS!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
   ```

### 2. Set Up the AWS Infrastructure with Terraform

Create a directory for the Terraform project, e.g., flask-infra and Inside flask-infra, create the following files:
  
- main.tf: Contains the core infrastructure resources.
- variables.tf: Contains variables to make your infrastructure reusable and configurable.
- outputs.tf: Defines outputs to get important information after the deployment (e.g., Load Balancer DNS

### 3. Create a VPC with public and private subnets:
- Use Terraform to create a VPC with two public and two private subnets.
- Include an Internet Gateway (IGW) for public access.

### 4. Deploy the EC2 Instances

- Set up an auto-scaling group for EC2 instances running the Flask app.
- Configure security groups to allow traffic only from the ALB.
- Use EC2 user data to automate the Flask app deployment.

### 5. Configure Load Balancing and Scaling

- Deploy an Application Load Balancer (ALB) to distribute incoming requests.
- Set up auto-scaling based on CPU utilization.

### 6. Set Up RDS MySQL Database

- Deploy an RDS MySQL instance in the private subnet.
- Ensure secure connectivity to EC2 instances.

### 7. Use S3 for Static Assets

- Configure an S3 bucket to store static assets for the application.

### 8. Implement Monitoring and Logging

- Set up CloudWatch to monitor the performance of EC2, ALB, and RDS.

### 9. Security Best Practices

- Use IAM roles to interact securely with S3 and RDS.
- Configure Security Groups and Network ACLs for tight access control.


### Installation Steps to Simply use the codes in this repository

1. **Clone the Repository**

   Open your terminal and run:

   ```
   git clone https://github.com/tobimicheal/Deploying-a-Highly-Available-Flask-Web-Application-on-AWS-with-Terraform.git
   cd Deploying-a-Highly-Available-Flask-Web-Application-on-AWS-with-Terraform
   ```
2. Configure AWS Credentials
   Set up your AWS credentials using the AWS CLI:
    ```
   aws configure
     ```
    Follow the prompts to enter your AWS Access Key ID, Secret Access Key, region, and output format.
   
4. Initialize Terraform
   Run the following command to initialize Terraform in your project directory:
   ```
   terraform init
   ```
5. Apply the Terraform Configuration
   Create the infrastructure with:
      ```
   terraform apply
      ```
6. Access the Flask Application
   Once the deployment is complete, navigate to the Application Load Balancer (ALB) URL provided in the Terraform output to access your Flask application and also view access all your provisioned resources in your AWS account.



