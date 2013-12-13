using System;
using System.Text;
using System.Threading;
using System.Web.UI;
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;

public partial class UserControls_PreviousCharges : UserControl
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


  private BillManager billManager;

  protected void Page_Load(object sender, EventArgs e)
  {
    billManager = new BillManager(UI);

    if (Page.IsAsync)
    {
      var task = new PageAsyncTask(BeginHandler,
                                   EndHandler,
                                   TimeoutHandler, null, true);
      Page.RegisterAsyncTask(task);
    }
    else
    {
      InvoiceReport = billManager.GetInvoiceReport(false);
    }
  }

  IAsyncResult BeginHandler(object src, EventArgs e, AsyncCallback cb, object state)
  {
    ((MTPage)Page).Logger.LogInfo(ID + " BeginHandler - " + Thread.CurrentThread.GetHashCode());
    return billManager.GetInvoiceReportBeginAsync(cb, state);
  }

  void EndHandler(IAsyncResult result)
  {
    ((MTPage)Page).Logger.LogInfo(ID + " EndHandler - " + Thread.CurrentThread.GetHashCode());
    InvoiceReport = billManager.GetInvoiceReportEndAsync(result);
  }

  void TimeoutHandler(IAsyncResult ar)
  {
    ((MTPage)Page).Logger.LogInfo(ID + " TimeoutHandler - " + Thread.CurrentThread.GetHashCode());
  }

  protected string GetBalanceForwardAmount()
  {
    {
      if (InvoiceReport != null && InvoiceReport.PreviousBalances != null)
      {
        return InvoiceReport.PreviousBalances.BalanceForwardAsString ?? 0M.ToDisplayAmount(UI);
      }
    }
    return 0M.ToDisplayAmount(UI);
  }

  protected string GetPreviousBalanceAmount()
  {
    if (InvoiceReport != null && InvoiceReport.PreviousBalances != null)
    {
      return InvoiceReport.PreviousBalances.PreviousBalanceAsString ?? 0M.ToDisplayAmount(UI);
    }
    return 0M.ToDisplayAmount(UI);
  }
  
  protected string GetPostBillAdjustments()
  {
    var sb = new StringBuilder();
    const string strAdj = "<tr><td>{0}</td><td class=\"amount\">{1}</td></tr>";
    string adjLink = "";
    if (UI.Subscriber.SelectedAccount._AccountID != null)
    {
      var accountSlice = new PayerAccountSlice
      {
        PayerID = new AccountIdentifier((int)UI.Subscriber.SelectedAccount._AccountID)
      };
      adjLink = String.Format("<a href='AdjustmentDetails.aspx?isPostBill={0}&accountSlice={1}'>{2}</a>",
                              true,
                              SliceConverter.ToString(accountSlice),
                              GetLocalResourceObject("PostbillAdjustments.Text"));
    }

    //sb.Append("<tr>");
    if (InvoiceReport != null && InvoiceReport.PostBillAdjustments != null && InvoiceReport.PostBillAdjustments.Count > 0)
    {
      foreach (var adjustment in InvoiceReport.PostBillAdjustments)
      {
        if (adjustment.NumAdjustments != 0)
        {
          sb.Append(String.Format(strAdj, adjLink, adjustment.AdjustmentAmountAsString));

          if (!billManager.ReportParams.InlineVATTaxes)
          {
            sb.Append(string.Format(strAdj, GetLocalResourceObject("PostBillAdjustmentsTax.Text"), adjustment.TotalTax.TaxAmountAsString));
          }

        }
        else
        {
          sb.Append(String.Format(strAdj, GetLocalResourceObject("PostbillAdjustments.Text"), 0M.ToDisplayAmount(UI)));
        }
      }
    }
    else
    {
      sb.Append(String.Format(strAdj, GetLocalResourceObject("PostbillAdjustments.Text"), 0M.ToDisplayAmount(UI)));
    }
    //sb.Append("</tr>");
    return sb.ToString();
  }

  protected string GetPaymentsReceived()
  {
    var sb = new StringBuilder();
    const string strAdj = "<tr><td>{0} ({1})</td><td class=\"amount\">{2}</td></tr>";
    if (InvoiceReport != null && InvoiceReport.Payments != null && InvoiceReport.Payments.Count > 0)
    {

      foreach (var payment in InvoiceReport.Payments)
      {
          sb.Append(String.Format(strAdj, GetLocalResourceObject("PaymentsReceived.Text"), (payment.PaymentDate.HasValue) ? payment.PaymentDate.Value.ToUserDateString(UI) : GetLocalResourceObject("NA.Text"),
                                payment.AmountAsString));
      }
    }
    else
    {
      sb.Append(String.Format(strAdj, GetLocalResourceObject("PaymentsReceived.Text"), GetLocalResourceObject("NA.Text"), 0M.ToDisplayAmount(UI)));
    }
    return sb.ToString();
  }
}
