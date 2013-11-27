using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Web;
using MetraTech.UI.Common;
using MetraTech;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.Billing;
using MetraTech.DomainModel.MetraPay;

/// <summary>
/// Summary description for MetraPayManager
/// </summary>
public class MetraPayManager
{
  private UIManager UI;
  private BillManager billManager;
  private static readonly Logger Logger = new Logger("[MetraView_MetraPayManger]");

  public MetraPayManager(UIManager ui)
  {
    UI = ui;
    billManager = new BillManager(UI);
  }

  #region Payment Methods
  public MTList<MetraPaymentMethod> GetPaymentMethodSummaries()
  {
    if (UI.Subscriber.SelectedAccount == null)
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);

    if (UI.Subscriber.SelectedAccount._AccountID == null)
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);

    RecurringPaymentsServiceClient client = null;

    try
    {
      client = new RecurringPaymentsServiceClient();

      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

      var acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
      var cardList = new MTList<MetraPaymentMethod>();
      client.GetPaymentMethodSummaries(acct, ref cardList);

      client.Close();
      client = null;
      return cardList;
    }
    catch (Exception ex)
    {
      Logger.LogError(ex.Message);
      throw new Exception("Unable to get list of payment methods", ex);
    }
    finally
    {
      if (client != null)
      {
        client.Abort();
      }
    }
  }

// ReSharper disable InconsistentNaming
  public Guid AddPaymentMethod(AccountIdentifier acct, MetraPaymentMethod ACHCard)
