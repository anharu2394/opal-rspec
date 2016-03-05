class RSpec::Matchers::BuiltIn::BaseMatcher
  def self.underscore(camel_cased_word)
    # string mutation
    word = camel_cased_word.to_s
    word = word.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
    word = word.gsub(/([a-z\d])([A-Z])/,'\1_\2')
    word = word.tr("-", "_")
    word.downcase
  end
end