/* PopUp Calendar v2.1
© PCI, Inc.,2000 • Freeware
webmaster@personal-connections.com
+1 (925) 955 1624
Permission granted  for unlimited use so far
as the copyright notice above remains intact. */

/* Settings. Please read readme.html file for instructions*/
//var ppcDF = "d.M.yyyy* HH:mm:ssaa"

//var ppc24Clock = false;

//var ppcDF = "d.m.Y";
//var ppc24Clock = true;

var ppcMN = new Array("January","February","March","April","May","June","July","August","September","October","November","December");
var ppcWN = new Array("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday");
var ppcER = new Array(4);
ppcER[0] = "Required DHTML functions are not supported in this browser.";
ppcER[1] = "Target form field is not assigned or not accessible.";
ppcER[2] = "Sorry, the chosen date is not acceptable. Please read instructions on the page.";
ppcER[3] = "Unknown error occurred while executing this script.";
var ppcUC = false;
var ppcUX = 4;
var ppcUY = 4;

/* Do not edit below this line unless you are sure what are you doing! */
var ppcIE = (navigator.appName == "Microsoft Internet Explorer" || (navigator.appName == "Netscape" && Object.hasOwnProperty.call(window, "ActiveXObject") && !window.ActiveXObject)); // In IE 11, navigator.appName is set to "Netscape", so need to use feature detection to check if is IE
var ppcNN=((navigator.appName == "Netscape")&&(document.layers));
var is_chrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1;
var ppcTT="<table width=\"200\" cellspacing=\"1\" cellpadding=\"2\" border=\"1\" bordercolorlight=\"#000000\" bordercolordark=\"#000000\">\n";
var ppcCD=ppcTT;var ppcFT="<font face=\"MS Sans Serif, sans-serif\" size=\"1\" color=\"#000000\">";var ppcFC=true;
var ppcTI=false;var ppcSV=null;var ppcRL=null;var ppcXC=null;var ppcYC=null;
var ppcML=new Array(31,28,31,30,31,30,31,31,30,31,30,31);
var ppcWE=new Array("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday");
var ppcNow=new Date();var ppcPtr=new Date();
var ppcCurrentMonthDropDownMax= 24;

if (ppcNN) {
 window.captureEvents(Event.RESIZE);
 window.onresize = restoreLayers;
 document.captureEvents(Event.MOUSEDOWN|Event.MOUSEUP);
 document.onmousedown = recordXY;
 document.onmouseup = confirmXY;}
function restoreLayers(e) {
 if (ppcNN) {
  with (window.document) {
   open("text/html");
   write("<html><head><title>Restoring the layer structure...</title></head>");
   write("<body bgcolor=\"#FFFFFF\" onLoad=\"history.go(-1)\">");
   write("</body></html>");
   close();}}}
function recordXY(e) {
 if (ppcNN) {
  ppcXC = e.x;
  ppcYC = e.y;
  document.routeEvent(e);}}
function confirmXY(e) {
 if (ppcNN) {
  ppcXC = (ppcXC == e.x) ? e.x : null;
  ppcYC = (ppcYC == e.y) ? e.y : null;
  document.routeEvent(e);}}
	
function getCalendarForTimeOpt(target,rules, boolshowtime)
{
	showCalendarTimeBlock(boolshowtime);
  
  setCalendarValueBasedOnTarget(target);
  
	return getCalendarFor(target,rules);
}	

function getCalendarForEndDate(target,rules)
{
  showCalendarTimeBlock(true);
  
  setCalendarValueBasedOnTarget(target);   
  
  //If the original (target) value is blank, then seed the end time
  if (target.value.length==0)
  {
    if (ppc24Clock)
    {
      setTimeForCalendarTimeBlock("23","59","59","");
    }
    else
    {
      setTimeForCalendarTimeBlock("11","59","59","PM");
    }
  }
  
	return getCalendarFor(target,rules);
}	

function getCalendarForStartDate(target,rules)
{
  showCalendarTimeBlock(true);
  
  setCalendarValueBasedOnTarget(target);
  
  //If the original (target) value is blank, then seed the start time
  if (target.value.length==0)
  {
    if (ppc24Clock)
    {
      setTimeForCalendarTimeBlock("00","00","00","");
    }
    else
    {
      setTimeForCalendarTimeBlock("12","00","00","AM");
    }
  }
  
	return getCalendarFor(target,rules);
}	

function setTimeForCalendarTimeBlock(hours,minutes,seconds,period)
{
  document.all.time_hour_form.value = hours;
  document.all.time_minute_form.value = minutes;
  document.all.time_second_form.value = seconds;
  document.all.time_period_form.value = period;
  
  if (period=="AM")
  {
    document.all.time_period_form.options[0].selected =true;
  }
  else
  {
    document.all.time_period_form.options[1].selected =true;
  }
  
  return true;
}

