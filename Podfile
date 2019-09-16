# suppress the UUIDs warnings
install! 'cocoapods', :deterministic_uuids => false

# Insert your own private specs repo source
source 'git@bitbucket.org:evomo/evomopods.git'
# Standard cocoapods specs source
source 'https://github.com/CocoaPods/Specs.git'

target 'evomoExampleApp' do
  platform :ios, '12.1'
  use_frameworks!
  
  # Pods for evomoExampleApp
  pod "EVOFoundation/Binary", :git => 'git@bitbucket.org:evomo/evofoundationbinary.git', :tag => '6.1.2'
  pod "EVORecording/BinaryMovesense", :git => 'git@bitbucket.org:evomo/evorecordingbinary.git', :tag => '6.1.22'
  pod "EVOClassificationKit/Binary", :git => 'git@bitbucket.org:evomo/evoclassificationkitbinary.git', :tag => '6.0.5'
  pod "EVOControlLayer/Binary",  :git => 'git@bitbucket.org:evomo/evocontrollayerbinary.git', :tag => '6.1.5'

  # Pods used for internal development
#  pod "EVOFoundation/Source", '~>6.0.0'
#  pod "EVORecording/Source", '~>6.0.2'
#  pod "EVOClassificationKit/Source", '~>6.0.0'
#  pod "EVOControlLayer/Source", '~>6.0.0'

#   pod "EVOFoundation/Source", :path => '~/evomo/swift/frameworks/emfoundation/'
#   pod "EVORecording/Movesense", :path => '~/evomo/swift/frameworks/evorecording/'
#   pod "EVOClassificationKit/Source", :path => '~/evomo/swift/frameworks/evoclassificationframework/'
#   pod "EVOControlLayer/Source", :path => '~/evomo/swift/frameworks/EVOControlLayer/'

   pod "SwiftSpinner"
end

# only needed for source (not precompiled) recording pod
## post install to add movesense libmds.a library to project.
#post_install do |installer|
#
#  lib_name = "libmds.a"
#  lib_path = "Movesense/IOS/Movesense/Release-iphoneos"
#
#  # get ref of lib file
#  path = File.dirname(__FILE__) + "/Pods/" + lib_path + "/" + lib_name
#  movesense_ref = installer.pods_project.reference_for_path(path)
#
#  installer.pods_project.targets.each do |target|
#
#    # find the right target
#    print(target.name)
#    if target.name == 'EVORecording'
#      # add libmds.a file to build files
#      # check if build_phase exists
#      # build_phase = target.frameworks_build_phase
#
#      target.build_configurations.each do |config|
#        # add library search paths
#        config.build_settings['LIBRARY_SEARCH_PATHS'] = ["$(inherited)", "$(PROJECT_DIR)/" + lib_path]
#
#      end
#    end
#  end
#end
