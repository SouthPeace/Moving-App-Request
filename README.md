Moving App Request - Mobile Application (Requester Version)
(note: conceptualization app, not pollished app, only corefunctionality)

Description:
Developed the requester version of a robust mobile application for a moving company, enabling users to order, request, and schedule moving services. 
The app offers a comprehensive and user-friendly experience, allowing customers to manage their moving needs efficiently.

Key Features:

Service Booking & Scheduling: Users can book and schedule moving services tailored to their needs, with options for preset trips.
Repeat Request Feature: Added a dynamic feature enabling users to place additional requests if the initially booked trips are insufficient, ensuring flexibility and satisfaction.
Live Tracking: Integrated real-time tracking of the driver's location and the user's contents, providing transparency and peace of mind.
Notifications: Implemented push notifications to keep users informed about the status of their move, including updates on the driver's progress.
Intuitive User Interface: Designed with ease of use in mind, offering a booking and tracking experience.

Technologies & Packages:

Real-Time Communication: Leveraged socket_io_client to enable real-time, bidirectional communication between users and the backend server, ensuring instant updates and responsiveness throughout the moving process.
Google Maps Integration: Used google_maps_flutter, flutter_polyline_points, and google_geocoding to implement real-time map tracking and route visualization.
Location Services: Leveraged the location package for accurate GPS tracking of drivers.
Push Notifications: Implemented with firebase_messaging and flutter_local_notifications for timely updates and alerts.
UI Enhancements: Employed flutter_svg for high-quality vector graphics, sliding_up_panel for interactive elements, and url_launcher for seamless external link handling.
Backend Connectivity: Utilized http for REST API calls and rxdart for reactive programming.
Cross-Platform Development: Built using Flutter and Dart, ensuring a consistent and performant experience across both Android and iOS devices.
Note: This version of the app is specifically designed for users (requesters) looking to book moving services. A separate version of the app exists for drivers to manage and fulfill these requests.

[![Demo app showcase](https://github.com/SouthPeace/Moving-App-Request/tree/main/media/location details.png)](https://youtu.be/c-SMFXBvXJQ)

