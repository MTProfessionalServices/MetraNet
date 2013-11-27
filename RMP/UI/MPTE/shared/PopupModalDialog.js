//////////////////////////////////////////////////////////////////////////////////////////////////
// PopupModalDialog.js                                                                          //
//                                                                                              //
// Description:                                                                                 //
//  Routines for the simulated modal browser-based dialog window.                               //
//  Routines for the parent are in PopupEdit.js                                                 //
//                                                                                              //
// Notes:                                                                                       //
//  The following statements should be placed in the opening body tag of the HTML page.         //
//    onFocus   = "GotFocus('window');" (including the text 'window')                           //
//    onBlur    = "LostFocus();"                                                                //
//    (optionally) onLoad = "SizeWindow();" to resize the window appropriately                  //
//                                                                                              //
//  Forms should call InAForm('formName') in their onClick handler.                             //
//                                                                                              //
//  The following is not fully implemented.  It is intended to set the focus to the correct     //
//  form element when bringing focus back to the dialog.                                        //
//                                                                                              //
//  Form elements should set the following handlers:                                            // 
//    onBlur  = LostFocus();                                                                    //
//    onFocus = GotFocus('elementName');                                                        //
//////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////
// Global Variables //
//////////////////////
var bInForm = false;              //indicates the focus is on a form element
var bWinHasFocus = false;         //indicates the focus is on the main window
var strFocus = 'undefined';       //contains the name of the form element that has focus
var strFormName = 'undefined';    //the name of the form with focus
      
///////////////////////
// Global Statements //
///////////////////////
setInterval("CheckFocus()", 50);  //update the focus every 1/2 second


//////////////////////////////////////////////////////////////////////////////////////////////////
// SizeWindow()                                                                                 //
//                                                                                              //
//  Description:                                                                                //
//    Adjust the size of the dialog window to reflect the size of the document.  It should be   //
//    called on onLoad of the document, and whenever divs & spans are hidden and revealed.      //
//    (Not yet tested with divs)                                                                //
//////////////////////////////////////////////////////////////////////////////////////////////////
function SizeWindow() {
  var intX = 0, intY = 0;
  var posX = 0, posY = 0;
  var b = new BrowserCheck();
  
  //Get the dimensions of the document
  if(b.ie) {
    intX = document.body.scrollWidth + 40;
    intY = document.body.scrollHeight + 40;
  }
  
  if(b.ns) {
    intX = document.width;
    intY = document.height;
  }
  
  
  //Resize if sizes are valid
//  alert('x: ' + intX + '  y: ' + intY);
  //We don't know what browser we're in, don't resize
  if(intX == 0 && intY == 0)
    return false;
  
  //100x100 is the smallest allowable in Netscape...we'll use that as a guideline, regardless of browser
  if(intX < 100)
    intX = 100;
  
  if(intY < 100)
    intY = 100;
    
  // center the window in the screen
  posX = (window.screen.width - intX)/2 ;
  if ( posX < 0 ) posX = 0;

  posY = (window.screen.height - intY)/2 ;
  if ( posY < 0 ) posY = 0;

//  alert('x: ' + intX + '  y: ' + intY);
  //now move and resize the window
  window.moveTo(posX, posY);
  window.resizeTo(intX, intY);
}
    
//////////////////////////////////////////////////////////////////////////////////////////////////
// CheckFocus                                                                                   //
//                                                                                              //
//  Description:                                                                                //
//    Update the dialog window's focus to keep it on top when it or the parent window has focus //
//////////////////////////////////////////////////////////////////////////////////////////////////
function CheckFocus() {
  //Check to see if we're in a form
//  alert('bWin: ' + bWinHasFocus +  ' Get: ' + window.opener.GetFocusStatus());
  if(!bWinHasFocus && window.opener && window.opener.GetFocusStatus()) {
    //set the focus to the form element that last had focus
    if(bInForm) {
      eval('window.' + strFormName + '.' + strFocus + '.focus();');
      bWinHasFocus = true;
    } else {
      eval('window.focus();');
      bWinHasFocus = true;
    }
  }
}
      
//////////////////////////////////////////////////////////////////////////////////////////////////
// Utility Functions, setting focus                                                             //
//////////////////////////////////////////////////////////////////////////////////////////////////
function OutOfForm() {
  bInForm = false;
}

//////////////////////////////////////////////////////////////////////////////////////////////////
      
function InAForm(strForm) {
  strFormName = strForm
  bInForm = true;
}

//////////////////////////////////////////////////////////////////////////////////////////////////       

function LostFocus() {
  bWinHasFocus = false;
}

//////////////////////////////////////////////////////////////////////////////////////////////////      

function GotFocus(strNewFocus) {
  if(strNewFocus == 'window')
    bInForm = false;
          
  strFocus = strNewFocus;
        
  bWinHasFocus = true;
  
}
      
