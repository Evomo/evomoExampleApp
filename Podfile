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
    # pod "EvomoMotionAI/Movesense", :path => '~/evomo/swift/frameworks/evomomotionaiframework/'

    pod "SwiftSpinner"
    
end

# exampleApp with iphone only
target 'iPhoneOnlyExample' do
    platform :ios, '12.1'
    use_frameworks!

    # Pods for evomoExampleApp
    pod "EvomoMotionAI/Basic"
    # pod "EvomoMotionAI", :path => '~/evomo/swift/frameworks/evomomotionaiframework/'

end

## exampleApp with classification only (feed data directly into SDK and get movement back)
## !!! Troubleshooting: if evomoExampleApp was builed before, clear DerivedData folder and clean project before building this target
target 'ClassificationOnlyExample' do
    platform :ios, '12.1'
    use_frameworks!

    # Pods for evomoExampleApp
    pod "EvomoMotionAI/ClassificationOnly"

end
#
#post_install do |installer|
#  # ------------------- Prepare framework build
#
#  installer.pods_project.targets.each do |target|
#    #print target.name
#    #print "\n"
#
#    target.build_configurations.each do |config|
#
#      # activate for xcFramework build
#      #config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = "YES"
#
#      if target.name == 'Pods-EvomoMotionAI'
#
#        # enable bitcode for pods
#        cflags = config.build_settings['OTHER_CFLAGS'] || ['$(inherited)']
#        cflags << '-fembed-bitcode'
#        config.build_settings['OTHER_CFLAGS'] = cflags
#        if config.name == "Debug"
#          config.build_settings['BITCODE_GENERATION_MODE'] = "marker"
#          elsif config.name == "Release"
#          config.build_settings['BITCODE_GENERATION_MODE'] = "bitcode"
#        end
#      end
#    end
#  end
#
#  # ------------------- add movesense lib
#
#  lib_name = "libmds.a"
#  lib_path = "Movesense/IOS/Movesense/Release-iphoneos"
#
#  # get ref of lib file
#  path = File.dirname(__FILE__) + "/Pods/" + lib_path + "/" + lib_name
#  movesense_ref = installer.pods_project.reference_for_path(path)
#
#  installer.pods_project.targets.each do |target|
#    # find the right target
#    print(target.name)
#    print("\n")
#    if target.name == 'EvomoMotionAI-Movesense-Source' || target.name == 'EvomoMotionAI'
#      print "Add movesense lib\n"
#      # add libmds.a file to build files
#      build_phase = target.frameworks_build_phase
#      build_phase.add_file_reference(movesense_ref)
#
#      target.build_configurations.each do |config|
#        # add library search paths
#        config.build_settings['LIBRARY_SEARCH_PATHS'] = ["$(inherited)", "$(PROJECT_DIR)/" + lib_path]
#
#      end
#    end
#  end
#end
