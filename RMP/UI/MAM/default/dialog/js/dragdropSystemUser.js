//==========================================================================
// Copyright 1998, 2007 by MetraTech Corporation
// All rights reserved.
//
// THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
// NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
// example, but not limitation, MetraTech Corporation MAKES NO
// REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
// PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
// DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
// COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
//
// Title to copyright in this software and any associated
// documentation shall at all times remain with MetraTech Corporation,
// and USER agrees to preserve the same.
//==========================================================================
// NAME:  Drag and Drop Script - dragdropSystemUser.js
// VERSION:  5.1
// CREATION_DATE:  08/27/2001
// Updated:  5/08/2007
// AUTHOR:  K.Boucher
// DESCRIPTION:  Contains the functions needed to implement Drag & Drop 
//               events for HTML objects.
//               
//               * Alows objects to be set as dragable and dropable via style
//               * Allows custom drop events
//               * Provides shadow of dragging object
//               * Supports single and multiple select
//==========================================================================

// There is probably no need to change this file.  You can override any of the properties
// in your own file.

// Color settings
var SELECTED_COLOR = "#97CE21";
var NORMAL_COLOR = "black";
var HIGHLIGHT_COLOR = "red"

// Shadow settings
var SHADOW_OFFSET = 10;
var SHADOW_LEFT_OFFSET = 255;
var SHADOW_DOWN_OFFSET = 100;
var SHADOW_HTML_ID_PREFIX = "shadow";   // (SHADOW_HTML_ID_PREFIX + dragID)  - This id tells us what html object to grab for the dragging shadow     
var SMALL_SHADOW_HTML_ID_PREFIX = "smallShadow";
var MAX_NUMBER_IN_MULTI_DRAG = 3;
var MAX_HTML_TO_SHOW_ON_DRAG = 1500;

//==========================================================================
// Sample HTML 
//==========================================================================
//<html>
//<head>
//	<title>Sample Drag & Drop</title>
//  
//  <!-- Drag & Drop Functions --> 
//  <script language="Javascript" src="js/dragdrop.js"></script>  
//
//  <!-- Drag & Drop Styles --> 
//  <style> 
//          .clsDrag{cursor:hand; dragable:true;} 
//          .clsDrop{cursor:hand; dropable:true;} 
//          .clsDragDiv{position:absolute; cursor:hand; visibility : hidden;  filter: alpha(opacity=50);}
//  </style>
//  
//</head>
//
//  <!-- Drag & Drop body tag -->
//  <body bgcolor="SeaGreen" onDrag="fOnDrag();" onDragEnd="fOnDragEnd();" onDragLeave="fOnDragLeave();" onDragEnter="fOnDragEnter();" onDragStart="fOnDragStart();" onDragOver="fOnDragOver();" onDrop="fOnDrop();">
//
//  <!-- DIV for dragable shadow --> 
//  <div class="clsDragDiv" id="dragDiv"></div>
//
//  <!-- Sample dragable item -->
//  <table id="shadow0"><tr><td class="clsDrag" dragID="0" onMouseDown="SelectMe('0');"> drag me 0</td></tr></table><br><br>
//  <table id="shadow1"><tr><td class="clsDrag" dragID="1" onMouseDown="SelectMe('1');"> drag me 1</td></tr></table><br><br>
//  <table><tr><td class="clsDrop" dragID="10"> drop here </td></tr></table>  
//
//</body>
//</html>
//==========================================================================

var m_arrMultiSelectData = new Array( );
var m_nMultiSelectIndex  = 0;
var m_nUnSelectIndex = 0;
var m_bMultiSelect = false;
var m_Type = 'Account';

