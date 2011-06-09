$(document).ready(function() {
    $('input[title!=""]').hint();
    $('a[href*="crunchbase.com"]').attr('target','_blank');
    $('.icons li').hover(
	function() { $(this).addClass('ui-state-hover'); },
	function() { $(this).removeClass('ui-state-hover'); }
    );
    $('.edit_button').button();
  
    $('#form-crunchbase').ajaxForm({ url: '/crunchbase', success: switch_form });

    $('#form-crunchnews').ajaxForm({ url: '/news' });
    $('.edit_alert').click(function() {
	$(this).text('');
	var update_alert = "<form class='form-update' method='post' name='alert'><select id='freq' name='freq'><option value='true'>Daily</option><option value='false'>Weekly</option></select><input id='news' name='news' type='checkbox' check value='true' /><input name='news' type='hidden' value='false' /><label for='news'>Include TechCrunch &amp; TechMeme news updates</label><div class='actions'><input id='alert_submit' type='submit' value='Submit' /></div></form>";
	$(this).parent().append(update_alert);
	var content = $(this).parent().attr('id');
	var alert_class = '.' + content;
	$(this).parent().find('form').addClass(content);

	var delete_button = "<br /><div id='delete_button'>delete button</div><br />";
	var cancel_button = "<br /><div id='cancel_button'>cancel button</div><br />";
	$(alert_class).append(delete_button);
	$(alert_class).append(cancel_button);

	$(alert_class).submit(function() {
	    var prefs = $(alert_class + ' *').fieldValue();
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
	    $(alert_class).remove();
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





		error: function(xhr, status, error) {
		    alert(xhr.responseText);
		}





	    });
	});
    }
};