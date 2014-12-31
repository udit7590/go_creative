module ProjectHelper
  def humanize_sti_class(classname, baseclass = 'Project')
    classname.gsub(baseclass, '')
  end
  def contribute_button_text(type)
    type == 'CharityProject' ? 'Donate' : 'Invest'
  end
end
