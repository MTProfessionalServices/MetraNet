using System;
using System.Text;
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;

public partial class UserControls_CurrentChargesByFolder : System.Web.UI.UserControl
{
  public UIManager UI
  {
    get { return ((MTPage)Page).UI; }
  }

  public InvoiceReport InvoiceReport
  {
    get { return ViewState[SiteConstants.InvoiceReport] as InvoiceReport; }
    set { ViewState[SiteConstants.InvoiceReport] = value; }
  }

  public ReportLevel ReportLevel
  {
    get { return ViewState[SiteConstants.ReportLevel] as ReportLevel; }
    set { ViewState[SiteConstants.ReportLevel] = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      if ((string)Session[SiteConstants.View] == "details")
      {
        var billManager = new BillManager(UI);
        if (billManager.ReportParams.ReportView == ReportViewType.Interactive)
        {
          PanelCurrentTotalAmount.Visible = false; // Hide current total amount for usage
          PanelAdjustments.Visible = false;        // Hide prebill adjustments for usage
        }
        if (billManager.InvoiceReport == null)
        {
          InvoiceReport = billManager.GetInvoiceReport(true);
        }
        else
        {
          InvoiceReport = billManager.InvoiceReport;
        }

        if (UI.Subscriber.SelectedAccount._AccountID != null)
        {
          if (billManager.ReportParams.ReportView == ReportViewType.OnlineBill)
          {
            ReportLevel = billManager.GetByFolderReport(null, null);
          }
          else
          {
            if (Session[SiteConstants.OwnedAccount] == null)
            {
              ReportLevel = billManager.GetByFolderReport((int)UI.Subscriber.SelectedAccount._AccountID, null);
            }
            else
            {
              // Show usage for owned folder
              ReportLevel = billManager.GetByFolderReport(int.Parse(Session[SiteConstants.OwnedAccount].ToString()), null);
            }
          }
        }
      }

      // Hide tax panel if taxes are inlined
      if (SiteConfig.Settings.BillSetting.InlineTax != null)
      {
        if ((bool)SiteConfig.Settings.BillSetting.InlineTax)
        {
          PanelTaxes.Visible = false;
        }
      }

      // Hide adjustment panel if adjustments are inlined
      if (SiteConfig.Settings.BillSetting.InlineAdjustments != null)
      {
        if ((bool)SiteConfig.Settings.BillSetting.InlineAdjustments)
        {
          PanelAdjustments.Visible = false;
        }
      }

    }
  }

  protected string GetChargesByFolder()
  {
    var billManager = new BillManager(UI);
    var sb = new StringBuilder();
    int indent = 0;
    if (ReportLevel != null)
    {
      sb.Append("<table width=\"100%\" cellspacing=\"0\" cellpadding=\"0\">");
      billManager.RenderReportLevel(ReportLevel, (Session[SiteConstants.View].ToString() == "summary"), indent, ref sb);
      sb.Append("</table>");
    }

    return sb.ToString();
  }

  protected string GetSubTotalAmount()
  {
    return ReportLevel.DisplayAmountAsString;
  }

  protected string GetPreBillAdjustmentAmount()
  {
    return ReportLevel.AdjustmentInfo != null ? ReportLevel.AdjustmentInfo.PreBillAdjustmentAmountAsString : 0M.ToDisplayAmount(UI);
  }

  protected string GetTaxAdjustmentAmount()
  {
    return ReportLevel.TotalTax != null ? ReportLevel.TotalTax.PreBillTaxAdjustmentAmountAsString : 0M.ToDisplayAmount(UI);
  }

  protected string GetTaxAmount()
  {
    return ReportLevel.TotalTax != null ? ReportLevel.TotalTax.TaxAmountAsString : 0M.ToDisplayAmount(UI);
  }

  protected string GetTotalCurrentChargesAmount()
  {
    return ReportLevel.TotalDisplayAmountAsString;
  }

  protected string GetCurrentTotalAmount()
  {
    if (InvoiceReport != null)
    {
      if (InvoiceReport.PreviousBalances != null)
      {
        return InvoiceReport.PreviousBalances.CurrentBalanceAsString ?? 0M.ToDisplayAmount(UI);
      }
    }
    return GetTotalCurrentChargesAmount();
  }

  protected string GetAdjustmentDetailLink()
  {
    string str = "";
    if (UI.Subscriber.SelectedAccount._AccountID != null)
    {
      var accountSlice = new PayerAccountSlice
      {
        PayerID = new AccountIdentifier((int)UI.Subscriber.SelectedAccount._AccountID)
      };

      if (ReportLevel != null && ReportLevel.AdjustmentInfo != null && ReportLevel.NumPreBillAdjustments > 0)
      {
        str = String.Format("<a href='AdjustmentDetails.aspx?isPostBill={0}&accountSlice={1}'>{2}</a>",
                            false,
                            SliceConverter.ToString(accountSlice),
                            GetLocalResourceObject("PrebillAdjustments.Text"));
      }
      else
      {
        str = GetLocalResourceObject("PrebillAdjustments.Text").ToString();
      }
    }
    return str;
  }
}
