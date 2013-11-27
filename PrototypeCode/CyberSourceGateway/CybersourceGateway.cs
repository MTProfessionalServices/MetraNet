using System;
using System.Data;
using System.Net;
using System.ServiceModel;
using System.Web.Services.Protocols;
using System.Text;
using System.Xml;
using System.Configuration;
using MetraTech.DomainModel.Enums.PaymentSvrClient.Metratech_com_paymentserver;
using MetraTech.DomainModel.Enums.Core.Metratech_com;
using MetraTech.DomainModel.MetraPay;
using MetraTech.DomainModel.Enums;
using MetraTech.Interop.MTServerAccess;

using MetraTech.ActivityServices.Common;
using MetraTech.MetraPay.PaymentGateway;
using MetraTech.Interop.RCD;
using System.IO;

namespace MetraTech.MetraPay.CyberSourceGateway
{
  public class CybersourceGateway : IPaymentGateway
  {
    #region Private Variables
    protected Configuration m_GatewayConfig;
    protected string m_WCFConfigFile;
    protected string m_EndpointName;

    protected String m_MerchantID;
    protected String m_TransactionKey;

    protected String m_ValidReplyReasonCodes;
    protected String m_ValidAVSCode;
    protected String m_ValidCVNCodes;

    protected string m_AllowBlankCodes;

    protected static DataTable m_Checks = new DataTable("checks");
    #endregion

    #region Protected Variables
    protected string m_ReferenceCode;
    protected string m_MerchantContactNumber;

    protected string m_ValidationCurrency;
    protected string m_ValidationAmount;

    protected Logger mLogger = new Logger("[CybersourceGateway]");
    #endregion

    #region Constructors
    /// <summary>
    /// Initializes a new instance of CybersourceGateway class
    /// </summary>
    public CybersourceGateway()
    {
    }

    #endregion

    #region IPaymentGateway Members

    public void Init(string configFile)
    {
      ExeConfigurationFileMap map = new ExeConfigurationFileMap();
      map.ExeConfigFilename = configFile;

      m_GatewayConfig = ConfigurationManager.OpenMappedExeConfiguration(map, ConfigurationUserLevel.None);

      m_ValidReplyReasonCodes = m_GatewayConfig.AppSettings.Settings["ValidReplyReasonCodes"].Value;
      m_ValidAVSCode = m_GatewayConfig.AppSettings.Settings["ValidAVSCodes"].Value;
      m_ValidCVNCodes = m_GatewayConfig.AppSettings.Settings["ValidCVNCodes"].Value;

      m_ReferenceCode = m_GatewayConfig.AppSettings.Settings["ReferenceCode"].Value;

      m_AllowBlankCodes = m_GatewayConfig.AppSettings.Settings["AllowBlankCodes"].Value;

      m_MerchantContactNumber = m_GatewayConfig.AppSettings.Settings["MerchantContactNumber"].Value;

      m_ValidationCurrency = m_GatewayConfig.AppSettings.Settings["ValidationCurrency"].Value;
      m_ValidationAmount = m_GatewayConfig.AppSettings.Settings["ValidationAmount"].Value;

      IMTServerAccessDataSet sa = new MTServerAccessDataSet();
      sa.Initialize();
      string credentialsName = m_GatewayConfig.AppSettings.Settings["CredentialsName"].Value;
      IMTServerAccessData accessData = sa.FindAndReturnObject(credentialsName);
      m_MerchantID = accessData.UserName;
      m_TransactionKey = accessData.Password;

      IMTRcd rcd = new MTRcdClass();
        
      string wcfConfig = m_GatewayConfig.AppSettings.Settings["WCFConfigFile"].Value;
      if (Path.IsPathRooted(wcfConfig))
      {
        m_WCFConfigFile = wcfConfig;
      }
      else
      {
        m_WCFConfigFile = Path.Combine(rcd.ExtensionDir, wcfConfig);
      }

      m_EndpointName = m_GatewayConfig.AppSettings.Settings["EndpointName"].Value;
    }

