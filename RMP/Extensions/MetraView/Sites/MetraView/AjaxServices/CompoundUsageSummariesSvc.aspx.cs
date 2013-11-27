using System;
using System.Text;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.Debug.Diagnostics;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;

public partial class AjaxServices_CompoundUsageSummariesSvc : MTPage
{
  private AccountSlice accountSlice;
  private SingleProductSlice productSlice;
  private string parentSessionID;

  protected void Page_Load(object sender, EventArgs e)
  {
    using (new HighResolutionTimer("CompundUsageSummariesSvc", 5000))
    {
      var sb = new StringBuilder();

      try
      {
        if (Request["accountSlice"] != null)
        {
          accountSlice = SliceConverter.FromString<AccountSlice>(Request["accountSlice"]);
        }

        if (Request["productSlice"] != null)
        {
          productSlice = SliceConverter.FromString<SingleProductSlice>(Request["productSlice"]);
          if (productSlice == null)
          {
            Logger.LogWarning("No product slice provided.");
            Response.End();
          }
        }

        if (Request["parentSessionID"] != null)
        {
          parentSessionID = Request["parentSessionID"];
        }

        var billManager = new BillManager(UI);
        var childUsageSummaryList = billManager.GetCompoundUsageSummaries(accountSlice, parentSessionID);
        
        if (childUsageSummaryList != null)
        {
          if (childUsageSummaryList.Count > 0)
          {
            sb.Append("<h6>");
            sb.Append(Resources.Resource.TEXT_CHILD_ITEMS);
            sb.Append("</h6>");
            sb.Append("<hr/>");
            sb.Append("<table width=\"100%\" cellspacing=\"0\" cellpadding=\"0\">");

            string accountSliceString = SliceConverter.ToString(accountSlice);
            foreach (var childUsageSummary in childUsageSummaryList)
            {
              string productSliceString = SliceConverter.ToString(childUsageSummary.ProductSlice);
              sb.Append("<tr>");
              sb.Append(
                String.Format(
                  "<td style=\"padding-left:{0}px;\"><a href=\"Details.aspx?productSlice={2}&accountSlice={3}&parentSessionID={4}\">{1}</a></td>",
                  2*10,
                  childUsageSummary.DisplayName,
                  productSliceString,
                  accountSliceString,
                  parentSessionID));

              sb.Append(String.Format("<td class=\"{0}\">{1}</td>",
                                      billManager.GetAmountStyle(5, false),
                                      childUsageSummary.DisplayAmountAsString));

              sb.Append("</tr>");
            }
            sb.Append("</table>");
            sb.Append("<hr/>");
            Response.Write(sb.ToString());
          }
        }
      }
      catch (Exception ex)
      {
        Logger.LogException("Error getting compound usage summary details.", ex);
      }
      Response.End();
    }

  }
}
