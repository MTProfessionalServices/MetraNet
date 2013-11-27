using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Xml.Linq;
using MetraTech.UI.Common;
using MetraTech.BusinessEntity.Service.ClientProxies;
using Core.UI;
using MetraTech.UI.Controls;

public partial class GenericReport : MTPage
{
  private ReportInventory report = null; 
  protected override void OnLoadComplete(EventArgs e)
  {
    MyGrid1.Title = report.ReportInventoryBusinessKey.Name;
    MyGrid1.Expandable = false;
    foreach (MTGridDataElement elt in MyGrid1.Elements)
    {
      elt.HeaderText = elt.DataIndex;
      elt.IsIdentity = true;
      if (elt.ID.Contains(" "))
      {
        elt.ID = elt.ID.Replace(" ", "%20");
      }
    }

  }
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      try
      {
        var client = new RepositoryService_LoadInstance_Client();

        client.UserName = UI.User.UserName;
        client.Password = UI.User.SessionPassword;
        client.In_entityName = typeof (Core.UI.ReportInventory).FullName;
        client.In_id = new Guid(Request["ReportID"]);

        client.Invoke();

        report = client.Out_dataObject as ReportInventory;

        MyGrid1.TemplateFileName = report.LayoutName;
        MyGrid1.ExtensionName = report.LayoutExtensionName;
      }
      catch (Exception)
      {
        Response.Write(Resources.Resource.TEXT_PAGE_ERROR);
        Response.End();
      }
    }
  }
}