/////////////////////////////////////////////////////////////////////
function fOnDragStart(){
 obj = window.event.srcElement;
 
 if (obj.currentStyle.dragable == "true") {
   if (!window.event.dataTransfer) {
     alert("This version of IE does not support Drag n' Drop");
     return;
   }

   // Check to see if we are in multi-select mode
   if(m_bMultiSelect){
     window.event.dataTransfer.setData("Text", "MULTI-SELECT"); 

     // check to see if obj.dragID is in multi select array... if not clear multi select array
     var bInMultiSelect = false;
     for(j=0; (j < m_arrMultiSelectData.length); j++) {
       if(obj.dragID == m_arrMultiSelectData[j]) {
         bInMultiSelect = true;
       }
     }
     if(!bInMultiSelect) {    
       clearSelection();
       // build shadow div for single select
       if(document.all(SHADOW_HTML_ID_PREFIX + obj.dragID) != null) {
         if(document.all(SHADOW_HTML_ID_PREFIX + obj.dragID).outerHTML.length > MAX_HTML_TO_SHOW_ON_DRAG){
           document.all.dragDiv.innerHTML = document.all.dragDiv.innerHTML + "<table>" + document.all(SMALL_SHADOW_HTML_ID_PREFIX + obj.dragID).outerHTML + "</table>";                
         }
         else {
           document.all.dragDiv.innerHTML = document.all(SHADOW_HTML_ID_PREFIX + obj.dragID).outerHTML;   
         }       
         if(getFrameMetraNet().main.parentfOnDrag) {
           getFrameMetraNet().main.document.all.dragDiv.innerHTML = document.all.dragDiv.innerHTML;
         }  
       }
       
       window.event.dataTransfer.setData("Text", obj.dragID);
       return;
     }
     
     // Build multi select shadow div
     for(j=0; (j < m_arrMultiSelectData.length) && (j <= MAX_NUMBER_IN_MULTI_DRAG); j++) {

         if(document.all(SHADOW_HTML_ID_PREFIX + m_arrMultiSelectData[j]).outerHTML != null) {
           
           // add ... if we hit the max
           if((j == MAX_NUMBER_IN_MULTI_DRAG) && (m_arrMultiSelectData.length > MAX_NUMBER_IN_MULTI_DRAG +1)) {
             document.all.dragDiv.innerHTML = document.all.dragDiv.innerHTML + "&nbsp;&nbsp;&nbsp;.<br>&nbsp;&nbsp;&nbsp;.<br>&nbsp;&nbsp;&nbsp;.<br>";
           }
           else{  
             if(document.all(SHADOW_HTML_ID_PREFIX + m_arrMultiSelectData[j]).outerHTML.length > MAX_HTML_TO_SHOW_ON_DRAG){
               document.all.dragDiv.innerHTML = document.all.dragDiv.innerHTML + "<table>" + document.all(SMALL_SHADOW_HTML_ID_PREFIX + m_arrMultiSelectData[j]).outerHTML + "</table>";                     
             }
             else{
               document.all.dragDiv.innerHTML = document.all.dragDiv.innerHTML + document.all(SHADOW_HTML_ID_PREFIX + m_arrMultiSelectData[j]).outerHTML;   
             }
           }
					 if(getFrameMetraNet().main.parentfOnDrag){
              getFrameMetraNet().main.document.all.dragDiv.innerHTML = document.all.dragDiv.innerHTML; 
       	   }	

         }     
     }
     // add the last one selected after the ...
     if(m_arrMultiSelectData.length > MAX_NUMBER_IN_MULTI_DRAG) {
         j = m_arrMultiSelectData.length -1; 
         if(document.all(SHADOW_HTML_ID_PREFIX + m_arrMultiSelectData[j]).outerHTML != null) {
          
           //document.all.dragDiv.innerHTML = document.all.dragDiv.innerHTML + document.all(SHADOW_HTML_ID_PREFIX + m_arrMultiSelectData[j]).outerHTML;   
           if(document.all(SHADOW_HTML_ID_PREFIX + m_arrMultiSelectData[j]).outerHTML.length > MAX_HTML_TO_SHOW_ON_DRAG){
             document.all.dragDiv.innerHTML = document.all.dragDiv.innerHTML + "<table>" + document.all(SMALL_SHADOW_HTML_ID_PREFIX + m_arrMultiSelectData[j]).outerHTML + "</table>";                     
           }
           else{
             document.all.dragDiv.innerHTML = document.all.dragDiv.innerHTML + document.all(SHADOW_HTML_ID_PREFIX + m_arrMultiSelectData[j]).outerHTML;   
           }					
           if(getFrameMetraNet().main.parentfOnDrag){
              getFrameMetraNet().main.document.all.dragDiv.innerHTML = document.all.dragDiv.innerHTML; 
       	   }	
         }
     }
    
     if(m_arrMultiSelectData.length == 1) {     // treat one multi select as single
      window.event.dataTransfer.setData("Text", obj.dragID);
    }    
 
   }
   else {
     // build shadow div for single select
     if(document.all(SHADOW_HTML_ID_PREFIX + obj.dragID) != null) {
       if(document.all(SHADOW_HTML_ID_PREFIX + obj.dragID).outerHTML.length > MAX_HTML_TO_SHOW_ON_DRAG){
         document.all.dragDiv.innerHTML = document.all.dragDiv.innerHTML + "<table>" + document.all(SMALL_SHADOW_HTML_ID_PREFIX + obj.dragID).outerHTML + "</table>";                
       }
       else {
         document.all.dragDiv.innerHTML = document.all(SHADOW_HTML_ID_PREFIX + obj.dragID).outerHTML;   
       }       
       if(getFrameMetraNet().main.parentfOnDrag) {
         getFrameMetraNet().main.document.all.dragDiv.innerHTML = document.all.dragDiv.innerHTML;
       }  
     }
     
     window.event.dataTransfer.setData("Text", obj.dragID);
   }   
 }
 else {
   window.event.returnValue = false; 
 }

}

