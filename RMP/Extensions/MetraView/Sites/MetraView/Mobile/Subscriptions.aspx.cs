using System.Text;
using MetraTech.ActivityServices.Common;
using MetraTech.UI.Common;
using System;
using MetraTech.DomainModel.ProductCatalog;
using System.Collections.Generic;

public partial class Mobile_Subscriptions : MTPage
{
    new public UIManager UI
    {
        get { return ((MTPage)Page).UI; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        var billManager = new BillManager(UI);
        MTList<Subscription> subList = new MTList<Subscription>();
        subList = billManager.GetSubscriptions(subList);

        var sb = new StringBuilder();
        sb.Append("[");
        const string row = "{\"name\" : \"%%NAME%%\",  \"description\" : \"%%DESCRIPTION%%\", \"date\" : \"%%DATE%%\",\"amount\" : \"%%AMOUNT%%\"}";

        if (subList.Items.Count == 0)
        {
            var str = row;
            str = str.Replace("%%NAME%%", "No Subscriptions Found");
            str = str.Replace("%%DESCRIPTION%%", "Click the plus to add a subscription to your account.");
            str = str.Replace("%%DATE%%", "");
            sb.Append(str);
        }
        else
        {
            var i = 0;
            foreach (var sub in subList.Items)
            {
                i++;
                var str = row;
                str = str.Replace("%%NAME%%", sub.ProductOffering.DisplayName);
                str = str.Replace("%%DESCRIPTION%%", sub.ProductOffering.Description);
                str = str.Replace("%%DATE%%", sub.SubscriptionSpan.StartDate.Value.ToShortDateString() + " - " + sub.SubscriptionSpan.EndDate.Value.ToShortDateString());
                sb.Append(str);
                if (subList.Items.Count != i)
                {
                    sb.Append(", ");
                }
            }
        }

        sb.Append("]");
        Response.Write(sb.ToString());
    }
}