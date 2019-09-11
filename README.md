# exampleApp
Documentation and example app to show the usage of the Evomo MotionAI SDK.

## TheEvomo MotionAI SDK
### Functionality
- Classify movement in realtime
- deliver heart rate
- Classify sensorposition while running
### Sensors
- iPhone
- Movesense
- Artificial (Simulated for debugging)
### Platform
- iOS

## How to install
Installation of iOS/Swift Frameworks via CocoaPods (Precompiled)

1. Add private repo
```shell
pod repo add evomopods git@bitbucket.org:evomo/evomopods.git    
```
2. Add to podfile
```ruby
# suppress the UUIDs warnings
install! 'cocoapods', :deterministic_uuids => false

# Insert your own private specs repo source
source 'git@bitbucket.org:evomo/evomopods.git'
# Standard cocoapods specs source
source 'https://github.com/CocoaPods/Specs.git'

target 'YourTarget' do
  
  platform :ios, '12.1'
  use_frameworks!
  pod "EVOFoundation/Binary", :git => 'git@bitbucket.org:evomo/evofoundationbinary.git', :tag => '6.0.1'
  pod "EVORecording/Binary", :git => 'git@bitbucket.org:evomo/evorecordingbinary.git', :tag => '6.0.2'
  pod "EVOClassificationKit/Binary", :git => 'git@bitbucket.org:evomo/evoclassificationkitbinary.git', :tag => '6.0.0'
  pod "EVOControlLayer/Binary",  :git => 'git@bitbucket.org:evomo/evocontrollayerbinary.git', :tag => '6.0.0'

end
```
Note: logical operators or optimistic operators don't work for the tag in this case. So the tag must be manual incremented on version changes. 

## General Access API

### Initialise the EVOControlLayer
```swift
import EVOControlLayer
import PromiseKit
import EVOFoundation

// Init the ClassificationControlLayer
let controlLayer = ClassificationControlLayer.shared
```

### Setup the source device
```swift
// Define sensor device
// 1. Option coremotion _ device sensor data
controlLayer.device = Device(deviceID: "", // String not important
                             deviceType: .iPhone,
                             devicePosition: .leftUpperArm, 
                             // Position of the smartphone: .belly or .leftUpperArm
                             deviceOrientation: .buttonDown) 
                             // Orientation of the smartphone: .buttonDown, .buttonUp, buttonLeft, or .buttonRight (display always points away from the body)

// 2. Option .artificial -> simulate device sensor (helpful to debug in simulator)
// Note: Wait about 5 seconds for the first movement after starting
//     + The artificial source for simulation only works with belly-based classification models
controlLayer.device = Device(deviceID: WorkoutFile.jumpingJacks.rawValue, // options: .jumpingJacks, .squats, .sixerSets, .running
                             deviceType: .artificial,
                             devicePosition: .belly, // <- do not change for artificial
                             deviceOrientation: .buttonRight)// <- do not change for artificial
```
# Define the classification model
```swift
// Define classification model
controlLayer.classificationModel = .belly 
// options: .belly(default), .leftUpperArm, specific(Int) <- Inset a testRun id to select a specific model
```

### Setup the subscriptions
```swift
// Subscribe to the classified movements
controlLayer.movementHandler = { movement in
	// Do something with the classified movements in time
}

// Handle heart rate changes
ClassificationControlLayer.shared.heartRateSubHandler = { hr in
    // Do something with the heart rate
}
```
### Start and stop movement classification


### Device position classification



![](/Documentation/Media/StartScreen.PNG)

