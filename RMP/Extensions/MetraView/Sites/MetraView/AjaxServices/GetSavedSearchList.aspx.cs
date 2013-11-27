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

using MetraTech.ActivityServices.Common;
using System.Web.Script.Serialization;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using System.Text.RegularExpressions;
using Core.UI;

public partial class AjaxServices_GetSavedSearchList : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    string pageURL = Request["PageUrl"];
    pageURL = RepackURL(pageURL, "SavedSearchID=");
    string gridID = Request["GridID"];
    string searchLayout = Request["SearchLayout"];

    //prepare the service client
    var client = new RepositoryService_LoadInstances_Client();

    client.UserName = UI.User.UserName;
    client.Password = UI.User.SessionPassword;

    client.In_entityName = typeof(SavedSearch).FullName; 

    MTList<DataObject> items = new MTList<DataObject>();
    items.Filters.Add(new MTFilterElement("CreatedBy", MTFilterElement.OperationType.Equal, UI.SessionContext.AccountID));

    if (!string.IsNullOrEmpty(pageURL))
    {
      items.Filters.Add(new MTFilterElement("PageUrl", MTFilterElement.OperationType.Equal, pageURL));
    }

    if (!string.IsNullOrEmpty(gridID))
    {
      items.Filters.Add(new MTFilterElement("GridId", MTFilterElement.OperationType.Equal, gridID));
    }

    if (!string.IsNullOrEmpty(searchLayout))
    {
      items.Filters.Add(new MTFilterElement("SearchLayout", MTFilterElement.OperationType.Equal, searchLayout));
    }
    items.SortCriteria.Add(new SortCriteria("CreatedDate", SortType.Descending));

    client.InOut_dataObjects = items;

    try
    {
      client.Invoke();
    }
    catch (Exception ex)
    {
      Response.Write("Error processing request. " + ex.Message);
      return;
    }

    JavaScriptSerializer jss = new JavaScriptSerializer();
    string json = jss.Serialize(client.InOut_dataObjects);

    json = FixJsonDate(json);
    Response.Write(json);
  }

  protected string FixJsonDate(string input)
  {
    MatchEvaluator me = new MatchEvaluator(MTListServicePage.MatchDate);
    string json = Regex.Replace(input, "\\\\/\\Date[(](-?\\d+)[)]\\\\/", me, RegexOptions.None);

    return json;
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
}

