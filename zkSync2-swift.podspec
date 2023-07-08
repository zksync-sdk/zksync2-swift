Pod::Spec.new do |s|
    s.name             = 'zkSync2-swift'
    s.version          = '0.0.2-alpha.4'
    s.summary          = 'Swift SDK for ZkSync2'

    s.description      = <<-DESC
zkSync is a scaling and privacy engine for Ethereum. Its current functionality scope includes low gas transfers of ETH and ERC20 tokens in the Ethereum network.
    DESC

    s.homepage         = "https://github.com/zksync-sdk/zksync2-swift"
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    
    s.author           = { "The Matter Labs team" => "hello@matterlabs.dev" }
  
    s.ios.deployment_target = "13.0"
    s.swift_version    = '5.6'
  
    s.source           = { :git => "https://github.com/zksync-sdk/zksync2-swift.git", :tag => "#{s.version.to_s}" }
    
    s.dependency 'Alamofire', '~> 5.0'
    s.dependency 'web3swift-zksync2', '2.6.5-zksync'

    s.source_files = 'Sources/ZkSync2/**/*'
end
