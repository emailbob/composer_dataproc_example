// Copyright 2018 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

resource "google_project_service" "composer" {
  project = "${var.project}"
  service = "composer.googleapis.com"
}

resource "google_project_service" "runtimeconfig" {
  project = "${var.project}"
  service = "runtimeconfig.googleapis.com"
}

resource "google_composer_environment" "composer" {
  name   = "${var.composer_environment}"
  region = "${var.region}"

  labels {
    env  = "dev"
    role = "composer"
  }

  config {
    node_count = "${var.node_count}"

    node_config {
      zone            = "${var.zone}"
      machine_type    = "${var.machine_type}"
      network         = "${google_compute_network.composer.self_link}"
      subnetwork      = "${google_compute_subnetwork.composer.self_link}"
      service_account = "${google_service_account.composer.name}"
    }
  }

  depends_on = ["google_project_iam_member.composer-worker", "google_project_iam_member.dataproc-editor",
    "google_project_iam_member.dataproc-worker",
    "google_project_iam_member.cloudkms-cryptoKeyEncrypterDecrypter",
  ]
}

resource "google_compute_network" "composer" {
  name                    = "${var.network}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "composer" {
  name                     = "${var.subnetwork}"
  ip_cidr_range            = "${var.ip_cidr_range}"
  region                   = "${var.region}"
  network                  = "${google_compute_network.composer.self_link}"
  private_ip_google_access = true
}

resource "google_compute_firewall" "composer" {
  name          = "${var.firewall}"
  network       = "${google_compute_network.composer.name}"
  source_ranges = ["${var.ip_cidr_range}"]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["1-65535"]
  }
}

resource "google_service_account" "composer" {
  account_id   = "composer-service-account"
  display_name = "Test Service Account for Composer Environment"
}

resource "google_project_iam_member" "composer-worker" {
  role   = "roles/composer.worker"
  member = "serviceAccount:${google_service_account.composer.email}"
}

resource "google_project_iam_member" "dataproc-editor" {
  role   = "roles/dataproc.editor"
  member = "serviceAccount:${google_service_account.composer.email}"
}

resource "google_project_iam_member" "dataproc-worker" {
  role   = "roles/dataproc.worker"
  member = "serviceAccount:${google_service_account.composer.email}"
}

resource "google_project_iam_member" "cloudkms-cryptoKeyEncrypterDecrypter" {
  role   = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member = "serviceAccount:${google_service_account.composer.email}"
}
