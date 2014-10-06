helpers do
  def javascripts *scripts
    javascripts = (@js ? @js + settings.javascripts + args : settings.javascripts + args).uniq
    javascripts.each do |script|
      html << "<script src=\"/#{script}\"></script>"
    end.join    
  end
end