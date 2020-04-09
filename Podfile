# Evomo private specs repo source
source 'https://bitbucket.org/evomo/evomopodsrelease.git'

# Standard cocoapods specs source
source 'https://github.com/CocoaPods/Specs.git'

# exampleApp with Movesense sensor
target 'evomoExampleApp' do
    platform :ios, '12.1'
    use_frameworks!
    
    # Pods for evomoExampleApp
    pod "EvomoMotionAI/Movesense"
#    pod "EvomoMotionAI/Movesense", :path => '~/evomo/swift/frameworks/evomomotionaiframework/'

    pod "SwiftSpinner"
    
end

# exampleApp with iphone only
target 'iPhoneOnlyExample' do
    platform :ios, '12.1'
    use_frameworks!

    # Pods for evomoExampleApp
    pod "EvomoMotionAI/Basic"

end

## exampleApp with classification only (feed data directly into SDK and get movement back)
## !!! Troubleshooting: if evomoExampleApp was builed before, clear DerivedData folder and clean project before building this target
#target 'ClassificationOnlyExample' do
#    platform :ios, '12.1'
#    use_frameworks!
#
#    # Pods for evomoExampleApp
#    pod "EvomoMotionAI/ClassificationOnly"
#
#end