    // TODO: Need to finalize ACH payment add
    public bool ValidatePaymentMethod(MetraPaymentMethod creditCardInfo)
    {
      if (creditCardInfo.GetType() == typeof(CreditCardPaymentMethod))
      {
        RequestMessage request = InitializeRequest();

        request.ccAuthService = new CCAuthService();
        request.ccAuthService.run = "true";

        request.billTo = InitializeBillingInfo(creditCardInfo);
        request.card = InitializeCardInfo(creditCardInfo);
        request.purchaseTotals = InitializeValidationPurchaseTotals();


        try
        {
          TransactionProcessorClient proc = MASClientClassFactory.CreateClient<TransactionProcessorClient>(m_WCFConfigFile, m_EndpointName);

          proc.ClientCredentials.UserName.UserName = m_MerchantID;
          proc.ClientCredentials.UserName.Password = m_TransactionKey;

          ReplyMessage reply = proc.runTransaction(request);
          mLogger.LogInfo("decision = " + reply.decision + " reasonCode = " + reply.reasonCode + " requestID = " + reply.requestID);

          //check the reply code
          if (!IsCodeInList(reply.reasonCode, m_ValidReplyReasonCodes))
          {
            mLogger.LogError(String.Format("Invalid Credit Card Number {0}", reply.reasonCode));
            throw new PaymentProcessorException(String.Format("Invalid Credit Card Number {0}", reply.reasonCode));
          }

          if (creditCardInfo.GetType() == typeof(CreditCardPaymentMethod))
          {
            CreditCardPaymentMethod cc = (CreditCardPaymentMethod)creditCardInfo;
            //check additional codes
            if (reply.ccAuthReply != null)
            {
              if (cc.CVNumber != null)
              {
                //perform CVN code check
                if (!IsCodeInList(reply.ccAuthReply.cvCode, m_ValidCVNCodes))
                {
                  //fix for CYBS bug in simulator that returns an empty AuthReply.cvCode if CVN.Length < 4
                  if ((reply.ccAuthReply.cvCode != String.Empty) || (m_AllowBlankCodes != "1"))
                  {
                    mLogger.LogError("Invalid Credit Card Verification Number; ccAuthReply.cvCode=" + reply.ccAuthReply.cvCode);
                    throw new PaymentProcessorException(String.Format("Invalid Credit Card Verification Number; ccAuthReply.cvCode= {0}", reply.ccAuthReply.cvCode));
                  }
                }
              }

              //perform Address Verification check (AVS)
              if (!IsCodeInList(reply.ccAuthReply.avsCode, m_ValidAVSCode))
              {
                mLogger.LogError("Failed AVS check; ccAuthReply.avsCode=" + reply.ccAuthReply.avsCode);
                throw new PaymentProcessorException(String.Format("Failed AVS check; ccAuthReply.avsCode {0}", reply.ccAuthReply.avsCode));
              }
            }
          }
        }

        catch (PaymentProcessorException ppe)
        {
          mLogger.LogException("PaymentProcessorException Exception while capturing charge. ", ppe);
          throw ppe;
        }
        catch (MASBasicException mas)
        {
          mLogger.LogException("MAS Exception caught while processing Credit Card", mas);
          throw mas;
        }
        catch (TimeoutException e)
        {
          mLogger.LogException("Timeout Exception while processing Credit Card", e);
          throw new MASBasicException("Timeout Exception while processing Credit Card");
        }
        catch (FaultException e)
        {
          mLogger.LogException("Fault Exception while processing Credit Card", e);
          throw new MASBasicException("Fault Exception while processing Credit Card");
        }
        catch (CommunicationException e)
        {
          mLogger.LogException("Communication Exception while processing Credit Card", e);
          throw new MASBasicException("Communication Exception while processing Credit Card");
        }
        catch (Exception e)
        {
          mLogger.LogException("Exception while processing Credit Card", e);
          throw new MASBasicException("Exception while processing Credit Card");
        }

        return true;
      }
      else if (creditCardInfo.GetType() == typeof(ACHPaymentMethod))
      {
        // TODO: NEED TO DO SOME VALIDATION HERE
        return true;
      }
      else
      {
        return false;
      }
    }

