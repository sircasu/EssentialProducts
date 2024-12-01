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
- And the cache is less than seven days old
- When the customer request to see the products  
- The app should display the latest products saved  

- Given the customer does not have connectivity  
- And there's a cache version of products  
- And the cache is  seven days old or more
- When the customer request to see the products  
- The app should display an error message 
  
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
4. System creates product items from valid data. 
5. System delivers product items.  
  
Invalida data - error course (sad apath)  
  
1. System delivers error.  
  
No connectiivty - error course (sad path):  
  
1. System delivers error  
  
  
**\|\| Load product from cache use case**  

Primary course (happy path):  
  
1. Execute "Load Product Items" command with above data.
2. System retrieves product data from cache.
3. System validates caches is less than seven years old.
4. System creates product items from cache data. 
5. System delivers product items.  

Retrieval error course (sad path)

1. System deletes cache.
2. System delivers error.

Expired cache (sad path)

1. System deletes cache.
2. System delivers no products.

Empty cache - error course (sad apath)  
  
1. System delivers no products.  
  
  
**\|\| Cache product use case**  
  
**Data: **Product items  
  
Primary course (happy path):  
  
1. Execute "Save Product Items" command with above data.  
2. System deletes old cache data.
3. System encode product items.  
4. System timestamps the new cache.
5. System save new cache data.  
6. System delivers a success message.  
  
Deleting Error course (sad path):

1. System delivers error.

Saving Error course (sad path):

1. System delivers error.

---

API Contract

Products - Get
```
[
    {
        "id": 1,
        "title": "Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops",
        "price": 109.95,
        "description": "Your perfect pack for everyday use and walks in the forest. Stash your laptop (up to 15 inches) in the padded sleeve, your everyday",
        "category": "men's clothing",
        "image": "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg",
        "rating": {
            "rate": 3.9,
            "count": 120
        }
    },
    {
        "id": 2,
        "title": "Mens Casual Premium Slim Fit T-Shirts ",
        "price": 22.3,
        "description": "Slim-fitting style, contrast raglan long sleeve, three-button henley placket, light weight & soft fabric for breathable and comfortable wearing. And Solid stitched shirts with round neck made for durability and a great fit for casual fashion wear and diehard baseball fans. The Henley style round neckline includes a three-button placket.",
        "category": "men's clothing",
        "image": "https://fakestoreapi.com/img/71-3HjGNDUL._AC_SY879._SX._UX._SY._UY_.jpg",
        "rating": {
            "rate": 4.1,
            "count": 259
        }
    }
    ...
]
```
