<%
' //==========================================================================
' //
' // Copyright 1998-2009 by MetraTech Corporation
' // All rights reserved.
' //
' // THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' // NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' // example, but not limitation, MetraTech Corporation MAKES NO
' // REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' // PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' // DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' // COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
' //
' // Title to copyright in this software and any associated
' // documentation shall at all times remain with MetraTech Corporation,
' // and USER agrees to preserve the same.
' //
' //==========================================================================

Option Explicit

Response.Buffer = True
Response.Expires = 0

dim imageURL
imageURL = mom_GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/header/"

'On Error Resume Next
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp"                   -->
<!-- #INCLUDE VIRTUAL="/mdm/SecurityFramework.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdmIncludes.asp" -->

<html>
  <head>
  	<title>MetraTech Corp.</title>
    <link rel="STYLESHEET" type="text/css" href="<%=mom_GetDictionary("DEFAULT_LOCALIZED_PATH")%>/styles/styles.css">  

    <script src="../../../MDM/Common/Widgets/Calendar/date.js"></script>   	
  	<script>
  	//Set date format for clock
    var clockFormat = "<%=mom_GetDictionary("MOM_HEADER_CLOCK_DISPLAY_FORMAT")%>";
    if (clockFormat == "") { clockFormat = "MMM d, yyyy hh:mm:ss"; }
    
    var winHelp;
    // 'SECENG: Encoding added
    var strFlip = '<%=SafeForJS(UCase(Request.QueryString("Flip")))%>';
    function LogOut() {
        window.parent.location = "logout.asp?urlredirect=<%=Mid(request.ServerVariables("SCRIPT_NAME"), 1, instr(2, request.ServerVariables("SCRIPT_NAME"), "/") - 1)%>"
		}    
          
		function OpenHelp() {
			if (winHelp){
      
				if (!winHelp.closed) winHelp.close();
      }				
       // 'SECENG: Changed old help path to new help system CORE-4774 CLONE - MSOL BSS 27970 Unauthenticated Info Disclosure on /MOM/help.asp (post-pb)
      winHelp = window.open('<%=Session("mdm_LOCALIZATION_DICTIONARY").Item("APP_HTTP_PATH")%>/../MetraNetHelp/en-US/index.htm', 'HelpWindow', 'height=600,width=800, resizable=yes, scrollbars=yes, status=yes');
		}
      
      ///////////////////////////////////////////////////////////////////////////////////          	
  		function FullScreen() {

        if(strFlip == "TRUE")
        {
         strFlip = "FALSE"
        }
        else
        {
         strFlip = "TRUE"
        }

        parent.resizeIt();    
        window.location = "header.asp?Flip=" + strFlip;
  	  }
      
  	</script>	

  <SCRIPT language="JavaScript"><!--

function leadingZero(varInt)
{
  return (varInt < 10)? ( "0" + varInt ):(varInt)
}

function convertHours(hr)
{
  if (hr < 0 ) {hr = 24 - hr}
  if (hr > 24) {hr = hr%24  }
  return leadingZero(hr)
}

function convertStringsToTimeStamp(dateGMT,strGMT)
{
                          var yearGMT  = dateGMT.substr(0,4)
                          var monthGMT = dateGMT.substr(5,2)
                          var dayGMT   = dateGMT.substr(8,2)
                          var hrGMT    = strGMT.substr(0,2)
                          var minGMT   = strGMT.substr(3,2)
                          var secGMT   = strGMT.substr(6,2)

                      var gmtRef   = new Date(yearGMT,(monthGMT-1),dayGMT,hrGMT,minGMT,secGMT,0)
        return gmtRef.getTime()
}
function returnTimeFromTimeStamp (tsMs)
{
        var hlpDate = new Date()
            hlpDate.setTime(tsMs)
        var hr     = leadingZero ( hlpDate.getHours()  )
        var min    = leadingZero ( hlpDate.getMinutes())
        var sec    = leadingZero ( hlpDate.getSeconds())
 return hr + ":" + min + ":" + sec
}
function returnDateFromTimeStamp (tsMs)
{
        var hlpDate = new Date()
            hlpDate.setTime(tsMs)
        var year   = hlpDate.getFullYear()
        var month  = leadingZero ( hlpDate.getMonth() + 1)
        var day    = leadingZero ( hlpDate.getDate())
 return year + "-" + month + "-" + day
}

var updateCount=0;

