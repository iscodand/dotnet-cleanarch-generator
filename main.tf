terraform {
  required_version = ">= 1.0"
}

locals {
  project_name       = var.project_name
  project_name_lower = lower(var.project_name)
  src                = "${var.output_path}/src"
  tests              = "${var.output_path}/tests"

  guid_domain         = "A1B2C3D4-E5F6-7890-ABCD-EF1234567801"
  guid_application    = "A1B2C3D4-E5F6-7890-ABCD-EF1234567802"
  guid_infra_data     = "A1B2C3D4-E5F6-7890-ABCD-EF1234567803"
  guid_infra_identity = "A1B2C3D4-E5F6-7890-ABCD-EF1234567804"
  guid_infra_shared   = "A1B2C3D4-E5F6-7890-ABCD-EF1234567805"
  guid_infra_ioc      = "A1B2C3D4-E5F6-7890-ABCD-EF1234567806"
  guid_webapi         = "A1B2C3D4-E5F6-7890-ABCD-EF1234567807"
  guid_unit_tests     = "A1B2C3D4-E5F6-7890-ABCD-EF1234567808"
  guid_int_tests      = "A1B2C3D4-E5F6-7890-ABCD-EF1234567809"
  guid_src_folder     = "A1B2C3D4-E5F6-7890-ABCD-EF123456780A"
  guid_tests_folder   = "A1B2C3D4-E5F6-7890-ABCD-EF123456780B"

  template_vars = {
    project_name       = local.project_name
    project_name_lower = local.project_name_lower
    dotnet_version     = var.dotnet_version
    database_port      = var.database_port
  }

  sln_tests_section = var.include_tests ? join("\n", [
    "Project(\"{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}\") = \"${var.project_name}.UnitTests\", \"tests\\${var.project_name}.UnitTests\\${var.project_name}.UnitTests.csproj\", \"{${local.guid_unit_tests}}\"",
    "EndProject",
    "Project(\"{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}\") = \"${var.project_name}.IntegrationTests\", \"tests\\${var.project_name}.IntegrationTests\\${var.project_name}.IntegrationTests.csproj\", \"{${local.guid_int_tests}}\"",
    "EndProject",
  ]) : ""

  sln_tests_folder_section = var.include_tests ? join("\n", [
    "Project(\"{2150E333-8FDC-42A3-9474-1A3956D46DE8}\") = \"tests\", \"tests\", \"{${local.guid_tests_folder}}\"",
    "EndProject",
  ]) : ""

  sln_tests_config_section = var.include_tests ? join("\n", [
    "    {${local.guid_unit_tests}}.Debug|Any CPU.ActiveCfg = Debug|Any CPU",
    "    {${local.guid_unit_tests}}.Debug|Any CPU.Build.0 = Debug|Any CPU",
    "    {${local.guid_unit_tests}}.Release|Any CPU.ActiveCfg = Release|Any CPU",
    "    {${local.guid_unit_tests}}.Release|Any CPU.Build.0 = Release|Any CPU",
    "    {${local.guid_int_tests}}.Debug|Any CPU.ActiveCfg = Debug|Any CPU",
    "    {${local.guid_int_tests}}.Debug|Any CPU.Build.0 = Debug|Any CPU",
    "    {${local.guid_int_tests}}.Release|Any CPU.ActiveCfg = Release|Any CPU",
    "    {${local.guid_int_tests}}.Release|Any CPU.Build.0 = Release|Any CPU",
  ]) : ""

  sln_tests_nested_section = var.include_tests ? join("\n", [
    "    {${local.guid_unit_tests}} = {${local.guid_tests_folder}}",
    "    {${local.guid_int_tests}} = {${local.guid_tests_folder}}",
  ]) : ""

  solution_vars = merge(local.template_vars, {
    guid_domain         = local.guid_domain
    guid_application    = local.guid_application
    guid_infra_data     = local.guid_infra_data
    guid_infra_identity = local.guid_infra_identity
    guid_infra_shared   = local.guid_infra_shared
    guid_infra_ioc      = local.guid_infra_ioc
    guid_webapi         = local.guid_webapi
    guid_unit_tests     = local.guid_unit_tests
    guid_int_tests      = local.guid_int_tests
    guid_src_folder     = local.guid_src_folder
    guid_tests_folder   = local.guid_tests_folder

    tests_section        = local.sln_tests_section
    tests_folder_section = local.sln_tests_folder_section
    tests_config_section = local.sln_tests_config_section
    tests_nested_section = local.sln_tests_nested_section
  })
}

# =============================================================================
# Solution
# =============================================================================

resource "local_file" "solution" {
  filename = "${var.output_path}/${var.project_name}.sln"
  content  = templatefile("${path.module}/templates/solution.tftpl", local.solution_vars)
}

resource "local_file" "gitignore" {
  filename = "${var.output_path}/.gitignore"
  content  = templatefile("${path.module}/templates/gitignore.tftpl", local.template_vars)
}

resource "local_file" "editorconfig" {
  filename = "${var.output_path}/.editorconfig"
  content  = templatefile("${path.module}/templates/editorconfig.tftpl", local.template_vars)
}

