using System;
using System.Diagnostics;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Workflow.Runtime;
using System.Workflow.Activities;
using System.Workflow.ComponentModel;
using System.Threading;

using MetraTech.UI.Common;

public partial class welcome : MTPage
{

  public string TopPadding
  {
    get 
    {
      if (UI != null)
      {
        if (UI.Subscriber.SelectedAccount != null)
        {
          return "25";
        }
      }

      return "0";
    }
  }
	
  protected void Page_Load(object sender, EventArgs e)
  {
    //Debugger.Launch();
  }

  /// <summary>
  ///   
  /// </summary>
  /// <param name="sender"></param>
  /// <param name="e"></param>
  protected void OkBtn_Click(object sender, EventArgs e)
  {
  }

}
