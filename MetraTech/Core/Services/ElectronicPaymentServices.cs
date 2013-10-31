using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
using System.ServiceModel;
using System.Threading;

using MetraTech.ActivityServices.Services.Common;

using MetraTech.ActivityServices.Common;
using MetraTech.Auth.Capabilities;
using MetraTech.Domain;
using MetraTech.DomainModel.Enums.Core.Metratech_com;
using MetraTech.DomainModel.Billing;
using MetraTech.DomainModel.MetraPay;
using MetraTech.Interop.MTAuth;
using MetraTech.MetraPay.Client;
using System.Security.Cryptography.X509Certificates;
using MetraTech.DataAccess;
using MetraTech.DomainModel.Enums;
using MetraTech.Interop.RCD;
using System.Configuration;
using System.IO;
using MetraTech.Interop.MTAuditEvents;
using System.Transactions;
using System.Xml;
using MetraTech.DomainModel.Enums.Core.Metratech_com_balanceadjustments;
using MetraTech.DomainModel.Enums.PaymentSvrClient.Metratech_com_paymentserver;
using MetraTech.Security.Crypto;
using System.Security.Cryptography;
using System.Reflection;
using System.ServiceModel.Description;
using MetraTech.ActivityServices.Runtime;
using MetraTech.Interop.QueryAdapter;
using System.Data;
using System.Linq.Expressions;
using System.Linq;
using MetraTech.Debug.Diagnostics;
using DatabaseUtils = MetraTech.Domain.DataAccess.DatabaseUtils;

namespace MetraTech.Core.Services
{
  #region Interfaces
  /// <summary>
  /// The IRecurringPaymentsService interface defines the methods clients can use to manage and credit/debit
  /// stored payment methods.  The payment method must be stored in the MetraPay server prior to submittting
  /// credits or debits.  
  /// </summary>
  [ServiceContract()]
  public interface IRecurringPaymentsService
  {
    /// <summary>
    /// The GetPaymentMethodSummaries method retrieves a collection of stored payment method summaries
    /// for the specified account.  These summaries do not contain any information that could be
    /// used to compromise the credit card.  Any account-specified information is truncated so
    /// that it is not visible to the client.
    /// </summary>
    /// <param name="acct">This identifies the MetraNet account that owns the requested payment
    /// method information.</param>
    /// <param name="paymentMethods">This is an MTList that stores the MetraPaymentMethod instances
    /// that contain the information about the payment methods for the specified account. </param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetPaymentMethodSummaries(AccountIdentifier acct, ref MTList<MetraPaymentMethod> paymentMethods);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetPaymentMethodDetail(AccountIdentifier acct, Guid token, out MetraPaymentMethod paymentMethod);

    /// <summary>
    /// Associates the payment method identified by token with the account specified in AccountIdentifier
    /// </summary>
    /// <param name="token">This token is returned from the MetraPay server and uniquely 
    /// identifies that payment method in the system.  This token will be associated with 
    /// MetraNet account that is identified by acct.AccountID</param>
    /// <param name="acct">This identifies the account to which the payment method is to be 
    /// associated</param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void AssignPaymentMethodToAccount(Guid token, AccountIdentifier acct);

    /// <summary>
    /// The AddPaymentMethod method adds a new payment method to the system for the specified 
    /// user account.
    /// </summary>
    /// <param name="acct">This identifies the account to which the payment method is to be 
    /// associated</param>
    /// <param name="paymentMethod">This contains all the information about the payment method 
    /// (type, account numbers, etc.</param>
    /// <param name="token">This token is returned from the MetraPay server and uniquely 
    /// identifies that payment method in the system</param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    void AddPaymentMethod(AccountIdentifier acct, MetraPaymentMethod paymentMethod, out Guid token);

    /// <summary>
    /// The UpdatePaymentMethod method takes updated payment method information and overwrites the
    /// existing payment method information with the new data.  The original payment method is
    /// identified by the specified token.
    /// </summary>
    /// <param name="acct">Represents the account that owns the payment method</param>
    /// <param name="token">This identifies the payment method record to be updated.</param>
    /// <param name="paymentMethod">This MetraPaymentMethod instance contains the information
    /// to be written to the database to update the payment method.</param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    void UpdatePaymentMethod(AccountIdentifier acct, Guid token, MetraPaymentMethod paymentMethod);

    /// <summary>
    /// The UpdatePriority method updates the priority for a given payment instrument and ensures
    /// that there are no duplicates and no gaps.
    /// </summary>
    /// <param name="acct">The account that owns the payment method</param>
    /// <param name="token">The identiifer of the payment instrument to be modified</param>
    /// <param name="priority">The new priority value to be used (e.g. where in the list)</param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void UpdatePriority(AccountIdentifier acct, Guid token, int priority);

    /// <summary>
    /// The DeletePaymentMethod method is used to delete a stored payment method from the system. 
    /// This removes all traces of the payment method, especially the encrypted account information.
    /// </summary>
    /// <param name="acct">Represents the account that owns the payment method</param>
    /// <param name="token">This Guid uniquely identifies the payment method in the system.  This is the
    /// payment method to be deleted.</param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DeletePaymentMethod(AccountIdentifier acct, Guid token);

    /// <summary>
    /// The GetACHTransactionStatus submit a status request to the payment processor.
    /// </summary>
    /// <param name="transactionId">The transaction id whose status will be looked up</param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    void GetACHTransactionStatus(string transactionId, out bool bProcessed);

    /// <summary>
    /// DownloadACHTransactionsReport downloads the ACH transaction report from a particular url
    /// </summary>
    /// <param name="url">location of the ACH report</param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    void DownloadACHTransactionsReport(string url);

    /// <summary>
    /// 
    /// </summary>
    /// <param name="acct"></param>
    /// <param name="ccPaymentInstrument"></param>
    /// <param name="paymentInfo"></param>
    /// <param name="instrumentToken"></param>
    /// <param name="authToken"></param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    [TransactionFlow(TransactionFlowOption.Allowed)]
    void AddCCAndAuthorizeCharge(AccountIdentifier acct,
                                    CreditCardPaymentMethod ccPaymentInstrument,
                                    ref MetraPaymentInfo paymentInfo,
                                    out Guid instrumentToken,
                                    out Guid authToken);

    /// <summary>
    /// 
    /// </summary>
    /// <param name="acct"></param>
    /// <param name="token"></param>
    /// <param name="paymentMethod"></param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void UpdatePaymentMethodNoCheck(AccountIdentifier acct, Guid token, MetraPaymentMethod paymentMethod);

    /// <summary>
    /// 
    /// </summary>
    /// <param name="authToken"></param>
    /// <param name="paymentToken"></param>
    /// <param name="paymentInfo"></param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    void ReverseChargeAuthorization(Guid authToken, Guid paymentToken, ref MetraPaymentInfo paymentInfo);

    /// <summary>
    /// 
    /// </summary>
    /// <param name="paymentToken"></param>
    /// <param name="paymentDate"></param>
    /// <param name="tryDunning"></param>
    /// <param name="paymentInfo"></param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void SchedulePayment(Guid paymentToken, DateTime paymentDate, bool tryDunning, ref MetraPaymentInfo paymentInfo);
    /// <summary>
    /// The DebitPaymentMethod method submits a debit request to the payment process and stores the result.
    /// The MetraPaymentInfo instance stores the information about the amount, the currency, etc. of
    /// the debit request.
    /// </summary>
    /// <param name="token">This identifies the payment method that is to be debited</param>
    /// <param name="paymentInfo">This stores the information about the debit request, such as the
    /// ammount, currency, etc.</param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    void DebitPaymentMethod(Guid token, ref MetraPaymentInfo paymentInfo);

    /// <summary>
    /// The CreditPaymentMethod method submits a credit request to the payment processor for the
    /// specified payment method.
    /// </summary>
    /// <param name="token">This uniquely identifies the payment method in the system that is to be credited</param>
    /// <param name="paymentInfo">This instance stores the information about the credit request, such
    /// as the amount, currency, etc.</param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    void CreditPaymentMethod(Guid token, ref MetraPaymentInfo paymentInfo);



    /// <summary>
    /// This method submits an authorization request to the payment processor.  This request checks
    /// to see if the specified amount is available on the payment method, and if it is, places a 
    /// lock on that amount so that it can be captured later.
    /// </summary>
    /// <param name="methodToken">This uniquely identifies the payment method in the system to which
    /// the authorization request is to be submitted</param>
    /// <param name="estimatedPaymentInfo">This MetraPaymentInfo instance stores the information to be submitted
    /// in the authorization request.  The amount specified does not have to match the amount
    /// that is ultimately charged to the account.</param>
    /// <param name="authorizationToken">This returns the token that identifies the information stored in the sytem
    /// about the authorization request</param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    void PreAuthorizeCharge(Guid methodToken, ref MetraPaymentInfo estimatedPaymentInfo, out Guid authorizationToken);

    /// <summary>
    /// The CapturePreauthorizedCharge method submits a capture request to the payment processor.  This method
    /// must be called after a PreAuthorizeCharge method has been called and it has succeeded.  The actualPaymentInfo
    /// paramter stores the amount that is to be actually charged to the payment method.
    /// </summary>
    /// <param name="authorizationToken">This token identifies the information that was previously stored in the system
    /// by a successful call to the PreAuthorizeCharge method</param>
    /// <param name="actualPaymentinfo">This parameter stores the information about the charge that is to be placed on the payment method.</param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    void CapturePreauthorizedCharge(Guid authorizationToken, Guid paymentToken, ref MetraPaymentInfo actualPaymentinfo);
    /// <summary>
    /// The DebitPaymentMethod method submits a debit request to the payment process and stores the result.
    /// The MetraPaymentInfo instance stores the information about the amount, the currency, etc. of
    /// the debit request.
    /// </summary>
    /// <param name="token">This identifies the payment method that is to be debited</param>
    /// <param name="paymentInfo">This stores the information about the debit request, such as the
    /// ammount, currency, etc.</param>
    /// <param name="timeOut">Timeout in milliseconds.  After the timeout, EPS guarantees to reverse the debit.</param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    void DebitPaymentMethodV2(Guid token, ref MetraPaymentInfo paymentInfo, double timeOut, string classOfService);

    /// <summary>
    /// The CreditPaymentMethod method submits a credit request to the payment processor for the
    /// specified payment method.
    /// </summary>
    /// <param name="token">This uniquely identifies the payment method in the system that is to be credited</param>
    /// <param name="paymentInfo">This instance stores the information about the credit request, such
    /// as the amount, currency, etc.</param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    void CreditPaymentMethodV2(Guid token, ref MetraPaymentInfo paymentInfo, double timeOut, string classOfService);



    /// <summary>
    /// This method submits an authorization request to the payment processor.  This request checks
    /// to see if the specified amount is available on the payment method, and if it is, places a 
    /// lock on that amount so that it can be captured later.
    /// </summary>
    /// <param name="methodToken">This uniquely identifies the payment method in the system to which
    /// the authorization request is to be submitted</param>
    /// <param name="estimatedPaymentInfo">This MetraPaymentInfo instance stores the information to be submitted
    /// in the authorization request.  The amount specified does not have to match the amount
    /// that is ultimately charged to the account.</param>
    /// <param name="authorizationToken">This returns the token that identifies the information stored in the sytem
    /// about the authorization request</param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    void PreAuthorizeChargeV2(Guid methodToken, ref MetraPaymentInfo estimatedPaymentInfo, out Guid authorizationToken, double timeOut, string classOfService);

    /// <summary>
    /// The CapturePreauthorizedCharge method submits a capture request to the payment processor.  This method
    /// must be called after a PreAuthorizeCharge method has been called and it has succeeded.  The actualPaymentInfo
    /// paramter stores the amount that is to be actually charged to the payment method.
    /// </summary>
    /// <param name="authorizationToken">This token identifies the information that was previously stored in the system
    /// by a successful call to the PreAuthorizeCharge method</param>
    /// <param name="actualPaymentinfo">This parameter stores the information about the charge that is to be placed on the payment method.</param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    void CapturePreauthorizedChargeV2(Guid authorizationToken, Guid paymentToken, ref MetraPaymentInfo actualPaymentinfo, double timeOut, string classOfService);

  }

  /// <summary>
  /// The IOneTimePaymentService interface is implemented by services that support one time payments
  /// to payment methods (such as Credit Cards or ACH).  One time payments do not store the payment
  /// method information in the MetraNet or MetraPay systems.  Rather it is transient data that is only
  /// in the system long enough to process the requested credit or debit.
  /// </summary>
  [ServiceContract]
  public interface IOneTimePaymentService
  {
    /// <summary>
    /// The OneTimeDebit method submits a debit request to the payment processor and stores the result.
    /// </summary>
    /// <param name="paymentMethod">This MetraPaymentMethod instance stores all the information about the payment method to be debited</param>
    /// <param name="paymentInfo">This MetraPaymentInfo instance stores the information about the debit transaction</param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    void OneTimeDebit(AccountIdentifier acct, MetraPaymentMethod paymentMethod, ref MetraPaymentInfo paymentInfo);

    /// <summary>
    /// The OneTimeCredit method submits a credit request to the payment process and stores the result.
    /// </summary>
    /// <param name="paymentMethod">This MetraPaymentMethod instance stores all the information about the payment method to be credited</param>
    /// <param name="paymentInfo">This MetraPaymentInfo instance stores all the information about the credit transaction</param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    void OneTimeCredit(AccountIdentifier acct, MetraPaymentMethod paymentMethod, ref MetraPaymentInfo paymentInfo);
  }

  /// <summary>
  /// The IOneTimePaymentServiceV2 interface is implemented by services that support one time payments
  /// to payment methods (such as Credit Cards or ACH).  One time payments do not store the payment
  /// method information in the MetraNet or MetraPay systems.  Rather it is transient data that is only
  /// in the system long enough to process the requested credit or debit.  It is like the IOneTimePaymentService
  /// interface, with the addition of timeouts.
  /// </summary>
  [ServiceContract]
  public interface IOneTimePaymentServiceV2
  {
    /// <summary>
    /// The OneTimeDebit method submits a debit request to the payment processor and stores the result.
    /// </summary>
    /// <param name="paymentMethod">This MetraPaymentMethod instance stores all the information about the payment method to be debited</param>
    /// <param name="paymentInfo">This MetraPaymentInfo instance stores the information about the debit transaction</param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    void OneTimeDebitV2(AccountIdentifier acct, MetraPaymentMethod paymentMethod, ref MetraPaymentInfo paymentInfo, double timeOut, string classOfService);

    /// <summary>
    /// The OneTimeCredit method submits a credit request to the payment process and stores the result.
    /// </summary>
    /// <param name="paymentMethod">This MetraPaymentMethod instance stores all the information about the payment method to be credited</param>
    /// <param name="paymentInfo">This MetraPaymentInfo instance stores all the information about the credit transaction</param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    void OneTimeCreditV2(AccountIdentifier acct, MetraPaymentMethod paymentMethod, ref MetraPaymentInfo paymentInfo, double timeOut, string classOfService);
  }

  [ServiceContract]
  public interface ICleanupTransactionService
  {
    /// <summary>
    /// The Void method submits a void request to the payment processor for a transaction that failed.
    /// If the payment processor reports the transaction as already settled, the Void() will reverse the transaction,
    /// doing a debit or credit as required.
    /// </summary>
    /// <param name="transactionId">This is the transaction that failed</param>
    /// <param name="timeOut">Timeout for this operation.</param>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    void VoidTransaction(Guid transactionId, double timeOut = 0, string classOfService = "");

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetPaymentTransactions(ref MTList<PaymentTransaction> paymentTransactions);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void SetPaymentStatus(List<Guid> transactionIds, TransactionState status, string notes);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void ResetNumOpenTransactions();

  }

  [ServiceContract]
  public interface IBatchUpdaterService
  {
    [OperationContract(IsOneWay = true)]
    void UpdateCreditCards(string transactionId, BatchUpdaterParameters parameters);
  }

  [ServiceContract]
  public interface IARPaymentIntegration
  {
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    string InitiatePayment(int acctId, Guid paymentInstrumentId, MetraPaymentInfo paymentInfo);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void PaymentFailed(string requestId);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void PaymentSucceed(string requestId);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void PaymentAbandoned(string requestId);
  }

  #endregion

  [ServiceBehavior(ConcurrencyMode = ConcurrencyMode.Multiple, InstanceContextMode = InstanceContextMode.Single)]
  public class ElectronicPaymentServices
  : CMASServiceBase, IRecurringPaymentsService, IOneTimePaymentService, IBatchUpdaterService, ICleanupTransactionService,
  IOneTimePaymentServiceV2
  {
    private static Logger mLogger = new Logger("[ElectronicPaymentService]");
    Auditor auditor = new Auditor();

    private static MemoryStream m_RouterXoml = null;
    private static MemoryStream m_RouterRules = null;
    private static EPSConfig m_EPSConfig = null;

    //private static string m_InsertSchedPymtQuery = null;
    private static string m_InsertSchedPymtDetailsQuery = null;

    private static Stack<GetPaymentRecord> mGetPaymentRecord = new Stack<GetPaymentRecord>();
    private static IARPaymentIntegration mArPaymentIntegrationImpl;

    private static int m_OpenTransactions = 0;
    private static DateTime m_NextTransactionCheck = DateTime.MinValue;

    static ElectronicPaymentServices()
    {
      CMASServiceBase.ServiceStarting += new ServiceStartingEventHandler(CMASServiceBase_ServiceStarting);
    }

    static void CMASServiceBase_ServiceStarting()
    {
      InitializeRouterWorkflow();

      // Reading in EPS Config related . . .
      Configuration config = LoadConfigurationFile(@"ElectronicPaymentServices\EPSHost.xml");

      EPSConfig epsConfig = config.GetSection("EPSConfig") as EPSConfig;
      m_EPSConfig = epsConfig;

      IMTQueryAdapter qa = new MTQueryAdapter();
      qa.Init(@"Queries\ElectronicPaymentService");
      qa.SetQueryTag("__INSERT_SCHEDULED_PAYMENT_DETAILS__");
      m_InsertSchedPymtDetailsQuery = qa.GetQuery();
      //IMTQueryAdapter qa = new MTQueryAdapterClass();
      //qa.Init("Queries\\ElectronicPaymentService");
      //qa.SetQueryTag("__INSERT_SCHEDULED_PAYMENT__");
      //m_InsertSchedPymtQuery = qa.GetQuery();

      try
      {
        mLogger.LogInfo("ArImplementation Assembly Name :" + m_EPSConfig.ArPayImplementation.Type);
        if (!string.IsNullOrEmpty(m_EPSConfig.ArPmtImplType))
        {
          mArPaymentIntegrationImpl = Activator.CreateInstance(Type.GetType(m_EPSConfig.ArPmtImplType)) as IARPaymentIntegration;
        }
      }
      catch (Exception excp)
      {
        mLogger.LogException("Error while instantiating ARPaymentIntegration. ", excp);
      }

    }

    private void FireAuditEvent(MTAuditEvent auditEvent, int accountID, string auditInfo = "", string details = "", AccountIdentifier acct = null, Guid token = default(Guid))
    {
      string accIdentifire = string.Empty;
      string tokenString = string.Empty;

      if (acct != null)
        accIdentifire = acct.AccountID.HasValue ? acct.AccountID.Value.ToString() : acct.Username;

      if (token != default(Guid))
        tokenString = token.ToString();

      auditor.FireEventWithAdditionalData((int)auditEvent,
                                          this.GetSessionContext().AccountID,
                                          (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                          String.Format(details, tokenString, accIdentifire, auditInfo),
                                          GetSessionContext().LoggedInAs,
                                          GetSessionContext().ApplicationName);
    }

    #region IRecurringPaymentsService and IRecurringPaymentsServiceV2 Members

      /// <summary>
      /// This method is involved in the sorting and filtering of a list of MetraPaymentMethods returned to
      /// clients.  The clients should only be aware of the payment method domain model member names.
      /// This method converts the MetraPaymentMethod domain model member names into the appropriate
      /// database column names.
      /// </summary>
      /// <param name="domainModelMemberName">Name of a decision instance domain model member</param>
      /// <param name="filterVal">unused</param>
      /// <param name="helper">unused</param>
      /// <returns>Column name within the table that holds decision instances</returns>
      private string MetraPaymentMethodDomainModelMemberNameToColumnName(string domainModelMemberName,
                                                                         ref object filterVal, object helper)
      {
          string columnName = null;

          switch (domainModelMemberName)
          {
              case "PaymentInstrumentID":
                  columnName = "id_payment_instrument";
                  break;
              case "AccountID":
                  columnName = "id_acct";
                  break;
              case "PaymentMethodType":
                  columnName = "n_payment_method_type";
                  break;
              case "AccountNumber":
                  columnName = "nm_truncd_acct_num";
                  break;
              case "AccountNumberHash":
                  columnName = "tx_hash";
                  break;
              case "CreditCardType":
                  columnName = "id_creditcard_type";
                  break;
              case "AccountType":
                  columnName = "n_account_type";
                  break;
              case "ExpirationDate":
                  columnName = "nm_exp_date";
                  break;
              case "ExpirationDateFormat":
                  columnName = "nm_exp_date_format";
                  break;
              case "FirstName":
                  columnName = "nm_first_name";
                  break;
              case "MiddleName":
                  columnName = "nm_middle_name";
                  break;
              case "LastName":
                  columnName = "nm_last_name";
                  break;
              case "Street":
                  columnName = "nm_address1";
                  break;
              case "Street2":
                  columnName = "nm_address2";
                  break;
              case "City":
                  columnName = "nm_city";
                  break;
              case "State":
                  columnName = "nm_state";
                  break;
              case "ZipCode":
                  columnName = "nm_zip";
                  break;
              case "Country":
                  columnName = "id_country";
                  break;
              case "Priority":
                  columnName = "id_priority";
                  break;
              case "MaxChargePerCycle":
                  columnName = "n_max_charge_per_cycle";
                  break;
              case "dt_created":
                  columnName = "dt_created";
                  break;
              default:
                  throw new MASBasicException(
                      "MetraPaymentMethodDomainModelMemberNameToColumnName: attempt to sort on invalid field " +
                      domainModelMemberName);
                  break;
          }
          return columnName;
      }

      [OperationCapability("Manage Account Hierarchies")]
    public void GetPaymentMethodSummaries(AccountIdentifier acct, ref MTList<MetraPaymentMethod> paymentMethods)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetPaymentMethodSummaries"))
      {
        try
        {
          int accountID = ResolveAccount(acct);

          if (accountID > 0 && !HasManageAccHeirarchyAccess(accountID, MetraTech.DomainModel.Enums.Core.Global.AccessLevel.READ, MetraTech.Interop.MTAuth.MTHierarchyPathWildCard.SINGLE))
          {
            throw new MASBasicException("Access denied");
          }

          using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\ElectronicPaymentService"))
          {
            //retrieve by account ID for existing accounts            
            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement("Queries\\ElectronicPaymentService", "__GET_PAYMENT_INSTRUMENTS_FOR_ACCOUNT__"))
            {
              stmt.AddParam("%%ACCOUNT_ID%%", accountID);

              #region Apply Filters
              //apply filters
              
              // 1. Make a copy of the original filters, replacing RawAccountNumber for hash of account number
              List<MTFilterElement> filtersList = new List<MTFilterElement>();

              foreach (MTFilterElement filterElement in paymentMethods.Filters)
              {
                object filterValue = filterElement.Value;
                if (string.Compare(filterElement.PropertyName, "RawAccountNumber", true) == 0)
                {
                  filterValue = HashAccountNumber((string)filterValue);
                }

                MTFilterElement fe = new MTFilterElement(filterElement.PropertyName,
                      (MTFilterElement.OperationType)((int)filterElement.Operation),
                      filterValue);
                filtersList.Add(fe);
              }

              // 2. empty the original filters on the payementMethods list
              paymentMethods.Filters.Clear();

              // 3. add the new filters back into the payementMethods list
              foreach (var filterElement in filtersList)
              {
                  MTFilterElement fe = new MTFilterElement(filterElement.PropertyName,
                                                         (MTFilterElement.OperationType)((int)filterElement.Operation),
                                                         filterElement.Value);
                  paymentMethods.Filters.Add(fe);
              }

              // 4. Apply the filters from the paymentMethods list to the statement
              ApplyFilterSortCriteria<MetraPaymentMethod>(stmt, paymentMethods,
                  new FilterColumnResolver(MetraPaymentMethodDomainModelMemberNameToColumnName), null);
              #endregion

              #region Apply Pagination
              //set paging info
              stmt.CurrentPage = paymentMethods.CurrentPage;
              stmt.PageSize = paymentMethods.PageSize;
              #endregion

              using (IMTDataReader dataReader = stmt.ExecuteReader())
              {

                //if there are records, create a payment method object for each
                while (dataReader.Read())
                {
                  PaymentType paymentType = (PaymentType)EnumHelper.GetCSharpEnum(dataReader.GetInt32("n_payment_method_type"));

                  MetraPaymentMethod paymentMethod = GetPaymentMethodInstance(paymentType);

                  paymentMethod.PaymentInstrumentID = new Guid(dataReader.GetValue("id_payment_instrument").ToString());
                  paymentMethod.AccountNumber = dataReader.GetInt32("id_acct").ToString();
                  paymentMethod.FirstName = dataReader.GetString("nm_first_name");
                  paymentMethod.MiddleName = dataReader.GetString("nm_middle_name");
                  paymentMethod.LastName = dataReader.GetString("nm_last_name");
                  paymentMethod.Street = dataReader.GetString("nm_address1");
                  paymentMethod.Street2 = dataReader.GetString("nm_address2");
                  paymentMethod.City = dataReader.GetString("nm_city");
                  paymentMethod.State = dataReader.GetString("nm_state");
                  paymentMethod.ZipCode = dataReader.GetString("nm_zip");
                  paymentMethod.Country = (PaymentMethodCountry)EnumHelper.GetCSharpEnum(dataReader.GetInt32("id_country"));
                  paymentMethod.Priority = dataReader.GetInt32("id_priority");


                  if (!dataReader.IsDBNull("n_max_charge_per_cycle"))
                  {
                    paymentMethod.MaxChargePerCycle = dataReader.GetDecimal("n_max_charge_per_cycle");
                  }

                  switch (paymentType)
                  {
                    case PaymentType.Credit_Card:
                      ((CreditCardPaymentMethod)paymentMethod).ExpirationDate = dataReader.GetString("nm_exp_date");
                      ((CreditCardPaymentMethod)paymentMethod).ExpirationDateFormat = (MTExpDateFormat)dataReader.GetInt32("nm_exp_date_format");
                      ((CreditCardPaymentMethod)paymentMethod).CreditCardType = (MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType)EnumHelper.GetCSharpEnum(dataReader.GetInt32("id_creditcard_type"));
                      break;

                    case PaymentType.ACH:
                      ((ACHPaymentMethod)paymentMethod).AccountType = (MetraTech.DomainModel.Enums.PaymentSvrClient.Metratech_com_paymentserver.BankAccountType)EnumHelper.GetCSharpEnum(dataReader.GetInt32("n_account_type"));
                      break;
                  }

                  paymentMethods.Items.Add(paymentMethod);
                }


                paymentMethods.TotalRows = stmt.TotalRows;
              }
            }
          }
        }
        catch (CommunicationException e)
        {
          mLogger.LogException("Cannot retrieve payment methods for account " +
            ((acct.AccountID.HasValue) ? acct.AccountID.Value.ToString() : acct.Username), e);
          throw;
        }

        catch (Exception e)
        {
          mLogger.LogException("Error retrieving payment method summaries for account " +
            ((acct.AccountID.HasValue) ? acct.AccountID.Value.ToString() : acct.Username), e);
          throw new MASBasicException("Error retrieving payment method summaries");
        }
      }
    }

