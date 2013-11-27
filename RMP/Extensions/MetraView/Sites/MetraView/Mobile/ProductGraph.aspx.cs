using System;
using System.Text;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;

public partial class AjaxServices_ProductGraph : MTPage
{
  public string ChartData
  {
      get { return ViewState["ChartData"] as string; }
      set { ViewState["ChartData"] = value; }
  }

  public string ChartLabels
  {
      get { return ViewState["ChartLabels"] as string; }
      set { ViewState["ChartLabels"] = value; }
  }

  public ReportLevel ReportLevel
  {
      get { return ViewState[SiteConstants.ReportLevel] as ReportLevel; }
      set { ViewState[SiteConstants.ReportLevel] = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
      if (UI.Subscriber.SelectedAccount == null)
          return;

      var billManager = new BillManager(UI);
      billManager.ReportParams.ReportView = ReportViewType.OnlineBill;
      var defaultIntervalSlice = new UsageIntervalSlice { UsageInterval = int.Parse(Request["intervalId"]) };
      billManager.ReportParams.DateRange = defaultIntervalSlice;
      billManager.ReportParams.UseSecondPassData = true; 
      billManager.GetInvoiceReport(true);

      ReportLevel = billManager.GetByProductReport();

      var count = 0;
      if (ReportLevel.ProductOfferings != null)
      {
          count += ReportLevel.ProductOfferings.Count;
      }
      if (ReportLevel.Charges != null)
      {
          count += ReportLevel.Charges.Count;
      }

      var sb = new StringBuilder();
      var sbLabels = new StringBuilder();
  
      int i = 0;
      if (ReportLevel.ProductOfferings != null && ReportLevel.ProductOfferings.Count > 0)
      {
          foreach (var reportProductOffering in ReportLevel.ProductOfferings)
          {
              if (reportProductOffering.Charges != null && reportProductOffering.Charges.Count > 0)
              {
                  foreach (var charge in reportProductOffering.Charges)
                  {
                      sbLabels.Append("'");
                      sbLabels.Append(charge.DisplayName.Replace("\"", "\\\""));
                      sbLabels.Append("'");
                      sb.Append(charge.Amount);

                      i++;
                      if (i < ReportLevel.ProductOfferings.Count)
                      {
                          sbLabels.Append(",");
                          sb.Append(",");
                      }
                  }
              }
          }
      }

      if (ReportLevel.Charges != null && ReportLevel.Charges.Count > 0)
      {
          if (ReportLevel.ProductOfferings != null && ReportLevel.ProductOfferings.Count > 0)
          {
              sbLabels.Append(",");
              sb.Append(",");
          }
          i = 0;
          foreach (var charge in ReportLevel.Charges)
          {
              sbLabels.Append("'");
              sbLabels.Append(charge.DisplayName.Replace("\"", "\\\""));
              sbLabels.Append("'");
              sb.Append(charge.Amount);

              i++;
              if (i < ReportLevel.Charges.Count)
              {
                  sbLabels.Append(",");
                  sb.Append(",");
              }
          }
      }

      ChartData = sb.ToString();
      ChartLabels = sbLabels.ToString();
  }
}
