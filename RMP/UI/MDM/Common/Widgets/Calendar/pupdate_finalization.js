<html>
<head>
<script language="JavaScript">
 document.writeln("<div id=\"PopUpCalendar\" style=\"position:absolute; left:0px; top:0px; z-index:7; width:200px; height:104px; overflow: visible; visibility: hidden; background-color: #FFFFFF; border: 1px none #000000\" onMouseOver=\"if(ppcTI){clearTimeout(ppcTI);ppcTI=false;}\" onMouseOut=\"ppcTI=setTimeout(\'hideCalendar()\',500)\">");
 document.writeln("<div id=\"monthSelector\" style=\"position:absolute; left:0px; top:0px; z-index:9; width:181px; height:50px; overflow: visible; visibility:inherit\">");
</script>
<noscript><p><font color="#FF0000"><b>JavaScript is not activated !</b></font></p></noscript>

<table border="1" cellspacing="1" cellpadding="2" width="200" bordercolorlight="#000000" bordercolordark="#000000" vspace="0" hspace="0">
	<form name="ppcMonthList"><tr><td align="center" bgcolor="#DDDDDD">
		<a href="javascript:moveMonth('Back')" onMouseOver="window.status=' ';return true;">
			<font face="Arial, Helvetica, sans-serif" size="2" color="#000000">
				<b>< </b></font></a><font face="MS Sans Serif, sans-serif" size="1"> 

				<select name="sItem" onMouseOut="if(ppcIE){window.event.cancelBubble = true;}" onChange="switchMonth(this.options[this.selectedIndex].value)" style="font-family: 'MS Sans Serif', sans-serif; font-size: 9pt">
				<option value="0" selected>2000 • January</option>
				<option value="1">2000 • February</option>
				<option value="2">2000 • March</option>
				<option value="3">2000 • April</option>
				<option value="4">2000 • May</option>
				<option value="5">2000 • June</option>
				<option value="6">2000 • July</option>
				<option value="7">2000 • August</option>
				<option value="8">2000 • September</option>
				<option value="9">2000 • October</option>
				<option value="10">2000 • November</option>
				<option value="11">2000 • December</option>
				<option value="0">2001 • January</option>
				</select>
			</font><a href="javascript:moveMonth('Forward')" onMouseOver="window.status=' ';return true;">
			<font face="Arial, Helvetica, sans-serif" size="2" color="#000000">
			<b> ></b></font></a>
		</td></tr>
	</form>
</table>
<table border="1" cellspacing="1" cellpadding="2" bordercolorlight="#000000" bordercolordark="#000000" width="200" vspace="0" hspace="0">
<form name="ppcTimeStamp"><tr align="center" bgcolor="#DDDDDD">
<td>
	<input type="text" name="time_hour_form" value="12" size="2" style="align: center; font-family: 'MS Sans Serif', sans-serif; font-size: 9pt">
	<font face="Arial, Helvetica, sans-serif" size="2" color="#000000">:</font>
	<input type="text" name="time_minute_form" value="00" size="2" style="align: center; font-family: 'MS Sans Serif', sans-serif; font-size: 9pt">
	<font face="Arial, Helvetica, sans-serif" size="2" color="#000000">&nbsp;</font>
	<input type="text" name="time_period_form" value="AM" size="2" style="align: center; font-family: 'MS Sans Serif', sans-serif; font-size: 9pt">
</td>
</tr>
</form>
</table>


<table border="1" cellspacing="1" cellpadding="2" bordercolorlight="#000000" bordercolordark="#000000" width="200" vspace="0" hspace="0">
<tr align="center" bgcolor="#DDDDDD">
	<td width="20" bgcolor="#FFFFDD"><b><font face="MS Sans Serif, sans-serif" size="1">Su</font></b></td>
	<td width="20"><b><font face="MS Sans Serif, sans-serif" size="1">Mo</font></b></td>
	<td width="20"><b><font face="MS Sans Serif, sans-serif" size="1">Tu</font></b></td>
	<td width="20"><b><font face="MS Sans Serif, sans-serif" size="1">We</font></b></td>
	<td width="20"><b><font face="MS Sans Serif, sans-serif" size="1">Th</font></b></td>
	<td width="20"><b><font face="MS Sans Serif, sans-serif" size="1">Fr</font></b></td>
	<td width="20" bgcolor="#FFFFDD"><b><font face="MS Sans Serif, sans-serif" size="1">Sa</font></b></td>
</tr>
</table>

<script language="JavaScript">
 document.writeln("</div>");
 document.writeln("<div id=\"monthDays\" style=\"position:absolute; left:0px; top:80px; z-index:8; width:200px; height:17px; overflow: visible; visibility:inherit; background-color: #FFFFFF; border: 1px none #000000\"> </div></div>");}
</script>
</head>
<body>
</body>
</html>