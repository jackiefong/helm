# Spark Thrift Server Helm Chart

This helm chart deploys the Spark Thrift Server.  It creates the service account, the Metastore, the Spark Thrift Server Driver Pod, and the Executors.

## Prerequisite
1.  mySQL or postgreSQL database (For Metastore)
2.  coreSiteSecret and metastoreSiteSecret (For Metastore)
     - Metastore requires  /opt/hive-metastore/conf/metastore-site.xml and /opt/hadoop/etc/hadoop/core-site.xml.  The luna-metastore.yaml  volumeMount the two files from AWS Secret Manager (luna-i11-xml-core, luna-i11-xml-metastore). 
3.  PVC for Spark Thrift Server Driver and Executor checkpoint,see spark.pvc values.yaml for more information (Recommanded size 2Gi for both)
---
## Helm Chart Values
---
Full documentation can be found in the comments of the `values.yaml` file, but a high-level overview is provided here.

---
__Global Values:__
| Parameter | Description | Default
| --- | --- | --- |
serviceAccount.create|if a Kubernetes ServiceAccount is created|true
rbac.create|Create|if Kubernetes RBAC resources are created|true
schedule|crontab schedule for the job, for more information, try:[ http://crontab.guru](https://crontab.guru/) | "* 1 * * *"
---
__Spark Thrift Server Driver configuration:__

### How the driver configuration works? ###
Spark Thrift Server is unlike any other typical k8s deployments, in which the k8s deployment starts the container from the docker image entry point.   Spark Thrift Server uses a script from Spark call spark-submit along with the arguments to initialize the services.

Here is an example of the Spark Thrift Server spark-submit command.

```
containers:
    - name: spark-thrift-server-driver
      image: spark:3.0.1
      args:
        - /opt/spark/bin/spark-submit
        - '--master'
        - k8s://https://kubernetes.default.svc
        - '--deploy-mode'
        - client
        - '--name'
        - STS
        - '--class'
        - SparkThriftServerRunner
        - '--conf'
        - spark.driver....
        # all of the script param goes here from Helm Values
        local:///opt/spark/spark-submit-app/spark-job.jar
```
There are many supported Spark configurations, and the helm chart organizes them into the below sub-category/config.  Values.yaml also contains the default value of the generic parameters.

```
        {{- with .Values.driver.spark.kubernetes.resource }}{{- toYaml . | nindent 8 }}{{- end }}
        {{- with .Values.driver.spark.kubernetes.executor.secretKeyRef }}{{- toYaml . | nindent 8 }}{{- end }}
        {{- with .Values.driver.spark.pvc }}{{- toYaml . | nindent 8 }}{{- end }}     
        {{- with .Values.driver.spark.hadoop.hive }}{{- toYaml . | nindent 8 }}{{- end }}
        {{- with .Values.driver.spark.hadoop.fs }}{{- toYaml . | nindent 8 }}{{- end }}
        {{- with .Values.driver.spark.customconfig }}{{- toYaml . | nindent 8 }}{{- end }}
```


| Parameter | Description | Default
| --- | --- | --- |
driver.image.repository|image repository|fongjackie/spark
driver.image.pullPolicy|image pull policy|IfNotPresent
driver.image.tag| image tag|3.1.2
driver.env| Env variable|
driver.resource|Kuberentes Resource setting| default is 6Gi memory and 1 core, `<see values.yaml>`
driver.tolerations|Kubernetes tolerations setting| default is xlarge, `<see values.yaml>`
driver.k8s|kubernetes api server url|k8s://
driver.spark.jar|spark dependency jar|`<see values.yaml>`
driver.spark.pvc|pvc for spark thrift server checkpoint, see prerequisite and values.yaml for more information
driver.spark.hadoop.fs|access S3|`<see values.yaml>`
driver.spark.hadoop.hive|hive configuration|`<see values.yaml>`
driver.spark.kubernetes.resource|config spark resources, such as executor instance, memory and cores.  Please refer to :  https://spark.apache.org/docs/3.0.0-preview/configuration.html for more information|` <see values.yaml>`
driver.spark.kubernetes.executor.secretKeyRef| the secret reference for the executor, for example, MONGODB_USER|` <see values.yaml>`
driver.spark.customconfig|any configuration that doesn't fit the above catagory will goes here, such as:  spark.eventLog.dir, spark.sql.thriftServer.incrementalCollect|` <see values.yaml>`