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

variable "zone" {
  description = "The zone in which to create this instance"
  type        = "string"
  default     = "us-central1-a"
}

variable "region" {
  description = "The region in which to create this instance."
  type        = "string"
  default     = "us-central1"
}

variable "project" {
  description = "The name of the GCP project"
  type        = "string"
  default     = "your-project"
}

variable "network" {
  description = "The name of the network"
  type        = "string"
  default     = "composer-network"
}

variable "subnetwork" {
  description = "The name of the subnetwork"
  type        = "string"
  default     = "composer-subnetwork"
}

variable "ip_cidr_range" {
  description = "subnetwork ip_cidr_range"
  type        = "string"
  default     = "10.2.0.0/16"
}

variable "firewall" {
  description = "The name of the firewall"
  type        = "string"
  default     = "composer-firewall"
}

variable "composer_environment" {
  description = "The name of the composer environment"
  type        = "string"
  default     = "terraform-composer"
}

variable "node_count" {
  description = "The number of composer nodes"
  type        = "string"
  default     = "3"
}

variable "machine_type" {
  description = "composer machine_type"
  type        = "string"
  default     = "n1-standard-1"
}