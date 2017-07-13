<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<title>Docker Hive Cluster</title>
	<link rel="stylesheet" type="text/css" href="style.css">
	<? 	$manager_dir = '/synced/www/managers';
		$manager_files = array_values(array_diff(scandir($manager_dir), array('..', '.')));
		#print_r($manager_files);
		foreach ($manager_files as $manager) {
			#echo $manager;
		}
	?>
	<script language="javascript" type="text/javascript" src="jquery.min.js"></script>
	<script type="text/javascript">
		window.onload = function() { 
			//if (window.jQuery) { alert("JQuery is loaded!"); } else { alert("JQuery doesn't Work"); }
		}
		/*
		jQuery.fn.extend({
			ExistingFile: function() {
				var whaturl = $(this).text();
				var result = false;
				$.ajax({
					url:'../'+whaturl,
					type:'HEAD',
					error: function()
						{
							result = false;
						},
					success: function()
						{	
							result = true;
						}
				});
				return result;
			}
		}); */
		//alert(('#dockerhost1').ExistingFile());
		function sendRequest(){
			$("#testB").html('starting sendRequest');
			$.ajax({
				url: '../managers/dockerhost1',
				type: 'GET',
				async: false,
				success: function(t){
					$("#testB").html('succes part 1');
					$("#testB").html(t);
						//$("#div_manager_id").text(data); //insert text of test.php into your div
						setTimeout(function(){	
							sendRequest(); //this will send request again and again;
						}, 5000);
					//});
				},
				error: function() {
						alert('failed to ajax-grab file');
				}
					
			});
		};
		/*	$.getJSON( "/managers/dockerhost1", function( data ) {
				var items=[];
				$.each( data, function(key,val) {
					items.push( "<li id='" + key + "'>" + val + "</li>" );
				});
				$( "<ul/>", {
					"class": "my-new-list",
					html: items.join( "" )
				}).appendTo( "body" );
			}); 
		}; */
		$(document).ready(function() {
			sendRequest();
			//$("#testB").html('testC');
			/*$.ajax({
				url:'../managers/dockerhost1',
				type:'HEAD',
				error: function()
					{
						$("#div_manager_id").html("fail");
					},
				success: function()
					{	
						$("#div_manager_id").html("success");
					}
			}); 
			*/
		});
		


	</script>
</head>
<body>
	<header>
		<div class="div_container">
			<div id="logo"></div>
		</div>
	</header>
	<div class="div_container">
		<div class="row">
			<div class="div_container">
				<h3>Swarm Managers</h3>
				<p> <div id="div_manager_id"></div>
					<div id="testB"></div></p>
			</div>

			<div class="div_container">
				<h3>Worker nodes</h3>
			</div>
		</div>
		<hr/>
		<footer>
			<p>footer p1</p>
			<p>
				<small>small</small>
			</p>
		</footer>
	</div>
</body>
</html>
