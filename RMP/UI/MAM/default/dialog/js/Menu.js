///////////////////////////////////////////////////////////////////////////////////
// Menu.js --  Routines for handling the tree menu                               //
///////////////////////////////////////////////////////////////////////////////////

var MAX_SIZE_TO_AUTO_OPEN = 100;

var g_strBaseImagePath = "images/"
    
//Create and load XSL
var objXSL = new ActiveXObject("MSXML2.DOMDocument.3.0");
objXSL.async = false;
objXSL.validateOnParse = false;
objXSL.resolveExternals = false;

objXSL.load("/mam/default/dialog/hierarchyGetXSL.asp");
//objXSL.load("/mam/default/dialog/hierarchy.xsl");
checkParseError(objXSL, 'Unable to load XSL!');
    
var objXML = new ActiveXObject("MSXML2.DOMDocument.3.0");
objXML.async = false;
objXML.validateOnParse = false;
objXML.resolveExternals = false; 
    

var nCounter = 0;
var strHTML;
var objNode;
//var objInsert;
var objList;
var nLength;
//var strURL;    
var bStopSync = false;
var nLastHighlighted = "0";

var arrLengths;
var arrCounters;
var arrInserts;
var arrURLs;

///////////////////////////////////////////////////////////////////////////////////
function LoadHierarchy()
{
  //Load unconnected service endpoints
  
  //Load hierarchy
  LoadID('1');
  

}
///////////////////////////////////////////////////////////////////////////////////
function LoadID(strID) {
  if(!window.event.ctrlKey){
    var strChild;
    var i = 0;
    
    var arrIDs = strID.split(',');

//    alert(arrIDs.length);    

    //Create arrays of our check variables
    arrCounters = new Array(arrIDs.length);
    arrLengths = new Array(arrIDs.length);
    arrInserts = new Array(arrIDs.length);
    arrURLs = new Array(arrIDs.length);
    

    if(nCounter != 0){
      alert("Still loading... [Completed " + nCounter + " of " + nLength + "]");
      return;
    }

    
    //Populate objects and load
    for(i = 0; i < arrIDs.length; i++)
    {
      arrURLs[i] = '/mam/default/dialog/hierarchySnippet.asp?action=Load&id=' + arrIDs[i];
      
      strChild = 'cellChildren' + arrIDs[i];
      
      arrInserts[i] = document.all(strChild);
      arrInserts[i].innerHTML = "<div style='color:navy;'>&nbsp;&nbsp;&nbsp;Loading...</div>";
      
      eval('setTimeout("loading(' + i + ', ' + strID + ')", 1);');      
    }
        

//    strURL = '/mam/default/dialog/hierarchySnippet.asp?action=Load&id=' + strID;

//    strChild = 'cellChildren' + strID;
//    objInsert = document.all(strChild);
        
//    objInsert.innerHTML = "<div style='color:navy;'>&nbsp;&nbsp;&nbsp;Loading...</div>";
    
//    eval('setTimeout("loading(' + strID + ')", 1);');
//    eval('setTimeout("loading(' + strID + ')", 1);');
  }
}

///////////////////////////////////////////////////////////////////////////////////
function HideID(strID) {
  if(strID == "1")
    return;
    
  if(eval("document.all.imageConnector" + strID + ".src").indexOf('images/menu_corner_minus.gif') != -1) {
    eval("document.all.imageConnector"  + strID + ".src = 'images/menu_corner_plus.gif';");   
  } else {
     eval("document.all.imageConnector"  + strID + ".src = 'images/menu_tee_plus.gif';");      
  }

  //Only change the image if this is a folder, not an account connected to Service Endpoints
  if(eval('document.all.imageConnector' + strID + '.IsFolder') == 'Y') {
    if(eval("document.all.image" + strID + "folder.src").indexOf('folder') != -1) {
      eval("document.all.image"  + strID + "folder.src = 'images/menu_folder_closed.gif';");   
    }
  }
  eval("document.all.row"  + strID + ".style.display = 'none';");
}

