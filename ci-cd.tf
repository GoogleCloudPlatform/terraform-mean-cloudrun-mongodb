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

resource "google_project_service" "ci_cd" {
  project = google_project.prj.name
  service = "${each.value}.googleapis.com"

  for_each = toset([
    "artifactregistry",
    "sourcerepo",
    "storage",
  ])
}

resource "google_artifact_registry_repository" "repo" {
  project  = google_project.prj.name
  location = var.google_cloud_region

  repository_id = "repo"
  format        = "DOCKER"

  depends_on = [google_project_service.ci_cd["artifactregistry"]]
}

locals {
  image_path = "${var.google_cloud_region}-docker.pkg.dev/${google_project.prj.name}/${google_artifact_registry_repository.repo.name}/demo"
}

resource "google_sourcerepo_repository" "repo" {
  project = google_project.prj.name
  name    = "repo"

  depends_on = [google_project_service.ci_cd["sourcerepo"]]
}
