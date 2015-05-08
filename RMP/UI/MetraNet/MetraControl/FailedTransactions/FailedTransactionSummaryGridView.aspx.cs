using System;

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