function showCalendarTimeBlock(boolshowtime)
{
	document.ppcTimeStamp.showTime.value = boolshowtime;
	document.ppcTimeStamp.time_hour_form.disabled = !boolshowtime;
	document.ppcTimeStamp.time_minute_form.disabled = !boolshowtime;
	document.ppcTimeStamp.time_second_form.disabled = !boolshowtime;
	document.ppcTimeStamp.time_period_form.disabled = !boolshowtime;
	
	if (boolshowtime)
	{
		document.getElementById("time_choice").style.display = "block";
    document.getElementById("monthDays").style.top = "80px";
		//document.getElementById("no_time_choice").style.display = "none";
	}
	else
	{
		//document.getElementById("no_time_choice").style.display = "block";
		document.getElementById("time_choice").style.display = "none"
    document.getElementById("monthDays").style.top = "51px";
	}

  return true;
}

function getPaddedString(iValue)
{
  return (iValue<10) ? "0"+iValue : "" + iValue;
}

//Encapsulates getting current date
function getCurrentDate()
{
  return new Date();
}

function setCalendarValueBasedOnTarget(target)
{
  var dtTemp;
  var dtParseResult = 0;
  if ((target.value!=null)&&(target.value.length!=0))
  {
    //window.alert("in[" + target.value + "]");
    //window.alert(target.value);
    //dtParseResult = getDateFromFormat("02/28/2002 12:00:00 AM", "M/d/yyyy hh:mm:ss a");
    //dtParseResult = getDateFromFormat(target.value, "M/d/yyyy h:m:s a");
    dtParseResult = getDateFromFormat(target.value, ppcDF);
    
    //if (dtParseResult==0) 
    //  dtParseResult = getDateFromFormat(target.value, "d.M.yyyy* H:m:saa");
    
    if (dtParseResult==0)
    {
       window.alert("Unable to parse current date value [" + target.value + "]" );
       ppcNow = new Date();
    }
    else
    { 
      ppcNow = new Date(dtParseResult);
      //window.alert("parse result[" + ppcNow.toLocaleString() + "] from [" + target.value + "]");
    }
   }
   else
   {
    ppcNow = getCurrentDate();
    //window.alert("date now is [" + ppcNow + "] getUTCDate[" + ppcNow.getUTCDate() + "]");
   }
   
   var hours = ppcNow.getUTCHours();
   var period = "";
   
   if (!ppc24Clock)
   {
    if (hours>12)
    {
      hours-=12;
      period="PM";
    }
    else
    {
      period="AM";
      if (hours==0)
        hours=12;
      else if (hours==12) period="PM"
    }
   }
   
    setTimeForCalendarTimeBlock(hours,getPaddedString(ppcNow.getUTCMinutes()),getPaddedString(ppcNow.getUTCSeconds()),period);
   
   ppcFC = true;
   
   return true;
}

function getCalendarFor(target,rules)
{
 var calendarSizeX;
 var calendarSizeY;
 
 calendarSizeX = 210;
 calendarSizeY = 190;
   
 ppcSV = target;
 ppcRL = rules;
 if (ppcFC) {setCalendar();ppcFC = false;}
 if ((ppcSV != null)&&(ppcSV))
 {
   if (ppc24Clock)
   {
    document.ppcTimeStamp.time_period_form.disabled = true;
    document.ppcTimeStamp.time_period_form.style.display = 'none';
   }

   
   var obj = document.all['PopUpCalendar'];
   var obj2 = document.all['monthSelector'];

   
	 // Calendar starts at mouse click position
	 obj.style.left = document.body.scrollLeft + parseInt(event.clientX); 
	 obj.style.top = document.body.scrollTop + parseInt(event.clientY) ;
   
   // #FRED - Due to conflict between the MDM PVB Refresh Icon and the Calendard position at init time, we moved the initial position of the calendar
   // in the pos left:-500px, and on the fly we restore the position.
   // Kevin Fred 2/28/2003
   obj2.style.left = "0px";
      
	 // If it goes over the end of the screen - then move it back
	 if((parseInt(event.clientX) + calendarSizeX) >= document.body.clientWidth){
	     obj.style.left = document.body.scrollLeft + document.body.clientWidth - calendarSizeX;
	 }
	 if((parseInt(event.clientY) + calendarSizeY) >= document.body.clientHeight){
	     obj.style.top = document.body.scrollTop + document.body.clientHeight - calendarSizeY;
	  }
	   if (ppcIE || is_chrome)
	 {
 	   // set Calendar visible 
		   obj.style.visibility = "visible";
       adjustiFrame(true);
   }
	 else if(ppcNN )	
   { obj.visibility = "show";}
	 
 else {showError(ppcER[0]);}}
 else {showError(ppcER[1]);}

 
 }

