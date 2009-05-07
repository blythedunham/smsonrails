module SmsOnRails
  module ModelSupport
    module PhoneNumber
      def self.included(base)
        base.send :include,InstanceMethods
        base.send :extend, ClassMethods
        base.send :validates_format_of, :phone_number_digits, :with => /^\d{5,30}$/, :message => 'must be a number and have at least 5 digits'
        base.before_save {|record| record.number = record.digits}
        base.send :validates_presence_of, :number
        base.send :attr_reader, :original_number
        base.class_inheritable_accessor :valid_finder_create_options
        base.valid_finder_create_options = %w(create keep_duplicates skip_sort)
      end
    end

    module ClassMethods

      # adds a sanitize search for numbers for the options
      # used for finders
      # Use with find for other ActiveRecord objects
      #   Outbound.find :all, add_number_search([1,2,3], :conditions => 'outbounds.send_priority == 1')
      def add_number_search(numbers, options={}, merge_options={})
        number_digits = [numbers].flatten
        number_digits.collect!{|n| digits(n) } unless merge_options[:skip_sanitize]
        number_conditions = ['number in (?)', number_digits.uniq.compact]
        options[:conditions] = merge_conditions(options[:conditions]||{}, number_conditions)
        options
      end

      # Find all numbers (sanitized) that match a list of String +numbers+
      def find_all_by_numbers(numbers, options={}, merge_options={})
        return [] unless numbers.dup.delete_if{|x| x.blank? }.any?
        find(:all, add_number_search(numbers, options, merge_options))
      end

      # Find a single number
      def find_by_number(number, options={})
        find_all_by_numbers([number], options).first;
      end



      # Find all numbers and create if it doesn't already exist
      # +number_list+ - a list of numbers (String, ActiveRecord or attribute hash)
      # +options+ - additional create options and normal finder options like <tt>:conditions</tt>
      # === Additional Options
      # <tt>:create</tt> - <tt>:new</tt>(Default), <tt>:create</tt>, or <tt>:create!</tt>
      # If the number does not exist, create it with this method. Using <tt>:new</tt> means none of the objects are saved
      # <tt>:keep_duplicates<tt> - When set to true, duplicates in the list are returned
      # <tt>:skip_sort</tt> - Default is to sort the list to be in the same order as +number_list+.
      # Set to false to skip sorting (perf boost). Instance creation or attribute update does not occur
      # when <tt>skip_sort</tt> is false.
      def find_and_create_all_by_numbers(number_list, options={})
        create_options, finder_options = seperate_find_and_create_options(options)

        # Collect a list of digits and a list of attributes
        attribute_list = []
        number_digits = [number_list].flatten.inject([]) do |list, n|
          attribute_list << (new_attributes = value_to_hash(n))
          digit = digits(new_attributes[:number]||new_attributes['number'])
          digit = new_attributes[:number]||new_attributes['number'] if digit.blank?
          list << digit
          list
        end

        
        found_numbers = find_all_by_numbers(number_digits, finder_options, :skip_sanitize => true)
        # sort the list based on the order of the original input
        # not found values have nil
        if create_options[:skip_sort]
          found_numbers
        else
          sorted_numbers = sort_by_numbers(found_numbers, number_digits, create_options)
          transaction { update_attributes_on_list(sorted_numbers, attribute_list, create_options) }
        end
      end

      # Find a number and create if it does not exist
      # +options+ include those specified in find_all_and_create_by_number
      def find_and_create_by_number(number, options={})
        find_and_create_all_by_numbers(number, options.reverse_merge(:create => :new)).first
      end


      # Return the phone number with specified carrier if the phone number is an sms email address
      def find_by_sms_email_address(address, options={})
        number, carrier = reflections[:carrier].klass.carrier_from_sms_email(address)

        if number
          phone = find_by_number(number, options)||new(:number => number)
          phone.carrier = carrier if carrier
          phone
        else
          nil
        end

      end

      # The digits (numbers) only of the phone number
      # Digits are how phone numbers are stored in the database
      # The following all return +12065555555+
      #  SmsOnRails::digits(12065555555')
      #  SmsOnRails::digits(206.555.5555')
      #  SmsOnRails::digits(1206-555  5555')
      def digits(text)
        return text.digits if text.is_a?(self)
        number = text.to_s.gsub(/\D/,'')
        number = "1#{number}" if number.length == 10
        number
      end

      # The human display pretty phone number
      # (206) 555-5555
      def human_display(number)
        base_number = digits(number)
        if base_number.length == 11 && base_number.first == '1'
          "(#{base_number[1..3]}) #{base_number[4..6]}-#{base_number[7..10]}"
        elsif base_number.length > 0
          "+#{base_number}"
        else
          nil
        end
      end

      protected
            # Return create_options hash and finder options hash from all options
      def seperate_find_and_create_options(options={})#:nodoc:

        seperated_options = (options||{}).inject([{}, {}]) {|map, (k,v)|
          if valid_finder_create_options.include?(k.to_s)
            map.first[k.to_sym] = v
          else
            map.last[k.to_sym]  = v
          end
          map
        }
        seperated_options.first[:create] = :new if seperated_options.first[:create].is_a?(TrueClass)
        seperated_options
      end

     # Convert a PhoneNumber, hash map or string number
      # into an attribute hash
      def value_to_hash(digits)#:nodoc:
        attributes = if digits.is_a?(ActiveRecord::Base)
          digits.attributes
        elsif digits.is_a?(Hash)
          digits.dup
        elsif digits
          {:number => digits}
        end
        attributes
      end

            # Return a sorted list of PhoneNumber instances
      # Will create new records for missing records if attribute_list is specified
      # +unsorted_list+ - unsorted list of PhoneNumbers
      # +sorted_digits+ - sorted list of digits (Strings)
      # +attribute_list+ - optional list of attributes in sorted order
      # +creation_method+ - :create, :new, or :create!
      def sort_by_numbers(unsorted_list, sorted_digits, options={})

        unsorted_map = unsorted_list.inject({}) {|map, v| map[v.number] = v; map }

        # First sort the list in the order of the sorted digits
        # leaving nils for empty spaces
        sorted_list = if sorted_digits.length > 1
          sorted = [nil] * sorted_digits.length
          sorted_digits.each_with_index{|n, idx|
            sorted[idx] = unsorted_map[n]
            unsorted_map[n] = :used unless options[:keep_duplicates]
          }
          
          sorted.delete_if{|x| x == :used } unless options[:keep_duplicates]
          sorted
        else
          unsorted_list.any? ?  unsorted_list.dup : [nil]
        end
        sorted_list
      end

      # create new records for any records not found
      # update the attributes of the found records
      # save if :create
      def update_attributes_on_list(sorted_list, attribute_list, options={})
      
        unless attribute_list.blank?
          0.upto(sorted_list.length - 1) {|idx|
            if sorted_list[idx]
              if (attr = attribute_list[idx].delete_if{|x, y| x.to_s == 'number'}).any?
                sorted_list[idx].attributes = attr
                sorted_list[idx].save  if options[:create]
                sorted_list[idx].save! if options[:create!]
              end
            elsif options[:create]
              sorted_list[idx] = self.send(options[:create], attribute_list[idx])
            end
          }
        end
        sorted_list
      end

    end

    module InstanceMethods
      # The human display pretty phone number
      # (206) 555-5555
      def human_display
        self.class.human_display(self.number)
      end

      def number=(value)
        @original_number = value unless value.blank?
        @digits = self.class.digits(value)
        write_attribute :number, @digits
      end

      def number
        n = read_attribute :number
        n.blank? ? original_number : n
      end

      def digits
        @digits||=self.class.digits(self.number)
      end

      # return the sms email address from the carrier
      def sms_email_address
        carrier.sms_email_address(self) if carrier
      end

      #Assign the carrier to the phone number if it exists
      #+carrier+ - can be a ActiveRecord object, a name of the carrier, or carrier id
      def assign_carrier(carrier)
        specified_carrier = self.class.reflections[:carrier].klass.carrier_by_value(carrier)
        self.carrier = specified_carrier if specified_carrier
      end
      
      alias_method  :phone_number_digits, :digits

      # Returns true if the number is marked as do not send (not blank)
      # Values could be abuse, bounce, opt-out, etc
      def do_not_send?
        !self.do_not_send.blank?
      end
      
    end
  end
end
