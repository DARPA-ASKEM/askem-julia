variable "DOCKER_REGISTRY" {
  default = "ghcr.io"
}
variable "DOCKER_ORG" {
  default = "darpa-askem"
}
variable "VERSION" {
  default = "local"
}

# ----------------------------------------------------------------------------------------------------------------------

function "tag" {
  params = [image_name, prefix, suffix]
  result = [ "${gen_image_name(image_name)}:${check_prefix(prefix)}${VERSION}${check_suffix(suffix)}" ]
}

function "check_prefix" {
  params = [tag]
  result = notequal("",tag) ? "${tag}-": ""
}

function "check_suffix" {
  params = [tag]
  result = notequal("",tag) ? "-${tag}": ""
}

function "gen_image_name" {
  params = [image_name]
  result = "${DOCKER_REGISTRY}/${DOCKER_ORG}/${image_name}"
}

# ----------------------------------------------------------------------------------------------------------------------
group "prod" {
  targets = ["askem-julia"]
}

group "default" {
  targets = ["askem-julia-base"]
}

# ----------------------------------------------------------------------------------------------------------------------
# Used by the metafile GH action
# DO NOT ADD ANYTHING HERE THIS WILL BE POPULATED DYNAMICALLY
# MAKE SURE THIS IS INHERITED NEAR THE END SO THAT IT DOES NOT GET OVERRIDEN
target "docker-metadata-action" {}

target "_platforms" {
  platforms = ["linux/amd64", "linux/arm64"]
}

target "askem-julia-base" {
  context = "."
  dockerfile = "docker/Dockerfile"
  tags = tag("askem-julia", "", "")
}

# NOTE: This is the target that CI will trigger and the metadata action will override image names
target "askem-julia" {
  inherits = ["askem-julia-base", "docker-metadata-action", "_platforms"]
}

