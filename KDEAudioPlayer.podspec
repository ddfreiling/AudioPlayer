Pod::Spec.new do |s|
  s.name          = 'KDEAudioPlayer'
  s.version       = '1.3.0'
  s.license       =  { :type => 'MIT' }
  s.homepage      = 'https://github.com/ddfreiling/AudioPlayer'
  s.authors       = { 'Kevin Delannoy' => 'delannoyk@gmail.com', 'Daniel Freiling' => 'ddfreiling@gmail.com' }
  s.summary       = 'AudioPlayer is a wrapper around AVPlayer and also offers cool features.'

  s.source        =  { :git => 'https://github.com/ddfreiling/AudioPlayer.git' }
  s.source_files  = 'AudioPlayer/AudioPlayer/**/*.swift'
  s.requires_arc  = true
  s.swift_version = '5.0'

  s.ios.deployment_target = '9.0'
  s.ios.framework = 'UIKit', 'AVFoundation', 'MediaPlayer', 'SystemConfiguration', 'CoreTelephony'

  s.tvos.deployment_target = '9.0'
  s.tvos.framework = 'UIKit', 'AVFoundation', 'MediaPlayer', 'SystemConfiguration'

  s.osx.deployment_target = '10.11'
  s.osx.framework = 'Foundation', 'AVFoundation', 'SystemConfiguration'
  s.osx.exclude_files = 'AudioPlayer/AudioPlayer/utils/MPNowPlayingInfoCenter+AudioItem.swift'
end
