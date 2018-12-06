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

#Update airflow admin->variables (variables have to be passed one at a time)
gcloud composer environments run terraform-composer \
     --location ${REGION} variables -- \
     --set gcp_project ${PROJECT_ID}

gcloud composer environments run terraform-composer \
     --location ${REGION} variables -- \
     --set gcs_bucket ${BUCKET}

gcloud composer environments run terraform-composer \
     --location ${REGION} variables -- \
     --set gce_zone ${ZONE}

gcloud composer environments run terraform-composer \
     --location ${REGION} variables -- \
     --set gce_region ${REGION}

gcloud composer environments run terraform-composer \
     --location ${REGION} variables -- \
     --set dataproc_cluster_name ${CLUSTER_NAME}

gcloud composer environments run terraform-composer \
     --location ${REGION} variables -- \
     --set cmek_resource_id projects/${PROJECT_ID}/locations/${REGION}/keyRings/${GCE_PD_KMS_KEY_KEYRING}/cryptoKeys/${GCE_PD_KMS_KEY}

gcloud composer environments run terraform-composer \
     --location ${REGION} variables -- \
     --set gce_subnetwork https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/regions/${REGION}/subnetworks/${COMPOSER_SUBNETWORK}

# Upload dependencies
gcloud composer environments storage dags import \
    --environment ${COMPOSER_ENV} \
    --location ${REGION} \
    --source './example_dags/dependencies'

# Upload DAG example_create_dataproc
gcloud composer environments storage dags import \
    --environment ${COMPOSER_ENV} \
    --location ${REGION} \
    --source 'example_dags/example_create_dataproc.py'

# Upload DAG example_existing_dataproc
gcloud composer environments storage dags import \
    --environment ${COMPOSER_ENV} \
    --location ${REGION} \
    --source 'example_dags/example_existing_dataproc.py'

# Upload DAG example_gcp_api
gcloud composer environments storage dags import \
    --environment ${COMPOSER_ENV} \
    --location ${REGION} \
    --source 'example_dags/example_gcp_api.py'

airflowUri=$(gcloud composer environments describe ${COMPOSER_ENV} \
  --location ${REGION} \
  --format='get(config.airflowUri)')

dagBucket=$(gcloud composer environments describe ${COMPOSER_ENV} \
  --location ${REGION} \
  --format='get(config.dagGcsPrefix)')

echo "Airflow dag GCS bucket: ${dagBucket}"

echo "To access the airflow UI go to ${airflowUri}"