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
using MetraTech.BusinessEntity.DataAccess.Metadata;
using Core.UI;

public partial class AjaxServices_DeleteSavedSearch : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    var client = new RepositoryService_DeleteInstanceUsingEntityName_Client();
    client.UserName = UI.User.UserName;
    client.Password = UI.User.SessionPassword;
    string deleteID = Request["delete"];
 
    Guid guidID = new Guid(deleteID);
    client.In_entityName = typeof(SavedSearch).FullName;
    client.In_id = guidID;

    try
    {
      client.Invoke();
    }
    catch (Exception ex)
    {
      Response.Write("Error processing request. " + ex.Message);
      return;
    }

    Response.Write("OK");
  }
}
