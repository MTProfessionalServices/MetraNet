//==========================================================================
// Copyright 1998, MENU_WIDTH1 by MetraTech Corporation
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
// NAME:  Context menu script - contextmenu.js
// VERSION:  3.0
// CREATION_DATE:  10/10/MENU_WIDTH1
// AUTHOR:  K.Boucher
// DESCRIPTION:  Contains the functions needed to implement a right click
//               context menu
//               ::original code at http://www.dynamicdrive.com
//==========================================================================
//
//<div id="contextMenu" class="clsContextMenu" onMouseover="highlightie5(event)" onMouseout="lowlightie5(event)" onClick="jumptoie5(event)" display:none>
//  <div class="clsContextItem" url="test.html" target="fmeMain">Add Account</div>
//  <div class="clsContextItem" url="test.html" target="fmeMain">New Folder</div>
//  <div class="clsContextItem" subMenu="true" onMouseover="showSubMenu('operationsMenu')" url="#">Operations<img src="images/more.gif"></div>
//</div>
//
//<div id="operationsMenu" class="clsContextMenu" onMouseover="highlight(event)" onMouseout="lowlight(event)" onClick="jumpto(event)" display:none>
//  <div class="clsContextItem" url="#">Issue Credit</div>
//  <div class="clsContextItem" url="#">Additional Charge</div>       
//</div>

//set this variable to 1 if you wish the URLs of the highlighted menu to be displayed in the status bar
var display_url=0
var dragID=0
var IsFolder="N"
var IsSE = false;
var ParentID = -1;
var MENU_WIDTH = 200;

var ie5=document.all&&document.getElementById
var ns6=document.getElementById&&!document.all
if (ie5||ns6)
  var menuobj=document.getElementById("contextMenu")

function showmenu(e){
        
   // first we must check to make sure we are not already loading an account...
   // the loading lock comes from hierarchy.asp - if it is set, then we exit   
   if(mLoadingLock) { 
    alert("Already performing an action on account [" + dragID + "].  Please wait..."); 
    return false;    
   }
        
  // now let's add some special code to see if we should show context menu !!!  
  obj = window.event.srcElement;
  if (obj.currentStyle.dragable == "true") {
   
    var rightedge = document.body.clientWidth - event.clientX; 
    var bottomedge = document.body.clientHeight - event.clientY;

	 if((event.clientX + MENU_WIDTH) >= document.body.clientWidth){
	     menuobj.style.left = document.body.scrollLeft + document.body.clientWidth - MENU_WIDTH;
	 }
	 else{
	   menuobj.style.left = document.body.scrollLeft + event.clientX; 
	 }
			  
    if (bottomedge < menuobj.offsetHeight + 20)
      menuobj.style.top = document.body.scrollTop + event.clientY - menuobj.offsetHeight;
    else
      menuobj.style.top = document.body.scrollTop + event.clientY

     menuobj.style.visibility="visible"
     dragID = obj.dragID; 
		 IsFolder = obj.IsFolder;
     
     if(obj.IsSE == 'Y')
      IsSE = true;
     else
      IsSE = false;
     
     if(obj.ParentID == null){
       parentID = -1;
     }
     else {
       parentID = obj.ParentID;
     }
     
     
		 // If we are not on a folder disable Add Account and Add Folder options
     // For SE's, disable other stuff
		 if(IsFolder == "N"){
       if(document.getElementById("addFolder") != null) {
         document.getElementById("addFolder").innerHTML = "<img src='/mam/default/localized/en-us/images/newfolder.gif'>&nbsp;&nbsp;" + locTextNewFolder;
  	     document.getElementById("addFolder").disabled = true;
       }  
		   if(document.getElementById("addAccount") != null) {
         document.getElementById("addAccount").disabled = true;
       }
       
       if(IsSE) {
  		   document.getElementById("operationsSubMenu").disabled = true;
	       document.getElementById("operationsMenu").disabled = true;
	       document.getElementById("searchSubHierarchy").disabled = true;
       } else {
  		   document.getElementById("operationsSubMenu").disabled = false;
	       document.getElementById("operationsMenu").disabled = false;
       }
		   
       document.getElementById("manageAccount").disabled = false;		
       
       if(document.getElementById("groupSub") != null) {        
         document.getElementById("groupSub").disabled = true;		       	  
       }  
		 }
		 else {
		   // If we are synthetic root hide some stuff
			 if(dragID == "1"){
			   document.getElementById("manageAccount").disabled = true;
			   document.getElementById("operationsSubMenu").disabled = true;
		     document.getElementById("operationsMenu").disabled = true;		
         if(document.getElementById("addAccount") != null) {        	 
  			   document.getElementById("addAccount").disabled = true;			
         }  
         if(document.getElementById("addFolder") != null) {    
           if(document.getElementById("CreateCorp") != null) {
             document.getElementById("addFolder").innerHTML = "<img src='/mam/default/dialog/images/corporates.gif'>&nbsp;&nbsp;" + locTextNewCorp;
             document.getElementById("addFolder").disabled = false;
           }  
           else{
             document.getElementById("addFolder").innerHTML = "<img src='/mam/default/dialog/images/corporates.gif'>&nbsp;&nbsp;" + locTextNewCorp;
             document.getElementById("addFolder").disabled = true;
           }
           
         }  
         if(document.getElementById("groupSub") != null) { 
           document.getElementById("groupSub").disabled = true;
         }		   
			 }
			 else {
         if(document.getElementById("addFolder") != null) {       
           document.getElementById("addFolder").innerHTML = "<img src='/mam/default/localized/en-us/images/newfolder.gif'>&nbsp;&nbsp;" + locTextNewFolder;
           document.getElementById("addFolder").disabled = false;			 
         }
  		   if(document.getElementById("addAccount") != null) {
           document.getElementById("addAccount").disabled = false;		 
         }  
			   document.getElementById("operationsSubMenu").disabled = false;		 
         document.getElementById("operationsMenu").disabled = false;			
			   document.getElementById("manageAccount").disabled = false;				 
         
         // If we are a corporate account then show group subs.
         if(document.getElementById("groupSub") != null) { 
           if(parentID == 1){
             document.getElementById("groupSub").disabled = false;
           }  
           else {
             document.getElementById("groupSub").disabled = true;         	       
           }
         }

			 }
		 }
   }
   return false
}

