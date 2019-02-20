Pod::Spec.new do |s|
  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.8'
  s.tvos.deployment_target = '9.0'
  s.name     = 'SYOperationQueue'
  s.version  = '1.0.3'
  s.license  = 'Custom'
  s.summary  = 'An operation queue subclass that allows LIFO style queuing and a max number of operations'
  s.homepage = 'https://github.com/dvkch/SYOperationQueue'
  s.author   = { 'Stan Chevallier' => 'contact@stanislaschevallier.fr' }
  s.source   = { :git => 'https://github.com/dvkch/SYOperationQueue.git', :tag => s.version.to_s }
  s.source_files = 'SYOperationQueue.{h,m}'
  s.requires_arc = true
  s.xcconfig = { 'CLANG_MODULES_AUTOLINK' => 'YES' }
end
