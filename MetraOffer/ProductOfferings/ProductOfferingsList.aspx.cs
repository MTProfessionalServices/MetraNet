using System;
using Newtonsoft.Json;
using MetraTech.UI.Common;

public partial class ProductOfferingsList : MTPage
{
  public bool IsMaster = false;

  protected override void OnLoadComplete(EventArgs e)
  {
    GridRenderer.PopulateProductCatalogBooleanFilter(MTFilterGrid1, "IsHidden");
    IsMaster = Convert.ToBoolean(Request["Master"]);
    const string inputfiltertype = "PO";
    if (IsMaster)
    {
      var masterLocalizedText = GetLocalResourceObject("TEXT_MASTER") ?? "Master Product Offering";
      PartitionLibrary.SetupFilterGridForMaster(MTFilterGrid1, masterLocalizedText.ToString());
    }
    else
    {
      PartitionLibrary.SetupFilterGridForPartition(MTFilterGrid1, inputfiltertype);
    }
    if (Request.Cookies["MCSaveFilterModel"] == null || !Convert.ToBoolean(Request["PreviousResultView"]))
    {
      var gdelHidden = MTFilterGrid1.FindElementByID("IsHidden");
      if (gdelHidden == null)
      {
        throw new ApplicationException(
          string.Format(
            "Can't find element named 'IsHidden' on the Product Offering FilterGrid layout. Has the layout '{0}' been tampered with?",
            MTFilterGrid1.TemplateFileName));
      }
      // Fill out Product Catalog with Booleans that are represented as Y/N as opposed to the default 1/0
      gdelHidden.ElementValue = "N";
      gdelHidden.FilterHideable = false;
    }
    else
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
    base.OnLoadComplete(e);
  }
}