function updateClock()
{
  //var time     = new Date()
  //var hrSof    = time.getHours()
  //hrSof    = leadingZero(hrSof)
  //var min      = leadingZero (time.getMinutes())
  //var sec      = leadingZero (time.getSeconds())

  if (document.hform.gmtOnOff.value == "On")
  {
    var GMTincms = convertStringsToTimeStamp(document.hform.gmtDateStr.value, document.hform.gmtTimeStr.value )+ 1000
  
    document.hform.gmtTimeStr.value = returnTimeFromTimeStamp(GMTincms);
    document.hform.gmtDateStr.value = returnDateFromTimeStamp(GMTincms)
  
    //document.all.MetraTime.innerText = document.hform.gmtDateStr.value + " " + document.hform.gmtTimeStr.value + " GMT";
    //document.all.MetraTime.title     = document.hform.gmtDateStr.value;
    
    var tempDate = new Date(GMTincms);
    document.all.MetraTime.innerText = formatDate(tempDate,clockFormat,true);
  }

   updateCount++;
   //Our javascript clock can get out of sync with the server, so every two hours
   //we'll check back in
   if (updateCount>(60*60*2))
   {
     window.location=window.location;
   }
   else
   {
    setTimeout("updateClock()", 1000);
   }
}


//--></SCRIPT>   
    <style type="text/css">
    <!--
    .gradBG {
    	background-color: #0066CC;
    	background-image: url(../localized/en-us/images/header/gradient.gif);
    	background-position: right;
    	background-repeat: repeat-y;
      color: white;
      font-size: 11px;
    	font-family: Arial Unicode MS, Lucida Sans Unicode, Tahoma, Verdana, Arial, Helvetica, sans-serif;
    }
    -->
    </style> 
  </head>

  <body style="margin:0" onLoad="updateClock();"> 
    <!-- Header Table -->
<%
    Function Pad(strValue)
      if len(strValue)=1 then
        Pad="0" & strValue
      else
        Pad=strValue
      end if
    End Function
    
    dim dtNow,sGMTTime,sGMTDate,objMetraTimeClient
    Set objMetraTimeClient = Server.CreateObject("MetraTech.MetraTimeClient")
    dtNow = objMetraTimeClient.GetMTOleTime()
    
    sGMTTime=Pad(DatePart("h",dtNow)) & ":" & Pad(DatePart("n",dtNow)) & ":" & Pad(DatePart("s",dtNow))
    sGMTDate=DatePart("yyyy", dtNow) & "-" & Pad(DatePart("m", dtNow)) & "-" & Pad(DatePart("d", dtNow)) '2002-12-06"
%>

<!-- Form to hold our time and date values between updates -->
<form name = 'hform'><INPUT TYPE='hidden' NAME='gmtOnOff' VALUE = On><INPUT TYPE='hidden' NAME='gmtDateStr' VALUE = <%=sGMTDate%>><INPUT TYPE='hidden' NAME='gmtTimeStr' VALUE = <%=sGMTTime%>></form>

  <div id="north">
 
    <a style="float: right; margin-right: 10px;" target="_top" href="/MetraNet">
      <img border="0" alt="MetraNet" src="/Res/Images/Header/MetraNet1Small.png" />
    </a>
    <span style="float: right; margin-right: 10px;">
       <span id='MetraTime' style="border: none; font-family: sans-serif; font-size: 11px; font-weight: 900; color: white; background: transparent;">&nbsp;</span>&nbsp;&nbsp;&nbsp;
      
      <%
      If UCase(Request.QueryString("Flip")) = "TRUE" Then
      %>
        <a href="JavaScript:FullScreen();"><img border="0" alt="<%=mom_GetDictionary("TEXT_FULLSCREEN")%>" src="<%=imageURL%>left_nav_on.gif" width="25" height="25"></a>
      <%
      Else
      %>
        <a href="JavaScript:FullScreen();"><img border="0" alt="<%=mom_GetDictionary("TEXT_FULLSCREEN")%>" src="<%=imageURL%>left_nav_off.gif" width="25" height="25"></a>
      <%
      End If
      %>             

      <img src="<%=imageURL%>spacer.gif" width="10" height="10">
      <a href="javascript:OpenHelp();"><img border="0" alt="<%=mom_GetDictionary("TEXT_HELP")%>" src="<%=imageURL%>help.gif" width="25" height="25"></a>
      <img src="<%=imageURL%>spacer.gif" width="10" height="10">
      <a href="JavaScript:LogOut();"><img border="0" alt="<%=mom_GetDictionary("TEXT_LOGOUT")%>" src="<%=imageURL%>exit.gif" width="25" height="25"></a>
      <img src="<%=imageURL%>spacer.gif" width="10" height="10">
    </span>    
    
    <div class="title">MetraControl
		  <span class="SmallText" style="padding-left:100px;">
              <%
              ' Set server description
              Dim objVersionInfo, serverDescription
              Set objVersionInfo= CreateObject("MetraTech.Statistics.VersionInfo")
              serverDescription = objVersionInfo.GetServerDescription("")
              response.write serverDescription
              If instr(1,UCase(serverDescription),"PRODUCTION") Then
              %>
                 <img src="<%=Session("LocalizedPath")%>images/Header/production.gif" width="10" height="10">
              <%
              End If
              %>

      </span>
    </div>
   <br />
   </div>

  </body>
</html>