    public void AuthorizeCharge(CreditCardPaymentMethod ccPaymentMethod, ref MetraPaymentInfo paymentInfo, out string requestParms, out string warnings)
    {
      warnings = "";
      requestParms = "";
      RequestMessage request = InitializeRequest();

      request.ccAuthService = new CCAuthService();
      request.ccAuthService.run = "true";

      request.billTo = InitializeBillingInfo(ccPaymentMethod);
      request.card = InitializeCardInfo(ccPaymentMethod);
      request.purchaseTotals = InitializePurchaseTotals(ref paymentInfo);

      try
      {
        TransactionProcessorClient proc = MASClientClassFactory.CreateClient<TransactionProcessorClient>(m_WCFConfigFile, m_EndpointName);

        proc.ClientCredentials.UserName.UserName = m_MerchantID;
        proc.ClientCredentials.UserName.Password = m_TransactionKey;

        mLogger.LogInfo("Submitting Preauthorization request to CyberSource");
        ReplyMessage reply = proc.runTransaction(request);
        mLogger.LogInfo("decision = " + reply.decision + " reasonCode = " + reply.reasonCode + " requestID = " + reply.requestID);

        //TODO: Just doing this for now to move along with dev, need to identify a design that is good for other processors
        requestParms = String.Format("{0};{1}", reply.requestID, reply.requestToken);

        //check the reply code
        if (!IsCodeInList(reply.reasonCode, m_ValidReplyReasonCodes))
        {
          mLogger.LogError(String.Format("Invalid Reason Code: {0}", reply.reasonCode));
          throw new PaymentProcessorException(String.Format("Invalid Reason Code: {0}", reply.reasonCode));
        }

        //check additional codes
        if (reply.ccAuthReply != null)
        {
          //perform CVN code check if there is one sent, one-time payment
          if (ccPaymentMethod.CVNumber != null)
          {
            if (!IsCodeInList(reply.ccAuthReply.cvCode, m_ValidCVNCodes))
            {
              //fix for CYBS bug in simulator that returns an empty AuthReply.cvCode if CVN.Length < 4
              if ((reply.ccAuthReply.cvCode != String.Empty) || (m_AllowBlankCodes != "1"))
              {
                mLogger.LogError(String.Format("Invalid Credit Card Verification Number; ccAuthReply.cvCode= {0}", reply.ccAuthReply.cvCode));
                throw new PaymentProcessorException(String.Format("Invalid Credit Card Verification Number; ccAuthReply.cvCode= {0}", reply.ccAuthReply.cvCode));
              }
            }
          }
          else
          {
            if (!IsCodeInList(reply.ccAuthReply.reasonCode, m_ValidReplyReasonCodes))
            {
              mLogger.LogError(String.Format("Invalid Credit Card Verification Number; ccAuthReply.reasonCode= {0}", reply.ccAuthReply.reasonCode));
              throw new PaymentProcessorException(String.Format("Invalid Credit Card Verification Number; ccAuthReply.reasonCode= {0}", reply.ccAuthReply.reasonCode));
            }
          }
        }
      }
      catch (PaymentProcessorException ppe)
      {
        mLogger.LogException("PaymentProcessorException Exception while capturing charge. ", ppe);
        throw ppe;
      }
      catch (MASBasicException mas)
      {
        mLogger.LogException("MAS Exception while pre-authorizing charge. ", mas);
        throw mas;
      }
      catch (TimeoutException e)
      {
        mLogger.LogException("TimeoutException: ", e);
        throw new MASBasicException("Timeout Exception while pre-authorizing charge.");
      }
      catch (FaultException e)
      {
        mLogger.LogException("FaultException: ", e);
        throw new MASBasicException("Fault Exception while pre-authorizing charge.");
      }
      catch (CommunicationException e)
      {
        mLogger.LogException("CommunicationException: ", e);
        throw new MASBasicException("Communication Exception while pre-authorizing charge.");
      }
      catch (Exception e)
      {
        mLogger.LogException("Exception while pre-authorizing charge. ", e);
        throw new MASBasicException("Exception while pre-authorizing charge.");
      }
    }

