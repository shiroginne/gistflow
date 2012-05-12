$(function(){
  var inline_gist_template = _.template(' \
    <li> \
      <a href="/posts/new" class="add" data-id="<%= id %>" data-lang="<%= language %>">add</a> \
      <%= description %> \
      <a href="https://gist.github.com/gists/<%= id %>/edit">edit</a> \
    </li> \
  ')
  if (window.current_user) {
    var url = 'https://api.github.com/users/' + window.current_user.username + '/gists'
    $.getJSON(url, function(gists){
      var section = $('section.gists')
      section.find('p').remove()
      var ul = $('<ul>')
      section.append(ul)
      $.each(gists, function(index, gist){
        languages = _.map(gist.files, function(file, name){
          if (file.language) return '#' + file.language.toLowerCase()
        })
        languages = _.uniq(languages)
        languages = _.compact(languages)
        gist.language = languages.join(' ')
        ul.append(inline_gist_template(gist))
      })
      section.find('a.add').tooltip({title: 'Add gist to new post or comment'});
    })
  
    var field_gist = _.template('gist:<%= id %> <%= lang %> ')
  
    $(document).on('click', 'section.gists a.add', function(e){
      e.preventDefault()
      var content = field_gist({
        id: $(this).data('id'),
        lang: $(this).data('lang')
      })
      var content_field = $('#post_content')
      if (content_field.length > 0) {
         box.val(box.val() + content)
      } else {
        document.location = $(this).attr('href') + '?content=' + escape(content)
      }
    })
  }
  
  $("article.post a:contains('gist:')").click(function(){
    var article = $(this).parents('article:first')
    if (!article.hasClass('detail')) {
      document.location = article.attr('rel')
      return false
    }
  })
  
  var detail_gist_template = _.template(' \
    <div class="gist"> \
      <pre> \
        <code class="<%= lang %>"><%= code %></code> \
      </pre> \
    </div> \
  ')
  
  $("article.post.detail a:contains('gist:')").each(function(){
    var id = $(this).html().match(/gist:(\d+)/)[1];
    var element = $(this);
    $.getJSON('https://api.github.com/gists/' + id, function(data){
      _.each(data.files, function(raw, name){
        var gist = detail_gist_template({ code: raw.content, lang: raw.language.toLowerCase() });
        element.after(gist);
      });
      // remove all rehighlighting
      $('pre code').each(function(i, e) { hljs.highlightBlock(e) });
      element.remove();
    })
  })
});
