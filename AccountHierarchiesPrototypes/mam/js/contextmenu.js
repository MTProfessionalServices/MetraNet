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
// NAME:  Context menu script - contextmenu.js
// VERSION:  3.0
// CREATION_DATE:  10/10/2001
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

var ie5=document.all&&document.getElementById
var ns6=document.getElementById&&!document.all
if (ie5||ns6)
  var menuobj=document.getElementById("contextMenu")

function showmenu(e){

  // first let's add some special code to see if we should show context menu !!!
  obj = window.event.srcElement;
  if (obj.currentStyle.dragable == "true") {
   
    var rightedge=ie5? document.body.clientWidth-event.clientX : window.innerWidth-e.clientX
    var bottomedge=ie5? document.body.clientHeight-event.clientY : window.innerHeight-e.clientY

    menuobj.style.left=ie5? document.body.scrollLeft+event.clientX : window.pageXOffset+e.clientX
  
    if (bottomedge<menuobj.offsetHeight)
      menuobj.style.top=ie5? document.body.scrollTop+event.clientY-menuobj.offsetHeight : window.pageYOffset+e.clientY-menuobj.offsetHeight
    else
      menuobj.style.top=ie5? document.body.scrollTop+event.clientY : window.pageYOffset+e.clientY
  
    menuobj.style.visibility="visible"
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

  var rightedge=ie5? document.body.clientWidth-event.clientX : window.innerWidth-e.clientX
  var bottomedge=ie5? document.body.clientHeight-event.clientY : window.innerHeight-e.clientY

  subObj.style.left=ie5? document.body.scrollLeft+event.clientX : window.pageXOffset+e.clientX
  
 // if (bottomedge<menuobj.offsetHeight)
 //   subObj.style.top=ie5? document.body.scrollTop+event.clientY-menuobj.offsetHeight : window.pageYOffset+e.clientY-menuobj.offsetHeight
 // else
    subObj.style.top=ie5? document.body.scrollTop+event.clientY : window.pageYOffset+e.clientY
  
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
