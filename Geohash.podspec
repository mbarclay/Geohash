Pod::Spec.new do |s|
  s.name = 'Geohash'
  s.version = '1.0.1'
  s.license = 'MIT'
  s.summary = 'A basic geohash library written in Swift.'
  s.homepage = 'https://github.com/mbarclay/Geohash'
  s.authors = { 'Malcolm Barclay' => 'malcolm@mbarclay.net' }
  s.source = { :git => 'https://github.com/mbarclay/Geohash.git', :tag => s.version }

  s.osx.deployment_target = '10.9'
  s.ios.deployment_target = '10.0'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.module_name = 'Geohash'
  s.source_files = 'Geohash/Classes/*.swift'
end
