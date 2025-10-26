# Terraform-AWS-Jenkins
Spinning up 5 Compute Instances + 1 Load Balancer
Objectives:
1.	Create a VPC with necessary networking components.
2.	Launch 5 EC2 instances:
o	Two for production environment (Production_Env1 and Production_Env2).
o	One for Jenkins controller (JenkinsController).
o	One for testing environment (Testing_Env).
o	One for staging environment (Staging_Env).
3.	Configure a load balancer to handle requests to the production environment instances using round-robin algorithm.
4.	Install Jenkins on the Jenkins controller instance.
5.	Open the necessary ports for each instance.

# Class_repository_public_terraform
