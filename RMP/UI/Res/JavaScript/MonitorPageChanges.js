/////////////////////////////////////////////////////////////////////////////////////
// The code here in MonitorPageChanges.js, in conjunction with the code in
// Source/MetraTech/UI/MetraNet/App_Code/MTClientSidePage.cs,
// provides a way for ASP.NET pages to specify what controls on the page
// should be monitored for changes.  If the user navigates away from the
// page when changed data on the page has not been saved, he will be
// warned with a popup that offers the options to leave the page
// (losing unsaved changes) or to stay on the current page.
//
// A page that includes MonitorPageChanges.js may define a function
// called MPC_executeBeforePopup().  If that function is defined,
// it is called right before displaying a popup that warns the user that
// his changes will be lost if he navigates away from the current page.
//
// (Source: This code is adapted from an article entitled 
// "Using ASP.NET to Prompt a User to Save When Leaving a Page"
// by Scott Mitchell (http://www.4guysfromrolla.com/articles/101304-1.aspx).
// That article describes an extended Page class that contains methods
// to inject client-side JavaScript, which prompts the user to confirm
// leaving a page when data on the page has been changed (and will be lost).)
/////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////
// Private variables used internally on this page:

// Contains the IDs of the monitored controls on the page.
var MPC_monitorChangesIDs = new Array();

// Contains the initial values of the monitored controls on the page.
var MPC_monitorChangesValues = new Array();

// Indicates whether we should display a confirmation popup
// if the user has chosen to leave the page when the page
// contents have changed.  (Defaults to true.)
var MPC_bNeedToConfirm = true;
/////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////
// Public functions that can be called from ASP.NET pages:

// Fills the elements of the MPC_monitorChangesValues array with
// the contents of the page's controls (identified by the
// elements of MPC_monitorChangesIDs).
function MPC_assignInitialValues()
{
  for (var i = 0; i < MPC_monitorChangesIDs.length; i++) {
    var elem = document.getElementById(MPC_monitorChangesIDs[i]);
    if (elem) 
    {
      if (elem.type == 'checkbox' || elem.type == 'radio') 
      {
        MPC_monitorChangesValues[i] = elem.checked;
      }
      else 
      {
        MPC_monitorChangesValues[i] = elem.value;
      }
    } // if (elem)
  } // for
}


// Sets the MPC_bNeedToConfirm flag to the specified value.
function MPC_setNeedToConfirm(value) 
{
  MPC_bNeedToConfirm = value;
}


// Consults the MPC_monitorChangesXX arrays and returns a nonempty string 
// if any of the field's values have changed.  This causes Windows to
// display a popup asking the user to confirm leaving the page (and
// losing those changes).
function MPC_confirmClose() 
{
  if (!MPC_bNeedToConfirm) 
  {
    return;
  }

  for (var i = 0; i < MPC_monitorChangesValues.length; i++) 
  {
    var elem = document.getElementById(MPC_monitorChangesIDs[i]);
    if (elem)
    {
      if (((elem.type == 'checkbox' || elem.type == 'radio') && elem.checked != MPC_monitorChangesValues[i]) || 
          (elem.type != 'checkbox' && elem.type != 'radio' && elem.value != MPC_monitorChangesValues[i]))
      {
        // Set MPC_bNeedToConfirm to false for 750 msecs to prevent a second popup
        // from appearing in the case of JavaScript in a hyperlink causing
        // the page to unload a second time.  (See the article referenced at
        // the top of this file.)
        MPC_bNeedToConfirm = false;
        setTimeout('MPC_setNeedToConfirm(true)', 750);

        // If the page has defined a function called MPC_executeBeforePopup(),
        // call it now, right before displaying a popup that warns the user that
        // his changes will be lost if he navigates away from the current page.
        if (typeof MPC_executeBeforePopup == 'function') {
          MPC_executeBeforePopup();
        }

        // Return nonempty string to cause warning popup to be displayed to user.
        return TEXT_WILL_LOSE_CHANGES;
      }
    } // if (elem)
  } //for
} // MPC_confirmClose


// When the page is about to be unloaded, check if the contents
// of the controls on the page have changed.
window.onbeforeunload = MPC_confirmClose;

/////////////////////////////////////////////////////////////////////////////////////
