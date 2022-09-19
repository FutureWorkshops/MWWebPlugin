source 'https://cdn.cocoapods.org/'
source 'https://github.com/FutureWorkshops/MWPodspecs.git'

workspace 'MWWeb'
platform :ios, '15.0'

inhibit_all_warnings!
use_frameworks!

project 'MWWeb/MWWeb.xcodeproj'
project 'MWWebPlugin/MWWebPlugin.xcodeproj'

abstract_target 'MWWeb' do
  pod 'MobileWorkflow'
  #here you can add any extra dependencies that you need

  target 'MWWeb' do
    project 'MWWeb/MWWeb.xcodeproj'

    target 'MWWebTests' do
      inherit! :search_paths
    end
  end

  target 'MWWebPlugin' do
    project 'MWWebPlugin/MWWebPlugin.xcodeproj'

    target 'MWWebPluginTests' do
      inherit! :search_paths
    end
  end
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ""
    end
  end
end
