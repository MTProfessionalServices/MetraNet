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
    int CreateQuote(QuoteRequest quoteRequest, IMTSessionContext sessionContext, QuotingConfiguration configuration);
    QuoteResponse UpdateQuoteWithResponse(QuoteResponse quoteResponse);
    QuoteResponse UpdateQuoteWithErrorResponse(int idQuote, QuoteResponse quoteResponse, string errorMessage);
    void SaveQuoteLog(List<QuoteLogRecord> logRecords);

    QuoteHeader GetQuoteHeader(int quoteID, bool loadAllRelatedEntities = true);

    void UpdateStatus(int quoteID, string status, int value);
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

    /// <summary>
    /// Creates quoting BMEs and save them into DB
    /// </summary>
    /// <param name="quoteRequest"></param>
    /// <param name="sessionContext">SessionContext used for knowing which user is performing the action</param>
    /// <param name="configuration">Quoting configuration</param>
    /// /// 
    /// <returns>ID of created quote</returns>
    public int CreateQuote(QuoteRequest quoteRequest, IMTSessionContext sessionContext, QuotingConfiguration configuration)
    {
      var quoteHeader = SetQuoteHeader(quoteRequest, sessionContext, configuration);
      return quoteHeader.QuoteID;

    }

    /// <summary>
    /// Updates quoting BMEs in DB
    /// </summary>     
    /// <param name="quoteResponse"></param>
    public QuoteResponse UpdateQuoteWithResponse(QuoteResponse quoteResponse)
    {
      return SetQuoteContent(quoteResponse);
    }
    /// <summary>
    /// Update cleanup or pdfreport status of quote in async operations
    /// </summary>
    /// <param name="quoteID"></param>
    /// <param name="status"></param>
    /// <param name="value"></param>
    public void UpdateStatus(int quoteID, string status, int value)
    {
      throw new NotImplementedException();
    }

    public QuoteResponse UpdateQuoteWithErrorResponse(int quoteId, QuoteResponse quoteResponse, string errorMessage)
    {
      quoteResponse.FailedMessage = errorMessage;
      return SetQuoteContent(quoteResponse);

      //TODO: Determine how state/error information should be saved (different method?) if we failed in generating quote
    }

    /// <summary>
    /// Get QuoteHeader with related QuoteContent, AccountForQuote and POforQuote
    /// </summary>
    /// <param name="quoteID">Id of quote to get data about</param>
    /// <param name="loadAllRelatedEntities">If false - loads only QuoteHeader </param>
    /// <returns>Null if there is no QuoteHeader for quoteID in DB</returns>
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
          var quoteHeader = new QuoteHeader();

          quoteHeader.CustomDescription = quoteRequest.QuoteDescription;
          quoteHeader.CustomIdentifier = quoteRequest.QuoteIdentifier;
          quoteHeader.StartDate = quoteRequest.EffectiveDate;
          quoteHeader.EndDate = quoteRequest.EffectiveEndDate;

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

    #endregion  }
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