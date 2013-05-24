using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.SecurityFramework;

namespace WebApplication1
{
  public partial class SiteMaster : System.Web.UI.MasterPage
  {
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void HeadLoginStatus_LoggingOut(object sender, EventArgs e)
    {
      SecurityKernel.SecurityMonitor.Api.ReportLogout();
    }


  }
}