function hidemenu(e){
  menuobj.style.visibility="hidden"
  hideSubMenu("operationsMenu")
}

function highlight(e){
  var firingobj=ie5? event.srcElement : e.target
  if (firingobj.className=="clsContextItem"||ns6&&firingobj.parentNode.className=="clsContextItem"){
    if (ns6&&firingobj.parentNode.className=="clsContextItem") firingobj=firingobj.parentNode 
    firingobj.style.backgroundColor="highlight"
    firingobj.style.color="white"
    if (display_url==1)
      window.status=event.srcElement.url
    if((firingobj.parentNode.id == "contextMenu") && (firingobj.subMenu != "true")) {
      hideSubMenu("operationsMenu");  
    }
  }
}

function lowlight(e){
  var firingobj=ie5? event.srcElement : e.target
  if (firingobj.className=="clsContextItem"||ns6&&firingobj.parentNode.className=="clsContextItem"){
    if (ns6&&firingobj.parentNode.className=="clsContextItem") firingobj=firingobj.parentNode 
    firingobj.style.backgroundColor=""
    firingobj.style.color="black"
    window.status=''
  }
}

function jumpto(e){
  var firingobj=ie5? event.srcElement : e.target
  if (firingobj.className=="clsContextItem"||ns6&&firingobj.parentNode.className=="clsContextItem"){
    if (ns6&&firingobj.parentNode.className=="clsContextItem") firingobj=firingobj.parentNode
    if (firingobj.getAttribute("target"))
      window.open(firingobj.getAttribute("url"),firingobj.getAttribute("target"))
    else
      window.location=firingobj.getAttribute("url")
  }
}

function showSubMenu(strMenu){
  var subObj = document.getElementById(strMenu)
  obj = window.event.srcElement;

  var bottomedge = document.body.clientHeight - event.clientY;

  if((event.clientX + MENU_WIDTH) >= document.body.clientWidth){
	   subObj.style.left = document.body.scrollLeft + document.body.clientWidth - 180;
	}
	else{
	   subObj.style.left = document.body.scrollLeft + event.clientX; 
	}
			  	
 // if (bottomedge<menuobj.offsetHeight)
 //   subObj.style.top=ie5? document.body.scrollTop+event.clientY-menuobj.offsetHeight : window.pageYOffset+e.clientY-menuobj.offsetHeight
 // else
  subObj.style.top=ie5? document.body.scrollTop + event.clientY : window.pageYOffset + e.clientY
  
  subObj.style.visibility="visible"

  return false    
}

function hideSubMenu(strMenu){
    document.getElementById(strMenu).style.visibility="hidden"
}
    
if (ie5||ns6){
  menuobj.style.display=''
  document.oncontextmenu=showmenu
  document.onclick=hidemenu
}
