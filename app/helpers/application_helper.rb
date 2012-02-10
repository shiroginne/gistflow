# coding: utf-8

module ApplicationHelper
  GIST_URL = "https://gist.github.com"  
  
  def gist_js_url id
    "#{GIST_URL}/#{id}.js"
  end
  
  def render_flash
    capture_haml do
      flash.each do |type, message|
        haml_tag :div, :class => alert_classes(type) do
          haml_tag :a, :class => 'close' do
            haml_concat "×"
          end
          haml_concat message
        end
      end
    end
  end
  
  def post_tags(post)
    capture_haml do
      haml_tag :div, :class => "tags" do
        post.tags.each do |tag|
          haml_tag :a, :href => tag_path(tag.name) do
            haml_concat "##{tag.name}"
          end
        end
      end
    end
  end
  
  def alert_classes(type)
    classes = ['alert']
    classes << case type.to_sym
    when :notice then
      'alert-success'
    when :alert then
      'alert-error'
    end
    classes.join ' '
  end
    
  def login_url
    if Rails.env.development?
      login_path
    else
      'https://github.com/login/oauth/authorize?client_id=83dfd929d47091e3902d'
    end
  end
  
  def avatar_image(user, size)
    image_tag user.gravatar(size)
  end
  
  def title(title)
    content_for(:title, title)
  end
  
  def credits
    creators = ['releu', 'makaroni4'].shuffle.map do |u|
      link_to "@#{u}", "https://github.com/#{u}"
    end
    
    "Created by #{creators[0]} and #{creators[1]}".html_safe
  end
  
  def categories_menu
    capture_haml do
      categories_items.each do |item|
        haml_tag :small do
          haml_concat item
        end
      end
    end
  end
  
  def user_gists_title(user)
    title = user == current_user ? "Your gists" : "#{user.username} on Github"
    
    capture_haml do
      caption_haml title
    end
  end
  
  def caption_haml(title)
    haml_tag :div, :class => 'caption' do
      haml_concat title
    end
  end
  
  def user_page_title(user)
    name = current_user == user ? "Your" : "#{user.username}'s"
    capture_haml do
      caption_haml "#{name} posts"
    end
  end
  
  def sidebar_posts(title, posts, more_url)
    capture_haml do
      caption_haml title

      posts.each do |post|
        haml_tag :div, :class => 'sidebar_link' do
          #FIX post.title from content
          #FIX post_path to models_path
          haml_concat link_to(post.content[0..30], post_path(post)).html_safe
        end
      end
      haml_tag :div, :class => 'sidebar_link' do
        haml_concat link_to "more", more_url
      end
    end
  end
  
  def authentication_menu
    capture_haml do
      haml_tag :ul, :class => 'authentication' do
        authentication_items.each_with_index do |item, index|
          haml_tag :li do
            haml_concat item
            if authentication_items.size != index.next
              haml_tag(:span) { haml_concat '|' }
            end
          end
        end
      end
    end
  end
  
  def cookie_gists
    JSON.parse(cookies[:gists]).map do |raw|
      Github::Gist.new(
        :id => raw['id'],
        :description => raw['description']
      )
    end if cookies[:gists]
  end
  
  def link_to_notifiable(notification)
    username = notification.notifiable.user.username
    user_link = link_to(
      username, 
      user_path(:id => username), 
      :class => 'username'
    )
    record_link = notification.notifiable.link_to_post
    
    time = time_ago_in_words(notification.created_at)
    
    "#{user_link} mentioned you in #{record_link} #{time} ago".html_safe
  end
  
protected
  
  def categories_items
    { :articles  => articles_path,
      :questions => questions_path,
      :community => community_index_path }.map do |name, link|
      link_to_unless_current name, link
    end
  end
  
  def authentication_items
    items = []
    if user_signed_in?
      
      items << link_to(
        current_user.username, 
        user_path(current_user.username), 
        :class => 'username'
      )
      
      unread_notifications = current_user.notifications.unread
      unread_notifications_block = content_tag(
        :span, "+#{unread_notifications.count}", 
        :class => "unread_notification_counter"
      ) if unread_notifications.any?
      
      items << link_to(
        "notifications#{unread_notifications_block}".html_safe,     
        notifications_path
      )
      items << link_to('logout', logout_path)
    else
      items << link_to('login', login_url, :class => 'login')
    end
    items
  end
  
  def subscription_form(subscription)
    locals = { :subscription => subscription }
    partial = subscription.new_record? ? 'form' : 'destroy_form'
    render :partial => "subscriptions/#{partial}", :locals => locals
  end
  
end
