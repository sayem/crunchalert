
$(document).ready(function() {
    $('input[title!=""]').hint();
    $('a[href*="crunchbase.com"]').attr('target','_blank');
    $('.icons li').hover(
	function() { $(this).addClass('ui-state-hover'); },
	function() { $(this).removeClass('ui-state-hover'); }
    );
    $('.edit_alert').button().css('font-weight','bold');
    if ($('#news-check').html()) {
	$.ajax({
	    url: '/news_prefs',
	    type: 'post',
	    success: function(data) {
		if (data == 'undefined') {
		    var news = "<input id='news' name='news' type='checkbox' value='true' /><label for='news'>Receive our news digest with the latest tech news<br /> and deals from CrunchBase</label>";
		    var freq = "<span style='font-weight:bold'>Frequency: </span><input type='radio' name='freq' value='true' />Daily<input type='radio' name='freq' value='false'/>Weekly";
		}
		else {
		    if (data[0])
			var news = "<input id='news' name='news' type='checkbox' value='true' checked/><label for='news'>Receive our news digest with the latest tech news<br /> and deals from CrunchBase</label>";
		    else
			var news = "<input id='news' name='news' type='checkbox' value='true' /><label for='news'>Receive our news digest with the latest tech news<br /> and deals from CrunchBase</label>";
		    if (data[1])
			var freq = "<span style='font-weight:bold'>Frequency: </span><input type='radio' name='freq' value='true' checked/>Daily<input type='radio' name='freq' value='false'/>Weekly";
		    else
			var freq = "<span style='font-weight:bold'>Frequency: </span><input type='radio' name='freq' value='true' />Daily<input type='radio' name='freq' value='false' checked/>Weekly";
		}
		$('#news-check').append(news);
		$('#news-freq').prepend(freq);
	    }
	});
    };
    $('.crunchalert-user').each(function() {
	var height = $(this).height();
	var width = $(this).width();
	var v_margin = (120 - height)/2;
	var h_margin = (255 - width)/2;
	$(this).css('margin-top', v_margin);	
	$(this).css('margin-left', h_margin);
    });
    if ($('#crunchbase').val() != 'enter a crunchbase profile name') {
	$('#crunchbase').val('enter a crunchbase profile name');
    }
    $('#crunchbase').click(function(){ $(this).val('') });
    $('#form-crunchbase').ajaxForm({ url: '/crunchbase', beforeSend: function() { $('#wait').css('visibility', 'visible') }, complete: function() { $('#wait').css('visibility', 'hidden') }, success: switch_form });
    $('#form-crunchnews').submit(function() {
	var prefs = $('#form-crunchnews *').fieldValue();
	if (prefs.length == '1') {
	    var news = false;
	    var freq = prefs[0];
	}
	else {
	    var news = true;
	    var freq = prefs[1];
	}
	$.ajax({
	    url: '/news',
	    type: 'post', 
	    data: { news: news, freq: freq },
	    async: false
	});
    })
    $('.edit_alert').click(function() {
	var content = $(this).parent().attr('id');
	var edit = '#edit-' + content;
	var content_id = '#' + content;
	$(edit).css('border', 'solid 1px #C9C9C9');
	$.ajax({
	    url: '/prefs',
	    type: 'post',
	    data: { content: content },
	    success: function(data) {
		if (data[0])
		    var freq = "<div class='edit-freq'>Frequency: <input type='radio' name='freq' value='true' checked>Daily<input type='radio' name='freq' value='false'>Weekly</div><input class='alert-submit' type='submit' value='Update' /></form>";
		else
		    var freq = "<div class='edit-freq'>Frequency: <input type='radio' name='freq' value='true'>Daily<input type='radio' name='freq' value='false' checked>Weekly</div><input class='alert-submit' type='submit' value='Update' /></form>";
		if (data[1])
		    var news = "<form class='form-update' method='post' name='alert'><div class='edit-news'><input id='news' name='news' type='checkbox' check value='true' checked/><input name='news' type='hidden' value='false'/><label for='news'>Include TechCrunch &amp; TechMeme news</label></div>";
		else
		    var news = "<form class='form-update' method='post' name='alert'><div class='edit-news'><input id='news' name='news' type='checkbox' check value='true'/><input name='news' type='hidden' value='false'/><label for='news'>Include TechCrunch &amp; TechMeme news</label></div>";
		var update_alert = news + freq;
		$(edit).append(update_alert);
	    }
	});

	var cancel_button = "<div class='button ui-widget ui-helper-clearfix icons cancel_button'><li class='ui-state-default ui-corner-all'><span class='ui-icon ui-icon-closethick'></span></li></div>";
	var delete_button = "<a href='/' class='delete-alert'>Delete CrunchAlert</a>";
	$(edit).append(cancel_button);
	$(edit).append(delete_button);
	$('.delete-alert').click(function() {
	    $.ajax({
		url: '/removealert',
		type: 'post',
		data: { content: content },
		async: false
	    });
	});
	$('.cancel_button').click(function() {
	    $(edit).find('.form-update').remove();
	    $(edit).find('.delete-alert').remove();
	    $(edit).find('.cancel_button').remove();
	    $(edit).css('border', 'none');
	});
	$(edit).submit(function() {
	    var prefs = $('.form-update *').fieldValue();
	    if (prefs.length == '3') {
		var news = prefs[0];
		var freq = prefs[2];
	    }
	    else {
		var news = prefs[0];
		var freq = prefs[1];
	    }
	    $.ajax({
		url: '/editalert',
		type: 'post', 
		data: { content: content, news: news, freq: freq },
		async: false
	    });
	});
    });
    $(".crunchalert").click(function(e){   
	e.stopPropagation();
    });
    $(document).click(function(){
	$(".form-update").parent().css('border', 'none');
	$(".form-update").remove();
	$(".delete-alert").remove();
	$(".cancel_button").remove();
    });
});

