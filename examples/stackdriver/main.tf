/**
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

provider "google" {
  version = "~> 2.15.0"
}

resource "random_string" "suffix" {
  length  = 4
  special = "false"
  upper   = "false"
}

resource "google_compute_network" "default" {
  name                    = "example-network-${random_string.suffix.result}"
  auto_create_subnetworks = "false"
  project                 = var.project_id
}

resource "google_compute_subnetwork" "main" {
  project       = var.project_id
  region        = "us-central1"
  name          = "example-subnetwork-${random_string.suffix.result}"
  ip_cidr_range = "10.128.0.0/20"
  network       = google_compute_network.default.self_link
}

module "gsuite-export" {
  source          = "../../"
  service_account = var.service_account
  api             = "reports_v1"
  applications    = ["login", "drive", "token"]
  admin_user      = "superadmin@domain.com"
  project_id      = var.project_id
  machine_name    = "gsuite-exporter-simple"
  machine_network = google_compute_network.default.self_link
}