    public void CaptureCharge(CreditCardPaymentMethod ccPaymentMethod, ref MetraPaymentInfo paymentInfo, string requestParams, out string warnings)
    {
      warnings = "";
      RequestMessage request = InitializeRequest();

      // This is implementation specific, in another Processor there might be other params required
      string requestId = "", requestToken = "";
      string[] codes = requestParams.Split(';');
      requestId = codes[0];
      requestToken = codes[1];

      request.ccCaptureService = new CCCaptureService();
      request.ccCaptureService.run = "true";

      request.billTo = InitializeBillingInfo(ccPaymentMethod);
      request.card = InitializeCardInfo(ccPaymentMethod);
      request.purchaseTotals = InitializePurchaseTotals(ref paymentInfo);

      // let cybersource know the original pre-auth request id and token
      request.ccCaptureService.authRequestID = requestId;
      request.orderRequestToken = requestToken;

      try
      {
        TransactionProcessorClient proc = MASClientClassFactory.CreateClient<TransactionProcessorClient>(m_WCFConfigFile, m_EndpointName);

        proc.ClientCredentials.UserName.UserName = m_MerchantID;
        proc.ClientCredentials.UserName.Password = m_TransactionKey;

        mLogger.LogInfo("Submitting Capture request to CyberSource");
        ReplyMessage reply = proc.runTransaction(request);
        mLogger.LogInfo("decision = " + reply.decision + " reasonCode = " + reply.reasonCode + " requestID = " + reply.requestID);

        //TODO: Just doing this for now to move along with dev, need to identify a design that is good for other processors
        warnings = String.Format("{0};{1}", reply.requestID, reply.requestToken);

        //check the reply code
        if (!IsCodeInList(reply.reasonCode, m_ValidReplyReasonCodes))
        {

          mLogger.LogError(String.Format("Invalid Reason Code : {0} - RequestToken: {1} ", reply.reasonCode, reply.requestToken));
          throw new PaymentProcessorException(String.Format("Invalid Reason Code: {0} - RequestToken: {1} ", reply.reasonCode, reply.requestToken));

        }

        //check additional codes
        if (reply.ccCaptureReply != null)
        {
          //perform other code check
          if (!IsCodeInList(reply.ccCaptureReply.reasonCode, m_ValidReplyReasonCodes))
          {
            mLogger.LogError(String.Format("Unable to capture charge; ccCaptureReply.reasonCode = {0}, ", reply.ccCaptureReply.reasonCode));
            throw new PaymentProcessorException(String.Format("Unable to capture charge; ccCaptureReply.reasonCode = {0}, ", reply.ccCaptureReply.reasonCode));
          }
        }
      }
      catch (PaymentProcessorException ppe)
      {
        mLogger.LogException("PaymentProcessorException Exception while capturing charge. ", ppe);
        throw ppe;
      }
      catch (MASBasicException mas)
      {
        mLogger.LogException("MAS Exception while capturing charge. ", mas);
        throw mas;
      }
      catch (TimeoutException e)
      {
        mLogger.LogException("Timeout Exception while capturing charge. ", e);
        throw new MASBasicException("Timeout Exception while capturing charge.");
      }
      catch (FaultException e)
      {
        mLogger.LogException("Fault Exception while capturing charge. ", e);
        throw new MASBasicException("Fault Exception while capturing charge.");
      }
      catch (CommunicationException e)
      {
        mLogger.LogException("Communication Exception while capturing charge. ", e);
        throw new MASBasicException("Communication Exception while capturing charge.");
      }
      catch (Exception e)
      {
        mLogger.LogException("Exception while capturing charge. ", e);
        throw new MASBasicException("Exception while capturing charge.");
      }
    }

    public void Debit(MetraPaymentMethod paymentMethod, ref MetraPaymentInfo paymentInfo, out string warnings)
    {
      warnings = "";
      RequestMessage request = InitializeRequest();

      if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod))
      {
        request.ccAuthService = new CCAuthService();
        request.ccAuthService.run = "true";

        request.ccCaptureService = new CCCaptureService();
        request.ccCaptureService.run = "true";
        request.card = InitializeCardInfo(paymentMethod);
      }
      else if (paymentMethod.GetType() == typeof(ACHPaymentMethod))
      {
        request.ecDebitService = new ECDebitService();
        request.ecDebitService.run = "true";

        request.ecDebitService.settlementMethod = "F";
        request.check = InitializeCheckInfo(paymentMethod);
      }

      request.billTo = InitializeBillingInfo(paymentMethod);
      request.invoiceHeader = InitializeInvoiceHeader(ref paymentInfo);
      request.purchaseTotals = InitializePurchaseTotals(ref paymentInfo);

