Pod::Spec.new do |s|
  s.name     = 'ISAppearance'
  s.version  = '0.2.0'
  s.license  = 'MIT'
  s.summary  = 'Appearance library.'
  s.authors  =  'Yaroslav Ponomarenko'
  s.source   = { :git => 'https://github.com/InSightMobile/ISAppearance.git', :tag => '0.2.0'}
  s.requires_arc = true
  s.default_subspecs = 'Config','ValueConverters'
  s.homepage = 'https://github.com/InSightMobile/ISAppearance'

  s.ios.deployment_target = '7.0'
  s.ios.frameworks = 'UIKit'

  #s.public_header_files = 'ISAppearance/Core/ISAppearance.h', 'ISAppearance/Core/ISAValueConverter.h'

  s.subspec 'Core' do |ss|
    ss.source_files = 'ISAppearance/Core/*.{h,m}'
    ss.public_header_files = 'ISAppearance/Core/ISAppearance.h', 'ISAppearance/Core/ISAValueConverter.h'
  end

  s.subspec 'Config' do |ss|
    ss.source_files = 'ISAppearance/Config/*.{h,m}'
    ss.dependency 'ISAppearance/Core'
    ss.dependency 'ISAppearance/ISYAML'
    ss.public_header_files = 'ISAppearance/Config/ISAConfig.h'
  end

  s.subspec 'CodeGeneration' do |ss|
    ss.source_files = 'ISAppearance/CodeGeneration/*.{h,m}'
    ss.dependency 'ISAppearance/Config'
    ss.prefix_header_contents = '
    #if TARGET_IPHONE_SIMULATOR
		#define ISA_CODE_GENERATION 1
		#endif'
  end  

  s.subspec 'ValueConverters' do |ss|
    ss.dependency 'ISAppearance/Config'
    ss.source_files = 'ISAppearance/ValueConverters/*.{h,m}'
  end  

  s.subspec 'Categories' do |ss|
    ss.source_files = 'ISAppearance/Categories/*.{h,m}'
    ss.dependency 'ISAppearance/Core'
  end  

  s.subspec 'ISYAML' do |ss|
    ss.source_files = 'ISYAML/*.{h,m}'
    ss.dependency 'LibYAML', '~> 0.1.4'
  end 
  
end