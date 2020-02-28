# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Voice Pitch Analyzer' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Voice Pitch Analyzer
  # Bug: Beethoven 4.0.2 installed via cocoapods doesn't build in xcode 11,
  # reason is a wrong config "SWIFT_VERSION = 3.0" in the podspec.
  # HOTFIX: use fork with fix in it: https://github.com/fetzig/Beethoven
  # see PR: https://github.com/vadymmarkov/Beethoven/pull/71
  pod 'Beethoven', :git => 'https://github.com/fetzig/Beethoven.git'

end