/////////////////////////////////////////////////////////////////////
function fOnDragOver(){
  window.event.returnValue = false; 
}

/////////////////////////////////////////////////////////////////////
function fOnDragEnter(){
  obj = window.event.srcElement;

  var bFolder;
  var bDropable;
 
  var bHighlightMulti;
  var bHighlightSingle;

  if(obj.IsFolder == 'Y')
    bFolder = true;
  else
    bFolder = false;
 
  if(obj.currentStyle.dropable == 'true')
    bDropable = true;
  else
    bDropable = false;

  // multi-select drag enter
  //If moving accounts, then don't hightlight unless a folder
  if((bDropable && bFolder) || (bDropable && (obj.dragID == "DropField")))
  {
    if(m_bMultiSelect)
    {
      for(i=0;i < m_arrMultiSelectData.length; i++)
      {
        if(obj.dragID == m_arrMultiSelectData[i])
        {
          obj.style.color = "";
          window.event.returnValue = false; 
          return;       
        }  
      }

      obj.style.color = SELECTED_COLOR;
      window.event.returnValue = false; 
      return;
   
    } else {
      //Don't allow dropping on oneself
      if(window.event.dataTransfer.getData("Text") != obj.dragID)
      {
      obj.style.color = SELECTED_COLOR;
      }
    }
  }
 window.event.returnValue = false; 
}

/////////////////////////////////////////////////////////////////////
function fOnDragLeave(){
	obj = window.event.srcElement;

	for(i=0;i < m_arrMultiSelectData.length; i++){
		if(obj.dragID == m_arrMultiSelectData[i]){
		obj.style.color = HIGHLIGHT_COLOR;
		window.event.returnValue = false; 
		return;       
		}  
	}

	if (obj.currentStyle.dragable == "true") {
		obj.style.color = "";
	}   
}

/////////////////////////////////////////////////////////////////////
function clearSelection(){
     var bClearSelection = false;
     
     // Set styles back and clear multi-select array  
     for(i=0;i < m_arrMultiSelectData.length; i++){
       if(eval("getFrameMetraNet().hierarchyUser.document.all.text" + m_arrMultiSelectData[i]+ ".style") != null){
       
         eval("getFrameMetraNet().hierarchyUser.document.all.text" + m_arrMultiSelectData[i] + ".style.color = '" + NORMAL_COLOR + "';");
         bClearSelection = true;
       }
     }
     if(bClearSelection) {
       m_arrMultiSelectData.length = 0;
       m_nMultiSelectIndex = 0;

       m_bMultiSelect = false;
     }
}

// Default OnDrop - will call custom dropEvent if one is specified
/////////////////////////////////////////////////////////////////////
function fOnDrop(){
 var str = "";
 obj = window.event.srcElement;

 document.all.dragDiv.innerHTML = "";
 document.all.dragDiv.style.display = 'none';

 if((obj.dropEvent == "GetHierarchyPath") || (obj.dropEvent == "GetID") || (obj.dropEvent == "GetFieldID") || (obj.dropEvent == "GetHierarchyPathWithCorporate") ){
   eval(obj.dropEvent + "('" + obj.name + "');");
	 return;
 }

 if(obj.currentStyle != null) {       	  	        
   if ((obj.currentStyle.dropable == "true") && (window.event.dataTransfer.getData("Text") != obj.dragID)) {

     // DEFAULT:  Multi-Select (overridable with dropEvent attribute)
     if (window.event.dataTransfer.getData("Text") == "MULTI-SELECT"){
       		   
  		 if(obj.dropEvent == null) {
         return;  
       }
       else { 
         eval(obj.dropEvent + "();");		
         return; 
       }
     }   

     // DEFAULT:  single move (overridable with dropEvent attribute)
  	 if(obj.dropEvent == null) {
       return;
     }
     else {  
       eval(obj.dropEvent + "();");		
     }
   
  }
 }
 
}

