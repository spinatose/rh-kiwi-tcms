# rh-kiwi-tcms
Branded version of Kiwi TCMS Docker Swarm

The following instructions have been derived from steps outlined in the Kiwi TCMS documentation for getting a docker network running with Kiwi: [Running Kiwi TCMS as a Docker container](https://kiwitcms.readthedocs.io/en/latest/installing_docker.html)

## Docker Setup Instructions

### 1. Initial Docker Compose Setup
- Create a `docker-compose.yaml` file with two services:
  - `db` (MariaDB database)
  - `web` (Kiwi TCMS application)

### 2. Volume Configuration for Data Persistence
- Set up two persistent volumes:
  - `db_data` for the database
  - `uploads` for uploaded files

### 3. Port Configuration
- Use port 8080 for HTTP access
- Use port 443 for HTTPS

### 4. Initial System Startup
```bash
# Start the containers in detached mode
docker compose up -d
```

### 5. Initial Setup and Base URL Configuration
```bash
# Run initial setup
docker exec -it kiwi_web /Kiwi/manage.py initial_setup

# Set base URL for local development
docker exec -it kiwi_web /Kiwi/manage.py set_domain localhost:8080

# Restart the web container to apply the base URL changes
docker compose restart web
```

### 6. Logo Customization
- Use the existing `branding` folder
- Copy logo file to the correct name:
```bash
cp .\branding\rhblkbkgdsmall.png .\branding\kiwi_h20.png
```
- Modify `docker-compose.yaml` to mount the branding folder:
```yaml
volumes:
  - ./branding:/Kiwi/custom_static:ro
```
- Add environment variable for static files:
```yaml
environment:
  STATICFILES_DIRS: /Kiwi/custom_static
```

### 7. UI Customization
- Create and modify the `branding/patternfly_override.css` file to customize UI colors and styles
- This file is automatically mounted to the correct location in the container and will override the default Patternfly styles
- Example: To change the top border color, add or modify this CSS rule:
```css
.navbar.navbar-default {
    border-top-color: #e11f00 !important;
}
```
- Add the CSS file mount to docker-compose.yaml:
```yaml
volumes:
  - ./branding/patternfly_override.css:/Kiwi/static/style/patternfly_override.css:ro
```
- After making CSS changes, restart the containers to apply the changes:
```bash
docker-compose down && docker-compose up -d
```

### 8. Final Docker Compose Configuration
```yaml
services:
    db:
        container_name: kiwi_db
        image: mariadb:latest
        command:
            --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
        volumes:
            - db_data:/var/lib/mysql:rw
        restart: always
        environment:
            MYSQL_ROOT_PASSWORD: kiwi-1s-aw3s0m3
            MYSQL_DATABASE: kiwi
            MYSQL_USER: kiwi
            MYSQL_PASSWORD: kiwi

    web:
        container_name: kiwi_web
        depends_on:
            - db
        restart: always
        image: pub.kiwitcms.eu/kiwitcms/kiwi:latest
        ports:
            - 8080:8080
            - 443:8443
        volumes:
            - uploads:/Kiwi/uploads:rw
            - static_files:/Kiwi/static:rw
            - ./branding:/Kiwi/custom_static:ro
            - ./branding/patternfly_override.css:/Kiwi/static/style/patternfly_override.css:ro
        environment:
            KIWI_DB_HOST: db
            KIWI_DB_PORT: 3306
            KIWI_DB_NAME: kiwi
            KIWI_DB_USER: kiwi
            KIWI_DB_PASSWORD: kiwi
            STATICFILES_DIRS: /Kiwi/custom_static
        cap_drop:
          - ALL

volumes:
    db_data:
        driver: local
    uploads:
        driver: local
    static_files:
        driver: local
```

### 9. Final Steps to Start the System
```bash
# Stop any running containers
docker compose down

# Start the containers
docker compose up -d

# Collect static files (including the custom logo)
docker exec -it kiwi_web /Kiwi/manage.py collectstatic --noinput

# Restart the web container to apply changes
docker compose restart web
```

### 10. Accessing Kiwi TCMS
- HTTP: `http://localhost:8080`
- HTTPS: `https://localhost:443`

### 11. Useful Commands for Management
- Start the system: `docker compose up -d`
- Stop the system: `docker compose down`
- View logs: `docker compose logs -f`
- Restart web container: `docker compose restart web`

## Setup of Testing in Kiwi TCMS

### 1. Create Test Plan   
   1. In Title use \<Client Prefix\>: \<Product\> \- \<Type of Test Plan\> \- ex. MIDW: Online Member Directory \- User Acceptance   
   2. Create a product for the Test Plan   
   3. Create a version of the product that will be tested \- ex. 1.0.0   
   4. Select Test Plan type \- ex. "Acceptance", "Functional", etc...   
   5. Add Test Document to Test Plan   
   6. Save  
### 2. Create Test Cases   
   1. Create a category or select one from the list   
   2. Create a Template if one will serve to provide structure to multiple Test Cases   
   3. Set Status to "CONFIRMED" to allow test execution   
   4. Fill out test description and instructions   
   5. Save   
   6. On page that appears with committed Test Case   
      1. Search Test Plan in Test Plans new Test Case belongs to and type in id of previous Test Plan created above   
      2. Select Test Plan   
      3. Click "+" button to assign Test Case to Test Plan   
   7. NOTE: You can edit test assets by clicking the little gears image in header on page for asset  
### 3. Create Test Run   
   1. Select Product and Test Plan created above will be available to create this Test Run for   
   2. Create a build based on Product and Version   
   3. Fill out rest of fields   
   4. Save  
### 4. Add Tests (Test Cases) for Test Run   
   1. Select Test Run (should already be on the page with Test Run showing after creation in step above)   
   2. Under "Test Executions" \- not intuitive   
      1. Type ID of Test Case to add to Test Run for execution   
      2. When Test Case shows up- click it and then click "+" button to add to Test Run   
      3. Repeat for rest of Test Cases   
      4. NOTE: Only "CONFIRMED" status Test Cases are available to add to Test Run  
      5. Assign tester for executions
         1. Once Test Cases have been added for executions, then mark the checkbox next to all Test Cases that should be executed by a given tester
         2. Click the hamburger menu icon at the top and to the left of the list of Test Cases and choose "Assign User"
         3. In the popup that appears, type the email of a user that is a tester in the TCMS and click OK
         4. The tester will now be assigned to each Test Case for execution that was checked
### 5. Test Run \- Test Executions   
   1. Once all Test Cases are added to Test Run, they can be executed   
      1. Click "Started at:" button to indicate Test Run has begun   
      2. Run thru Test Cases for execution   
         1. Expand Test Case   
         2. Enter results of test into textarea   
         3. Optionally attach files/screen shots   
         4. Mark result of test execution- ex. "PASSED", "FAILED", etc   
      3. After all test cases \- "Finished at" should update \- if not set to now

## Azure Deployment Instructions

### Prerequisites
1. Azure account with appropriate permissions
2. Azure CLI installed
3. Docker installed locally
4. Azure Container Registry (ACR) account

### 1. Create Azure Resources
```bash
# Create a resource group
az group create --name kiwi-tcms-rg --location eastus

# Create an Azure Container Registry
az acr create --resource-group kiwi-tcms-rg --name kiwitcmsregistry --sku Basic

# Create an AKS cluster
az aks create \
    --resource-group kiwi-tcms-rg \
    --name kiwi-tcms-cluster \
    --node-count 2 \
    --enable-addons monitoring \
    --generate-ssh-keys \
    --node-vm-size Standard_D2s_v3

# Get AKS credentials
az aks get-credentials \
    --resource-group kiwi-tcms-rg \
    --name kiwi-tcms-cluster
```

### 2. Set Up Persistent Storage
1. Create Azure Files share for uploads:
```bash
# Create storage account
az storage account create \
    --name kiwitcmsstorage \
    --resource-group kiwi-tcms-rg \
    --location eastus \
    --sku Standard_LRS

# Create file share
az storage share create \
    --name kiwitcms-uploads \
    --account-name kiwitcmsstorage

# Get storage account key
STORAGE_KEY=$(az storage account keys list \
    --resource-group kiwi-tcms-rg \
    --account-name kiwitcmsstorage \
    --query "[0].value" -o tsv)

# Create Kubernetes secret for storage
kubectl create secret generic azure-storage-secret \
    --from-literal=azurestorageaccountname=kiwitcmsstorage \
    --from-literal=azurestorageaccountkey=$STORAGE_KEY
```

2. Create Azure Database for MySQL:
```bash
# Create MySQL server
az mysql server create \
    --resource-group kiwi-tcms-rg \
    --name kiwi-tcms-db \
    --location eastus \
    --admin-user kiwi \
    --admin-password <your-db-password> \
    --sku-name B_Gen5_1
```

### 3. Deploy Kiwi TCMS to AKS
1. Create Kubernetes deployment files:

```yaml
# kiwi-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kiwi-tcms
spec:
  replicas: 2
  selector:
    matchLabels:
      app: kiwi-tcms
  template:
    metadata:
      labels:
        app: kiwi-tcms
    spec:
      containers:
      - name: kiwi-tcms
        image: pub.kiwitcms.eu/kiwitcms/kiwi:latest
        ports:
        - containerPort: 80
        env:
        - name: KIWI_DB_HOST
          value: "<your-mysql-server>.mysql.database.azure.com"
        - name: KIWI_DB_PORT
          value: "3306"
        - name: KIWI_DB_NAME
          value: "kiwi"
        - name: KIWI_DB_USER
          value: "kiwi"
        - name: KIWI_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: kiwi-db-secret
              key: password
        volumeMounts:
        - name: uploads
          mountPath: /Kiwi/uploads
      volumes:
      - name: uploads
        azureFile:
          secretName: azure-storage-secret
          shareName: kiwitcms-uploads
          readOnly: false
```

```yaml
# kiwi-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: kiwi-tcms
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: kiwi-tcms
```

2. Create Kubernetes secrets:
```bash
# Create database password secret
kubectl create secret generic kiwi-db-secret \
    --from-literal=password=<your-db-password>
```

3. Deploy to AKS:
```bash
# Apply the deployment
kubectl apply -f kiwi-deployment.yaml
kubectl apply -f kiwi-service.yaml

# Verify deployment
kubectl get pods
kubectl get services
```

### 4. Configure Ingress and SSL
```yaml
# kiwi-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kiwi-tcms-ingress
  annotations:
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  tls:
  - hosts:
    - your-domain.com
    secretName: kiwi-tcms-tls
  rules:
  - host: your-domain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: kiwi-tcms
            port:
              number: 80
```

```bash
# Install NGINX ingress controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx

# Install cert-manager for SSL
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --version v1.8.0 \
    --set installCRDs=true

# Apply ingress configuration
kubectl apply -f kiwi-ingress.yaml
```

### 5. Configure Monitoring and Logging
```bash
# Enable Azure Monitor for containers
az aks enable-addons \
    --resource-group kiwi-tcms-rg \
    --name kiwi-tcms-cluster \
    --addons monitoring

# Set up log analytics workspace
az monitor log-analytics workspace create \
    --resource-group kiwi-tcms-rg \
    --workspace-name kiwi-tcms-logs
```

### 6. Set Up Auto-scaling
```bash
# Enable cluster autoscaler
az aks update \
    --resource-group kiwi-tcms-rg \
    --name kiwi-tcms-cluster \
    --enable-cluster-autoscaler \
    --min-count 2 \
    --max-count 5

# Configure pod autoscaling
kubectl autoscale deployment kiwi-tcms \
    --cpu-percent=70 \
    --min=2 \
    --max=5
```

### 7. Backup and Disaster Recovery

#### 7.1 Database Backup Strategy
```bash
# Enable automated backups for Azure Database for MySQL
az mysql server configuration set \
    --resource-group kiwi-tcms-rg \
    --server-name kiwi-tcms-db \
    --name backup_retention_days \
    --value 35

# Create a backup policy
az mysql server configuration set \
    --resource-group kiwi-tcms-rg \
    --server-name kiwi-tcms-db \
    --name backup_retention_hours \
    --value 24

# Enable geo-redundant backups
az mysql server update \
    --resource-group kiwi-tcms-rg \
    --name kiwi-tcms-db \
    --geo-redundant-backup Enabled
```

#### 7.2 Storage Backup
```bash
# Enable soft delete for Azure Files
az storage account blob-service-properties update \
    --resource-group kiwi-tcms-rg \
    --account-name kiwitcmsstorage \
    --enable-delete-retention true \
    --delete-retention-days 30

# Create a backup vault
az backup vault create \
    --resource-group kiwi-tcms-rg \
    --name kiwi-tcms-backup-vault \
    --location eastus

# Enable backup for the storage account
az backup protection enable-for-azurefileshare \
    --resource-group kiwi-tcms-rg \
    --vault-name kiwi-tcms-backup-vault \
    --storage-account kiwitcmsstorage \
    --azure-file-share kiwitcms-uploads \
    --policy-name DefaultPolicy
```

#### 7.3 Kubernetes State Backup
```bash
# Create a backup namespace
kubectl create namespace velero

# Install Velero for Kubernetes backup
velero install \
    --provider azure \
    --plugins velero/velero-plugin-for-microsoft-azure:v1.5.0 \
    --bucket kiwi-tcms-backups \
    --backup-location-config resourceGroup=kiwi-tcms-rg,storageAccount=kiwitcmsbackups,storageAccountKeyEnvVar=AZURE_STORAGE_ACCOUNT_ACCESS_KEY \
    --secret-file ./credentials-velero.yaml \
    --namespace velero

# Create a backup schedule
velero schedule create kiwi-tcms-daily \
    --schedule="0 1 * * *" \
    --include-namespaces default \
    --ttl 720h
```

#### 7.4 Disaster Recovery Plan

1. **Database Recovery**:
```bash
# List available backups
az mysql server backup list \
    --resource-group kiwi-tcms-rg \
    --server-name kiwi-tcms-db

# Restore from backup
az mysql server restore \
    --resource-group kiwi-tcms-rg \
    --name kiwi-tcms-db-restored \
    --source-server kiwi-tcms-db \
    --restore-point-in-time "2024-01-01T00:00:00Z"
```

2. **Storage Recovery**:
```bash
# List recovery points
az backup recoverypoint list \
    --resource-group kiwi-tcms-rg \
    --vault-name kiwi-tcms-backup-vault \
    --container-name "StorageContainer;storage;kiwitcmsstorage;kiwitcms-uploads" \
    --item-name "AzureFileShare;kiwitcms-uploads"

# Restore files
az backup restore restore-azurefileshare \
    --resource-group kiwi-tcms-rg \
    --vault-name kiwi-tcms-backup-vault \
    --container-name "StorageContainer;storage;kiwitcmsstorage;kiwitcms-uploads" \
    --item-name "AzureFileShare;kiwitcms-uploads" \
    --rp-name <recovery-point-name> \
    --target-storage-account kiwitcmsstorage \
    --target-file-share kiwitcms-uploads-restored
```

3. **Kubernetes State Recovery**:
```bash
# List available backups
velero backup get

# Restore from backup
velero restore create --from-backup kiwi-tcms-daily-20240101-010000
```

#### 7.5 Cross-Region Disaster Recovery
```bash
# Create a secondary region resource group
az group create --name kiwi-tcms-dr-rg --location westus2

# Enable geo-replication for storage
az storage account create \
    --name kiwitcmsstoragedr \
    --resource-group kiwi-tcms-dr-rg \
    --location westus2 \
    --sku Standard_GRS

# Set up cross-region replication for MySQL
az mysql server replica create \
    --resource-group kiwi-tcms-dr-rg \
    --name kiwi-tcms-db-dr \
    --source-server kiwi-tcms-db
```

#### 7.6 Recovery Testing Procedures
1. **Database Recovery Test**:
```bash
# Create a test restore
az mysql server restore \
    --resource-group kiwi-tcms-rg \
    --name kiwi-tcms-db-test \
    --source-server kiwi-tcms-db \
    --restore-point-in-time "2024-01-01T00:00:00Z"

# Verify data integrity
mysql -h kiwi-tcms-db-test.mysql.database.azure.com -u kiwi -p kiwi -e "SELECT COUNT(*) FROM test_executions;"
```

2. **Storage Recovery Test**:
```bash
# Create a test restore
az backup restore restore-azurefileshare \
    --resource-group kiwi-tcms-rg \
    --vault-name kiwi-tcms-backup-vault \
    --container-name "StorageContainer;storage;kiwitcmsstorage;kiwitcms-uploads" \
    --item-name "AzureFileShare;kiwitcms-uploads" \
    --rp-name <recovery-point-name> \
    --target-storage-account kiwitcmsstorage \
    --target-file-share kiwitcms-uploads-test
```

3. **Kubernetes Recovery Test**:
```bash
# Create a test namespace
kubectl create namespace recovery-test

# Restore to test namespace
velero restore create --from-backup kiwi-tcms-daily-20240101-010000 --namespace-mappings default:recovery-test
```

#### 7.7 Monitoring and Alerts
```bash
# Create backup monitoring alerts
az monitor metrics alert create \
    --name "backup-failure-alert" \
    --resource-group kiwi-tcms-rg \
    --scopes /subscriptions/<subscription-id>/resourceGroups/kiwi-tcms-rg/providers/Microsoft.DBforMySQL/servers/kiwi-tcms-db \
    --condition "total backup storage bytes < 1000000" \
    --description "Alert when backup size is too small"

# Set up backup status monitoring
az monitor action-group create \
    --resource-group kiwi-tcms-rg \
    --name backup-admins \
    --action email admin@example.com
```

## Google Cloud Platform (GCP) Deployment Instructions

### Prerequisites
1. Google Cloud account with appropriate permissions
2. Google Cloud SDK (gcloud) installed
3. Docker installed locally
4. Google Container Registry (GCR) or Artifact Registry access
5. kubectl installed

### 1. Create GCP Resources
```bash
# Set your project ID
export PROJECT_ID=your-project-id
gcloud config set project $PROJECT_ID

# Create a VPC network
gcloud compute networks create kiwi-tcms-network \
    --subnet-mode=auto

# Create a subnet
gcloud compute networks subnets create kiwi-tcms-subnet \
    --network=kiwi-tcms-network \
    --region=us-central1 \
    --range=10.0.0.0/24

# Create a GKE cluster
gcloud container clusters create kiwi-tcms-cluster \
    --network=kiwi-tcms-network \
    --subnetwork=kiwi-tcms-subnet \
    --zone=us-central1-a \
    --machine-type=e2-standard-2 \
    --num-nodes=2 \
    --enable-ip-alias \
    --enable-autoscaling \
    --min-nodes=2 \
    --max-nodes=5 \
    --addons=HttpLoadBalancing,HorizontalPodAutoscaling

# Get credentials for the cluster
gcloud container clusters get-credentials kiwi-tcms-cluster \
    --zone=us-central1-a
```

### 2. Set Up Cloud SQL (MySQL)
```bash
# Create a Cloud SQL instance
gcloud sql instances create kiwi-tcms-db \
    --database-version=MYSQL_8_0 \
    --tier=db-f1-micro \
    --region=us-central1 \
    --network=kiwi-tcms-network \
    --root-password=<your-root-password>

# Create the database
gcloud sql databases create kiwi \
    --instance=kiwi-tcms-db

# Create a user
gcloud sql users create kiwi \
    --instance=kiwi-tcms-db \
    --password=<your-db-password>

# Create a secret for database credentials
kubectl create secret generic kiwi-db-secret \
    --from-literal=username=kiwi \
    --from-literal=password=<your-db-password>
```

### 3. Set Up Cloud Storage
```bash
# Create a storage bucket for uploads
gsutil mb -l us-central1 gs://kiwi-tcms-uploads

# Create a service account for the container
gcloud iam service-accounts create kiwi-tcms-sa \
    --display-name="Kiwi TCMS Service Account"

# Grant storage access to the service account
gsutil iam ch \
    serviceAccount:kiwi-tcms-sa@$PROJECT_ID.iam.gserviceaccount.com:objectViewer,objectCreator \
    gs://kiwi-tcms-uploads

# Create a secret for storage credentials
kubectl create secret generic kiwi-storage-secret \
    --from-file=key.json=/path/to/service-account-key.json
```

### 4. Deploy Kiwi TCMS to GKE
1. Create Kubernetes deployment files:

```yaml
# kiwi-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kiwi-tcms
spec:
  replicas: 2
  selector:
    matchLabels:
      app: kiwi-tcms
  template:
    metadata:
      labels:
        app: kiwi-tcms
    spec:
      containers:
      - name: kiwi-tcms
        image: pub.kiwitcms.eu/kiwitcms/kiwi:latest
        ports:
        - containerPort: 80
        env:
        - name: KIWI_DB_HOST
          value: "<your-cloud-sql-connection-name>"
        - name: KIWI_DB_PORT
          value: "3306"
        - name: KIWI_DB_NAME
          value: "kiwi"
        - name: KIWI_DB_USER
          valueFrom:
            secretKeyRef:
              name: kiwi-db-secret
              key: username
        - name: KIWI_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: kiwi-db-secret
              key: password
        volumeMounts:
        - name: uploads
          mountPath: /Kiwi/uploads
      volumes:
      - name: uploads
        gcePersistentDisk:
          pdName: kiwi-tcms-uploads
          fsType: ext4
```

```yaml
# kiwi-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: kiwi-tcms
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: kiwi-tcms
```

2. Deploy to GKE:
```bash
# Apply the deployment
kubectl apply -f kiwi-deployment.yaml
kubectl apply -f kiwi-service.yaml

# Verify deployment
kubectl get pods
kubectl get services
```

### 5. Configure Ingress and SSL
```yaml
# kiwi-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kiwi-tcms-ingress
  annotations:
    kubernetes.io/ingress.class: "gce"
    kubernetes.io/ingress.global-static-ip-name: "kiwi-tcms-ip"
    networking.gke.io/managed-certificates: "kiwi-tcms-cert"
spec:
  rules:
  - host: your-domain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: kiwi-tcms
            port:
              number: 80
```

```bash
# Reserve a static IP
gcloud compute addresses create kiwi-tcms-ip --global

# Create managed SSL certificate
gcloud compute ssl-certificates create kiwi-tcms-cert \
    --domains=your-domain.com

# Apply ingress configuration
kubectl apply -f kiwi-ingress.yaml
```

### 6. Set Up Cloud SQL Connection
```bash
# Create a Cloud SQL proxy deployment
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/cloud-sql-proxy/master/manifests/cloud-sql-proxy.yaml

# Configure the proxy to connect to your instance
kubectl patch deployment cloud-sql-proxy \
    --patch '{"spec":{"template":{"spec":{"containers":[{"name":"cloud-sql-proxy","args":["--structured-logs","--port=3306","<your-cloud-sql-connection-name>"]}]}}}}'
```

### 7. Configure Monitoring and Logging
```bash
# Enable Cloud Monitoring
gcloud services enable monitoring.googleapis.com

# Enable Cloud Logging
gcloud services enable logging.googleapis.com

# Create a monitoring dashboard
gcloud monitoring dashboards create \
    --config-from-file=dashboard-config.json
```

### 8. Set Up Backup Strategy
```bash
# Enable automated backups for Cloud SQL
gcloud sql instances patch kiwi-tcms-db \
    --backup-start-time="23:00" \
    --enable-bin-log \
    --backup-retention-count=7 \
    --enable-point-in-time-recovery

# Create a backup schedule
gcloud scheduler jobs create http kiwi-tcms-backup \
    --schedule="0 23 * * *" \
    --uri="https://sqladmin.googleapis.com/v1/projects/$PROJECT_ID/instances/kiwi-tcms-db/backup" \
    --http-method=POST

# Enable cross-region replication
gcloud sql instances patch kiwi-tcms-db \
    --availability-type=REGIONAL \
    --region=us-central1
```

### 9. Security Considerations
1. Use Secret Manager for sensitive data:
```bash
# Create secrets
gcloud secrets create kiwi-db-password \
    --replication-policy="automatic"

# Store the database password
echo -n "<your-db-password>" | \
    gcloud secrets versions add kiwi-db-password --data-file=-
```

2. Configure IAM roles:
```bash
# Grant minimal required permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:kiwi-tcms-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/cloudsql.client"
```

### 10. Cost Optimization
1. Use appropriate machine types
2. Configure auto-scaling:
```bash
# Configure horizontal pod autoscaling
kubectl autoscale deployment kiwi-tcms \
    --cpu-percent=70 \
    --min=2 \
    --max=5
```

3. Set up budget alerts:
```bash
gcloud billing budgets create \
    --billing-account=<your-billing-account> \
    --display-name="Kiwi TCMS Budget" \
    --budget-amount=100USD \
    --threshold-rule=percent=0.9 \
    --threshold-rule=percent=1.0
```

### 11. Backup and Disaster Recovery

#### 11.1 Database Backup Strategy
```bash
# Enable automated backups for Cloud SQL
gcloud sql instances patch kiwi-tcms-db \
    --backup-start-time="23:00" \
    --enable-bin-log \
    --backup-retention-count=7 \
    --enable-point-in-time-recovery

# Create a backup schedule
gcloud scheduler jobs create http kiwi-tcms-backup \
    --schedule="0 23 * * *" \
    --uri="https://sqladmin.googleapis.com/v1/projects/$PROJECT_ID/instances/kiwi-tcms-db/backup" \
    --http-method=POST

# Enable cross-region replication
gcloud sql instances patch kiwi-tcms-db \
    --availability-type=REGIONAL \
    --region=us-central1
```

#### 11.2 Storage Backup
```bash
# Enable versioning for Cloud Storage
gsutil versioning set on gs://kiwi-tcms-uploads

# Set up lifecycle rules for old versions
gsutil lifecycle set lifecycle-config.json gs://kiwi-tcms-uploads

# Create a backup bucket in a different region
gsutil mb -l us-east1 gs://kiwi-tcms-uploads-backup

# Set up cross-region replication
gsutil cors set cors-config.json gs://kiwi-tcms-uploads
gsutil cors set cors-config.json gs://kiwi-tcms-uploads-backup
```

#### 11.3 Kubernetes State Backup
```bash
# Install Velero for Kubernetes backup
velero install \
    --provider gcp \
    --plugins velero/velero-plugin-for-gcp:v1.5.0 \
    --bucket kiwi-tcms-backups \
    --secret-file ./credentials-velero.yaml \
    --namespace velero

# Create a backup schedule
velero schedule create kiwi-tcms-daily \
    --schedule="0 1 * * *" \
    --include-namespaces default \
    --ttl 720h

# Create a backup location in a different region
velero backup-location create secondary \
    --provider gcp \
    --bucket kiwi-tcms-backups-secondary \
    --config region=us-east1
```

#### 11.4 Disaster Recovery Plan

1. **Database Recovery**:
```bash
# List available backups
gcloud sql backups list \
    --instance=kiwi-tcms-db

# Restore from backup
gcloud sql instances restore-backup kiwi-tcms-db-restored \
    --restore-instance=kiwi-tcms-db \
    --backup-instance=kiwi-tcms-db \
    --backup-id=<backup-id>

# Point-in-time recovery
gcloud sql instances restore-backup kiwi-tcms-db-restored \
    --restore-instance=kiwi-tcms-db \
    --backup-instance=kiwi-tcms-db \
    --restore-time="2024-01-01T00:00:00Z"
```

2. **Storage Recovery**:
```bash
# List object versions
gsutil ls -a gs://kiwi-tcms-uploads/

# Restore specific version
gsutil cp gs://kiwi-tcms-uploads/object#version-id gs://kiwi-tcms-uploads/object

# Restore from backup bucket
gsutil -m cp -r gs://kiwi-tcms-uploads-backup/* gs://kiwi-tcms-uploads/
```

3. **Kubernetes State Recovery**:
```bash
# List available backups
velero backup get

# Restore from backup
velero restore create --from-backup kiwi-tcms-daily-20240101-010000

# Restore to different cluster
velero restore create --from-backup kiwi-tcms-daily-20240101-010000 \
    --kubeconfig /path/to/secondary-cluster-kubeconfig
```

#### 11.5 Cross-Region Disaster Recovery
```bash
# Create a secondary region cluster
gcloud container clusters create kiwi-tcms-cluster-dr \
    --zone=us-east1-a \
    --network=kiwi-tcms-network \
    --subnetwork=kiwi-tcms-subnet-dr \
    --machine-type=e2-standard-2 \
    --num-nodes=2

# Set up cross-region replication for Cloud SQL
gcloud sql instances create kiwi-tcms-db-dr \
    --master-instance-name=kiwi-tcms-db \
    --region=us-east1

# Configure cross-region replication for storage
gsutil iam ch \
    serviceAccount:kiwi-tcms-sa@$PROJECT_ID.iam.gserviceaccount.com:objectViewer,objectCreator \
    gs://kiwi-tcms-uploads-backup
```

#### 11.6 Recovery Testing Procedures
1. **Database Recovery Test**:
```bash
# Create a test instance
gcloud sql instances create kiwi-tcms-db-test \
    --source-instance=kiwi-tcms-db \
    --region=us-central1

# Verify data integrity
gcloud sql connect kiwi-tcms-db-test --user=kiwi --database=kiwi \
    --command="SELECT COUNT(*) FROM test_executions;"
```

2. **Storage Recovery Test**:
```bash
# Create a test bucket
gsutil mb -l us-central1 gs://kiwi-tcms-uploads-test

# Copy data to test bucket
gsutil -m cp -r gs://kiwi-tcms-uploads/* gs://kiwi-tcms-uploads-test/

# Verify data integrity
gsutil ls -l gs://kiwi-tcms-uploads-test/
```

3. **Kubernetes Recovery Test**:
```bash
# Create a test namespace
kubectl create namespace recovery-test

# Restore to test namespace
velero restore create --from-backup kiwi-tcms-daily-20240101-010000 \
    --namespace-mappings default:recovery-test
```

#### 11.7 Monitoring and Alerts
```bash
# Create backup monitoring alerts
gcloud monitoring policies create \
    --policy-from-file=backup-policy.yaml

# Set up backup status monitoring
gcloud monitoring channels create \
    --display-name="Backup Alerts" \
    --type=email \
    --channel-labels=email_address=admin@example.com

# Create alert for backup failures
gcloud alpha monitoring policies create \
    --policy-from-file=backup-failure-policy.yaml
```

#### 11.8 Backup Policy Configuration
```json
# lifecycle-config.json
{
  "lifecycle": {
    "rule": [
      {
        "action": {
          "type": "Delete"
        },
        "condition": {
          "numNewerVersions": 5,
          "isLive": false
        }
      }
    ]
  }
}
```

```json
# backup-policy.yaml
displayName: "Backup Monitoring Policy"
conditions:
- displayName: "Backup Size Check"
  conditionThreshold:
    filter: "resource.type = \"cloudsql_database\" AND metric.type = \"cloudsql.googleapis.com/database/backup/bytes_used\""
    comparison: COMPARISON_LT
    threshold_value: 1000000
    duration: "300s"
```
