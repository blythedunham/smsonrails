module SmsOnRails
  module ModelSupport
    module Draft

      def self.included(base)#:nodoc
        base.send :accepts_nested_attributes_for, :outbounds
        base.send :include, InstanceMethods
        base.send :extend,  ClassMethods
      end

      module ClassMethods
      end

      module InstanceMethods
      end
    end
  end
end