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

"""An example DAG demonstrating some interactions with the GCP API."""

from __future__ import print_function


import datetime

from airflow import models
from airflow.operators import bash_operator
from airflow.operators import python_operator

from airflow.contrib.hooks.gcp_dataproc_hook import DataProcHook
#from airflow.contrib.hooks.gcp_compute_hook import GceHook
#from gcp_compute_hook import GceHook
from dependencies.gcp_compute_hook import GceHook

import logging

default_dag_args = {
    # The start_date describes when a DAG is valid / can be run. Set this to a
    # fixed point in time rather than dynamically, since it is evaluated every
    # time a DAG is parsed. See:
    # https://airflow.apache.org/faq.html#what-s-the-deal-with-start-date
    'start_date': datetime.datetime(2018, 1, 1),
}

# Define a DAG (directed acyclic graph) of tasks.
# Any task you create within the context manager is automatically added to the
# DAG object.
with models.DAG(
        'example_gcp_api',
        schedule_interval=datetime.timedelta(days=1),
        default_args=default_dag_args) as dag:

    def _get_cluster_list_for_project(service, region):
        project_id=models.Variable.get('gcp_project')
        result = service.projects().regions().clusters().list(
            projectId=project_id,
            region=region
        ).execute()
        return result.get('clusters', [])

    def _get_cluster(service, cluster_name, region):
        cluster_list = _get_cluster_list_for_project(service, region)
        cluster = [c for c in cluster_list if c['clusterName'] == cluster_name]
        if cluster:
            return cluster[0]
        return None

    def get_dataproc_vars():
        gcp_conn_id='google_cloud_default'
        delegate_to=None
        cluster_name=models.Variable.get('dataproc_cluster_name')
        project_id=models.Variable.get('gcp_project')
        region=models.Variable.get('gce_region')

        hook = DataProcHook(
            gcp_conn_id=gcp_conn_id,
            delegate_to=delegate_to
        )

        service = hook.get_conn()

        cluster = _get_cluster(service, cluster_name, region)

        if 'status' in cluster:
            logging.info(cluster['config']['configBucket'])
            logging.info(cluster['config']['workerConfig']['instanceNames'])
        else:
            logging.info('not ready')

    def stop_instance():
        gcp_conn_id='google_cloud_default'
        delegate_to=None
        project_id=models.Variable.get('gcp_project')
        zone=models.Variable.get('gce_zone')

        gcehook = GceHook(
            gcp_conn_id=gcp_conn_id,
            delegate_to=delegate_to,
            api_version='v1'
        )

        gceservice = gcehook.get_conn()

        # replace instance-1 with a test instance you want to stop
        response = gcehook.stop_instance(project_id, zone, 'instance-1')
        logging.info(response)

    # An instance of an operator is called a task. In this case, the
    # get_dataproc task calls the "get_dataproc_vars" Python function.
    get_dataproc = python_operator.PythonOperator(
        task_id='get_dataproc',
        python_callable=get_dataproc_vars)

    # An instance of an operator is called a task. In this case, the
    # get_instance task calls the "stop_instance" Python function.
    stop_instance = python_operator.PythonOperator(
        task_id='stop_instance',
        python_callable=stop_instance)

    get_dataproc >> stop_instance
