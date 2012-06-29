module ApplicationHelper

  def title(text)
    content_for :title, text
    content_tag(:h2, text, class: 'title')
  end

end
