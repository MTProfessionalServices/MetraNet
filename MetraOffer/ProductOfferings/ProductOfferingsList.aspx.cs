using System;
using MetraTech.UI.Common;

public partial class ProductOfferingsList : MTPage
{
  public bool IsMaster = false;

  protected override void OnLoadComplete(EventArgs e)
  {
    // Hidden field logic
    GridRenderer.PopulateProductCatalogBooleanFilter(MTFilterGrid1, "IsHidden");

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
    //gdel_hidden.FilterReadOnly = true;
    gdelHidden.FilterHideable = false;

    IsMaster = Convert.ToBoolean(Request["Master"]);
    const string inputfiltertype = "PO";

    // Handle Partition Id logic
    if (IsMaster)
    {
      PartitionLibrary.SetupFilterGridForMaster(MTFilterGrid1);
    }
    else
    {
      PartitionLibrary.SetupFilterGridForPartition(MTFilterGrid1, inputfiltertype);
    }

    base.OnLoadComplete(e);
  }
}