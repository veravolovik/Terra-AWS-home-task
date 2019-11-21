provider "postgresql" {
  host            = aws_db_instance.postgresql.address
  port            = var.db_port
  database        = "postgres"
  username        = "dbadmin"
  password        = "changeme"
  sslmode         = "disable"
  connect_timeout = 30
}

resource "postgresql_role" "db_admin" {
  name = "db_admin"
}

resource "postgresql_extension" "extention" {
  name = "pg_trgm"
}
