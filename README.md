# Expiration Date Tracker

As a college student at UCLA, I noticed that I had trouble remembering when the products in my fridge and pantry were expiring. To help me stay on top of my ingriedients in the kitchen, I created an IOS app that tracks the expiration dates of my items in my fridge, freezer, and pantry to help me not only stop wasting food but also save me money.

# Tech Used

Swift, SwiftUI, Firebase Realtime Database, Firebase Authentication, Firebase Cloud functions, TypeScript, JavaScript, HTML, NodeJS, Google Cloud Platform

# Screenshots:

<p align="middle">
  <img src="https://user-images.githubusercontent.com/112910934/214775515-e83795cd-4f89-4111-a97a-80e8b5606847.png" width="200" alt="Screenshot of the Home Screen" />
  <img height="" hspace="30"/>
  <img src="https://user-images.githubusercontent.com/112910934/214775522-7fb20670-6d7b-4d11-bc6b-950644853dd3.png" width="200" alt="Screenshot of the Pantry Screen" />
  <img height="" hspace="30"/>
  <img src="https://user-images.githubusercontent.com/112910934/214775449-dcb36d46-951a-4fb6-8d09-9d7bff5c2e1e.png" width="200" alt="Screenshot of the Edit Item Screen" />
</p>

# Key Features

-  Each user and their respective items are stored in a Firebase Realtime Database 
-  Items are separated into 3 different locations: Fridge, Freezer, and Pantry
-  Items may be sorted by alphabetical order, by their expiration date, or by the date of when the items were added into the app
-  The Home tab has 3 collapsible lists: Items Already Expired, Items Expiring in 1 Week, and All Items
-  An on-tap gesture on any item brings up a pop-up view to edit the item name, quantity, expiration date, and item location
-  All changes in the IOS app will appear on any other connected devices in realtime
-  Every Saturday night, an email is sent to each user listing their items that are expired or are expiring within the upcoming week
