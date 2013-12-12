using System;
using System.Collections.Generic;
using System.Data.Entity.Validation;
using System.Linq;
using System.Reflection;
using System.Transactions;
using Core.Quoting;
using MetraTech.ActivityServices.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.DataAccess;
using MetraTech.Debug.Diagnostics;
using MetraTech.Domain.DataAccess;
using MetraTech.Domain.Quoting;
using MetraTech.Interop.MTAuth;

namespace MetraTech.Core.Services.Quoting
{
  /// <summary>
  /// Encapsulates the storage and retrieval of quoting objects in the repository
  /// </summary>
  public interface IQuotingRepository
  {
    /// <summary> Creates quoting BMEs and save them into DB
    /// </summary>
    /// <param name="quoteRequest"></param>
    /// <param name="sessionContext">SessionContext used for knowing which user is performing the action</param>
    /// <param name="configuration">Quoting configuration</param>
    /// <returns>ID of created quote</returns>
    int CreateQuote(QuoteRequest quoteRequest, IMTSessionContext sessionContext, QuotingConfiguration configuration);
    /// <summary> Updates quoting BMEs in DB
    /// </summary>     
    /// <param name="quoteResponse"></param>    
    QuoteResponse UpdateQuoteWithResponse(QuoteResponse quoteResponse);
    /// <summary> Updates quoting BMEs in DB with error massage
    /// </summary>     
    /// <param name="quoteResponse"></param> 
    /// <param name="errorMessage"></param>       
    QuoteResponse UpdateQuoteWithErrorResponse(int idQuote, QuoteResponse quoteResponse, string errorMessage);
    /// <summary>Save log messages into db
    /// </summary>
    /// <param name="logRecords"></param>
    void SaveQuoteLog(List<QuoteLogRecord> logRecords);
    /// <summary> Get QuoteHeader with related QuoteContent, AccountForQuote and POforQuote
    /// </summary>
    /// <param name="quoteID">Id of quote to get data about</param>
    /// <param name="loadAllRelatedEntities">If false - loads only QuoteHeader </param>
    /// <returns>Null if there is no QuoteHeader for quoteID in DB</returns>
    QuoteHeader GetQuoteHeader(int quoteID, bool loadAllRelatedEntities = true);
    /// <summary> Update cleanup or pdfreport status of quote in async operations
    /// </summary>
    /// <param name="quoteId">Quote to update status for</param>
    /// <param name="status">Action to update status for</param>
    /// <param name="value">Value to set for status</param>
    void UpdateStatus(int quoteId, ActionStatus status, QuoteStatus value);
    /// <summary>Get status of async operation for quote (generate PDF or cleanup)
    /// </summary>
    /// <param name="quoteID">Quote to get status for</param>
    /// <param name="status">StatusReport, StatusCleanup</param>
    /// <returns></returns>
    QuoteStatus GetActionStatus(int quoteID, ActionStatus status);
    /// <summary>Delete data from t_acc_usage
    /// </summary>
    /// <param name="quoteId">Quote to delete data for</param>
    /// <param name="configuration"></param>
    void DeleteAccUsageQuoting(int quoteId, QuotingConfiguration configuration);
    /// <summary> Delete quoting information from BME tables
    /// </summary>
    /// <param name="quoteId">External quote id</param>
    void DeleteQuoteBME(int quoteId);
  }

  /// <summary>
  /// Test verification requires independent checking of the counts of items in the repository
  /// Separated into different interface on repository so it is clear what is required by quoting
  /// implementation and what is needed for test verification
  /// </summary>
  public interface IQuotingRespositoryStatistics
  {
    int GetQuoteHeaderCount();
    int GetQuoteContentCount();
    int GetAccountForQuoteCount();
    int GetPOForQuoteCount();
    int GetQuoteLogRecordsCount();
  }

  /// <summary>
  /// Implementation of storing and retrieving quote information using BMEs
  /// </summary>
  public class QuotingRepository : IQuotingRepository, IQuotingRespositoryStatistics
  {
    private static Logger mLogger = new Logger("[QuotingRepository]");

    public int CreateQuote(QuoteRequest quoteRequest, IMTSessionContext sessionContext, QuotingConfiguration configuration)
    {
      var quoteHeader = SetQuoteHeader(quoteRequest, sessionContext, configuration);
      return quoteHeader.QuoteID;

    }

