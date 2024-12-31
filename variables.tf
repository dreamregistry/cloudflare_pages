variable "dream_env" {
  description = "dream app environment variables to set"
  type        = any
  default     = {}
}

variable "dream_project_dir" {
  description = "root directory of the project sources"
  type        = string
}

variable "d1_databases" {
  description = "d1 database name"
  type = set(string)
  default = {}
}