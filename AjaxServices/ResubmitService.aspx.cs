using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.ActivityServices.Common;
using MetraTech.DataAccess;
using MetraTech.Debug.Diagnostics;
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;

public partial class AjaxServices_ResubmitService : MTListServicePage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    Session["SelectedIDs"] = this.Request["SelectedIDs"];
    var result = new AjaxResponse();
    result.Success = true;
    result.Message = String.Format("Selected {0} items.", this.Request["_TotalRows"]);
    Response.Write(result.ToJson());
    Response.End();
  }
}