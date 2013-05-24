using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;

namespace MetraTech.UI.MetraNet.App_Code
{
  /////////////////////////////////////////////////////////////////////////////////////
  // The code here in MTClientSidePage.cs, in conjunction with the code in
  // Source/MetraTech/UI/Res/JavaScript/MonitorPageChanges.js,
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

  public class MTClientSidePage : MTPage
  {
      #region Methods for Prompting the User to Save Before Leaving the Page
    
  
      // Adds the specified control to two client-side arrays:
      // (1) MPC_monitorChangesIDs, which contains the client-side IDs of the input form fields to watch, and
      // (2) MPC_monitorChangesValues, which contains the initial values of those form fields.
      protected void MonitorChangesInControl(WebControl wc)
      {
        if (wc == null)
        {
          return;
        }

        if (wc is CheckBoxList || wc is RadioButtonList)
        {
          for (int i = 0; i < ((ListControl)wc).Items.Count; i++)
          {
            ClientScript.RegisterArrayDeclaration("MPC_monitorChangesIDs", "\"" + string.Concat(wc.ClientID, "_", i.ToString()) + "\"");
            ClientScript.RegisterArrayDeclaration("MPC_monitorChangesValues", "null");
          }
        }
        else
        {
          ClientScript.RegisterArrayDeclaration("MPC_monitorChangesIDs", string.Concat("\"", wc.ClientID, "\""));
          ClientScript.RegisterArrayDeclaration("MPC_monitorChangesValues", "null");
        }
      }

      // Adds the specified client id to two client-side arrays:
      // (1) MPC_monitorChangesIDs, which contains the client-side IDs of the input form fields to watch, and
      // (2) MPC_monitorChangesValues, which contains the initial values of those form fields.
      protected void MonitorChangesInControlByClientId(String clientId)
      {
        if (String.IsNullOrEmpty(ClientID))
        {
          return;
        }

        ClientScript.RegisterArrayDeclaration("MPC_monitorChangesIDs", string.Concat("\"", clientId, "\""));
        ClientScript.RegisterArrayDeclaration("MPC_monitorChangesValues", "null");
      }

    // Indicates that a change in the contents of the specified control
      // should NOT cause the confirmation popup to be displayed.
      protected void IgnoreChangesInControl(MTButton button)
      {
        button.OnClientClick = "MPC_setNeedToConfirm(false);" + button.OnClientClick;
      }


      #endregion

  } // MTClientSidePage
}
