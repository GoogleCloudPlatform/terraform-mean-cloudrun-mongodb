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

provider "mongodbatlas" {
  public_key  = var.atlas_pub_key
  private_key = var.atlas_priv_key
}

resource "mongodbatlas_project" "demo" {
  name   = local.project_id
  org_id = var.atlas_org_id
}

resource "mongodbatlas_project_ip_access_list" "acl" {
  project_id = mongodbatlas_project.demo.id
  cidr_block = "0.0.0.0/0"
}

resource "mongodbatlas_cluster" "cluster" {
  project_id = mongodbatlas_project.demo.id
  name       = local.project_id

  provider_name               = "TENANT"
  backing_provider_name       = "GCP"
  provider_region_name        = var.atlas_cluster_region
  provider_instance_size_name = var.atlas_cluster_tier
}

resource "mongodbatlas_database_user" "user" {
  project_id         = mongodbatlas_project.demo.id
  auth_database_name = "admin"

  username = var.db_user
  password = random_string.mongodb_password.result

  roles {
    role_name     = "readWrite"
    database_name = var.db_name
  }
}

locals {
  # the demo app only takes URIs with the credentials embedded and the atlas
  # provider doesn't give us a good way to get the hostname without the protocol
  # part so we end up doing some slicing and dicing to get the creds into the URI
  atlas_uri = replace(
    mongodbatlas_cluster.cluster.srv_address,
    "://",
    "://${var.db_user}:${mongodbatlas_database_user.user.password}@"
  )
}
