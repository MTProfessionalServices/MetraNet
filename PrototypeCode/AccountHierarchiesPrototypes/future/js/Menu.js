///////////////////////////////////////////////////////////////////////////////////
// Menu.js --  Routines for handling the tree menu                               //
///////////////////////////////////////////////////////////////////////////////////

var g_strBaseImagePath = "images/"

function LoadID(strID) {
  if(!window.event.ctrlKey)
    document.location.href = 'menu.asp?action=Load&id=' + strID;
}

function UnLoadID(strID) {
  if(!window.event.ctrlKey)
    document.location.href = 'menu.asp?action=Unload&id=' + strID;
}

var gRolled = false;
      
function RollDiv(strDiv) {
  var intHeight = 0;
  var i;
  
//  intHeight = document.body.clientHeight - (28 * g_arrDivs.length);
  intHeight = document.body.clientHeight - 100;
//  intHeight = document.all(strDiv).scrollHeight;

  
  if(gRolled) {
    document.all(strDiv).style.height = intHeight;
    document.all(strDiv).style.overflowY = 'auto';
    
  } else {
    document.all(strDiv).style.height='14';
    document.all(strDiv).style.overflowY = 'hidden';
  }
  
  gRolled = !gRolled;
}

