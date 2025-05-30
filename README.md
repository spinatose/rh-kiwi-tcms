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

# Create an Azure Container Instance
az container create \
    --resource-group kiwi-tcms-rg \
    --name kiwi-tcms \
    --image pub.kiwitcms.eu/kiwitcms/kiwi:latest \
    --dns-name-label kiwi-tcms \
    --ports 80 443 \
    --environment-variables \
        KIWI_DB_HOST=<your-db-host> \
        KIWI_DB_PORT=3306 \
        KIWI_DB_NAME=kiwi \
        KIWI_DB_USER=kiwi \
        KIWI_DB_PASSWORD=<your-db-password>
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

### 3. Configure Networking and SSL
1. Set up Azure Application Gateway:
```bash
# Create a public IP address
az network public-ip create \
    --resource-group kiwi-tcms-rg \
    --name kiwi-tcms-ip \
    --allocation-method Static \
    --sku Standard

# Create the Application Gateway
az network application-gateway create \
    --resource-group kiwi-tcms-rg \
    --name kiwi-tcms-gateway \
    --location eastus \
    --capacity 2 \
    --sku Standard_v2 \
    --public-ip-address kiwi-tcms-ip \
    --frontend-port 80 \
    --http-settings-port 80 \
    --http-settings-protocol Http \
    --routing-rule-type Basic \
    --servers <container-ip>
```

2. Configure SSL Certificate:
```bash
# Create a Key Vault
az keyvault create \
    --resource-group kiwi-tcms-rg \
    --name kiwi-tcms-vault \
    --location eastus

# Import your SSL certificate (if you have one)
az keyvault certificate import \
    --vault-name kiwi-tcms-vault \
    --name ssl-cert \
    --file /path/to/your/certificate.pfx \
    --password <certificate-password>

# Or create a new certificate using Let's Encrypt
az network application-gateway ssl-cert create \
    --resource-group kiwi-tcms-rg \
    --gateway-name kiwi-tcms-gateway \
    --name ssl-cert \
    --cert-file /path/to/cert.pfx \
    --cert-password <certificate-password>

# Configure HTTPS listener
az network application-gateway http-listener create \
    --resource-group kiwi-tcms-rg \
    --gateway-name kiwi-tcms-gateway \
    --name https-listener \
    --frontend-port 443 \
    --ssl-cert ssl-cert
```

3. Set up custom domain and DNS:
```bash
# Add custom domain to Application Gateway
az network application-gateway frontend-port create \
    --resource-group kiwi-tcms-rg \
    --gateway-name kiwi-tcms-gateway \
    --name https-port \
    --port 443

# Create DNS record
az network dns record-set a add-record \
    --resource-group kiwi-tcms-rg \
    --zone-name yourdomain.com \
    --record-set-name kiwi \
    --ipv4-address <application-gateway-ip>
```

4. Configure firewall rules:
```bash
# Create network security group
az network nsg create \
    --resource-group kiwi-tcms-rg \
    --name kiwi-tcms-nsg

# Add inbound rules
az network nsg rule create \
    --resource-group kiwi-tcms-rg \
    --nsg-name kiwi-tcms-nsg \
    --name allow-http \
    --protocol tcp \
    --priority 100 \
    --destination-port-range 80

az network nsg rule create \
    --resource-group kiwi-tcms-rg \
    --nsg-name kiwi-tcms-nsg \
    --name allow-https \
    --protocol tcp \
    --priority 110 \
    --destination-port-range 443
```

### 4. Environment Variables
Create a `.env` file for your production environment:
```env
KIWI_DB_HOST=<your-mysql-server>.mysql.database.azure.com
KIWI_DB_PORT=3306
KIWI_DB_NAME=kiwi
KIWI_DB_USER=kiwi
KIWI_DB_PASSWORD=<your-db-password>
```

### 5. Backup Strategy
1. Set up automated backups for the database
2. Configure backup retention policies
3. Test restore procedures regularly

### 6. Monitoring and Logging
1. Set up Azure Monitor for container insights
2. Configure log analytics workspace
3. Set up alerts for critical events

### 7. Security Considerations
1. Use Azure Key Vault for sensitive information
2. Implement proper access controls
3. Regular security updates and patches
4. Network security rules
5. SSL/TLS configuration

### 8. Scaling
1. Configure auto-scaling rules
2. Set up load balancing
3. Monitor resource usage

### 9. Maintenance
1. Regular updates of the Kiwi TCMS image
2. Database maintenance
3. Storage cleanup
4. Log rotation

### 10. Cost Optimization
1. Use appropriate VM sizes
2. Implement auto-shutdown for non-production environments
3. Monitor and optimize resource usage

## Google Cloud Platform (GCP) Deployment Instructions

### Prerequisites
1. Google Cloud account with appropriate permissions
2. Google Cloud SDK (gcloud) installed
3. Docker installed locally
4. Google Container Registry (GCR) or Artifact Registry access

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
```

### 4. Deploy to Cloud Run
```bash
# Build and push the container
gcloud builds submit --tag gcr.io/$PROJECT_ID/kiwi-tcms

# Deploy to Cloud Run
gcloud run deploy kiwi-tcms \
    --image gcr.io/$PROJECT_ID/kiwi-tcms \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated \
    --set-env-vars="KIWI_DB_HOST=<cloud-sql-connection-name>,KIWI_DB_PORT=3306,KIWI_DB_NAME=kiwi,KIWI_DB_USER=kiwi,KIWI_DB_PASSWORD=<your-db-password>" \
    --vpc-connector=kiwi-tcms-connector \
    --port 80
```

### 5. Configure SSL and Custom Domain
```bash
# Create a load balancer
gcloud compute backend-services create kiwi-tcms-backend \
    --global \
    --protocol HTTP \
    --port-name http

# Add the Cloud Run service as a backend
gcloud compute backend-services add-backend kiwi-tcms-backend \
    --global \
    --target-https-proxy=kiwi-tcms-https-proxy \
    --service=kiwi-tcms

# Create SSL certificate
gcloud compute ssl-certificates create kiwi-tcms-cert \
    --domains=your-domain.com

# Create a global IP address
gcloud compute addresses create kiwi-tcms-ip \
    --global

# Create a forwarding rule
gcloud compute forwarding-rules create kiwi-tcms-https-rule \
    --global \
    --target-https-proxy=kiwi-tcms-https-proxy \
    --ports=443 \
    --address=kiwi-tcms-ip
```

### 6. Set Up Cloud SQL Connection
```bash
# Create a VPC connector
gcloud compute networks vpc-access connectors create kiwi-tcms-connector \
    --network=kiwi-tcms-network \
    --region=us-central1 \
    --range=10.8.0.0/28

# Configure Cloud SQL connection
gcloud sql instances patch kiwi-tcms-db \
    --authorized-networks=<your-ip>/32
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
# Enable automated backups
gcloud sql instances patch kiwi-tcms-db \
    --backup-start-time="23:00" \
    --enable-bin-log

# Create a backup schedule
gcloud scheduler jobs create http kiwi-tcms-backup \
    --schedule="0 23 * * *" \
    --uri="https://cloudsql.googleapis.com/v1/projects/$PROJECT_ID/instances/kiwi-tcms-db/backup" \
    --http-method=POST
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
gcloud run services update kiwi-tcms \
    --min-instances=1 \
    --max-instances=10 \
    --cpu=1 \
    --memory=512Mi
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
