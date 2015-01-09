class DateValidator < ::ActiveModel::EachValidator
  #FIXME_AB: reduce complixity of this method by reducing nested if statements
  def validate_each(record, attribute, value)
    #FIXME_AB: use value.present? 
    if (!value.nil?)
      if options
        if options.include? :future
          #FIXME_AB: Is this validation working fine Date.new gives  Mon, 01 Jan -4712. I think you should use Date.current which also take care of timezone of the application
          record.errors[attribute] << 'cannot be a future date' if !options[:future] && record[attribute] > Date.new
          record.errors[attribute] << 'cannot be a past date' if options[:future] && record[attribute] < Date.new
        end
        if options.include? :greater_than_or_equal_to
          #FIXME_AB: following message and condition is not metching the about check :greater_than_or_equal_to
          record.errors[attribute] << "should be greater than #{ options[:greater_than_or_equal_to].to_s(:long) }" if record[attribute] < options[:greater_than_or_equal_to]
        end
        if options.include? :less_than_or_equal_to
          record.errors[attribute] << "should be less than #{ options[:less_than_or_equal_to].to_s(:long) }" if record[attribute] > options[:less_than_or_equal_to]
        end
      end
    end
  end
end
