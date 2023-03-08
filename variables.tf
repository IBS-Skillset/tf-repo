variable "db_name" {
  default = "aurora_instance_db"
}
variable "allocated_storage" {
  default = 10
}
variable "engine_version" {
  default = "5.6.10a"
}
variable "tags" {
  Environment: "RnD"
  Project: "Skillset"
  Name: "HappyStays"
  CostCenter: "CDx"
}
variable "scaling_configuration" {
  auto_pause = true
  max_capacity = 4
  min_capacity = 2

}