//==========================================================================
// Copyright 1998, 2001 by MetraTech Corporation
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
// NAME:  Drag and Drop Script - dragdrop.js
// VERSION:  3.0
// CREATION_DATE:  08/27/2001
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
var NORMAL_COLOR = "white";
var HIGHLIGHT_COLOR = "silver"

// Shadow settings
var SHADOW_OFFSET = 10;
var SHADOW_HTML_ID_PREFIX = "shadow";   // (SHADOW_HTML_ID_PREFIX + dragID)  - This id tells us what html object to grab for the dragging shadow     

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
     return;
   }
   
   window.event.dataTransfer.setData("Text", obj.dragID);
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
  
 // multi-select drag enter
 if((m_bMultiSelect) && (obj.currentStyle.dropable == "true")){
 
   for(i=0;i < m_arrMultiSelectData.length; i++){
     if(obj.dragID == m_arrMultiSelectData[i]){
       obj.style.color = "";
       window.event.returnValue = false; 
       return;       
     }  
   }

   obj.style.color = SELECTED_COLOR;
   window.event.returnValue = false; 
   return;
 } 

 // single drag enter 
 if ((obj.currentStyle.dropable == "true")  && (window.event.dataTransfer.getData("Text") != obj.dragID)) {
   obj.style.color = SELECTED_COLOR;
 }
 
 window.event.returnValue = false; 
}

/////////////////////////////////////////////////////////////////////
function fOnDragLeave(){
 obj = window.event.srcElement;
 
 if (obj.currentStyle.dragable == "true") {
    obj.style.color = "";
 }
}

/////////////////////////////////////////////////////////////////////
function fOnDrop(){
 var str = "";
 obj = window.event.srcElement;
 
 document.all.dragDiv.style.visibility = 'hidden';
            
 if ((obj.currentStyle.dropable == "true") && (window.event.dataTransfer.getData("Text") != obj.dragID)) {
    
   // DEFAULT:  Multi-Select (overridable with dropEvent attribute)
   if (window.event.dataTransfer.getData("Text") == "MULTI-SELECT"){
     if(obj.dropEvent == null) {

       // check upfront to make sure we can drop here safely
       for(i=0;i < m_arrMultiSelectData.length; i++){
         if(obj.dragID == m_arrMultiSelectData[i]){
           return; 
         }
       } 
       for(i=0;i < m_arrMultiSelectData.length; i++){
           if(m_arrMultiSelectData[i] != "unselected")
             str = str + m_arrMultiSelectData[i] + "\n";
       }
       alert("Multi drop:  \n" + str + " onto --> " + obj.dragID);
       obj.style.border = "";

       // Set styles back and clear multi-select array
       m_arrMultiSelectData.length = 0;
       m_nMultiSelectIndex = 0;
     
       var tds;
       tds = document.all.tags("td");
       for(i=0; i < tds.length; i++){
         tds(i).style.color = NORMAL_COLOR;
       }
     
       m_bMultiSelect = false;
       document.all.dragDiv.innerText = "";
       return;  
     }
     else { 
       eval(obj.dropEvent + "();");		
       return; 
     }
   }   
  
   // DEFAULT:  single move (overridable with dropEvent attribute)
   if(obj.dropEvent == null) {
     alert("dropped " + window.event.dataTransfer.getData("Text") + " on " + obj.dragID);
     obj.style.border = "";
     document.all.dragDiv.innerText = "";
   }
   else { 
     eval(obj.dropEvent + "();");		
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
   
      m_bMultiSelect = true;
       
      // Check to see if it already is selected 
      // then unselect it by setting the value to 'unselected'
      for(i=0; i < m_arrMultiSelectData.length; i++){
        
        if(m_arrMultiSelectData[i] == nID) {
          obj.style.color = NORMAL_COLOR;
          m_arrMultiSelectData[i] = "unselected";
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
        m_arrMultiSelectData[m_nMultiSelectIndex] = nID;
        obj.style.color = HIGHLIGHT_COLOR;
        m_nMultiSelectIndex++;      
      }  
   }  

   // Create shadow div
   if(m_bMultiSelect){
     for(j=0; j < m_arrMultiSelectData.length; j++){
       if(m_arrMultiSelectData[j] != "unselected")
         if(document.all(SHADOW_HTML_ID_PREFIX + m_arrMultiSelectData[j]).outerHTML != null)
           document.all.dragDiv.innerHTML = document.all.dragDiv.innerHTML + document.all(SHADOW_HTML_ID_PREFIX + m_arrMultiSelectData[j]).outerHTML;   
     }   
   }
   else{
     if(document.all(SHADOW_HTML_ID_PREFIX + nID) != null)
       document.all.dragDiv.innerHTML = document.all(SHADOW_HTML_ID_PREFIX + nID).outerHTML;   
   }
 }
}

//  Support for showing what you are moving
/////////////////////////////////////////////////////////////////////
function fOnDrag(){
  document.all.dragDiv.style.pixelLeft = window.event.clientX + document.body.scrollLeft + SHADOW_OFFSET ;
  document.all.dragDiv.style.pixelTop = window.event.clientY + document.body.scrollTop;
  document.all.dragDiv.style.visibility = 'visible';
}

/////////////////////////////////////////////////////////////////////
function fOnDragEnd(){
  document.all.dragDiv.style.visibility = 'hidden';
}