function switch_form(data) {
    if (data == 'not there') {
	$('#form-crunchbase').remove();
	var submit_url = "<div id='submit-url'>Sorry, we\'re having trouble finding that. Please enter that profile's CrunchBase URL below to add it as an alert:<form id='form-submit-url' method='post' name='url'><input id='url' name='url' type='text' value='crunchbase.com url' /><div id='url-buttons'><span id='url-cancel'>cancel button</span><input id='url-submit' type='submit' value='Submit' /></div></form></div>";
	$('#crunchbase-search').append(submit_url);
	$('#url').click(function() {
	    $(this).attr('value','');
	})
	$('#url-cancel').click(function() {
	    window.location.reload();
	});
	$('#form-submit-url').ajaxForm({ url: '/crunchbaseurl', success: switch_form });
    }
    else {
	if (data[3]) {
	    var content = data[2];
	    var type = data[3];
	}
	else {
	    var content = $('#form-crunchbase *').fieldValue()[0];
	    var type = $('#form-crunchbase *').fieldValue()[1];
	}
	var picurl = data[0];
	$('#form-crunchbase').remove();
	$('#submit-url').remove();
	$('#crunchbase-search').append(data[1]);
	var new_form = "<form id='form-alert' method='post' name='alert'><div id='form-check'><label for='news'>Include TechCrunch &amp; TechMeme news updates</label><input id='news' name='news' type='checkbox' check value='true' /><input name='news' type='hidden' value='false' /></div><div id='form-freq'><span style='font-weight:bold'>Frequency: </span><input type='radio' name='freq' value='true'>Daily<input type='radio' name='freq' value='false'>Weekly</div><div class='actions'><input id='form-submit' type='submit' value='Add' /></div></form>";
	$('#crunchbase-search').append(new_form);
	$('#form-alert').submit(function() {
	    var prefs = $('#form-alert *').fieldValue();
	    if (prefs.length == '3') {
		var news = prefs[0];
		var freq = prefs[2];
	    }
	    else {
		var news = prefs[0];
		var freq = prefs[1];
	    }
	    content = content.replace(/\s/g,'-');
	    $.ajax({
		url: '/crunchalert',
		type: 'post',
		data: { content: content, type: type, freq: freq, news: news, pic: picurl },
		async: false,
		success: function(data) {
		    var message = data.split("\"")[1];
		    if (message != 'already added')
			window.location.reload();
		    else {
			$('#form-crunchnews').append(message);
			//			$('#input').remove(); //
			setTimeout("window.location.reload()", 2500);
		    }
		}
	    });
	    return false;
	});
    }
};