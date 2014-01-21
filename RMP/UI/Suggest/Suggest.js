var mQueryField = null;

//
//This is the key handler function, for when a user presses the up arrow,
//down arrow, tab key, or enter key from the input field.
//
function keypressHandler (evt)
{
  if(mQueryField == null) return true;
    
  // don't do anything if the div is hidden
  var div = GetDiv("autocomplete_" + mQueryField.name);
  if (div.style.visibility == "hidden")
    return true;
  
  // make sure we have a valid event variable
  if(!evt && window.event) {
    evt = window.event;
  }
  var key = evt.keyCode;
  
  // if this key isn't one of the ones we care about, just return
  var KEYUP = 38;
  var KEYDOWN = 40;
  var KEYENTER = 13;
  var KEYTAB = 9;
  
  if ((key != KEYUP) && (key != KEYDOWN) && (key != KEYENTER) && (key != KEYTAB))
  {
    return true;
  }
  
  // get the div that's currently selected, and perform an appropriate action
  var selNum = getSelectedSpanNum(div);
  var selSpan = setSelectedSpan(div, selNum);
  
  if ((key == KEYENTER) || (key == KEYTAB)) {
    if (selSpan)
      _selectResult(selSpan);
    evt.cancelBubble=true;
    
   if(key == KEYENTER)
   {
     if(typeof DoFind != 'undefined')
       DoFind();
    }
    return false;
  } else {
    if (key == KEYUP)
      selSpan = setSelectedSpan(div, selNum - 1);
    if (key == KEYDOWN)
      selSpan = setSelectedSpan(div, selNum + 1);
    if (selSpan)
      _highlightResult(selSpan);
  }
  
  ShowDiv();
  mQueryField.focus();
  return true;
}

// This actually fills the field with the selected result and hides the div 
function _selectResult(item)
{
  //If the page has a custom handler defined for when the user selects an item, call it with the value selected
  if (typeof onSuggestUserSelectResult != 'undefined')
  {
    onSuggestUserSelectResult(item.innerHTML);
  }
  else
  {
    //Default behavior, set the selected value into the value field and give it focus
	mQueryField.value = item.innerHTML;
	mQueryField.focus();
  }
  HideDiv();
  return;
}

//
// Get the number of the result that's currently selected/highlighted
// (the first result is 0, the second is 1, etc.)
//
function getSelectedSpanNum (div)
{
  var count = -1;
  var spans = div.getElementsByTagName("div");
  if (spans) {
    for (var i = 0; i < spans.length; i++) {
      count++;
      if (spans[i].className != "clsSuggest")
        return count;
    }
  }
  
  return -1;
}


//
// Select/highlight the result at the given position
//
function setSelectedSpan(div, spanNum)
{
  var count = -1;
  var thisSpan;
  var spans = div.getElementsByTagName("div");
  if (spans) {
    for (var i = 0; i < spans.length; i++) {
      if (++count == spanNum) {
        _highlightResult(spans[i]);
        thisSpan = spans[i];
      } else {
        _unhighlightResult(spans[i]);
      }
    }
  }
  
  return thisSpan;
}

// This actually highlights the selected result 
function _highlightResult(item)
{
  item.className = "clsSuggestSelected";
}

// This actually unhighlights the selected result 
function _unhighlightResult(item)
{
  item.className = "clsSuggest";
}

var	req;
function Initialize()
{
	try
	{
		req=new	ActiveXObject("Msxml2.XMLHTTP");
	}
	catch(e)
	{
		try
		{
			req=new	ActiveXObject("Microsoft.XMLHTTP");
		}
		catch(oc)
		{
				req=null;
		}
	}

	if(!req&&typeof	XMLHttpRequest!="undefined")
	{
		req=new	XMLHttpRequest();
	}
}

function SendQuery(obj, method, params, serializedContext)
{
  mQueryField = obj;
  var keyword = obj.value  
  var evt = window.event;
  var key = evt.keyCode;
  
  var KEYUP = 38;
  var KEYDOWN = 40;
  var KEYENTER = 13;
  var KEYTAB = 9;
  
  // if ((key != KEYUP) && (key != KEYDOWN) && (key != KEYENTER) && (key != KEYTAB)) // Search every key
  if (key == KEYTAB)                                                                 // Search only on tab
  {
    SendQueryClick(obj, method, params, serializedContext);
  }
}

function SendQueryClick(obj, method, params, serializedContext)
{
  mQueryField = obj;
  var keyword = obj.value  
  Initialize();
  var url = "/Suggest/Suggest.aspx";
  var parameters = "Field=" + obj.name + "&Keyword=" + keyword + "&Method=" + method + "&Parameters=" + encodeURIComponent(params) + "&SerializedContext=" + encodeURIComponent(serializedContext);

  // make the call back to the server
  if(req!=null)
  {
      ShowLoading();
      
      req.onreadystatechange = Process;

      // req.open("GET", url, true);
      // Use POST in case the serialized context is too long and does not fit in the QueryString
      req.open("POST", url, true);
      req.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
      req.setRequestHeader("Content-length", parameters.length);
      req.setRequestHeader("Connection", "close");
      req.send(parameters);
      //req.send(null);
  }
}

