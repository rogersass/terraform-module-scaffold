module "scaffold" {
  source    = "./terraform-module-scaffold"
}
resource "random_string" "webapprnd" {
  length  = 8
  lower   = true
  number  = true
  upper   = false
  special = false
}

resource "azurerm_resource_group" "webapps" {
   name     = "webapps"
   location = var.loc
   tags     = var.tags
}

resource "azurerm_app_service_plan" "free" {
    count               = length(var.webapplocs)
    name                = "plan-free-${var.webapplocs[count.index]}"
    location            = var.webapplocs[count.index]
    resource_group_name = azurerm_resource_group.webapps.name
    tags                = azurerm_resource_group.webapps.tags
    kind                = "Linux"
    reserved            = true
    sku {
        tier = "Free"
        size = "F1"
    }
}

resource "azurerm_app_service" "citadel" {
    # count               = length(var.webapplocs)
    count               = length(var.webapplocs) * local.webappsperloc
    # name                = "webapp-${random_string.webapprnd.result}-${var.webapplocs[count.index]}"
    name                = "${format("webapp-%s-%02d-%s", random_string.webapprnd.result, count.index + 1, element(var.webapplocs, count.index))}"
    # location            = var.webapplocs[count.index]
    location            = "${element(var.webapplocs, count.index)}"
    resource_group_name = azurerm_resource_group.webapps.name
    tags                = azurerm_resource_group.webapps.tags
    app_service_plan_id = "${element(azurerm_app_service_plan.free.*.id, count.index)}"
}

locals {
    webappsperloc = 2
}

output "webapp_ids" {
    value = "${azurerm_app_service.citadel.*.id}"
}