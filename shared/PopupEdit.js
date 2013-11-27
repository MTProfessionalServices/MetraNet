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

var descx = 100;                    // x coordinate of window to popup
var descy = 100;                    // y coordinate of window to popup

var bc = new BrowserCheck();                //browser check object
var n = bc.ns;
var ie = bc.ie;

      
////////////////////////
// Global statements  //
////////////////////////
setInterval("CheckStatus()", 500);  //Check the status every 500 ms


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
	
    if(strOptions == '')
      winDialog = window.open(strHref, 'Dialog', 'left=' + descx + ',top=' + descy + ',height=100,width=100,resizable=yes,scrollbars=yes');
    else
      winDialog = window.open(strHref, 'Dialog', strOptions);

    bDialogOpen = true;
  }
}
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
// Utility Functions, setting focus, etc.                                                         //
////////////////////////////////////////////////////////////////////////////////////////////////////
function GotFocus() {
  bGotFocus = true;
}
      
////////////////////////////////////////////////////////////////////////////////////////////////////
      
function LostFocus() {
  bGotFocus = false;
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
  return bGotFocus;
}
