provider "rundeck" {
  url         = "rundeck_url"
  api_version = "34"
  auth_token  = "auth-token-here"
}

resource "rundeck_project" "anvils" {
  name        = "anvils"
  description = "Application for managing Anvils"

  #ssh_key_storage_path = rundeck_private_key.anvils.path
  resource_model_source {
    type = "local"
    config = {

    }
  }

  resource_model_source {
    type = "com.batix.rundeck.plugins.AnsibleResourceModelSourceFactory"

    config = {
      format                   = "resourcexml"
      ansible-gather-facts     = "true"
      ansible-ignore-errors    = "true"
      ansible-config-file-path = "/ansible/config/path"
      ansible-inventory        = "/ansible/inventory/path"
    }
  }
  extra_config = {
    "project/jobs/gui/groupExpandLevel" = "1"
  }
}

resource "rundeck_job" "bounceweb" {
  name              = "Bounce Web Servers"
  project_name      = rundeck_project.anvils.name
  node_filter_query = "tags: web"
  description       = "Restart the service daemons on all the web servers"

  command {
    shell_command = "sudo service anvils restart"
  }
}

resource "rundeck_private_key" "anvils" {
  path         = "anvils/secret"
  key_material = "test"
}