/////////////////////////////////////////////////////////////////////
function SelectMe(nID) {
  obj = window.event.srcElement;
  var bUnselect = false;
  
  if (obj.currentStyle.dragable == "true") {
 
   // clear shadow div
   document.all.dragDiv.innerHTML = "";
   
   // Select the item
   txtRange = document.body.createTextRange();
   txtRange.moveToElementText(obj);
   txtRange.select();
   
   // Check to see if we are in multi-select mode
   if(window.event.ctrlKey) {
      
      if(nID == '1') return;
          
      m_bMultiSelect = true;
       
      // Check to see if it already is selected 
      // then unselect it by removing it
      for(i=0; i < m_arrMultiSelectData.length; i++){
        
        if(m_arrMultiSelectData[i] == nID) {
          obj.style.color = NORMAL_COLOR;
          unselectElement(m_arrMultiSelectData, i);
          m_nUnSelectIndex++;
          // if we unselect the last item leave multi-select mode
          if(m_nUnSelectIndex == m_nMultiSelectIndex){  
            m_bMultiSelect = false;
            m_nMultiSelectIndex = 0;
            m_nUnSelectIndex = 0;
          }
          bUnselect = true;
        }
      }      
      
      if(!bUnselect) {
        // Store id in global array, update the index, and set the style to selected
        m_arrMultiSelectData[m_arrMultiSelectData.length] = nID;
        obj.style.color = HIGHLIGHT_COLOR;
        m_nMultiSelectIndex++;      
      }  
            
   }  

 }
}

//  unselect element
/////////////////////////////////////////////////////////////////////
function unselectElement(array, nIndex) {
  size = array.length;
  delindex = nIndex
  validNo = (delindex != "NaN");
  inRange = ( (delindex >= 0) && (delindex <= array.length) );
  if (validNo && inRange) {
    for (var i=0; i<=size; i++)
      array[i] = ((i == delindex) ? "delete" : array[i]);
      for (var j=delindex; j<size-1; j++)
        if (j != size) array[j] = array[j+1];
      array.length = size-1;
  }
}

//  Support for showing what you are moving
/////////////////////////////////////////////////////////////////////
function fOnDrag(){
  document.all.dragDiv.style.pixelLeft = window.event.clientX + document.body.scrollLeft + SHADOW_OFFSET ;
  document.all.dragDiv.style.pixelTop = window.event.clientY + document.body.scrollTop;
  document.all.dragDiv.style.display = 'inline';
  if(getFrameMetraNet().main.parentfOnDrag){
  	 getFrameMetraNet().main.parentfOnDrag(window.event.clientX + SHADOW_OFFSET, window.event.clientY);
	}	
}

//  Support for showing what you are moving in main frame
/////////////////////////////////////////////////////////////////////
function parentfOnDrag(parentX, parentY){
  document.all.dragDiv.style.pixelLeft = parentX + document.body.scrollLeft - SHADOW_LEFT_OFFSET;  // yes, these numbers are a bit magical
  document.all.dragDiv.style.pixelTop = parentY + document.body.scrollTop + SHADOW_DOWN_OFFSET;
  document.all.dragDiv.style.display = 'inline';  
}

/////////////////////////////////////////////////////////////////////
function fOnDragEnd(){
  document.all.dragDiv.innerHTML = "";
  document.all.dragDiv.style.display = 'none';
}


///////////////////////////////////////////////////////////////////////
// Custom Drop Events Start Here:  GetHierarchyPath, HandleDrop
///////////////////////////////////////////////////////////////////////

