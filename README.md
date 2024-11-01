Products Feature  
  
BDD Specs  
  
Scenarios  
  
  
Story: Customer requests to see the products  
  
Narrative \#1  
- As an online customer  
- I want the app to automatically load my latest products  
- So I can always show the see products  
  
Scenarios (Acceptance criteria)  
- Given the customer has connectivity  
- When the customer requests to see the products  
- Then the app should display the latest products from remote  
- And replace the cache with the new products  
  
  
Narrative \#2  
- As an offline customer  
- I want the app to show the latest saved version of my products  
- So I can always see products  
  
Scenarios (Acceptance criteria)  
- Given the customer does not have connectivity  
- And there's a cache version of products  
- When the customer request to see the products  
- The app should display the latest products saved  
  
- Given the customer does not have connectivity  
- And the cache is empty  
- When the customer request to see the products  
- The app should display an error message  
  
------  
  
Use Cases  
  
**\|\| Load products use case **  
  
**Data: **URL  
  
Primary course (happy path):  
  
1. Execute "Load Product Items" command with above data,  
2. System downloads data from the URL.  
3. System validates downloaded data.  
4. System creates product items from valid data,  
5. System delivers product items.  
  
Invalida data - error course (sad apath)  
  
1. System delivers error.  
  
No connectiivty - error course (sad path):  
  
1. System delivers error  
  
-  
  
**\|\| Load product fallback (cache) use case**  
  
**Data: **Max age  
  
Primary course (happy path):  
  
1. Execute "Load Product Items" command with above data,  
2. System fetches product data from cache  
3. System creates product items from cache  
4. System delivers product items  
  
No cache - error course (sad apath)  
  
1. System delivers no products.  
  
-  
  
**\|\| Save product items use case**  
  
**Data: **Product items  
  
Primary course (happy path):  
  
1. Execute "Save Product Items" command with above data,  
2. System encode product items  
3. System timestamps the new cache  
4. System replace cache with new data  
5. System delivers a success message  
  
  

