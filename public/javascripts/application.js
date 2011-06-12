
$(document).ready(function() {
    $('input[title!=""]').hint();
    $('a[href*="crunchbase.com"]').attr('target','_blank');
    $('.icons li').hover(
	function() { $(this).addClass('ui-state-hover'); },
	function() { $(this).removeClass('ui-state-hover'); }
    );
    $('.edit_button').button();

    $('#form-crunchbase').ajaxForm({ url: '/crunchbase', beforeSend: function() { $('#wait').css('visibility', 'visible') }, complete: function() { $('#wait').css('visibility', 'hidden') }, success: switch_form });

    $('#form-crunchnews').ajaxForm({ url: '/news' });

    $('.edit_alert').click(function() {
	var content = $(this).parent().attr('id');
	var content_id = '#' + content;
	$.ajax({
	    url: '/prefs',
	    type: 'post',
	    data: { content: content },
	    success: function(data) {
		if (data[0])
		    var freq = "<form class='form-update' method='post' name='alert'><input type='radio' name='freq' value='true' checked>Daily<br><input type='radio' name='freq' value='false'>Weekly<br>"
		else
		    var freq = "<form class='form-update' method='post' name='alert'><input type='radio' name='freq' value='true'>Daily<br><input type='radio' name='freq' value='false' checked>Weekly<br>"
		if (data[1])
		    var news = "<input id='news' name='news' type='checkbox' check value='true' checked/><input name='news' type='hidden' value='false'/><label for='news'>Include TechCrunch &amp; TechMeme news updates</label><div class='actions'><input id='alert_submit' type='submit' value='Submit' /></div></form>";
		else
		    var news = "<input id='news' name='news' type='checkbox' check value='true'/><input name='news' type='hidden' value='false'/><label for='news'>Include TechCrunch &amp; TechMeme news updates</label><div class='actions'><input id='alert_submit' type='submit' value='Submit' /></div></form>";

		var update_alert = freq + news;
		$(content_id).append(update_alert);
	    }
	});

	var delete_button = "<div id='delete_button' class='form-update'>delete button</div>";
	var cancel_button = "<div id='cancel_button' class='form-update'>cancel button</div>";
	$(content_id).append(delete_button);
	$(content_id).append(cancel_button);
	$(this).text('');

	$(content_id).submit(function() {
	    var prefs = $('.form-update *').fieldValue();
	    $.ajax({
		url: '/editalert',
		type: 'post', 
		data: { content: content, freq: prefs[0], news: prefs[1] },
		async: false
	    });
	});

	$('#delete_button').click(function() {
	    $.ajax({
		url: '/removealert',
		type: 'post',
		data: { content: content },
		async: false
	    });
	    window.location.reload();
	});

	$('#cancel_button').click(function() {
	    $(".form-update").remove();
	    $(".edit_alert").text('Edit');
	});
    });

    $(".crunchalert").click(function(e){   
	e.stopPropagation();
    });

    $(document).click(function(){
	$(".form-update").remove();
	$(".edit_alert").text('Edit');
    });
});


function switch_form(data) {
    if (data == 'not there') {
	$('#form-crunchbase').remove();
	var submit_url = "Couldn't find the profile. Please enter the CrunchBase profile URL here:<form id='form-submit_url' method='post' name='url'><input id='url' name='url' type='text' title='crunchbase url' /><input id='url_submit' type='submit' value='Submit' /></form>";
	$('#input').append(submit_url);

	var cancel_button = "<br /><div id='cancel_button'>cancel button</div><br />";
	$('#form-submit_url').append(cancel_button);
	$('#cancel_button').click(function() {
	    window.location.reload();
	});
	$('#form-submit_url').ajaxForm({ url: '/crunchbaseurl', success: switch_form });
    }
    else {
	if (data[3]) {
	    var content = data[2];
	    var type = data[3];
	}
	else {
	    var content = $('#form-crunchbase *').fieldValue()[0];
	    var type = $('#form-crunchbase *').fieldValue()[1];
	    $('#input').append(data[2]);
	}
	var picurl = data[0];
	$('#form-crunchbase').remove();
	$('#input').append(data[1]);
	var new_form = "<form id='form-alert' method='post' name='alert'><select id='freq' name='freq'><option value='true'>Daily</option><option value='false'>Weekly</option></select><input id='news' name='news' type='checkbox' check value='true' /><input name='news' type='hidden' value='false' /><label for='news'>Include TechCrunch &amp; TechMeme news updates</label><div class='actions'><input id='alert_submit' type='submit' value='Submit' /></div></form>";
	$('#input').append(new_form);
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
			$('#input').remove();
			setTimeout("window.location.reload()", 2500);
		    }
		}
	    });
	    return false;
	});
    }
};