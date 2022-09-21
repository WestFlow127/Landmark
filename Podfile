# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Landmark' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  pod 'FirebaseAppCheck'
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  
  
  target 'LandmarkTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'LandmarkUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    puts target.name
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
#      if config.name == 'Debug'
#        config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-Onone']
#        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
#        config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'NO'
#      end
    end
  end
end
