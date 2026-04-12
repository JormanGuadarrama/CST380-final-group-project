Original App Design Project - README Template
===

# Local Deals Live Map

## Table of Contents

1. [Overview](#Overview)
2. [Product Spec](#Product-Spec)
3. [Wireframes](#Wireframes)
4. [Schema](#Schema)

## Overview

### Description

Local Deals Live Map is a community-driven mobile app that helps users discover nearby deals and discounts in real time. Users can view deals on an interactive map, submit their own deals, and see important details such as discount type and expiration. The app centralizes local savings opportunities that are often hard to find.

### App Evaluation

- **Category:** Lifestyle / Community-driven map app  
- **Mobile:** Mobile-first application that uses maps, GPS/location services, camera (for deal photos), and push notifications  
- **Story:** People frequently miss nearby deals because promotions are scattered or only visible in-store. This app helps users discover and share local deals in one centralized platform  
- **Market:** Broad audience of local shoppers, starting with Monterey County and scalable to other regions  
- **Habit:** Users may check the app multiple times per week when planning purchases; contributors may use it more frequently  
- **Scope:** Narrow initial scope (map + deals), with clear expansion opportunities such as voting, saved deals, notifications, and AI-powered recommendations  

Product spec · MD
# Product Spec
 
---
 
## 1. User Stories
 
### Required Must-Have Stories
 
* User can view nearby deals displayed as pins on a map within a 10-mile radius of a location they plan to be around or want to go to, with traffic and walking time factored into results
* User can tap on a pin to view a deal card where the most important information — discount amount, store name, and expiration — is visually prioritized so it can be understood at a fast glance, with additional details available below
* User can add a new deal with location, description, and expiration — new deals are visible to all users when they are nearby or when the deal matches a filter they search with
 
### Optional Nice-to-Have Stories
 
Difficulty is rated using **Fibonacci Story Points**, the industry-standard Agile estimation scale:
`1` = trivial · `3` = simple · `5` = moderate · `8` = complex · `13` = large/high effort · `21` = very large, consider breaking apart
 
* **5 pts** — User can upvote or downvote deals to verify accuracy — requires vote tracking, duplicate vote prevention, and updating deal credibility scores
* **8 pts** — User can upload photos of deals using their camera — requires device camera API access, image compression, and cloud storage integration
* **13 pts** — User can receive push notifications when deals are nearby — requires background location monitoring, notification scheduling, and a push delivery service
* **8 pts** — User can create an account to track their contributions; guest browsing is available with extreme limitations on content creation — requires full auth system (login, session management, roles)
* **3 pts** — User can save/bookmark deals — saved cards update to reflect expiration status and display the date the user saved them — requires persistent local or cloud storage with time-aware state
* **13 pts** — User can receive AI-based deal recommendations (Gemini integration) — requires prompt engineering, API integration, and personalization logic based on user behavior
 
---
 
## 2. Screen Archetypes
 
- [ ] **Map Screen (Home)**
  * Required: User can view nearby deals on a map
  * Required: User can tap a deal pin to view details
 
```
+----------------------------------------------------------+
|  📍 Enter a location... Current          [ 🔍 Search ] |
+----------------------------------------------------------+
|                                                          |
|        .  .  .  .  .  .  .  .  .  .  .  .  .  .        |
|      .                                             .      |
|    .         📌 Starbucks                           .    |
|   .          (25% off)                               .   |
|  .                                                    .  |
|  .                    📌 Target                       .  |
|  .                    (BOGO)                          .  |
|  .                                                    .  |
|   .              ★ YOU ARE HERE ★                    .   |
|    .                                                .    |
|    .      📌 Chipotle                               .    |
|     .     ($5 bowl)                               .      |
|       .                                         .        |
|         .  .  .  .  .  .  .  .  .  .  .  .  .          |
|                                          [ + Add Deal ]  |
+----------------------------------------------------------+
|  [   🗺  Map   ]    [  ➕  Add Deal  ]   [  👤 Profile ] |
+----------------------------------------------------------+
```
 
- [ ] **Deal Detail Screen**
  * Required: User can view detailed information about a deal
  * Optional: User can save/bookmark a deal
 
- [ ] **Add Deal Screen**
  * Required: User can submit a new deal
 
- [ ] **Profile Screen**
  * Optional: User can view saved/bookmarked deals
  * Optional: User can view previously submitted deals
 
---
 
## 3. Navigation
 
### Tab Navigation
 
```
+------------------------------------------+
|                                          |
|              [Screen Content]            |
|                                          |
+------------------------------------------+
|  [  Map  ]   [ + Add Deal ]  [ Profile ] |
+------------------------------------------+
```
 
```
+------------------------------------------+
|  Deal Card View                          |
|  +------------------------------------+  |
|  |  Store Name         💾 Save        |  |
|  |  📍 0.3 mi  |  ⏱ 5 min walk       |  |
|  |  20% off all items                 |  |
|  |  Expires: Apr 18, 2026             |  |
|  +------------------------------------+  |
|  +------------------------------------+  |
|  |  Store Name         💾 Save        |  |
|  |  📍 1.1 mi  |  🚗 4 min drive      |  |
|  |  Buy 1 Get 1 Free                  |  |
|  |  Expires: Apr 20, 2026             |  |
|  +------------------------------------+  |
+------------------------------------------+
|  [  Map  ]   [ + Add Deal ]  [ Profile ] |
+------------------------------------------+
```
 
---
 
### Flow Navigation
 
**Map Screen**
```
[ Map Screen ]
      |
      |-- (tap a pin) ---------> [ Deal Detail Screen ]
      |
      +-- (tap add button) ----> [ Add Deal Screen ]
```
 
**Deal Detail Screen**
```
[ Deal Detail Screen ]
      |
      |-- (back) --------------> [ Map Screen ]
      |
      +-- (save/view saved) ---> [ Profile Screen ]
```
 
**Add Deal Screen**
```
[ Add Deal Screen ]
      |
      +-- (submit or cancel) --> [ Map Screen ]
```
 
**Profile Screen**
```
[ Profile Screen ]
      |
      +-- (tap saved/posted) --> [ Deal Detail Screen ]
```
 
---
 
## Wireframes

<img src="images/wireframe_image.jpg" width=600>
 
### [BONUS] Digital Wireframes & Mockups
 
### [BONUS] Interactive Prototype

## Schema 

> ⚠️ Note: The following schema is preliminary and subject to change as the app design evolves. It represents our current brainstorming and may be refined during implementation.

### Models

**Deal**
| Property     | Type    | Description                                      |
|--------------|---------|--------------------------------------------------|
| id           | String  | unique identifier for the deal                   |
| title        | String  | name of the deal or business                     |
| description  | String  | details about the deal                           |
| latitude     | Double  | location latitude                                |
| longitude    | Double  | location longitude                               |
| discountType | String  | type of discount (e.g., %, BOGO)                 |
| expiration   | Date    | expiration date of the deal                      |
| imageUrl     | String  | optional image of the deal                       |
| votes        | Int     | upvote/downvote score                            |

**User (Optional)**
| Property | Type   | Description                          |
|----------|--------|--------------------------------------|
| id       | String | unique user id                       |
| username | String | user's display name                  |
| email    | String | user's email                         |

**SavedDeal (Optional)**
| Property | Type   | Description                          |
|----------|--------|--------------------------------------|
| userId   | String | reference to user                    |
| dealId   | String | reference to saved deal              |

### Networking

- **Map Screen**
  - `[GET] /deals` - retrieve all deals for map display  

- **Deal Detail Screen**
  - `[GET] /deals/:id` - retrieve details for a specific deal  

- **Add Deal Screen**
  - `[POST] /deals` - submit a new deal  

- **Voting (Optional)**
  - `[POST] /deals/:id/vote` - upvote/downvote a deal  

- **Saved Deals (Optional)**
  - `[POST] /saved` - save/bookmark a deal  
  - `[GET] /saved` - retrieve saved deals for a user  

- **Image Upload (Optional)**
  - `[POST] /upload` - upload deal image  

- **External APIs**
  - Coupon/Deals APIs (Groupon, RetailMeNot, RapidAPI)  
  - Maps API (Google Maps SDK or Apple MapKit)  
