
# Evomo private specs repo source
source 'https://bitbucket.org/evomo/evomopodsrelease.git'

# Standard cocoapods specs source
source 'https://github.com/CocoaPods/Specs.git'

target 'evomoExampleApp' do
    platform :ios, '12.1'
    use_frameworks!
    
    # Pods for evomoExampleApp
    pod "EvomoMotionAI"
    
    pod "SwiftSpinner"
    
end

print("SetProductBundle for Binary")
post_install do |installer|
    installer.pods_project.targets.each do |target|
        
        # set bundle identifier platform specific (cocoapod bug: https://github.com/CocoaPods/CocoaPods/issues/9135 )
        target.build_configurations.each do |config|
            config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "org.cocoapods.${PRODUCT_NAME:rfc1034identifier}.${PLATFORM_NAME}"
        end
    end
end