///////////////////////////////////////////////////////////////////////////////////
function ShowID(strID) {
  if(strID == "1")
    return;
  
  if(eval("document.all.imageConnector" + strID + ".src").indexOf('images/menu_corner_plus.gif') != -1) {
    eval("document.all.imageConnector"  + strID + ".src = 'images/menu_corner_minus.gif';");   
  } else {
    eval("document.all.imageConnector"  + strID + ".src = 'images/menu_tee_minus.gif';");      
  }

  //Only change the image if this is a folder, not an account connected to Service Endpoints
  if(eval('document.all.imageConnector' + strID + '.IsFolder') == 'Y') {
    if(eval("document.all.image" + strID + "folder.src").indexOf('folder') != -1) {
       eval("document.all.image"  + strID + "folder.src = 'images/menu_folder_open.gif';");
    }
  }
  eval("document.all.row"  + strID + ".style.display = 'inline';");
}

///////////////////////////////////////////////////////////////////////////////////
function Toggle(strID) {

    // check to see if we have already loaded and call show or hide... else load
    if(eval("document.all.row" + strID + ".style.display") == 'none') {
      ShowID(strID);
    }
    else if(eval("document.all.row" + strID + ".style.display") == 'inline') {
      HideID(strID); 
    }
    else{ 
      LoadID(strID);
      ShowID(strID);
    }
}
///////////////////////////////////////////////////////////////////////////////////
function LoadFind(strID) {
    var strChild;

    if(nCounter != 0){
      alert("Still loading... [Completed " + nCounter + " of " + nLength + "]");
      return;
    }

    strURL = '/mam/default/dialog/hierarchySnippet.asp?action=Load&id=' + strID;

    strChild = 'cellChildren' + strID;
    objInsert = document.all(strChild);
        
    objInsert.innerHTML = "<div style='color:navy;'>&nbsp;&nbsp;&nbsp;Loading...</div>";

    loadingSingle(strID);
}
///////////////////////////////////////////////////////////////////////////////////
function loading(intIndex, strID)
{
  var objInsert = arrInserts[intIndex];
  var strURL = arrURLs[intIndex];

   objXML.load(strURL);
//   alert(objXML.xml);
   if(!checkParseError(objXML, 'Unable to load XML!')) {
   
     objList = objXML.selectNodes("/hierarchy/hierarchy");
     nLength = objList.length
     
     if(nLength > MAX_SIZE_TO_AUTO_OPEN) {  
       var bOK = false;
       bOK = confirm("There are " + nLength + " accounts under this folder.\r\nClick OK to continue loading.");
     
       if(bOK){
         objInsert.innerHTML = objXML.transformNode(objXSL);
       }
       else {
         bStopSync = true;
         objInsert.innerHTML = "&nbsp;&nbsp;&nbsp;<a  style='cursor:hand;text-decoration:underline;' onclick='JavaScript:dragID=" + strID + ";searchSubHierarchy();'>Search from here.</a>" +  "<br>&nbsp;&nbsp;&nbsp;<a style='cursor:hand;text-decoration:underline;' onclick='LoadID(\"" + strID + "\");ShowID(\"" + strID + "\");'>Load folder.</a>";
       }
     }
     else {
       objInsert.innerHTML = objXML.transformNode(objXSL);
     }
   }
//   alert(objXML.transformNode(objXSL));
//   document.DragForm.hierarchyHTML.value = objXML.transformNode(objXSL);
}
///////////////////////////////////////////////////////////////////////////////////
 function loadingSingle(strID){
   objXML.load(strURL);
//   alert(objXML.xml);
   if(!checkParseError(objXML, 'Unable to load XML!')) {
   
     objList = objXML.selectNodes("/hierarchy/hierarchy");
     nLength = objList.length
     
     if(nLength > MAX_SIZE_TO_AUTO_OPEN) {  
       var bOK = false;
       bOK = confirm("There are " + nLength + " accounts under this folder.\r\nClick OK to continue loading.");
     
       if(bOK){
         objInsert.innerHTML = objXML.transformNode(objXSL);
       }
       else {
         bStopSync = true;
         objInsert.innerHTML = "&nbsp;&nbsp;&nbsp;<a  style='cursor:hand;text-decoration:underline;' onclick='JavaScript:dragID=" + strID + ";searchSubHierarchy();'>Search from here.</a>" +  "<br>&nbsp;&nbsp;&nbsp;<a style='cursor:hand;text-decoration:underline;' onclick='LoadID(\"" + strID + "\");ShowID(\"" + strID + "\");'>Load folder.</a>";
       }
     }
     else {
       objInsert.innerHTML = objXML.transformNode(objXSL);
     }
   }
//   alert(objXML.transformNode(objXSL));
//   document.DragForm.hierarchyHTML.value = objXML.transformNode(objXSL);
}
///////////////////////////////////////////////////////////////////////////////////  
function Highlight(strID){
   if(nLastHighlighted != "0"){
     if(eval("document.all.text" + nLastHighlighted) != null){      
       eval("document.all.text"  + nLastHighlighted + ".style.color = 'black';");
     }  
   }
   nLastHighlighted = strID;
   if(eval("document.all.text" + strID) != null){   
     eval("document.all.text"  + strID + ".style.color = 'green';");
    
    // TODO:  I want to scroll to the highlighted element, but I can't find it's position 
    //var left;
    //var top;
    //eval("left = document.all.text"  + strID + ".left;");
    //eval("top = document.all.text"  + strID + ".top;");
    //alert(left + " - " + top);
    //moveScroll(left, top);
   }
}

