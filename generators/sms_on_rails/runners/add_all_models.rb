append_file 'config/environment.rb', <<-EOS
# Include vanilla sms models. If you wish to make changes and create your own
# models/sms_on_rails this line should be removed.
require 'sms_on_rails/all_models'

EOS
