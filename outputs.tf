output "project_path" {
  description = "Full path of the generated project"
  value       = var.output_path
}

output "solution_file" {
  description = "Path to the .sln file"
  value       = "${var.output_path}/${var.project_name}.sln"
}

output "next_steps" {
  description = "Next steps after generating the project"
  value       = <<-EOT
    Project '${var.project_name}' successfully generated at '${var.output_path}'!

    Next steps:
      cd ${var.output_path}
      dotnet restore
      dotnet build

    To run with Docker:
      docker-compose -f docker/docker-compose.yml up -d

    To run tests:
      dotnet test
  EOT
}
