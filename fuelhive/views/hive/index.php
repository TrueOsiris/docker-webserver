<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<title>Docker Hive Cluster</title>
	<?php echo Asset::css('bootstrap.css'); ?>
	<script language="javascript" type="text/javascript" src="jquery.min.js"></script>
	<script type="text/javascript">
		//window.onload = function() { if (window.jQuery) { alert("JQuery is loaded!"); } else { alert("JQuery doesn't Work"); }}
	</script>
	<style>
		#logo{
			display: block;
			background-image: url('data:image/png;base64,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JuLub9Vv69atQjQ3RdUSBEEQxCAYgCNGjEBhYSE450hNTcWCBQtga2sLa2trHD58GCqVCk1NTUhOToadnV2/W4czZ87E/v37cfjw4QH7kP2csLW1FQzAd999V+f61tbWQv3IyMgXpt82NjaQy+VoaGjosR39U8aPH489e/agsrISsbGxBklOThAEQRC/JIy6rUBtZWNjw/bu3ctWr17NzMzMNO599913zNLSkv39739n165dY7W1teyrr75iP/74I7O1tWVubm5s4sSJzMrKipWWlrKsrCz29ddfUxjOT5SXl8ekUil76623NKJvtVVWVhZzdHRkwcHBrLa29oXpt0QiYfv27WOrVq1izc3NrKysjP3jH/9g//nPf5idnR1zdnZmXl5e7JtvvmGXL19mmZmZ7LvvvqMJQyKRSCSSjtLZAOyWra0tmzVrFhszZgz74YcfWGNjI6upqWEeHh7svffeY4sXL2YSiUQo/7e//Y1duHCB/fnPf2bff/89jTypTzk6OjJfX1/m7u7ObGxs2OPHj9mjR4+YUqlkVVVV7JtvvqFBIpFIJBLpeRiAJBKJRCKRSKQXUyIaAhKJRCKRSCQyAEkkEolEIpFIZACSSCQSiUQikX4u+j/QKQJNtf8sfgAAAABJRU5ErkJggg==');
			width: 360px;
			height: 40px;
			position: relative;
			top: 2px;
		}
		header{
			background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACwAAAAsCAIAAACR5s1WAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH4QcHCDAHcQp0xgAAAB1pVFh0Q29tbWVudAAAAAAAQ3JlYXRlZCB3aXRoIEdJTVBkLmUHAAAAHUlEQVRYw+3BAQ0AAADCoPdPbQ43oAAAAAAA4MsAFtwAAe7QDg8AAAAASUVORK5CYII=');
			height: 44px;
			width: 100%;
			margin-bottom: 2px;
		}
		a{
			color: #883ced;
		}
		a:hover{
			color: #af4cf0;
		}
		.btn.btn-primary{color:#ffffff!important;background-color:#883ced;background-repeat:repeat-x;background-image:-khtml-gradient(linear, left top, left bottom, from(#fd6ef7), to(#883ced));background-image:-moz-linear-gradient(top, #fd6ef7, #883ced);background-image:-ms-linear-gradient(top, #fd6ef7, #883ced);background-image:-webkit-gradient(linear, left top, left bottom, color-stop(0%, #fd6ef7), color-stop(100%, #883ced));background-image:-webkit-linear-gradient(top, #fd6ef7, #883ced);background-image:-o-linear-gradient(top, #fd6ef7, #883ced);background-image:linear-gradient(top, #fd6ef7, #883ced);filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#fd6ef7', endColorstr='#883ced', GradientType=0);text-shadow:0 -1px 0 rgba(0, 0, 0, 0.25);border-color:#883ced #883ced #003f81;border-color:rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.1) rgba(0, 0, 0, 0.25);}
		body { margin: 0px 0px 40px 0px; }
	</style>
</head>
<body>
	<header>
		<div class="container">
			<div id="logo"></div>
		</div>
	</header>
	<div class="container">
		<div class="row">
			<div class="col-md-4">
				<h3>Swarm Managers</h3>
				<p><? foreach( $managers as $manager ) {
						echo "$manager\n";
					}
					?></p>
			</div>
			<div class="col-md-4">
				<h3>Worker nodes</h3>
			</div>
		</div>
		<hr/>
		<footer>
			<p class="pull-right">Page rendered in {exec_time}s using {mem_usage}mb of memory.</p>
			<p>
				<a href="http://fuelphp.com">FuelPHP</a> is released under the MIT license.<br>
				<small>Version: <?php echo Fuel::VERSION; ?></small>
			</p>
		</footer>
	</div>
</body>
</html>
