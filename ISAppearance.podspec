Pod::Spec.new do |s|
  s.name     = 'ISAppearance'
  s.version  = '0.1.1'
  s.license  = 'MIT'
  s.summary  = 'Appearance library.'
  s.source   = { :git => 'git@bitbucket.org:Infoshell/isappearance.git', :branch => "develop",  :submodules => true }
  s.requires_arc = true
  s.default_subspecs = 'Core','ValueConverters'

  s.ios.deployment_target = '6.0'
  s.ios.frameworks = 'UIKit'

  s.public_header_files = 'ISAppearance/*.h'
  s.source_files = 'ISAppearance/*.{h,m}'

  s.subspec 'Core' do |ss|
    ss.source_files = 'ISAppearance/Core/*.{h,m}'
    ss.dependency 'ISAppearance/ISYAML'
  end

  s.subspec 'CodeGeneration' do |ss|
    ss.source_files = 'ISAppearance/CodeGeneration/*.{h,m}'
    ss.dependency 'ISAppearance/Core'
    ss.prefix_header_contents = '
    	#if TARGET_IPHONE_SIMULATOR
		#define ISA_CODE_GENERATION 1
		#endif'
  end  

  s.subspec 'ValueConverters' do |ss|
    ss.source_files = 'ISAppearance/ValueConverters/*.{h,m}'
    ss.dependency 'ISAppearance/Core'
  end  

  s.subspec 'Categories' do |ss|
    ss.source_files = 'ISAppearance/Categories/*.{h,m}'
  end  

  s.subspec 'ImageManipulation' do |ss|
    ss.source_files = 'ISAppearance/Categories/ImageManipulation/*.{h,m}'
  end  

  s.subspec 'ISYAML' do |ss|
    ss.source_files = 'YAML/ISYAML/*.{h,m}'
    ss.dependency 'LibYAML', '~> 0.1.4'
  end 
  
end