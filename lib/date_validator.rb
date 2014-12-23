class DateValidator < ::ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if (!value.nil?)
      if options
        if options.include? :future
          record.errors[attribute] << 'cannot be a future date' if !options[:future] && record[attribute] > Date.new
          record.errors[attribute] << 'cannot be a past date' if options[:future] && record[attribute] < Date.new
        end
        if options.include? :greater_than_or_equal_to
          record.errors[attribute] << "should be greater than #{ options[:greater_than_or_equal_to].to_s(:long) }" if record[attribute] < options[:greater_than_or_equal_to]
        end
        if options.include? :less_than_or_equal_to
          record.errors[attribute] << "should be less than #{ options[:less_than_or_equal_to].to_s(:long) }" if record[attribute] > options[:less_than_or_equal_to]
        end
      end
    end
  end
end
