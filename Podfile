# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
use_frameworks!


  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks

  
def shared_pods

  # Pods for Voice Pitch Analyzer
	pod 'Beethoven', '~> 4.0.2'
  
  # add the Firebase pod for Google Analytics
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  # add pods for any other desired Firebase products
  # https://firebase.google.com/docs/ios/setup#available-pods
  
  pod 'Firebase/Firestore'
  # Optionally, include the Swift extensions if you're using Swift.
  pod 'FirebaseFirestoreSwift'
  
  pod 'Firebase/Auth'
  
  pod 'SwiftyJSON'
  pod 'Wrap', :git => 'https://github.com/JohnSundell/Wrap.git'
  
  # Package to polyfil CALayer with traitCollection.userInterfaceStyle to adapt color as UIView does.
  pod 'XYColor'
  pod 'SwiftLint'

end

target 'Voice Pitch Analyzer' do
  
  shared_pods

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.0'
        end
    end
end
end
