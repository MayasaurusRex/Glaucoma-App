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
1. Login and user verification process
2. User and Server Account Creation
3. Bluetooth Low Energy Central and Peripheral Connection
4. Automatically identifying UUIDs, Services, and Characteristics for BLE transmission
6. Bluetooth data collection
7. Sending and Receiving data from the server
8. Delete user
9. Record observations on the server
10. Delete observations
11. Display observations in graphical form to the user
12. Data is exchanged between the application and the user
13. Data View to visualize IOP data
14. Home View to start IOP test and record observations
15. Settings with accesibility and health features to benefit user experience
16. Debug mode for developers
17. Setting time ranges for viewing observations

### Developer Quick Start

#### How to build the application

#### Developer Account
In order to build the application with all of its features an Apple Developer account is needed. To purchase an apple developer account please visit developer.apple.com

#### Commands to Build

`git clone (insert repo here)`
`git submodule init`
`git submodule update`
`Open Xcode Project`
`Sign in with developer account in Xcode`
`Click the build button in Xcode, it looks like a play symbol in the top left of Xcode.`

#### Software Desgin Overview

##### MVC Architecture
![mvc](https://user-images.githubusercontent.com/67076014/182691878-1b40eb67-800a-4a30-ac28-1b5ce468476c.png)
\
\
The MVC architecture was central to my software design. MVC is commonly used for UI desgin and web applications and defines the flow of the application. The Model acts as the backbone of the code and manages the data of the application and is in charge of updating the View. The View displays the information the user needs to see, depending on imput from the Model. The Controller recieves user input and can send the relevant information to the Model. The fundamental idea is that the controller does not affect to the view directly.

##### Software Files
