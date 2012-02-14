class Comments::ShowPresenter
  attr_reader :controller, :comment
  
  extend ActiveModel::Naming
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::DateHelper
  include Rails.application.routes.url_helpers
  
  def initialize(comment)
    @comment = comment
  end
  
  def title
    u = link_to user.username, user_path(:id => user.username), :class => 'username'
    w = time_ago_in_words(comment.created_at)
    "#{u} commented #{w} ago".html_safe
  end
  
  def user
    comment.user
  end
  
  def content
    @content ||= begin
      raw = Replaceable.new(comment.content)
      raw.replace_gists!
      raw.replace_tags!
      raw.replace_usernames!
    end
  end
end
