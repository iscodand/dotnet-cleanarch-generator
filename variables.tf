variable "project_name" {
  description = "Project name (used as namespace and prefix). Ex: MyApp -> MyApp.Domain, MyApp.WebApi"
  type        = string

  validation {
    condition     = can(regex("^[A-Z][a-zA-Z0-9]+$", var.project_name))
    error_message = "project_name must be start with Capital Letter and contains just letters and numbers (PascalCase)."
  }
}

variable "dotnet_version" {
  description = ".NET SDK version."
  type        = string
  default     = "10.0"
}

variable "output_path" {
  description = "Directory where the project will be created."
  type        = string
  default     = "./output"
}

variable "include_docker" {
  description = "Include dockerfile and docker-compose settings."
  type        = bool
  default     = true
}

variable "include_ci_cd" {
  description = "Include github actions workflows."
  type        = bool
  default     = true
}

variable "include_tests" {
  description = "Include test projects. (Unit and Integration)."
  type        = bool
  default     = true
}

variable "database_port" {
  description = "PostgreSQL Port for docker-compose."
  type        = number
  default     = 5432
}
