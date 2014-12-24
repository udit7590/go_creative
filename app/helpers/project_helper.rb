module ProjectHelper
  def humanize_sti_class(classname, baseclass = 'Project')
    classname.gsub(baseclass, '')
  end
end
