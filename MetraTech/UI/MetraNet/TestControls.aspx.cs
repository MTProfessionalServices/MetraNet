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

using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel;

public partial class TestControls : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    MTDatePicker2.Text = ApplicationTime.ToShortDateString();
    if (!IsPostBack)
    {
      tbAlpha.Text = "hello";
      ddBlank.SelectedValue = "b";
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    Response.Write(tbAlpha.Text);
    Response.Write(ddBlank.SelectedValue);
    Response.Write(cb1.Checked.ToString());
    Response.Write(cb2.Checked.ToString());
  }
}