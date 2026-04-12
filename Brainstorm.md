# CST-380 Group Project Unit 7 Milestones
===

## Favorite Existing Apps - List
1. Instagram
1. Apple Maps
1. Yelp
1. Pinterest
1. Quora
1. GuitarTuna
1. QeoGuesser
1. MyFitnessPal
1. Threads
1. Peerspace

## New App Ideas - List
1. Local Deals Live Map  
   Lets locals help each other discover deals/sales around them. Users can see a live map that has pinned points for restaurants and stores that are having sales. Each pin would have quick info like the name of the establishment, discount type, and expiration.

3. Fitness Accountability  
   Helps people on their fitness journey keep each other accountable, whether that be in their diet or in their activities. Based on the user's input, they would be matched with users with similar goals and be provided a platform where they can communicate, track their activities and diet to compare, and challenge each other (friendly competition)

6. Food Truck Tracker  

4. Personal Energy Usage Tracker  
   Tracks your home or device energy consumption in real time. Helps users identify when and where they're using the most power, suggests ways to cut costs, and monitors usage trends over time.

5. Live Job Progress Tracker for Hired Services  
   A real-time status tracker for handymen, mechanics, contractors, and other hired help. Clients get live updates as work progresses (e.g., "Now working on: brake replacement - estimated time: 45 min, estimated cost: $180"). Similar to how DoorDash tracks your delivery, but for service jobs.

---

## Top 3 New App Ideas
1. Local Deals Live Map
2. Fitness Accountability
3. Food Truck Tracker

---

## New App Ideas - Evaluate and Categorize

### 1. Local Deals Live Map
- **Description**: Lets locals help each other discover deals/sales around them. Users can see a live map that has pinned points for restaurants and stores that are having sales. Each pin would have quick info like the name of the establishment, discount type, and expiration.
- **Category:** Community-driven map app
- **Mobile:** Mobile is essential for the smooth browsing of the live map and for the instant logging of deals. Can also use location services, push notifications, and camera features.
- **Story:** People frequently miss out on nearby deals because promotions are scattered or hard to discover. This app helps people be more aware of local deals in an interactive way.
- **Market:** Any person in Monterey County (initially) could utilize this app, with potential to expand to other regions.
- **Habit:** Locals are using this a couple of days a week to see how they can save money by taking advantage of local deals.
- **Scope:**  
  V1 would allow users to see a map with prepopulated pins of establishments having limited sales.  
  V2 would let users enter deals and place a pin on the map with the establishment's name, discount type, and expiration date.  
  V3 would let users upvote valid deals and downvote invalid ones.  
  V4 would incorporate the camera so that users can take photos of banners and posters related to the deals.  
  V5 (stretch) could include notifications and personalized deal recommendations.  
  V6 (stretch) could include AI-assisted deal discovery or customization based on user preferences.
- **API:**  
  Maps can be implemented using Google Maps SDK or Apple MapKit.  
  Deal data could come from coupon/deal APIs such as Groupon, RetailMeNot, or RapidAPI-based services.  
  If APIs are limited, the app can start with mock or manually entered data.  
  Firebase can serve as the backend for storing user-submitted deals, votes, and images in real time.  
  There is also potential integration with Gemini to help users find deals faster, summarize local offers, or customize recommendations based on user interests and behavior.

---

### 2. Fitness Accountability
- **Description**: Helps people on their fitness journey keep each other accountable, whether that be in their diet or in their activities. Users are matched with others with similar goals and can communicate, track activities and diet, and challenge each other.
- **Category:** Health & Fitness / Social
- **Mobile:** Mobile is important for tracking workouts, sending reminders through push notifications, and enabling real-time communication. Could integrate with device health tracking features.
- **Story:** Many people struggle to stay consistent with fitness goals. This app motivates users through accountability partners and friendly competition.
- **Market:** Large market of people interested in fitness and self-improvement. However, it is competitive with many existing apps.
- **Habit:** Very habit-forming. Users would likely open the app daily to log workouts, track diet, and communicate with partners.
- **Scope:**  
  V1 would include basic profiles and activity tracking.  
  V2 would introduce matching users with similar goals.  
  V3 would add messaging and challenges.  
  V4 would include diet tracking and analytics.
- **API:**  
  Could use nutrition APIs such as Nutritionix for diet tracking.  
  Could integrate with Apple HealthKit for activity data.  
  Firebase or similar backend could support messaging and real-time updates.

---

### 3. Food Truck Tracker
- **Description**: Allows users to find nearby food trucks in real time, including their locations, menus, and hours.
- **Category:** Food & Drink / Lifestyle
- **Mobile:** Strong mobile use case with GPS/location tracking, maps, and real-time updates. Push notifications can alert users when food trucks are nearby.
- **Story:** Food trucks move frequently, making them hard to find. This app provides an easy way for users to discover and track them in real time.
- **Market:** Niche but strong market, especially in cities, college towns, and event-heavy areas.
- **Habit:** Users may check the app a few times a week, especially during meal times or when looking for new food options.
- **Scope:**  
  V1 would include a map with static food truck locations.  
  V2 would allow real-time updates (manual or owner-submitted).  
  V3 would add menus, ratings, and reviews.  
  V4 would include notifications for nearby or favorite trucks.
- **API:**  
  Maps can be implemented using Google Maps SDK or Apple MapKit.  
  Yelp API or similar could provide business and food data.  
  Firebase or a custom backend could handle real-time location updates.

---

## Final App Choice
### Local Deals Live Map

- **Reasoning:**  
  This idea offers the best balance of strong mobile features, clear user value, and manageable scope. It leverages location services, maps, and real-time data, making it more than just a simple website. Compared to the other ideas, it is easier to build a functional MVP while still being useful and expandable.  

  Additionally, this app allows us to apply a wide range of tools and concepts learned in CodePath, including working with APIs, integrating maps and location services, handling user-generated content, using Firebase as a backend for deal storage and updates, and potentially implementing real-time updates and push notifications. It also leaves room for future AI integration with Gemini to help users discover or personalize deals. This makes it both a practical and educational choice that reinforces multiple core mobile development skills.
