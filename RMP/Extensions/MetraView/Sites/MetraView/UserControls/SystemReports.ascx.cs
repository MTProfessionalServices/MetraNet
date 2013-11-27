using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text;
using MetraTech.ActivityServices.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using Core.UI;
using MetraTech.UI.Common;
using MetraTech.BusinessEntity.Service.ClientProxies;
using MetraTech;
using System.ServiceModel;

public partial class UserControls_SystemReports : System.Web.UI.UserControl
{
  private MetraTech.Logger mtLog = new Logger("[SystemReportsControl]");
  private int maxDisplayItems = 5;
  public int MaxDisplayItems
  {
    get { return maxDisplayItems; }
    set { maxDisplayItems = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      GetReportList();
    }
  }
  public UIManager UI
  {
    get { return ((MTPage)Page).UI; }
  }
  public string GetReportList()
  {
    StringBuilder sb = new StringBuilder();
    var client = new RepositoryService_LoadInstances_Client();

    try
    {
      client.UserName = UI.User.UserName;
      client.Password = UI.User.SessionPassword;
      client.In_entityName = typeof(ReportInventory).FullName;
      client.InOut_dataObjects = new MTList<DataObject>();
      client.Invoke();
    }
    catch (FaultException<MASBasicFaultDetail> ex)
    {
      mtLog.LogError("Error retrieving report list:" + ex.Detail.ErrorMessages[0]);
    }
    catch (CommunicationException ex)
    {
      mtLog.LogException("Error retrieving report list", ex);
    }
    catch (Exception ex)
    {
      mtLog.LogException("Error retrieving report list", ex);
    }
    MTList<DataObject> reports = client.InOut_dataObjects;

    if (reports.Items.Count == 0)
    {
      sb.Append(Resources.Resource.TEXT_NO_RECORDS_FOUND);
      return sb.ToString();
    }

    sb.Append("<ul class='bullets'>");

    int i = 0;
    foreach (ReportInventory report in reports.Items)
    {
      if (i > maxDisplayItems)
      {
        break;
      }
      sb.Append(string.Format("<li><a href='{0}'>{1}</a></li>",
        SiteConfig.GetVirtualFolder() + "/Reports/GenericReport.aspx?ReportID=" + report.Id,
        report.ReportInventoryBusinessKey.Name));

      i++;
    }

    sb.Append("</ul>");

    if (client.InOut_dataObjects.Items.Count > maxDisplayItems)
    {
      sb.Append(string.Format("<a href='{0}'>{1}</a></li>",
        SiteConfig.Settings.RootUrl + "/Usage.aspx", Resources.Resource.TEXT_MORE_ITEMS));
    }

    return sb.ToString();
  }
}