function switchMonth(param) {
 var tmp = param.split("|");
 setCalendar(tmp[0],tmp[1]);}

////////////////////////////////////////////////////////////////////////////////// 
function moveMonth(dir) {
 var obj = null;
 var limit = false;
 var tmp,dptrYear,dptrMonth;
 
 if (ppcIE|| is_chrome) {
   obj = document.ppcMonthList.sItem;
 }
 else if (ppcNN ) {
   obj = document.layers['PopUpCalendar'].document.layers['monthSelector'].document.ppcMonthList.sItem;
 }
 else {
   showError(ppcER[0]);
 }
 
 if (obj != null)
 {
   if ((dir.toLowerCase() == "back")&&(obj.selectedIndex > 0))
   {
     obj.selectedIndex--;
   }
   else
     if (dir.toLowerCase() == "forward")
     {
       if (obj.selectedIndex < ppcCurrentMonthDropDownMax)
       {
         //alert("index will be[" + (obj.selectedIndex+1) + "]");
         obj.selectedIndex++;
       }
       else
       {
           tmp = obj.options[obj.selectedIndex].value.split("|");
           var year  = tmp[0];
           var month = tmp[1];
           
           var iPreviousMaxItem = ppcCurrentMonthDropDownMax;

           // Add 2 years of data in dropdown
           i=1;
           while (i <= 24)
           {
            month++;
            if (month >= 12)
            {
              year++;
              month = 0;
            }
            
            //alert('About to add month[' + month + '][' + ppcMN[month]+ '] year [' + year + ']');
            obj.options[iPreviousMaxItem+i] = new Option();
            obj.options[iPreviousMaxItem+i].value = (year) + "|" + month;
            obj.options[iPreviousMaxItem+i].text  = (year) + " - " + ppcMN[month];
            //if(i==12)
            //{
            //  obj.options[i].selected = true;
            //}
            i++;
          }
          obj.options[iPreviousMaxItem+1].selected = true;
          ppcCurrentMonthDropDownMax= iPreviousMaxItem+i-1;
       }
     }
     else
     {
       limit = true;
     }
 }

 if (!limit) {
  tmp = obj.options[obj.selectedIndex].value.split("|");
  dptrYear  = tmp[0];
  dptrMonth = tmp[1];
  setCalendar(dptrYear,dptrMonth);}
 else {

   if (ppcIE) {
     obj.style.backgroundColor = "#FF0000";
     window.setTimeout("document.ppcMonthList.sItem.style.backgroundColor = '#FFFFFF'",50);
   }
 }
}

function selectDate(param) {
 var arr   = param.split("|");
 var year  = arr[0];
 var month = arr[1];
 var date  = arr[2];
 var ptr = parseInt(date);
 ppcPtr.setDate(ptr);
 if ((ppcSV != null) && (ppcSV)) {
 if ((document.ppcTimeStamp.showTime.value == "false") || (validDate(date)))
 {
  ppcSV.value = dateFormat(year,month,date);
  //See if we should call the onCalendarSelect callback event
  //window.alert("ppcSV[" + ppcSV + "]");
  if (ppcSV.onCalendarSelect!=null)
  {
    eval(ppcSV.onCalendarSelect);
  }
  
  hideCalendar();
 }
  else {showError(ppcER[2]);if (ppcTI) {clearTimeout(ppcTI);ppcTI = false;}}}
 else {
  showError(ppcER[1]);
  hideCalendar();}}

function setCalendar(year,month) {

 if (year  == null) {year = getFullYear(ppcNow);}
 if (month == null) {month = ppcNow.getUTCMonth();setSelectList(year,month);}
 if (month == 1) {ppcML[1]  = (isLeap(year)) ? 29 : 28;}
 ppcPtr.setUTCFullYear(year);
 ppcPtr.setUTCMonth(month);
 ppcPtr.setUTCDate(1);
 updateContent();}

function updateContent() {
 //window.alert("updateContent");
 generateContent();
 if (ppcIE || is_chrome) {document.all['monthDays'].innerHTML = ppcCD;}
 else if (ppcNN ) {
  with (document.layers['PopUpCalendar'].document.layers['monthDays'].document) {
   open("text/html");
   write("<html>\n<head>\n<title>DynDoc</title>\n</head>\n<body bgcolor=\"#FFFFFF\">\n");
   write(ppcCD);
   write("</body>\n</html>");
   close();}}
 else {showError(ppcER[0]);}
 ppcCD = ppcTT;}

