# Setup
CD into application-database
terrafom init
terraform plan
terraform apply

# For devs
Password should be stored in AWS secrets or Hashicorp Vault

# Security
Database exists in private subnet and allows connections from the application server only
Create a user for the application with fine tuned roles 
SQL injection attack is prevention with appropriate database libraries
Password are never stored in the clear in the database

# Reason For Choice 
Postgres repesents a stable, reliable database with a rich set of features

