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
  
  # Pods for evomoExampleApp

end
```
Note: logical operators or optimistic operators don't work for the tag in this case. So the tag must be manual incremented on version changes. 

### iPhone only usage
Replace the pod line:

```ruby
pod "EVORecording/BinaryMovesense", :git => 'git@bitbucket.org:evomo/evorecordingbinary.git', :tag => '6.2.6'
```
with 
```ruby
pod "EVORecording/Binary", :git => 'git@bitbucket.org:evomo/evorecordingbinary.git', :tag => '6.2.6'
```
### AppStore requirements
Add following entries to iOS Info.plist:
```
NSBluetoothAlwaysUsageDescription : "We use Bluetooth to communicate with extern motion sensors to make motion detection possible." (This is a example)

NSBluetoothPeripheralUsageDescription : "This app requires Bluetooth to connect to an external motion sensor." (This is a example)
```

## General Access API - sample app
```swift
import EvomoMotionAI

// Init the ClassificationControlLayer
let controlLayer = ClassificationControlLayer.shared

// Declare licenseID string once (You will receive the license key from Evomo after agreeing to the license conditions.)
ClassificationControlLayer.shared.setLicense(licenseID: licenseID)

// Define sensor device
let devices = [Device(deviceID: "",
                      deviceType: .iPhone,
                      devicePosition: .leftUpperArm, 
                      deviceOrientation: .buttonDown)]
                             
// Subscribe to the classified movements
controlLayer.movementHandler = { movement in
	// Do something with the classified movements in time
}

// Handle heart rate changes
ClassificationControlLayer.shared.heartRateSubHandler = { hr in
	// Do something with the heart rate
}

// Handle device events
ClassificationControlLayer.shared.deviceEventHandler = { deviceEvent in
    let (device, event) = deviceEvent
    
    switch event {
    case let .dataStraming(state):
        // Will be triggered on data streaming state change (Bool)
        // dataStraming = true if sensor data received in the last 0.2 seconds
        print("\(state ? "data streaming" : "data stream lost")")
        
    case let .connected(connected):
        // Will be triggered if the device successfully connect or disconnect
        print("\(connected ? "connected" : "disconnected")")
        
    case let .energyPercent(energyPercent):
        // Implemented for movesense devices (Apple devices dont return a energy level)
        // The energy level will always emit on after connecting to the device.
        print("Energy \(Int(energyPercent * 100)) %"
        
    case let .softwareVersion(version):
        // not implemented now
        // Will return the software version of the device after connecting
        print("OS/FW - \(version)")
    }
}

// Start movement classification
ClassificationControlLayer.shared.start(
    devices: devices,
    isConnected: {
        print("--- All devices connected ---")
}, isStarted:{
    print("--- All devices started ---")
}, isFailed: { error in
    print("Start classification failed: \(error)")
})
	
wait(10)

// Stop movement classification
_ = ClassificationControlLayer.shared.stop()

```

## API Details

### Initialise the EVOControlLayer
```swift
import EvomoMotionAI

// Init the ClassificationControlLayer
let controlLayer = ClassificationControlLayer.shared
```

### Setup licenseID
```swift
// Declare licenseID string once (You will receive the license key from Evomo after agreeing to the license conditions.)
ClassificationControlLayer.shared.setLicense(licenseID: "licenseID-String")
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
       ..)
```

#### Movesense
```swift
Device(deviceID: "175030001022", // Ident string (serial number) of the movesense sensor
	   deviceType: .movesense,
	   ..)
```

#### Artificial/Simulator
Simulate device sensor by loading a workout file. (helpful to debug or test in simulator)
Note: Wait about 5 seconds for the first movement after starting. The artificial sourcefor simulation only works with belly-based classification models.
```swift

# default WorkoutFile is JumpingJack
# if you want to select another WorkoutFile -> use the detail property of the device

Device(deviceID: ""
	   deviceType: .iPhone,
	   devicePosition: .belly,  // Artificial device only works in belly position and buttonRight orientation
	   deviceOrientation: .buttonRight,
       ...
       
  ---> details: WorkoutFile.squats.rawValue
       )

enum WorkoutFile: String {
    case jumpingJacks = "20JumpingJacks"
    case squats = "20SquatsMovingArms"
    case sixerSets = "6erSets"
    case running = "running"
}
```

### Define the classification model
```swift
// Expert/Experimental property: 
// Define classification model (optional - default model for each devicePosition will be overwritten)
let device = Device(deviceID: ""
       deviceType: .iPhone,
       ...
---->  classificationModel: .specific(1915)
       )
       
// options: .belly, .leftUpperArm, .chest, specific(Int) <- Inset a testRun id to select a specific model
```
Note: On the simulator the sdk only works with belly-based classification models such as .belly.

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

// Device Event

public typealias DeviceEvent = (Device, DeviceStateChange)


public enum DeviceStateChange: Equatable {
    case energyPercent(Double)
    case dataStraming(Bool)
    case connected(Bool)
    case softwareVersion(String)
}

// Handle device events
ClassificationControlLayer.shared.deviceEventHandler = { deviceEvent in
    let (device, event) = deviceEvent
    
    switch event {
    case let .dataStraming(state):
        // Will be triggered on data streaming state change (Bool)
        // dataStraming = true if sensor data received in the last 0.2 seconds
        
    case let .connected(connected):
        // Will be triggered if the device successfully connect or disconnect
        
    case let .energyPercent(energyPercent):
        // Implemented for movesense devices (Apple devices dont return a energy level)
        // The energy level will always emit on after connecting to the device.
        
    case let .softwareVersion(version):
        // not implemented now
        // Will return the software version of the device after connecting
    }
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

## Input Types

### Device
```swift

public struct Device {

    public var deviceID: String
    public let deviceType: DeviceType
    public let devicePosition: DevicePosition
    public let deviceOrientation: DeviceOrientation
    public let deviceForward: Bool = true
    public let heartRate: Bool // if true -> record heartRate
    public var classificationModel: String // customize classification model
    public var isSimulated: Bool = false
    public var details: String // set WorkoutFile.rawValue to select a file for simulation mode
}

enum DeviceType: String {
    case iPhone = "iPhone"
    case movesense = "Movesense"
    case appleWatch = "Apple Watch"
}

enum DevicePosition: String {
    case unknown = "Unknown"
    case leftWrist = "Left Wrist"
    case rightWrist = "Right Wrist"
    case leftThigh = "Left Thigh"
    case rightThigh = "Right Thigh"
    case belly = "Belly"
    case neck = "Neck"
    case leftUpperArm = "Left Upper Arm"
    case rightUpperArm = "Right Upper Arm"
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

## Output Types

### Movement (Output)
```swift
public struct Movement {

    public let typeID: Int // This represents the Category ID at the Moment.
    public var typeLabel: String
    public let start: Date
    public var end: Date
    public var durationPositive: Double?
    public var durationNegative: Double?
    public var gVelAmplitudePositive: Double?
    public var gVelAmplitudeNegative: Double?
    public var amplitude: Double?

}
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
- only relevant for the movesense device scan
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
Most relevant ist only the serial string of the MovesenseDevice.


## DevicePositionClassification - in development

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

### Stats (Output)
```swift
typealias DevicePositionOrientation = (DevicePosition, DeviceOrientation, String)
    // (classified device positon, 
    // classified device orientation,
    // json string with collected statstic data)
```
