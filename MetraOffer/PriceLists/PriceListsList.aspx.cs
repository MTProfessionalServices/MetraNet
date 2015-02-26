using System;
using System.ServiceModel;
using System.Web;
using System.Web.Script.Serialization;

using Newtonsoft.Json;

using MetraTech.ActivityServices.Common;
using MetraTech.Debug.Diagnostics;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;

public partial class PriceListsList : MTPage
{
  protected override void OnLoadComplete(EventArgs e)
  {
    string inputfiltertype = "PL";
    PartitionLibrary.SetupFilterGridForPartition(MTFilterGrid1, inputfiltertype);
    base.OnLoadComplete(e);

    if (Request.Cookies["MCSaveFilterModel"] != null && Convert.ToBoolean(Request["PreviousResultView"]))
    {
      var httpCookie = Request.Cookies["MCSaveFilterModel"];
      if (httpCookie != null)
      {
        var decode = System.Web.HttpUtility.UrlDecode(httpCookie.Value);
        var filterData = JsonConvert.DeserializeObject<FilterModel[]>(decode);
        foreach (var filterItemData in filterData)
        {
          var filterElement = MTFilterGrid1.FindElementByID(filterItemData.FieldName);
          if (filterElement != null)
          {
            filterElement.ElementValue = filterItemData.Value;
            filterElement.FilterHideable = filterItemData.FilterHideable;
            filterElement.FilterReadOnly = filterItemData.FilterReadOnly;
            filterElement.FilterOperation = filterItemData.GetFilterOperationByString();
          }
        }
        httpCookie.Expires = DateTime.Now.AddDays(-1d);
        Response.Cookies.Add(httpCookie);
      }
    }
  }
}