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

### 7. Final Docker Compose Configuration
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

### 8. Final Steps to Start the System
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

### 9. Accessing Kiwi TCMS
- HTTP: `http://localhost:8080`
- HTTPS: `https://localhost:443`

### 10. Useful Commands for Management
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
### 5. Test Run \- Test Executions   
   1. Once all Test Cases are added to Test Run, they can be executed   
      1. Click "Started at:" button to indicate Test Run has begun   
      2. Run thru Test Cases for execution   
         1. Expand Test Case   
         2. Enter results of test into textarea   
         3. Optionally attach files/screen shots   
         4. Mark result of test execution- ex. "PASSED", "FAILED", etc   
      3. After all test cases \- "Finished at" should update \- if not set to now
