using System;
using System.IO;
using System.Linq;
using System.Threading;
using System.Web.UI;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;
using MetraTech.UI.Tools;


public partial class UserControls_BillAndPayments : UserControl
{
  public UIManager UI
  {
    get { return ((MTPage)Page).UI;}
  }

  public InvoiceReport InvoiceReport { get; set; }
  public Payment Payment { get; set; }
  public bool HidePaymentButton { get; set; }
  private BillManager billManager;

  private PaymentInfo paymentInfo;

  protected void Page_Load(object sender, EventArgs e)
  {
    billManager = new BillManager(UI);

    // Hide the Make Payment button under certain circumstances.
    if (HidePaymentButton)
    {
      PanelPaymentButton.Visible = false;
    }
    else
    {
      // Check if MetraPay is installed by looking for the PaymentSvrClient extension.
      MetraTech.Interop.RCD.IMTRcd rcd = new MetraTech.Interop.RCD.MTRcd();
      string paymentSvrClientExtFile = Path.Combine(rcd.ExtensionDir, @"PaymentSvrClient\config\extension.xml");

      // Check if online payment is allowed.
      bool? aop = SiteConfig.Settings.BillSetting.AllowOnlinePayment;

      if (!File.Exists(paymentSvrClientExtFile))
      {
        PanelPaymentButton.Visible = false;
      }
      else if (aop.HasValue)
      {
       // if (billManager.GetCurrentInterval().Status == IntervalStatusCode.HardClosed)
       // {
          PanelPaymentButton.Visible = aop.Value;
       // }
       // else
       // {
       //   PanelPaymentButton.Visible = false;
       // }
      }
      else
      {
        PanelPaymentButton.Visible = true;
      }
    }

    paymentInfo = billManager.PaymentInformation;
    if (paymentInfo != null)
    {
      //show or hide the lines if no payment is due, e.g. first bill
      if ((paymentInfo.DueDate == null) || (paymentInfo.DueDate == new DateTime(1900, 1, 1)))
      {
        dueDateDiv.Visible = false;
        noPaymentDueDiv.Visible = true;
        totalAmountDueDiv.Visible = false;
      }
      else
      {
        dueDateDiv.Visible = true;
        noPaymentDueDiv.Visible = false;
        totalAmountDueDiv.Visible = true;
      }

      //show or hide last payment info
      if (((paymentInfo.LastPaymentDate == null) || (paymentInfo.LastPaymentDate == new DateTime(1900, 1, 1))) && paymentInfo.LastPaymentAmount == 0)
      {
        lastPaymentDiv.Visible = false;
      }
      else
      {
        lastPaymentDiv.Visible = true;
      }
    }

    // Any cached user control (i.e., with an OutputCache directive) that should NOT be cached 
    // while in DemoMode should call DisableUserControlCachingInDemoMode() at the end of Page_Load().
    WebUtils.DisableUserControlCachingInDemoMode(this);

  }

  IAsyncResult BeginHandler(object src, EventArgs e, AsyncCallback cb, object state)
  {
    ((MTPage)Page).Logger.LogInfo(ID + " BeginHandler - " + Thread.CurrentThread.GetHashCode());
    return billManager.GetDefaultInvoiceReportBeginAsync(cb, state);
  }

  void EndHandler(IAsyncResult result)
  {
    ((MTPage)Page).Logger.LogInfo(ID + " EndHandler - " + Thread.CurrentThread.GetHashCode());
    InvoiceReport = billManager.GetDefaultInvoiceReportEndAsync(result);
    if (InvoiceReport.Payments != null && InvoiceReport.Payments.Count > 0)
    {
      Payment = InvoiceReport.Payments.Where(p => p.Amount != 0).FirstOrDefault();
    }
  }

  void TimeoutHandler(IAsyncResult ar)
  {
    ((MTPage)Page).Logger.LogInfo(ID + " TimeoutHandler - " + Thread.CurrentThread.GetHashCode());
  }

  protected string GetPaymentDate()
  {
    if (paymentInfo == null)
    {
      return "";
    }

    if ((paymentInfo.LastPaymentDate == null) || (paymentInfo.LastPaymentDate == new DateTime(1900, 1, 1)))
    {
        return "";
    }

    return paymentInfo.LastPaymentDate.ToShortDateString();
  }

  protected string GetPaymentAmount()
  {
    if (paymentInfo == null)
    {
      return 0M.ToDisplayAmount(UI);
    }

    return paymentInfo.LastPaymentAmountAsString;
  }

  protected string GetPreviousBalance()
  {
    if (paymentInfo == null)
    {
      return 0M.ToDisplayAmount(UI);
    }

    return paymentInfo.AmountDueAsString;
  }

  protected string GetPaymentDueDate()
  {
    if ( (paymentInfo == null) || (paymentInfo.DueDate == null) || (paymentInfo.DueDate == new DateTime(1900, 1, 1)))
    {
      return "";
    }

    return paymentInfo.DueDate.ToShortDateString();
  }

}
