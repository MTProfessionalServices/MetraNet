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
using System.Text;
using System.Reflection;
using System.Collections.Generic;

using MetraTech.UI.Common;
using MetraTech;
using MetraTech.DataAccess;
using MTAuth = MetraTech.Interop.MTAuth;
using MTYAAC = MetraTech.Interop.MTYAAC;
using Rowset = MetraTech.Interop.Rowset;
using MTCol = MetraTech.Interop.GenericCollection;
using MetraTech.UI.Tools;
using MetraTech.DomainModel.Common;
using MetraTech.Interop.Rowset;
using MetraTech.DomainModel.AccountTypes;
using System.IO;

public partial class AjaxServices_FindAccount : MTPage
{

  

  protected void PopulateColumns(MTYAAC.IMTCollection columns)
  {
    CoreSubscriber csa = new CoreSubscriber();
    List<PropertyInfo> propList = csa.GetProperties();
    AddColumn(propList, columns); 

    ContactView cv = new ContactView();
    propList = cv.GetProperties();
    AddColumn(propList, columns);
  }

  private void AddColumn(List<PropertyInfo> propList, MTYAAC.IMTCollection columns)
  {

    foreach (PropertyInfo pi in propList)
    {
      if ((pi.PropertyType.BaseType.Name == "ValueType") || ((pi.PropertyType.BaseType.Name.ToLower() == "object") && (pi.PropertyType.Name == "String")))
      {
        string propName = pi.Name;
        if ((propName.ToLower() == "applydefaultsecuritypolicy") || (propName.ToLower() == "password_"))
        {
          continue;
        }

        columns.Add(pi.Name);
      }
    }
  }

  //Append all filters from the Ext Grid
  protected void AppendFilters(Rowset.IMTDataFilter filter)
  {
    int i = 0;
    string fieldName = Request["filter[" + i.ToString() + "][field]"];
    string operation = String.Empty;
    string type = String.Empty;
    string value = String.Empty;

    while (!String.IsNullOrEmpty(fieldName))
    {
      //extract the value, type, and comparison operator
      value = Request["filter[" + i.ToString() + "][data][value]"];
      type = Request["filter[" + i.ToString() + "][data][type]"];
      operation = Request["filter[" + i.ToString() + "][data][comparison]"];

      object realValue = null;
      switch (type.ToLower())
      {
        case "string":
        case "numeric":
        case "account":
        case "list":
          realValue = value;
          break;
        case "date":
          realValue = DateTime.Parse(value, System.Threading.Thread.CurrentThread.CurrentUICulture);
          break;
      }

      //add the filter to the collection
      filter.Add(fieldName, ConvertComparisonToMTObject(operation), realValue);

      // increment counter
      i++;
      fieldName = Request["filter[" + i.ToString() + "][field]"];
    }

  }

  protected object ConvertComparisonToMTObject(string op)
  {
    object MTComparisonObject = null;

    switch (op)
    {
      case null:
      case "":
        MTComparisonObject = Rowset.MTOperatorType.OPERATOR_TYPE_LIKE_W;
        break;

      case "eq":
        MTComparisonObject = Rowset.MTOperatorType.OPERATOR_TYPE_EQUAL;
        break;

      case "ne":
        MTComparisonObject = Rowset.MTOperatorType.OPERATOR_TYPE_NOT_EQUAL;
        break;

      case "lt":
        MTComparisonObject = Rowset.MTOperatorType.OPERATOR_TYPE_LESS;
        break;

      case "lte":
        MTComparisonObject = Rowset.MTOperatorType.OPERATOR_TYPE_LESS_EQUAL;
        break;

      case "gte":
        MTComparisonObject = Rowset.MTOperatorType.OPERATOR_TYPE_GREATER_EQUAL;
        break;

      case "gt":
        MTComparisonObject = Rowset.MTOperatorType.OPERATOR_TYPE_GREATER;
        break;

      default:
        MTComparisonObject = Rowset.MTOperatorType.OPERATOR_TYPE_DEFAULT;
        break;
    }

    return MTComparisonObject;
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    // Get parameters
    int limit = 0;
    if (!String.IsNullOrEmpty(Request["limit"]))
    {
      limit = int.Parse(Request["limit"].ToString());
    }

    string query = String.Empty;
    if (!String.IsNullOrEmpty(Request["query"]))
    {
      query = Request["query"].ToString();
    }

    int start = 0;
    if (!String.IsNullOrEmpty(Request["start"]))
    {
      start = int.Parse(Request["start"].ToString());
    }

    //read out sort field and sort direction if available
    string sortField = String.Empty;
    string sortDir = "ASC";

    if (!String.IsNullOrEmpty(Request["sort"]))
    {
      sortField = Request["sort"].ToString();

      if (!String.IsNullOrEmpty(Request["dir"]))
      {
        sortDir = Request["dir"].ToString();
      }
    }

    // Run account finder with filter
    MTYAAC.IMTAccountCatalog accountCatalog = new MTYAAC.MTAccountCatalog();
    MTYAAC.IMTSessionContext sessionContext = (MTYAAC.IMTSessionContext)UI.User.SessionContext;
    accountCatalog.Init(sessionContext);
    Rowset.IMTDataFilter filter = new Rowset.MTDataFilter();
    
  //  filter.Add("_NameSpaceType", Rowset.MTOperatorType.OPERATOR_TYPE_EQUAL, "system_mps");

    //filter out namespace=auth
    filter.Add("name_space", Rowset.MTOperatorType.OPERATOR_TYPE_NOT_EQUAL, "Auth");

    //add username filter with the value provided by user
    if (!String.IsNullOrEmpty(query))
    {
      filter.Add("username", Rowset.MTOperatorType.OPERATOR_TYPE_LIKE_W, query);
    }
    else  //append all grid filters
    {
      AppendFilters(filter);
    }

    MTYAAC.IMTCollection columns = (MTYAAC.IMTCollection)new MTCol.MTCollection();
    PopulateColumns(columns);

    object moreRows;
    Rowset.IMTSQLRowset rs = (Rowset.IMTSQLRowset)accountCatalog.FindAccountsAsRowset(ApplicationTime, columns, (MTYAAC.IMTDataFilter)filter, null, null, 1001, out moreRows, null);
    
    if (!String.IsNullOrEmpty(sortField))
    {
      MTSortOrder sortOrder = (sortDir.ToLower() == "desc") ? MTSortOrder.SORT_DESCENDING : MTSortOrder.SORT_ASCENDING;
      rs.Sort(sortField, sortOrder);
    }
    
    if ((rs == null) || (rs.RecordCount == 0))
    {
      Response.Write("{\"TotalRows\":\"0\",\"records\":[]}");
      Response.End();
      return;
    }

    if (Page.Request["mode"] == "csv")
    {
      ExportToCSV(rs, start, limit);
    }
    else
    {
      // Return json
      string json = Converter.GetRowsetAsJson(rs, start, limit);
      Response.Write("{" + json + "}");
    }
    Response.End();
  }

  protected void ExportToCSV(Rowset.IMTSQLRowset rs, int start, int limit)
  {
    Response.Buffer = false;
    Response.ContentType = "application/csv";
    Response.AddHeader("Content-Disposition", "attachment; filename=export.csv");

    string csvContent = Converter.RowsetToCSV(rs, start, limit, true);

    Response.Write(csvContent);

    Response.End();

  }
}
