using System;
using System.ServiceModel;
using System.Web;
using System.Web.Script.Serialization;

using MetraTech.ActivityServices.Common;
using MetraTech.Debug.Diagnostics;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;

public partial class ProductOfferingsList : MTPage
{
    public bool isMaster = false;

    protected override void OnLoadComplete(EventArgs e)
    {
        // Hidden field logic
        GridRenderer.PopulateProductCatalogBooleanFilter(MTFilterGrid1, "IsHidden");

        MetraTech.UI.Controls.MTGridDataElement gdel_hidden = MTFilterGrid1.FindElementByID("IsHidden");
        if (gdel_hidden == null)
        {
            throw new ApplicationException(string.Format("Can't find element named 'IsHidden' on the Product Offering FilterGrid layout. Has the layout '{0}' been tampered with?", MTFilterGrid1.TemplateFileName));
        }

        // Fill out Product Catalog with Booleans that are represented as Y/N as opposed to the default 1/0
        gdel_hidden.ElementValue = "N";
        //gdel_hidden.FilterReadOnly = true;
        gdel_hidden.FilterHideable = false;

        isMaster = Convert.ToBoolean(Request["Master"]);
        string inputfiltertype = "PO";

        // Handle Partition Id logic
        if (isMaster)
        {
            PartitionLibrary.SetupFilterGridForMaster(MTFilterGrid1);
        }
        else
        {
            PartitionLibrary.SetupFilterGridForPartition(MTFilterGrid1,inputfiltertype);
        }

        base.OnLoadComplete(e);
    }

}