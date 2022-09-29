# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

provider "google" {}

resource "google_project" "prj" {
  project_id      = local.project_id
  name            = local.project_id
  billing_account = var.google_billing_account

  lifecycle {
    # ignoring org_id changes allows the project to be created in whatever org
    # the user is part of by default, without having to explicitly include the
    # org id in the terraform config. is this a problem waiting to happen? only
    # time will tell.
    ignore_changes = [org_id]
  }
}

resource "google_project_service" "svc" {
  project = google_project.prj.name
  service = "${each.value}.googleapis.com"

  for_each = toset([
    "run",
    "compute",
  ])
}

resource "google_cloud_run_service" "app" {

  for_each = var.google_cloud_regions
    
  project = google_project.prj.name

  name     = "demo"
  location = each.value

  template {
    spec {
      containers {
        image = var.app_image

        env {
          name  = "ATLAS_URI"
          value = local.atlas_uri
        }
      }
    }
  }

  depends_on = [google_project_service.svc["run"]]
}

resource "google_cloud_run_service_iam_binding" "app" {
  
  for_each = google_cloud_run_service.app

  location = each.value.location
  project  = each.value.project
  service  = each.value.name

  role    = "roles/run.invoker"
  members = ["allUsers"]
}

module "lb-http" {
  
  source  = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version = "~> 6.3"
  name    = var.lb_name
  project = google_project.prj.name

  backends = {
    default = {
      description = null
      groups = [
        for neg in google_compute_region_network_endpoint_group.serverless-neg: {
        group = neg.id
        }
      ]
      enable_cdn              = false
      security_policy         = null
      custom_request_headers  = null
      custom_response_headers = null

      iap_config = {
        enable               = false
        oauth2_client_id     = ""
        oauth2_client_secret = ""
      }
      log_config = {
        enable      = false
        sample_rate = null
      }
    }
  }

  depends_on = [google_project_service.svc["compute"]]
}


resource "google_compute_region_network_endpoint_group" "serverless-neg" {

 for_each = var.google_cloud_regions
  
  provider              = google-beta
  name                  = "serverless-neg"
  network_endpoint_type = "SERVERLESS"
  region                = each.value
  project = google_project.prj.name
  
  cloud_run {
    service = google_cloud_run_service.app[each.key].name
  }

  depends_on = [google_project_service.svc["compute"]]
}