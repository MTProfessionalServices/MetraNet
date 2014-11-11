using System;
using MetraTech.UI.Common;

namespace MetraNet.MetraControl.ScheduledAdapters
{
  public partial class RunScheduledAdapter : MTPage
  {
    protected void Page_Load(object sender, EventArgs e)
    {
      if (!UI.CoarseCheckCapability("Manage Scheduled Adapters"))
      {
        Response.End();
      }
    }
  }
}