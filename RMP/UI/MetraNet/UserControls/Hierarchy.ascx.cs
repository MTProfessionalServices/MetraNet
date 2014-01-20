using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MetraTech;
using MetraTech.UI.Common;

public partial class UserControls_Hierarchy : System.Web.UI.UserControl
{
  private string mStartAccountType;
  public string StartAccountType
  {
    get { return mStartAccountType; }
    set { mStartAccountType = value; }
  }

  public string MetraTimeToday
  {
    get { return ((MTPage)Page).ApplicationTime.ToShortDateString(); }
  }
	
  protected void Page_Load(object sender, EventArgs e)
  {

  }
}
