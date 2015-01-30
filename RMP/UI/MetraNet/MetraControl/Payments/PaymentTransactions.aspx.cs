using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;

public partial class MetraControl_Payments_PaymentTransactions : MTPage
{

  protected void Page_Load(object sender, EventArgs e)
  {
    //Extra check that user has permission to work with paymenttransactions
    //Eventually would be good to move this to configuration
    if (!UI.CoarseCheckCapability("Manage Payment Server"))
      Response.End();
  }

  protected override void OnLoadComplete(EventArgs e)
  {
  
   // SetDefaultFilterFromQueryString(FailedTransactionList);

    base.OnLoadComplete(e);
  }

}