    public QuoteResponse UpdateQuoteWithResponse(QuoteResponse quoteResponse)
    {
      return SetQuoteContent(quoteResponse);
    }

    public void UpdateStatus(int quoteId, ActionStatus status, QuoteStatus value)
    {
      using (new HighResolutionTimer(MethodBase.GetCurrentMethod().Name))
      {
        RepositoryAccess.Instance.Initialize();

        //get quoteContent BME
        var quoteContent = GetQuoteContent(quoteId);

        try
        {
          if (quoteContent == null)
          {
            throw new Exception(String.Format("Can't find quote header with idQuote = {0}", quoteId));
          }

          switch (status)
          {
            case ActionStatus.StatusReport:
              quoteContent.StatusReport = (int?)value;
              break;
            case ActionStatus.StatusCleanup:
              quoteContent.StatusCleanup = (int?)value;
              break;
            default:
              throw new ArgumentOutOfRangeException("status");
          }

          quoteContent.Save();
        }
        catch (Exception ex)
        {
          mLogger.LogException("Error save Quote content", ex);
          throw;
        }
      }
    }

    public QuoteStatus GetActionStatus(int quoteID, ActionStatus status)
    {
      using (new HighResolutionTimer(MethodBase.GetCurrentMethod().Name))
      {
        RepositoryAccess.Instance.Initialize();

        //get quoteContent BME
        var quoteContent = GetQuoteContent(quoteID);

        try
        {
          if (quoteContent == null)
          {
            throw new Exception(String.Format("Can't find quote header with idQuote = {0}", quoteID));
          }

          switch (status)
          {
            case ActionStatus.StatusReport:
              return quoteContent.StatusReport != null ? (QuoteStatus)quoteContent.StatusReport : QuoteStatus.None;
            case ActionStatus.StatusCleanup:
              return quoteContent.StatusCleanup != null ? (QuoteStatus)quoteContent.StatusCleanup : QuoteStatus.None;
            default:
              return QuoteStatus.None;
          }
        }
        catch (Exception ex)
        {
          mLogger.LogException("Error return action status", ex);
          throw;
        }
      }
    }

    public QuoteResponse UpdateQuoteWithErrorResponse(int quoteId, QuoteResponse quoteResponse, string errorMessage)
    {
      quoteResponse.FailedMessage = errorMessage;
      return SetQuoteContent(quoteResponse);

      //TODO: Determine how state/error information should be saved (different method?) if we failed in generating quote
    }

    public QuoteHeader GetQuoteHeader(int quoteID, bool loadAllRelatedEntities = true)
    {
      RepositoryAccess.Instance.Initialize();
      try
      {
        //get quoteContent BME
        IStandardRepository standardRepository = RepositoryAccess.Instance.GetRepository();

        var qouteHeaderList = new MTList<QuoteHeader>();
        qouteHeaderList.Filters.Add(
          new MTFilterElement("QuoteID",
                              MTFilterElement.OperationType.Equal,
                              quoteID));

        standardRepository.LoadInstances(ref qouteHeaderList);

        if (qouteHeaderList.TotalRows < 1)
          return null;

        var quoteHeder = qouteHeaderList.Items.First();

        //get related entities
        if (loadAllRelatedEntities)
        {
          quoteHeder.QuoteContent = quoteHeder.LoadQuoteContent();

          var mtList = new MTList<DataObject>();
          StandardRepository.Instance.LoadInstancesFor(typeof(AccountForQuote).FullName,
                                                       typeof(QuoteHeader).FullName,
                                                       quoteHeder.Id,
                                                       mtList);
          foreach (var accountforQuoteDataObject in mtList.Items)
          {
            var accountforQuote = new AccountForQuote();
            accountforQuote.CopyPropertiesFrom(accountforQuoteDataObject);
            quoteHeder.AccountForQuotes.Add(accountforQuote);
          }

          mtList = new MTList<DataObject>();
          StandardRepository.Instance.LoadInstancesFor(typeof(POforQuote).FullName,
                                                       typeof(QuoteHeader).FullName,
                                                       quoteHeder.Id,
                                                       mtList);
          foreach (var POforQuoteDataObject in mtList.Items)
          {
            var pOforQuote = new POforQuote();
            pOforQuote.CopyPropertiesFrom(POforQuoteDataObject);


            mtList = new MTList<DataObject>();
            StandardRepository.Instance.LoadInstancesFor(typeof(UDRCForQuoting).FullName,
                                                         typeof(POforQuote).FullName,
                                                         POforQuoteDataObject.Id,
                                                         mtList);

            foreach (var UDRCQuoteDataObject in mtList.Items)
            {
              var udrcForQuote = new UDRCForQuoting();
              udrcForQuote.CopyPropertiesFrom(UDRCQuoteDataObject);
              pOforQuote.UDRCForQuotings.Add(udrcForQuote);
            }

            quoteHeder.POforQuotes.Add(pOforQuote);
          }
        }

        return quoteHeder;
      }
      catch (Exception ex)
      {
        mLogger.LogException("Error get QuoteHeader", ex);
        throw;
      }
    }

