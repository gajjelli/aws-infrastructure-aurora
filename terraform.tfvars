
# your environment
env = "uat"
# aws account number (used while creating topics for sns)
account_num="951849664683"
# ami id you want to base your EC2 instance off
ami_id="ami-4836a428"
# which port will your app server running on EC2 be listening to
web_port="9080"
# probably your laptop rsa key so that you can easily ssh into EC2
key_rsa_pub = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDEaTP2WFKF5eAEzdA2nR+rkBy+0lheH1PdZr2M9AgoQFGSW7YLOZWe0EWgCVUAc2KshlRBNLJ2wkHOywOq56LTXngS0vErk11W2tqQc6JuTMW5Wmqvijy0+5T2b9faT4WDm+IlhURaO59F4Y7fXidrGFyy4Ok9QGNg8X11y5kE1zrHa5APxKqGnK1SuANZnCzLrpvafbZf8rtD5VHPt9+4/hwcU8iB1/x1T7yIB6TorWq4IRDwtBBfGVZ4mZep4wPZHdye7OLrkaoBpPzcuo36S9r1mre4A72fxOYkQYUOFTtZbvyrxykidG6HLRGyp8wncYf54Dup3jT3Im4kEp4b ansible"
# what cidr ranges whould your vpc comprise off
vpc_cidr = "172.0.0.0/16"
# cidr of private subnet1
subnet_private1_cidr = "172.0.2.0/24"
# cidr of private subnet2
subnet_private2_cidr = "172.0.3.0/24"
# cidr of public subnet
subnet_public_cidr = "172.0.1.0/24"
subnet_public1_cidr = "172.0.4.0/24"

# cidr for the world
allow_all_cidr = "0.0.0.0/0"
# rds master db name
master_db_name = "master_db"
# rds master username
master_username = "admindb"
# rds master password
master_password = "123456789"
vpc_rds_subnet_ids = ""
