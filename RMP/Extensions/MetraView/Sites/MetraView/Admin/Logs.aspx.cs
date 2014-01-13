using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;

public partial class Admin_Logs : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    if(!UI.CoarseCheckCapability("MetraView Admin"))
    {
      Response.Write(Resources.ErrorMessages.ERROR_ACCESS_DENIED);
      Response.End();
    }
  }
}
