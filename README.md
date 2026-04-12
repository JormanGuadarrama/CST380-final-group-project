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

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User can view nearby deals displayed as pins on a map  
* User can tap on a pin to view deal details (name, discount, expiration)  
* User can add a new deal with location, description, and expiration  
* User can view the map centered around their current location  

**Optional Nice-to-have Stories**

* User can upvote or downvote deals to verify accuracy  
* User can upload photos of deals using their camera  
* User can receive push notifications when deals are nearby  
* User can create an account to track their contributions  
* User can save/bookmark deals or locations for later viewing  
* User can receive AI-based deal recommendations (Gemini integration)  

### 2. Screen Archetypes

- [ ] **Map Screen (Home)**
* Required User Feature: User can view nearby deals on a map  
* Required User Feature: User can tap a deal pin to view details  

- [ ] **Deal Detail Screen**
* Required User Feature: User can view detailed information about a deal  
* Optional User Feature: User can save/bookmark a deal  

- [ ] **Add Deal Screen**
* Required User Feature: User can submit a new deal  

- [ ] **Profile Screen**
* Optional User Feature: User can view saved/bookmarked deals  
* Optional User Feature: User can view previously submitted deals  

### 3. Navigation

**Tab Navigation** (Tab to Screen)

- [ ] Map (Home)  
- [ ] Add Deal  
- [ ] Profile  

**Flow Navigation** (Screen to Screen)

- [ ] **Map Screen**
  * Leads to **Deal Detail Screen** (tap a pin)  
  * Leads to **Add Deal Screen** (tap add button)  

- [ ] **Deal Detail Screen**
  * Leads to **Map Screen** (back)  
  * Leads to **Profile Screen** (if saving/viewing saved deals)  

- [ ] **Add Deal Screen**
  * Leads to **Map Screen** (after submission or cancel)  

- [ ] **Profile Screen**
  * Leads to **Deal Detail Screen** (view saved or posted deals)  

## Wireframes

[Add picture of your hand sketched wireframes in this section]

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
