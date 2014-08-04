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

public partial class PriceListsList : MTPage
{
    protected override void OnLoadComplete(EventArgs e)
    {
        string inputfiltertype = "PL";
        PartitionLibrary.SetupFilterGridForPartition(MTFilterGrid1, inputfiltertype);
        base.OnLoadComplete(e);
    }
}