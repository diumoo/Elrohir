#
Pod::Spec.new do |s|

  s.name         = "Elrohir"
  s.version      = "0.0.1"
  s.summary      = "Douban API Client"
  s.authors             = { "Chase Zhang" => "yun.er.run@gmail.com",
                           "Oolong Tea" => "yechunxiao19@gmail.com"}

  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.8'

  s.source       = { :git => "https://github.com/shanzi/Elrohir.git", :tag => "0.0.1" }


  s.source_files  = 'EHAPIClient'
  s.dependency 'AFNetworking', '~> 1.3.2'

end
