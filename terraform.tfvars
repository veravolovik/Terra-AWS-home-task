region              = "us-east-2"
vpc_cidr_block      = "10.1.0.0/16"
sn_alb_cidr_block   = "10.1.1.0/24"
sn_alb2_cidr_block  = "10.1.5.0/24"
sn_web_cidr_block   = "10.1.2.0/24"
sn_db_cidr_block    = "10.1.3.0/24"
sn_db2_cidr_block   = "10.1.4.0/24"
db_version          = "11.4"
db_instance_class   = "db.t2.micro"
ami_id              = "ami-0dacb0c129b49f529"
web_instance_type   = "t2.micro"
asg_min_size        = "3"
asg_max_size        = "3"
asg_desire_capacity = "3"
db_role             = "db_admin"
db_extension        = "pg_trgm"