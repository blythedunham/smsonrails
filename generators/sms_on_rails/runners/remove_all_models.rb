
sentinel = "[^#](require\\s+['|\"]sms_on_rails/all_models['|\"])"
gsub_file 'config/environment.rb', Regexp.new(sentinel) do |match|
  "\n##{match.strip}"
end