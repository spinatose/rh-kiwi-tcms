# rh-kiwi-tcms
Branded version of Kiwi TCMS Docker Swarm

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
