using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;

public partial class Help : System.Web.UI.Page
{
  protected void Page_Load(object sender, EventArgs e)
  {
    Response.Redirect(Session[Constants.HELP_PAGE].ToString());
  }
}