    private static object lock_create_quote_header = new object();
    private static QuoteHeader SetQuoteHeader(QuoteRequest quoteRequest, IMTSessionContext sessionContext, QuotingConfiguration configuration)
    {
      using (new HighResolutionTimer(MethodBase.GetCurrentMethod().Name))
      {
        RepositoryAccess.Instance.Initialize();

        try
        {
          var quoteHeader = new QuoteHeader
            {
              CustomDescription = quoteRequest.QuoteDescription,
              CustomIdentifier = quoteRequest.QuoteIdentifier,
              StartDate = quoteRequest.EffectiveDate,
              EndDate = quoteRequest.EffectiveEndDate
            };

          if (sessionContext != null)
            quoteHeader.UID = sessionContext.AccountID;

          // NHibernate does not support multithreading for saving in case Quote creates in async mode
          lock (lock_create_quote_header)
          {

            #region Get max quote id and save quoteHeader

            //TODO: we need to implement Delete() methods and call it in case exceptoion was thrown
            // Do not put thise cose under one big transaction, because you eill get the error something like that:
            // Cannot save data objects of type 'Core.Quoting.QuoteHeader' with Id'446fb7ed-0071-4f28-8453-a25a005a89d9'
            // An exception occurred when executing batch queries
            // Transaction (Process ID 121) was deadlocked on lock resources with another process and has been chosen as the deadlock victim. Rerun the transaction.
            using (var scope = new TransactionScope(TransactionScopeOption.Required))
            {
              using (var conn = ConnectionManager.CreateConnection())
              {
                // calculate max quote ID
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(configuration.QuotingQueryFolder,
                                                                         configuration.GetMaxQuoteIdQueryTag))
                {
                  using (IMTDataReader rowset = stmt.ExecuteReader())
                  {
                    rowset.Read();
                    int quoteId;
                    var quoteIdTmp = rowset.GetValue("QuoteId");
                    Int32.TryParse(quoteIdTmp.ToString(), out quoteId);
                    quoteHeader.QuoteID = ++quoteId;
                    quoteHeader.Save();
                  }
                }
              }
              scope.Complete();
            }

            #endregion Get max quote id and save quoteHeader

            #region Save accounts for quote

            foreach (var accountForQuoteBME in
                quoteRequest.Accounts.Select(account => new AccountForQuote { AccountID = account }))
            {
              accountForQuoteBME.QuoteHeader = quoteHeader;
              accountForQuoteBME.Save();
            }

            #endregion

            #region Save product offering

            var poOrder = 0;
            foreach (
                var POforQuoteBME in quoteRequest.ProductOfferings.Select(po => new POforQuote { POID = po }))
            {
              POforQuoteBME.QuoteHeader = quoteHeader;
              POforQuoteBME.Order = poOrder++;
              POforQuoteBME.Save();

              if (quoteRequest.SubscriptionParameters.UDRCValues.ContainsKey(POforQuoteBME.POID.ToString()))
              {

                foreach (
                    var UDRCValue in
                        quoteRequest.SubscriptionParameters.UDRCValues[POforQuoteBME.POID.ToString()])
                {
                  var udrcValuesForQuote = new UDRCForQuoting();
                  udrcValuesForQuote.CreationDate = MetraTime.Now;
                  udrcValuesForQuote.StartDate = UDRCValue.StartDate;
                  udrcValuesForQuote.EndDate = UDRCValue.EndDate;
                  udrcValuesForQuote.POforQuote = POforQuoteBME;
                  udrcValuesForQuote.Value = UDRCValue.Value;
                  udrcValuesForQuote.PI_Id = UDRCValue.UDRC_Id;

                  udrcValuesForQuote.Save();
                }
              }

              #region Save ICB prices

              var prices = quoteRequest.IcbPrices.Where(i => i.ProductOfferingId == POforQuoteBME.POID);
              foreach (var price in prices)
              {
                var qip = new QuoteICB
                    {
                      QuoteHeader = quoteHeader,
                      POforQuote = POforQuoteBME,
                      CurrentChargeType = price.CurrentChargeType.ToString(),
                      PriceableItemId = price.PriceableItemId,
                      ChargesRates =
                          System.Text.Encoding.UTF8.GetBytes(price.ChargesRates.Serialize())
                    };
                qip.Save();
              }

              #endregion
            }

            #endregion

            #region Save quote content

            var quoteContent = new QuoteContent
                {
                  Status = 1,
                  QuoteHeader = quoteHeader
                };
            quoteContent.Save();

            #endregion
            return quoteHeader;
          }

        }
        catch (DbEntityValidationException e)
        {
          mLogger.LogException("Error save Quote header", e);
          throw;
        }
        catch (Exception ex)
        {
          mLogger.LogException("Error save Quote header", ex);
          throw;
        }


      }
    }