// If the dropEvent="GetFieldID" attribute is set then this
// function will fill in the current field with the hierarchy path
/////////////////////////////////////////////////////////////////////
function GetHierarchyPath(strName) {
  if(getFrameMetraNet().hierarchyUser.getCurrentPath().indexOf("(1)") == -1) {
    eval("document.all." + strName + ".value = getFrameMetraNet().hierarchyUser.getCurrentPath();");
    eval("document.all." + strName + ".style.color = 'black';");
  }
}
function GetHierarchyPathWithCorporate(strName) {
    eval("document.all." + strName + ".value = getFrameMetraNet().hierarchyUser.getCurrentPath();");
    eval("document.all." + strName + ".style.color = 'black';");
}

/////////////////////////////////////////////////////////////////////
function GetID(strName) {
  var obj = window.event.srcElement;
  var obj_id;
  obj_id = window.event.dataTransfer.getData("Text");

  if(obj_id == null)
  {
    obj_id = window.getFrameMetraNet().dragAccounts;
  }
  
  eval("document.all." + strName + ".value = " + obj_id + ";");
}

function GetFieldID(strName) {
  var obj = window.event.srcElement;
  var nID;
  nID = window.event.dataTransfer.getData("Text");
  if(nID == null)
  {
    nID = window.getFrameMetraNet().dragAccounts;
  }
  if(getFrameMetraNet().hierarchyUser.GetFieldIDFromAccountID)
  {
    getFrameMetraNet().hierarchyUser.GetFieldIDFromAccountID(nID);
  }
  waitForReady(strName);
}

function waitForReady(strName) {
  if(getFrameMetraNet().hierarchyUser.LastID != null) {
    var str = getFrameMetraNet().hierarchyUser.LastID;
    str = str.replace(/'/g, "\\\'"); 
    eval("document.all." + strName + ".value = '" + str + "';");
    getFrameMetraNet().hierarchyUser.LastID = null;
  }
  else {
      setTimeout("waitForReady('" + strName + "')", 100);   
  }
}

// If the dropEvent="HandleDrop" attribute is set then this
// function will fill in the DropGrid with the accounts that have
// been selected
/////////////////////////////////////////////////////////////////////
function HandleDrop() {
  var obj = window.event.srcElement;
  var strSelected = '';
  var i = 0;

  var bDropable;
  var bFolder;

  //Check for allowable drop.
  //Check for multi drop
  if(obj.currentStyle.dropable == "true")
    bDropable = true;
  else
    bDropable = false;
   
  if(obj.IsFolder == 'Y')
    bFolder = true;
  else
    bFolder = false;

  if((bDropable && bFolder) || (bDropable && (obj.dragID == "DropField"))) {
  
    document.mdm.DropAction.value = "MULTI";  
    strSelected = window.event.dataTransfer.getData("Text");
	if (strSelected == null)  
	{
	  strSelected = window.getFrameMetraNet().dragAccounts;
	}
	
    //Set the target of the drop
    document.mdm.Parent.value = obj.dragID;
  
    //Set the items to move
    document.mdm.Child.value = strSelected;

    //Popup window with confirmation, etc. before submit        
    document.all.dragDiv.innerHTML = "";

    //Call DropGrid_Click
    mdm_RefreshDialog("DropGrid");
  }
}
      
// Set Folder Action - used in DropGrid if bFolderOptions is true
/////////////////////////////////////////////////////////////////////
function SetFolderAction(objElement) {
  
   var strCurrentValue =  objElement.value;
  
   var arrFolderActions = new Array();
   arrFolderActions[0] = "Current Node";
   arrFolderActions[1] = "Direct Descendants";
   arrFolderActions[2] = "All Descendants";  
   
   if (strCurrentValue == arrFolderActions[0])
   {
    objElement.value = arrFolderActions[1];
   }
   
   if(strCurrentValue == arrFolderActions[1])
   {
    objElement.value = arrFolderActions[2];
   }
   
   if(strCurrentValue == arrFolderActions[2])
   {
    objElement.value = arrFolderActions[0];
   }
}           

/////////////////////////////////////////////////////////////////////
  function ToggleManualEntry() {
    if(document.all.Advanced.style.display == "none")  
      document.all.Advanced.style.display = "block";   
    else
      document.all.Advanced.style.display = "none"; 
  }

function getFrameMetraNet()
{
  if(top.frameMetraCare)
    return top.frameMetraCare;
  else
    return top;  
}