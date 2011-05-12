/*

- put in delete button and test
- put in cancel button on url/edit form and check errors/responses too

*/

$(document).ready(function() {
    var crunchbase_options = {
	url: '/crunchbase',
	success: switch_form
    };
    $('#form-crunchbase').ajaxForm(crunchbase_options);
    var crunchnews_options = {
	url: '/news',
	dataType: 'json',
    };
    $('#form-crunchnews').ajaxForm(crunchnews_options);
    $('.edit_alert').click(function() {
	$(this).text('');
	var update_alert = "<form id='form-update' method='post' name='alert'><select id='freq' name='freq'><option value='true'>Daily</option><option value='false'>Weekly</option></select><input id='news' name='news' type='checkbox' check value='true' /><input name='news' type='hidden' value='false' /><label for='news'>Include TechCrunch &amp; TechMeme news updates</label><div class='actions'><input id='alert_submit' type='submit' value='Submit' /></div></form>";
	$(this).parent().append(update_alert);
	var delete_button = "delete button";
	var cancel_button = "cancel button";
	$('#form-update').append(delete_button);
	$('#form-update').append(cancel_button);

	$('#form-update').submit(function() {
	    var prefs = $('#form-update *').fieldValue();
	    var content = $(this).parent().attr('id');
	    $.ajax({
		url: '/editalert',
		type: 'post', 
		data: { content: content, freq: prefs[0], news: prefs[1] },
		async: false
	    });
	});


	// put in delete func to post too, on click


    });
});

function switch_form(data) {
    if (data == 'not there') {
	$('#form-crunchbase').remove();
	var submit_url = "Couldn't find the profile. Please enter the CrunchBase profile URL here:<form id='form-submit_url' method='post' name='url'><input id='url' name='url' type='text' title='crunchbase url' /><input id='url_submit' type='submit' value='Submit' /></form>";
	$('#input').append(submit_url);
	var url_options = {
	    url: '/crunchbaseurl',
	    success: switch_form
	};
	$('#form-submit_url').ajaxForm(url_options);
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
	    $.ajax({
		url: '/crunchalert',
		type: 'post', 
		data: { content: content, type: type, freq: prefs[0], news: prefs[1], pic: picurl },
		async: false
	    });
	});
    }
};