function generateContent() {
 //window.alert("generateContent");
 var year  = getFullYear(ppcPtr);
 var month = ppcPtr.getUTCMonth();
 var date  = 1;
 var day   = ppcPtr.getUTCDay();
 var len   = ppcML[month];
 var bgr,cnt,tmp = "";
 var j,i = 0;
 for (j = 0; j < 7; ++j) {
  if (date > len) {break;}
  for (i = 0; i < 7; ++i) {
   bgr = ((i == 0)||(i == 6)) ? "#C1CBD7" : "#CFDBE5";
   if (((j == 0)&&(i < day))||(date > len)) {tmp  += makeCell(bgr,year,month,0);}
   else {tmp  += makeCell(bgr,year,month,date);++date;}}
  ppcCD += "<tr align=\"center\">\n" + tmp + "</tr>\n";tmp = "";}
 ppcCD += "</table>\n";}

function makeCell(bgr,year,month,date) {
 var param = "\'"+year+"|"+month+"|"+date+"\'";
 var td1 = "<td width=\"20\" bgcolor=\""+bgr+"\" ";
 var td2 = (ppcIE) ? "</font></span></td>\n" : "</font></a></td>\n";
 var evt = "onMouseOver=\"this.style.backgroundColor=\'#688ABA\'\" onMouseOut=\"this.style.backgroundColor=\'"+bgr+"\'\" onMouseUp=\"selectDate("+param+")\" ";
 var ext = "<span Style=\"cursor: hand\">";
 var lck = "<span Style=\"cursor: default\">";
 var lnk = "<a href=\"javascript:selectDate("+param+")\" onMouseOver=\"window.status=\' \';return true;\">";
 var cellValue = (date != 0) ? date+"" : "&nbsp;";
 if ((ppcNow.getUTCDate() == date)&&(ppcNow.getUTCMonth() == month)&&(getFullYear(ppcNow) == year))
 {
  //Formatting for the initial value
  cellValue = "<b>"+cellValue+"</b>";
 }
 var cellCode = "";
 if (date == 0) {
  if (ppcIE) {cellCode = td1+"Style=\"cursor: default\">"+lck+ppcFT+cellValue+td2;}
  else {cellCode = td1+">"+ppcFT+cellValue+td2;}}
 else {
  if (ppcIE) {cellCode = td1+evt+"Style=\"cursor: hand\">"+ext+ppcFT+cellValue+td2;}
  else {
   if (date < 10) {cellValue = "&nbsp;" + cellValue + "&nbsp;";}
   cellCode = td1+">"+lnk+ppcFT+cellValue+td2;}}
 return cellCode;}

function setSelectList(year,month) {
 var i = 0;
 var obj = null;

 if (ppcIE || is_chrome) {
   obj = document.ppcMonthList.sItem;
 }
 else if (ppcNN) {
   obj = document.layers['PopUpCalendar'].document.layers['monthSelector'].document.ppcMonthList.sItem;
 }
 else {
/* NOP */
 }
 
 // Set 2 years of data in dropdown
 while (i < 241)
 {
  obj.options[i] = new Option();
  obj.options[i].value = (year -10) + "|" + month;
  obj.options[i].text  = (year -10) + " - " + ppcMN[month];
  if(i==120)
  {
    obj.options[i].selected = true;
  }
  i++;
  month++;
  if (month == 12)
  {
    year++;
    month = 0;
  }
 }
}

function hideCalendar()
{
 if (ppcIE || is_chrome) {document.all['PopUpCalendar'].style.visibility = "hidden";}
 else if (ppcNN) {document.layers['PopUpCalendar'].visibility = "hide";window.status = " ";}
 else {/* NOP */}
 ppcTI = false;
 setCalendar();
 ppcSV = null;
 if (ppcIE || is_chrome) { var obj = document.ppcMonthList.sItem; }
 else if (ppcNN) {var obj = document.layers['PopUpCalendar'].document.layers['monthSelector'].document.ppcMonthList.sItem;}
 else {/* NOP */}
 obj.selectedIndex = 0;
 adjustiFrame(false);
}

function showError(message) {
 window.alert("[ PopUp Calendar ]\n\n" + message);}

function isLeap(year) {
 if ((year%400==0)||((year%4==0)&&(year%100!=0))) {return true;}
 else {return false;}}

function getFullYear(obj) {
 if (ppcNN) {return obj.getUTCYear() + 1900;}
 else {return obj.getUTCFullYear();}}

