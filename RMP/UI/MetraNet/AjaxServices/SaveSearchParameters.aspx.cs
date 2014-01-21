using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;

using MetraTech.BusinessEntity.Service.ClientProxies;
using MetraTech.UI.Common;
using Core.UI;
using Core.UI.Interface;
using MetraTech.BusinessEntity.DataAccess.Metadata;

public partial class AjaxServices_SaveSearchParameters : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    //prepare the service client
    var client = new RepositoryService_SaveInstance_Client();
    client.UserName = UI.User.UserName;
    client.Password = UI.User.SessionPassword;

    SavedSearch savedSearch = new SavedSearch();

    string searchName = Request["search_name"];
    string pageURL = Request["page_url"];
    string gridID = Request["grid_id"];
    string description = Request["description"];
    string searchLayout = Request["search_layout"];

    savedSearch.Name = searchName;
    savedSearch.Description = description;
    savedSearch.PageUrl = pageURL;
    savedSearch.GridId = gridID;
    savedSearch.SearchLayout = searchLayout;
    savedSearch.CreatedDate = DateTime.Now;
    savedSearch.CreatedBy = UI.User.AccountId;

    client.InOut_dataObject = savedSearch;
    try
    {
      client.Invoke();
    }
    catch (Exception ex)
    {
      Response.Write("Error processing request. " + ex.Message);
      return;
    }
    
    int filterID = 0;
    while (!String.IsNullOrEmpty(Request["filter[" + filterID.ToString() + "][field]"]))
    {
      string propertyName = Request["filter[" + filterID + "][field]"];
      if (String.IsNullOrEmpty(propertyName))
      {
        continue;
      }

      string op = Request["filter[" + filterID + "][operation]"];
      if (string.IsNullOrEmpty(op))
      {
        op = "eq";
      }

      string visible = Request["filter[" + filterID + "][visible]"];
      string value = Request["filter[" + filterID + "][data][value]"];
      string dataType = this.Request["filter[" + filterID.ToString() + "][data][type]"];
      string position = Request["filter[" + filterID + "][position]"];
      if (string.IsNullOrEmpty(position))
      {
        position = "0";
      }
      /*
      if (!String.IsNullOrEmpty(dataType) && (dataType.ToLower() == "date"))
      {
        DateTime tmpDate;
        if (DateTime.TryParse(value.ToString(), out tmpDate))
        {
          value = tmpDate.ToString();
        }
      }
      */

      string value2 = Request["filter[" + filterID + "][data][value2]"];

      //create new filter
      var searchFilter = new SearchFilter();
      searchFilter.Name = propertyName;
      searchFilter.Value = value;
      searchFilter.Value2 = value2;
      searchFilter.IsVisible = (string.IsNullOrEmpty(visible) || (visible.ToLower() != "true")) ? false : true;
      searchFilter.Operation = op;
      searchFilter.Position = int.Parse(position);
      savedSearch.SearchFilters.Add(searchFilter);

      filterID++;
    }

    var clientFilter = new RepositoryService_CreateInstancesFor_Client();

    clientFilter.In_forEntityId = client.InOut_dataObject.Id;
    clientFilter.In_forEntityName = typeof(SavedSearch).FullName;
    clientFilter.UserName = UI.User.UserName;
    clientFilter.Password = UI.User.SessionPassword;

    List<DataObject> dataObjects = new List<DataObject>();
    foreach (ISearchFilter searchFilter in savedSearch.SearchFilters)
    {
      dataObjects.Add(searchFilter as DataObject);
    }
    clientFilter.InOut_dataObjects = dataObjects;

    try
    {
      clientFilter.Invoke();
    }
    catch (Exception ex)
    {
      Response.Write("Error processing request. " + ex.Message);
      return;
    }
    Response.Write("OK");
  }
}