      try
      {
        TransactionProcessorClient proc = MASClientClassFactory.CreateClient<TransactionProcessorClient>(m_WCFConfigFile, m_EndpointName);

        proc.ClientCredentials.UserName.UserName = m_MerchantID;
        proc.ClientCredentials.UserName.Password = m_TransactionKey;

        mLogger.LogInfo("Submitting debit request to CyberSource");
        ReplyMessage reply = proc.runTransaction(request);

        mLogger.LogInfo("decision = " + reply.decision + " reasonCode = " + reply.reasonCode + " requestID = " + reply.requestID);


        //check the reply code
        if (!IsCodeInList(reply.reasonCode, m_ValidReplyReasonCodes))
        {
          mLogger.LogError(String.Format("Unable to process debit request: {0} - RequestToken: {1} ", reply.reasonCode, reply.requestToken));
          throw new PaymentProcessorException(String.Format("Unable to process debit request: {0} - RequestToken: {1} ", reply.reasonCode, reply.requestToken));
        }
        else
        {
          warnings = reply.requestToken;
        }

        if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod))
        {
          // check the capture request
          if (reply.ccCaptureReply != null)
          {
            if (!IsCodeInList(reply.ccCaptureReply.reasonCode, m_ValidReplyReasonCodes))
            {
              mLogger.LogError(String.Format("Unable to process debit request; ccCaptureReply.reasonCode = {0}, ", reply.ccCaptureReply.reasonCode));
              throw new PaymentProcessorException(String.Format("Unable to process debit request for debit; ccCaptureReply.reasonCode = {0}, ", reply.ccCaptureReply.reasonCode));
            }
          }
        }
        else
        {
          if (reply.ecDebitReply != null)
          {
            if (!IsCodeInList(reply.ecDebitReply.reasonCode, m_ValidReplyReasonCodes))
            {
              mLogger.LogError(String.Format("Unable to process debit request; ecDebitReply.reasonCode = {0}, ", reply.ecDebitReply.reasonCode));
              throw new PaymentProcessorException(String.Format("Unable to process debit request for debit; ecDebitReply.reasonCode = {0}, ", reply.ecDebitReply.reasonCode));
            }
          }
        }

      }
      catch (PaymentProcessorException ppe)
      {
        mLogger.LogException("PaymentProcessorException Exception while submitting debit request. ", ppe);
        throw ppe;
      }
      catch (MASBasicException mas)
      {
        mLogger.LogException("MAS Exception while submitting debit request. ", mas);
        throw mas;
      }
      catch (TimeoutException e)
      {
        mLogger.LogException("Timeout Exception while submitting debit request. ", e);
        throw new MASBasicException("Timeout Exception while submitting debit request.");
      }
      catch (FaultException e)
      {
        mLogger.LogException("Fault Exception while submitting debit request. ", e);
        throw new MASBasicException("Fault Exception while submitting debit request.");
      }
      catch (CommunicationException e)
      {
        mLogger.LogException("Communication Exception while submitting debit request. ", e);
        throw new MASBasicException("Communication Exception while submitting debit request.");
      }
      catch (Exception e)
      {
        mLogger.LogException("Exception while submitting debit request. ", e);
        throw new MASBasicException("Exception while submitting debit request.");
      }
    }

    // TODO: We are not supporting follow on credits only standalone credits.  This needs to be further confirmed.
    // Note You cannot automatically do stand-alone credits for cards processed through the CyberSource Global Payment Service. Contact Customer Support if you want to do stand-alone credits with the Global Payment Service.
    // TODO: just doing this for credit cards right now
    public void Credit(MetraPaymentMethod paymentMethod, ref MetraPaymentInfo paymentInfo, out string warnings)
    {
      warnings = "";
      RequestMessage request = InitializeRequest();

      if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod))
      {
        request.ccCreditService = new CCCreditService();
        request.ccCreditService.run = "true";
        request.card = InitializeCardInfo(paymentMethod);
      }
      else
      {
        request.ecCreditService = new ECCreditService();
        request.ecCreditService.run = "true";
        request.check = InitializeCheckInfo(paymentMethod);
        request.ecCreditService.settlementMethod = "B";
      }

      request.billTo = InitializeBillingInfo(paymentMethod);
      request.purchaseTotals = InitializePurchaseTotals(ref paymentInfo);
      try
      {
        TransactionProcessorClient proc = MASClientClassFactory.CreateClient<TransactionProcessorClient>(m_WCFConfigFile, m_EndpointName);

        proc.ClientCredentials.UserName.UserName = m_MerchantID;
        proc.ClientCredentials.UserName.Password = m_TransactionKey;

        mLogger.LogInfo("Submitting Credit request to CyberSource");
        ReplyMessage reply = proc.runTransaction(request);
        mLogger.LogInfo("decision = " + reply.decision + " reasonCode = " + reply.reasonCode + " requestID = " + reply.requestID);

        //TODO: Just doing this for now to move along with dev, need to identify a design that is good for other processors
        warnings = String.Format("{0};{1}", reply.requestID, reply.requestToken);

        //check the reply code
        if (!IsCodeInList(reply.reasonCode, m_ValidReplyReasonCodes))
        {
          mLogger.LogError(String.Format("Unable to  process credit request: {0} - RequestToken: {1} ", reply.reasonCode, reply.requestToken));
          throw new PaymentProcessorException(String.Format("Unable to process credit request: {0} - RequestToken: {1} ", reply.reasonCode, reply.requestToken));
        }

        if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod))
        {
          //check additional codes
          if (reply.ccCreditReply != null)
          {
            //perform credit reply check
            if (!IsCodeInList(reply.ccCreditReply.reasonCode, m_ValidReplyReasonCodes))
            {
              mLogger.LogError(String.Format("Unable to process credit request; ccCaptureReply.reasonCode = {0}, ", reply.ccCaptureReply.reasonCode));
              throw new PaymentProcessorException(String.Format("Unable to process credit request for credit; ccCaptureReply.reasonCode = {0}, ", reply.ccCaptureReply.reasonCode));
            }
          }
        }
        else
        {
          //check additional codes
          if (reply.ecCreditReply != null)
          {
            //perform credit reply check
            if (!IsCodeInList(reply.ecCreditReply.reasonCode, m_ValidReplyReasonCodes))
            {
              mLogger.LogError(String.Format("Unable to process credit request; ecCreditReply.reasonCode = {0}, ", reply.ecCreditReply.reasonCode));
              throw new PaymentProcessorException(String.Format("Unable to process credit request for credit; ecCreditReply.reasonCode = {0}, ", reply.ecCreditReply.reasonCode));
            }
          }
        }
      }
      catch (PaymentProcessorException ppe)
      {
        mLogger.LogException("PaymentProcessorException Exception while processing credit request.", ppe);
        throw ppe;
      }
      catch (MASBasicException mas)
      {
        mLogger.LogException("MAS Exception while processing credit request. ", mas);
        throw mas;
      }
      catch (TimeoutException e)
      {
        mLogger.LogException("Timeout Exception while processing credit request. ", e);
        throw new MASBasicException("Timeout Exception while processing credit request.");
      }
      catch (FaultException e)
      {
        mLogger.LogException("Fault Exception while processing credit request. ", e);
        throw new MASBasicException("Fault Exception while processing credit request.");
      }
      catch (CommunicationException e)
      {
        mLogger.LogException("Communication Exception while processing credit request. ", e);
        throw new MASBasicException("Communication Exception while processing credit request.");
      }
      catch (Exception e)
      {
        mLogger.LogException("Exception while processing credit request. ", e);
        throw new MASBasicException("Exception while processing credit request.");
      }
    }

    public void Void(MetraPaymentMethod paymentMethod, ref MetraPaymentInfo paymentInfo, out string warnings)
    {
      throw new Exception("The method or operation is not implemented.");
    }

    public bool GetACHTransactionStatus(string transactionId, out string warnings)
    {
      warnings = "";
      bool found = false;

      foreach (DataRow dr in m_Checks.Rows)
      {
        string txRefNum = dr["TransactionReferenceNumber"].ToString().Trim();

        if (txRefNum.Equals(transactionId))
        {
          string merchantCurrency = dr["MerchantCurrencyCode"].ToString().Trim();
          string merchantAmount = dr["MerchantAmount"].ToString().Trim();
          string consumerCurrencyCode = dr["ConsumerCurrencyCode"].ToString().Trim();
          string consumerAmount = dr["ConsumerAmount"].ToString().Trim();
          string feeCurrencyCode = dr["FeeCurrencyCode"].ToString().Trim();
          string feeAmount = dr["FeeAmount"].ToString().Trim();

          mLogger.LogDebug("Check Details: {0} {1} {2} {3} {4} {5} ", txRefNum, merchantCurrency, merchantAmount, consumerCurrencyCode, consumerAmount, feeCurrencyCode);
          found = true;
          break;
        }
      }
      return found;
    }

    public void DownloadACHTransactionsReport(string url, out string warnings)
    {
      warnings = "";

      // clear out what we have and redownload the report
      if (m_Checks.Rows.Count > 0)
        m_Checks.Rows.Clear();

      m_Checks = GetACHTxReport(url, "Check");
      
      mLogger.LogDebug("Report contains data for {0} checks that have been processed", m_Checks.Rows.Count);
    }

    public void GetCreditCardUpdates(string transactionId, System.Collections.Generic.List<CreditCardPaymentMethod> cardsToUpdate, ref System.Collections.Generic.List<CreditCardPaymentMethod> updatedCards)
    {
        mLogger.LogError("Call to GetCreditCardUpdates not implemented...doing nothing");
    }

    public void ReverseAuthorizedCharge(CreditCardPaymentMethod paymentMethod, ref MetraPaymentInfo paymentInfo, string requestParams, out string warnings)
    {
        requestParams = string.Empty;
        warnings = string.Empty;
    }

    #endregion

    #region Virtual Methods
    /// <summary>
    /// Retrieve Cybersource code based on MT credit card type enum
    /// </summary>
    /// <param name="creditCardType">MT credit type enum value</param>
    /// <returns>Cybersource code</returns>
    protected virtual string GetCardType(MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType creditCardType)
    {
      string retval = null;

      switch (creditCardType)
      {
        case MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType.Visa:
          retval = "001";
          break;

        case MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType.MasterCard:
          retval = "002";
          break;

        case MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType.American_Express:
          retval = "003";
          break;

        case MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType.Discover:
          retval = "004";
          break;

        case MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType.Diners_Club:
          retval = "005";
          break;

        case MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType.JCB:
          retval = "007";
          break;

        //case MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType.Maestro:
        //  retval = "042";
        //  break;
      }

      return retval;
    }

    /// <summary>
    /// Sets purchase totals to $0 for authorization
    /// </summary>
    /// <returns></returns>
    protected virtual PurchaseTotals InitializeValidationPurchaseTotals()
    {
      PurchaseTotals purchaseTotals = new PurchaseTotals();
      purchaseTotals.currency = m_ValidationCurrency;
      purchaseTotals.grandTotalAmount = m_ValidationAmount;
      return purchaseTotals;
    }

    protected virtual PurchaseTotals InitializePurchaseTotals(ref MetraPaymentInfo paymentInfo)
    {
      PurchaseTotals purchaseTotals = new PurchaseTotals();
      purchaseTotals.currency = paymentInfo.Currency;
      purchaseTotals.grandTotalAmount = paymentInfo.Amount.ToString();
      return purchaseTotals;
    }

    protected virtual InvoiceHeader InitializeInvoiceHeader(ref MetraPaymentInfo paymentInfo)
    {
      InvoiceHeader invHeader = new InvoiceHeader();
      invHeader.merchantDescriptor = "ClientName" + paymentInfo.InvoiceNum;    // client name + invoice id
      invHeader.merchantDescriptorContact = m_MerchantContactNumber;    // should be phone number from the config file
      return invHeader;
    }

    /// <summary>
    /// Initializes Card object with credit card information received in CreditCardPaymentMethod object
    /// </summary>
    /// <returns></returns>
    protected virtual Card InitializeCardInfo(MetraPaymentMethod paymentMethod)
    {
      Card card = new Card();
      CreditCardPaymentMethod creditCardInfo = (CreditCardPaymentMethod)paymentMethod;
      if (!String.IsNullOrEmpty(creditCardInfo.AccountNumber))
      {
        card.accountNumber = creditCardInfo.RawAccountNumber;
      }

      string expirationMonth = String.Empty;
      string expirationYear = string.Empty;

      creditCardInfo.GetExpirationDate(out expirationMonth, out expirationYear);
      card.expirationMonth = expirationMonth;
      card.expirationYear = expirationYear;

      card.cardType = GetCardType(creditCardInfo.CreditCardType);

      if (!String.IsNullOrEmpty(creditCardInfo.CVNumber))
      {
        card.cvNumber = creditCardInfo.CVNumber;
      }

      return card;
    }

    /// <summary>
    /// Initializes Check object with check information received in ACHPaymentMethod object
    /// </summary>
    /// <returns></returns>
    protected virtual Check InitializeCheckInfo(MetraPaymentMethod paymentMethod)
    {
      Check check = new Check();
      ACHPaymentMethod achInfo = (ACHPaymentMethod)paymentMethod;
      if (!String.IsNullOrEmpty(achInfo.AccountNumber))
      {
        check.accountNumber = achInfo.RawAccountNumber;
      }
      check.accountType = "c";
      check.bankTransitNumber = achInfo.RoutingNumber;
      return check;
    }
    /// <summary>
    /// Initializes the BillTo object with data from creditCardInfo object
    /// </summary>
    /// <returns>Populated BillTo object</returns>
    protected virtual BillTo InitializeBillingInfo(MetraPaymentMethod creditCardInfo)
    {
      BillTo billTo = new BillTo();
      billTo.email = "null@cybersource.com";

      //string tmpFirstName = String.Empty;
      //string tmpLastName = String.Empty;

      //SplitCustomerName(creditCardInfo, out tmpFirstName, out tmpLastName);
      billTo.firstName = creditCardInfo.FirstName;
      billTo.middleName = creditCardInfo.MiddleName;
      billTo.lastName = creditCardInfo.LastName;

      if (!String.IsNullOrEmpty(creditCardInfo.Street))
      {
        billTo.street1 = creditCardInfo.Street;
      }

      if (!String.IsNullOrEmpty(creditCardInfo.Street2))
      {
        billTo.street2 = creditCardInfo.Street2;
      }

      if (!String.IsNullOrEmpty(creditCardInfo.City))
      {
        billTo.city = creditCardInfo.City;
      }

      if (!String.IsNullOrEmpty(creditCardInfo.State))
      {
        billTo.state = creditCardInfo.State;
      }
      if (!String.IsNullOrEmpty(creditCardInfo.ZipCode))
      {
        billTo.postalCode = creditCardInfo.ZipCode;
      }

      billTo.country = (string)EnumHelper.GetValueByEnum(creditCardInfo.Country);

      return billTo;
    }

    /// <summary>
    /// Initializes RequestMessage object to be used for MSFT .NET WCF service implementation
    /// </summary>
    /// <returns></returns>
    protected virtual RequestMessage InitializeRequest()
    {
      RequestMessage request = new RequestMessage();

      request.merchantID = m_MerchantID;

      // Before using this example, replace the generic value with your
      // reference number for the current transaction.
      request.merchantReferenceCode = m_ReferenceCode;

      // To help us troubleshoot any problems that you may encounter,
      // please include the following information about your application.
      request.clientLibrary = ".NET WCF";
      request.clientLibraryVersion = Environment.Version.ToString();
      request.clientEnvironment =
          Environment.OSVersion.Platform +
          Environment.OSVersion.Version.ToString();

      return request;
    }

    protected virtual DataTable GetACHTxReport(string url, string elementName)
    {
      XmlTextReader reportReader = new XmlTextReader(url);
      XmlDocument report = new XmlDocument();
      report.Load(reportReader);

      if (m_Checks.Columns.Count == 0)
      {
        // TODO: Maybe create a virtual method that inititializes this
        m_Checks.Columns.Add("TransactionReferenceNumber", typeof(string));
        m_Checks.Columns.Add("MerchantCurrencyCode", typeof(string));
        m_Checks.Columns.Add("MerchantAmount", typeof(string));
        m_Checks.Columns.Add("ConsumerCurrencyCode", typeof(string));
        m_Checks.Columns.Add("ConsumerAmount", typeof(string));
        m_Checks.Columns.Add("FeeCurrencyCode", typeof(string));
        m_Checks.Columns.Add("FeeAmount", typeof(string));
      }
      XmlNodeList checks = report.GetElementsByTagName("Check");
      
      for (int i = 0; i < checks.Count; i++)
      {
        DataRow dr = m_Checks.NewRow();
        
        for (int j = 0; j < m_Checks.Columns.Count; j++)
        {
          dr[j] = checks.Item(i).ChildNodes[j].InnerText;
        }
        m_Checks.Rows.Add(dr);
      }
      
      return m_Checks;
    }
    #endregion

    #region Private Methods
    /// <summary>
    /// Splits MT Customer name field into first name and last name by finding the first empty space.
    /// </summary>
    /// <param name="firstName"></param>
    /// <param name="lastName"></param>
    //private void SplitCustomerName(MetraPaymentMethod creditCardInfo, out string firstName, out string lastName)
    //{
    //  firstName = string.Empty;
    //  lastName = string.Empty;

    //  if (String.IsNullOrEmpty(creditCardInfo.CustomerName))
    //  {
    //    mLogger.LogWarning("Customer name is empty");
    //    return;
    //  }

    //  //split the name around the space and return maximum of two substrings
    //  string[] splitName = creditCardInfo.CustomerName.Trim().Split(new Char[] { ' ' }, 2);

    //  if (splitName.Length == 0)
    //  {
    //    mLogger.LogWarning("Unable to split customer name " + creditCardInfo.CustomerName);
    //    return;
    //  }

    //  if (splitName.Length == 1)
    //  {
    //    mLogger.LogInfo("Only one word in customer name: " + creditCardInfo.CustomerName + ". Copying to firstName and lastName");
    //    firstName = creditCardInfo.CustomerName.Trim();
    //    lastName = firstName;

    //    return;
    //  }

    //  if (splitName.Length > 2)
    //  {
    //    mLogger.LogWarning("Customer name " + creditCardInfo.CustomerName + " was split in more than two parts. Use first two for firstName and lastName");
    //  }

    //  firstName = splitName[0].Trim();
    //  lastName = splitName[1].Trim();
    //}

    /// <summary>
    /// Checks if the code is present in the codeList parameter
    /// </summary>
    /// <param name="code"></param>
    /// <param name="codeList"></param>
    /// <returns></returns>
    private bool IsCodeInList(string code, string codeList)
    {
      bool bResult = false;

      //false if empty code
      if (String.IsNullOrEmpty(code) || String.IsNullOrEmpty(code.Trim()))
      {
        return false;
      }

      //false if list is empty
      if (String.IsNullOrEmpty(codeList) || String.IsNullOrEmpty(codeList.Trim()))
      {
        return false;
      }

      string[] codes = codeList.Split(new char[] { ',', ';', ' ' });

      //attempt to find the code in the list
      foreach (string curCode in codes)
      {
        if (curCode.ToLower().Trim() == code.ToLower())
        {
          return true;
        }
      }

      return bResult;
    }
    #endregion
  }
}