    private QuoteContent GetQuoteContent(int quoteID)
    {
      var quoteHeader = GetQuoteHeader(quoteID, false);

      if (quoteHeader == null)
        return null;

      return quoteHeader.LoadQuoteContent() as QuoteContent;
    }

    private QuoteResponse SetQuoteContent(QuoteResponse q)
    {
      using (new HighResolutionTimer(MethodBase.GetCurrentMethod().Name))
      {
        RepositoryAccess.Instance.Initialize();

        //get quoteContent BME
        var quoteContent = GetQuoteContent(q.IdQuote);

        try
        {
          if (quoteContent == null)
          {
            throw new Exception(String.Format("Can't find quote header with idQuote = {0}{1}Inner Exceptions:{1}{2}",
                                              q.IdQuote,
                                              Environment.NewLine,
                                              q.MessageLog.Aggregate("",
                                                                     (current, message) =>
                                                                     current + (message.Message + Environment.NewLine))));
          }

          quoteContent.Total = q.TotalAmount;
          quoteContent.TotalTax = q.TotalTax;
          quoteContent.Currency = q.Currency;
          quoteContent.ReportLink = q.ReportLink;
          //quoteContent.CreationDate = q.CreationDate;
          var failedMessage = q.FailedMessage;
          if (!String.IsNullOrEmpty(failedMessage) && failedMessage.Length > 2000)
          {
            failedMessage = failedMessage.Substring(0, 2000);
          }
          quoteContent.FailedMessage = failedMessage;
          quoteContent.Status = Convert.ToInt32(q.Status);

          // todo fill .ReportContent =

          quoteContent.Save();
        }
        catch (Exception ex)
        {
          mLogger.LogException("Error save Quote content", ex);
          throw;
        }
        q.CreationDate = quoteContent.CreationDate == null ? MetraTime.Now : Convert.ToDateTime(quoteContent.CreationDate);
        return q;
      }
    }

    public void SaveQuoteLog(List<QuoteLogRecord> logRecords)
    {
      using (new HighResolutionTimer(MethodBase.GetCurrentMethod().Name))
      {
        RepositoryAccess.Instance.Initialize();

        try
        {
          foreach (var record in logRecords)
          {
            var quoteLog = record.ConvertToQuoteLog();
            quoteLog.Save();
          }
        }
        catch (Exception ex)
        {
          mLogger.LogException("Error saving log record(s)", ex);
          throw;
        }
      }
    }

    public void DeleteAccUsageQuoting(int quoteId, QuotingConfiguration configuration)
    {
      try
      {
        using (var conn = ConnectionManager.CreateConnection())
        {
          using (var stmt = conn.CreateAdapterStatement(configuration.QuotingQueryFolder,
                                                         configuration.RemoveQuoteUsagesQueryTag))
          {
            stmt.AddParam("%%QUOTE_ID%%", quoteId);
            stmt.ExecuteReader();
          }
        }
      }
      catch (Exception ex)
      {
        mLogger.LogException("Error delete AccUsageQuoting record(s)", ex);
        throw;
      }
    }


    #region IQuoteRepositoryStatistics: Methods needed by test scenarios

