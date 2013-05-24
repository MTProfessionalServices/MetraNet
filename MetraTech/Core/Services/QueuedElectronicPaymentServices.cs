using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ServiceModel;
using MetraTech.DomainModel.MetraPay;
using System.IO;
using MetraTech.ActivityServices.Services.Common;
using System.Configuration;
using MetraTech.Interop.QueryAdapter;
using MetraTech.Interop.RCD;

namespace MetraTech.Core.Services
{
  /// <summary>
  /// Used to submit requests to process individual transactions as well as signal all batch transactions to be sent.
  /// </summary>
  [ServiceContract]
  public interface IQueuedBatchPaymentSubmissionService
  {
    [OperationContract(IsOneWay = true)]
    void CapturePreAuthorizedChargeBatch(Guid authorizationToken, Guid paymentToken, MetraPaymentInfo metraPaymentInfo);
    [OperationContract(IsOneWay = true)]
    void DebitPaymentMethodBatch(Guid token, MetraPaymentInfo metraPaymentInfo);
    [OperationContract(IsOneWay = true)]
    void CreditPaymentMethodBatch(Guid token, MetraPaymentInfo metraPaymentInfo);
    [OperationContract(IsOneWay = true)]
    void SubmitAllBatches();
  }

  /// <summary>
  /// Allows clients to submit payments in a de-coupled, queued manner.
  /// </summary>
  [ServiceContract]
  public interface IQueuedPaymentSubmissionService
  {
    [OperationContract(IsOneWay = true)]
    void CapturePreAuthorizedCharge(Guid authorizationToken, Guid paymentToken, MetraPaymentInfo metraPaymentInfo);
    [OperationContract(IsOneWay = true)]
    void DebitPaymentMethod(Guid token, MetraPaymentInfo metraPaymentInfo);
    [OperationContract(IsOneWay = true)]
    void CreditPaymentMethod(Guid token, MetraPaymentInfo metraPaymentInfo);
    [OperationContract(IsOneWay = true)]
    void PreAuthorizeCharge(Guid methodToken, MetraPaymentInfo estimatedPaymentInfo);
  }
  /// <summary>
  /// This is used by queued services to post responses to their clients.
  /// </summary>
  [ServiceContract]
  public interface IQueuedPaymentResponseService
  {
    [OperationContract(IsOneWay = true)]
    void OnComplete(PaymentResponseBase response);
  }

  [ServiceBehavior(ConcurrencyMode = ConcurrencyMode.Single,
    InstanceContextMode = InstanceContextMode.Single,
    ReleaseServiceInstanceOnTransactionComplete = false)]
  public class QueuedElectronicPaymentServices : CMASServiceBase,
    IQueuedPaymentSubmissionService, IQueuedBatchPaymentSubmissionService, IQueuedPaymentResponseService
  {
    private static Logger m_logger = new Logger("[QueuedElectronicPaymentServices]");
    private static EPSConfig m_epsConfig = null;
    private static string m_insertSchedPymtDetailsQuery = null;
    private static IARPaymentIntegration m_arPaymentIntegrationImpl;
    private static MemoryStream m_routerXoml = null;
    private static MemoryStream m_routerRules = null;

    static QueuedElectronicPaymentServices()
    {
      CMASServiceBase.ServiceStarting += new ServiceStartingEventHandler(CMASServiceBase_ServiceStarting);
    }

    static void CMASServiceBase_ServiceStarting()
    {
      InitializeRouterWorkflow();

      // Reading in EPS Config related . . .
      Configuration config = LoadConfigurationFile(@"ElectronicPaymentServices\EPSHost.xml");
      m_epsConfig = config.GetSection("EPSConfig") as EPSConfig;

      IMTQueryAdapter qa = new MTQueryAdapter();
      qa.Init(@"Queries\ElectronicPaymentService");
      qa.SetQueryTag("__INSERT_SCHEDULED_PAYMENT_DETAILS__");
      m_insertSchedPymtDetailsQuery = qa.GetQuery();

      try
      {
        m_logger.LogInfo("ArImplementation Assembly Name :" + m_epsConfig.ArPayImplementation.Type);
        if (!string.IsNullOrEmpty(m_epsConfig.ArPmtImplType))
        {
          m_arPaymentIntegrationImpl = Activator.CreateInstance(Type.GetType(m_epsConfig.ArPmtImplType)) as IARPaymentIntegration;
        }
      }
      catch (Exception excp)
      {
        m_logger.LogException("Error while instantiating ARPaymentIntegration. ", excp);
      }

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

        m_routerXoml = new MemoryStream(bytes);

        rdr.Close();
        rdr.Dispose();
      }
      string rulesFilename = Path.Combine(rcd.ExtensionDir, @"paymentsvrclient\config\MetraPay\MetraPayRouter.rules");

      if (File.Exists(rulesFilename))
      {
        StreamReader rdr = new StreamReader(rulesFilename);
        byte[] bytes = new byte[rdr.BaseStream.Length + 1];
        rdr.BaseStream.Read(bytes, 0, bytes.Length);

        m_routerRules = new MemoryStream(bytes);

        rdr.Close();
        rdr.Dispose();
      }
    }

    #region IQueuedPaymentSubmissionService Members
    [OperationBehavior(TransactionScopeRequired = true)]
    public void DebitPaymentMethod(Guid token, MetraPaymentInfo metraPaymentInfo)
    {

    }

    [OperationBehavior(TransactionScopeRequired = true)]
    public void CreditPaymentMethod(Guid token, MetraPaymentInfo metraPaymentInfo)
    {

    }

    [OperationBehavior(TransactionScopeRequired = true)]
    public void PreAuthorizeCharge(Guid methodToken, MetraPaymentInfo estimatedPaymentInfo)
    {

    }

    [OperationBehavior(TransactionScopeRequired = true)]
    public void CapturePreAuthorizedCharge(Guid authorizationToken, Guid paymentToken, MetraPaymentInfo metraPaymentInfo)
    {
    }

    #endregion

    #region IQueuedBatchPaymentSubmissionService Members

    [OperationBehavior(TransactionScopeRequired = true)]
    public void CapturePreAuthorizedChargeBatch(Guid authorizationToken, Guid paymentToken, MetraPaymentInfo metraPaymentInfo)
    {
    }

    [OperationBehavior(TransactionScopeRequired = true)]
    public void DebitPaymentMethodBatch(Guid token, MetraPaymentInfo metraPaymentInfo)
    {
    }

    [OperationBehavior(TransactionScopeRequired = true)]
    public void CreditPaymentMethodBatch(Guid token, MetraPaymentInfo metraPaymentInfo)
    {
    }

    [OperationBehavior(TransactionScopeRequired = true)]
    public void SubmitAllBatches()
    {
    }

    #endregion

    #region IQueuedPaymentResponseService Members

    [OperationBehavior(TransactionScopeRequired = true)]
    public void OnComplete(PaymentResponseBase response)
    {
    }

    #endregion
  }

}
