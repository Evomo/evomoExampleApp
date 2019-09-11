# exampleApp
Documentation and example app X-Code project to show the usage of the Evomo MotionAI SDK.

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

The Evomo Movement Classification Engine consist of four precompiled Cocoa Touch Frameworks.
All four frameworks must be integrated in the Xcode project, but only the **EVOControlLayer** is needed to control the movement classification.

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

# post install to add movesense libmds.a library to project.
post_install do |installer|
  
  lib_name = "libmds.a"
  lib_path = "Movesense/IOS/Movesense/Release-iphoneos"
  
  # get ref of lib file
  path = File.dirname(__FILE__) + "/Pods/" + lib_path + "/" + lib_name
  movesense_ref = installer.pods_project.reference_for_path(path)
  
  installer.pods_project.targets.each do |target|
    # find the right target
    if target.name == 'EVORecording'
      # add libmds.a file to build files
      build_phase = target.frameworks_build_phase
      build_phase.add_file_reference(movesense_ref)
      
      target.build_configurations.each do |config|
        # add library search paths
        config.build_settings['LIBRARY_SEARCH_PATHS'] = ["$(inherited)", "$(PROJECT_DIR)/" + lib_path]
        
      end
    end
  end
end
```
Note: logical operators or optimistic operators don't work for the tag in this case. So the tag must be manual incremented on version changes. 

### iPhone only usage
The post install is not needed if do not need the movesense as device.
Also replace the pod line:
```ruby
pod "EVORecording/Binary", :git => 'git@bitbucket.org:evomo/evorecordingbinary.git', :tag => '6.0.2'
```


## General Access API - sample app
```swift
import EVOControlLayer
import PromiseKit
import EVOFoundation

// Init the ClassificationControlLayer
let controlLayer = ClassificationControlLayer.shared

// Define sensor device
controlLayer.device = Device(deviceID: "",
                             deviceType: .iPhone,
                             devicePosition: .leftUpperArm, 
                             deviceOrientation: .buttonDown)
                             
// Define classification model
controlLayer.classificationModel = .leftUpperArm 

// Subscribe to the classified movements
controlLayer.movementHandler = { movement in
	// Do something with the classified movements in time
}

// Handle heart rate changes
ClassificationControlLayer.shared.heartRateSubHandler = { hr in
	// Do something with the heart rate
}

// Start movement classification
ClassificationControlLayer.shared.start(
	lookingForMovementType: nil,
	isConnected: {
		// Do something if connected successful
	}, connectingFailed: { error in

		// Do something if connecting failed
	})
	
wait(10)

// Stop movement classification
_ = ClassificationControlLayer.shared.stop()

```

## API Details

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
controlLayer.device = Device(deviceID: "", // Device ID 
                             deviceType: .iPhone, // Device type
                             devicePosition: .Belly, // Position of the smartphone
                             deviceOrientation: .buttonRight) 
```
#### iPhone
```swift
Device(deviceID: "", // id for iphone device not relevant
	   deviceType: .iphone,
	   devicePosition: .belly,
	   deviceOrientation: .buttonRight)
```

#### Movesense
```swift
Device(deviceID: "175030001022", // Ident string (serial number) of the movesense sensor
	   deviceType: .movesense,
	   devicePosition: .chest, 
	   deviceOrientation: .buttonRight)
```

#### Artificial 
Simulate device sensor by loading a workout file. (helpful to debug or test in simulator)
Note: Wait about 5 seconds for the first movement after starting. The artificial sourcefor simulation only works with belly-based classification models.
```swift
Device(deviceID: WorkoutFile.jumpingJacks.rawValue,
	   deviceType: .artificial,
	   devicePosition: .belly, // <- do not change for artificial
	   deviceOrientation: .buttonRight)// <- do not change for artificial

enum WorkoutFile: String {
    case jumpingJacks = "20JumpingJacks"
    case squats = "20SquatsMovingArms"
    case sixerSets = "6erSets"
    case running = "running"
}
```

### Define the classification model
```swift
// Define classification model
controlLayer.classificationModel = .belly 
// options: .belly(default), .leftUpperArm, specific(Int) <- Inset a testRun id to select a specific model
```
Note: The artificial source for simulation only works with belly-based classification models such as .belly.

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

```swift

// Start movement classification
ClassificationControlLayer.shared.start(
	lookingForMovementType: nil,
	isConnected: {
		// Do something if connected successful
	}, connectingFailed: { error in

		// Do something if connecting failed
	})

// Stop movement classification
_ = ClassificationControlLayer.shared.stop()
```

### Start device position classification while running
```swift
// Start classification of device position and orientation with timeout
ClassificationControlLayer.shared.startPositionClassificationWithTimeout(
	timeoutSeconds: 5,
	isConnected: {
		// Do something if connected successful
		}
	}, connectingFailed: { error in
		// Do something if connecting failed
		}
}).done { stats in
	// Do something with the stats
}
```
Note: If you start movement classification before device position classification timeout ends → automatic stopping of device position classification and return unknown position and unknown orientation

## Output Types

### Device
```swift
enum DeviceType: String {
    case iPhone = "iPhone"
    case movesense = "Movesense"
    case appleWatch = "Apple Watch"
    case artificial = "Artificial"
}

enum DevicePosition: String {
	case unknown = "Unknown"
	case leftWrist = "Left Wrist"
	case rightWrist = "Right Wrist"
	case leftThigh = "Left Thigh"
	case rightThigh = "Right Thigh"
	case belly = "Belly"
	case head = "Head"
	case neck = "Neck"
	case leftShoulder = "Left Shoulder"
	case rightShoulder = "Right Shoulder"
	case leftUpperArm = "Left Upper Arm"
	case rightUpperArm = "Right Upper Arm"
	case leftHand = "Left Hand"
	case rightHand = "Right Hand"
	case chest = "Chest"
	case leftFoot = "Left Foot"
	case rightFoot = "Right Foot"
}

enum DeviceOrientation: String {
	case unknown = "Unknown"
	case crownLeft = "CrownLeft"
	case crownRight = "CrownRight"
	case buttonUp = "ButtonUp"
	case buttonDown = "ButtonDown"
	case buttonRight = "ButtonRight"
	case buttonLeft = "ButtonLeft"
}
```

### Movement (Output)
```swift
public struct MovementOutput {
	
	// Label of the movement type
	public let label: String
	// Start timestamp of the movement
	public let start: Date
	// End timestamp of the movement
	public let end: Date
}
```

### Stats (Output)
```swift
typealias DevicePositionOrientation = (DevicePosition, DeviceOrientation, String)
	// (classified device positon, 
	// classified device orientation,
	// json string with collected statstic data)

```
![](/Documentation/Media/StartScreen.PNG)

