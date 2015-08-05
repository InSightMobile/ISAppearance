Pod::Spec.new do |s|
  s.name     = 'ISAppearanceCore'
  s.version  = '0.2.0'
  s.license  = 'MIT'
  s.summary  = 'Appearance library.'
  s.authors  =  'Yaroslav Ponomarenko'
  s.source   = { :git => 'https://github.com/InSightMobile/ISAppearance.git', :tag => '0.2.0'}
  s.requires_arc = true
  s.default_subspecs = 'Core'
  s.homepage = 'https://github.com/InSightMobile/ISAppearance'

  s.ios.deployment_target = '7.0'
  s.ios.frameworks = 'UIKit'

  s.public_header_files = 'ISAppearance/Core/ISAppearance.h', 'ISAppearance/Core/ISAValueConverter.h'

  s.subspec 'Core' do |ss|
    ss.source_files = 'ISAppearance/Core/*.{h,m}'
  end 

  s.subspec 'Categories' do |ss|
    ss.source_files = 'ISAppearance/Categories/*.{h,m}'
    ss.dependency 'ISAppearance/Core'
  end  
  
end