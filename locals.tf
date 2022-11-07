locals {
  package_url = "https://github.com/mdrxtech/beis-orp-application/archive/refs/tags/v0.0.1.zip"
  downloaded  = "downloaded_package_${md5(local.package_url)}.zip"
}

resource "null_resource" "download_package" {
  triggers = {
    downloaded = local.downloaded
}

provisioner "local-exec" {
  command = "curl -L -o ${local.downloaded} ${local.package_url}"
  }
}

data "null_data_source" "downloaded_package" {
  inputs = {
  id       = null_resource.download_package.id
  filename = local.downloaded
  }
}
