variable "loc" {
    description = "Default Azure region"
    default     =   "westus2"
}

variable "tags" {
    default     = {
        source  = "citadel"
        env     = "training"
    }
}
