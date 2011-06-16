
$(document).ready(function() {
    $('input[title!=""]').hint();
    $('a[href*="crunchbase.com"]').attr('target','_blank');
    $('.icons li').hover(
	function() { $(this).addClass('ui-state-hover'); },
	function() { $(this).removeClass('ui-state-hover'); }
    );
    $('.edit_alert').button().css('font-weight','bold');
    $('#form-crunchbase').ajaxForm({ url: '/crunchbase', beforeSend: function() { $('#wait').css('visibility', 'visible') }, complete: function() { $('#wait').css('visibility', 'hidden') }, success: switch_form });
    $('#form-crunchnews').ajaxForm({ url: '/news' });
    $('.edit_alert').click(function() {
	var content = $(this).parent().attr('id');
	var edit = '#edit-' + content;
	var content_id = '#' + content;
	$.ajax({
	    url: '/prefs',
	    type: 'post',
	    data: { content: content },
	    success: function(data) {
		if (data[0])
		    var freq = "<div class='edit-freq'>Frequency: <input type='radio' name='freq' value='true' checked>Daily<input type='radio' name='freq' value='false'>Weekly</div><input class='alert-submit' type='submit' value='Update' /></form><div class='delete-alert'>Delete CrunchAlert</div><div class='button ui-widget ui-helper-clearfix icons'><li class='ui-state-default ui-corner-all'><span class='ui-icon ui-icon-close'></span></li></div>";
		else
		    var freq = "<div class='edit-freq'>Frequency: <input type='radio' name='freq' value='true'>Daily<input type='radio' name='freq' value='false' checked>Weekly</div><input class='alert-submit' type='submit' value='Update' /></form><div class='delete-alert'>Delete CrunchAlert</div><div class='button ui-widget ui-helper-clearfix icons'><li class='ui-state-default ui-corner-all'><span class='ui-icon ui-icon-close'></span></li></div>";
		if (data[1])
		    var news = "<form class='form-update' method='post' name='alert'><div class='edit-news'><input id='news' name='news' type='checkbox' check value='true' checked/><input name='news' type='hidden' value='false'/><label for='news'>Include TechCrunch &amp; TechMeme news</label></div>";
		else
		    var news = "<form class='form-update' method='post' name='alert'><div class='edit-news'><input id='news' name='news' type='checkbox' check value='true'/><input name='news' type='hidden' value='false'/><label for='news'>Include TechCrunch &amp; TechMeme news</label></div>";
		var update_alert = news + freq;
		$(edit).append(update_alert);
	    }
	});


/*
	var delete_button = "<div id='delete_button' class='form-update'>delete button</div>";
	var cancel_button = "<div id='cancel_button' class='form-update'>cancel button</div>";
	$(edit).append(delete_button);
	$(edit).append(cancel_button);
*/

	$(edit).submit(function() {
	    var prefs = $('.form-update *').fieldValue();
	    $.ajax({
		url: '/editalert',
		type: 'post', 
		data: { content: content, freq: prefs[0], news: prefs[1] },
		async: false
	    });
	});

	$('.delete-alert').click(function() {       // make delete work with new div
	    $.ajax({
		url: '/removealert',
		type: 'post',
		data: { content: content },
		async: false
	    });
	    window.location.reload();
	});

	$('#cancel_button').click(function() {      // update cancel button with jquery ui button
	    $(".form-update").remove();
	});
    });

    $(".crunchalert").click(function(e){   
	e.stopPropagation();
    });

    $(document).click(function(){
	$(".form-update").remove();
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
	    content = content.replace(/\s/g,'-');
	    $.ajax({
		url: '/crunchalert',
		type: 'post',
		data: { content: content, type: type, freq: prefs[0], news: prefs[1], pic: picurl },
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