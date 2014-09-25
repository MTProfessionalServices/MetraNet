using System;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;

public partial class Subscriptions_SelectPO : MTPage
{
    protected override void OnLoadComplete(EventArgs e)
    {
// ReSharper disable SpecifyACultureInStringConversionExplicitly
        var arg = new MTGridDataBindingArgument("POEffectiveDate", ApplicationTime.ToString());
        MyGrid1.DataBinder.Arguments.Add(arg);

        const string inputfiltertype = "PO";
        PartitionLibrary.SetupFilterGridForPartition(MyGrid1, inputfiltertype, true);

        base.OnLoadComplete(e);
    }

}