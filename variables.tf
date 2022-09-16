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

variable "project_name" {
  type        = string
  description = "the base name to use when creating resources. a randomized suffix will be added."
  default     = "gcp-meanstack-demo"
}

variable "atlas_pub_key" {
  type        = string
  description = "public key for MongoDB Atlas"
}

variable "atlas_priv_key" {
  type        = string
  description = "private key for MongoDB Atlas"
}

variable "atlas_org_id" {
  type        = string
  description = "the ID of your MongoDB Atlas organization"
}

variable "db_name" {
  type        = string
  description = "the name of the database to configure"
  default     = "meanStackExample"
}
