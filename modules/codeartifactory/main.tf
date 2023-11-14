# Create CodeArtifactory
resource "aws_kms_key" "domain_key" {
  description = var.artifact_domain_key
}

resource "aws_codeartifact_domain" "artifact_domain" {
  domain         = var.artifact_domain
  encryption_key = aws_kms_key.domain_key.arn
}

resource "aws_codeartifact_repository" "maven_artifact_repository" {
  repository = var.maven_artifact_repository_name
  domain     = aws_codeartifact_domain.artifact_domain.domain

  external_connections {
    external_connection_name = "public:maven-central"
  }
}

resource "aws_codeartifact_repository" "npm_artifact_repository" {
  repository = var.npm_artifact_repository_name
  domain     = aws_codeartifact_domain.artifact_domain.domain

  external_connections {
    external_connection_name = "public:npmjs"
  }
}