using System;
using System.Linq;
using System.ServiceModel;
using Core.Quoting;
using Core.Quoting.Interface;
using MetraTech.ActivityServices.Common;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.Core.Services.Quoting;
using MetraTech.DataAccess;
using MetraTech.Domain.Quoting;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.Core.Services.Test.Quoting
{
  #region Shared Helper Methods For Quoting Tests

  public class SharedTestCodeQuoting
  {
    public static int GetNRCsCount()
    {
      return GetProductViewCount("t_pv_NonRecurringCharge");
    }

    public static int GetFlatRCsCount()
    {
      return GetProductViewCount("t_pv_FlatRecurringCharge");
    }

    public static int GetUDRCsCount()
    {
      return GetProductViewCount("t_pv_UDRecurringCharge");
    }

    public static int GetProductViewCount(string productViewTableName)
    {
      int count = -1;

      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
        using (IMTStatement stmt = conn.CreateStatement("SELECT count(*) as Count from " + productViewTableName))
        {
          using (IMTDataReader reader = stmt.ExecuteReader())
          {
            while (reader.Read())
            {
              count = reader.GetInt32("count");
            }
          }
        }
      }

      return count;
    }

    public static void VerifyUsageHasBeenCleanedUp(string batchId)
    {
      //TODO: Check to make sure nothing in t_acc_usage has this batchId
      //TODO: Check to make sure nothing in t_failed_transaction
    }

    public static int GetHeadersCount()
    {
      var headers = new MTList<QuoteHeader>();

      RepositoryAccess.Instance.Initialize();
      StandardRepository.Instance.LoadInstances(ref headers);

      return headers.Items.Count;
    }

    public static int GetContentsCount()
    {
      var contents = new MTList<QuoteContent>();

      RepositoryAccess.Instance.Initialize();
      StandardRepository.Instance.LoadInstances(ref contents);

      return contents.Items.Count;
    }

    public static int GetAccountsForQuoteCount()
    {
      var accountForQuote = new MTList<AccountForQuote>();

      RepositoryAccess.Instance.Initialize();
      StandardRepository.Instance.LoadInstances(ref accountForQuote);

      return accountForQuote.Items.Count;
    }

    public static int GetPOsforQuoteCount()
    {
      var poForQuote = new MTList<AccountForQuote>();

      RepositoryAccess.Instance.Initialize();
      StandardRepository.Instance.LoadInstances(ref poForQuote);

      return poForQuote.Items.Count;
    }

    public static void VerifyQuoteRequestCorrectInRepository(int idQuote, QuoteRequest quoteRequest,
                                                             IQuotingRepository quotingRepository)
    {
      var quoteHeaderFromDB = new QuoteHeader();
      try
      {
        quoteHeaderFromDB = quotingRepository.GetQuoteHeader(idQuote);
      }
      catch (Exception ex)
      {
        Assert.Fail("Exception on get quote header: " + ex.Message);
      }

      Assert.AreEqual(quoteHeaderFromDB.QuoteID, idQuote, "Wrong quoteHeaderID");
      Assert.AreEqual(quoteHeaderFromDB.CustomIdentifier, quoteRequest.QuoteIdentifier, "Wrong QuoteIdentifier");
      Assert.AreEqual(quoteHeaderFromDB.CustomDescription, quoteRequest.QuoteDescription, "Wrong QuoteDescription");
      Assert.AreEqual(quoteHeaderFromDB.StartDate, quoteRequest.EffectiveDate, "Wrong EffectiveDate");
      Assert.AreEqual(quoteHeaderFromDB.EndDate, quoteRequest.EffectiveEndDate, "Wrong EffectiveEndDate");


      foreach (var accountID in quoteRequest.Accounts)
      {
        Assert.IsTrue(
          Enumerable.Any<IAccountForQuote>(quoteHeaderFromDB.AccountForQuotes, accountForQuote => accountForQuote.AccountID == accountID),
          "AccountID is missed in QuoteHeader");
      }

      foreach (var poID in quoteRequest.ProductOfferings)
      {
        Assert.IsTrue(Enumerable.Any<IPOforQuote>(quoteHeaderFromDB.POforQuotes, accountForQuote => accountForQuote.POID == poID),
                      "POID is missed in QuoteHeader");

        if (quoteRequest.SubscriptionParameters.UDRCValues.ContainsKey(poID.ToString()))
        {
          var udrcValues = quoteRequest.SubscriptionParameters.UDRCValues[poID.ToString()];
          var po = Enumerable.FirstOrDefault<IPOforQuote>(quoteHeaderFromDB.POforQuotes, p => p.POID == poID);

          foreach (var udrcInstanceValueBase in udrcValues)
          {
            Assert.IsTrue(po.UDRCForQuotings.Any(udrc => udrc.PI_Id == udrcInstanceValueBase.UDRC_Id),
                          "UDRC is missed in POforQuotes");
          }

        }

      }
    }

    public static void VerifyQuoteResponseCorrectInRepository(int idQuote, QuoteResponse quoteResponse, IQuotingRepository quotingRepository)
    {
        var quoteHeaderFromDB = new QuoteHeader();
        try
        {
            quoteHeaderFromDB = quotingRepository.GetQuoteHeader(idQuote);
        }
        catch (Exception ex)
        {
            Assert.Fail("Exception on get quote header: " + ex.Message);
        }
        
        Assert.AreEqual(quoteHeaderFromDB.QuoteContent.Total, quoteResponse.TotalAmount, "Wrong TotalAmount");
        Assert.AreEqual(quoteHeaderFromDB.QuoteContent.TotalTax, quoteResponse.TotalTax, "Wrong TotalTax");
        Assert.AreEqual(quoteHeaderFromDB.QuoteContent.Currency, quoteResponse.Currency, "Wrong Currency");
        Assert.AreEqual(quoteHeaderFromDB.QuoteContent.ReportLink, quoteResponse.ReportLink, "Wrong ReportLink");
        Assert.AreEqual(quoteHeaderFromDB.QuoteContent.FailedMessage, quoteResponse.FailedMessage, "Wrong FailedMessage");
        Assert.AreEqual(quoteHeaderFromDB.QuoteContent.Status, Convert.ToInt32((object) quoteResponse.Status), "Wrong Status");
    }

    public static void VerifyQuoteResponseIsErrorInRepository(int idQuote, string partialErrorMessageToCheckFor, IQuotingRepository quotingRepository)
    {
        var quoteHeaderFromDB = new QuoteHeader();
        try
        {
            quoteHeaderFromDB = quotingRepository.GetQuoteHeader(idQuote);
        }
        catch (Exception ex)
        {
            Assert.Fail("Exception on get quote header: " + ex.Message);
        }

        Assert.IsTrue(quoteHeaderFromDB.QuoteContent.FailedMessage.Contains(partialErrorMessageToCheckFor), "Wrong FailedMessage");   
    }

    public static QuoteResponse InvokeCreateQuote(QuoteRequest request)
    {
      QuotingServiceClient qsc = new QuotingServiceClient();

      try
      {
        QuoteResponse response = null;
        qsc.ClientCredentials.UserName.UserName = "su";
        qsc.ClientCredentials.UserName.Password = "su123";
        qsc.CreateQuote(request, out response);

        return response;
      }
      finally
      {
                if (qsc.State == CommunicationState.Opened)
                  {
                    qsc.Close();
                  }
                  else
                  {
                    qsc.Abort();
                  }
      }
    }
  }

  #endregion
}
