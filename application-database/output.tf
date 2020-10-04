output "public_ip" {
  value = module.web-server.public_ip
}

output "database_domain" {
 value       = module.database.this_db_instance_address
}