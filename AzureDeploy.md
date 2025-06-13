# Kiwi TCMS Azure Deployment Guide (App Service for Containers + Azure PostgreSQL Flexible Server)

This guide provides a step-by-step, cost-effective approach to deploying Kiwi TCMS with your customizations on Azure, using:
- **Azure Database for PostgreSQL Flexible Server** (cheapest tier)
- **Azure App Service for Containers** (Linux, Docker)
- **Azure Files** for persistent uploads/static files
- **Custom logo and CSS**

---

## Prerequisites
- Azure CLI (latest version)
- Docker image: `pub.kiwitcms.eu/kiwitcms/kiwi:latest`
- Your custom logo and CSS files
- Resource group and region (e.g., `kiwi-tcms-rg`, `eastus`)

---

## 1. Create Resource Group
```bash
az group create --name kiwi-tcms-rg --location eastus
```

---

## 2. Create Azure Database for PostgreSQL Flexible Server
```bash
# Create the server (cheapest Burstable tier)
az postgres flexible-server create \
  --resource-group kiwi-tcms-rg \
  --name kiwi-tcms-db \
  --location eastus \
  --admin-user kiwi \
  --admin-password <your-db-password> \
  --sku-name Standard_B1ms \
  --tier Burstable \
  --version 14 \
  --storage-size 32

# Create the database
az postgres flexible-server db create \
  --resource-group kiwi-tcms-rg \
  --server-name kiwi-tcms-db \
  --database-name kiwi

# Allow Azure services to access the DB
az postgres flexible-server firewall-rule create \
  --resource-group kiwi-tcms-rg \
  --name kiwi-tcms-db \
  --rule-name AllowAllAzureIPs \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0
```

---

## 3. Create Azure Storage Account and File Share (for uploads/static files)
```bash
az storage account create \
  --name kiwitcmsstorage \
  --resource-group kiwi-tcms-rg \
  --location eastus \
  --sku Standard_LRS \
  --kind StorageV2

az storage share create \
  --name kiwitcms-uploads \
  --account-name kiwitcmsstorage

STORAGE_KEY=$(az storage account keys list \
  --resource-group kiwi-tcms-rg \
  --account-name kiwitcmsstorage \
  --query "[0].value" -o tsv)
```

---

## 4. Create App Service Plan and Web App for Containers
```bash
# App Service Plan (cheapest Linux tier)
az appservice plan create \
  --name kiwi-tcms-plan \
  --resource-group kiwi-tcms-rg \
  --sku B1 \
  --is-linux

# Web App for Containers
az webapp create \
  --resource-group kiwi-tcms-rg \
  --plan kiwi-tcms-plan \
  --name kiwi-tcms \
  --deployment-container-image-name pub.kiwitcms.eu/kiwitcms/kiwi:latest
```

---

## 5. Configure App Settings and Storage Mounts
```bash
# Set environment variables for Kiwi TCMS
db_host="kiwi-tcms-db.postgres.database.azure.com"
db_user="kiwi@kiwi-tcms-db"

az webapp config appsettings set \
  --resource-group kiwi-tcms-rg \
  --name kiwi-tcms \
  --settings \
  KIWI_DB_HOST="$db_host" \
  KIWI_DB_PORT="5432" \
  KIWI_DB_NAME="kiwi" \
  KIWI_DB_USER="$db_user" \
  KIWI_DB_PASSWORD="<your-db-password>" \
  WEBSITES_PORT=8080 \
  STATICFILES_DIRS="/Kiwi/custom_static"

# Mount Azure Files for uploads
az webapp config storage-account add \
  --resource-group kiwi-tcms-rg \
  --name kiwi-tcms \
  --custom-id uploads \
  --storage-type AzureFiles \
  --share-name kiwitcms-uploads \
  --account-name kiwitcmsstorage \
  --access-key $STORAGE_KEY \
  --mount-path /Kiwi/uploads
```

---

## 6. Deploy Custom Logo and CSS
```bash
# Prepare your custom_static directory
mkdir -p custom_static
cp <your-logo-file> custom_static/kiwi_h20.png
cp <your-css-file> custom_static/patternfly_override.css

# Zip and deploy to the app
zip -r custom_static.zip custom_static/
az webapp deployment source config-zip \
  --resource-group kiwi-tcms-rg \
  --name kiwi-tcms \
  --src custom_static.zip
```

---

## 7. Set Startup Command (if needed)
> **Note:** The official Kiwi TCMS container should start automatically. If you need to override, use:
```bash
az webapp config set \
  --resource-group kiwi-tcms-rg \
  --name kiwi-tcms \
  --startup-file ""
```
(Leave blank to use the container's default CMD/ENTRYPOINT.)

---

## 8. Initial Kiwi TCMS Setup
```bash
az webapp ssh --resource-group kiwi-tcms-rg --name kiwi-tcms

# Find the location of manage.py
find / -name manage.py

# cd to the directory containing manage.py (e.g., /Kiwi)
cd /Kiwi

python manage.py initial_setup
python manage.py set_domain kiwi-tcms.azurewebsites.net
python manage.py collectstatic --noinput
exit
```

---

## 9. (Optional) Add Custom Domain
```bash
az webapp config hostname add \
  --resource-group kiwi-tcms-rg \
  --webapp-name kiwi-tcms \
  --hostname <your-custom-domain>

# Update Kiwi TCMS domain
az webapp ssh --resource-group kiwi-tcms-rg --name kiwi-tcms
cd /Kiwi
python manage.py set_domain <your-custom-domain>
exit
```

---

## 10. Verify Deployment
```bash
az webapp show --resource-group kiwi-tcms-rg --name kiwi-tcms
az webapp log tail --resource-group kiwi-tcms-rg --name kiwi-tcms
```

---

## 11. Update Customizations
```bash
# Update CSS/logo and redeploy
zip -r custom_static.zip custom_static/
az webapp deployment source config-zip \
  --resource-group kiwi-tcms-rg \
  --name kiwi-tcms \
  --src custom_static.zip
```

---

## 12. Cost Optimization Tips
- Use the lowest App Service and DB tiers for dev/test
- Monitor usage and scale up only if needed
- Clean up unused resources

---

## 13. Troubleshooting
- Use `az webapp log tail` to view logs
- Use `az webapp ssh` to debug inside the container
- Ensure all environment variables are set correctly
- Check Azure Portal for error messages

---

**You now have a cost-effective, production-ready Kiwi TCMS deployment on Azure with PostgreSQL Flexible Server and your custom branding!** 