function Process()
{
    if (req.readyState == 4)
        {
            HideLoading();
            // only if "OK"
            if (req.status == 200)
            {
                if(req.responseText=="")
                    HideDiv();
                else
                {
                    ShowDiv();
                }
            }
            else
            {
                document.getElementById("autocomplete_" + mQueryField.name).innerHTML = "There was a problem retrieving data:<br>" + req.statusText;
            }
        }
}
function HideLoading()
{
  document.getElementById("autocomplete_" + mQueryField.name).innerHTML = req.responseText;
  document.getElementById("suggestLoading_" + mQueryField.name).style.display = "none";
 // setSelectedSpan(GetDiv("autocomplete_" + mQueryField.name), 0);
}
function ShowLoading()
{
  document.getElementById("suggestLoading_" + mQueryField.name).style.display = "inline";
  setTimeout('document.images["suggestLoading_" + mQueryField.name].src = "/Suggest/Suggest.gif"', 10); // work around for IE bug that doesn't animate gif after it has been hidden
}

function GetDiv(divid)
{
   var d;
   if (document.layers) d = document.layers[divid];
   else d = document.getElementById(divid);
   return d;
}

function ShowDiv()
{
   if (document.layers)
     document.layers["autocomplete_" + mQueryField.name].visibility = "show";
   else 
     document.getElementById("autocomplete_" + mQueryField.name).style.visibility = "visible";

   adjustiFrame(true);
}

function HideDiv()
{
   if (document.layers) 
     document.layers["autocomplete_" + mQueryField.name].visibility = "hide";
   else 
     document.getElementById("autocomplete_" + mQueryField.name).style.visibility = "hidden";

   adjustiFrame(false);  
}

/**
Use an "iFrame shim" to deal with problems where the lookup div shows up behind
selection list elements, if they're below the queryField. The problem and solution are
described at:

http://dotnetjunkies.com/WebLog/jking/archive/2003/07/21/488.aspx
http://dotnetjunkies.com/WebLog/jking/archive/2003/10/30/2975.aspx
*/
function adjustiFrame(state)
{
   var DivRef = document.getElementById("autocomplete_" + mQueryField.name);
   var IfrRef = document.getElementById("DivShim_" + mQueryField.name);
   if(state)
   {
    DivRef.style.display = "block";
    IfrRef.style.width = DivRef.offsetWidth;
    IfrRef.style.height = DivRef.offsetHeight;
    IfrRef.style.top = DivRef.style.top;
    IfrRef.style.left = DivRef.style.left;
    IfrRef.style.zIndex = DivRef.style.zIndex;
    DivRef.style.zIndex++;
    IfrRef.style.filter='progid:DXImageTransform.Microsoft.Alpha(style=0,opacity=0)';
    IfrRef.style.display = "block";
   }
   else
   {
    DivRef.style.display = "none";
    IfrRef.style.width = "0px";
    IfrRef.style.height = "0px";
    IfrRef.style.display = "none";
   }
}
function MakeTopZ(){
  var allElems = document.getElementsByTagName?
                  document.getElementsByTagName("*"):
                  document.all; // or test for that too
  var maxZIndex = 0;
  for(var i=0;i<allElems.length;i++) {
    var elem = allElems[i];
    var cStyle = null;
    if (elem.currentStyle) {cStyle = elem.currentStyle;}
    else if (document.defaultView && document.defaultView.getComputedStyle) {
      cStyle = document.defaultView.getComputedStyle(elem,"");
    }
    var sNum;
    if (cStyle) {
      sNum = Number(cStyle.zIndex);
    } else {
      sNum = Number(elem.style.zIndex);
    }
    if (!isNaN(sNum)) {  
      maxZIndex = Math.max(maxZIndex,sNum);
    }
  } 
  return maxZIndex;
}

function SuggestLoad()
{
    document.onkeydown = keypressHandler;
}


document.onmousemove = getMouseXY;

var tempX = 0;
var tempY = 0;
var suggestX = 0;
var suggestY = 0;

function getMouseXY(e) {
  tempX = event.clientX + document.body.scrollLeft;
  tempY = event.clientY + document.body.scrollTop;
  
  if(mQueryField)
  {
    suggestX = findPosX(document.getElementById("autocomplete_" + mQueryField.name));
    suggestY = findPosY(document.getElementById("autocomplete_" + mQueryField.name));
  
    if((tempX > suggestX + 210) || (tempY > suggestY + 210) || (tempX < suggestX - 210) || (tempY < suggestY - 210))
      HideDiv();
  }
  return true;
}
function findPosX(obj)
{
	var curleft = 0;
	if (obj.offsetParent)
	{
		while (obj.offsetParent)
		{
			curleft += obj.offsetLeft;
			obj = obj.offsetParent;
		}
	}
	else if (obj.x)
		curleft += obj.x;
	return curleft;
}

function findPosY(obj)
{
	var curtop = 0;
	if (obj.offsetParent)
	{
		while (obj.offsetParent)
		{
			curtop += obj.offsetTop;
			obj = obj.offsetParent;
		}
	}
	else if (obj.y)
		curtop += obj.y;
	return curtop;
}