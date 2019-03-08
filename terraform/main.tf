provider "azuread" {
  version = "=0.1.0"
}

variable "environment_list" {
  description = "Environment ID"
  type        = "list"
  default     = ["staging", "prod"]
}

variable "env" {
  description = "Which environment? (options: staging, prod):"
}

resource "null_resource" "is_environment_name_valid" {
  count                                             = "${contains(var.environment_list, var.env) == true ? 0 : 1}"
  "ERROR: The env value can only be: staging, prod" = true
}

data "http" "localIp" {
  url = "http://ipv4.icanhazip.com"
}

resource "azurerm_resource_group" "rg" {
  name     = "website-v2-${var.env}-unc-rg"
  location = "North Central US"
}

resource "azurerm_app_service_plan" "asp" {
  name                = "website-v2-${var.env}-unc-asp"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "app" {
  name                = "website-v2-${var.env}-unc-app"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  app_service_plan_id = "${azurerm_app_service_plan.asp.id}"
}

resource "azurerm_application_insights" "test" {
  name                = "website-v2-${var.env}-ue-appi"
  location            = "East US"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  application_type    = "Web"
}

resource "random_string" "mysql_admin_pass" {
  length  = 16
  special = true
}

resource "random_string" "mysql_user_pass" {
  length  = 16
  special = true
}

resource "azurerm_mysql_server" "mysql" {
  name                = "website-v2-${var.env}-unc-mysql"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  sku {
    name     = "B_Gen5_1"
    capacity = 1
    tier     = "Basic"
    family   = "Gen5"
  }

  storage_profile {
    storage_mb            = 5120
    backup_retention_days = 7
    geo_redundant_backup  = "Disabled"
  }

  administrator_login          = "mysqladmin"
  administrator_login_password = "${random_string.mysql_admin_pass.result}"
  version                      = "5.7"
  ssl_enforcement              = "disabled"
}

resource "azurerm_mysql_firewall_rule" "mysql_firewall" {
  name                = "localIP"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  server_name         = "${azurerm_mysql_server.mysql.name}"
  start_ip_address    = "${chomp(data.http.localIp.body)}"
  end_ip_address      = "${chomp(data.http.localIp.body)}"
}

resource "azurerm_mysql_database" "mysql_db" {
  name                = "wordpress"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  server_name         = "${azurerm_mysql_server.mysql.name}"
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

output "mysql_admin_username" {
  value = "${azurerm_mysql_server.mysql.administrator_login}"
}

output "mysql_admin_password" {
  value = "${azurerm_mysql_server.mysql.administrator_login_password}"
}

output "mysql_server" {
  value = "${azurerm_mysql_server.mysql.name}.mysql.database.azure.com"
}

output "mysql_user_password" {
  value = "${random_string.mysql_user_pass.result}"
}
