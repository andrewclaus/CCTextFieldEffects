Pod::Spec.new do |spec|
  spec.name                  = 'CCTextFieldEffects'
  spec.platform              = :ios
  spec.version               = '1.0.0'
  spec.license               = { :type => 'MIT' }
  spec.homepage              = 'https://github.com/Cokile/CCTextFieldEffects'
  spec.authors               = { 'Cokile' => 'kelvintgx@gmail.com' }
  spec.summary               = 'A simple replacement for UITextField.'
  spec.source                = { :git => 'https://github.com/andrewclaus/CCTextFieldEffects.git', :tag => '1.0.0'}
  spec.source_files          = 'CCTextFieldEffects/*.{h,m}'
  spec.resources             = 'CCTextFieldEffects/*.png'
  spec.requires_arc          = true
end
