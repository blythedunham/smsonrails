module SmsOnRails
  class SmsError < Exception
  end

  class FatalSmsError < SmsError
  end
end
