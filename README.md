# Glauc-At-Home-A

## Technical Documentation

### Purpose of the application:

#### Introduction
Glac-at-home-a is an application that is currently in the development stages but is being used in an National Science Foundation (NSF) funded grant research program. The goal of the research project is to create a device for at-home intraocular pressure reading (IOP) that will then send the data to a mobile phone so that the data can be viewed, and shipped to a server. The theoretical device which has not yet been fully developed would connect to the phone via Bluetooth Low Energy (BLE).

#### Aid Development Process
Since at the current moment the intraocular pressure reading device is still in development, the engineers fabricating the device need a software solution to aid their development and debugging process along with having a baseline starting point for when the device will be used more extensively in the beta testing phase of the project.

### Main Features
Most features are set up to assist with the development of the physical device associated with this applciation and are not optimized for end user use; although the foundations and functionality are built into this application and can be easily ported over for end user use in the future.

The main features that were implemented in this application are as follows:

1. Bluetooth Low Energy Central and Peripheral Connection
2. Automatically identifying UUIDs, Services, and Characteristics for BLE transmission
3. Bluetooth data collection
4. Sending and Receiving data from the server
5. Record observations on the server
6. Display observations in graphical form to the user
7. Data is exchanged between the application and the user
8. Data View to visualize IOP data
9. Home View to start IOP test and record observations

### Developer Quick Start

#### How to build the application

#### Developer Account
In order to build the application with all of its features an Apple Developer account is needed. To purchase an apple developer account please visit developer.apple.com

#### Commands to Build

`git clone (insert repo here)` \
`git submodule init` \
`git submodule update` \
`Open Xcode Project` \
`Sign in with developer account in Xcode` \
`Click the build button in Xcode, it looks like a play symbol in the top left of Xcode.` \

#### Software Desgin Overview

##### MVC Architecture
![mvc](https://user-images.githubusercontent.com/67076014/182691878-1b40eb67-800a-4a30-ac28-1b5ce468476c.png)
\
\
The MVC architecture was central to the software design. MVC is commonly used for UI desgin and web applications and defines the flow of the application. The Model acts as the backbone of the code and manages the data of the application and is in charge of updating the View. The View displays the information the user needs to see, depending on imput from the Model. The Controller recieves user input and can send the relevant information to the Model. The fundamental idea is that the controller does not affect to the view directly.

##### Software Files
![software_files](https://github.com/user-attachments/assets/695fa1cd-43c9-433e-8b99-eceb4c7b9339)
\
\
The software files, shown above, provide a little more insight into the actual implementation of the MVC methods for the app. 
\
\
In the Base folder, the Main.storyboard file provides a benchmark for the user interface (UI). This is where future work for new pages in the application should start. Buttons, lists, graphs,etc. can be created here by adding a new view to the storyboard. Future development on application flow (the order in which the views are shown) begins here as well.
\
\
In the Controllers folder, the files each represent a "view". Each of these views use different libraries to display information on the screen. They each take in user input and handle it, and any relavant data is stored persistently. User inputs, such as navigating to different pages is also handled within each view. ViewController is the initial view where the user can connect to the BLE peripheral. ConsoleViewController is the view in which the data sent and recieved is shown. GraphViewController displays the data recieved during the application's use.
\
\
The Model folder contains files that hold information about the BLE device peripheral. Most notably, it saves the CBUUIDs which tell the phone which device to connect to. As the scope of this project increases, there could be several CBUUIDs for each user.
\
\
Finally, the View folder contains the outline for a table cell view. This is simply a way to display information that the controller uses to show the console. It's an easy way for the incoming and outgoing data to be displayed. Any other display options moving forward in the application design process can be outlined in this folder.

### Future Development (And Known Issues)
1. Login and user verification process
2. User and Server Account Creation
3. Delete user
4. Delete observations
5. Settings with accesibility and health features to benefit user experience
6. Debug mode for developers
7. Setting time ranges for viewing observations
8. Implement SMART OAuth between the server and client
9. Implement proper error handling
10. A logger for logging events
11. Add more user functionality for getting and using data.
12. During very very slow internet connectivity the device may not respond, this is a rare occurance.
13. If you delete all observation or the patient you need to restart the application
14. Link incoming data to DataView2
15. Add functionality to all options for settings

#### How to Integrate a new Firebase Database

In order to communicate with a new Firebase database, follow the steps outlined here: 
https://github.com/MayasaurusRex/Glaucoma-App/blob/main/IntegrateFirebase.pdf

#### How to Dynamically Update Firebase Fields

To update Firebase fields to match the current device settings and reading values, follow the steps outlined here:
https://github.com/MayasaurusRex/Glaucoma-App/blob/main/DynamicallyUpdatingFirebaseFields.pdf

## Helpful links

This repository is an update/continuation of this project: https://github.com/cchriskeach/Glaucoma-App 

Other helpful sources throughout the project:
1. https://www.swift.org/getting-started/swiftui/ 
2. https://firebase.google.com/docs/ios/setup
3. https://medium.com/theleanprogrammer/connecting-firebase-6102ef4eca08
4. https://firebase.google.com/docs/firestore/query-data/get-data
