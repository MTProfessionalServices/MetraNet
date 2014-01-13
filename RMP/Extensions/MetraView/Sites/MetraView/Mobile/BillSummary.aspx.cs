using System;
using System.Linq;
using System.Threading;
using System.Web.UI;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;

public partial class Mobile_BillSummary : MTPage
{
  new public UIManager UI
  {
    get { return ((MTPage)Page).UI; }
  }
  public InvoiceReport InvoiceReport { get; set; }
  public Payment Payment { get; set; }
  private BillManager billManager;

  private PaymentInfo paymentInfo;

  protected void Page_Load(object sender, EventArgs e)
  {
    billManager = new BillManager(UI);
    paymentInfo = billManager.PaymentInformation;
  }

  protected string GetPaymentDate()
  {
    if (paymentInfo == null)
    {
      return "N/A";
    }

    if ((paymentInfo.LastPaymentDate == null) || (paymentInfo.LastPaymentDate == new DateTime(1900, 1, 1)))
    {
      return "N/A";
    }

    return paymentInfo.LastPaymentDate.ToShortDateString();
  }

  protected string GetPaymentAmount()
  {
    if (paymentInfo == null)
    {
        return 0M.ToDisplayAmount(UI);
    }

    return paymentInfo.LastPaymentAmountAsString.Replace("-", "");
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
    if ((paymentInfo == null) || (paymentInfo.DueDate == null) || (paymentInfo.DueDate == new DateTime(1900, 1, 1)))
    {
      return "N/A";
    }

    return paymentInfo.DueDate.ToShortDateString();
  }
}