///////////////////////////////////////////////////////////////////////////////////  
function ClearHighlight(){
   if(nLastHighlighted != "0"){
     if(eval("document.all.text" + nLastHighlighted) != null){   
       eval("document.all.text"  + nLastHighlighted + ".style.color = 'black';");
     }
   }
}

///////////////////////////////////////////////////////////////////////////////////  
function FindAccountInHierarchy(strIDS, myID){
  MyTree.FindInHierarchy(strIDS);  
	/*var ids = strIDS.split(",");
	bStopSync = false;

	for (var i=1; i < ids.length; i++)
	{
    if(eval("document.all.row" + ids[i]) == null){
        LoadFind(ids[i-1]); 
        if(bStopSync) return;
        ShowID(ids[i-1]);    
        if(bStopSync) return;
    }
    else{
      // check to see if we have already loaded and call show 
      if(eval("document.all.row" + ids[i] + ".style.display") == 'none') {
        ShowID(ids[i]); 
        if(bStopSync) return;
      }
      else if(eval("document.all.row" + ids[i] + ".style.display") == 'inline') { 
      }
      else{ 
       LoadFind(ids[i]); 
       if(bStopSync) return;
       ShowID(ids[i]);    
       if(bStopSync) return;
      } 
    }
	}
  if(eval("document.all.text" + myID) != null){
    Highlight(myID);
  }
  else {
    ClearHighlight();
    alert("There too many accounts under the folder to allow highlighting.  Please load the folder first.");
  }*/
}
  
///////////////////////////////////////////////////////////////////////////////////  
function checkParseError(objXML, strError) {
  var node;
  node = objXML.selectSingleNode("timeout"); // check for timeout
  if(node != null) {
    eval(node.text);
    return(true);
  }
 
  if(objXML.parseError.errorCode != 0) {
    alert(strError + ":  " + objXML.parseError.reason);
    return(true);
  }
  return(false);
}

function moveScroll(left, top) {
	document.body.scrollLeft = left;
	document.body.scrollTop = top;
}

// on page load we get the scroll offset from the querystring and scroll
function positionScroll() {
  QueryString_Parse();
	document.body.scrollLeft = QueryString("scrollLeft");
	document.body.scrollTop = QueryString("scrollTop");
}
/////////////////////////////////////////////////////////////////////////////
function QuickInfo(strID) {
  if(!window.event.ctrlKey)
    parent.main.location.href = 'QuickInfo.asp?ID=' + strID;
}
/////////////////////////////////////////////////////////////////////////////
function QuickInfoSE(strID) {
  if(!window.event.ctrlKey)
    parent.main.location.href = 'SE_QuickInfo.asp?ID=' + strID;
}
//
// QueryString helper functions
//
function QueryString(key)
{
	var value = null;
	for (var i=0;i<QueryString.keys.length;i++)
	{
		if (QueryString.keys[i]==key)
		{
			value = QueryString.values[i];
			break;
		}
	}
	return value;
}
QueryString.keys = new Array();
QueryString.values = new Array();

function QueryString_Parse()
{
	var query = window.location.search.substring(1);
	var pairs = query.split("&");
	
	for (var i=0;i<pairs.length;i++)
	{
		var pos = pairs[i].indexOf('=');
		if (pos >= 0)
		{
			var argname = pairs[i].substring(0,pos);
			var value = pairs[i].substring(pos+1);
			QueryString.keys[QueryString.keys.length] = argname;
			QueryString.values[QueryString.values.length] = value;		
		}
	}

}


  