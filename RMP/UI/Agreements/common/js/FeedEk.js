(function ($) {
  $.fn.FeedEk = function (opt, callback) {
    var def = { FeedUrl: '', MaxCount: 5, ShowDesc: true, ShowPubDate: true,  HiddenDivToShow:''};
    if (opt) { $.extend(def, opt) } var idd = $(this).attr('id');

    if (def.FeedUrl == null || def.FeedUrl == '') {
      $('#' + idd).empty(); return
    }
    var hasFeeds = false;

    var pubdt;
    
    $('#' + idd).empty().append('<div style="text-align:left; padding:3px;"><img src="../Images/loader.gif" /></div>');
    $.ajax({ url: 'https://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=' + def.MaxCount + '&output=json&q=' + encodeURIComponent(def.FeedUrl) + '&callback=?', dataType: 'json', success: function (data) {
      $('#' + idd).empty();
      $.each(data.responseData.feed.entries, function (i, entry) {
        hasFeeds = true;
        $('#' + idd).append('<div class="ItemTitle"><a href="' + entry.link + '" target="_blank" >' + entry.title + '</a></div>');
        if (def.ShowPubDate) {
          pubdt = new Date(entry.publishedDate);
          $('#' + idd).append('<div class="ItemDate">' + pubdt.toLocaleDateString() + '</div>')
        }
        if (def.ShowDesc) $('#' + idd).append('<div class="ItemContent">' + entry.content + '</div>')

      })
      if (hasFeeds && def.HiddenDivToShow != '') {
        $("#"+def.HiddenDivToShow).show();
      } 
    }
    }).done(function(){
		if(typeof callback == 'function'){ callback.call(this);}
	})
	
  }




})



(jQuery);
