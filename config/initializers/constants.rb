module Constants
  IMAGE_UPLOAD_FORMATS = %w(image/jpg image/jpeg image/png)
  PAN_REGEXP = /\A[a-z]{3}[abcfghljpt]{1}[a-z]{1}[0-9]{4}[a-z]{1}\Z/i
  DEFAULT_CURRENCY = 'INR'

  case Rails.env
  when 'development'
    INITIAL_COMMENT_DISPLAY_LIMIT  = 20
    ADMIN_RECORDS_PAGINATION_LIMIT = 20
    PROJECT_HOME_PAGE_LIMIT        = 4
    PROJECT_LIST_PAGE_LIMIT        = 28
  when 'production'
    INITIAL_COMMENT_DISPLAY_LIMIT  = 20
    ADMIN_RECORDS_PAGINATION_LIMIT = 20
    PROJECT_HOME_PAGE_LIMIT        = 4
    PROJECT_LIST_PAGE_LIMIT        = 28
  when 'test'
    INITIAL_COMMENT_DISPLAY_LIMIT  = 20
    ADMIN_RECORDS_PAGINATION_LIMIT = 20
    PROJECT_HOME_PAGE_LIMIT        = 4
    PROJECT_LIST_PAGE_LIMIT        = 28    
  else

  end

end
