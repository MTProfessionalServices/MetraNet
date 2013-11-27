using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.ActivityServices.Common;
using MetraTech.UI.Common;
using MetraTech.DomainModel.MetraPay;
using MetraTech;

public partial class Mobile_PayNow : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    string resultSuccess = "{ \"success\": \"true\", \"confirmationNumber\" : \"%%CONFIRMATION_NUMBER%%\", \"errorMessage\" : \"\"}";
    string resultFailed = "{ \"success\": \"false\", \"errorMessage\" : \"%%ERROR_MESSAGE%%\" }";

    try
    {
      MetraPaymentInfo paymentData = new MetraPaymentInfo();
      paymentData.Amount = decimal.Parse(Request["amountToPay"]);
      paymentData.Currency = "USD";  //TODO
      paymentData.MetraPaymentInvoices = new List<MetraPaymentInvoice>();
      MetraPaymentInvoice invoice = new MetraPaymentInvoice();
      invoice.InvoiceDate = MetraTime.Now;
      paymentData.MetraPaymentInvoices.Add(invoice);

        //TODO:  invoice number and date...

      var metraPayManager = new MetraPayManager(UI);
      MetraPaymentInfo confirmationData = metraPayManager.DebitPaymentMethod(new Guid(Request["PIID"]), paymentData);

      resultSuccess = resultSuccess.Replace("%%CONFIRMATION_NUMBER%%", confirmationData.TransactionID);

      Response.Write(resultSuccess);
    }
    catch (FaultException<MASBasicFaultDetail> fe)
    {
      string message = "";
      foreach (string msg in fe.Detail.ErrorMessages)
      {
        message += msg + " ";
      }
      Response.Write(resultFailed.Replace("%%ERROR_MESSAGE%%", message));
    }
    catch (Exception ex)
    {
      Response.Write(resultFailed.Replace("%%ERROR_MESSAGE%%", ex.Message));
      Logger.LogError(ex.Message);
    }
  }
}
