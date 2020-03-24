class CountValidator < ::ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if (!value.nil? && options.include?(:allow_blank))
      if options.include? :limit
        if value.length > options[:limit]
          message = options[:message] || "can have maximum of #{ options[:limit] }"
          message = (message.arity.zero? ? message.call : message.call(record)) if message.is_a?(Proc)
          record.errors.add(attribute, message)
        end
      end
    end
  end
end