    [OperationCapability("Manage Account Hierarchies")]
    public void GetPaymentMethodDetail(AccountIdentifier acct, Guid token, out MetraPaymentMethod paymentMethod)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetPaymentMethodDetail"))
      {
        try
        {
          MTList<MetraPaymentMethod> paymentMethods = new MTList<MetraPaymentMethod>();
          MTFilterElement fe = new MTFilterElement("PaymentInstrumentID", MTFilterElement.OperationType.Equal, token.ToString());
          paymentMethods.Filters.Add(fe);

          GetPaymentMethodSummaries(acct, ref paymentMethods);
          if (paymentMethods.TotalRows < 1)
          {
            throw new MASBasicException("Error retrieving payment instrument details: " + token.ToString());
          }

          paymentMethod = paymentMethods.Items[0];
        }
        catch (Exception e)
        {
          mLogger.LogException("Error retrieving Payment Instrument; token=" + token.ToString(), e);
          throw new MASBasicException("Error retrieving payment information");
        }
      }
    }

    [OperationCapability("Manage Account Hierarchies")]
    public void AssignPaymentMethodToAccount(Guid token, AccountIdentifier acct)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("AssignPaymentMethodToAccount"))
      {
        int accountID = ResolveAccount(acct);

        if (accountID > 0 && !HasManageAccHeirarchyAccess(accountID, MetraTech.DomainModel.Enums.Core.Global.AccessLevel.WRITE, MetraTech.Interop.MTAuth.MTHierarchyPathWildCard.SINGLE))
        {
          throw new MASBasicException("Access denied");
        }

        if (accountID <= 0)
        {

          mLogger.LogError(String.Format("Error in Assigning token {0} to an account: invalid accountID specified", token.ToString()));
          throw new MASBasicException("Error assigning payment information to account");
        }

        using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                             new TransactionOptions(),
                                                             EnterpriseServicesInteropOption.Full))
        {
          // Lock all instrument for the target account to ensure proper locking semantics in SQL Server
          // since we'll need to update priorities
          LockAllInstrumentsForAccount(accountID);

          MetraPaymentMethod method;
          int accId;
          GetPaymentMethodDetailInternal(token, out method, out accId);

          bool bIsAlreadyOnFile = false;

          // Check to see if instrument being assigned already exists on the target account
          bIsAlreadyOnFile = IsInstrumentOnFile(method, accountID);
          if (bIsAlreadyOnFile)
          {
            mLogger.LogError(String.Format("Payment Instrument {0} is already on file for account {1}", method.AccountNumber, accountID));
            throw new MASBasicException("Submitted Payment Instrument is already on file for account.");
          }

          try
          {
            //call internal method to assign method
            AssignPaymentMethodToAccountInternal(token, accountID);
          }
          catch (Exception e)
          {
            auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ASSIGN_CREDITCARD_FAILED, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
              String.Format("Error assigning payment instrument {0} to account {1}",
              token.ToString(), accountID.ToString()));

            mLogger.LogException("Error in Assigning token " + token.ToString() + " to account " + accountID.ToString(), e);
            throw new MASBasicException("Error assigning payment information to account");
          }

          scope.Complete();
        }

        FireAuditEvent(MTAuditEvent.AUDITEVENT_ASSIGN_CREDITCARD_SUCCESS, accountID, details: "Successfully assigned payment instrument {0} to account {1}", token: token);
      }
    }

    [OperationCapability("Manage Account Hierarchies")]
    public void AddPaymentMethod(AccountIdentifier acct, MetraPaymentMethod paymentMethod, out Guid token)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("AddPaymentMethod"))
      {
        int accountID = ResolveAccount(acct);

        if (accountID > 0 && !HasManageAccHeirarchyAccess(accountID, MetraTech.DomainModel.Enums.Core.Global.AccessLevel.WRITE, MetraTech.Interop.MTAuth.MTHierarchyPathWildCard.SINGLE))
        {
          throw new MASBasicException("Access denied");
        }

          string currency = GetAccountCurrency(accountID);

        if (paymentMethod.RawAccountNumber.Length < 4)
        {
          throw new MASBasicException("Account number length is invalid");
        }

        using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                             new TransactionOptions(),
                                                             EnterpriseServicesInteropOption.Full))
        {
          // Lock all instrument for the target account to ensure proper locking semantics in SQL Server
          // since we'll need to update priorities
          LockAllInstrumentsForAccount(accountID);

          bool bIsAlreadyOnFile = false;


          bIsAlreadyOnFile = IsInstrumentOnFile(paymentMethod, accountID);
          if (bIsAlreadyOnFile)
          {
            mLogger.LogError(String.Format("Payment Instrument {0} is already on file", paymentMethod.AccountNumber));
            throw new MASBasicException("Duplicate Payment Instrument Submitted.");
          }

          MetraPayClient client = null;
          try
          {
            client = InitializeServiceCall(CalculateServiceName(paymentMethod, null, accountID));
            // add the payment instrument to the payment server
            client.AddPaymentMethod(paymentMethod, currency, out token);
            client.Close();
            client = null;
          }
          catch (FaultException<PaymentProcessorFaultDetail> e)
          {
            if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
              paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ADD_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                           String.Format(
                             "Payment processor error adding payment instrument to account {0}; CC#: {1}",
                             (acct.AccountID.HasValue) ? acct.AccountID.Value.ToString() : acct.Username,
                             paymentMethod.AccountNumber));
            }
            else
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ADD_ACH_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                           String.Format(
                             "Payment processor error adding payment instrument to account {0}; CC#: {1}",
                             (acct.AccountID.HasValue) ? acct.AccountID.Value.ToString() : acct.Username,
                             paymentMethod.AccountNumber));
            }
            mLogger.LogException(
              "Payment processor exception while adding payment information; Acct#=" + paymentMethod.AccountNumber +
              "; username=" + acct.Username + ";accID=" + accountID.ToString(), e);
            throw new PaymentProcessorException(e.Detail);
          }
          catch (FaultException<MASBasicFaultDetail> e)
          {
            if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
              paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ADD_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                           String.Format("Failed to add payment instrument to account {0}; CC#: {1}",
                                   (acct.AccountID.HasValue)
                                   ? acct.AccountID.Value.ToString()
                                   : acct.Username, paymentMethod.AccountNumber));
            }
            else
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ADD_ACH_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                           String.Format("Failed to add payment instrument to account {0}; ACH Acc#: {1}",
                                   (acct.AccountID.HasValue)
                                   ? acct.AccountID.Value.ToString()
                                   : acct.Username, paymentMethod.AccountNumber));
            }
            mLogger.LogException(
              "Fault exception while adding payment information; Acct#=" + paymentMethod.AccountNumber + "; username=" +
              acct.Username + ";accID=" + accountID.ToString(), e);
            throw new MASBasicException(e.Detail);
          }
          catch (CommunicationException e)
          {
            if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
              paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ADD_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                           String.Format(
                             "Communication exception while adding payment instrument to account {0}; CC#: {1}",
                             (acct.AccountID.HasValue) ? acct.AccountID.Value.ToString() : acct.Username,
                             paymentMethod.AccountNumber));
            }
            else
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ADD_ACH_FAILED, this.GetSessionContext().AccountID,
                     (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                     String.Format(
                     "Communication exception while adding payment instrument to account {0}; ACH Acc#: {1}",
                     (acct.AccountID.HasValue) ? acct.AccountID.Value.ToString() : acct.Username,
                     paymentMethod.AccountNumber));
            }
            mLogger.LogInfo("****Exception type was " + e.GetType().ToString());
            mLogger.LogException(
              "Communication exception while adding payment information; Acct#=" + paymentMethod.AccountNumber +
              "; username=" + acct.Username + ";accID=" + accountID.ToString(), e);
            throw;
          }
          catch (TimeoutException e)
          {
            if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
              paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ADD_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                           String.Format("Failed to add payment instrument to account {0}; CC#: {1}",
                                   (acct.AccountID.HasValue)
                                   ? acct.AccountID.Value.ToString()
                                   : acct.Username, paymentMethod.AccountNumber));
            }
            else
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ADD_ACH_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                           String.Format("Failed to add payment instrument to account {0}; ACH Acc#: {1}",
                                   (acct.AccountID.HasValue)
                                   ? acct.AccountID.Value.ToString()
                                   : acct.Username, paymentMethod.AccountNumber));
            }

            mLogger.LogException(
              "Timeout while adding payment information; Acct#=" + paymentMethod.AccountNumber + "; username=" +
              acct.Username + ";accID=" + accountID.ToString(), e);
            throw new MASBasicException("Error processing payment information");
          }
          catch (Exception e)
          {
            if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
              paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ADD_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                           String.Format("Failed to add payment instrument to account {0}; CC#: {1}",
                                   (acct.AccountID.HasValue)
                                   ? acct.AccountID.Value.ToString()
                                   : acct.Username, paymentMethod.AccountNumber));
            }
            else
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ADD_ACH_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                           String.Format("Failed to add payment instrument to account {0}; ACH acc#: {1}",
                                   (acct.AccountID.HasValue)
                                   ? acct.AccountID.Value.ToString()
                                   : acct.Username, paymentMethod.AccountNumber));
            }
            mLogger.LogInfo("***The other place: " + e.GetType().ToString());
            mLogger.LogException(
              "Exception while adding payment information; Acct#=" + paymentMethod.AccountNumber + "; username=" +
              acct.Username + ";accID=" + accountID.ToString(), e);
            throw new MASBasicException("Error processing payment information");
          }
          finally
          {
            if (client != null)
            {
              try
              {
                client.Close();
              }
              catch
              {
                client.Abort();
              }
            }
          }

          try
          {
            // store the payment instrument on the Activity Server
            AddPaymentMethodInternal(accountID, paymentMethod, token);
          }
          catch (Exception e)
          {
            if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
              paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ADD_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                           String.Format("Failed to add payment instrument {0} to account {1}; CC#: {2}",
                                   token.ToString(),
                                   (acct.AccountID.HasValue)
                                   ? acct.AccountID.Value.ToString()
                                   : acct.Username, paymentMethod.AccountNumber));

            }
            else
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ADD_ACH_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                           String.Format("Failed to add payment instrument {0} to account {1}; Ach Account#: {2}",
                                   token.ToString(),
                                   (acct.AccountID.HasValue)
                                   ? acct.AccountID.Value.ToString()
                                   : acct.Username, paymentMethod.AccountNumber));
            }
            mLogger.LogException(
              "Error Adding Payment Instrument; Acct#=" + paymentMethod.AccountNumber + "; username=" + acct.Username +
              ";accID=" + acct.AccountID.ToString() + ";piid=" + token.ToString(), e);
            throw new MASBasicException("Error processing payment information");
          }
          scope.Complete();
        }

        if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
          paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
        {
          //success audit event
          auditor.FireEventWithAdditionalData((int)MTAuditEvent.AUDITEVENT_ADD_CREDITCARD_SUCCESS, this.GetSessionContext().AccountID,
                    (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                    String.Format("Successfully added payment instrument {0} to account {1}",
                          token.ToString(),
                          (acct.AccountID.HasValue) ? acct.AccountID.Value.ToString() : acct.Username),
                          this.GetSessionContext().LoggedInAs, this.GetSessionContext().ApplicationName);
        }
        else
        {
          auditor.FireEventWithAdditionalData((int)MTAuditEvent.AUDITEVENT_ADD_ACH_SUCCESS, this.GetSessionContext().AccountID,
                    (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                    String.Format("Successfully added payment instrument {0} to account {1}",
                          token.ToString(),
                          (acct.AccountID.HasValue) ? acct.AccountID.Value.ToString() : acct.Username),
                          this.GetSessionContext().LoggedInAs, this.GetSessionContext().ApplicationName);
        }
      }
    }

    public void ReverseChargeAuthorization(Guid authToken, Guid paymentToken, ref MetraPaymentInfo paymentInfo)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("ReverseChargeAuthorization"))
      {
        ReverseChargeAuthorizationV2(authToken, paymentToken, ref paymentInfo, 0, "");
      }
    }

    public void ReverseChargeAuthorizationV2(Guid authToken, Guid paymentToken, ref MetraPaymentInfo paymentInfo, double timeOut, string cos)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("ReverseChargeAuthorizationV2"))
      {
        if (DoesTransactionExist(ref paymentInfo))
        {
          return;
        }
        MetraPaymentMethod paymentMethod = null;
        int acctId;

        Exception arNotifyException = null;

        GetPaymentMethodDetailInternal(paymentToken, out paymentMethod, out acctId);

        if (paymentMethod == null)
        {
          auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_PREAUTH_CREDITCARD_FAILED, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
            String.Format("Invalid payment instrument {0}", paymentToken.ToString()));

          mLogger.LogError("Invalid Payment token supplied.");
          throw new MASBasicException("Invalid Payment token supplied.");
        }


        //Call to check whether invoice has been sent as both single-invoice and multiple-invoice throw error
        ValidatePaymentInfo(paymentInfo);

        decimal preAuthAmount;
        string arRequestId = GetARRequestIDFromPreAuth(authToken, out preAuthAmount);

        using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                             new TransactionOptions(),
                                                             EnterpriseServicesInteropOption.Full))
        {
          MetraPayTProcessorClient tpClient = null;
          try
          {


            tpClient = InitializeTPServiceCall(CalculateServiceName(paymentMethod, paymentInfo, acctId));
            LogPaymentHistory(acctId, paymentToken, paymentMethod, paymentInfo, TransactionType.REVERSE_AUTH);
            //We never retry an auth reversal, because auths are automatically reversed over time.  So we can just close this out as a SUCCESS
            CloseTransaction(paymentInfo.TransactionSessionId, TransactionState.SUCCESS);
            tpClient.SubmitAuthReversal(authToken, ref paymentInfo, timeOut * m_EPSConfig.TimeOutStepDown, cos);
            tpClient.Close();

            try
            {
              NotifyARPaymentAbandoned(arRequestId);
            }
            catch (Exception excp)
            {
              arNotifyException = new ArNotificationProcessorException(excp.Message);
              mLogger.LogException(string.Format("Error while executing AR Notification failed message for AR Request ID : {0}", arRequestId), excp);
            }
          }
          catch (FaultException<PaymentProcessorFaultDetail> e)
          {
            auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_PREAUTH_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                         String.Format(
                           "ProcessorException: Failed to process credit card for invoice: {0}",
                           GetInvoiceNumbers(paymentInfo)));
            mLogger.LogException(
              String.Format("Payment processor exception while reversing authorization request for invoice: {0}",
                    GetInvoiceNumbers(paymentInfo)), e);

            tpClient.Abort();
            throw new PaymentProcessorException(e.Detail);
          }
          catch (FaultException<MASBasicFaultDetail> e)
          {
            auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_PREAUTH_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                         String.Format("FaultException: Failed to process credit card for invoice: {0}",
                                 GetInvoiceNumbers(paymentInfo)));
            mLogger.LogException(
                      String.Format("Fault exception while reversing authorization request for invoice: {0}",
                    GetInvoiceNumbers(paymentInfo)), e);

            tpClient.Abort();
            throw new MASBasicException(e.Detail);
          }
          catch (CommunicationException e)
          {
            auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_PREAUTH_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                         String.Format("FaultException: Failed to process credit card for invoice: {0}",
                                 GetInvoiceNumbers(paymentInfo)));

            mLogger.LogException(
                      String.Format("Communication exception while reversing authorization request for invoice: {0}.",
                    GetInvoiceNumbers(paymentInfo)), e);
            tpClient.Abort();
            throw;
          }
          catch (TimeoutException e)
          {
            auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_PREAUTH_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                         String.Format("TimeoutException: Failed to process credit card for invoice: {0}",
                                 GetInvoiceNumbers(paymentInfo)));


            mLogger.LogException(
                      String.Format("Timeout exception while reversing authorization request for invoice: {0}.",
                    GetInvoiceNumbers(paymentInfo)), e);
            tpClient.Abort();
            throw new MASBasicException("Error processing payment information");
          }

          catch (Exception e)
          {
            auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_PREAUTH_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                         String.Format("TimeoutException: Failed to process credit card for invoice: {0}",
                                 GetInvoiceNumbers(paymentInfo)));

            mLogger.LogException(
                      String.Format("Exception while reversing authorization request for invoice: {0}",
                    GetInvoiceNumbers(paymentInfo)), e);
            tpClient.Abort();
            throw new MASBasicException("Error processing payment information");

          }

          scope.Complete();

        }

        auditor.FireEvent((int)MTAuditEvent.AUDITEVENT_PREAUTH_CREDITCARD_SUCCESS, this.GetSessionContext().AccountID,
                    (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                    String.Format("Successfully reversed authorization request for invoice: {0}",
                          GetInvoiceNumbers(paymentInfo)));

        if (arNotifyException != null && m_EPSConfig.ArPayImplementation.RaiseError)
        {
          throw arNotifyException;
        }
      }
    }

    [OperationCapability("Manage Account Hierarchies")]
    public void UpdatePaymentMethodNoCheck(AccountIdentifier acct, Guid token, MetraPaymentMethod paymentMethod)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("UpdatePaymentMethodNoCheck"))
      {
        bool bVerifiedOwner = false;

        if (paymentMethod.PaymentInstrumentID.CompareTo(Guid.Empty) == 0)
        {
          paymentMethod.PaymentInstrumentID = token;
        }

        int accountID = ResolveAccount(acct);

        if (accountID > 0 && !HasManageAccHeirarchyAccess(accountID, MetraTech.DomainModel.Enums.Core.Global.AccessLevel.WRITE, MetraTech.Interop.MTAuth.MTHierarchyPathWildCard.SINGLE))
        {
          throw new MASBasicException("Access denied");
        }

        MetraPaymentMethod oldPaymentMethod;
        using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                             new TransactionOptions(),
                                                             EnterpriseServicesInteropOption.Full))
        {
          // Lock instrument to ensure proper locking semantics in SQL Server
          LockPaymentInstrument(token);

          MetraPaymentMethod loadedPaymentMethod;
          GetPaymentMethodDetail(acct, token, out loadedPaymentMethod);
          oldPaymentMethod = (MetraPaymentMethod)loadedPaymentMethod.Clone();

          loadedPaymentMethod.ApplyDirtyProperties(paymentMethod);

          // attempt to verify owner
          try
          {
            bVerifiedOwner = VerifyPaymentOwner(acct, token);
          }
          catch (Exception e)
          {
            auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_UPDATE_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                                       (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                       String.Format("Failed to verify ownership of {0} by account {1}",
                                                     token.ToString(),
                                                     (acct.AccountID.HasValue)
                                                       ? acct.AccountID.Value.ToString()
                                                       : acct.Username));

            mLogger.LogException(
              "Unable to verify ownership of payment instrument " + token.ToString() + " by accID: " +
              accountID.ToString(), e);
            throw new MASBasicException("Error updating payment information");
          }

          if (!bVerifiedOwner)
          {
            auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_UPDATE_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                                       (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                       String.Format("Not allowed to update payment instrument {0} by account {1}",
                                                     token.ToString(),
                                                     (acct.AccountID.HasValue)
                                                       ? acct.AccountID.Value.ToString()
                                                       : acct.Username));

            throw new MASBasicException("You are not allowed to modify payment information");
          }

          MetraPayClient client = null;

          try
          {
            client = InitializeServiceCall(CalculateServiceName(paymentMethod, null, accountID));

            //Call the service method
            client.UpdatePaymentMethodNoCheck(token, paymentMethod);
            client.Close();
          }
          catch (FaultException<PaymentProcessorFaultDetail> e)
          {
            if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
                paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_UPDATE_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                         String.Format(
                                           "Payment processor error updating payment instrument {0} to account {1}",
                                           token.ToString(),
                                           (acct.AccountID.HasValue) ? acct.AccountID.Value.ToString() : acct.Username));
            }
            else
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_UPDATE_ACH_FAILED, this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                         String.Format(
                                           "Payment processor error updating payment instrument {0} to account {1}",
                                           token.ToString(),
                                           (acct.AccountID.HasValue) ? acct.AccountID.Value.ToString() : acct.Username));
            }
            mLogger.LogException("Payment processor exception updating payment method", e);

            client.Abort();
            throw new PaymentProcessorException(e.Detail);
          }
          catch (FaultException<MASBasicFaultDetail> e)
          {
            if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
                paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_UPDATE_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                         String.Format("Failed to add payment instrument {0} to account {1}",
                                                       token.ToString(),
                                                       (acct.AccountID.HasValue)
                                                         ? acct.AccountID.Value.ToString()
                                                         : acct.Username));
            }
            else
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_UPDATE_ACH_FAILED, this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                         String.Format(
                                           "Payment processor error updating payment instrument {0} to account {1}",
                                           token.ToString(),
                                           (acct.AccountID.HasValue) ? acct.AccountID.Value.ToString() : acct.Username));
            }

            mLogger.LogException("MASBasicException updating payment method", e);

            client.Abort();
            throw new MASBasicException(e.Detail);
          }
          catch (CommunicationException e)
          {
            if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
                paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_UPDATE_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                         String.Format("Failed to add payment instrument {0} to account {1}",
                                                       token.ToString(),
                                                       (acct.AccountID.HasValue)
                                                         ? acct.AccountID.Value.ToString()
                                                         : acct.Username));
            }
            else
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_UPDATE_ACH_FAILED, this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                         String.Format(
                                           "Payment processor error updating payment instrument {0} to account {1}",
                                           token.ToString(),
                                           (acct.AccountID.HasValue) ? acct.AccountID.Value.ToString() : acct.Username));
            }
            mLogger.LogException("Communication Exception while updating payment method. Token=" + token.ToString(), e);

            client.Abort();
            throw;
          }
          catch (TimeoutException e)
          {
            if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
                paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_UPDATE_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                         String.Format("Failed to add payment instrument {0} to account {1}",
                                                       token.ToString(),
                                                       (acct.AccountID.HasValue)
                                                         ? acct.AccountID.Value.ToString()
                                                         : acct.Username));
            }
            else
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_UPDATE_ACH_FAILED, this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                         String.Format(
                                           "Payment processor error updating payment instrument {0} to account {1}",
                                           token.ToString(),
                                           (acct.AccountID.HasValue) ? acct.AccountID.Value.ToString() : acct.Username));
            }
            mLogger.LogException("Timed out while updating payment method. Token=" + token.ToString(), e);

            client.Abort();
            throw new MASBasicException("Error updating payment information");

          }
          catch (Exception e)
          {
            mLogger.LogException("An unexpected exception occurred", e);
            client.Abort();
            throw;
          }
          //save to MetraNet db
          try
          {
            UpdatePaymentMethodInternal(token, loadedPaymentMethod, accountID);
          }
          catch (Exception e)
          {
            if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
                paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_UPDATE_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                         String.Format("Failed to add payment instrument {0} to account {1}",
                                                       token.ToString(),
                                                       (acct.AccountID.HasValue)
                                                         ? acct.AccountID.Value.ToString()
                                                         : acct.Username));
            }
            else
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_UPDATE_ACH_FAILED, this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                         String.Format(
                                           "Payment processor error updating payment instrument {0} to account {1}",
                                           token.ToString(),
                                           (acct.AccountID.HasValue) ? acct.AccountID.Value.ToString() : acct.Username));
            }
            mLogger.LogException(
              "Error Updating Payment Instrument; Acct#=" + paymentMethod.AccountNumber + ";token=" + token, e);
            throw new MASBasicException("Error processing payment information");
          }

          scope.Complete();
        }

        //success

        //Info for auditing:
        //Get info for auditing
        var resourceManager = new ResourcesManager();
        String auditInfo = "";
        if (oldPaymentMethod.FirstName != paymentMethod.FirstName)
        {
          auditInfo += String.Format(resourceManager.GetLocalizedResource("FIRST_NAME_CHANGED"), oldPaymentMethod.FirstName, paymentMethod.FirstName);
        }
        if (oldPaymentMethod.MiddleName != paymentMethod.MiddleName)
        {
          auditInfo += String.Format(resourceManager.GetLocalizedResource("MIDDLE_NAME_CHANGED"), oldPaymentMethod.MiddleName, paymentMethod.MiddleName);
        }
        if (oldPaymentMethod.LastName != paymentMethod.LastName)
        {
          auditInfo += String.Format(resourceManager.GetLocalizedResource("LAST_NAME_CHANGED"), oldPaymentMethod.LastName, paymentMethod.LastName);
        }
        if (oldPaymentMethod.Street != paymentMethod.Street)
        {
          auditInfo += String.Format(resourceManager.GetLocalizedResource("STREET_CHANGED"), oldPaymentMethod.Street, paymentMethod.Street);
        }
        if (oldPaymentMethod.Street2 != paymentMethod.Street2)
        {
          auditInfo += String.Format(resourceManager.GetLocalizedResource("STREET_2_CHANGED"), oldPaymentMethod.Street2, paymentMethod.Street2);
        }
        if (oldPaymentMethod.City != paymentMethod.City)
        {
          auditInfo += String.Format(resourceManager.GetLocalizedResource("CITY_CHANGED"), oldPaymentMethod.City, paymentMethod.City);
        }
        if (oldPaymentMethod.State != paymentMethod.State)
        {
          auditInfo += String.Format(resourceManager.GetLocalizedResource("STATE_CHANGED"), oldPaymentMethod.State, paymentMethod.State);
        }
        if (oldPaymentMethod.ZipCode != paymentMethod.ZipCode)
        {
          auditInfo += String.Format(resourceManager.GetLocalizedResource("ZIP_CHANGED"), oldPaymentMethod.ZipCode, paymentMethod.ZipCode);
        }
        if (oldPaymentMethod.Country != paymentMethod.Country)
        {
          auditInfo += String.Format(resourceManager.GetLocalizedResource("COUNTRY_CHANGED"), oldPaymentMethod.Country, paymentMethod.Country);
        }
        if (oldPaymentMethod.MaxChargePerCycle != paymentMethod.MaxChargePerCycle)
        {
          auditInfo += String.Format(resourceManager.GetLocalizedResource("MAX_CHARGE_CHANGED"), oldPaymentMethod.MaxChargePerCycle, paymentMethod.MaxChargePerCycle);
        }


        if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
          paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
        {
          if (((CreditCardPaymentMethod)paymentMethod).ExpirationDate != ((CreditCardPaymentMethod)oldPaymentMethod).ExpirationDate)
          {
            auditInfo += String.Format(resourceManager.GetLocalizedResource("EXPIRATION_CHANGED"), ((CreditCardPaymentMethod)oldPaymentMethod).ExpirationDate,
              ((CreditCardPaymentMethod)paymentMethod).ExpirationDate);
          }

          FireAuditEvent(MTAuditEvent.AUDITEVENT_UPDATE_CREDITCARD_SUCCESS, accountID, auditInfo, resourceManager.GetLocalizedResource("UPDATED_PAYMENT_INST_AUDIT"), acct, token);
        }
        else
        {
          FireAuditEvent(MTAuditEvent.AUDITEVENT_UPDATE_ACH_SUCCESS, accountID, auditInfo, resourceManager.GetLocalizedResource("UPDATED_PAYMENT_INST_AUDIT"), acct, token);
        }
      }
    }

    [OperationCapability("Manage Account Hierarchies")]
    public void UpdatePaymentMethod(AccountIdentifier acct, Guid token, MetraPaymentMethod paymentMethod)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("UpdatePaymentMethod"))
      {
        bool bVerifiedOwner = false;
        MetraPaymentMethod oldPaymentMethod;
        //if (paymentMethod.RawAccountNumber.Length < 4)
        //{
        //    throw new MASBasicException("Account number length is invalid");
        //}

        if (paymentMethod.PaymentInstrumentID.CompareTo(Guid.Empty) == 0)
        {
          paymentMethod.PaymentInstrumentID = token;
        }

        int accountID = ResolveAccount(acct);

        if (accountID > 0 && !HasManageAccHeirarchyAccess(accountID, MetraTech.DomainModel.Enums.Core.Global.AccessLevel.WRITE, MetraTech.Interop.MTAuth.MTHierarchyPathWildCard.SINGLE))
        {
          throw new MASBasicException("Access denied");
        }

          var currency = GetAccountCurrency(accountID);

          using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                             new TransactionOptions(),
                                                             EnterpriseServicesInteropOption.Full))
        {
          // Lock instrument to ensure proper locking semantics in SQL Server
          LockPaymentInstrument(token);

          MetraPaymentMethod loadedPaymentMethod;
          GetPaymentMethodDetail(acct, token, out loadedPaymentMethod);
          oldPaymentMethod = (MetraPaymentMethod)loadedPaymentMethod.Clone();

          loadedPaymentMethod.ApplyDirtyProperties(paymentMethod);

          // attempt to verify owner
          try
          {
            bVerifiedOwner = VerifyPaymentOwner(acct, token);
          }
          catch (Exception e)
          {
            auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_UPDATE_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                         String.Format("Failed to verify ownership of {0} by account {1}",
                                 token.ToString(),
                                 (acct.AccountID.HasValue)
                                 ? acct.AccountID.Value.ToString()
                                 : acct.Username));

            mLogger.LogException(
              "Unable to verify ownership of payment instrument " + token.ToString() + " by accID: " +
              accountID.ToString(), e);
            throw new MASBasicException("Error updating payment information");
          }

          if (!bVerifiedOwner)
          {
            auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_UPDATE_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                         String.Format("Not allowed to update payment instrument {0} by account {1}",
                                 token.ToString(),
                                 (acct.AccountID.HasValue)
                                 ? acct.AccountID.Value.ToString()
                                 : acct.Username));

            throw new MASBasicException("You are not allowed to modify payment information");
          }

          MetraPayClient client = null;
          try
          {
            client = InitializeServiceCall(CalculateServiceName(paymentMethod, null, accountID));

            //Call the service method
            client.UpdatePaymentMethod(token, paymentMethod, currency);
            client.Close();
            client = null;
          }
          catch (FaultException<PaymentProcessorFaultDetail> e)
          {
            if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
              paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_UPDATE_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                             (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                             String.Format(
                             "Payment processor error updating payment instrument {0} to account {1}",
                             token.ToString(),
                             (acct.AccountID.HasValue) ? acct.AccountID.Value.ToString() : acct.Username));
            }
            else
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_UPDATE_ACH_FAILED, this.GetSessionContext().AccountID,
                             (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                             String.Format(
                             "Payment processor error updating payment instrument {0} to account {1}",
                             token.ToString(),
                             (acct.AccountID.HasValue) ? acct.AccountID.Value.ToString() : acct.Username));
            }
            mLogger.LogException("Payment processor exception updating payment method", e);

            throw new PaymentProcessorException(e.Detail);
          }
          catch (FaultException<MASBasicFaultDetail> e)
          {
            if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
              paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_UPDATE_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                             (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                             String.Format("Failed to add payment instrument {0} to account {1}",
                                   token.ToString(),
                                   (acct.AccountID.HasValue)
                                     ? acct.AccountID.Value.ToString()
                                     : acct.Username));
            }
            else
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_UPDATE_ACH_FAILED, this.GetSessionContext().AccountID,
                             (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                             String.Format(
                             "Payment processor error updating payment instrument {0} to account {1}",
                             token.ToString(),
                             (acct.AccountID.HasValue) ? acct.AccountID.Value.ToString() : acct.Username));
            }

            mLogger.LogException("MASBasicException updating payment method", e);

            throw new MASBasicException(e.Detail);
          }
          catch (CommunicationException e)
          {
            if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
              paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_UPDATE_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                             (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                             String.Format("Failed to add payment instrument {0} to account {1}",
                                   token.ToString(),
                                   (acct.AccountID.HasValue)
                                     ? acct.AccountID.Value.ToString()
                                     : acct.Username));
            }
            else
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_UPDATE_ACH_FAILED, this.GetSessionContext().AccountID,
                             (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                             String.Format(
                             "Payment processor error updating payment instrument {0} to account {1}",
                             token.ToString(),
                             (acct.AccountID.HasValue) ? acct.AccountID.Value.ToString() : acct.Username));
            }
            mLogger.LogException("Communication Exception while updating payment method. Token=" + token.ToString(), e);

            throw;
          }
          catch (TimeoutException e)
          {
            if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
              paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_UPDATE_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                             (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                             String.Format("Failed to add payment instrument {0} to account {1}",
                                   token.ToString(),
                                   (acct.AccountID.HasValue)
                                     ? acct.AccountID.Value.ToString()
                                     : acct.Username));
            }
            else
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_UPDATE_ACH_FAILED, this.GetSessionContext().AccountID,
                             (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                             String.Format(
                             "Payment processor error updating payment instrument {0} to account {1}",
                             token.ToString(),
                             (acct.AccountID.HasValue) ? acct.AccountID.Value.ToString() : acct.Username));
            }
            mLogger.LogException("Timed out while updating payment method. Token=" + token.ToString(), e);

            throw new MASBasicException("Error updating payment information");
          }
          catch (Exception e)
          {
            mLogger.LogException("An unexpected exception occurred", e);
            throw;
          }
          finally
          {
            if (null != client)
            {
              try
              {
                client.Close();
              }
              catch
              {
                client.Abort();
              }
            }
          }

          //save to MetraNet db
          try
          {
            UpdatePaymentMethodInternal(token, loadedPaymentMethod, accountID);
          }
          catch (Exception e)
          {
            if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
            paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_UPDATE_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                           String.Format("Failed to add payment instrument {0} to account {1}",
                                   token.ToString(),
                                   (acct.AccountID.HasValue)
                                   ? acct.AccountID.Value.ToString()
                                   : acct.Username));
            }
            else
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_UPDATE_ACH_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                           String.Format(
                             "Payment processor error updating payment instrument {0} to account {1}",
                             token.ToString(),
                             (acct.AccountID.HasValue) ? acct.AccountID.Value.ToString() : acct.Username));
            }
            mLogger.LogException(
              "Error Updating Payment Instrument; Acct#=" + paymentMethod.AccountNumber + ";token=" + token, e);
            throw new MASBasicException("Error processing payment information");
          }

          scope.Complete();
        }

        //success

        //Get info for auditing
        var resourceManager = new ResourcesManager();
        String auditInfo = "";
        if (oldPaymentMethod.FirstName != paymentMethod.FirstName)
        {
          auditInfo += String.Format(resourceManager.GetLocalizedResource("FIRST_NAME_CHANGED"), oldPaymentMethod.FirstName, paymentMethod.FirstName);
        }
        if (oldPaymentMethod.MiddleName != paymentMethod.MiddleName)
        {
          auditInfo += String.Format(resourceManager.GetLocalizedResource("MIDDLE_NAME_CHANGED"), oldPaymentMethod.MiddleName, paymentMethod.MiddleName);
        }
        if (oldPaymentMethod.LastName != paymentMethod.LastName)
        {
          auditInfo += String.Format(resourceManager.GetLocalizedResource("LAST_NAME_CHANGED"), oldPaymentMethod.LastName, paymentMethod.LastName);
        }
        if (oldPaymentMethod.Street != paymentMethod.Street)
        {
          auditInfo += String.Format(resourceManager.GetLocalizedResource("STREET_CHANGED"), oldPaymentMethod.Street, paymentMethod.Street);
        }
        if (oldPaymentMethod.Street2 != paymentMethod.Street2)
        {
          auditInfo += String.Format(resourceManager.GetLocalizedResource("STREET_2_CHANGED"), oldPaymentMethod.Street2, paymentMethod.Street2);
        }
        if (oldPaymentMethod.City != paymentMethod.City)
        {
          auditInfo += String.Format(resourceManager.GetLocalizedResource("CITY_CHANGED"), oldPaymentMethod.City, paymentMethod.City);
        }
        if (oldPaymentMethod.State != paymentMethod.State)
        {
          auditInfo += String.Format(resourceManager.GetLocalizedResource("STATE_CHANGED"), oldPaymentMethod.State, paymentMethod.State);
        }
        if (oldPaymentMethod.ZipCode != paymentMethod.ZipCode)
        {
          auditInfo += String.Format(resourceManager.GetLocalizedResource("ZIP_CHANGED"), oldPaymentMethod.ZipCode, paymentMethod.ZipCode);
        }
        if (oldPaymentMethod.Country != paymentMethod.Country)
        {
          auditInfo += String.Format(resourceManager.GetLocalizedResource("COUNTRY_CHANGED"), oldPaymentMethod.Country, paymentMethod.Country);
        }
        if (oldPaymentMethod.MaxChargePerCycle != paymentMethod.MaxChargePerCycle)
        {
          auditInfo += String.Format(resourceManager.GetLocalizedResource("MAX_CHARGE_CHANGED"), oldPaymentMethod.MaxChargePerCycle, paymentMethod.MaxChargePerCycle);
        }


        if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
          paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
        {
          if (((CreditCardPaymentMethod)paymentMethod).ExpirationDate != ((CreditCardPaymentMethod)oldPaymentMethod).ExpirationDate)
          {
            auditInfo += String.Format(resourceManager.GetLocalizedResource("EXPIRATION_CHANGED"), ((CreditCardPaymentMethod)oldPaymentMethod).ExpirationDate,
              ((CreditCardPaymentMethod)paymentMethod).ExpirationDate);
          }

          FireAuditEvent(MTAuditEvent.AUDITEVENT_UPDATE_CREDITCARD_SUCCESS, accountID, auditInfo, resourceManager.GetLocalizedResource("UPDATED_PAYMENT_INST_AUDIT"), acct, token);
        }
        else
        {
          FireAuditEvent(MTAuditEvent.AUDITEVENT_UPDATE_ACH_SUCCESS, accountID, auditInfo, resourceManager.GetLocalizedResource("UPDATED_PAYMENT_INST_AUDIT"), acct, token);
        }
      }
    }

      private string GetAccountCurrency(int accountID)
      {
          string currency = "USD";
          IMTQueryAdapter qa = new MTQueryAdapter();
          qa.Init("Queries\\ElectronicPaymentService");
          qa.SetQueryTag("__GET_CURRENCY_FOR_ACCOUNT__");
          string txInfo = qa.GetQuery();
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
              using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(txInfo))
              {
                  stmt.AddParam("id_acc", MTParameterType.Integer, accountID);
                  using (IMTDataReader dataReader = stmt.ExecuteReader())
                  {
                      if (dataReader.Read())
                      {
                          currency = dataReader.GetString("c_currency");
                      }
                  }
              }
          }
          return currency;
      }

      [OperationCapability("Manage Account Hierarchies")]
    public void UpdatePriority(AccountIdentifier acct, Guid token, int priority)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("UpdatePriority"))
      {
        MetraPaymentMethod paymentMethod = null;
        int acctId;

        int accountID = ResolveAccount(acct);

        if (accountID > 0 && !HasManageAccHeirarchyAccess(accountID, MetraTech.DomainModel.Enums.Core.Global.AccessLevel.WRITE, MetraTech.Interop.MTAuth.MTHierarchyPathWildCard.SINGLE))
        {
          throw new MASBasicException("Access denied");
        }

        using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                             new TransactionOptions(),
                                                             EnterpriseServicesInteropOption.Full))
        {
          // Lock all instrument for the target account to ensure proper locking semantics in SQL Server
          // since we'll need to update priorities
          LockAllInstrumentsForAccount(accountID);

          GetPaymentMethodDetailInternal(token, out paymentMethod, out acctId);

          if (paymentMethod != null)
          {

            if (accountID != acctId)
            {
              throw new MASBasicException("The specified account does not own the specified payment method");
            }

            try
            {
              using (IMTConnection conn = ConnectionManager.CreateConnection())
              {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\ElectronicPaymentService",
                  "__UPDATE_PAYMENT_INSTRUMENT_PRIORITY__"))
                {
                  stmt.AddParam("%%PAYMENT_INSTRUMENT_ID%%", token.ToString());
                  stmt.AddParam("%%ACCOUNT_ID%%", accountID);
                  stmt.AddParam("%%PRIORITY%%", priority);

                  stmt.ExecuteNonQuery();
                }
              }

              mLogger.LogDebug(String.Format("Successfully deleted payment instrument {0} from system.", token.ToString()));
            }
            catch (Exception e)
            {
              mLogger.LogException("Error Removing Payment Instrument; token=" + token, e);
              throw new MASBasicException("Error removing payment information");
            }
          }

          scope.Complete();
        }

        auditor.FireEventWithAdditionalData((int)MTAuditEvent.AUDITEVENT_DELETE_CREDITCARD_SUCCESS, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
        String.Format("Successfully deleted payment instrument {0}", token.ToString()),
        this.GetSessionContext().LoggedInAs, this.GetSessionContext().ApplicationName);
      }
    }

    [OperationCapability("Manage Account Hierarchies")]
    public void DeletePaymentMethod(AccountIdentifier acct, Guid token)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("DeletePaymentMethod"))
      {
        MetraPaymentMethod paymentMethod = null;
        int acctId;

        int accountID = ResolveAccount(acct);

        if (accountID > 0 && !HasManageAccHeirarchyAccess(accountID, MetraTech.DomainModel.Enums.Core.Global.AccessLevel.WRITE, MetraTech.Interop.MTAuth.MTHierarchyPathWildCard.SINGLE))
        {
          throw new MASBasicException("Access denied");
        }


        using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                             new TransactionOptions(),
                                                             EnterpriseServicesInteropOption.Full))
        {
          // Lock all instrument for the target account to ensure proper locking semantics in SQL Server
          // since we'll need to update priorities
          LockAllInstrumentsForAccount(accountID);

          GetPaymentMethodDetailInternal(token, out paymentMethod, out acctId);

          if (paymentMethod != null)
          {
            if (accountID != acctId)
            {
              mLogger.LogError("The specified account does not own the specifeid payment method");
              throw new MASBasicException("The specified account does not own the specified payment method");
            }


            MetraPayClient client = null;
            try
            {
              client = InitializeServiceCall(CalculateServiceName(paymentMethod, null, acctId));
              client.DeletePaymentMethod(token);
              client.Close();
              client = null;
              mLogger.LogDebug(String.Format("Removed payment instrument {0} from MetraPay.", token.ToString()));
            }
            catch (FaultException<MASBasicFaultDetail> e)
            {
              if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
                  paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
              {
                auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_DELETE_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                           String.Format("Exception while deleting payment instrument {0}",
                                                         token.ToString()));
              }
              else
              {
                auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_DELETE_ACH_FAILED, this.GetSessionContext().AccountID,
                                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                           String.Format("Exception while deleting payment instrument {0}",
                                                         token.ToString()));
              }
              mLogger.LogException("MASBasicException deleting payment method", e);

              throw new MASBasicException(e.Detail);
            }
            catch (CommunicationException e)
            {
              if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
                  paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
              {
                auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_DELETE_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                           String.Format("Communication error while deleting payment instrument {0}",
                                                         token.ToString()));
              }
              else
              {
                auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_DELETE_ACH_FAILED, this.GetSessionContext().AccountID,
                                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                           String.Format("Exception while deleting payment instrument {0}",
                                                         token.ToString()));
              }

              mLogger.LogException("Communication Exception while deleting payment method. Token=" + token.ToString(), e);
              throw;
            }
            catch (TimeoutException e)
            {
              if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
                  paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
              {
                auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_DELETE_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                           String.Format("Timed while deleting payment instrument {0}", token.ToString()));
              }
              else
              {
                auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_DELETE_ACH_FAILED, this.GetSessionContext().AccountID,
                                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                           String.Format("Exception while deleting payment instrument {0}",
                                                         token.ToString()));
              }
              mLogger.LogException("Timed out while deleting payment method. Token=" + token.ToString(), e);

              throw new MASBasicException("Error removing payment information");
            }
            catch (Exception e)
            {
              mLogger.LogException("An unexpected exception occurred", e);
              throw;
            }
            finally
            {
              if (null != client)
              {
                try
                {
                  client.Close();
                }
                catch
                {
                  client.Abort();
                }
              }
            }

            try
            {
              DeletePaymentMethodInternal(accountID, token);
              mLogger.LogDebug(String.Format("Successfully deleted payment instrument {0} from system.",
                                             token.ToString()));
            }
            catch (Exception e)
            {
              mLogger.LogException("Error Removing Payment Instrument; token=" + token, e);
              throw new MASBasicException("Error removing payment information");
            }
          }

          scope.Complete();
        }

        if (paymentMethod != null)
        {
          if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
              paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
          {
            FireAuditEvent(MTAuditEvent.AUDITEVENT_DELETE_CREDITCARD_SUCCESS, accountID, details: "Successfully deleted payment instrument {0}", acct: acct, token: token);
          }
          else
          {
            FireAuditEvent(MTAuditEvent.AUDITEVENT_DELETE_ACH_SUCCESS, accountID, details: "Successfully deleted payment instrument {0}", acct: acct, token: token);
          }
        }
      }
    }


    /// <summary>
    /// Send a debit command to the payment server
    /// </summary>
    /// <param name="token">A token for the payment instrument</param>
    /// <param name="paymentInfo">How much to pay, other payment info</param>
    public void DebitPaymentMethod(Guid token, ref MetraPaymentInfo paymentInfo)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("DebitPaymentMethod"))
      {
        DebitPaymentMethodV2(token, ref paymentInfo, 0, "");
      }
    }
    /// <summary>
    /// Send a debit command to the payment server
    /// </summary>
    /// <param name="token">A token for the payment instrument</param>
    /// <param name="paymentInfo">How much to pay, other payment info</param>
    /// <param name="timeOut">If the method does not return before the timeout expires, the caller can assume a failure</param>
    /// <param name="classOfService">Class of service to pass down to the payment gateway, which may or may not use it.</param>
    public void DebitPaymentMethodV2(Guid token, ref MetraPaymentInfo paymentInfo, double timeOut, string classOfService)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("DebitPaymentMethodV2"))
      {
        InternalDebitPaymentMethod(token, ref paymentInfo, timeOut, classOfService);
      }
    }
    /// <summary>
    /// Send a debit command to the payment server
    /// </summary>
    /// <param name="token">A token for the payment instrument</param>
    /// <param name="paymentInfo">How much to pay, other payment info</param>
    /// <param name="timeOut">If the method does not return before the timeout expires, the caller can assume a failure</param>
    /// <param name="classOfService">Class of service to pass down to the payment gateway, which may or may not use it.</param>
    /// <param name="recordPayment">Should we record this payment?  Only false if we're doing the debit as part of reconciling a Void</param>
    private void InternalDebitPaymentMethod(Guid token, ref MetraPaymentInfo paymentInfo, double timeOut, string classOfService, bool recordPayment = true)
    {
      if (DoesTransactionExist(ref paymentInfo))
      {
        return;
      }

      CheckExceededMaxOpenTransactions();
      if (timeOut == 0)
      {
        timeOut = m_EPSConfig.DefaultTransactionTimeOut;
      }
      DateTime endTime = DateTime.Now.AddMilliseconds(timeOut);

      MetraPaymentMethod paymentMethod = null;
      int acctId;
      string arRequestId = string.Empty;
      ArNotificationProcessorException arNotifyException = null;

      GetPaymentMethodDetailInternal(token, out paymentMethod, out acctId);

      if (paymentMethod == null)
      {
        auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_DEBIT_CREDITCARD_FAILED,
                                 this.GetSessionContext().AccountID,
                                 (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                 String.Format("Invalid payment instrument {0}", token.ToString()));

        mLogger.LogError("Invalid Payment token supplied.");
        throw new MASBasicException("Invalid Payment token supplied.");
      }

      //Call to check whether invoice has been sent as both single-invoice and multiple-invoice throw error
      ValidatePaymentInfo(paymentInfo);

      try
      {
        arRequestId = InitiateARPayment(acctId, paymentMethod.PaymentInstrumentID, paymentInfo);
      }
      catch (Exception excp)
      {
        mLogger.LogException("Error while executing InitiateARPayment. ", excp);
        arNotifyException = new ArNotificationProcessorException(excp.Message);
      }

      LogPaymentHistory(-1, token, null, paymentInfo, TransactionType.DEBIT);
      using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                           new TransactionOptions(),
                                                           EnterpriseServicesInteropOption.Full))
      {
        bool transactionCompleted = false;
        while (!transactionCompleted)
        {
          MetraPayTProcessorClient tpClient = null;
          // if all is good then call debit
          try
          {
            tpClient = InitializeTPServiceCall(CalculateServiceName(paymentMethod, paymentInfo, acctId),
                                               timeOut);

            if (endTime <= DateTime.Now)
            {
              FailTransaction(paymentInfo.TransactionSessionId);
              throw new TimeoutException();
            }

            //Call the service method
            tpClient.SubmitDebit(token, ref paymentInfo, timeOut * m_EPSConfig.TimeOutStepDown, classOfService);

            //If we've timed out, throw a timeout exception
            if (endTime <= DateTime.Now)
            {
              FailTransaction(paymentInfo.TransactionSessionId);
              throw new TimeoutException();
            }

            UpdateTransactionState(paymentInfo.TransactionSessionId, TransactionState.RECEIVED_RESPONSE);
            if (paymentMethod.GetType() == typeof(ACHPaymentMethod))
            {
              WritePendingACHTxDetails(paymentInfo, paymentMethod, acctId, arRequestId);
            }

            tpClient.Close();
            tpClient = null;
            if (recordPayment && m_EPSConfig.MetraPayLog.LogRecord != null
                && m_EPSConfig.MetraPayLog.LogRecord != string.Empty
                && (m_EPSConfig.MetraPayLog.LogRecord.ToUpper().Equals("TRUE"))
                && paymentMethod.GetType() == typeof(CreditCardPaymentMethod))
            {
              WritePaymentRecord(acctId, paymentMethod, paymentInfo);
            }
            UpdateTransactionState(paymentInfo.TransactionSessionId,
                                   TransactionState.POST_PROCESSING_SUCCESSFUL);

            //If we've timed out, throw a timeout exception
            if (endTime <= DateTime.Now)
            {
              FailTransaction(paymentInfo.TransactionSessionId);
              throw new TimeoutException();
            }
            transactionCompleted = true;
          }
          #region Catch blocks
          #region payment processor fault

          catch (FaultException<PaymentProcessorFaultDetail> e)
          {
            CloseTransaction(paymentInfo.TransactionSessionId, TransactionState.REJECTED,
                             String.Join(",", e.Detail.ErrorMessages));
            if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
                paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_DEBIT_CREDITCARD_FAILED,
                                       this.GetSessionContext().AccountID,
                                       (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                       String.Format(
                                           "FaultException: Failed to process credit card for invoice: {0}",
                                           GetInvoiceNumbers(paymentInfo)));

              try
              {
                NotifyARPaymentFailed(arRequestId);
              }
              catch (Exception excp)
              {
                mLogger.LogException(
                    string.Format(
                        "Error while executing AR Notification failed message for AR Request ID : {0}",
                        arRequestId), excp);
                arNotifyException = new ArNotificationProcessorException(excp.Message);
              }
            }
            else
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_DEBIT_ACH_FAILED,
                                       this.GetSessionContext().AccountID,
                                       (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                       String.Format(
                                           "FaultException: Failed to process ach transaction for invoice: {0}",
                                           GetInvoiceNumbers(paymentInfo)));
            }
            mLogger.LogException(
                String.Format("Payment processor exception while processing payment for  Invoice {0}",
                              GetInvoiceNumbers(paymentInfo)), e);
            throw new PaymentProcessorException(e.Detail);
          }
          #endregion
          #region FaultException

          catch (FaultException<MASBasicFaultDetail> e)
          {
            if (e.Detail.ErrorCode == ErrorCodes.TRANSACTION_ALREADY_REJECTED)
            {
              //Log this like a payment processor fault, since it means the opayment server already got a payment fault with this tx ID.
              CloseTransaction(paymentInfo.TransactionSessionId, TransactionState.REJECTED);
              if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
                  paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
              {
                auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_DEBIT_CREDITCARD_FAILED,
                                         this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                         String.Format(
                                             "FaultException: Failed to process credit card for invoice: {0}",
                                             GetInvoiceNumbers(paymentInfo)));

                try
                {
                  NotifyARPaymentFailed(arRequestId);
                }
                catch (Exception excp)
                {
                  mLogger.LogException(
                      string.Format(
                          "Error while executing AR Notification failed message for AR Request ID : {0}",
                          arRequestId), excp);
                  arNotifyException = new ArNotificationProcessorException(excp.Message);
                }
              }
              else
              {
                auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_DEBIT_ACH_FAILED,
                                         this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                         String.Format(
                                             "FaultException: Failed to process ach transaction for invoice: {0}",
                                             GetInvoiceNumbers(paymentInfo)));
              }
              mLogger.LogException(
                  String.Format("Payment processor exception while processing payment for  Invoice {0}",
                                GetInvoiceNumbers(paymentInfo)), e);
              throw new MASBasicException(e.Detail);
            }
            else
            {
              FailTransaction(paymentInfo.TransactionSessionId);

              if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
                  paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
              {
                auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_DEBIT_CREDITCARD_FAILED,
                                         this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                         String.Format(
                                             "FaultException: Failed to process credit card for invoice: {0}",
                                             GetInvoiceNumbers(paymentInfo)));
              }
              else
              {
                auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_DEBIT_ACH_SUCCESS,
                                         this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                         String.Format(
                                             "FaultException: Failed to process ach transaction for invoice: {0}",
                                             GetInvoiceNumbers(paymentInfo)));
              }
              mLogger.LogException(
                  String.Format("Fault exception while processing payment for  Invoice {0}",
                                GetInvoiceNumbers(paymentInfo)), e);

              throw new MASBasicException(e.Detail);
            }
          }
          #endregion
          #region CommunicationException

          catch (CommunicationException e)
          {
            FailTransaction(paymentInfo.TransactionSessionId);
            if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
                paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_DEBIT_CREDITCARD_FAILED,
                                       this.GetSessionContext().AccountID,
                                       (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                       String.Format(
                                           "CommunicationException: Failed to process credit card for invoice: {0}",
                                           GetInvoiceNumbers(paymentInfo)));
            }
            else
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_DEBIT_ACH_FAILED,
                                       this.GetSessionContext().AccountID,
                                       (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                       String.Format(
                                           "CommunicationException: Failed to process ach transaction for invoice: {0}",
                                           GetInvoiceNumbers(paymentInfo)));
            }
            mLogger.LogException(
                String.Format("Communication exception while processing payment for  Invoice {0}.",
                              GetInvoiceNumbers(paymentInfo)),
                e);
            throw;
          }
          #endregion

          catch (TimeoutException e)
          {
            HandleTimeoutException(paymentInfo, paymentMethod, acctId, endTime, e, scope);
          }
          catch (Exception e)
          {
            FailTransaction(paymentInfo.TransactionSessionId);
            if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
                paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
            {

              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_DEBIT_CREDITCARD_FAILED,
                                       this.GetSessionContext().AccountID,
                                       (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                       String.Format(
                                           "Exception: Failed to process credit card for invoice: {0}",
                                           GetInvoiceNumbers(paymentInfo)));

            }
            else
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_DEBIT_ACH_FAILED,
                                       this.GetSessionContext().AccountID,
                                       (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                       String.Format(
                                           "Exception: Failed to process ach transaction for invoice: {0}",
                                           GetInvoiceNumbers(paymentInfo)));
            }
            mLogger.LogException(
                String.Format("Exception while processing payment for  Invoice {0}",
                              GetInvoiceNumbers(paymentInfo)), e);
            throw new MASBasicException("Error processing payment information");
          }
          finally
          {
            if (null != tpClient)
            {
              try
              {
                tpClient.Close();
              }
              catch
              {
                tpClient.Abort();
              }
            }
          }

          #endregion
        }
        if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
            paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
        {
          try
          {
            NotifyARPaymentSucceeded(arRequestId);
          }
          catch (Exception excp)
          {
            arNotifyException = new ArNotificationProcessorException(excp.Message);
            mLogger.LogException(
                string.Format(
                    "Error while executing AR Notification failed message for AR Request ID : {0}",
                    arRequestId), excp);
          }
        }


        scope.Complete();
      }

      if (endTime <= DateTime.Now)
      {
        FailTransaction(paymentInfo.TransactionSessionId);
        throw new TimeoutException();
      }

      //Handle braces in the invoice #, which throw an error in FireAuditEvent
      String invNum = GetInvoiceNumbers(paymentInfo);
      invNum = invNum.Replace("{", "{{");
      invNum = invNum.Replace("}", "}}");
      if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
          paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
      {
        FireAuditEvent(MTAuditEvent.AUDITEVENT_DEBIT_CREDITCARD_SUCCESS, acctId, details: String.Format("Successfully processed credit card for invoice: {0}", invNum));
      }
      else
      {
          FireAuditEvent(MTAuditEvent.AUDITEVENT_DEBIT_ACH_SUCCESS, acctId, details: String.Format("Successfully processed ach transaction for invoice: {0}", invNum));
      }

      if (arNotifyException != null && m_EPSConfig.ArPayImplementation.RaiseError)
      {
        FailTransaction(paymentInfo.TransactionSessionId);
        throw arNotifyException;
      }
      CloseTransaction(paymentInfo.TransactionSessionId, TransactionState.SUCCESS);
    }

    /// <summary>
    /// Send a credit command to the payment server
    /// </summary>
    /// <param name="token">A token for the payment instrument</param>
    /// <param name="paymentInfo">How much to pay, other payment info</param>
    public void CreditPaymentMethod(Guid token, ref MetraPaymentInfo paymentInfo)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("CreditPaymentMethod"))
      {
        CreditPaymentMethodV2(token, ref paymentInfo, 0, "");
      }
    }

    /// <summary>
    /// Send a credit command to the payment server
    /// </summary>
    /// <param name="token">A token for the payment instrument</param>
    /// <param name="paymentInfo">How much to pay, other payment info</param>
    /// <param name="timeOut">If the method does not return before the timeout expires, the caller can assume a failure</param>
    /// <param name="classOfService">Class of service to pass down to the payment gateway, which may or may not use it.</param>
    public void CreditPaymentMethodV2(Guid token, ref MetraPaymentInfo paymentInfo, double timeOut, string classOfService)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("CreditPaymentMethodV2"))
      {
        InternalCreditPaymentMethod(token, ref paymentInfo, timeOut, classOfService);
      }
    }

    /// <summary>
    /// Send a credit command to the payment server
    /// </summary>
    /// <param name="token">A token for the payment instrument</param>
    /// <param name="paymentInfo">How much to pay, other payment info</param>
    /// <param name="timeOut">If the method does not return before the timeout expires, the caller can assume a failure</param>
    /// <param name="classOfService">Class of service to pass down to the payment gateway, which may or may not use it.</param>
    /// <param name="recordPayment">Record this payment?  We don't record the payment if the credit is part of reconciling a Void for a debit</param>
    private void InternalCreditPaymentMethod(Guid token, ref MetraPaymentInfo paymentInfo, double timeOut, string classOfService, bool recordPayment = true)
    {
      if (DoesTransactionExist(ref paymentInfo))
      {
        return;
      }

      CheckExceededMaxOpenTransactions();
      if (timeOut == 0)
      {
        timeOut = m_EPSConfig.DefaultTransactionTimeOut;
      }
      DateTime endTime = DateTime.Now.AddMilliseconds(timeOut);

      MetraPaymentMethod paymentMethod = null;
      int acctId;

      GetPaymentMethodDetailInternal(token, out paymentMethod, out acctId);

      if (paymentMethod == null)
      {
        auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_DEBIT_CREDITCARD_FAILED,
                                 this.GetSessionContext().AccountID,
                                 (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                 String.Format("Invalid payment instrument {0}", token.ToString()));

        mLogger.LogError("Invalid Payment token supplied.");
        throw new MASBasicException("Invalid Payment token supplied.");
      }


      //Call to check whether invoice has been sent as both single-invoice and multiple-invoice throw error
      ValidatePaymentInfo(paymentInfo);

      LogPaymentHistory(-1, token, null, paymentInfo, TransactionType.CREDIT);
      using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                           new TransactionOptions(),
                                                           EnterpriseServicesInteropOption.Full))
      {
        bool transactionCompleted = false;
        while (!transactionCompleted)
        {
          MetraPayTProcessorClient tpClient = null;
          try
          {
            tpClient = InitializeTPServiceCall(CalculateServiceName(paymentMethod, paymentInfo, acctId));

            if (endTime <= DateTime.Now)
            {
              FailTransaction(paymentInfo.TransactionSessionId);
              throw new TimeoutException();
            }
            //Call the service method
            tpClient.SubmitCredit(token, ref paymentInfo, timeOut * m_EPSConfig.TimeOutStepDown, classOfService);
            UpdateTransactionState(paymentInfo.TransactionSessionId, TransactionState.RECEIVED_RESPONSE);

            //If we've timed out, throw a timeout exception
            if (endTime <= DateTime.Now)
            {
              FailTransaction(paymentInfo.TransactionSessionId);
              throw new TimeoutException();
            }

            if (paymentMethod.GetType() == typeof(ACHPaymentMethod))
            {
              WritePendingACHTxDetails(paymentInfo, paymentMethod, acctId, string.Empty);
            }
            tpClient.Close();
            tpClient = null;
            if (recordPayment && m_EPSConfig.MetraPayLog.LogRecord != null
                && m_EPSConfig.MetraPayLog.LogRecord != string.Empty
                && (m_EPSConfig.MetraPayLog.LogRecord.ToUpper().Equals("TRUE"))
                && paymentMethod.GetType() == typeof(CreditCardPaymentMethod))
            {
              WritePaymentRecord(acctId, paymentMethod, paymentInfo);
            }
            UpdateTransactionState(paymentInfo.TransactionSessionId, TransactionState.POST_PROCESSING_SUCCESSFUL);
            transactionCompleted = true;
          }
          #region catch blocks

          catch (FaultException<PaymentProcessorFaultDetail> e)
          {
            CloseTransaction(paymentInfo.TransactionSessionId, TransactionState.REJECTED,
                             String.Join(",", e.Detail.ErrorMessages));

            if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
                paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_CREDIT_CREDITCARD_FAILED,
                                       this.GetSessionContext().AccountID,
                                       (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                       String.Format(
                                           "ProcessorException: Failed to process credit for invoice: {0}",
                                           GetInvoiceNumbers(paymentInfo)));
            }
            else
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_CREDIT_ACH_FAILED,
                                       this.GetSessionContext().AccountID,
                                       (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                       String.Format(
                                           "ProcessorException: Failed to process ach credit for invoice: {0}",
                                           GetInvoiceNumbers(paymentInfo)));
            }
            mLogger.LogException(
                String.Format("Payment processor exception while processing payment for  Invoice {0}",
                              GetInvoiceNumbers(paymentInfo)), e);

            throw new PaymentProcessorException(e.Detail);
          }
          catch (FaultException<MASBasicFaultDetail> e)
          {
            if (e.Detail.ErrorCode == ErrorCodes.TRANSACTION_ALREADY_REJECTED)
            {
              //Log this like a payment processor fault, since it means the opayment server already got a payment fault with this tx ID.
              CloseTransaction(paymentInfo.TransactionSessionId, TransactionState.REJECTED);
              if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
                  paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
              {
                auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_DEBIT_CREDITCARD_FAILED,
                                         this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                         String.Format(
                                             "FaultException: Failed to process credit card for invoice: {0}",
                                             GetInvoiceNumbers(paymentInfo)));
              }
              else
              {
                auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_DEBIT_ACH_FAILED,
                                         this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                         String.Format(
                                             "FaultException: Failed to process ach transaction for invoice: {0}",
                                             GetInvoiceNumbers(paymentInfo)));
              }
              mLogger.LogException(
                  String.Format("Payment processor exception while processing payment for  Invoice {0}",
                                GetInvoiceNumbers(paymentInfo)), e);
            }
            else
            {
              FailTransaction(paymentInfo.TransactionSessionId);
              if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
                  paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
              {
                auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_CREDIT_CREDITCARD_FAILED,
                                         this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                         String.Format(
                                             "FaultException: Failed to process credit for invoice: {0}",
                                             GetInvoiceNumbers(paymentInfo)));
              }
              else
              {
                auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_CREDIT_ACH_FAILED,
                                         this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                         String.Format(
                                             "FaultException: Failed to process ach credit for invoice: {0}",
                                             GetInvoiceNumbers(paymentInfo)));
              }
              mLogger.LogException(
                  String.Format("Fault exception while processing payment for  Invoice {0}",
                                GetInvoiceNumbers(paymentInfo)), e);

              throw new MASBasicException(e.Detail);
            }
          }
          catch (CommunicationException e)
          {
            FailTransaction(paymentInfo.TransactionSessionId);
            if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
                paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_CREDIT_CREDITCARD_FAILED,
                                       this.GetSessionContext().AccountID,
                                       (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                       String.Format(
                                           "FaultException: Failed to process credit for invoice: {0}",
                                           GetInvoiceNumbers(paymentInfo)));
            }
            else
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_CREDIT_ACH_FAILED,
                                       this.GetSessionContext().AccountID,
                                       (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                       String.Format(
                                           "FaultException: Failed to process ach credit for invoice: {0}",
                                           GetInvoiceNumbers(paymentInfo)));
            }
            mLogger.LogException(
                String.Format("Communication exception while processing payment for  Invoice {0}.",
                              GetInvoiceNumbers(paymentInfo)),
                e);
            throw;
          }
          catch (TimeoutException e)
          {
            HandleTimeoutException(paymentInfo, paymentMethod, acctId, endTime, e, scope);
          }
          catch (Exception e)
          {
            FailTransaction(paymentInfo.TransactionSessionId);
            if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
                paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_CREDIT_CREDITCARD_FAILED,
                                       this.GetSessionContext().AccountID,
                                       (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                       String.Format(
                                           "TimeoutException: Failed to process credit for invoice: {0}",
                                           GetInvoiceNumbers(paymentInfo)));
            }
            else
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_CREDIT_ACH_FAILED,
                                       this.GetSessionContext().AccountID,
                                       (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                       String.Format(
                                           "TimeoutException: Failed to process ach credit for invoice: {0}",
                                           GetInvoiceNumbers(paymentInfo)));
            }
            mLogger.LogException(
                String.Format("Exception while processing payment for  Invoice {0}",
                              GetInvoiceNumbers(paymentInfo)),
                e);
            throw new MASBasicException("Error processing payment information");

          }
          finally
          {
            if (null != tpClient)
            {
              try
              {
                tpClient.Close();
              }
              catch
              {
                tpClient.Abort();
              }
            }
          }

          #endregion
        }
        scope.Complete();
      }

      if (endTime <= DateTime.Now)
      {
        FailTransaction(paymentInfo.TransactionSessionId);
        throw new TimeoutException();
      }

      if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
          paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
      {
        auditor.FireEvent((int)MTAuditEvent.AUDITEVENT_CREDIT_CREDITCARD_SUCCESS,
                          this.GetSessionContext().AccountID,
                          (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                          String.Format("Successfully processed credit for invoice: {0}",
                                        GetInvoiceNumbers(paymentInfo)));
      }
      else
      {
        auditor.FireEvent((int)MTAuditEvent.AUDITEVENT_CREDIT_ACH_SUCCESS, this.GetSessionContext().AccountID,
                          (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                          String.Format("Successfully processed credit for invoice: {0}",
                                        GetInvoiceNumbers(paymentInfo)));
      }
      CloseTransaction(paymentInfo.TransactionSessionId, TransactionState.SUCCESS);
    }

    public void PreAuthorizeCharge(Guid methodToken, ref MetraPaymentInfo estimatedPaymentInfo, out Guid authorizationToken)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("PreAuthorizeCharge"))
      {
        PreAuthorizeChargeV2(methodToken, ref estimatedPaymentInfo, out authorizationToken, 0, "");
      }
    }

    public void PreAuthorizeChargeV2(Guid methodToken, ref MetraPaymentInfo estimatedPaymentInfo, out Guid authorizationToken, double timeOut, string classOfService)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("PreAuthorizeChargeV2"))
      {
        //Not going to check for pre-existing transaction here.  If there was one, MetraPay will catch it, and we need MetraPay to fill in the authorizationToken.
        if (estimatedPaymentInfo.TransactionSessionId.ToString() == "00000000-0000-0000-0000-000000000000")
        {
          estimatedPaymentInfo.TransactionSessionId = Guid.NewGuid();
        }

        CheckExceededMaxOpenTransactions();
        if (timeOut == 0)
        {
          timeOut = m_EPSConfig.DefaultTransactionTimeOut;
        }
        DateTime endTime = DateTime.Now.AddMilliseconds(timeOut);

        MetraPaymentMethod paymentMethod = null;
        int acctId;
        ArNotificationProcessorException arNotifyExcp = null;

        GetPaymentMethodDetailInternal(methodToken, out paymentMethod, out acctId);

        if (paymentMethod == null)
        {
          auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_PREAUTH_CREDITCARD_FAILED,
                                   this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT,
                                   acctId,
                    String.Format("Invalid payment instrument {0}", methodToken.ToString()));

          mLogger.LogError("Invalid Payment token supplied.");
          throw new MASBasicException("Invalid Payment token supplied.");
        }

        ValidatePaymentInfo(estimatedPaymentInfo);

        string arRequestId = string.Empty;

        try
        {
          arRequestId = InitiateARPayment(acctId, paymentMethod.PaymentInstrumentID, estimatedPaymentInfo);
        }
        catch (Exception excp)
        {
          mLogger.LogException("Error while executing InitiateARPayment. ", excp);
          arNotifyExcp = new ArNotificationProcessorException(excp.Message);
        }

        using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                             new TransactionOptions(),
                                                             EnterpriseServicesInteropOption.Full))
        {
          MetraPayTProcessorClient tpClient = null;
          try
          {
            tpClient = InitializeTPServiceCall(
              CalculateServiceName(paymentMethod, estimatedPaymentInfo, acctId), timeOut);
            // CORE-883 Don't need to log payment history
            //LogPaymentHistory(-1, methodToken, null, estimatedPaymentInfo);
            tpClient.SubmitPreAuth(methodToken, ref estimatedPaymentInfo, out authorizationToken,
                           arRequestId, timeOut * m_EPSConfig.TimeOutStepDown, classOfService);

            if (endTime <= DateTime.Now)
            {
              throw new TimeoutException();
            }
            tpClient.Close();
            tpClient = null;
          }
          #region Catch blocks

          catch (FaultException<PaymentProcessorFaultDetail> e)
          {
            auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_PREAUTH_CREDITCARD_FAILED,
                                             this.GetSessionContext().AccountID,
                                     (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                             String.Format(
                                               "ProcessorException: Failed to process credit card for invoice: {0}",
                                               GetInvoiceNumbers(estimatedPaymentInfo)));
            mLogger.LogException(
              String.Format(
                "Payment processor exception while processing pre-authorization request for invoice: {0}",
                GetInvoiceNumbers(estimatedPaymentInfo)), e);
            throw new PaymentProcessorException(e.Detail);
          }
          catch (FaultException<MASBasicFaultDetail> e)
          {
            auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_PREAUTH_CREDITCARD_FAILED,
                                             this.GetSessionContext().AccountID,
                                     (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                             String.Format(
                                               "FaultException: Failed to process credit card for invoice: {0}",
                                               GetInvoiceNumbers(estimatedPaymentInfo)));
            mLogger.LogException(
              String.Format(
                "Fault exception while processing pre-authorization request for invoice: {0}",
                GetInvoiceNumbers(estimatedPaymentInfo)), e);
            throw new MASBasicException(e.Detail);
          }
          catch (CommunicationException e)
          {
            auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_PREAUTH_CREDITCARD_FAILED,
                                             this.GetSessionContext().AccountID,
                                     (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                             String.Format(
                                               "FaultException: Failed to process credit card for invoice: {0}",
                                               GetInvoiceNumbers(estimatedPaymentInfo)));

            mLogger.LogException(
              String.Format(
                "Communication exception while processing pre-authorization request for invoice: {0}.",
                GetInvoiceNumbers(estimatedPaymentInfo)), e);
            throw;
          }
          catch (TimeoutException e)
          {
            auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_PREAUTH_CREDITCARD_FAILED,
                                             this.GetSessionContext().AccountID,
                                     (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                             String.Format(
                                               "TimeoutException: Failed to process credit card for invoice: {0}",
                                               GetInvoiceNumbers(estimatedPaymentInfo)));


            mLogger.LogException(
              String.Format(
                "Timeout exception while processing pre-authorization request for invoice: {0}.",
                GetInvoiceNumbers(estimatedPaymentInfo)), e);
            throw new MASBasicException("Error processing payment information");
          }

          catch (Exception e)
          {
            auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_PREAUTH_CREDITCARD_FAILED,
                                             this.GetSessionContext().AccountID,
                                     (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                             String.Format(
                                               "TimeoutException: Failed to process credit card for invoice: {0}",
                                               GetInvoiceNumbers(estimatedPaymentInfo)));

            mLogger.LogException(
              String.Format("Exception while processing pre-authorization request for invoice: {0}",
                            GetInvoiceNumbers(estimatedPaymentInfo)), e);
            throw new MASBasicException("Error processing payment information");
          }
          finally
          {
            if (null != tpClient)
            {
              try
              {
                tpClient.Close();
              }
              catch
              {
                tpClient.Abort();
              }
            }
          }

          #endregion

          scope.Complete();
        }
        auditor.FireEvent((int)MTAuditEvent.AUDITEVENT_PREAUTH_CREDITCARD_SUCCESS, this.GetSessionContext().AccountID,
                      (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                      String.Format("Successfully processed pre-authorization request for invoice: {0}",
                            GetInvoiceNumbers(estimatedPaymentInfo)));

        if (arNotifyExcp != null && m_EPSConfig.ArPayImplementation.RaiseError)
        {
          throw arNotifyExcp;
        }
      }
    }

    public void CapturePreauthorizedCharge(Guid authorizationToken, Guid paymentToken, ref MetraPaymentInfo actualPaymentinfo)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("CapturePreauthorizedCharge"))
      {
        CapturePreauthorizedChargeV2(authorizationToken, paymentToken, ref actualPaymentinfo, 0, "");
      }
    }

    public void CapturePreauthorizedChargeV2(Guid authorizationToken, Guid paymentToken, ref MetraPaymentInfo actualPaymentInfo, double timeOut, string classOfService)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("CapturePreauthorizedChargeV2"))
      {
        if (DoesTransactionExist(ref actualPaymentInfo))
        {
          return;
        }
        CheckExceededMaxOpenTransactions();
        if (timeOut == 0)
        {
          timeOut = m_EPSConfig.DefaultTransactionTimeOut;
        }
        DateTime endTime = DateTime.Now.AddMilliseconds(timeOut);

        MetraPaymentMethod paymentMethod = null;
        int acctId;
        ArNotificationProcessorException arNotifyExcp = null;

        GetPaymentMethodDetailInternal(paymentToken, out paymentMethod, out acctId);

        if (paymentMethod == null)
        {
          auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_PREAUTH_CAPTURE_CREDITCARD_FAILED,
                                   this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT,
                                   acctId,
                    String.Format("Invalid payment instrument {0}", paymentToken.ToString()));

          mLogger.LogError("Invalid Payment token supplied.");
          throw new MASBasicException("Invalid Payment token supplied.");
        }


        //Call to check whether invoice has been sent as both single-invoice and multiple-invoice throw error
        ValidatePaymentInfo(actualPaymentInfo);

        decimal preAuthAmount;
        string arRequestId = GetARRequestIDFromPreAuth(authorizationToken, out preAuthAmount);
        string newArRequestId = string.Empty;

        if (!decimal.Equals(preAuthAmount, actualPaymentInfo.Amount))
        {
          try
          {
            //if preauth amt doesn't match posting amount then cancel preauth notification to AR and initiate new ar notification with posting amount.
            NotifyARPaymentFailed(arRequestId);
            newArRequestId = InitiateARPayment(acctId, paymentMethod.PaymentInstrumentID, actualPaymentInfo);

          }
          catch (Exception excp)
          {
            arNotifyExcp = new ArNotificationProcessorException(excp.Message);
          }
        }
        LogPaymentHistory(-1, paymentToken, null, actualPaymentInfo, TransactionType.CAPTURE);

        using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                             new TransactionOptions(),
                                                             EnterpriseServicesInteropOption.Full))
        {
          bool transactionCompleted = false;
          while (!transactionCompleted)
          {
            MetraPayTProcessorClient tpClient = null;
            try
            {
              tpClient = InitializeTPServiceCall(CalculateServiceName(paymentMethod, actualPaymentInfo, acctId));

              if (endTime <= DateTime.Now)
              {
                UpdateTransactionState(actualPaymentInfo.TransactionSessionId, TransactionState.FAILURE);
                throw new TimeoutException();
              }
              tpClient.SubmitCapture(authorizationToken, ref actualPaymentInfo, timeOut * m_EPSConfig.TimeOutStepDown, classOfService);
              UpdateTransactionState(actualPaymentInfo.TransactionSessionId, TransactionState.RECEIVED_RESPONSE);

              //If we've timed out, throw a timeout exception
              if (endTime <= DateTime.Now)
              {
                UpdateTransactionState(actualPaymentInfo.TransactionSessionId, TransactionState.FAILURE);
                throw new TimeoutException();
              }
              tpClient.Close();
              tpClient = null;
              if (m_EPSConfig.MetraPayLog.LogRecord != null
                  && m_EPSConfig.MetraPayLog.LogRecord != string.Empty
                  && (m_EPSConfig.MetraPayLog.LogRecord.ToUpper().Equals("TRUE"))
             && paymentMethod.GetType() == typeof(CreditCardPaymentMethod))
              {
                WritePaymentRecord(acctId, paymentMethod, actualPaymentInfo);
              }

              try
              {
                NotifyARPaymentSucceeded((string.IsNullOrEmpty(newArRequestId) ? arRequestId : newArRequestId));
              }
              catch (Exception excp)
              {
                arNotifyExcp = new ArNotificationProcessorException(excp.Message);

                mLogger.LogException(
                  string.Format("Error while executing AR Notification failed message for AR Request ID : {0}",
                                arRequestId), excp);
              }
              transactionCompleted = true;
            }
            catch (FaultException<PaymentProcessorFaultDetail> e)
            {
              CloseTransaction(actualPaymentInfo.TransactionSessionId, TransactionState.REJECTED,
                   String.Join(",", e.Detail.ErrorMessages));
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_PREAUTH_CAPTURE_CREDITCARD_FAILED,
                                            this.GetSessionContext().AccountID,
                                       (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                            String.Format(
                                              "ProcessorException: Failed to process credit card for invoice: {0}",
                                         GetInvoiceNumbers(actualPaymentInfo)));
              mLogger.LogException(
                String.Format("Payment processor exception while capturing pre-authorization for invoice: {0}",
                         GetInvoiceNumbers(actualPaymentInfo)), e);

              try
              {
                NotifyARPaymentFailed(arRequestId);
              }
              catch (Exception excp)
              {
                arNotifyExcp = new ArNotificationProcessorException(excp.Message);
                mLogger.LogException(
                  string.Format("Error while executing AR Notification failed message for AR Request ID : {0}",
                                arRequestId), excp);

              }

              throw new PaymentProcessorException(e.Detail);
            }
            catch (FaultException<MASBasicFaultDetail> e)
            {
              if (e.Detail.ErrorCode == ErrorCodes.TRANSACTION_TIMED_OUT)
              {
                FailTransaction(actualPaymentInfo.TransactionSessionId);
                auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_PREAUTH_CAPTURE_CREDITCARD_FAILED,
                                         this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                         String.Format(
                                           "TimeoutException: Failed to process credit card for invoice: {0}",
                                      GetInvoiceNumbers(actualPaymentInfo)));


                mLogger.LogException(
                  String.Format("Timeout exception while capturing pre-authorization for invoice: {0}.",
                           GetInvoiceNumbers(actualPaymentInfo)), e);
                throw new MASBasicException(ErrorCodes.TRANSACTION_TIMED_OUT);
              }
              if (e.Detail.ErrorCode == ErrorCodes.TRANSACTION_ALREADY_REJECTED)
              {
                //Log this like a payment processor fault, since it means the opayment server already got a payment fault with this tx ID.
                CloseTransaction(actualPaymentInfo.TransactionSessionId, TransactionState.REJECTED,
                                      String.Join(",", e.Detail.ErrorMessages));
                auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_PREAUTH_CAPTURE_CREDITCARD_FAILED,
                                         this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                         String.Format(
                                           "ProcessorException: Failed to process credit card for invoice: {0}",
                                      GetInvoiceNumbers(actualPaymentInfo)));
                mLogger.LogException(
                  String.Format("Payment processor exception while capturing pre-authorization for invoice: {0}",
                           GetInvoiceNumbers(actualPaymentInfo)), e);

                try
                {
                  NotifyARPaymentFailed(arRequestId);
                }
                catch (Exception excp)
                {
                  FailTransaction(actualPaymentInfo.TransactionSessionId);
                  mLogger.LogException(
                    string.Format("Error while executing AR Notification failed message for AR Request ID : {0}",
                                  arRequestId), excp);

                }
              }
              else
              {
                FailTransaction(actualPaymentInfo.TransactionSessionId);
                auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_PREAUTH_CAPTURE_CREDITCARD_FAILED,
                                              this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                              String.Format(
                                                "FaultException: Failed to process credit card for invoice: {0}",
                                           GetInvoiceNumbers(actualPaymentInfo)));
                mLogger.LogException(
                  String.Format("Fault exception while capturing pre-authorization for invoice: {0}",
                           GetInvoiceNumbers(actualPaymentInfo)), e);
              }
              throw new MASBasicException(e.Detail);
            }
            catch (CommunicationException e)
            {
              FailTransaction(actualPaymentInfo.TransactionSessionId);
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_PREAUTH_CAPTURE_CREDITCARD_FAILED,
                                            this.GetSessionContext().AccountID,
                                       (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                            String.Format(
                                              "FaultException: Failed to process credit card for invoice: {0}",
                                         GetInvoiceNumbers(actualPaymentInfo)));

              mLogger.LogException(
                String.Format("Communication exception while capturing pre-authorization for invoice: {0}.",
                         GetInvoiceNumbers(actualPaymentInfo)), e);
              throw;
            }
            catch (TimeoutException e)
            {
              FailTransaction(actualPaymentInfo.TransactionSessionId);
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_PREAUTH_CAPTURE_CREDITCARD_FAILED,
                                            this.GetSessionContext().AccountID,
                                       (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                            String.Format(
                                              "TimeoutException: Failed to process credit card for invoice: {0}",
                                         GetInvoiceNumbers(actualPaymentInfo)));


              mLogger.LogException(
                String.Format("Timeout exception while capturing pre-authorization for invoice: {0}.",
                         GetInvoiceNumbers(actualPaymentInfo)), e);
              throw new MASBasicException(ErrorCodes.TRANSACTION_TIMED_OUT);
            }

            catch (Exception e)
            {
              FailTransaction(actualPaymentInfo.TransactionSessionId);
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_PREAUTH_CAPTURE_CREDITCARD_FAILED,
                                            this.GetSessionContext().AccountID,
                                       (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                            String.Format(
                                              "TimeoutException: Failed to process credit card for invoice: {0}",
                                         GetInvoiceNumbers(actualPaymentInfo)));

              mLogger.LogException(
                String.Format("Exception while capturing pre-authorization for invoice: {0}",
                         GetInvoiceNumbers(actualPaymentInfo)), e);
              throw new MASBasicException("Error processing payment information");
            }
            finally
            {
              if (null != tpClient)
              {
                try
                {
                  tpClient.Close();
                }
                catch
                {
                  tpClient.Abort();
                }
              }
            }
          }
          scope.Complete();
        }
        auditor.FireEvent((int)MTAuditEvent.AUDITEVENT_PREAUTH_CAPTURE_CREDITCARD_SUCCESS,
                          this.GetSessionContext().AccountID,
                        (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                        String.Format("Successfully captured pre-authorization for invoice: {0}",
                                        GetInvoiceNumbers(actualPaymentInfo)));

        if (arNotifyExcp != null && m_EPSConfig.ArPayImplementation.RaiseError)
        {
          FailTransaction(actualPaymentInfo.TransactionSessionId);
          throw arNotifyExcp;
        }
        CloseTransaction(actualPaymentInfo.TransactionSessionId, TransactionState.SUCCESS);
      }
    }

    public void GetACHTransactionStatus(string transactionId, out bool bProcessed)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetACHTransactionStatus"))
      {
        mLogger.LogDebug("Retrieving transaction status for {0}", transactionId);
        bProcessed = false;
        if (transactionId != null)
        {

          using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                           new TransactionOptions(),
                                                           EnterpriseServicesInteropOption.Full))
          {
            MetraPayTProcessorClient tpClient = null;
            try
            {
              tpClient = InitializeTPServiceCall(CalculateServiceName(null, null, 0));
              tpClient.GetACHTransactionStatus(transactionId, out bProcessed);
              tpClient.Close();
            }
            catch (FaultException<MASBasicFaultDetail> e)
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_DELETE_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, -1,
                           String.Format("Exception while retrieving transaction status for {0}",
                                   transactionId));

              mLogger.LogException("MASBasicException retrieving transaction status", e);

              tpClient.Abort();
              throw new MASBasicException(e.Detail);
            }
            catch (CommunicationException e)
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_DELETE_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, -1,
                           String.Format("Communication error while retrieiving transaction status for {0}",
                                   transactionId));

              mLogger.LogException("Communication Exception while retrieving transaction status ", e);
              tpClient.Abort();
              throw;
            }
            catch (TimeoutException e)
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_DELETE_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, -1,
                           String.Format("Timed out while retrieving transaction status for {0}", transactionId));

              mLogger.LogException("Timed out while retrieving transaction status for ", e);
              tpClient.Abort();
              throw new MASBasicException("Error retrieving transaction status");
            }
            catch (Exception e)
            {
              mLogger.LogException("An unexpected exception occurred", e);
              tpClient.Abort();
              throw;
            }
          }
        }
      }
    }

    public void DownloadACHTransactionsReport(string url)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("DownloadACHTransactionsReport"))
      {
        if (url != null)
        {

          using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                           new TransactionOptions(),
                                                           EnterpriseServicesInteropOption.Full))
          {
            MetraPayTProcessorClient tpClient = null;
            try
            {
              tpClient = InitializeTPServiceCall(CalculateServiceName(null, null, 0));

              mLogger.LogDebug("About to Download Transaction Report.");
              tpClient.DownloadACHTransactionsReport(url);
              tpClient.Close();
              mLogger.LogDebug("Downloaded Transaction Report.");
            }
            catch (FaultException<MASBasicFaultDetail> e)
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_DELETE_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, -1,
                           String.Format("Exception while downloading transaction report from {0}",
                                   url));

              mLogger.LogException("MASBasicException downloading transaction report", e);

              tpClient.Abort();
              throw new MASBasicException(e.Detail);
            }
            catch (CommunicationException e)
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_DELETE_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, -1,
                           String.Format("Communication error while downloading transaction report from {0}",
                                   url));

              mLogger.LogException("Communication Exception while downloading transaction report from " + url, e);
              tpClient.Abort();
              throw;
            }
            catch (TimeoutException e)
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_DELETE_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, -1,
                           String.Format("Timed while downloading transaction report from {0}", url));

              mLogger.LogException("Timed out while downloading transaction report from " + url, e);
              tpClient.Abort();
              throw new MASBasicException("Error downloading transaction report");
            }
            catch (Exception e)
            {
              mLogger.LogException("An unexpected exception occurred", e);
              tpClient.Abort();
              throw;
            }
          }
        }
      }
    }

    public void AddCCAndAuthorizeCharge(AccountIdentifier acct, CreditCardPaymentMethod paymentMethod, ref MetraPaymentInfo paymentInfo, out Guid instrumentToken, out Guid authToken)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("AddCCAndAuthorizeCharge"))
      {
        int accountID = ResolveAccount(acct);

        if (accountID > 0 && !HasManageAccHeirarchyAccess(accountID, MetraTech.DomainModel.Enums.Core.Global.AccessLevel.WRITE, MetraTech.Interop.MTAuth.MTHierarchyPathWildCard.SINGLE))
        {
          throw new MASBasicException("Access denied");
        }

        if (paymentMethod.RawAccountNumber.Length < 4)
        {
          throw new MASBasicException("Account number length is invalid");
        }

        ValidatePaymentInfo(paymentInfo);

        string arRequestId = string.Empty;
        ArNotificationProcessorException arNotifyExcp = null;
        try
        {
          arRequestId = InitiateARPayment(accountID, paymentMethod.PaymentInstrumentID, paymentInfo);
        }
        catch (Exception excp)
        {
          mLogger.LogException("Error while executing InitiateARPayment. ", excp);
          arNotifyExcp = new ArNotificationProcessorException(excp.Message);
        }

        using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                             new TransactionOptions(),
                                                             EnterpriseServicesInteropOption.Full))
        {
          // Lock all instrument for the target account to ensure proper locking semantics in SQL Server
          // since we'll need to update priorities
          LockAllInstrumentsForAccount(accountID);

          bool bIsAlreadyOnFile = false;


          bIsAlreadyOnFile = IsInstrumentOnFile(paymentMethod, accountID);
          if (bIsAlreadyOnFile)
          {
            mLogger.LogError(String.Format("Payment Instrument {0} is already on file", paymentMethod.AccountNumber));
            throw new MASBasicException("Duplicate Payment Instrument Submitted.");
          }



          MetraPayClient client = null;
          try
          {
            client = InitializeServiceCall(CalculateServiceName(paymentMethod, null, accountID));
            // add the payment instrument to the payment server
            client.AddCreditCardAndPreAuth(paymentMethod, ref paymentInfo, out instrumentToken, out authToken, arRequestId);
            client.Close();
          }
          catch (FaultException<PaymentProcessorFaultDetail> e)
          {
            if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
              paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ADD_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                           String.Format(
                             "Payment processor error adding payment instrument to account {0}; CC#: {1}",
                             (acct.AccountID.HasValue) ? acct.AccountID.Value.ToString() : acct.Username,
                             paymentMethod.AccountNumber));
            }
            else
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ADD_ACH_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                           String.Format(
                             "Payment processor error adding payment instrument to account {0}; CC#: {1}",
                             (acct.AccountID.HasValue) ? acct.AccountID.Value.ToString() : acct.Username,
                             paymentMethod.AccountNumber));
            }
            mLogger.LogException(
              "Payment processor exception while adding payment information; Acct#=" + paymentMethod.AccountNumber +
              "; username=" + acct.Username + ";accID=" + accountID.ToString(), e);

            client.Abort();
            throw new PaymentProcessorException(e.Detail);
          }
          catch (FaultException<MASBasicFaultDetail> e)
          {
            if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
              paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ADD_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                           String.Format("Failed to add payment instrument to account {0}; CC#: {1}",
                                   (acct.AccountID.HasValue)
                                   ? acct.AccountID.Value.ToString()
                                   : acct.Username, paymentMethod.AccountNumber));
            }
            else
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ADD_ACH_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                           String.Format("Failed to add payment instrument to account {0}; ACH Acc#: {1}",
                                   (acct.AccountID.HasValue)
                                   ? acct.AccountID.Value.ToString()
                                   : acct.Username, paymentMethod.AccountNumber));
            }
            mLogger.LogException(
              "Fault exception while adding payment information; Acct#=" + paymentMethod.AccountNumber + "; username=" +
              acct.Username + ";accID=" + accountID.ToString(), e);

            client.Abort();
            throw new MASBasicException(e.Detail);
          }
          catch (CommunicationException e)
          {
            if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
              paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ADD_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                           String.Format(
                             "Communication exception while adding payment instrument to account {0}; CC#: {1}",
                             (acct.AccountID.HasValue) ? acct.AccountID.Value.ToString() : acct.Username,
                             paymentMethod.AccountNumber));
            }
            else
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ADD_ACH_FAILED, this.GetSessionContext().AccountID,
                     (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                     String.Format(
                     "Communication exception while adding payment instrument to account {0}; ACH Acc#: {1}",
                     (acct.AccountID.HasValue) ? acct.AccountID.Value.ToString() : acct.Username,
                     paymentMethod.AccountNumber));
            }

            mLogger.LogException(
              "Communication exception while adding payment information; Acct#=" + paymentMethod.AccountNumber +
              "; username=" + acct.Username + ";accID=" + accountID.ToString(), e);

            client.Abort();
            throw;
          }
          catch (TimeoutException e)
          {
            if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
              paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ADD_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                           String.Format("Failed to add payment instrument to account {0}; CC#: {1}",
                                   (acct.AccountID.HasValue)
                                   ? acct.AccountID.Value.ToString()
                                   : acct.Username, paymentMethod.AccountNumber));
            }
            else
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ADD_ACH_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                           String.Format("Failed to add payment instrument to account {0}; ACH Acc#: {1}",
                                   (acct.AccountID.HasValue)
                                   ? acct.AccountID.Value.ToString()
                                   : acct.Username, paymentMethod.AccountNumber));
            }

            mLogger.LogException(
              "Timeout while adding payment information; Acct#=" + paymentMethod.AccountNumber + "; username=" +
              acct.Username + ";accID=" + accountID.ToString(), e);

            client.Abort();
            throw new MASBasicException("Error processing payment information");
          }
          catch (Exception e)
          {
            if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
              paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ADD_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                           String.Format("Failed to add payment instrument to account {0}; CC#: {1}",
                                   (acct.AccountID.HasValue)
                                   ? acct.AccountID.Value.ToString()
                                   : acct.Username, paymentMethod.AccountNumber));
            }
            else
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ADD_ACH_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                           String.Format("Failed to add payment instrument to account {0}; ACH acc#: {1}",
                                   (acct.AccountID.HasValue)
                                   ? acct.AccountID.Value.ToString()
                                   : acct.Username, paymentMethod.AccountNumber));
            }

            mLogger.LogException(
              "Exception while adding payment information; Acct#=" + paymentMethod.AccountNumber + "; username=" +
              acct.Username + ";accID=" + accountID.ToString(), e);

            client.Abort();
            throw new MASBasicException("Error processing payment information");
          }

          try
          {
            // store the payment instrument on the Activity Server
            AddPaymentMethodInternal(accountID, paymentMethod, instrumentToken);
          }
          catch (Exception e)
          {
            if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
              paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ADD_CREDITCARD_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                           String.Format("Failed to add payment instrument {0} to account {1}; CC#: {2}",
                                   instrumentToken.ToString(),
                                   (acct.AccountID.HasValue)
                                   ? acct.AccountID.Value.ToString()
                                   : acct.Username, paymentMethod.AccountNumber));

            }
            else
            {
              auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ADD_ACH_FAILED, this.GetSessionContext().AccountID,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                           String.Format("Failed to add payment instrument {0} to account {1}; Ach Account#: {2}",
                                   instrumentToken.ToString(),
                                   (acct.AccountID.HasValue)
                                   ? acct.AccountID.Value.ToString()
                                   : acct.Username, paymentMethod.AccountNumber));
            }
            mLogger.LogException(
              "Error Adding Payment Instrument; Acct#=" + paymentMethod.AccountNumber + "; username=" + acct.Username +
              ";accID=" + acct.AccountID.ToString() + ";piid=" + instrumentToken.ToString(), e);
            throw new MASBasicException("Error processing payment information");
          }
          scope.Complete();
        }

        if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
          paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
        {
          //success audit event
          auditor.FireEventWithAdditionalData((int)MTAuditEvent.AUDITEVENT_ADD_CREDITCARD_SUCCESS, this.GetSessionContext().AccountID,
                    (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                    String.Format("Successfully added payment instrument {0} to account {1}",
                          instrumentToken.ToString(),
                          (acct.AccountID.HasValue) ? acct.AccountID.Value.ToString() : acct.Username),
                          this.GetSessionContext().LoggedInAs, this.GetSessionContext().ApplicationName);
        }
        else
        {
          auditor.FireEventWithAdditionalData((int)MTAuditEvent.AUDITEVENT_ADD_ACH_SUCCESS, this.GetSessionContext().AccountID,
                    (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                    String.Format("Successfully added payment instrument {0} to account {1}",
                          instrumentToken.ToString(),
                          (acct.AccountID.HasValue) ? acct.AccountID.Value.ToString() : acct.Username),
                          this.GetSessionContext().LoggedInAs, this.GetSessionContext().ApplicationName);
        }

        if (arNotifyExcp != null && m_EPSConfig.ArPayImplementation.RaiseError)
        {
          throw arNotifyExcp;
        }
      }
    }

    public void SchedulePayment(Guid paymentToken, DateTime paymentDate, bool tryDunning, ref MetraPaymentInfo paymentInfo)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("SchedulePayment"))
      {
        try
        {
          MetraPaymentMethod paymentMethod = null;
          int acctId;

          GetPaymentMethodDetailInternal(paymentToken, out paymentMethod, out acctId);

          if (paymentMethod == null)
          {
            auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_SCHEDULE_PAYMENT_FAILURE, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
              String.Format("Invalid payment instrument {0}", paymentToken.ToString()));

            mLogger.LogError("Invalid Payment token supplied.");
            throw new MASBasicException("Invalid Payment token supplied.");
          }

          if (paymentDate.Date < MetraTime.Now.Date || paymentDate.Date > MetraTime.Max.Date)
          {
            auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_SCHEDULE_PAYMENT_FAILURE, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
              String.Format("Invalid payment date {0}", paymentDate));

            mLogger.LogError("Invalid payment date supplied.");
            throw new MASBasicException("Invalid payment date supplied.");
          }


          //Call to check whether invoice has been sent as both single-invoice and multiple-invoice throw error
          ValidatePaymentInfo(paymentInfo);

          using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                           new TransactionOptions(),
                                                           EnterpriseServicesInteropOption.Full))
          {
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
              int id_pending_payment = -1;
              using (IMTCallableStatement stmt = conn.CreateCallableStatement("InsertPaymentPendingTrans"))
              {
                //stmt.AddParam("p_acct_id",  MTParameterType.Integer, null);
                stmt.AddParam("p_acct_id", MTParameterType.Integer, acctId);
                stmt.AddParam("p_payment_instr_id", MTParameterType.String, paymentMethod.PaymentInstrumentID.ToString());
                stmt.AddParam("p_description", MTParameterType.String, paymentInfo.Description);
                stmt.AddParam("p_currency", MTParameterType.String, paymentInfo.Currency);
                stmt.AddParam("p_amount", MTParameterType.Decimal, paymentInfo.Amount);
                stmt.AddParam("p_trydunning", MTParameterType.String, (tryDunning ? "1" : "0"));
                stmt.AddParam("p_dt_create", MTParameterType.DateTime, MetraTime.Now);
                stmt.AddParam("p_dt_execute", MTParameterType.DateTime, paymentDate.Date);
                stmt.AddOutputParam("p_id_pending_payment", MTParameterType.Integer);
                stmt.ExecuteNonQuery();

                id_pending_payment = (int)stmt.GetOutputValue("p_id_pending_payment");
              }

              if (!string.IsNullOrEmpty(paymentInfo.InvoiceNum) || !string.IsNullOrEmpty(paymentInfo.PONum) || paymentInfo.IsInvoiceDateDirty)
              {
                using (IMTPreparedStatement prepStmt = conn.CreatePreparedStatement(m_InsertSchedPymtDetailsQuery))
                {
                  prepStmt.AddParam(MTParameterType.Integer, id_pending_payment);
                  prepStmt.AddParam(MTParameterType.String, paymentInfo.InvoiceNum);
                  prepStmt.AddParam(MTParameterType.DateTime, paymentInfo.InvoiceDate);
                  prepStmt.AddParam(MTParameterType.String, paymentInfo.PONum);
                  prepStmt.AddParam(MTParameterType.Decimal, paymentInfo.Amount);
                  prepStmt.ExecuteNonQuery();
                }
              }

              if (paymentInfo.MetraPaymentInvoices != null && paymentInfo.MetraPaymentInvoices.Count > 0)
              {
                //IMTQueryAdapter qa = new MTQueryAdapter();
                //qa.Init(@"Queries\ElectrionicPaymentService");
                //qa.SetQueryTag("__INSERT_SCHEDULED_PAYMENT_DETAILS__");

                foreach (MetraPaymentInvoice invoice in paymentInfo.MetraPaymentInvoices)
                {
                  using (IMTPreparedStatement prepStmt = conn.CreatePreparedStatement(m_InsertSchedPymtDetailsQuery))
                  {
                    prepStmt.AddParam(MTParameterType.Integer, id_pending_payment);
                    prepStmt.AddParam(MTParameterType.String, invoice.InvoiceNum);
                    prepStmt.AddParam(MTParameterType.DateTime, invoice.InvoiceDate);
                    prepStmt.AddParam(MTParameterType.String, invoice.PONum);
                    prepStmt.AddParam(MTParameterType.Decimal, invoice.AmountToPay);
                    prepStmt.ExecuteNonQuery();
                  }
                }
              }

            }

            scope.Complete();
          }
          //success audit event
          auditor.FireEvent((int)MTAuditEvent.AUDITEVENT_SCHEDULE_PAYMENT_SUCCESS, this.GetSessionContext().AccountID,
                    (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                    String.Format("Successfully scheduled payment on {0} for payment instrument {1} for account {2}",
                            paymentDate,
                            paymentMethod.PaymentInstrumentID.ToString(),
                            acctId));
        }
        catch (MASBasicException masE)
        {
          mLogger.LogException("MAS Exception in SchedulePayment", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Unexpected Exception in SchedulePayment", e);
          throw new MASBasicException("Unhandled error in payment scheduling");
        }
      }
    }
    #endregion

    #region IOneTimePaymentService Members
    public void OneTimeDebit(AccountIdentifier acct, MetraPaymentMethod paymentMethod, ref MetraPaymentInfo paymentInfo)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("OneTimeDebit"))
      {
        OneTimeDebitV2(acct, paymentMethod, ref paymentInfo, 0, "");
      }
    }
    public void OneTimeCredit(AccountIdentifier acct, MetraPaymentMethod paymentMethod, ref MetraPaymentInfo paymentInfo)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("OneTimeCredit"))
      {
        OneTimeCreditV2(acct, paymentMethod, ref paymentInfo, 0, "");
      }
    }
    #endregion

    #region IOneTimePaymentServiceV2 Members

    public void OneTimeDebitV2(AccountIdentifier acct, MetraPaymentMethod paymentMethod, ref MetraPaymentInfo paymentInfo, double timeOut, string classOfService)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("OneTimeDebitV2"))
      {
        if (DoesTransactionExist(ref paymentInfo))
        {
          return;
        }

        CheckExceededMaxOpenTransactions();
        if (timeOut == 0)
        {
          timeOut = m_EPSConfig.DefaultTransactionTimeOut;
        }
        DateTime endTime = DateTime.Now.AddMilliseconds(timeOut);
        int accountID = ResolveAccount(acct);

        string arRequestId = string.Empty;

        ArNotificationProcessorException arNotifyExcp = null;


        if (paymentMethod.RawAccountNumber.Length < 4)
        {
          throw new MASBasicException("Account number length is invalid");
        }

        if (accountID == 0)
          throw new MASBasicException("Unable to resolve account information");

        //We need to save the payment method, even though this is a one-time payment, because otherwise we can't void it if necessary.
        Guid paymentInstrumentId;
        AccountIdentifier tempAcct = new AccountIdentifier("OneTimeNonexistentuser", "MT");
        if (!IsInstrumentOnFile(paymentMethod, ResolveAccount(tempAcct), out paymentInstrumentId))
        {
          AddPaymentMethod(tempAcct, paymentMethod, out paymentInstrumentId);
        }
        paymentMethod.PaymentInstrumentID = paymentInstrumentId;

        //Call to check whether invoice has been sent as both single-invoice and multiple-invoice throw error
        ValidatePaymentInfo(paymentInfo);

        try
        {
          arRequestId = InitiateARPayment(accountID, paymentMethod.PaymentInstrumentID, paymentInfo);
        }
        catch (Exception excp)
        {
          mLogger.LogException("Error while executing InitiateARPayment. ", excp);
          arNotifyExcp = new ArNotificationProcessorException(excp.Message);
        }

        LogPaymentHistory(accountID, paymentMethod.PaymentInstrumentID, paymentMethod, paymentInfo,
                                TransactionType.DEBIT);
        using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                             new TransactionOptions(),
                                                             EnterpriseServicesInteropOption.Full))
        {
          bool transactionCompleted = false;
          while (!transactionCompleted)
          {
            MetraPayTProcessorClient tpClient = null;

            #region try

            try
            {
              tpClient = InitializeTPServiceCall(CalculateServiceName(paymentMethod, paymentInfo, accountID));

              //  Submit the one time debit
              if (endTime <= DateTime.Now)
              {
                FailTransaction(paymentInfo.TransactionSessionId);
                throw new TimeoutException();
              }

              tpClient.SubmitOneTimeDebit(paymentMethod, ref paymentInfo, timeOut * m_EPSConfig.TimeOutStepDown, classOfService);

              //If we've timed out, throw a timeout exception
              if (endTime <= DateTime.Now)
              {
                FailTransaction(paymentInfo.TransactionSessionId);
                throw new TimeoutException();
              }
              UpdateTransactionState(paymentInfo.TransactionSessionId, TransactionState.RECEIVED_RESPONSE);

              tpClient.Close();
              tpClient = null;
              if (paymentMethod.GetType() == typeof(ACHPaymentMethod))
              {
                WritePendingACHTxDetails(paymentInfo, paymentMethod, accountID, arRequestId);
              }

              if (m_EPSConfig.MetraPayLog.LogRecord != null
                  && m_EPSConfig.MetraPayLog.LogRecord != string.Empty
                  && (m_EPSConfig.MetraPayLog.LogRecord.ToUpper().Equals("TRUE"))
              && paymentMethod.GetType() == typeof(CreditCardPaymentMethod))
              {
                WritePaymentRecord(accountID, paymentMethod, paymentInfo);
              }
              UpdateTransactionState(paymentInfo.TransactionSessionId,
                                     TransactionState.POST_PROCESSING_SUCCESSFUL);
              //If we've timed out, throw a timeout exception
              if (endTime <= DateTime.Now)
              {
                FailTransaction(paymentInfo.TransactionSessionId);
                throw new TimeoutException();
              }
              transactionCompleted = true;
            }
            #endregion endregion
            #region Catch blocks
            #region payment processor fault

            catch (FaultException<PaymentProcessorFaultDetail> e)
            {
              CloseTransaction(paymentInfo.TransactionSessionId, TransactionState.REJECTED,
                               String.Join(",", e.Detail.ErrorMessages));
              if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
                  paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
              {
                auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ONETIME_DEBIT_CREDITCARD_FAILED,
                                             this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                             String.Format(
                                               "ProcessorException: Failed to process one-time credit card debit for invoice: {0}",
                                               GetInvoiceNumbers(paymentInfo)));
                try
                {
                  NotifyARPaymentFailed(arRequestId);
                }
                catch (Exception excp)
                {
                  mLogger.LogException(
                    string.Format("Error while executing AR Notification failed message for AR Request ID : {0}",
                                  arRequestId), excp);
                  arNotifyExcp = new ArNotificationProcessorException(excp.Message);
                }
              }
              else
              {
                auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ONETIME_DEBIT_ACH_FAILED,
                                             this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                             String.Format(
                                               "ProcessorException: Failed to process one-time ach debit for invoice: {0}",
                                               GetInvoiceNumbers(paymentInfo)));
              }
              mLogger.LogException(
                String.Format("Payment processor exception while processing payment for  Invoice {0}",
                              GetInvoiceNumbers(paymentInfo)), e);
              throw new PaymentProcessorException(e.Detail);
            }
            #endregion
            #region MASBasicFaultDetail

            catch (FaultException<MASBasicFaultDetail> e)
            {
              if (e.Detail.ErrorCode == ErrorCodes.TRANSACTION_ALREADY_REJECTED)
              {
                //Log this like a payment processor fault, since it means the opayment server already got a payment fault with this tx ID.
                CloseTransaction(paymentInfo.TransactionSessionId, TransactionState.REJECTED);

                if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
                    paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
                {
                  auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ONETIME_DEBIT_CREDITCARD_FAILED,
                                               this.GetSessionContext().AccountID,
                                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                               String.Format(
                                                 "ProcessorException: Failed to process one-time credit card debit for invoice: {0}",
                                                 GetInvoiceNumbers(paymentInfo)));
                  try
                  {
                    NotifyARPaymentFailed(arRequestId);
                  }
                  catch (Exception excp)
                  {
                    mLogger.LogException(
                      string.Format("Error while executing AR Notification failed message for AR Request ID : {0}",
                                    arRequestId), excp);
                    arNotifyExcp = new ArNotificationProcessorException(excp.Message);
                  }
                }
                else
                {
                  auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ONETIME_DEBIT_ACH_FAILED,
                                               this.GetSessionContext().AccountID,
                                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                               String.Format(
                                                 "ProcessorException: Failed to process one-time ach debit for invoice: {0}",
                                                 GetInvoiceNumbers(paymentInfo)));
                }
                mLogger.LogException(
                  String.Format("Payment processor exception while processing payment for  Invoice {0}",
                                GetInvoiceNumbers(paymentInfo)), e);
                throw new MASBasicException(e.Detail);
              }
              else
              {
                FailTransaction(paymentInfo.TransactionSessionId);
                if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
                    paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
                {
                  auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ONETIME_DEBIT_CREDITCARD_FAILED,
                                               this.GetSessionContext().AccountID,
                                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                               String.Format(
                                                 "FaultException: Failed to process one-time credit card debit for invoice: {0}",
                                                 GetInvoiceNumbers(paymentInfo)));
                }
                else
                {
                  auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ONETIME_DEBIT_ACH_FAILED,
                                               this.GetSessionContext().AccountID,
                                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                               String.Format(
                                                 "FaultException: Failed to process one-time ach debit for invoice: {0}",
                                                 GetInvoiceNumbers(paymentInfo)));
                }
                mLogger.LogException(
                  String.Format("Fault exception while processing payment for  Invoice {0}",
                                GetInvoiceNumbers(paymentInfo)), e);
                throw new MASBasicException(e.Detail);
              }

            }
            #endregion
            #region CommunicationException

            catch (CommunicationException e)
            {
              FailTransaction(paymentInfo.TransactionSessionId);
              if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
                  paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
              {
                auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ONETIME_DEBIT_CREDITCARD_FAILED,
                                             this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                             String.Format(
                                               "CommunicationException: Failed to process one-time credit card debit for invoice: {0}",
                                               GetInvoiceNumbers(paymentInfo)));
              }
              else
              {
                auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ONETIME_DEBIT_ACH_FAILED,
                                             this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                             String.Format(
                                               "CommunicationException: Failed to process one-time ach debit for invoice: {0}",
                                               GetInvoiceNumbers(paymentInfo)));
              }

              mLogger.LogException(
                String.Format("Communication exception while processing payment for  Invoice {0}.",
                              GetInvoiceNumbers(paymentInfo)),
                e);
              throw;
            }
            #endregion
            #region TimeoutException

            catch (TimeoutException e)
            {
              HandleTimeoutException(paymentInfo, paymentMethod, accountID, endTime, e, scope);
            }
            #endregion
            #region Exception

            catch (Exception e)
            {
              FailTransaction(paymentInfo.TransactionSessionId);
              if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
                  paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
              {
                auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ONETIME_DEBIT_CREDITCARD_FAILED,
                                             this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                             String.Format(
                                               "TimeoutException: Failed to process one-time credit card debit for invoice: {0}",
                                               GetInvoiceNumbers(paymentInfo)));
              }
              else
              {
                auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ONETIME_DEBIT_ACH_FAILED,
                                             this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                             String.Format(
                                               "TimeoutException: Failed to process one-time ach debit for invoice: {0}",
                                               GetInvoiceNumbers(paymentInfo)));
              }
              mLogger.LogException(
                String.Format("Exception while processing payment for  Invoice {0}", GetInvoiceNumbers(paymentInfo)),
                e);

              throw new MASBasicException("Error processing one-time credit card debit.");
            }

            #endregion

            #endregion

            finally
            {
              if (null != tpClient)
              {
                try
                {
                  tpClient.Close();
                }
                catch
                {
                  tpClient.Abort();
                }
              }
            }
          }

          if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
              paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
          {
            try
            {
              NotifyARPaymentSucceeded(arRequestId);
            }
            catch (Exception excp)
            {
              FailTransaction(paymentInfo.TransactionSessionId);
              mLogger.LogException(
                string.Format("Error while executing AR Notification failed message for AR Request ID : {0}",
                              arRequestId), excp);
              arNotifyExcp = new ArNotificationProcessorException(excp.Message);
            }
          }

          scope.Complete();

        }
        if (endTime <= DateTime.Now)
        {
          FailTransaction(paymentInfo.TransactionSessionId);
          throw new TimeoutException();
        }

        if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
            paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
        {
          auditor.FireEvent((int)MTAuditEvent.AUDITEVENT_ONETIME_DEBIT_CREDITCARD_SUCCESS,
                                this.GetSessionContext().AccountID,
                            (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                String.Format("Successfully processed one-time credit card debit for invoice: {0}",
                                              GetInvoiceNumbers(paymentInfo)));
        }
        else
        {
          auditor.FireEvent((int)MTAuditEvent.AUDITEVENT_ONETIME_DEBIT_ACH_SUCCESS,
                                this.GetSessionContext().AccountID,
                            (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                String.Format("Successfully processed one-time ach debit for invoice: {0}",
                                              GetInvoiceNumbers(paymentInfo)));
        }
        mLogger.LogDebug(String.Format("Successfully processed one-time credit card debit for invoice: {0}",
                                       GetInvoiceNumbers(paymentInfo)));

        if (arNotifyExcp != null && m_EPSConfig.ArPayImplementation.RaiseError)
        {
          throw arNotifyExcp;
        }
        if (endTime <= DateTime.Now)
        {
          FailTransaction(paymentInfo.TransactionSessionId);
          throw new TimeoutException();
        }
        CloseTransaction(paymentInfo.TransactionSessionId, TransactionState.SUCCESS);
      }
    }


    public void OneTimeCreditV2(AccountIdentifier acct, MetraPaymentMethod paymentMethod, ref MetraPaymentInfo paymentInfo, double timeOut, string classOfService)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("OneTimeCreditV2"))
      {
        if (DoesTransactionExist(ref paymentInfo))
        {
          return;
        }

        CheckExceededMaxOpenTransactions();
        if (timeOut == 0)
        {
          timeOut = m_EPSConfig.DefaultTransactionTimeOut;
        }
        DateTime endTime = DateTime.Now.AddMilliseconds(timeOut);

        int accountID = ResolveAccount(acct);

        if (paymentMethod.RawAccountNumber.Length < 4)
        {
          throw new MASBasicException("Account number length is invalid");
        }

        if (accountID == 0)
          throw new MASBasicException("Unable to resolve account information");

        //We need to save the payment method, even though this is a one-time payment, because otherwise we can't void it if necessary.
        Guid paymentInstrumentId;
        AccountIdentifier tempAcct = new AccountIdentifier("nonexistentuser", "MT");
        if (!IsInstrumentOnFile(paymentMethod, ResolveAccount(tempAcct), out paymentInstrumentId))
        {
          AddPaymentMethod(tempAcct, paymentMethod, out paymentInstrumentId);
        }
        paymentMethod.PaymentInstrumentID = paymentInstrumentId;

        //Call to check whether invoice has been sent as both single-invoice and multiple-invoice throw error
        ValidatePaymentInfo(paymentInfo);
        LogPaymentHistory(accountID, paymentMethod.PaymentInstrumentID, paymentMethod, paymentInfo,
                                    TransactionType.CREDIT);

        using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                             new TransactionOptions(),
                                                             EnterpriseServicesInteropOption.Full))
        {
          MetraPayTProcessorClient tpClient = null;
          bool transactionCompleted = false;
          while (!transactionCompleted)
          {
            try
            {
              tpClient = InitializeTPServiceCall(CalculateServiceName(paymentMethod, paymentInfo, accountID));

              //  Submit the one time debit
              if (endTime <= DateTime.Now)
              {
                FailTransaction(paymentInfo.TransactionSessionId);
                throw new TimeoutException();
              }

              tpClient.SubmitOneTimeCredit(paymentMethod, ref paymentInfo, timeOut * m_EPSConfig.TimeOutStepDown, classOfService);
              //If we've timed out, throw a timeout exception
              if (endTime <= DateTime.Now)
              {
                FailTransaction(paymentInfo.TransactionSessionId);
                throw new TimeoutException();
              }
              UpdateTransactionState(paymentInfo.TransactionSessionId, TransactionState.RECEIVED_RESPONSE);

              tpClient.Close();
              tpClient = null;
              if (paymentMethod.GetType() == typeof(ACHPaymentMethod))
              {
                WritePendingACHTxDetails(paymentInfo, paymentMethod, accountID, string.Empty);
              }

              if (m_EPSConfig.MetraPayLog.LogRecord != null
                  && m_EPSConfig.MetraPayLog.LogRecord != string.Empty
                  && (m_EPSConfig.MetraPayLog.LogRecord.ToUpper().Equals("TRUE"))
                  && paymentMethod.GetType() == typeof(CreditCardPaymentMethod))
              {
                WritePaymentRecord(accountID, paymentMethod, paymentInfo);
              }
              UpdateTransactionState(paymentInfo.TransactionSessionId,
                   TransactionState.POST_PROCESSING_SUCCESSFUL);
              transactionCompleted = true;
            }
            catch (FaultException<PaymentProcessorFaultDetail> e)
            {
              CloseTransaction(paymentInfo.TransactionSessionId, TransactionState.REJECTED,
                             String.Join(",", e.Detail.ErrorMessages));
              if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
                  paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
              {
                auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ONETIME_CREDIT_CREDITCARD_FAILED,
                                         this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                         String.Format(
                                           "ProcessorException: Failed to process one-time credit card debit for invoice: {0}",
                                           GetInvoiceNumbers(paymentInfo)));
              }
              else
              {
                auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ONETIME_CREDIT_ACH_FAILED,
                                         this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                         String.Format(
                                           "ProcessorException: Failed to process one-time ach credit for invoice: {0}",
                                           GetInvoiceNumbers(paymentInfo)));
              }
              mLogger.LogException(
                String.Format("Payment processor exception while processing payment for  Invoice {0}",
                              GetInvoiceNumbers(paymentInfo)), e);

              throw new PaymentProcessorException(e.Detail);
            }
            catch (FaultException<MASBasicFaultDetail> e)
            {
              if (e.Detail.ErrorCode == ErrorCodes.TRANSACTION_ALREADY_REJECTED)
              {
                CloseTransaction(paymentInfo.TransactionSessionId, TransactionState.REJECTED);
                if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
                    paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
                {
                  auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ONETIME_CREDIT_CREDITCARD_FAILED,
                                                 this.GetSessionContext().AccountID,
                                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                                 String.Format(
                                                   "FaultException: Failed to process one-time credit card credit for invoice: {0}",
                                                   GetInvoiceNumbers(paymentInfo)));
                }
                else
                {
                  auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ONETIME_CREDIT_ACH_FAILED,
                                                 this.GetSessionContext().AccountID,
                                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                                 String.Format(
                                                   "FaultException: Failed to process one-time ach credit for invoice: {0}",
                                                   GetInvoiceNumbers(paymentInfo)));
                }
                mLogger.LogException(
                  String.Format("Payment processor rejected credit for Invoice {0}",
                                GetInvoiceNumbers(paymentInfo)), e);
                throw new MASBasicException(e.Detail);
              }
              else
              {
                if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
                    paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
                {
                  auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ONETIME_CREDIT_CREDITCARD_FAILED,
                                           this.GetSessionContext().AccountID,
                                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                           String.Format(
                                             "FaultException: Failed to process one-time credit card credit for invoice: {0}",
                                             GetInvoiceNumbers(paymentInfo)));
                }
                else
                {
                  auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ONETIME_CREDIT_ACH_FAILED,
                                           this.GetSessionContext().AccountID,
                                           (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                           String.Format(
                                             "FaultException: Failed to process one-time ach credit for invoice: {0}",
                                             GetInvoiceNumbers(paymentInfo)));
                }
                mLogger.LogException(
                  String.Format("Fault exception while processing payment for  Invoice {0}",
                                GetInvoiceNumbers(paymentInfo)), e);
                FailTransaction(paymentInfo.TransactionSessionId);
                throw new MASBasicException(e.Detail);
              }
            }
            catch (CommunicationException e)
            {
              FailTransaction(paymentInfo.TransactionSessionId);
              if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
                  paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
              {
                auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ONETIME_CREDIT_CREDITCARD_FAILED,
                                         this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                         String.Format(
                                           "CommunicationException: Failed to process one-time credit card credit for invoice: {0}",
                                           GetInvoiceNumbers(paymentInfo)));
              }
              else
              {
                auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ONETIME_CREDIT_ACH_FAILED,
                                         this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                         String.Format(
                                           "CommunicationException: Failed to process one-time ach credit for invoice: {0}",
                                           GetInvoiceNumbers(paymentInfo)));
              }
              mLogger.LogException(
                String.Format("Communication exception while processing payment for  Invoice {0}.",
                              GetInvoiceNumbers(paymentInfo)),
                e);
              throw;
            }
            catch (TimeoutException e)
            {
              HandleTimeoutException(paymentInfo, paymentMethod, accountID, endTime, e, scope);
            }

            catch (Exception e)
            {
              FailTransaction(paymentInfo.TransactionSessionId);
              if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
                  paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
              {
                auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ONETIME_CREDIT_CREDITCARD_FAILED,
                                         this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                         String.Format(
                                           "TimeoutException: Failed to process one-time credit card debit for invoice(s): {0}",
                                           GetInvoiceNumbers(paymentInfo)));
              }
              else
              {
                auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ONETIME_CREDIT_ACH_FAILED,
                                         this.GetSessionContext().AccountID,
                                         (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                                         String.Format(
                                           "TimeoutException: Failed to process one-time ach credit for invoice(s): {0}",
                                           GetInvoiceNumbers(paymentInfo)));
              }
              mLogger.LogException(
                String.Format("Exception while processing payment for  Invoice(s) {0}",
                              GetInvoiceNumbers(paymentInfo)), e);
              throw new MASBasicException("Error processing one-time credit card credit.");
            }
            finally
            {
              if (null != tpClient)
              {
                try
                {
                  tpClient.Close();
                }
                catch
                {
                  tpClient.Abort();
                }
              }
            }
          }
          scope.Complete();
        }

        if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
          paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
        {
          auditor.FireEvent((int)MTAuditEvent.AUDITEVENT_ONETIME_CREDIT_CREDITCARD_SUCCESS, this.GetSessionContext().AccountID,
                    (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                    String.Format("Successfully processed one-time credit card debit for invoice: {0}",
                          GetInvoiceNumbers(paymentInfo)));
        }
        else
        {
          auditor.FireEvent((int)MTAuditEvent.AUDITEVENT_ONETIME_CREDIT_ACH_SUCCESS, this.GetSessionContext().AccountID,
                    (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, accountID,
                    String.Format("Successfully processed one-time ach credit for invoice(s): {0}",
                          GetInvoiceNumbers(paymentInfo)));
        }
        mLogger.LogDebug(String.Format("Successfully processed one-time credit card credit for invoice(s): {0}",
                         GetInvoiceNumbers(paymentInfo)));
        if (endTime <= DateTime.Now)
        {
          FailTransaction(paymentInfo.TransactionSessionId);
          throw new TimeoutException();
        }
        CloseTransaction(paymentInfo.TransactionSessionId, TransactionState.SUCCESS);
      }
    }

    #endregion

    #region ICleanupTransactionService Members
    public void VoidTransaction(Guid transactionId, double timeOut = 0, string classOfService = "")
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("VoidTransaction"))
      {
        var resourceManager = new ResourcesManager();
        if (timeOut == 0)
        {
          timeOut = m_EPSConfig.DefaultTransactionTimeOut;
        }
        DateTime endTime = DateTime.Now.AddMilliseconds(timeOut);

        //Check that this transaction is in FAILURE mode.  We know that DoesTransactionExist() throws an exception if the transaction
        // failed, so use that.
        IMTQueryAdapter qa = new MTQueryAdapter();
        qa.Init("Queries\\ElectronicPaymentService");
        qa.SetQueryTag("__GET_TRANSACTION_INFO__");
        string txInfo = qa.GetQuery();
        using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Suppress,
                                                     new TransactionOptions(),
                                                     EnterpriseServicesInteropOption.Full))
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(txInfo))
            {
              stmt.AddParam("id_payment_transaction", MTParameterType.String,
                            transactionId.ToString());
              using (IMTDataReader dataReader = stmt.ExecuteReader())
              {
                //if there are records, then we do have this credit card on file.  If not, we move on.
                if (dataReader.Read())
                {
                  TransactionState state =
                    (TransactionState)
                    Enum.Parse(typeof(TransactionState), dataReader.GetString("n_state"));
                  Guid token = Guid.Parse(dataReader.GetString("id_payment_instrument"));
                  byte[] blob = dataReader.GetBytes("payment_info");
                  MetraPaymentInfo paymentInfo = Blob2MetraPaymentInfo(ref blob);
                  TransactionType type =
                    (TransactionType)Enum.Parse(typeof(TransactionType), dataReader.GetString("n_transaction_type"));
                  if (state != TransactionState.FAILURE)
                  {
                    throw new MASBasicException(ErrorCodes.TRANSACTION_NOT_FAILED);
                  }
                  MetraPaymentMethod paymentMethod = null;
                  int acctId;
                  GetPaymentMethodDetailInternal(token, out paymentMethod, out acctId);

                  MetraPayTProcessorClient tpClient = null;
                  try
                  {
                    tpClient = InitializeTPServiceCall(CalculateServiceName(paymentMethod, paymentInfo, acctId),
                                                       timeOut);

                    if (endTime <= DateTime.Now)
                    {
                      throw new TimeoutException();
                    }

                    //Call the service method
                    tpClient.SubmitVoid(token, ref paymentInfo, timeOut * m_EPSConfig.TimeOutStepDown, classOfService);
                    CloseTransaction(paymentInfo.TransactionSessionId, TransactionState.REVERSED);
                    return;
                  }
                  catch (TimeoutException e)
                  {
                    mLogger.LogException(
                      String.Format(resourceManager.GetLocalizedResource("VOIDING_TIMEOUT"),
                                    GetInvoiceNumbers(paymentInfo)), e);
                    throw new MASBasicException(
                      String.Format(resourceManager.GetLocalizedResource("VOIDING_TIMEOUT"),
                                    GetInvoiceNumbers(paymentInfo)), ErrorCodes.TRANSACTION_TIMED_OUT);
                  }
                  catch (FaultException<MASBasicFaultDetail> e)
                  {
                    if (e.Detail.ErrorCode == ErrorCodes.TRANSACTION_TIMED_OUT)
                    {
                      mLogger.LogException(
                        String.Format(resourceManager.GetLocalizedResource("VOIDING_TIMEOUT"),
                                      GetInvoiceNumbers(paymentInfo)), e);
                      throw new MASBasicException(
                        String.Format(resourceManager.GetLocalizedResource("VOIDING_TIMEOUT"),
                                      GetInvoiceNumbers(paymentInfo)), ErrorCodes.TRANSACTION_TIMED_OUT);
                    }
                    else if (e.Detail.ErrorCode == ErrorCodes.TRANSACTION_ALREADY_SETTLED)
                    {
                      //If the transaction has already been settled, we need a new transaction to balance the books,
                      //and only if that succeeds can we say that we've successfully reversed this one.  Since this is
                      // just to balance the books, we don't want to record it as a payment.
                      //If the new tx fails, we don't know what state it's in
                      Guid newTxId = Guid.NewGuid();
                      Guid tempTxId = paymentInfo.TransactionSessionId;
                      paymentInfo.TransactionSessionId = newTxId;
                      AddLinkedTransaction(tempTxId, newTxId);
                      try
                      {
                        switch (type)
                        {

                          case TransactionType.DEBIT:
                            InternalCreditPaymentMethod(token, ref paymentInfo, timeOut, "", recordPayment: false);
                            break;
                          case TransactionType.CREDIT:
                            InternalDebitPaymentMethod(token, ref paymentInfo, timeOut, "", recordPayment: false);
                            break;
                          case TransactionType.CAPTURE:
                            InternalCreditPaymentMethod(token, ref paymentInfo, timeOut, "", recordPayment: false);
                            break;
                          default:
                            //Shouldn't happen
                            mLogger.LogError(
                              String.Format(resourceManager.GetLocalizedResource("BAD_TRANSACTION_STATE")),
                              paymentInfo.TransactionSessionId.ToString(), type.ToString());
                            throw new MASBasicException(String.Format(
                              resourceManager.GetLocalizedResource("BAD_TRANSACTION_STATE"),
                              paymentInfo.TransactionSessionId.ToString(), type.ToString()),
                                                        ErrorCodes.BAD_TRANSACTION_STATE);
                        }
                        CloseTransaction(tempTxId, TransactionState.REVERSED);
                      }
                      catch (Exception newEx)
                      {
                        //For now, just re-throw exceptions.
                        mLogger.LogException(newEx.Message, newEx);
                        throw;
                      }
                    }
                  }
                  catch (CommunicationException e)
                  {
                    mLogger.LogException(
                      String.Format("Communication exception while processing payment for  Invoice {0}.",
                                    GetInvoiceNumbers(paymentInfo)), e);
                    throw;
                  }
                }
                else
                {
                  mLogger.LogError(String.Format(resourceManager.GetLocalizedResource("TRANSACTION_NOT_FOUND"),
                                                 transactionId.ToString()));
                  throw new MASBasicException(ErrorCodes.TRANSACTION_NOT_FOUND);
                }
              }
            }
          }
          scope.Complete();
        }
      }
    }

    public void GetPaymentTransactions(ref MTList<PaymentTransaction> paymentTransactions)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetPaymentTransactions"))
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (
              IMTFilterSortStatement stmt = conn.CreateFilterSortStatement("queries\\ElectronicPaymentService",
                                                                           "__GET_TRANSACTIONS__"))
          {
            ApplyFilterSortCriteria(stmt, paymentTransactions);
            using (IMTDataReader rdr = stmt.ExecuteReader())
            {

              while (rdr.Read())
              {
                PaymentTransaction temp = new PaymentTransaction();
                temp.Amount = rdr.GetDecimal("Amount");
                if (rdr.IsDBNull("InvoiceNumber"))
                {
                  temp.InvoiceNumber = "";
                }
                else
                {
                  temp.InvoiceNumber = rdr.GetString("InvoiceNumber");
                }
                temp.TransactionDate = rdr.GetDateTime("TransactionDate");
                temp.Payer = rdr.GetInt32("Payer");
                temp.TransactionId = Guid.Parse(rdr.GetString("TransactionId"));
                temp.Status = rdr.GetString("Status");

                paymentTransactions.Items.Add(temp);
              }

              paymentTransactions.TotalRows = stmt.TotalRows;
            }
          }
        }
      }
    }

    public void SetPaymentStatus(List<Guid> transactionIds, TransactionState status, string notes)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("SetPaymentStatus"))
      {
        //Doing this inefficiently for now, because there should only be a few transactions to change at a time.
        foreach (Guid transactionId in transactionIds)
        {
          UpdateTransactionState(transactionId, status, notes);
        }
      }
    }

    #endregion
    #region Private Methods
    private static MetraPaymentInfo Blob2MetraPaymentInfo(ref byte[] rawData)
    {
      MemoryStream piStream = new MemoryStream(rawData);
      var _BinaryFormatter = new System.Runtime.Serialization.Formatters.Binary.BinaryFormatter();
      return (MetraPaymentInfo)_BinaryFormatter.Deserialize(piStream);
    }

    // The following methods are needed to ensure proper locking semantics in SQL Server.  
    // A number of methods need to lock all the instruments for a given account because the operation
    // ends up updating other instruments (such as justifying the priority numbers), while others only
    // need to ensure that the single instrument is locked.  
    // The assumption is that these methods are called within a TransactionScope block.
    private void LockAllInstrumentsForAccount(int accountId)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        if (conn.ConnectionInfo.IsSqlServer)
        {
          using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
          {
            queryAdapter.Item = new MTQueryAdapter();
            queryAdapter.Item.Init(@"Queries\ElectronicPaymentService");
            queryAdapter.Item.SetQueryTag("__LOCK_ALL_INSTRUMENTS_FOR_ACCOUNT__");

            using (IMTPreparedStatement prepStmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
            {
              prepStmt.AddParam(MTParameterType.Integer, accountId);

              prepStmt.ExecuteNonQuery();
            }
          }
        }
      }
    }

    private void LockPaymentInstrument(Guid paymentInstrumentId)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        if (conn.ConnectionInfo.IsSqlServer)
        {
          using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
          {
            queryAdapter.Item = new MTQueryAdapter();
            queryAdapter.Item.Init(@"Queries\ElectronicPaymentService");
            queryAdapter.Item.SetQueryTag("__LOCK_PAYMENT_INSTRUMENT__");

            using (IMTPreparedStatement prepStmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
            {
              prepStmt.AddParam(MTParameterType.String, paymentInstrumentId.ToString());

              prepStmt.ExecuteNonQuery();
            }
          }
        }
      }
    }

    private string GetARRequestIDFromPreAuth(Guid authToken, out decimal preAuthAmt)
    {
      try
      {

        string arRequestId = string.Empty;
        //requestPrams = string.Empty;

        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("PaymentServer",
              "__LOAD_PREAUTH_RECORD__"))
          {

            // This only handles the credit card case
            stmt.AddParam("%%AUTH_TOKEN%%", authToken.ToString());

            using (IMTDataReader dataReader = stmt.ExecuteReader())
            {
              // Read the payment security token details
              if (dataReader.Read())
              {
                arRequestId = dataReader.GetString("nm_ar_request_id");
                preAuthAmt = dataReader.GetDecimal("n_amount");
              }
              else
              {
                mLogger.LogError(string.Format("Preauth Record not found. AuthToken : {0}", authToken));
                throw new MASBasicException(string.Format("Preauth Record not found. AuthToken : {0}", authToken));
              }
            }
          }
        }

        return arRequestId;
      }
      catch (MASBasicException)
      {
        throw;
      }
      catch (Exception ex)
      {
        mLogger.LogException("Error at LoadPreauthRecord", ex);
        throw new MASBasicException("Error while processing LoadPreauthRecord...");
      }
    }

    private string InitiateARPayment(int acctID, Guid paymentInstrumentId, MetraPaymentInfo paymentInfo)
    {
      string requestID = string.Empty;

      if (mArPaymentIntegrationImpl != null)
      {
        requestID = mArPaymentIntegrationImpl.InitiatePayment(acctID, paymentInstrumentId, paymentInfo);
      }
      return requestID;
    }

    private void NotifyARPaymentSucceeded(string requestID)
    {
      if (mArPaymentIntegrationImpl != null && !string.IsNullOrEmpty(requestID))
      {
        mArPaymentIntegrationImpl.PaymentSucceed(requestID);
      }
    }

    private void NotifyARPaymentFailed(string requestID)
    {
      if (mArPaymentIntegrationImpl != null && !string.IsNullOrEmpty(requestID))
      {
        mArPaymentIntegrationImpl.PaymentFailed(requestID);
      }
    }

    private void NotifyARPaymentAbandoned(string requestID)
    {
      if (mArPaymentIntegrationImpl != null && !string.IsNullOrEmpty(requestID))
      {
        mArPaymentIntegrationImpl.PaymentAbandoned(requestID);
      }
    }

    private void ValidatePaymentInfo(MetraPaymentInfo paymentInfo)
    {
      if (String.IsNullOrEmpty(paymentInfo.Currency))
      {
        mLogger.LogError("Invoice Info has no currency value");
        throw new MASBasicException("Invoice Info has no currency value");
      }
      if (((paymentInfo.InvoiceNum != null) || (paymentInfo.IsInvoiceDateDirty == true) || (paymentInfo.PONum != null))
          && (paymentInfo.MetraPaymentInvoices != null && paymentInfo.MetraPaymentInvoices.Count > 0))
      {
        mLogger.LogError("Invoice Information sent in multiple places");
        throw new MASBasicException("Invoice Information sent in multiple places");
      }

      //if multiple invoices, make sure all invoice amounts are <= metrapayinfo.amount
      if (paymentInfo.MetraPaymentInvoices != null && paymentInfo.MetraPaymentInvoices.Count > 0 && paymentInfo.MetraPaymentInvoices.Sum(invoice => invoice.AmountToPay) > paymentInfo.Amount)
      {
        mLogger.LogError("Invoice Amounts greater than metrapayinfo amount.");
        throw new MASBasicException("Sum of invoice amounts greater than total amount specified");
      }

      if (paymentInfo.MetraPaymentInvoices != null && paymentInfo.MetraPaymentInvoices.Count > 1)
      {
        Dictionary<string, int> uniqueStorage = new Dictionary<string, int>();

        paymentInfo.MetraPaymentInvoices.ForEach(item =>
        {
          if (!string.IsNullOrEmpty(item.InvoiceNum))
          {
            if (uniqueStorage.ContainsKey(item.InvoiceNum))
            {
              mLogger.LogError("Duplicate invoice numbers found.");
              throw new MASBasicException("Duplicate invoice numbers found.");
            }
            else
              uniqueStorage.Add(item.InvoiceNum, 1);
          }
        });

      }
    }


    private string GetInvoiceNumbers(MetraPaymentInfo paymentInfo)
    {
      try
      {
        StringBuilder invoiceNos = new StringBuilder();

        if (!string.IsNullOrEmpty(paymentInfo.InvoiceNum))
          invoiceNos.AppendFormat("{0},", paymentInfo.InvoiceNum);

        if (paymentInfo.MetraPaymentInvoices != null && paymentInfo.MetraPaymentInvoices.Count > 0)
        {
          paymentInfo.MetraPaymentInvoices.ForEach(invoice => { invoiceNos.AppendFormat("{0},", invoice.InvoiceNum); });
        }

        return invoiceNos.ToString();
      }
      catch (Exception e)
      {
        mLogger.LogException("cannot extract invoice numbers from MetraPaymentInfo", e);
        return "";
      }
    }
    private void WritePaymentRecord(int acctId, MetraPaymentMethod paymentMethod, MetraPaymentInfo paymentInfo)
    {
      string idPaymentTxn = paymentInfo.TransactionSessionId.ToString();
      GetPaymentRecord paymentRecord = null;

      try
      {

        paymentRecord = GetGetPaymentRecord();

        DataRow row;
        row = paymentRecord.Input.NewRow();
        row["c_Namespace"] = DBNull.Value;
        row["c__AccountID"] = acctId;
        row["c__Amount"] = paymentInfo.Amount * -1;
        row["c_Description"] = paymentInfo.Description;
        row["c_EventDate"] = MetraTime.Now;
        row["c_Source"] = "MT";
        row["c_ReferenceID"] = paymentInfo.TransactionID;
        row["c_PaymentTxnID"] = idPaymentTxn;

        string number = string.Empty;

        switch (paymentMethod.PaymentMethodType)
        {
          case PaymentType.Credit_Card:
            row["c_PaymentMethod"] = (int)EnumHelper.GetDbValueByEnum(PaymentMethod.CreditCard);
            //row["c_CCType"] = (string)EnumHelper.GetEnumEntryName(((CreditCardPaymentMethod)paymentMethod).CreditCardType);
            row["c_CCType"] = (int)EnumHelper.GetDbValueByEnum(((CreditCardPaymentMethod)paymentMethod).CreditCardType);
            break;
          case PaymentType.ACH:
            row["c_PaymentMethod"] = (int)EnumHelper.GetDbValueByEnum(PaymentMethod.ACH);
            //row["c_CCType"] = (string)EnumHelper.GetEnumEntryName(((ACHPaymentMethod)paymentMethod).AccountType);
            row["c_CCType"] = (int)EnumHelper.GetDbValueByEnum(((ACHPaymentMethod)paymentMethod).AccountType);
            break;
        }

        row["c_CheckOrCardNumber"] = paymentMethod.AccountNumber.Substring(paymentMethod.AccountNumber.Length - 4);
        string paymentID = Guid.NewGuid().ToString();
        row["PaymentID"] = paymentID;

        paymentRecord.Input.Rows.Add(row);

        if ((paymentInfo.InvoiceNum != null) || (paymentInfo.IsInvoiceDateDirty) || (paymentInfo.PONum != null))
        {
          DataRow childRow;
          childRow = paymentRecord.PaymentDetailsInput.NewRow();
          childRow["c_Namespace"] = DBNull.Value;
          childRow["c__AccountID"] = acctId;
          childRow["c_InvoiceNum"] = paymentInfo.InvoiceNum;
          childRow["c_PONumber"] = paymentInfo.PONum;
          if (paymentInfo.InvoiceDate != null)
          {
            childRow["c_InvoiceDate"] = paymentInfo.InvoiceDate;
          }

          childRow["c__Amount"] = paymentInfo.Amount;
          childRow["PaymentID"] = paymentID;
          paymentRecord.PaymentDetailsInput.Rows.Add(childRow);
        }

        if (paymentInfo.MetraPaymentInvoices.HasValue())
        {
          paymentInfo.MetraPaymentInvoices.ForEach(invoice =>
          {
            DataRow childRow;
            childRow = paymentRecord.PaymentDetailsInput.NewRow();
            childRow["c_Namespace"] = DBNull.Value;
            childRow["c__AccountID"] = acctId;
            childRow["c_InvoiceNum"] = invoice.InvoiceNum;
            childRow["c_PONumber"] = invoice.PONum;
            if (invoice.InvoiceDate.HasValue)
            {
              childRow["c_InvoiceDate"] = invoice.InvoiceDate.Value;
            }
            childRow["c__Amount"] = invoice.AmountToPay;
            childRow["PaymentID"] = paymentID;
            paymentRecord.PaymentDetailsInput.Rows.Add(childRow);
          });
        }

        paymentRecord.Run();

        #region Process Metra Flow Script Error Outputs

        //Check Error occurred.
        //if (paymentRecord.ErrorOutput.Rows.Count > 0)
        //{
        //TODO: Find what needs to be done when error occurs.
        //}

        #endregion


      }
      catch (Exception excp)
      {
        mLogger.LogException("Error occurred while writing payment record using MetraFlow Script...", excp);
        //Caller should log this exception with enough details and do NOT bubble up the error....
        //DO NOT BUBBLE UP ERROR..
        //throw new MASBasicException("Error occurred while writing payment record");


      }
      finally
      {
        ReleaseGetPaymentRecord(paymentRecord);
      }
    }

    private MetraPaymentMethod GetPaymentMethodInstance(PaymentType paymentType)
    {
      MetraPaymentMethod method = null;

      switch (paymentType)
      {
        case PaymentType.Credit_Card:
          method = new CreditCardPaymentMethod();
          break;

        case PaymentType.ACH:
          method = new ACHPaymentMethod();
          break;
      }

      return method;
    }

    private MetraPayClient InitializeServiceCall(string serviceName)
    {
      MetraPayClient client = null;
      try
      {
        string serverName = m_EPSConfig.HostName;
        int serverPort = m_EPSConfig.Port;

        client = new MetraPayClient(serverName, serverPort, m_EPSConfig.ServerDNSIdentity, serviceName);

        // SECENG: Fixing problem with multiple active certificates with the same subject.
        //client.ClientCredentials.ClientCertificate.SetCertificate(m_EPSConfig.ServiceCertificate.StoreLocation,
        //  m_EPSConfig.ServiceCertificate.StoreName, m_EPSConfig.ServiceCertificate.X509FindType, m_EPSConfig.ServiceCertificate.FindValue);

        client.ClientCredentials.ClientCertificate.Certificate = FindClientCertificate();

        foreach (Type t in GetExtendedTypes())
        {
          foreach (OperationDescription od in client.Endpoint.Contract.Operations)
          {
            od.KnownTypes.Add(t);
          }
        }
      }
      catch (Exception e)
      {
        mLogger.LogException("Unable to read EPS configuration", e);
        throw new MASBasicException("Unable to read server configuration");
      }

      return client;
    }

    private MetraPayTProcessorClient InitializeTPServiceCall(string serviceName, double timeOut = 0)
    {
      MetraPayTProcessorClient tpClient = null;
      try
      {
        string serverName = m_EPSConfig.HostName;
        int serverPort = m_EPSConfig.Port;
        tpClient = new MetraPayTProcessorClient(serverName, serverPort, m_EPSConfig.ServerDNSIdentity, serviceName);

        // SECENG: Fixing problem with multiple active certificates with the same subject.		
        //tpClient.ClientCredentials.ClientCertificate.SetCertificate(m_EPSConfig.ServiceCertificate.StoreLocation,
        //  m_EPSConfig.ServiceCertificate.StoreName, m_EPSConfig.ServiceCertificate.X509FindType, m_EPSConfig.ServiceCertificate.FindValue);

        tpClient.ClientCredentials.ClientCertificate.Certificate = FindClientCertificate();

        if (timeOut > 0)
        {
          tpClient.InnerChannel.OperationTimeout = new TimeSpan(0, 0, 0, 0, (int)timeOut);
        }
        foreach (Type t in GetExtendedTypes())
        {
          foreach (OperationDescription od in tpClient.Endpoint.Contract.Operations)
          {
            od.KnownTypes.Add(t);
          }
        }
      }
      catch (Exception e)
      {
        mLogger.LogException("Unable to read EPS configuration", e);
        throw new MASBasicException("Unable to read server configuration");
      }

      return tpClient;
    }

    private MetraPayBatchUpdateClient InitializeBatchUpdateServiceCall(string serviceName)
    {
      MetraPayBatchUpdateClient client = null;
      try
      {
        string serverName = m_EPSConfig.HostName;
        int serverPort = m_EPSConfig.Port;

        BatchUpdaterServiceCallback callbackInstance = new BatchUpdaterServiceCallback();
        InstanceContext context = new InstanceContext(callbackInstance);

        client = new MetraPayBatchUpdateClient(context, serverName, serverPort, m_EPSConfig.ServerDNSIdentity, serviceName);

        callbackInstance.MetraPayClient = client;

        // SECENG: Fixing problem with multiple active certificates with the same subject.		
        //client.ClientCredentials.ClientCertificate.SetCertificate(m_EPSConfig.ServiceCertificate.StoreLocation,
        //  m_EPSConfig.ServiceCertificate.StoreName, m_EPSConfig.ServiceCertificate.X509FindType, m_EPSConfig.ServiceCertificate.FindValue);

        client.ClientCredentials.ClientCertificate.Certificate = FindClientCertificate();

        foreach (Type t in GetExtendedTypes())
        {
          foreach (OperationDescription od in client.Endpoint.Contract.Operations)
          {
            od.KnownTypes.Add(t);
          }
        }
      }
      catch (Exception e)
      {
        mLogger.LogException("Unable to read EPS configuration", e);
        throw new MASBasicException("Unable to read server configuration");
      }

      return client;
    }

    private static X509Certificate2 FindClientCertificate()
    {
      return CertificateHelper.FindCertificate(
              m_EPSConfig.ServiceCertificate.StoreName,
              m_EPSConfig.ServiceCertificate.StoreLocation,
              m_EPSConfig.ServiceCertificate.X509FindType,
              m_EPSConfig.ServiceCertificate.FindValue);
    }

    private string CalculateServiceName(MetraPaymentMethod paymentMethod, MetraPaymentInfo paymentInfo, int id_acc)
    {
      string serviceName = "";

      try
      {
        Dictionary<string, object> outValues = null;
        Dictionary<string, object> parameters = new Dictionary<string, object>();
        parameters.Add("PaymentMethod", paymentMethod);
        parameters.Add("PaymentInfo", paymentInfo);
        parameters.Add("AccountID", id_acc);
        WorkflowExecutor wfExecutor = null;

        MemoryStream xomlStream = new MemoryStream(), rulesStream = new MemoryStream();

        lock (m_RouterXoml)
        {
          m_RouterXoml.Seek(0, SeekOrigin.Begin);
          m_RouterRules.Seek(0, SeekOrigin.Begin);

          m_RouterXoml.WriteTo(xomlStream);
          m_RouterRules.WriteTo(rulesStream);
        }

        xomlStream.Seek(0, SeekOrigin.Begin);
        rulesStream.Seek(0, SeekOrigin.Begin);

        wfExecutor = new WorkflowExecutor(xomlStream, rulesStream, parameters);
        wfExecutor.ExecuteWorkflow(out outValues);

        if (outValues != null && outValues.ContainsKey("ServiceName"))
        {
          serviceName = (string)outValues["ServiceName"];
        }
      }
      catch (Exception e)
      {
        mLogger.LogException("Exception executing MetraPay Routing Workflow", e);
        throw new MASBasicException("Error executing MetraPay Routing Workflow");
      }

      if (serviceName == "")
      {
        throw new MASBasicException("Unable to determine MetraPay service name");
      }

      return serviceName;
    }

    private bool DoesTransactionExist(ref MetraPaymentInfo paymentInfo)
    {
      if (paymentInfo.TransactionSessionId.ToString() == "00000000-0000-0000-0000-000000000000")
      {
        paymentInfo.TransactionSessionId = Guid.NewGuid();
        return false;
      }

      var resourceManager = new ResourcesManager();
      string alreadySubmittedMessage = resourceManager.GetLocalizedResource("TX_ALREADY_SUBMITTED");

      IMTQueryAdapter qa = new MTQueryAdapter();
      qa.Init("Queries\\ElectronicPaymentService");
      qa.SetQueryTag("__DOES_TRANSACTION_EXIST__");
      string numTx = qa.GetQuery();
      using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Suppress,
                                      new TransactionOptions(),
                                      EnterpriseServicesInteropOption.Full))
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(numTx))
          {
            stmt.AddParam("id_payment_transaction", MTParameterType.String,
                          paymentInfo.TransactionSessionId.ToString());



            using (IMTDataReader dataReader = stmt.ExecuteReader())
            {
              //if there are records, then we do have this credit card on file.  If not, we move on.
              if (dataReader.Read())
              {
                TransactionState state =
                  (TransactionState)
              Enum.Parse(typeof(TransactionState), dataReader.GetString("n_state"));
                if (state == TransactionState.SUCCESS)
                {
                  return true;
                }
                else if (state == TransactionState.REJECTED)
                {
                  throw new MASBasicException(
                    String.Format(alreadySubmittedMessage, paymentInfo.TransactionSessionId),
                    ErrorCodes.TRANSACTION_ALREADY_REJECTED);
                }
                else
                {
                  throw new MASBasicException(
                    String.Format(alreadySubmittedMessage, paymentInfo.TransactionSessionId),
                    ErrorCodes.TRANSACTION_ALREADY_FAILED);
                }
              }
            }
          }
        }
      }

      return false;
    }


    /// <summary>
    /// Returns the account ID if it can be resolved, or 0 otherwise
    /// </summary>
    /// <param name="acct"></param>
    /// <returns></returns>
    private int ResolveAccount(AccountIdentifier acct)
    {
      int accountID = 0;
      if (acct.AccountID.HasValue)
      {
        if (acct.AccountID.Value != 0)
        {
          accountID = acct.AccountID.Value;
        }
        else
        {
          mLogger.LogError("Zero is not a valid account identifier");
          throw new MASBasicException("Zero is not a valid account identifier");
        }
      }
      else if ((acct.Namespace != null) && (acct.Username != null))
      {
        accountID = AccountIdentifierResolver.ResolveAccountIdentifier(acct);
        string isMTRequired = m_EPSConfig.MetraNetAccount.Required;
        if ((accountID == -1) && (isMTRequired.ToUpper().Equals("TRUE")))
        {
          mLogger.LogError("EPS is configured to only add a payment method to a valid MetraNet Account.");
          throw new MASBasicException("EPS is configured to only add a payment method to a valid MetraNet Acount.");
        }

        if (accountID == -1)
        {
          int tmpAccId = CheckPaymentXrefTable(acct);
          if (tmpAccId == -1)
          {
            IIdGenerator2 accIDGenerator = new IdGenerator("temp_acc_id", 1);
            accountID = accIDGenerator.NextId;
            using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\ElectronicPaymentService"))
            {
              using (IMTAdapterStatement stmtHistory = conn.CreateAdapterStatement("Queries\\ElectronicPaymentService", "__INSERT_TMP_ACCID__"))
              {

                stmtHistory.AddParam("%%TEMP_ACCT_ID%%", accountID);
                stmtHistory.AddParam("%%NM_LOGIN%%", acct.Username);
                stmtHistory.AddParam("%%NM_SPACE%%", acct.Namespace);
                stmtHistory.AddParam("%%DT_CREATED%%", MetraTime.Now);

                stmtHistory.ExecuteNonQuery();
                stmtHistory.ClearQuery();
              }
            }
          }
          else
          {
            accountID = tmpAccId;
          }
        }
      }
      else
      {
        try
        {
          accountID = AccountIdentifierResolver.ResolveAccountIdentifier(acct);
        }
        catch (Exception e)
        {
          mLogger.LogException("Unable to retrieve account information", e);
        }

        mLogger.LogDebug(String.Format("Account id is {0}", accountID));
      }
      return accountID;
    }

    private int CheckPaymentXrefTable(AccountIdentifier act)
    {
      int tmpAccountId = -1;
      using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\ElectronicPaymentService"))
      {
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\ElectronicPaymentService",
          "__DOES_TEMP_ACCOUNT_EXIST__"))
        {
          stmt.AddParam("%%NM_LOGIN%%", act.Username);
          stmt.AddParam("%%NM_SPACE%%", act.Namespace);

          using (IMTDataReader dataReader = stmt.ExecuteReader())
          {
            if (dataReader.Read())
            {
              tmpAccountId = dataReader.GetInt32("temp_acc_id");
            }
          }
        }
      }

      return tmpAccountId;

    }

    private void AddPaymentMethodInternal(int accountID, MetraPaymentMethod paymentMethod, Guid token)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\ElectronicPaymentService"))
      {
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\ElectronicPaymentService",
            "__ADD_PAYMENT_INSTRUMENT__"))
        {

          stmt.AddParam("%%PAYMENT_INSTRUMENT_ID%%", token.ToString());
          stmt.AddParam("%%ACCOUNT_ID%%", (accountID == 0) ? (object)DBNull.Value : (object)accountID);
          stmt.AddParam("%%PAYMENT_METHOD_TYPE%%", EnumHelper.GetDbValueByEnum(paymentMethod.PaymentMethodType));
          stmt.AddParam("%%ACCOUNT_NUMBER%%", paymentMethod.AccountNumber);
          stmt.AddParam("%%HASH%%", HashAccountNumber(paymentMethod.UniqueAccountNumber));

          if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
            paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
          {
            CreditCardPaymentMethod cc = (CreditCardPaymentMethod)paymentMethod;
            stmt.AddParam("%%CREDITCARD_TYPE%%", EnumHelper.GetDbValueByEnum(cc.CreditCardType));
            stmt.AddParam("%%EXP_DATE%%", (cc.ExpirationDate));
            stmt.AddParam("%%EXP_DATE_FORMAT%%", ((int)cc.ExpirationDateFormat));
            stmt.AddParam("%%ACCOUNT_TYPE%%", null);
          }
          else
          {
            ACHPaymentMethod ach = (ACHPaymentMethod)paymentMethod;
            stmt.AddParam("%%CREDITCARD_TYPE%%", null);
            stmt.AddParam("%%EXP_DATE%%", null);
            stmt.AddParam("%%EXP_DATE_FORMAT%%", null);
            stmt.AddParam("%%ACCOUNT_TYPE%%", EnumHelper.GetDbValueByEnum(ach.AccountType));
          }
          stmt.AddParam("%%FIRST_NAME%%", paymentMethod.FirstName);
          stmt.AddParam("%%MIDDLE_NAME%%", paymentMethod.MiddleName);
          stmt.AddParam("%%LAST_NAME%%", paymentMethod.LastName);
          stmt.AddParam("%%ADDRESS1%%", BlankIfNull(paymentMethod.Street));
          stmt.AddParam("%%ADDRESS2%%", BlankIfNull(paymentMethod.Street2));
          stmt.AddParam("%%CITY%%", BlankIfNull(paymentMethod.City));
          stmt.AddParam("%%STATE%%", BlankIfNull(paymentMethod.State));
          stmt.AddParam("%%ZIP%%", BlankIfNull(paymentMethod.ZipCode));
          stmt.AddParam("%%COUNTRY%%", EnumHelper.GetDbValueByEnum(paymentMethod.Country));
          stmt.AddParam("%%PRIORITY_ID%%", (paymentMethod.Priority.HasValue ? paymentMethod.Priority.Value : 1));
          if (paymentMethod.MaxChargePerCycle.HasValue)
          {
            stmt.AddParam("%%MAX_CHARGE_PER_CYCLE%%", paymentMethod.MaxChargePerCycle.Value);
          }
          else
          {
            stmt.AddParam("%%MAX_CHARGE_PER_CYCLE%%", DBNull.Value);
          }

          stmt.AddParam("%%TIMESTAMP%%", MetraTime.Now);

          stmt.ExecuteNonQuery();
          stmt.ClearQuery();
        }
      }
    }

    private void HandleTimeoutException(MetraPaymentInfo paymentInfo, MetraPaymentMethod paymentMethod, int acctId, DateTime endTime, Exception e, TransactionScope scope)
    {
      //If we haven't reached the timeout for the method, just sleep for a bit, then try again
      if (endTime >= DateTime.Now)
      {
        Thread.Sleep(1000);
      }
      else
      {
        if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
            paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
        {
          auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_CREDIT_CREDITCARD_FAILED,
                                   this.GetSessionContext().AccountID,
                                   (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                   String.Format(
                                     "TimeoutException: Failed to process credit card transaction for invoice: {0}",
                                     GetInvoiceNumbers(paymentInfo)));
        }

        else
        {
          auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_CREDIT_ACH_FAILED,
                                   this.GetSessionContext().AccountID,
                                   (int)MTAuditEntityType.AUDITENTITY_TYPE_PAYMENT, acctId,
                                   String.Format(
                                     "TimeoutException: Failed to process ach transaction for invoice: {0}",
                                     GetInvoiceNumbers(paymentInfo)));
        }
        FailTransaction(paymentInfo.TransactionSessionId);
        mLogger.LogException(
          String.Format("Timeout exception while processing payment for  Invoice {0}.",
                        GetInvoiceNumbers(paymentInfo)), e);
        throw new MASBasicException(String.Format("Timeout exception while processing payment for  Invoice {0}.",
                    GetInvoiceNumbers(paymentInfo)), ErrorCodes.TRANSACTION_TIMED_OUT);
      }
    }


    private bool IsInstrumentOnFile(MetraPaymentMethod paymentInstrument, int idAcc)
    {
      Guid dummy = new Guid();
      return IsInstrumentOnFile(paymentInstrument, idAcc, out dummy);
    }
    /// <summary>
    /// Check if payment instrument is already on file for a given user
    /// </summary>
    /// <param name="paymentInstrument">PaymentInstrument information to check</param>
    /// <param name="instrumentId">Instrument Id if it does exist</param>
    /// <returns>True if card is on file, False if it is not</returns>
    private bool IsInstrumentOnFile(MetraPaymentMethod paymentInstrument, int idAcc, out Guid instrumentId)
    {
      bool bResult = false;
      instrumentId = new Guid();

      if (paymentInstrument == null)
        return false;

      string accountNumber = paymentInstrument.PaymentInstrumentID.ToString();

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\ElectronicPaymentService",
          "__DOES_PAYMENT_INSTRUMENT_EXIST__"))
        {
          stmt.AddParam("%%HASH%%", HashAccountNumber(paymentInstrument.UniqueAccountNumber));

          stmt.AddParamIfFound("%%ID_ACCT%%", idAcc);

          using (IMTDataReader dataReader = stmt.ExecuteReader())
          {
            //if there are records, then we do have this credit card on file
            if (dataReader.Read())
            {
              instrumentId = Guid.Parse(dataReader.GetString("id_payment_instrument"));
              bResult = true;
            }
          }
        }
      }

      return bResult;
    }
    private void UpdatePaymentMethodInternal(Guid token, MetraPaymentMethod paymentMethod, int accountID)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\ElectronicPaymentService"))
      {
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\ElectronicPaymentService",
            "__UPDATE_PAYMENT_INSTRUMENT__"))
        {

          if (paymentMethod.GetType() == typeof(CreditCardPaymentMethod) ||
            paymentMethod.GetType().IsSubclassOf(typeof(CreditCardPaymentMethod)))
            stmt.AddParam("%%EXP_DATE%%", ((CreditCardPaymentMethod)paymentMethod).ExpirationDate);
          else
            stmt.AddParam("%%EXP_DATE%%", null);
          stmt.AddParam("%%FIRST_NAME%%", paymentMethod.FirstName);
          stmt.AddParam("%%MIDDLE_NAME%%", paymentMethod.MiddleName);
          stmt.AddParam("%%LAST_NAME%%", paymentMethod.LastName);
          stmt.AddParam("%%ADDRESS1%%", BlankIfNull(paymentMethod.Street));
          stmt.AddParam("%%ADDRESS2%%", BlankIfNull(paymentMethod.Street2));
          stmt.AddParam("%%CITY%%", BlankIfNull(paymentMethod.City));
          stmt.AddParam("%%STATE%%", BlankIfNull(paymentMethod.State));
          stmt.AddParam("%%ZIP%%", BlankIfNull(paymentMethod.ZipCode));
          stmt.AddParam("%%COUNTRY%%", EnumHelper.GetDbValueByEnum(paymentMethod.Country));
          stmt.AddParam("%%MAX_CHARGE_PER_CYCLE%%", paymentMethod.MaxChargePerCycle);
          stmt.AddParam("%%PAYMENT_INSTRUMENT_ID%%", token.ToString());

          stmt.ExecuteNonQuery();
          stmt.ClearQuery();
        }
      }
    }

    private void AssignPaymentMethodToAccountInternal(Guid token, int accountID)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\ElectronicPaymentService"))
      {
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\ElectronicPaymentService",
            "__ASSIGN_PAYMENT_INSTRUMENT_TO_ACCOUNT_ID__"))
        {

          stmt.AddParam("%%ACCOUNT_ID%%", accountID);
          stmt.AddParam("%%PAYMENT_INSTRUMENT_ID%%", token.ToString());

          stmt.ExecuteNonQuery();
          stmt.ClearQuery();
        }
      }
    }

    private bool VerifyPaymentOwner(AccountIdentifier accIdentifier, Guid token)
    {

      MTList<MetraPaymentMethod> paymentMethods = new MTList<MetraPaymentMethod>();

      //filter results by payment instrument id guid that was received on query string
      MTFilterElement fe = new MTFilterElement
        ("PaymentInstrumentID", MTFilterElement.OperationType.Equal, token.ToString());
      paymentMethods.Filters.Add(fe);
      try
      {
        GetPaymentMethodSummaries(accIdentifier, ref paymentMethods);
      }
      catch (Exception e)
      {
        mLogger.LogException("Unable to get payment method summaries for account", e);
        return false;
      }

      if (paymentMethods.TotalRows != 1)
      {
        return false;
      }
      return true;
    }

    private void DeletePaymentMethodInternal(int accountID, Guid token)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\ElectronicPaymentService"))
      {
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\ElectronicPaymentService",
            "__DELETE_PAYMENT_INSTRUMENT__"))
        {

          stmt.AddParam("%%PAYMENT_INSTRUMENT_ID%%", token.ToString());
          stmt.AddParam("%%ACCOUNT_ID%%", accountID);

          stmt.ExecuteNonQuery();
          stmt.ClearQuery();
        }
      }
    }

    // out id acc could be security risk . . . internal should cover this?
    internal void GetPaymentMethodDetailInternal(Guid token, out MetraPaymentMethod paymentMethod, out int idAcc)
    {
      mLogger.LogDebug("In GetPaymentMethodDetailInternal");
      idAcc = 0;
      paymentMethod = null;

      try
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\ElectronicPaymentService"))
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\ElectronicPaymentService",
            "__GET_PAYMENT_INSTRUMENT__"))
          {

            stmt.AddParam("%%PAYMENT_INSTRUMENT_ID%%", token.ToString());

            using (IMTDataReader dataReader = stmt.ExecuteReader())
            {

              //if there are records, then we do have this credit card on file
              if (dataReader.Read())
              {
                paymentMethod = CreatePaymentMethodFromReader(dataReader, out idAcc);
              }
            }
          }
        }
      }
      catch (Exception e)
      {
        mLogger.LogException("Error loading payment instrument details", e);
        throw new MASBasicException("Error load payment instrument details");
      }
    }

    private MetraPaymentMethod CreatePaymentMethodFromReader(IMTDataReader dataReader, out int idAcc)
    {
      PaymentType paymentType = (PaymentType)EnumHelper.GetCSharpEnum(dataReader.GetInt32("PaymentMethodType"));

      MetraPaymentMethod paymentMethod = GetPaymentMethodInstance(paymentType);

      paymentMethod.PaymentInstrumentID = new Guid(dataReader.GetString("PaymentInstrumentID"));

      idAcc = dataReader.GetInt32("AccountID");
      paymentMethod.AccountNumber = dataReader.GetString("AccountNumber");

      paymentMethod.FirstName = dataReader.GetString("FirstName");
      paymentMethod.MiddleName = dataReader.GetString("MiddleName");
      paymentMethod.LastName = dataReader.GetString("LastName");
      paymentMethod.Street = dataReader.GetString("Street");
      paymentMethod.Street2 = dataReader.GetString("Street2");
      paymentMethod.City = dataReader.GetString("City");
      paymentMethod.State = dataReader.GetString("State");
      paymentMethod.ZipCode = dataReader.GetString("ZipCode");
      paymentMethod.Country = (PaymentMethodCountry)EnumHelper.GetCSharpEnum(dataReader.GetInt32("Country"));

      paymentMethod.Priority = dataReader.GetInt32("Priority");

      if (!dataReader.IsDBNull("MaxChargePerCycle"))
      {
        paymentMethod.MaxChargePerCycle = dataReader.GetDecimal("MaxChargePerCycle");
      }

      switch (paymentType)
      {
        case PaymentType.Credit_Card:
          ((CreditCardPaymentMethod)paymentMethod).CreditCardType = (MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType)EnumHelper.GetCSharpEnum(dataReader.GetInt32("CreditCardType"));
          ((CreditCardPaymentMethod)paymentMethod).ExpirationDate = dataReader.GetString("ExpirationDate");
          ((CreditCardPaymentMethod)paymentMethod).ExpirationDateFormat = (MTExpDateFormat)dataReader.GetInt32("ExpirationDateFormat");
          break;

        case PaymentType.ACH:
          break;
      }

      return paymentMethod;
    }

    private void AddLinkedTransaction(Guid txId, Guid linkedTx)
    {
      IMTQueryAdapter qa = new MTQueryAdapter();
      qa.Init("Queries\\ElectronicPaymentService");
      qa.SetQueryTag("__ADD_LINKED_TRANSACTION__");
      string updateTx = qa.GetQuery();
      //Transaction state updates shouldn't be rolled back in case of failure.
      using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Suppress,
                                                new TransactionOptions(),
                                                EnterpriseServicesInteropOption.Full))
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\ElectronicPaymentService"))
        {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(updateTx))
          {

            stmt.AddParam("id_payment_transaction", MTParameterType.Guid, txId);
            stmt.AddParam("linked_transaction", MTParameterType.Guid, linkedTx);

            stmt.ExecuteNonQuery();
            stmt.ClearParams();
          }
        }
      }
    }

    private void FailTransaction(Guid txId)
    {
      UpdateTransactionState(txId, TransactionState.FAILURE);
      VoidTransaction(txId);
    }

    private void UpdateTransactionState(Guid txId, TransactionState state, string notes = "")
    {
      if (state == TransactionState.FAILURE)
      {
        IncOpenTransactions();
      }
      IMTQueryAdapter qa = new MTQueryAdapter();

      //Some statuses can only be moved to from particular states.
      //  For those cases, get the current state, and then check it
      if ((state == TransactionState.MANUALLY_REVERSED) || (state == TransactionState.MANUAL_PENDING))
      {
        if (state == TransactionState.MANUALLY_REVERSED)
        {
          //Need particular capability for Manually_reversed
          IMTSecurity security = new MTSecurityClass();
          MetraTech.Interop.MTAuth.IMTCompositeCapability capability =
              security.GetCapabilityTypeByName("Manual Override").CreateInstance();
          if (!GetSessionContext().SecurityContext.CoarseHasAccess(capability))
          {
            throw new MASBasicException(ErrorCodes.NO_OVERRIDE_CAPABILITY);
          }
        }
        qa.Init("Queries\\ElectronicPaymentService");
        qa.SetQueryTag("__GET_TRANSACTION_INFO__");
        string txInfo = qa.GetQuery();
        TransactionState oldState = TransactionState.SUCCESS;

        using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Suppress,
                                                             new TransactionOptions(),
                                                             EnterpriseServicesInteropOption.Full))
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(txInfo))
            {
              stmt.AddParam("id_payment_transaction", MTParameterType.String,
                            txId.ToString());
              using (IMTDataReader dataReader = stmt.ExecuteReader())
              {
                //if there are records, then we do have this credit card on file.  If not, we move on.
                if (dataReader.Read())
                {
                  oldState = (TransactionState)
                             Enum.Parse(typeof(TransactionState), dataReader.GetString("n_state"));
                }
              }
            }
          }
        }

        if (state == TransactionState.MANUALLY_REVERSED)
        {
          if (oldState != TransactionState.MANUAL_PENDING)
            throw new MASBasicException(ErrorCodes.BAD_TRANSACTION_STATE);
        }

        if (state == TransactionState.MANUAL_PENDING)
        {
          if (oldState != TransactionState.FAILURE)
            throw new MASBasicException(ErrorCodes.BAD_TRANSACTION_STATE);
        }
      }
      qa.Init("Queries\\ElectronicPaymentService");
      qa.SetQueryTag("__UPDATE_TRANSACTION_STATE__");
      string updateTx = qa.GetQuery();
      //Transaction state updates shouldn't be rolled back in case of failure.
      using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Suppress,
                                                           new TransactionOptions(),
                                                           EnterpriseServicesInteropOption.Full))
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\ElectronicPaymentService"))
        {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(updateTx))
          {

            stmt.AddParam("id_payment_transaction", MTParameterType.String, txId.ToString());
            stmt.AddParam("n_state", MTParameterType.String, state.ToString());
            stmt.AddParam("notes", MTParameterType.String, notes);
            stmt.ExecuteNonQuery();
            stmt.ClearParams();
          }
        }
      }
    }

    private void CloseTransaction(Guid txId, TransactionState state, string gatewayResponse = "")
    {
      IMTQueryAdapter qa = new MTQueryAdapter();
      qa.Init("Queries\\ElectronicPaymentService");
      qa.SetQueryTag("__CLOSE_TRANSACTION__");
      string updateTx = qa.GetQuery();
      //Transaction state updates shouldn't be rolled back in case of failure.
      using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Suppress,
                                                new TransactionOptions(),
                                                EnterpriseServicesInteropOption.Full))
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\ElectronicPaymentService"))
        {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(updateTx))
          {

            stmt.AddParam("id_payment_transaction", MTParameterType.String, txId.ToString());
            stmt.AddParam("n_state", MTParameterType.String, state.ToString());
            stmt.AddParam("n_gateway_response", MTParameterType.String, gatewayResponse);
            stmt.ExecuteNonQuery();
            stmt.ClearParams();
          }
        }
      }
    }

    private void LogPaymentHistory(int idAcc, Guid token, MetraPaymentMethod pm, MetraPaymentInfo paymentInfo, TransactionType txType)
    {
      int accountId = 0;

      // poor man's way of checking if it is not one-time
      if (idAcc == -1)
      {
        pm = null;
        GetPaymentMethodDetailInternal(token, out pm, out accountId);
        idAcc = accountId;
      }

      // set it to cc, for one-time, we will query the table anyways and get the appropriate paymentmethod
      string nextTxnID = paymentInfo.TransactionSessionId.ToString();

      //Don't roll back inserts in case of failure, so that we can clean them up later.
      using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Suppress,
                                                           new TransactionOptions(),
                                                           EnterpriseServicesInteropOption.Full))
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\ElectronicPaymentService"))
        {
          IMTQueryAdapter qa = new MTQueryAdapter();
          qa.Init("Queries\\ElectronicPaymentService");
          qa.SetQueryTag("__INSERT_PAYMENT_HISTORY__");
          string payHistStmt = qa.GetQuery();
          try
          {
            using (IMTPreparedStatement stmtHistory = conn.CreatePreparedStatement(payHistStmt))
            {
              //Serialize PaymentInfo to a byte[]
              System.IO.MemoryStream piStream = new System.IO.MemoryStream();
              var _BinaryFormatter = new System.Runtime.Serialization.Formatters.Binary.BinaryFormatter();
              _BinaryFormatter.Serialize(piStream, paymentInfo);


              stmtHistory.AddParam("id_payment_transaction", MTParameterType.String, nextTxnID);
              stmtHistory.AddParam("id_acct", MTParameterType.Integer, idAcc);
              stmtHistory.AddParam("dt_transaction", MTParameterType.DateTime, MetraTime.Now);
              // should this be consistent on both sides?
              stmtHistory.AddParam("n_payment_method_type", MTParameterType.Integer,
                                   EnumHelper.GetDbValueByEnum(pm.PaymentMethodType));
              stmtHistory.AddParam("nm_truncd_acct_num", MTParameterType.String, pm.AccountNumber);
              if (pm.PaymentMethodType == PaymentType.Credit_Card)
              {
                stmtHistory.AddParam("id_creditcard_type", MTParameterType.Integer,
                                     EnumHelper.GetDbValueByEnum(
                                         ((CreditCardPaymentMethod)pm).CreditCardType));
              }
              else
              {
                stmtHistory.AddParam("id_creditcard_type", MTParameterType.Integer, null);
              }

              if (pm.PaymentMethodType == PaymentType.ACH)
              {
                stmtHistory.AddParam("n_account_type", MTParameterType.Integer,
                                    EnumHelper.GetDbValueByEnum(((ACHPaymentMethod)pm).AccountType));
                // for ach
              }
              else
              {
                stmtHistory.AddParam("n_account_type", MTParameterType.Integer, null); // for ach
              }

              stmtHistory.AddParam("nm_description", MTParameterType.String, BlankIfNull(paymentInfo.Description));
              stmtHistory.AddParam("n_currency", MTParameterType.String, BlankIfNull(paymentInfo.Currency));
              stmtHistory.AddParam("n_amount", MTParameterType.Decimal, BlankIfNull(paymentInfo.Amount));
              stmtHistory.AddParam("n_transaction_type", MTParameterType.String, txType.ToString());
              stmtHistory.AddParam("n_state", MTParameterType.String, TransactionState.RECEIVED_REQUEST.ToString());
              stmtHistory.AddParam("id_payment_instrument", MTParameterType.String, pm.PaymentInstrumentIDString);
              stmtHistory.AddParam("payment_info", MTParameterType.Blob, piStream.ToArray());
              //stmtHistory.
              stmtHistory.ExecuteNonQuery();
              stmtHistory.ClearParams();

            }

            using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
            {
              queryAdapter.Item = new MTQueryAdapter();
              queryAdapter.Item.Init("Queries\\ElectronicPaymentService");
              queryAdapter.Item.SetQueryTag("__INSERT_PAYMENT_HISTORY_DETAILS__");

              using (
                  IMTPreparedStatement stmtHistory =
                      conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
              {
                if (paymentInfo.MetraPaymentInvoices == null ||
                    paymentInfo.MetraPaymentInvoices.Count == 0)
                {
                  stmtHistory.AddParam(MTParameterType.String, nextTxnID);
                  stmtHistory.AddParam(MTParameterType.Integer, 1);
                  stmtHistory.AddParam(MTParameterType.String, paymentInfo.InvoiceNum);
                  stmtHistory.AddParam(MTParameterType.DateTime, paymentInfo.InvoiceDate);
                  stmtHistory.AddParam(MTParameterType.String, paymentInfo.PONum);
                  stmtHistory.AddParam(MTParameterType.Decimal, paymentInfo.Amount);

                  stmtHistory.ExecuteNonQuery();
                  stmtHistory.ClearParams();
                }
                else
                {
                  int idPmtTxnDtls = 1;

                  foreach (MetraPaymentInvoice invoice in paymentInfo.MetraPaymentInvoices)
                  {
                    stmtHistory.AddParam(MTParameterType.String, nextTxnID);
                    stmtHistory.AddParam(MTParameterType.Integer, idPmtTxnDtls);
                    stmtHistory.AddParam(MTParameterType.String, invoice.InvoiceNum);
                    stmtHistory.AddParam(MTParameterType.DateTime, invoice.InvoiceDate);
                    stmtHistory.AddParam(MTParameterType.String, invoice.PONum);
                    stmtHistory.AddParam(MTParameterType.Decimal, invoice.AmountToPay);

                    stmtHistory.ExecuteNonQuery();
                    stmtHistory.ClearParams();

                    idPmtTxnDtls++;
                  }
                }
              }
            }
          }
          catch (Exception e)
          {
            mLogger.LogException("Could not log transaction to database", e);
            throw new MASBasicException(e.Message, ErrorCodes.COULD_NOT_LOG_TRANSACTION);
          }
        }
      }
    }

    private void WritePendingACHTxDetails(MetraPaymentInfo pi, MetraPaymentMethod paymentMethod, int acctId, string arRequestId)
    {
      using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                           new TransactionOptions(),
                                                           EnterpriseServicesInteropOption.Full))
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\ElectronicPaymentService"))
        {
          using (IMTAdapterStatement stmtHistory = conn.CreateAdapterStatement("Queries\\ElectronicPaymentService",
              "__INSERT_PENDING_ACH_TX__"))
          {

            stmtHistory.AddParam("%%ID_PAYMENT_TRANSACTION%%", pi.TransactionID);
            stmtHistory.AddParam("%%N_DAYS%%", 1);
            stmtHistory.AddParam("%%ID_PAYMENT_INSTRUMENT%%", paymentMethod.PaymentInstrumentID.ToString());
            stmtHistory.AddParam("%%ID_ACC%%", acctId);
            stmtHistory.AddParam("%%N_AMOUNT%%", pi.Amount);
            stmtHistory.AddParam("%%NM_DESCRIPTION%%", pi.Description);
            stmtHistory.AddParam("%%DT_CREATE%%", MetraTime.Now);
            stmtHistory.AddParam("%%NM_AR_REQUEST_ID%%", arRequestId);

            stmtHistory.ExecuteNonQuery();
            stmtHistory.ClearQuery();
          }

          if (!string.IsNullOrEmpty(pi.InvoiceNum) || pi.IsInvoiceDateDirty || !string.IsNullOrEmpty(pi.PONum))
          {
            using (IMTAdapterStatement stmtHistory = conn.CreateAdapterStatement("Queries\\ElectronicPaymentService",
                         "__INSERT_PENDING_ACH_TX_DETAILS__"))
            {

              stmtHistory.AddParam("%%ID_PAYMENT_TRANSACTION%%", pi.TransactionID);
              stmtHistory.AddParam("%%NM_INVOICE_NUM%%", pi.InvoiceNum);
              stmtHistory.AddParam("%%AMOUNT%%", pi.Amount);
              stmtHistory.AddParam("%%DT_INVOICE%%", pi.InvoiceDate);
              stmtHistory.AddParam("%%NM_PO_NUMBER%%", pi.PONum);
              stmtHistory.ExecuteNonQuery();
              stmtHistory.ClearQuery();
            }
          }

          if (pi.MetraPaymentInvoices != null && pi.MetraPaymentInvoices.Count > 0)
          {
            foreach (MetraPaymentInvoice invoice in pi.MetraPaymentInvoices)
            {
              using (IMTAdapterStatement stmtHistory = conn.CreateAdapterStatement("Queries\\ElectronicPaymentService",
                          "__INSERT_PENDING_ACH_TX_DETAILS__"))
              {

                stmtHistory.AddParam("%%ID_PAYMENT_TRANSACTION%%", pi.TransactionID);
                stmtHistory.AddParam("%%NM_INVOICE_NUM%%", invoice.InvoiceNum);
                stmtHistory.AddParam("%%AMOUNT%%", invoice.AmountToPay);
                stmtHistory.AddParam("%%DT_INVOICE%%", invoice.InvoiceDate.Value);
                stmtHistory.AddParam("%%NM_PO_NUMBER%%", invoice.PONum);
                stmtHistory.ExecuteNonQuery();
                stmtHistory.ClearQuery();
              }
            }
          }


        }

        scope.Complete();
      }

    }

    //Isolating this in one place so we can change the way we handle locking if the current way is too expensive
    private void IncOpenTransactions()
    {
      Interlocked.Increment(ref m_OpenTransactions);
    }

    private void CheckExceededMaxOpenTransactions()
    {
      if (DateTime.Now >= m_NextTransactionCheck)
      {
        ResetNumOpenTransactions();
      }
      if (m_OpenTransactions >= m_EPSConfig.MaxOpenTransactions)
      {
        throw new MASBasicException("More than " + m_EPSConfig.MaxOpenTransactions + " failed transactions.",
                                    ErrorCodes.EXCEEDED_MAX_TRANSACTIONS);
      }
    }

    public void ResetNumOpenTransactions()
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("ResetNumOpenTransactions"))
      {
        IMTQueryAdapter qa = new MTQueryAdapter();
        qa.Init("Queries\\ElectronicPaymentService");
        qa.SetQueryTag("__GET_NUMBER_OF_FAILED_TRANSACTIONS__");
        string failedTxStmt = qa.GetQuery();
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(failedTxStmt))
          {
            using (IMTDataReader reader = stmt.ExecuteReader())
            {
              reader.Read();
              int temp = reader.GetInt32(0);
              Interlocked.Exchange(ref m_OpenTransactions, temp);
            }
          }
        }
      }
    }

    private bool LookUpInstrument(Guid token)
    {
      bool found = false;

      using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\ElectronicPaymentService"))
      {
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\ElectronicPaymentService",
          "__GET_PAYMENT_INSTRUMENT__"))
        {


          stmt.AddParam("%%PAYMENT_INSTRUMENT_ID%%", token.ToString());

          using (IMTDataReader dataReader = stmt.ExecuteReader())
          {

            //if there are records, then we do have this credit card on file
            if (dataReader.Read())
            {
              found = true;
            }
          }
        }
      }

      return found;
    }

    private object BlankIfNull(object input)
    {
      if ((input == null) || (input == DBNull.Value))
      {
        return string.Empty;
      }
      return input;
    }

    private string GetMD5(string plainText)
    {
      MD5 md5Hasher = MD5.Create();
      // Convert the input string to a byte array and compute the hash.
      byte[] data = md5Hasher.ComputeHash(Encoding.Default.GetBytes(plainText));

      // Create a new Stringbuilder to collect the bytes and create a string.
      StringBuilder builder = new StringBuilder();

      // Loop through each byte of the hashed data 
      // and format each one as a hexadecimal string.
      for (int i = 0; i < data.Length; i++)
      {
        builder.Append(data[i].ToString("x2"));
      }

      // Return the hexadecimal string.
      return builder.ToString();
    }

    private string HashAccountNumber(string acctNum)
    {
      string md5Hash = GetMD5(acctNum);
      string saltedAcctNum = md5Hash + acctNum;

      CryptoManager crypto = new CryptoManager();
      string hashedAcctNum = crypto.Hash(HashKeyClass.PaymentMethodHash, saltedAcctNum);

      return hashedAcctNum;
    }

    //        private bool ExceededMaxOpenConnections(){
    //            if (DateTime.Now >= m_NextTransactionCheck) 
    //            {
    //                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\ElectronicPaymentService", "__GET_NUMBER_OF_FAILED_TRANSACTIONS__"))
    //                {


    private static List<Type> GetExtendedTypes()
    {
      List<Type> knownTypes = new List<Type>();

      TypeExtensionsConfig typeExtensions = CMASHost.TypeExtensions;

      List<string> customizedTypes = new List<string>();
      customizedTypes.AddRange(typeExtensions.GetCustomizedTypes(typeof(MetraPaymentMethod)));
      customizedTypes.AddRange(typeExtensions.GetCustomizedTypes(typeof(MetraPaymentInfo)));

      if (customizedTypes != null)
      {
        foreach (string customizedType in customizedTypes)
        {
          try
          {
            knownTypes.Add(Type.GetType(customizedType, true, true));
          }
          catch (Exception e)
          {
            mLogger.LogException(string.Format("Error loading customized type {0}", customizedTypes), e);
          }
        }
      }

      return knownTypes;
    }

    private static void InitializeRouterWorkflow()
    {
      IMTRcd rcd = new MTRcdClass();

      string xomlFile = Path.Combine(rcd.ExtensionDir, @"paymentsvrclient\config\MetraPay\MetraPayRouter.xoml");

      if (File.Exists(xomlFile))
      {
        StreamReader rdr = new StreamReader(xomlFile);
        byte[] bytes = new byte[rdr.BaseStream.Length + 1];
        rdr.BaseStream.Read(bytes, 0, bytes.Length);

        m_RouterXoml = new MemoryStream(bytes);

        rdr.Close();
        rdr.Dispose();
      }
      string rulesFilename = Path.Combine(rcd.ExtensionDir, @"paymentsvrclient\config\MetraPay\MetraPayRouter.rules");

      if (File.Exists(rulesFilename))
      {
        StreamReader rdr = new StreamReader(rulesFilename);
        byte[] bytes = new byte[rdr.BaseStream.Length + 1];
        rdr.BaseStream.Read(bytes, 0, bytes.Length);

        m_RouterRules = new MemoryStream(bytes);

        rdr.Close();
        rdr.Dispose();
      }
    }

    #endregion

    #region IBatchUpdaterService Members

    public void UpdateCreditCards(string transactionId, BatchUpdaterParameters parameters)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("UpdateCreditCards"))
      {
        mLogger.LogInfo("Initiating batch update of credit cards with transaction id: {0}", transactionId);

        Dictionary<string, List<Guid>> cardsToUpdate = new Dictionary<string, List<Guid>>();

        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\ElectronicPaymentService", "__BATCH_CC_UPDATE_LOOKUP__"))
          {

            List<PropertyInfo> props = parameters.GetMTProperties();

            foreach (PropertyInfo prop in props)
            {
              object[] customAttribs = prop.GetCustomAttributes(typeof(BatchUpdaterParameterAttribute), false);

              if (customAttribs != null && customAttribs.Length == 1)
              {
                BatchUpdaterParameterAttribute attrib = customAttribs[0] as BatchUpdaterParameterAttribute;

                string tag = attrib.QueryTag;
                object value = prop.GetValue(parameters, null);

                stmt.AddParamIfFound(tag, DatabaseUtils.FormatValueForDB(value));
              }
            }

            using (IMTDataReader rdr = stmt.ExecuteReader())
            {
              while (rdr.Read())
              {
                try
                {
                  int acctId;

                  MetraPaymentMethod method = CreatePaymentMethodFromReader(rdr, out acctId);

                  string serviceName = CalculateServiceName(method, null, acctId);

                  if (cardsToUpdate.ContainsKey(serviceName))
                  {
                    cardsToUpdate[serviceName].Add(method.PaymentInstrumentID);
                  }
                  else
                  {
                    cardsToUpdate[serviceName] = new List<Guid>();
                    cardsToUpdate[serviceName].Add(method.PaymentInstrumentID);
                  }
                }
                catch (Exception e)
                {
                  mLogger.LogException("Exception loading payment instrument for batch update...skipping", e);
                }
              }
            }
          }
        }

        if (cardsToUpdate.Count > 0)
        {
          foreach (KeyValuePair<string, List<Guid>> kvp in cardsToUpdate)
          {
            try
            {
              mLogger.LogInfo("Submitting credit cards updates to service {0} for transaction {1}", kvp.Key, transactionId);
              MetraPayBatchUpdateClient client = InitializeBatchUpdateServiceCall(kvp.Key);

              client.UpdateCreditCards(transactionId, kvp.Value);

              // Note: Do not close client proxy here as it will be closed in the 
              // callback handler object.  Closing it here will cause the callback to fail
            }
            catch (Exception e)
            {
              mLogger.LogException(string.Format("Error sending batch update to service {0}", kvp.Key), e);
            }
          }
        }
      }
    }

    #endregion

    public class BatchUpdaterServiceCallback : IBatchUpdateServiceCallback
    {
      public MetraPayBatchUpdateClient MetraPayClient { get; set; }

      #region IBatchUpdateServiceCallback Members

      public void CreditCardsUpdated(string transactionId, List<CreditCardPaymentMethod> updatedCards)
      {
        using (HighResolutionTimer timer = new HighResolutionTimer("CreditCardsUpdated"))
        {
          ElectronicPaymentServices.mLogger.LogInfo("Received callback for updating credit cards for transaction {0}", transactionId);

          if (MetraPayClient.State == CommunicationState.Opened)
          {
            try
            {
              MetraPayClient.Close();
            }
            catch (Exception e)
            {
              mLogger.LogException("An unexpected exception occurred", e);
              MetraPayClient.Abort();
              throw;
            }
          }
          else
          {
            MetraPayClient.Abort();
          }

          ElectronicPaymentServices svc = new ElectronicPaymentServices();

          foreach (CreditCardPaymentMethod method in updatedCards)
          {
            try
            {
              using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                       new TransactionOptions(),
                                                       EnterpriseServicesInteropOption.Full))
              {
                int acctId = GetAccountIdForUpdate(method);

                if (acctId != -1)
                {
                  svc.UpdatePaymentMethodNoCheck(new AccountIdentifier(acctId), method.PaymentInstrumentID, method);
                }

                scope.Complete();
              }
            }
            catch (Exception e)
            {
              ElectronicPaymentServices.mLogger.LogException(string.Format("Exception updating payment instrument {0}", method.PaymentInstrumentID), e);
            }
          }

          ElectronicPaymentServices.mLogger.LogInfo("Finished updating credit cards for transaction {0}", transactionId);
        }
      }

      private int GetAccountIdForUpdate(CreditCardPaymentMethod method)
      {
        int acctId = -1;
        if (method.PaymentInstrumentID.CompareTo(Guid.Empty) != 0)
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\ElectronicPaymentService", "__GET_ACCT_ID_FOR_PIID__"))
            {
              stmt.AddParam("%%PIID%%", method.PaymentInstrumentID.ToString());

              using (IMTDataReader rdr = stmt.ExecuteReader())
              {
                if (rdr.Read())
                {
                  acctId = rdr.GetInt32(0);
                }
              }
            }
          }
        }
        else
        {
          throw new MASBasicException("Payment method ID not set in GetAccountId");
        }

        return acctId;
      }

      #endregion
    }

    private class GetPaymentRecord
    {
      private MetraTech.Dataflow.MetraFlowPreparedProgram procPaymentRecord;

      private string mInputTableID;
      private string mInputTablePaymentDetailsID;
      private string mErrorTableID;
      //private string mErrorTablePaymentDetailsID;

      public GetPaymentRecord()
      {
        #region Setup Input/Error Table
        Type intType = typeof(Int32);
        Type strType = typeof(String);
        Type dtType = typeof(DateTime);
        Type decType = typeof(Decimal);

        DataSet inputs = new DataSet();


        string inputTableID = Guid.NewGuid().ToString();
        string inputTablePaymentDetailsID = Guid.NewGuid().ToString();

        mInputTableID = inputTableID;
        mInputTablePaymentDetailsID = inputTablePaymentDetailsID;

        DataTable inputTable = new DataTable(inputTableID);
        DataTable inputTablePaymentDetails = new DataTable(inputTablePaymentDetailsID);

        inputTable.Columns.Add(new DataColumn("c_Namespace", strType));
        inputTable.Columns.Add(new DataColumn("c__AccountID", intType));
        inputTable.Columns.Add(new DataColumn("c__Amount", decType));
        inputTable.Columns.Add(new DataColumn("c_Description", strType));
        inputTable.Columns.Add(new DataColumn("c_EventDate", dtType));
        inputTable.Columns.Add(new DataColumn("c_Source", strType));
        inputTable.Columns.Add(new DataColumn("c_PaymentMethod", intType));
        inputTable.Columns.Add(new DataColumn("c_CCType", intType));
        inputTable.Columns.Add(new DataColumn("c_CheckOrCardNumber", strType));
        inputTable.Columns.Add(new DataColumn("c_TargetInterval", intType));
        inputTable.Columns.Add(new DataColumn("c_ReferenceID", strType));
        inputTable.Columns.Add(new DataColumn("c_PaymentTxnID", strType));
        inputTable.Columns.Add(new DataColumn("PaymentID", strType));
        inputs.Tables.Add(inputTable);

        inputTablePaymentDetails.Columns.Add(new DataColumn("c_Namespace", strType));
        inputTablePaymentDetails.Columns.Add(new DataColumn("c__AccountID", intType));
        inputTablePaymentDetails.Columns.Add(new DataColumn("c_InvoiceNum", strType));
        inputTablePaymentDetails.Columns.Add(new DataColumn("c_PONumber", strType));
        inputTablePaymentDetails.Columns.Add(new DataColumn("c_InvoiceDate", dtType));
        inputTablePaymentDetails.Columns.Add(new DataColumn("c__Amount", decType));
        inputTablePaymentDetails.Columns.Add(new DataColumn("PaymentID", strType));

        inputs.Tables.Add(inputTablePaymentDetails);

        string programText = string.Empty;

        /* MetraFlow Script moved to query configuration.
         * 
           p:import_queue[queueName="%%PARENT_QUEUE%%"];
           c:import_queue[queueName="%%CHILD_QUEUE%%"];
           m:meter[service="metratech.com/Payment", key=”PaymentID”, service="metratech.com/PaymentDetails", key=”PaymentID”, generateSummaryTable=false];
           p -> m(0);
           c -> m(1);
         * 
        */

        IMTQueryAdapter queryAdapter = new MTQueryAdapter();
        queryAdapter.Init("Queries\\ElectronicPaymentService");
        queryAdapter.SetQueryTag("__INSERT_PAYMENT_RECORD__");
        queryAdapter.AddParam("%%PARENT_QUEUE%%", inputTableID, true);
        queryAdapter.AddParam("%%CHILD_QUEUE%%", inputTablePaymentDetailsID, true);

        programText = queryAdapter.GetQuery();

        mLogger.LogInfo("MetraFlow script to Record Payment: " + programText);
        //Pass empty dataset for outputs. but don't disect after the call.
        DataSet outputs = new DataSet();
        string errorTableID = Guid.NewGuid().ToString();
        mErrorTableID = errorTableID;

        procPaymentRecord = new MetraTech.Dataflow.MetraFlowPreparedProgram(programText, inputs, outputs);

        #endregion
      }

      public DataTable Input
      {
        get { return procPaymentRecord.InputDataSet.Tables[mInputTableID]; }
      }

      public DataTable PaymentDetailsInput
      {
        get { return procPaymentRecord.InputDataSet.Tables[mInputTablePaymentDetailsID]; }
      }
      //public DataTable ErrorOutput
      //{
      //    get { return procPaymentRecord.OutputDataSet.Tables[mErrorTableID]; }
      //}

      public void Run()
      {
        procPaymentRecord.Run();
      }
      public void Close()
      {
        procPaymentRecord.Close();
      }

    }

    private GetPaymentRecord GetGetPaymentRecord()
    {
      lock (mGetPaymentRecord)
      {
        while (mGetPaymentRecord.Count > 0)
        {
          GetPaymentRecord getPaymentRecord = mGetPaymentRecord.Pop();
          return getPaymentRecord;
        }
      }

      return new GetPaymentRecord();
    }
    private void ReleaseGetPaymentRecord(GetPaymentRecord getPaymentRecord)
    {
      lock (mGetPaymentRecord)
      {
        if (getPaymentRecord != null)
        {
          if (mGetPaymentRecord.Count < 10)
          {
            getPaymentRecord.Input.Rows.Clear();
            getPaymentRecord.PaymentDetailsInput.Rows.Clear();
            //getPaymentRecord.ErrorOutput.Rows.Clear();
            mGetPaymentRecord.Push(getPaymentRecord);
          }
          else
          {
            getPaymentRecord.Close();
          }
        }
      }
    }
  }
}
