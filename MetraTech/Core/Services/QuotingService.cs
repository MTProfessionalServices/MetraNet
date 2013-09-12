using System;
using System.ServiceModel;
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.Basic.Exception;
using MetraTech.Debug.Diagnostics;
using MetraTech.Domain.Quoting;
using MetraTech.Quoting;

namespace MetraTech.Core.Services
{
  [ServiceContract]
  public interface IQuotingService
  {
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void CreateQuote(QuoteRequest quoteRequest, out QuoteResponse quoteResponse);
  }

  [ServiceBehavior(InstanceContextMode = InstanceContextMode.Single, ConcurrencyMode = ConcurrencyMode.Multiple)]
  public class QuotingService : CMASServiceBase, IQuotingService
  {
    #region Private Members

    private static Logger mLogger = new Logger("[QuotingService]");
    private static QuotingConfiguration cachedQuotingConfiguration = null;

    #endregion

    #region Startup/Initialization
    static QuotingService()
    {
      ServiceStarting += CMASServiceBase_ServiceStarting;
    }

    private static void CMASServiceBase_ServiceStarting()
    {
      try
      {
        cachedQuotingConfiguration = QuotingConfigurationManager.LoadConfigurationFromDefaultSystemLocation();
      }
      catch (Exception ex)
      {
        mLogger.LogError("Unable to load quoting configuration: " + ex.Message);
      }
    }
    #endregion

    #region Additional changes for using FakeItEasy
    //public delegate IMTConnection CreateConnectionDelegate();
    //public delegate IMTConnection CreateConnectionFromPathDelegate(string pathToFolder);

    //private readonly CreateConnectionDelegate _createConnectionDelegate;
    //private readonly CreateConnectionFromPathDelegate _createConnectionFromPathDelegate;
      
    //public DataExportReportManagementService()
    //{
    //  _createConnectionDelegate = ConnectionManager.CreateConnection;
    //  _createConnectionFromPathDelegate = ConnectionManager.CreateConnection;
    //}

    //public DataExportReportManagementService(CreateConnectionDelegate createConnDelegate, CreateConnectionFromPathDelegate createConnFromPathDelegate)
    //{
    //  _createConnectionDelegate = createConnDelegate;
    //  _createConnectionFromPathDelegate = createConnFromPathDelegate;
    //}

    //private IQuotingImplementation quotingImplementation;

    //public QuotingService(IQuotingImplementation _quotingImplementation)
    //{
    //  quotingImplementation = _quotingImplementation;
    //}

    #endregion Additional changes for using FakeItEasy

    /// <summary>
    /// Create quote for Quote Request
    /// </summary>
    /// <param name="quoteRequest"></param>
    /// <returns>Quote Response</returns>
    /// <remarks>Run StartQuote, AddCharges and FinalizeQuote</remarks>
    public void CreateQuote(QuoteRequest quoteRequest, out QuoteResponse quoteResponse)
    {
      quoteResponse = new QuoteResponse();

      using (new HighResolutionTimer("CreateQuote"))
      {
        try
        {
          //Retrieve the security context for this request
          Interop.MTAuth.IMTSessionContext sessionContext = null;
          if (ServiceSecurityContext.Current != null)
          {
            // Get identity context.
            CMASClientIdentity clientIdentity = ServiceSecurityContext.Current.PrimaryIdentity as CMASClientIdentity;

            if (clientIdentity != null)
            {
              sessionContext = clientIdentity.SessionContext;
            }
          }

          IQuotingImplementation quotingImplementation = new QuotingImplementation(cachedQuotingConfiguration, sessionContext);

          quoteResponse = quotingImplementation.CreateQuote(quoteRequest); 

        }
        catch (CommunicationException e)
        {
            mLogger.LogException("Cannot retrieve data for quoting from system ", e);
            quoteResponse.Status=QuoteStatus.Failed;
            quoteResponse.FailedMessage = e.GetaAllMessages(); 
        }

        catch (Exception e)
        {
            mLogger.LogException("Error creating quote ", e);
            quoteResponse.Status = QuoteStatus.Failed;
            quoteResponse.FailedMessage = e.GetaAllMessages(); 
        }
      }

    }
  } 
}
