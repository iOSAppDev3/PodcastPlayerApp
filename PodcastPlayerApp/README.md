# PodcastPlayerApp

A simple iOS podcast player built using SwiftUI. The app allows users to view podcasts and their episodes, and interact with a basic audio player interface.

## Features

* View list of podcasts with image,title
* View podcast details and list of episodes with play button
    * Podcast Detail view with title, author and description
    * List of episodes for the selected podcast with title and description, date, duration and play button
* Play an episode (mini audio player with basic playback controls) and player states
* Full screen audio player 
    * Play / Pause functionality 
    * Seek bar with playback progress UI
* Clean, responsive UI following Apple design guidelines
* Loading and error state handling
* Using Swift language and SwiftUI
* Built with MVVM architecture
* Unit test testing covered 90% of functionality using XCTest and ViewInspector


## Architecture

This project uses SwiftUI and MVVM 

- Service : API calls, Json parsing, audio playblack
- Models: domain models 
- ViewModels: state and UI logic
- Views - Screens and reusable components

## API 

This app uses https://the-podcasts.fly.dev/swagger/index.html#/ 
Podcast Swagger UI to fetch podcasts and podcast's episodes

## How to run
1. Open PodcastPlayerApp.xcodeproj file using xcode
2. Build and run on an iOS Simulator running iOS 17+
3. Ensure these frameworks are available in Packages SPM or reset package cache
    * KingFisher
    * ViewInspector
    

## Error handling

The app handles:

- invalid or missing feed URLs
- network failures
- empty podcast results
- feeds with missing audio URLs
- unexpected parsing/decoding issues

## Third-party libraries

* KingFisher 
    - Prevents re-downloading images in lists
    - Resizes the image before it’s loaded into memory
    - Smoother UX in grids and fast scrolling UI
    - Saves bandwidth Cancels download when view goes off-screen
    - Better performance and layout control
* ViewInspector
    - verify UI content and dynamic UI updates
    - simulate user actions
    - works with MVVM
    
