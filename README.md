# Setup
CD into application-database
terrafom init
terraform plan
terraform apply

The public IP of the server, the dns name of the database master and replica will be output after the command runs successfully

# Routing

Routing to the replica would be done with the library used to connect to the database. If there is more than one replica a network loadbalancer can be used to balance requests between the replicas. 