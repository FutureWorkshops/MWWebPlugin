Pod::Spec.new do |s|
    s.name                  = 'MWWebPlugin'
    s.version               = '0.4.2'
    s.summary               = 'WebView plugin for MobileWorkflow on iOS.'
    s.description           = <<-DESC
    WebView plugin for MobileWorkflow on iOS, containg WebView related steps:
	- MWWebStep
    DESC
    s.homepage              = 'https://www.mobileworkflow.io'
    s.license               = { :type => 'Copyright', :file => 'LICENSE' }
    s.author                = { 'Future Workshops' => 'info@futureworkshops.com' }
    s.source                = { :git => 'https://github.com/FutureWorkshops/MWWebPlugin-iOS.git', :tag => "#{s.version}" }
    s.platform              = :ios
    s.swift_version         = '5'
    s.ios.deployment_target = '15.0'
	s.default_subspecs      = 'Core'
	
    s.subspec 'Core' do |cs|
        cs.dependency            'MobileWorkflow', '~> 2.1.12'
        cs.source_files          = 'MWWebPlugin/MWWebPlugin/**/*.swift'
    end
end