function validDate(date) {
 var reply = true;
 if (ppcRL == null) {/* NOP */}
 else {
  var arr = ppcRL.split(":");
  var mode = arr[0];
  var arg  = arr[1];
  var key  = arr[2].charAt(0).toLowerCase();
  if (key != "d") {
   var day = ppcPtr.getDay();
   var orn = isEvenOrOdd(date);
   reply = (mode == "[^]") ? !((day == arg)&&((orn == key)||(key == "a"))) : ((day == arg)&&((orn == key)||(key == "a")));}
  else {reply = (mode == "[^]") ? (date != arg) : (date == arg);}}
 return reply;}

function isEvenOrOdd(date) {
 if (date - 21 > 0) {return "e";}
 else if (date - 14 > 0) {return "o";}
 else if (date - 7 > 0) {return "e";}
 else {return "o";}}

function dateFormat(year,month,date)
{
  if (ppcDF == null) {ppcDF = "m/d/Y";}
  
  var date; 
  var includeTime;
  
  if(document.ppcTimeStamp.showTime.value == "true")
  {
    includeTime = true;
  }
  else
  {
    includeTime= false;
  }
   
  if(includeTime)
  {
    var hours = parseInt(document.all.time_hour_form.value);
    if (!ppc24Clock)
    {
      if (document.all.time_period_form.value == "PM")
      {
        hours += 12;
        if (hours==24)
        {
          hours=0;
        }
      }
      else
      {
        if (hours==12)
        {
          hours=0;
        }  
      }
    }
    date = new Date(year,month,date,hours,document.all.time_minute_form.value,document.all.time_second_form.value);
  }
  else
  {
    date = new Date(year,month,date,0,0,0);
  }
  
  var temp=formatDate(date,ppcDF, includeTime);
  
  return temp;
}

function old____dateFormat(year,month,date)
{
 if (ppcDF == null) {ppcDF = "m/d/Y";}
 var day = ppcPtr.getDay();
 var crt = "";
 var str = "";
 var timestamp = "";
 var chars = ppcDF.length;
 for (var i = 0; i < chars; ++i)
 {
  crt = ppcDF.charAt(i);
  switch (crt) 
  {
  	case "M": str += ppcMN[month]; break;
  	case "m": str += (month<9) ? ("0"+(++month)) : ++month; break;
  	case "Y": str += year; break;
  	case "y": str += year.substring(2); break;
  	case "d": str += ((ppcDF.indexOf("m")!=-1)&&(date<10)) ? ("0"+date) : date; break;
  	case "W": str += ppcWN[day]; break;
    default: str += crt;
  }
 }
 
 if (document.ppcTimeStamp.showTime.value == "true")
 {
  timestamp = document.all.time_hour_form.value + ":" + document.all.time_minute_form.value + ":" + document.all.time_second_form.value;
  if (!ppc24Clock)
     timestamp += " " + document.all.time_period_form.value;
 	//timestamp = ppcTimeStamp.time_hour_form.value + ":" + ppcTimeStamp.time_minute_form.value + ":" + ppcTimeStamp.time_second_form.value + " " + ppcTimeStamp.time_period_form.value;
 	//timestamp = ppcTimeStamp.time_hour_form.value + ":" + ppcTimeStamp.time_minute_form.value + " " + ppcTimeStamp.time_period_form.value;
 	str += " ";
 	str += timestamp;
 }
 
 return unescape(str);
}

function setEndDateTimeAndShowCalendar(target, rules) {

  showCalendarTimeBlock(true);
  setCalendarValueBasedOnTarget(target);

  //if the enddate is empty or if only date part is entered
  if (target.value.length==0 || isTimePortionEmpty(target))
  {
         //If the original (target) value is blank, then seed the end time
    if (ppc24Clock)
    {
      setTimeForCalendarTimeBlock("23","59","59","");
    }
    else
    {
      setTimeForCalendarTimeBlock("11","59","59","PM");
    }
  }
  getCalendarFor(target,rules);
}

function isTimePortionEmpty(target) {
    if ((target.value != null) && (target.value.length != 0)) {
    dtParseResult = getDateFromFormat(target.value, ppcDF);

    if (dtParseResult == 0) {
      ppcNow = new Date();
    }
    else {
      ppcNow = new Date(dtParseResult);
    }
  }
  else {
    ppcNow = getCurrentDate();
  }

  var hours = ppcNow.getUTCHours();
  var minutes = ppcNow.getUTCMinutes();
  var seconds = ppcNow.getUTCSeconds();
  return (hours == 0 && minutes == 0 && seconds == 0);
}
