Pod::Spec.new do |s|
  s.name             = 'MarketKit.swift'
  s.module_name      = 'MarketKit'
  s.version          = '0.1.0'
  s.summary          = 'Kit provides latest rates for coins, chart data and historical data for different coins and currencies.'

  s.homepage         = 'https://github.com/horizontalsystems/market-kit-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Horizontal Systems' => 'hsdao@protonmail.ch' }
  s.source           = { git: 'https://github.com/horizontalsystems/market-kit-ios.git', tag: "#{s.version}" }
  s.social_media_url = 'http://horizontalsystems.io/'

  s.ios.deployment_target = '13.0'
  s.swift_version = '5'

  s.source_files = 'MarketKit/Classes/**/*'

  s.requires_arc = true

  s.dependency 'HsToolKit.swift', '~> 1.1'

  s.dependency 'RxSwift', '~> 5.0'
  s.dependency 'GRDB.swift', '~> 5.0'
  s.dependency 'ObjectMapper', '~> 4.0'
end
