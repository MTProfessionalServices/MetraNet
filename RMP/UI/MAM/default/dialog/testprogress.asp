<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<html>
<head>
<LINK rel="STYLESHEET" type="text/css" href="/mam/default/localized/en-us/styles/Styles.css">
<script language="JavaScript">
	var intIncrement=0;
  var strCaption = "";
  var n = 1;
  var bDone = false;

	function initialize(){
	 	document.all.ProgressBar.style.width = "1px";
		document.all.ProgressDiv.style.display  = "none";
    document.all.ProgressDiv.style.left = document.body.clientWidth / 2 - 150;
    document.all.ProgressDiv.style.top =  document.body.clientHeight / 2 - 100;
		intIncrement=0;	
    bDone = false;
	}
  
  function setProgress(intPos, intMax){
		// Number of pixels to increment progress bar for each record
    intIncrement = intIncrement + (1 / intMax) * (200);	

    // Ses progress caption 
		if(strCaption != "") {
  		document.all.ProgressBarCaption.innerText = strCaption;
		}
		else{
	    document.all.ProgressBarCaption.innerText = "Progress: " + intPos + " of " + intMax;
		}
		
		// Move progress and make visible
  	document.all.ProgressBar.style.width = intIncrement + "px";
    document.all.ProgressDiv.style.display  = "inline";

		// Set to 100% if at end or gone to far
		if(intPos >= intMax){
		  	document.all.ProgressBar.style.width = 200 + "px";
        bDone = true;
		}
	}
  
  // Show progress with a custom delay
  function setProgressSlow(intPos, intMax) {
   nDelay=100;
   var slowItDown = setTimeout("setProgress("+ intPos + "," + intMax+")", nDelay * n)
   n++;
  }

  // Where are we going next?
  function setRouteTo(strRouteTo) {
    var routeTo = setTimeout("goTo('" + strRouteTo + "')", 100)
  }
  
  // Make sure we are done loading before we go...
  function goTo(strRouteTo){
    if(bDone) {
      document.location.href = strRouteTo;
    }
    else {
      var routeTo = setTimeout("goTo('" + strRouteTo + "')", 100)    
    }
  }
  
  // Force the Progress Bar to be done
  function setDone(){
		document.all.ProgressDiv.style.display  = "none";  
    bDone = true;
  }

</script>
</head>
<body>
<div id="ProgressDiv" class="clsProgressDiv">
  <span id="ProgressBarCaption"></span>
  <div nowrap class="clsProgressBar">
    <img src="/mam/default/localized/en-us/images/progress/progressleft.gif"><img id="ProgressBar" height="13px;" width="1px;" src="/mam/default/localized/en-us/images/progress/progress.gif"><img src="/mam/default/localized/en-us/images/progress/progressright.gif">
  </div>
</div>
</body>
</html>
<script language="JavaScript">initialize();</script>
<%
dim o
dim i
set o = server.createobject("MTHTML.Progress")

for i = 1 to 100
  o.SetProgress CLng(i), CLng(100)
next
%>