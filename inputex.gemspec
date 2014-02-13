Gem::Specification.new do |s|
  s.name        = 'inputex'
  s.version     = '0.0.1'
  s.date        = '2014-02-07'
  s.summary     = "Interface the inputex UI library with ActiveModel"
  s.description = ""
  s.authors     = ["Maxime Réty", "Eric Abouaf"]
  s.email       = 'maxime.rety@clicrdv.com'
  s.files       = ["lib/inputex.rb"]
  s.add_development_dependency 'rake'
  s.add_development_dependency 'activerecord', '3.2.16'
  if RUBY_VERSION >= "1.9"
    s.add_development_dependency 'coveralls'
  end
  s.homepage    = 'http://rubygems.org/gems/inputex'
  s.license       = 'Apache License 2.0'
end