# =============================================================================
# Domain
# =============================================================================

resource "local_file" "domain_csproj" {
  filename = "${local.src}/${var.project_name}.Domain/${var.project_name}.Domain.csproj"
  content  = templatefile("${path.module}/templates/domain/csproj.tftpl", local.template_vars)
}

resource "local_file" "domain_base_entity" {
  filename = "${local.src}/${var.project_name}.Domain/Entities/BaseEntity.cs"
  content  = templatefile("${path.module}/templates/domain/base_entity.tftpl", local.template_vars)
}

resource "local_file" "domain_repository_interface" {
  filename = "${local.src}/${var.project_name}.Domain/Interfaces/IRepository.cs"
  content  = templatefile("${path.module}/templates/domain/repository_interface.tftpl", local.template_vars)
}

resource "local_file" "domain_unit_of_work_interface" {
  filename = "${local.src}/${var.project_name}.Domain/Interfaces/IUnitOfWork.cs"
  content  = templatefile("${path.module}/templates/domain/unit_of_work_interface.tftpl", local.template_vars)
}

resource "local_file" "domain_exceptions" {
  filename = "${local.src}/${var.project_name}.Domain/Exceptions/DomainExceptions.cs"
  content  = templatefile("${path.module}/templates/domain/exceptions.tftpl", local.template_vars)
}

# =============================================================================
# Application
# =============================================================================

resource "local_file" "application_csproj" {
  filename = "${local.src}/${var.project_name}.Application/${var.project_name}.Application.csproj"
  content  = templatefile("${path.module}/templates/application/csproj.tftpl", local.template_vars)
}

resource "local_file" "application_interfaces" {
  filename = "${local.src}/${var.project_name}.Application/Interfaces/IApplicationDbContext.cs"
  content  = templatefile("${path.module}/templates/application/interfaces.tftpl", local.template_vars)
}

resource "local_file" "application_result" {
  filename = "${local.src}/${var.project_name}.Application/Common/Result.cs"
  content  = templatefile("${path.module}/templates/application/result.tftpl", local.template_vars)
}

resource "local_file" "application_service_registration" {
  filename = "${local.src}/${var.project_name}.Application/ServiceRegistration.cs"
  content  = templatefile("${path.module}/templates/application/service_registration.tftpl", local.template_vars)
}

# =============================================================================
# Infrastructure.Data
# =============================================================================

resource "local_file" "infra_data_csproj" {
  filename = "${local.src}/${var.project_name}.Infrastructure.Data/${var.project_name}.Infrastructure.Data.csproj"
  content  = templatefile("${path.module}/templates/infrastructure_data/csproj.tftpl", local.template_vars)
}

resource "local_file" "infra_data_context" {
  filename = "${local.src}/${var.project_name}.Infrastructure.Data/Context/ApplicationDbContext.cs"
  content  = templatefile("${path.module}/templates/infrastructure_data/context.tftpl", local.template_vars)
}

resource "local_file" "infra_data_repository" {
  filename = "${local.src}/${var.project_name}.Infrastructure.Data/Repositories/GenericRepository.cs"
  content  = templatefile("${path.module}/templates/infrastructure_data/repository.tftpl", local.template_vars)
}

resource "local_file" "infra_data_unit_of_work" {
  filename = "${local.src}/${var.project_name}.Infrastructure.Data/Repositories/UnitOfWork.cs"
  content  = templatefile("${path.module}/templates/infrastructure_data/unit_of_work.tftpl", local.template_vars)
}

resource "local_file" "infra_data_interceptor" {
  filename = "${local.src}/${var.project_name}.Infrastructure.Data/Interceptors/AuditableEntityInterceptor.cs"
  content  = templatefile("${path.module}/templates/infrastructure_data/interceptor.tftpl", local.template_vars)
}

# =============================================================================
# Infrastructure.Identity
# =============================================================================

resource "local_file" "infra_identity_csproj" {
  filename = "${local.src}/${var.project_name}.Infrastructure.Identity/${var.project_name}.Infrastructure.Identity.csproj"
  content  = templatefile("${path.module}/templates/infrastructure_identity/csproj.tftpl", local.template_vars)
}

resource "local_file" "infra_identity_application_user" {
  filename = "${local.src}/${var.project_name}.Infrastructure.Identity/Models/ApplicationUser.cs"
  content  = templatefile("${path.module}/templates/infrastructure_identity/application_user.tftpl", local.template_vars)
}

resource "local_file" "infra_identity_context" {
  filename = "${local.src}/${var.project_name}.Infrastructure.Identity/Context/IdentityContext.cs"
  content  = templatefile("${path.module}/templates/infrastructure_identity/identity_context.tftpl", local.template_vars)
}

resource "local_file" "infra_identity_jwt_settings" {
  filename = "${local.src}/${var.project_name}.Infrastructure.Identity/Configuration/JwtSettings.cs"
  content  = templatefile("${path.module}/templates/infrastructure_identity/jwt_settings.tftpl", local.template_vars)
}

