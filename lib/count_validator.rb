class CountValidator < ::ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if (!value.nil?)
      if options
        if options.include? :limit
          record.errors[attribute] << "can have maximum of #{ options[:limit] }" if record[attribute] && record[attribute].length > options[:limit]
        end
      end
    end
  end
end