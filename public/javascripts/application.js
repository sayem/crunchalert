
$(document).ready(function() {
    var crunchbase_options = {
	url: '/crunchbase',
	dataType: 'json',
	success: switch_form
    };
    $('#form-crunchbase').ajaxForm(crunchbase_options);

    $('.edit_alert').click(function() {
	$this.remove();
	



    })
/*

- ajax for removing this Edit and showing freq/news fields and update/delete/cancel button  ----- add html
- then put in delete button and cancel button

*/

    

});

function switch_form(data) {
    var content = $('#form-crunchbase *').fieldValue()[0];
    var picurl = data[0];
    $('#form-crunchbase').remove();
    $('#input').append(data[1]);
    $('#input').append(data[2]);

    var new_form = "<form id='form-alert' method='post' name='alert'><select id='freq' name='freq'><option value='true'>Daily</option><option value='false'>Weekly</option></select><input id='news' name='news' type='checkbox' check value='true' /><input name='news' type='hidden' value='false' /><label for='news'>Include TechCrunch &amp; TechMeme news updates</label><div class='actions'><input id='alert_submit' type='submit' value='Submit' /></div></form>";
    $('#input').append(new_form);

    $('#form-alert').submit(function() {
	var prefs = $('#form-alert *').fieldValue();
	$.post('/crunchalert', { content: content, freq: prefs[0], news: prefs[1], pic: picurl }, function(data) {


/*
	    if (data)
		alert(data);
	    else 
		alert('not true');

*/


	});
	alert('added');
    });
};