//////////////////////////////////////////////////////////////////////////////////////////////////
// PopupEdit.js                                                                                 //
//                                                                                              //
// Description:                                                                                 //
//  Routines for the parent for simulating modal dialogs with a popup browser window.           //
//  Routines for the dialog window itself are in PopupModalDialog.js                            //
//                                                                                              //
// Notes:                                                                                       //
//  The following statements should be placed in the opening body tag of the HTML page.         //
//    onUnload  = "CleanUp();"                                                                  //
//    onFocus   = "GotFocus();"                                                                 //
//    onBlur    = "LostFocus();"                                                                //
//                                                                                              //
//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////
// Global Variables //
//////////////////////
var winDialog;                      // reference to the popup child dialog
var bDialogOpen = false;            // boolean to indicate if a dialog is open
var bGotFocus = false;              // indicates if the parent window has focus
var lngSessionID;                   // a unique identifier, used to provide the popup child with a unique name
var bTopLevelWindow = false;        // specifies whether this is the top level window or not
                                    // this is needed to provide special handling in the case that
                                    // the window opening the dialog is an embedded frame.  This
                                    // file needs to be included in the top level frame.
var descx = 100;                    // x coordinate of window to popup
var descy = 100;                    // y coordinate of window to popup

////////////////////////
// Global statements  //
////////////////////////
lngSessionID = Math.round(Math.random() * 1000);

setInterval("CheckStatus()", 500);  //Check the status every 500 ms

//Requires that browsercheck is included
///////////////////////////////////////////////////////////////////////////////////////////////////////////

  var bc = new BrowserCheck();
  var n = bc.ns;
  var ie = bc.ie;


document.onmousemove = MouseClick;

////////////////////////////////////////////////////////////////////////////////////////////////////
// MouseClick()                                                                                   //
//                                                                                                //
// Description:  Get the coordinates of mouse clicks.  Used so popups appear where the mouse was  //
//               clicked.                                                                         //
////////////////////////////////////////////////////////////////////////////////////////////////////
function MouseClick(e) {
    var evtobj = window.event ? event : e
    descx = n ? evtobj.layerX : evtobj.x;
    descy = n ? evtobj.layerY : evtobj.y;
  
    descx = descx + window.screenLeft;
    descy = descy + window.screenTop; 
}
////////////////////////////////////////////////////////////////////////////////////////////////////
// CheckStatus()                                                                                  //
//                                                                                                //
// Description:                                                                                   //
//  Checks the status of the child dialog window.  Set the boolean which indicates if the child   //
//  window is currently open or not.  (Checking the window reference or window.closed is not      //
//  sufficient if windows can open/close multiple times.                                          //
////////////////////////////////////////////////////////////////////////////////////////////////////
function CheckStatus() {
  if (winDialog) {
    if (winDialog.closed) {
      bDialogOpen = false;
    } 
    else 
      bDialogOpen = true;
  } 
  else 
    bDialogOpen = false;
    
   
}
////////////////////////////////////////////////////////////////////////////////////////////////////
// OpenDialogWindow(strHref, strOptions)()                                                        //
//                                                                                                //
// Description:                                                                                   //
//  Checks the status of the child dialog window.  Set the boolean which indicates if the child   //
//  window is currently open or not.  (Checking the window reference or window.closed is not      //
//  sufficient if windows can open/close multiple times.                                          //
//  If strOptions isn't blank, those options will be used instead of the default.                 //
////////////////////////////////////////////////////////////////////////////////////////////////////
function OpenDialogWindow(strHref, strOptions) {

  // if a popup is already open, alert the user and switch the focus
  if (bDialogOpen) {
    alert('A Dialog Window is already open!');
    winDialog.focus();

  
  //Otherwise, open the window and use the user options if specified
  } else {

//    alert('Before: ' + strHref);
    strHref = EncodeURLArgs(strHref);
//    alert('After: ' + strHref);
    if(strOptions == '')
      winDialog = window.open(strHref, 'Dialog' + lngSessionID, 'left=' + descx + ',top=' + descy + ',height=100,width=100,resizable=yes,scrollbars=yes');
    else
      winDialog = window.open(strHref, 'Dialog' + lngSessionID, strOptions);

    bDialogOpen = true;
  }
}
////////////////////////////////////////////////////////////////////////////////////////////////////
// EncodeURLArgs(strHref)                                                                         //
//                                                                                                //
// Description:                                                                                   //
// URL Encodes parameters passed over the url.                                                    //
////////////////////////////////////////////////////////////////////////////////////////////////////
function EncodeURLArgs(strHref){
  var strNewHref;
  var strTemp;
  var strArg;
  var intIndex = -1;
  var intNextIndex = -1;
  var bFirst = true;
  
  //Get the first part of the url
  intIndex = strHref.indexOf('?');
  
  //If no parameters, return the input
  if(intIndex <= 0)
    return(strHref);
  
  strNewHref = strHref.substring(0, intIndex) + '?';
  
  intNextIndex = strHref.indexOf('&', intIndex + 1);

  if(intNextIndex <= 0)
  {
    strArg = escape(strHref.slice(intIndex + 1));
    strArg = strArg.replace(escape('='), '=');
    return(strNewHref + strArg);
  }
  
  //process the next part
  while(intIndex > 0)
  {
    //Get the next &
    intNextIndex = strHref.indexOf('&', intIndex + 1);
    
    if(intNextIndex > 0)
      strTemp = strHref.substring(intIndex + 1, intNextIndex);
    else 
      strTemp = strHref.slice(intIndex + 1);
     
    //if not the first time through, prepend the &
    if(bFirst)  
      strArg = escape(strTemp);
    else
      strArg = '&' + escape(strTemp);
      
    //reset variable
    bFirst = false; 

    strArg = strArg.replace(escape('='), '=');

    strNewHref = strNewHref + strArg;
    
    intIndex = intNextIndex;    
  }
  
  strNewHref = strNewHref.replace(/__AMPERSAND__/, escape('&'));

  return(strNewHref);

}
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
// Utility Functions, setting focus, etc.                                                         //
////////////////////////////////////////////////////////////////////////////////////////////////////
function GotFocus() {
//  alert('Got Focus');
  bGotFocus = true;
}
      
////////////////////////////////////////////////////////////////////////////////////////////////////
      
function LostFocus() {
  bGotFocus = false;
//  alert('Lost Focus');
}

////////////////////////////////////////////////////////////////////////////////////////////////////      

function CleanUp() {
  if(winDialog && !winDialog.closed) {
      winDialog.close()
      bDialogOpen = false;
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////      
// Return the state of this window's focus
function GetFocusStatus() {
  return(bGotFocus);    
}
