# suppress the UUIDs warnings
install! 'cocoapods', :deterministic_uuids => false

# Insert your own private specs repo source
source 'git@bitbucket.org:evomo/evomopods.git'
# Standard cocoapods specs source
source 'https://github.com/CocoaPods/Specs.git'

target 'evomoExampleApp' do
  platform :ios, '13.0'
  use_frameworks!
  
  # Pods for evomoExampleApp
#  pod "EVOFoundation/Binary", :git => 'git@bitbucket.org:evomo/evofoundationbinary.git', :tag => '6.1.2'
#  pod "EVORecording/BinaryMovesense", :git => 'git@bitbucket.org:evomo/evorecordingbinary.git', :tag => '6.1.22'
#  pod "EVOClassificationKit/Binary", :git => 'git@bitbucket.org:evomo/evoclassificationkitbinary.git', :tag => '6.0.5'
#  pod "EVOControlLayer/Binary",  :git => 'git@bitbucket.org:evomo/evocontrollayerbinary.git', :tag => '6.1.5'

  # Pods used for internal development
#  pod "EVOFoundation/Source", '~>6.0.0'
#  pod "EVORecording/Source", '~>6.0.2'
#  pod "EVOClassificationKit/Source", '~>6.0.0'
#  pod "EVOControlLayer/Source", '~>6.0.0'

   pod "EVOFoundation/Source", :path => '~/evomo/swift/frameworks/emfoundation/'
   pod "EVORecording/Movesense", :path => '~/evomo/swift/frameworks/evorecording/'
   pod "EVOClassificationKit", :path => '~/evomo/swift/frameworks/evoclassificationframework/'
   pod "EVOControlLayer/Movesense", :path => '~/evomo/swift/frameworks/EVOControlLayer/'

   pod "SwiftSpinner"
end

#post_install do |installer|
#    installer.pods_project.targets.each do |target|
#
#        # set bundle identifier platform specific (cocoapod bug: https://github.com/CocoaPods/CocoaPods/issues/9135 )
#        target.build_configurations.each do |config|
#            config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "org.cocoapods.${PRODUCT_NAME:rfc1034identifier}.${PLATFORM_NAME}"
#        end
#    end
#end

# only needed for source (not precompiled) recording pod
# post install to add movesense libmds.a library to project.
post_install do |installer|
  
  lib_name = "libmds.a"
  lib_path = "Movesense/IOS/Movesense/Release-iphoneos"
  
  # get ref of lib file
  path = File.dirname(__FILE__) + "/Pods/" + lib_path + "/" + lib_name
  movesense_ref = installer.pods_project.reference_for_path(path)
  
  installer.pods_project.targets.each do |target|
    
    # set bundle identifier platform specific (cocoapod bug: https://github.com/CocoaPods/CocoaPods/issues/9135 )
    target.build_configurations.each do |config|
      config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "org.cocoapods.${PRODUCT_NAME:rfc1034identifier}.${PLATFORM_NAME}"
    end
    
    # find the right target
    if target.name == 'EVORecording'
      print("Add movesense libmds.a to project!")
      # add libmds.a file to build files
      build_phase = target.frameworks_build_phase
      build_phase.add_file_reference(movesense_ref)
      
      target.build_configurations.each do |config|
        # add library search paths
        config.build_settings['LIBRARY_SEARCH_PATHS'] = ["$(inherited)", "$(PROJECT_DIR)/" + lib_path]
        
      end
      print("Done")
    end
  end
end
