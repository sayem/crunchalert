
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
	$(this).append(update_alert);
	var delete_button = "delete button";
	var cancel_button = "cancel button";
	$(this).append(delete_button);
	$(this).append(cancel_button);
    });

/*
- get ajax values for update alert for news/freq, figure out form submission
- ajax for removing this Edit and showing freq/news fields and update/delete/cancel button
- then put in delete button and cancel button
*/    

});

function switch_form(data) {
    if (data == 'not there') {
	$('#form-crunchbase').remove();
	var submit_url = "Couldn't find the profile. Please enter the CrunchBase profile URL here:<form id='form-submit_url' method='post' name='url'><input id='url' name='url' type='text' title='crunchbase url' /><input id='url_submit' type='submit' value='Submit' /></form>";
	$('#input').append(submit_url);


	$('#form-submit_url').submit(function() {
	    url = $('#form-submit_url *').val();
	    $.post('/crunchbaseurl', { url: url }, function(data) {

// put in rules to switch to crunchalert form if good, else re-enter ----> change this entire thing to an ajaxform, just like crunchbaseform

		alert(data);


	    });
	});

// put in cancel button



    }
    else {
	var content = $('#form-crunchbase *').fieldValue()[0];
	var type = $('#form-crunchbase *').fieldValue()[1];
	var picurl = data[0];
	$('#form-crunchbase').remove();
	$('#input').append(data[1]);
	$('#input').append(data[2]);

	var new_form = "<form id='form-alert' method='post' name='alert'><select id='freq' name='freq'><option value='true'>Daily</option><option value='false'>Weekly</option></select><input id='news' name='news' type='checkbox' check value='true' /><input name='news' type='hidden' value='false' /><label for='news'>Include TechCrunch &amp; TechMeme news updates</label><div class='actions'><input id='alert_submit' type='submit' value='Submit' /></div></form>";
	$('#input').append(new_form);
	$('#form-alert').submit(function() {
	    var prefs = $('#form-alert *').fieldValue();
	    $.post('/crunchalert', { content: content, type: type, freq: prefs[0], news: prefs[1], pic: picurl }, function(data) {



		if (data)
		    alert(data);
		else 
		    alert('not true');



	    });
	    alert('added');
	});
    }
};