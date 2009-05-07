module SmsOnRails
  class SmsError < Exception
    attr_reader :sub_status
    def initialize(msg, new_sub_status = nil)
      super msg
      @sub_status = new_sub_status
    end
  end

  class FatalSmsError < SmsError
  end
end
