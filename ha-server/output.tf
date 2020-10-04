
output "elb_dns" {
  value = module.ha_elb.this_elb_dns_name
}