// ReSharper restore InconsistentNaming
  {
     RecurringPaymentsServiceClient client = null;

     try
     {
       client = new RecurringPaymentsServiceClient();

       client.ClientCredentials.UserName.UserName = UI.User.UserName;
       client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

       Guid paymentInstrumentId;
       client.AddPaymentMethod(acct, ACHCard, out paymentInstrumentId);

       client.Close();
       client = null;
       return paymentInstrumentId;
     }
     catch (Exception ex)
     {
       Logger.LogError(ex.Message);
       throw new Exception("Unable to add payment method", ex);
     }
    finally
     {
         if (client != null)
         {
           client.Abort();
         }
     }
  }


  public void DeletePaymentMethod(AccountIdentifier acct, Guid piId)
  {
    RecurringPaymentsServiceClient client = null;

    try
    {
      client = new RecurringPaymentsServiceClient();

      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      
      client.DeletePaymentMethod(acct, piId);
      client.Close();
      client = null;
    }
    catch (Exception ex)
    {
      Logger.LogError(ex.Message);
      throw new Exception("Unable to delete payment method", ex);
    }
    finally
    {
      if (client != null)
      {
        client.Abort();
      }
    }
  }


  public MetraPaymentMethod GetPaymentMethodDetail(AccountIdentifier acct, Guid piId)
  {
    RecurringPaymentsServiceClient client = null;

    try
    {
      client = new RecurringPaymentsServiceClient();

      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

      MetraPaymentMethod paymentMethod;
      client.GetPaymentMethodDetail(acct, piId, out paymentMethod);

      client.Close();
      client = null;
      return paymentMethod;
    }
    catch (Exception ex)
    {
      Logger.LogError(ex.Message);
      throw new Exception("Unable to get payment method details", ex);
    }
    finally
    {
      if (client != null)
      {
        client.Abort();
      }
    }
 }


  public void UpdatePaymentMethod(AccountIdentifier acct, Guid piId, MetraPaymentMethod paymentMethod, int oldPriority)
  {
    RecurringPaymentsServiceClient client = null;

    try
    {
      client = new RecurringPaymentsServiceClient();

      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

      client.UpdatePaymentMethod(acct, piId, paymentMethod);

      if (paymentMethod.Priority != null)
        if (paymentMethod.Priority.Value != oldPriority)
        {
          client.UpdatePriority(acct, piId, paymentMethod.Priority.Value);
        }

      client.Close();
      client = null;
    }
    catch (Exception ex)
    {
      Logger.LogError(ex.Message);
      throw new Exception("Unable to update payment method", ex);
    }
    finally
    {
      if (client != null)
      {
        client.Abort();
      }
    }
  }

  public MetraPaymentInfo DebitPaymentMethod(Guid paymentInstrumentId, MetraPaymentInfo paymentInfo)
  {
    RecurringPaymentsServiceClient client = null;

    try
    {
      client = new RecurringPaymentsServiceClient();

      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      int timeOut = 30000;
      if (((NameValueCollection)HttpContext.Current.GetSection("appSettings")).HasKeys())
      {
        timeOut = int.Parse(((NameValueCollection)HttpContext.Current.GetSection("appSettings")).Get("TimeOut"));
      }
      client.DebitPaymentMethodV2(paymentInstrumentId, ref paymentInfo, timeOut, "");

      client.Close();
      client = null;
      return paymentInfo;
    }
    catch (Exception ex)
    {
      Logger.LogError(ex.Message);
      throw new Exception("Unable to make payment", ex);
    }
    finally
    {
      if(client != null)
      {
         client.Abort();
      }
     
    }
  }

  public MetraPaymentInfo SchedulePaymentMethod(Guid paymentInstrumentId, DateTime paymentDate, MetraPaymentInfo paymentInfo)
  {
    RecurringPaymentsServiceClient client = null;

    try
    {
      client = new RecurringPaymentsServiceClient();

      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

      //try dunning is set to false, as we do not need retries
      client.SchedulePayment(paymentInstrumentId, paymentDate, false, ref paymentInfo);
      
      client.Close();
      client = null;
      return paymentInfo;
    }
    catch (Exception ex)
    {
      Logger.LogError(ex.Message);
      throw new Exception("Unable to make scheduled payment", ex);
    }
    finally
    {
      if (client != null)
      {
        client.Abort();
      }
    }
  }



  public PaymentConfirmationData MakePayment(MakePaymentData paymentData)
  {
    MetraPaymentInfo pi = new MetraPaymentInfo();
    pi.Amount = paymentData.Amount;
    // can also take currency from ((InternalView)(UI.Subscriber.SelectedAccount.GetInternalView())).Currency;
    pi.Currency = paymentData.Currency;
    // adding null check as we might not have any hard closed intervals
    Interval interval = billManager.GetCurrentInterval();

    pi.MetraPaymentInvoices = new List<MetraPaymentInvoice>();

    MetraPaymentInvoice pmtInvoice = new MetraPaymentInvoice();

    if (interval != null)
    {
      pmtInvoice.InvoiceNum = billManager.GetCurrentInterval().InvoiceNumber;
    }
    else
      pmtInvoice.InvoiceNum = "";
    //pi.PONum = "PO187"; // optional
    //pi.TransactionID = "420"; //coming back from MetraPay
    pmtInvoice.InvoiceDate = paymentData.InvoiceDate;
	pmtInvoice.AmountToPay = paymentData.Amount;
    //TODO: set proper description
    pi.Description = "Payment";
    Guid token = new Guid(paymentData.PaymentInstrumentId);

    pi.MetraPaymentInvoices.Add(pmtInvoice);
   
    if (paymentData.PayNow)
    {
      pi = DebitPaymentMethod(token, pi);
    }
    else
    {
      pi = SchedulePaymentMethod(token, paymentData.SchedulePaymentDate, pi);
    }
    PaymentConfirmationData confirmationData = new PaymentConfirmationData();
    confirmationData.Amount = paymentData.Amount;
    confirmationData.Method = paymentData.Method;
    confirmationData.MethodType = paymentData.MethodType;
    confirmationData.Number = paymentData.Number;
    confirmationData.Type = paymentData.Type;
    confirmationData.SchedulePaymentDate = paymentData.SchedulePaymentDate;
    confirmationData.ConfirmationNumber = pi.TransactionID;
    return confirmationData;
  }
  #endregion 
  
  #region Payment Helper Classes
  public enum PaymentMethodType : byte { CreditCard, ACH, Unknown };

  public class MakePaymentData
  {
    public decimal Amount;
    public string PaymentInstrumentId;
    public bool PayNow;
    public DateTime SchedulePaymentDate;
    public string Currency;
    public DateTime InvoiceDate;
    //Need both method and method type as no easy way to check type from string
    //and no easy way to get localized value outside the Master page
    public PaymentMethodType MethodType;
    public string Method; // credit card or ACH
    public string Type;// account type (checking/saving) or credit card type (visa/MasterCard)
    public string Number;//account number of credit card number
  }

  public class PaymentConfirmationData
  {
    public string ConfirmationNumber;
    public decimal Amount;
    public DateTime SchedulePaymentDate;
    public PaymentMethodType MethodType;
    public string Method;// credit card or ACH
    public string Type;// account type (checking/saving) or credit card type (visa/MasterCard)
    public string Number;//account number of credit card number
  }
  #endregion

}