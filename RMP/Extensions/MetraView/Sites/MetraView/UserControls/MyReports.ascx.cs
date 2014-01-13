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
using MetraTech.BusinessEntity.Service.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.UI.Common;
using System.Text;
using Core.UI;
using System.ServiceModel;
using MetraTech;

public partial class UserControls_My_Reports : System.Web.UI.UserControl
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

  }

  public string GetReportList()
  {
    if (!SiteConfig.Settings.BillSetting.AllowSavedReports.GetValueOrDefault(false))
      return "";

    StringBuilder sb = new StringBuilder();

    var client = new RepositoryService_LoadInstances_Client();

    client.UserName = UI.User.UserName;
    client.Password = UI.User.SessionPassword;

    client.In_entityName = typeof(SavedSearch).FullName;
    MTList<DataObject> items = new MTList<DataObject>();
    items.Filters.Add(new MTFilterElement("CreatedBy", MTFilterElement.OperationType.Equal, UI.SessionContext.AccountID));
    items.SortCriteria.Add(new SortCriteria("CreatedDate", SortType.Descending));

    client.InOut_dataObjects = items;

    try
    {
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

    if (client.InOut_dataObjects.Items.Count == 0)
    {
      return Resources.ErrorMessages.ERROR_NO_REPORTS_FOUND;
    }

    sb.Append("<ul class='bullets'>");
    int maxDisplay = maxDisplayItems;
    foreach (SavedSearch ss in client.InOut_dataObjects.Items)
    {
      if (maxDisplay <= 0)
      {
        break;
      }
      maxDisplay--;

      string formattedURL = ss.PageUrl;

      if (formattedURL.Contains("SavedSearchID="))
      {
        formattedURL = RepackURL(formattedURL, "SavedSearchID=");
      }

      //append seaved search ID to URL
      if (formattedURL.Contains("?"))
      {
        formattedURL += "&SavedSearchID=" + ss.Id;
      }
      else
      {
        formattedURL += "?SavedSearchID=" + ss.Id;
      }

      sb.Append(string.Format("<li><a href='{0}'>{1}</a></li>",
        formattedURL, ss.Name));
    }

    sb.Append("</ul>");

    if (client.InOut_dataObjects.Items.Count > maxDisplayItems)
    {
      sb.Append(string.Format("<a href='{0}'>{1}</a></li>",
        SiteConfig.Settings.RootUrl + "/Reports/MyReports.aspx", Resources.Resource.TEXT_MORE_ITEMS));
    }
    
    return sb.ToString();

  }
  private string RepackURL(string formattedURL, string pattern)
  {
    string repackedURL;

    if (!formattedURL.Contains(pattern))
    {
      return formattedURL;
    }

    int start = formattedURL.IndexOf(pattern);
    int end = formattedURL.IndexOf("&", start);
    if (end < 0)
    {
      repackedURL = formattedURL.Substring(0, start);
      if (repackedURL.EndsWith("?") || repackedURL.EndsWith("&"))
      {
        repackedURL = repackedURL.Substring(0, repackedURL.Length - 1);
      }
      return repackedURL;
    }
    //else, pattern is followed with another parameter
    repackedURL = formattedURL.Substring(0, start);
    repackedURL += formattedURL.Substring(end + 1, formattedURL.Length - end - 1);

    return repackedURL;

  }
  public UIManager UI
  {
    get { return ((MTPage)Page).UI; }
  }

}
