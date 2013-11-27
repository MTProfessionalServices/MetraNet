using System.Text;
using MetraTech.ActivityServices.Common;
using MetraTech.UI.Common;
using System;
using MetraTech.DomainModel.ProductCatalog;
using System.Collections.Generic;

public partial class Mobile_AvailableSubscriptions : MTPage
{
    new public UIManager UI
    {
        get { return ((MTPage)Page).UI; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        var billManager = new BillManager(UI);

        MTList<ProductOffering> poList = new MTList<ProductOffering>();
        poList = billManager.GetEligiblePOsForSubscriptions(poList);

        var sb = new StringBuilder();
        sb.Append("[");
        const string row = "{\"name\" : \"%%NAME%%\",  \"description\" : \"%%DESCRIPTION%%\",  \"poid\" : \"%%POID%%\"}";

        if (poList.Items.Count == 0)
        {
            var str = row;
            str = str.Replace("%%NAME%%", "No Available Subscriptions Found");
            str = str.Replace("%%DESCRIPTION%%", "");
            str = str.Replace("%%POID%%", "");
            sb.Append(str);
        }
        else
        {
            var i = 0;
            foreach (var po in poList.Items)
            {
                i++;
                var str = row;
                str = str.Replace("%%NAME%%", po.DisplayName);
                str = str.Replace("%%DESCRIPTION%%", po.Description);
                str = str.Replace("%%POID%%", po.ProductOfferingId.ToString());
                sb.Append(str);
                if (poList.Items.Count != i)
                {
                    sb.Append(", ");
                }
            }
        }

        sb.Append("]");
        Response.Write(sb.ToString());
    }
}
