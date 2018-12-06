#!/bin/bash
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


# Vars
source variables.sh

# Enable Google Cloud KMS API
gcloud services enable cloudkms.googleapis.com dataproc.googleapis.com

# Create keyring
gcloud kms keyrings create ${GCE_PD_KMS_KEY_KEYRING} --location=${REGION}

# Create key
gcloud kms keys create ${GCE_PD_KMS_KEY} --purpose=encryption \
  --keyring=${GCE_PD_KMS_KEY_KEYRING} --location=${REGION}

# Create GCS bucket
gsutil mb -p ${PROJECT_ID} -l ${REGION} gs://${BUCKET}/

# Add encryption key to GCS bucket
gsutil kms encryption -k projects/${PROJECT_ID}/locations/${REGION}/keyRings/${GCE_PD_KMS_KEY_KEYRING}/cryptoKeys/${GCE_PD_KMS_KEY} \
  gs://${BUCKET}/

# Set the service account to the same as composer
SERVICE_ACCOUNT=$(gcloud composer environments describe ${COMPOSER_ENV} \
	--location ${REGION} \
	--format="value(config.nodeConfig.serviceAccount)")

# Set the subnetwork to the same as composer
SUBNET=$(gcloud composer environments describe ${COMPOSER_ENV} \
	--location ${REGION} \
	--format="value(config.nodeConfig.subnetwork)")

# Set the project number
PROJECT_NUMBER=$(gcloud projects list --filter=${PROJECT_ID} \
  --format="value(PROJECT_NUMBER)")

# Grant service account permissions to use keys
gcloud kms keys add-iam-policy-binding \
  ${GCE_PD_KMS_KEY} --location ${REGION} --keyring ${GCE_PD_KMS_KEY_KEYRING} \
  --member "serviceAccount:${SERVICE_ACCOUNT}" \
  --role roles/cloudkms.cryptoKeyEncrypterDecrypter

# Grant default service account permissions to use keys
gcloud kms keys add-iam-policy-binding \
  ${GCE_PD_KMS_KEY} --location ${REGION} --keyring ${GCE_PD_KMS_KEY_KEYRING} \
  --member "serviceAccount:service-${PROJECT_NUMBER}@compute-system.iam.gserviceaccount.com" \
  --role roles/cloudkms.cryptoKeyEncrypterDecrypter

# Create DataProc cluster
gcloud dataproc clusters create ${CLUSTER_NAME} \
--no-address \
--bucket=${BUCKET} \
--labels=composer-env=${COMPOSER_ENV} \
--master-boot-disk-size=${MASTER_BOOT_DISK_SIZE} \
--master-machine-type=${MASTER_MACHINE_TYPE} \
--metadata=meta=test,meta=data \
--num-masters=${NUM_MASTERS} \
--region=${REGION} \
--service-account="${SERVICE_ACCOUNT}" \
--worker-boot-disk-size=${WORKER_BOOT_DISK_SIZE} \
--worker-machine-type=${WORKER_MACHINE_TYPE} \
--zone=${ZONE} \
--gce-pd-kms-key=${GCE_PD_KMS_KEY} \
--gce-pd-kms-key-keyring=${GCE_PD_KMS_KEY_KEYRING} \
--gce-pd-kms-key-location=${REGION} \
--gce-pd-kms-key-project=${PROJECT_ID} \
--subnet="${SUBNET}" \
--num-workers=${NUM_WORKERS}
