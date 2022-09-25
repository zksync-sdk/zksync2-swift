Pod::Spec.new do |s|
    s.name             = 'ZkSync2'
    s.version          = '0.0.1'
    s.summary          = 'Swift SDK for ZkSync2'

    s.description      = <<-DESC
zkSync is a scaling and privacy engine for Ethereum. Its current functionality scope includes low gas transfers of ETH and ERC20 tokens in the Ethereum network.
    DESC

    s.homepage         = "https://github.com/zksync-sdk/zksync2-swift"
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    
    s.author           = { "The Matter Labs team" => "hello@matterlabs.dev" }
  
    s.ios.deployment_target = "11.0"
    s.swift_version    = '5.0'
  
    s.source           = { :git => "https://github.com/zksync-sdk/zksync-swift.git", :tag => "#{s.version}" }
    
    s.dependency 'Alamofire', '~> 5.0'
    s.dependency 'web3swift', '~> 2.6.0'

    s.source_files = 'Sources/ZkSync2/**/*'
end