    public int GetQuoteHeaderCount()
    {
      RepositoryAccess.Instance.Initialize();
      try
      {
        //get quoteContent BME
        IStandardRepository standardRepository = RepositoryAccess.Instance.GetRepository();

        var qouteHeaderList = new MTList<QuoteHeader>();
        standardRepository.LoadInstances(ref qouteHeaderList);
        return qouteHeaderList.TotalRows;
      }
      catch (Exception ex)
      {
        mLogger.LogException("Error get QuoteHeader", ex);
        throw;
      }
    }

    public int GetQuoteContentCount()
    {
      RepositoryAccess.Instance.Initialize();
      try
      {
        //get quoteContent BME
        IStandardRepository standardRepository = RepositoryAccess.Instance.GetRepository();

        var qouteHeaderList = new MTList<QuoteContent>();
        standardRepository.LoadInstances(ref qouteHeaderList);
        return qouteHeaderList.TotalRows;
      }
      catch (Exception ex)
      {
        mLogger.LogException("Error get QuoteContent", ex);
        throw;
      }
    }

    public int GetAccountForQuoteCount()
    {
      RepositoryAccess.Instance.Initialize();
      try
      {
        //get quoteContent BME
        IStandardRepository standardRepository = RepositoryAccess.Instance.GetRepository();

        var qouteHeaderList = new MTList<AccountForQuote>();
        standardRepository.LoadInstances(ref qouteHeaderList);
        return qouteHeaderList.TotalRows;
      }
      catch (Exception ex)
      {
        mLogger.LogException("Error get AccountForQuote", ex);
        throw;
      }
    }

    public int GetPOForQuoteCount()
    {
      RepositoryAccess.Instance.Initialize();
      try
      {
        //get quoteContent BME
        IStandardRepository standardRepository = RepositoryAccess.Instance.GetRepository();

        var qouteHeaderList = new MTList<POforQuote>();
        standardRepository.LoadInstances(ref qouteHeaderList);
        return qouteHeaderList.TotalRows;
      }
      catch (Exception ex)
      {
        mLogger.LogException("Error get POforQuote", ex);
        throw;
      }
    }

    public int GetQuoteLogRecordsCount()
    {
      RepositoryAccess.Instance.Initialize();

      try
      {
        IStandardRepository repository = RepositoryAccess.Instance.GetRepository();

        var logRecords = new MTList<QuoteLog>();
        repository.LoadInstances(ref logRecords);

        return logRecords.TotalRows;
      }
      catch (Exception ex)
      {
        mLogger.LogException("Error loading QuoteLog instances", ex);
        throw;
      }
    }
    public int GetAssUsageQuotingRecordsCount(QuotingConfiguration config)
    {
      RepositoryAccess.Instance.Initialize();

      try
      {
        using (var conn = ConnectionManager.CreateNonServicedConnection())
        {
          using (var stmt = conn.CreateAdapterStatement(config.QuotingQueryFolder,
                                                   config.CountTotalQuoteUsagesQueryTag))
          {
            using (var rowset = stmt.ExecuteReader())
            {
              return rowset.GetInt32(1);
            }
          }
        }
      }
      catch (Exception ex)
      {
        mLogger.LogException("Error loading AssUsageQuoting instances", ex);
        throw;
      }
    }

    #endregion  }

