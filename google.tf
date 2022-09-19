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
  project = local.project_id
  service = "${each.value}.googleapis.com"

  for_each = toset([
    "run",
  ])
}

resource "google_cloud_run_service" "app" {
  project = google_project.prj.name

  name     = "demo"
  location = var.google_cloud_region

  template {
    spec {
      containers {
        image = var.app_image

        env {
          name  = "ATLAS_URI"
          value = local.atlas_uri
        }

        # ports {
        #   container_port = 5200
        # }
      }
    }
  }
}

resource "google_cloud_run_service_iam_binding" "app" {
  location = google_cloud_run_service.app.location
  project  = google_cloud_run_service.app.project
  service  = google_cloud_run_service.app.name

  role    = "roles/run.invoker"
  members = ["allUsers"]
}