resource "local_file" "infra_identity_token_service" {
  filename = "${local.src}/${var.project_name}.Infrastructure.Identity/Services/TokenService.cs"
  content  = templatefile("${path.module}/templates/infrastructure_identity/token_service.tftpl", local.template_vars)
}

resource "local_file" "infra_identity_auth_service" {
  filename = "${local.src}/${var.project_name}.Infrastructure.Identity/Services/AuthService.cs"
  content  = templatefile("${path.module}/templates/infrastructure_identity/auth_service.tftpl", local.template_vars)
}

# =============================================================================
# Infrastructure.Shared
# =============================================================================

resource "local_file" "infra_shared_csproj" {
  filename = "${local.src}/${var.project_name}.Infrastructure.Shared/${var.project_name}.Infrastructure.Shared.csproj"
  content  = templatefile("${path.module}/templates/infrastructure_shared/csproj.tftpl", local.template_vars)
}

# =============================================================================
# Infrastructure.Ioc
# =============================================================================

resource "local_file" "infra_ioc_csproj" {
  filename = "${local.src}/${var.project_name}.Infrastructure.Ioc/${var.project_name}.Infrastructure.Ioc.csproj"
  content  = templatefile("${path.module}/templates/infrastructure_ioc/csproj.tftpl", local.template_vars)
}

resource "local_file" "infra_ioc_dependency_injection" {
  filename = "${local.src}/${var.project_name}.Infrastructure.Ioc/DependencyInjection.cs"
  content  = templatefile("${path.module}/templates/infrastructure_ioc/dependency_injection.tftpl", local.template_vars)
}

# =============================================================================
# WebApi
# =============================================================================

resource "local_file" "webapi_csproj" {
  filename = "${local.src}/${var.project_name}.WebApi/${var.project_name}.WebApi.csproj"
  content  = templatefile("${path.module}/templates/webapi/csproj.tftpl", local.template_vars)
}

resource "local_file" "webapi_program" {
  filename = "${local.src}/${var.project_name}.WebApi/Program.cs"
  content  = templatefile("${path.module}/templates/webapi/program.tftpl", local.template_vars)
}

resource "local_file" "webapi_base_controller" {
  filename = "${local.src}/${var.project_name}.WebApi/Controllers/BaseController.cs"
  content  = templatefile("${path.module}/templates/webapi/base_controller.tftpl", local.template_vars)
}

resource "local_file" "webapi_middleware" {
  filename = "${local.src}/${var.project_name}.WebApi/Middleware/ExceptionHandlingMiddleware.cs"
  content  = templatefile("${path.module}/templates/webapi/middleware.tftpl", local.template_vars)
}

resource "local_file" "webapi_appsettings" {
  filename = "${local.src}/${var.project_name}.WebApi/appsettings.json"
  content  = templatefile("${path.module}/templates/webapi/appsettings.tftpl", local.template_vars)
}

resource "local_file" "webapi_appsettings_dev" {
  filename = "${local.src}/${var.project_name}.WebApi/appsettings.Development.json"
  content  = templatefile("${path.module}/templates/webapi/appsettings_dev.tftpl", local.template_vars)
}

# =============================================================================
# Tests (conditional)
# =============================================================================

resource "local_file" "unit_tests_csproj" {
  count    = var.include_tests ? 1 : 0
  filename = "${local.tests}/${var.project_name}.UnitTests/${var.project_name}.UnitTests.csproj"
  content  = templatefile("${path.module}/templates/tests/unit_csproj.tftpl", local.template_vars)
}

resource "local_file" "integration_tests_csproj" {
  count    = var.include_tests ? 1 : 0
  filename = "${local.tests}/${var.project_name}.IntegrationTests/${var.project_name}.IntegrationTests.csproj"
  content  = templatefile("${path.module}/templates/tests/integration_csproj.tftpl", local.template_vars)
}

# =============================================================================
# Docker (conditional)
# =============================================================================

resource "local_file" "dockerfile" {
  count    = var.include_docker ? 1 : 0
  filename = "${var.output_path}/docker/Dockerfile"
  content  = templatefile("${path.module}/templates/docker/dockerfile.tftpl", local.template_vars)
}

resource "local_file" "docker_compose" {
  count    = var.include_docker ? 1 : 0
  filename = "${var.output_path}/docker/docker-compose.yml"
  content  = templatefile("${path.module}/templates/docker/docker_compose.tftpl", local.template_vars)
}

# =============================================================================
# CI/CD (conditional)
# =============================================================================

resource "local_file" "ci_workflow" {
  count    = var.include_ci_cd ? 1 : 0
  filename = "${var.output_path}/.github/workflows/ci.yml"
  content  = templatefile("${path.module}/templates/ci_cd/ci.tftpl", local.template_vars)
}

resource "local_file" "cd_workflow" {
  count    = var.include_ci_cd ? 1 : 0
  filename = "${var.output_path}/.github/workflows/cd.yml"
  content  = templatefile("${path.module}/templates/ci_cd/cd.tftpl", local.template_vars)
}
