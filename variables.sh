# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#PROJECT_ID=''
#REGION='us-central1'
#ZONE='us-central1-a'
#COMPOSER_ENV='terraform-composer'
#COMPOSER_SUBNETWORK='composer-subnetwork'

# Example for getting vars from terraform output
PROJECT_ID=$(cd composer && terraform output project)
REGION=$(cd composer && terraform output region)
ZONE=$(cd composer && terraform output zone)
COMPOSER_ENV=$(cd composer && terraform output google_composer_environment)
COMPOSER_SUBNETWORK=$(cd composer && terraform output google_compute_subnetwork)

# Example for getting vars from runtime config
KMS_KEY_ID=$(gcloud beta runtime-config configs variables get-value \
  devel/dataproc/default/pd-kms-crypto-key --config-name data-proc-test)

#Dataproc
CLUSTER_NAME='example-internal-cluster'
BUCKET='cmek-testbucket'
MASTER_BOOT_DISK_SIZE='15GB'
MASTER_MACHINE_TYPE='n1-standard-1'
NUM_MASTERS=1
NUM_WORKERS=2
WORKER_BOOT_DISK_SIZE='15GB'
WORKER_MACHINE_TYPE='n1-standard-1'
GCE_PD_KMS_KEY='example-key'
GCE_PD_KMS_KEY_KEYRING='example-keyring'