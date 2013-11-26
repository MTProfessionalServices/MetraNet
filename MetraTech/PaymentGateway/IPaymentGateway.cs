using System;
using System.Collections.Generic;
using System.Text;
using MetraTech.DomainModel.MetraPay;

namespace MetraTech.MetraPay.PaymentGateway
{
  public interface IPaymentGateway
  {
    void Init(string configFile);

    bool ValidatePaymentMethod(MetraPaymentMethod paymentMethod, string currency);
    
    void AuthorizeCharge(CreditCardPaymentMethod ccPaymentMethod, ref MetraPaymentInfo paymentInfo, out string requestParms, out string warnings, double timeout = 0, string cos = "");
    void CaptureCharge(CreditCardPaymentMethod ccPaymentMethod, ref MetraPaymentInfo paymentInfo, string requestParms, out string warnings, double timeout = 0, string cos = "");
    void Debit(MetraPaymentMethod paymentMethod, ref MetraPaymentInfo paymentInfo, out string warnings, double timeout = 0, string cos = "");
    void Credit(MetraPaymentMethod paymentMethod, ref MetraPaymentInfo paymentInfo, out string warnings, double timeout = 0, string cos = "");
    void Void(MetraPaymentMethod paymentMethod, ref MetraPaymentInfo paymentInfo, out string warnings, double timeout = 0, string cos = "");
    bool GetACHTransactionStatus(string transactionId, out string warnings);
    void DownloadACHTransactionsReport(string url, out string warnings);

    void GetCreditCardUpdates(string transactionId, List<CreditCardPaymentMethod> cardsToUpdate, ref List<CreditCardPaymentMethod> updatedCards);

    void ReverseAuthorizedCharge(CreditCardPaymentMethod ccPaymentMethod, ref MetraPaymentInfo paymentInfo, string requestParams, out string warnings, double timeout = 0, string cos = "");
    void UpdatePaymentMethod(MetraPaymentMethod paymentMethod, string currency);
  }
}
