# Doku Evomo MotionAI SDK + exampleApp
Documentation and repo for the example app X-Code project to show the usage of the Evomo MotionAI SDK.

## The example App
<p float="left">
<img src="/Documentation/Media/StartScreen.PNG" alt="drawing" width="300"/> 
<img src="/Documentation/Media/ComplexMode.PNG" alt="drawing" width="300"/>
</p>

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
  pod "EVOFoundation/Binary", :git => 'git@bitbucket.org:evomo/evofoundationbinary.git', :tag => '6.1.2'
  pod "EVORecording/BinaryMovesense", :git => 'git@bitbucket.org:evomo/evorecordingbinary.git', :tag => '6.1.22'
  pod "EVOClassificationKit/Binary", :git => 'git@bitbucket.org:evomo/evoclassificationkitbinary.git', :tag => '6.0.5'
  pod "EVOControlLayer/Binary",  :git => 'git@bitbucket.org:evomo/evocontrollayerbinary.git', :tag => '6.1.5'

end
```
Note: logical operators or optimistic operators don't work for the tag in this case. So the tag must be manual incremented on version changes. 

### iPhone only usage
Replace the pod line:

```ruby
pod "EVORecording/BinaryMovesense", :git => 'git@bitbucket.org:evomo/evorecordingbinary.git', :tag => '6.1.22'
```
with 
```ruby
pod "EVORecording/Binary", :git => 'git@bitbucket.org:evomo/evorecordingbinary.git', :tag => '6.1.22'
```
### AppStore requirements
Add following entries to iOS Info.plist:
```
NSBluetoothAlwaysUsageDescription : "We use Bluetooth to communicate with extern motion sensors to make motion detection possible." (This is a example)

Privacy - Bluetooth Peripheral Usage Description : "This app requires Bluetooth to connect to an external motion sensor." (This is a example)
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

## Scan for movesense ble device
```swift

// start scan
firstly {
	when(resolved: self.movesense.startScan({ _ in
		
		// if new device found
		// fetch and display devices
		let bleDevices = self.movesense.getDevices().map { $0.serial }
		
	}.done {_ in
		// if scan done
	}

// handle scan events
self.movesense.setHandlers(
            deviceConnected: { deviceSerial in
                print("Device connected: \(deviceSerial)")
        },
            deviceDisconnected: { deviceSerial in
                print("Device disconnected: \(deviceSerial)")
        },
            bleOnOff: { (state) in
                print("BLE state changed: \(state)")
        })
```
Check the example App for a better understanding of the scan process.

### Type - MovesenseDevice
````swift

public struct MovesenseDevice {
    public var uuid: UUID
    public var localName: String
    public var serial: String // Must be unique among all devices
    public var bleStatus: Bool
    public var mdsConnected: Bool = false
    public var deviceInfo: MovesenseDeviceInfo?
}
````
Most relevant ist only the serial of the MovesenseDevice.