    public void DeleteQuoteBME(int quoteId)
    {
      try
      {
        var quoteHeader = GetQuoteHeader(quoteId);

        IStandardRepository repository = RepositoryAccess.Instance.GetRepository();
        repository.Delete("Core.Quoting.QuoteContent", quoteHeader.QuoteContent.Id);
        repository.Delete("Core.Quoting.QuoteHeader", quoteHeader.Id);
      }
      catch (Exception ex)
      {
        mLogger.LogException("Error deleting quote BME record(s) ", ex);
        throw;
      }
    }
  }

  /// <summary>
  /// Extension methods
  /// </summary>
  public static class QuotingRepositoryExtensionMethods
  {
    public static QuoteLog ConvertToQuoteLog(this QuoteLogRecord record)
    {
      return new QuoteLog()
      {
        QuoteIdentifier = record.QuoteIdentifier,
        DateAdded = record.DateAdded,
        Message = record.Message
      };
    }
  }

  /// <summary>
  /// Dummy implementation of quoting repository that does not utilize the database (stored in Memory)
  /// Useful in the beginning for testing; now would need updating as not all test checking, total calculation
  /// or PDF generation would work correctly against this dummy repository
  /// </summary>
  public class QuotingRepositoryInMemory : IQuotingRepository, IQuotingRespositoryStatistics
  {

    private int idCurrent = 0;
    private Dictionary<int, QuoteRequest> requests = new Dictionary<int, QuoteRequest>();
    private Dictionary<int, QuoteResponse> responses = new Dictionary<int, QuoteResponse>();
    private readonly Dictionary<int, QuoteHeader> headers = new Dictionary<int, QuoteHeader>();
    private readonly Dictionary<int, QuoteContent> contents = new Dictionary<int, QuoteContent>();
    private readonly Dictionary<int, List<AccountForQuote>> accounts = new Dictionary<int, List<AccountForQuote>>();
    private readonly Dictionary<int, List<POforQuote>> pos = new Dictionary<int, List<POforQuote>>();
    private readonly List<QuoteLogRecord> quoteLog = new List<QuoteLogRecord>();

    #region IQuotingRepository Members

    public int CreateQuote(QuoteRequest quoteRequest, IMTSessionContext sessionContext, QuotingConfiguration configuration)
    {
      int newId = idCurrent++;
      requests.Add(newId, quoteRequest);

      // Add empty entities for now

      headers.Add(newId, new QuoteHeader());
      contents.Add(newId, new QuoteContent());

      var accountToAdd = new List<AccountForQuote>();
      var posToAdd = new List<POforQuote>();

      for (int i = 0; i < quoteRequest.Accounts.Count; i++)
        accountToAdd.Add(new AccountForQuote());

      accounts.Add(newId, accountToAdd);

      for (int i = 0; i < quoteRequest.ProductOfferings.Count; i++)
        posToAdd.Add(new POforQuote());

      pos.Add(newId, posToAdd);

      return newId;
    }

    public QuoteHeader GetQuoteHeader(int quoteID, bool loadAllRelatedEntities = true)
    {
      var quoteHeder = new QuoteHeader { QuoteID = quoteID };
      return quoteHeder;
    }

    public void UpdateStatus(int quoteId, ActionStatus status, QuoteStatus value)
    {
      throw new NotImplementedException();
    }

    public QuoteStatus GetActionStatus(int quoteID, ActionStatus status)
    {
      throw new NotImplementedException();
    }

    public void DeleteAccUsageQuoting(int quoteId, QuotingConfiguration configuration)
    {
      throw new NotImplementedException();
    }

    public void DeleteQuoteBME(int quoteId)
    {
      throw new NotImplementedException();
    }

    public QuoteResponse UpdateQuoteWithResponse(QuoteResponse quoteResponse)
    {
      if (!requests.ContainsKey(quoteResponse.IdQuote))
        throw new ArgumentException(string.Format("Quote with id {0} not found in repository", quoteResponse.IdQuote), "idQuote");

      responses.Add(quoteResponse.IdQuote, quoteResponse);
      return quoteResponse;

    }

    public QuoteResponse UpdateQuoteWithErrorResponse(int idQuote, QuoteResponse quoteResponse, string errorMessage)
    {
      if (!requests.ContainsKey(idQuote))
        throw new ArgumentException(string.Format("Quote with id {0} not found in repository", idQuote), "idQuote");

      return quoteResponse;
      //For now don't know what the dummy implementation should do so do nothing
    }

    public void SaveQuoteLog(List<QuoteLogRecord> logRecords)
    {
      quoteLog.AddRange(logRecords);
    }
    #endregion

    #region IQuoteRepositoryStatistics: Methods needed by test scenarios

    public int GetQuoteHeaderCount()
    {
      return HeadersCount;
    }

    public int GetQuoteContentCount()
    {
      return ContentsCount;
    }

    public int GetAccountForQuoteCount()
    {
      return AccountsCount;
    }

    public int GetPOForQuoteCount()
    {
      return POsCount;
    }

    public int HeadersCount
    {
      get { return headers.Count; }
    }

    public int ContentsCount
    {
      get { return contents.Count; }
    }

    public int AccountsCount
    {
      get { return accounts.Values.Count == 0 ? 0 : accounts.Values.First().Count; }
    }

    public int POsCount
    {
      get { return pos.Values.Count == 0 ? 0 : pos.Values.First().Count; }
    }
    public int GetQuoteLogRecordsCount()
    {
      return quoteLog.Count;
    }

    #endregion
  }
}