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
using System.Collections.Generic;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.ActivityServices.Common;
using System.Web.Script.Serialization;


public partial class AjaxServices_LoadSavedSearch : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    string searchID = Request["SavedSearchID"];
    if (string.IsNullOrEmpty(searchID))
    {
      Response.Write("Bad Search ID");
      Response.End();
    }
    var client = new RepositoryService_LoadInstancesFor_Client();

    client.UserName = UI.User.UserName;
    client.Password = UI.User.SessionPassword;
    client.In_entityName = typeof(SearchFilter).FullName;
    client.In_forEntityId = new Guid(searchID);
    client.In_forEntityName = typeof(SavedSearch).FullName;

    var inList = new MTList<DataObject>();
    inList.SortCriteria.Add(new SortCriteria("Position", SortType.Ascending));
    client.InOut_mtList = new MTList<DataObject>();

    try
    {
      client.Invoke();
    }
    catch (Exception ex)
    {
      Response.Write("Error processing request. " + ex.Message);
      return;
    }

    var filters = client.InOut_mtList;

    JavaScriptSerializer jss = new JavaScriptSerializer();
    string json = jss.Serialize(filters);

    Response.Write(json);
  }
}
