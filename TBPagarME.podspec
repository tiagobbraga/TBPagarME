Pod::Spec.new do |s|

  s.name         = "TBPagarME"
  s.version      = "1.2.0"
  s.summary      = "Facilitador do gateway de pagamento pagar.me"
  s.description  = <<-DESC
                  "Facilita a transação com cartão de crédito com o pagar.me, gerando o card_hash necessário."
                   DESC

  s.homepage     = "https://github.com/tiagobsbraga/TBPagarME"
  s.license      = "MIT"
  s.author             = { "Tiago Braga" => "contato@tiagobraga.cc" }
  s.social_media_url   = "http://twitter.com/tiagobraga"
  s.platform     = :ios, '8.0'
  s.source       = { :git => "https://github.com/tiagobsbraga/TBPagarME.git", :tag => s.version.to_s }
  s.source_files  = "Pod", "Pod/Classes/*.{swift,h,m}"
  s.requires_arc = true
  s.frameworks = 'Foundation'
  s.dependency 'SwiftyRSA', '~> 0.2'
  s.dependency 'SwiftLuhn', '~> 0.1'

end