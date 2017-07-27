
##################################
########    rgajjelli    #########
##################################

#git clone https://github.com/gajjelli/aws-infrastructure-aurora.git

This terraform script will set up an end-to-end infrastructure set up which you can use for most projects.
It comprises of:
 * A VPC
 * Two public subnet
 * Two private subnets
 * Associated security groups, routing tables etc
 * Aurora-RDS Cluster

## Steps

1. Clone this repo - git clone https://github.com/gajjelli/aws-infrastructure-aurora.git
2. Update variables in terraform.tfvars and creds.sh file - Make sure that these credentials will not be available in GitHub.

3. `source creds.sh`
4. `terraform get`
5. `terraform plan`
     This is a dry-run test and show you all the resources that will get created.
6. `terraform apply`
     This actually creates the resources mentioned in step (4)

## Access

After 'terraform apply' runs succesfully, you can get the following info:

 `terraform output vpc_id` -  VPC ID

 `terraform output cluster_address` - Aurora cluster Address


### To log into your instance:

  `ssh -i ~/.ssh/id_rsa ec2-user@<ip address from previous step>`

  *NOTE*: The ~/.ssh/id_rsa should correspond to the public key you specified in your terraform.tfvars file

## Destroy

Once you are done, if you want to tear everything down:

  `terraform destroy`
