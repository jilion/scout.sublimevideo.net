module ApplicationHelper

  def title(text, page_title = true)
    content_for :title, text
    content_tag(:h2, text, class: 'title') if page_title
  end

   def url_with_protocol(url)
    return '' if url.blank?
    (url =~ %r(^https?://) ? '' : 'http://') + url
  end

end
