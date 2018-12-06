This example shows how to create a Composer environment using Terraform and a
Dataproc cluster using gcloud commands. I did't use Terraform for the Dataproc
since it doesn't support creating a cluster that uses customer mangaed keys yet.

The files in example_dags/dependencies are required until Composer uses the
Airflow version that includes the changes in
https://github.com/apache/incubator-airflow/pull/4200

# Create Composer environment
Creates an internal Composer environment in a seperate network and subnetwork
with a service account.

cd composer
terraform apply

# Create Dataproc cluster
Creates customer managed keys and GCS bucket. Gets the serivce account and
subnetwork values from the Composer environment and passes them to be used to
create a internal Dataproc cluster.

Look at variables.sh and update the PROJECT_ID. Also feel free to make any
changes to the other variables

variables.sh has examples on how to set variable form the terraform output and
from Google Runtime Configurator

./create_dataproc.sh

# Setup Airflow and upload DAGs
Uploads example DAGs to the composer GCS bucket. Sets up required Airflow
variables and outputs the Airflow UI http endpoint and Composer DAG GCS bucket.

./upload_dags.sh

# Airflow example Dags
 - example_create_dataproc: This workflow will create a Cloud Dataproc cluster,
    run the Hadoop wordcount example, and deletes the cluster

 - example_existing_dataproc: This workflow will run the Hadoop wordcount
    example in the Cloud Dataproc cluster created by the ./create_dataproc.sh script

 - example_gcp_api: Example workflow to show how to pull configs from dataproc
     and interacte with GCE instances