resource "azurerm_resource_group" "webapps" {
  name     = "webapps"
  location = "${var.loc}"
  tags     = "${var.tags}"
}

resource "random_string" "webapprnd" {
  length  = 8
  lower   = true
  number  = true
  upper   = true
  special = true
}

resource "azurerm_app_service_plan" "free" {
  count               = "${length(var.webapplocs)}"
  name                = "plan-free-${var.webapplocs[count.index]}"
  location            = "${var.webapplocs[count.index]}"
  resource_group_name = "${azurerm_resource_group.webapps.name}"
  tags                = "${azurerm_resource_group.webapps.tags}"

  kind     = "Linux"
  reserved = true
  sku {
    tier = "Free"
    size = "F1"
  }
}

//element(recurso.*.id, count.index) < Accede a un unico recurso de los creados a traves de un count. 
resource "azurerm_app_service" "citadel" {
  count               = "${length(var.webapplocs)}"
  name                = "webapp-${random_string.webapprnd.result}-${var.loc}"
  location            = "${var.loc}"
  resource_group_name = "${azurerm_resource_group.webapps.name}"
  tags                = "${azurerm_resource_group.webapps.tags}"

  app_service_plan_id = "${element(azurerm_app_service_plan.free.*.id, count.index)}"
}

//Se pueden usar variables de ambiente, con el prefijo TF_VAR_<variable>
output "webapps_ids" {
  description = "ids of the web apps provisoned"
  value = "${azurerm_app_service.citadel.*.id}"
}
