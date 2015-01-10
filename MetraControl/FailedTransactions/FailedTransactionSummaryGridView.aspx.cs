using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using MetraTech.UI.Common;

public partial class FailedTransactionSummaryGridView : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    //Extra check that user has permission to work with failed transactions
    //Eventually would be good to move this to configuration
    if (!UI.CoarseCheckCapability("Update Failed Transactions"))
      Response.End();
  }
}
