module ApplicationHelper

  def title(text)
    content_for :title, text
    content_tag(:h2, text, class: 'title')
  end

   def url_with_protocol(url)
    return '' if url.blank?
    (url =~ %r(^https?://) ? '' : 'http://') + url
  end

end
