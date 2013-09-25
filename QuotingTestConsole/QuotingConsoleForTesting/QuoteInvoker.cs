// -----------------------------------------------------------------------
// <copyright file="QuoteInvoker.cs" company="Microsoft">
// TODO: Update copyright text.
// </copyright>
// -----------------------------------------------------------------------

using MetraTech.Core.Services.ClientProxies;
using MetraTech.Domain.Quoting;

namespace QuotingConsoleForTesting
{
  using System;
  using System.Collections.Generic;
  using System.Linq;
  using System.Text;

  /// <summary>
  /// TODO: Update summary.
  /// </summary>
  public class QuoteInvoker
  {
    public static QuoteResponse InvokeCreateQuote(QuoteRequest request)
    {
      using (new MetraTech.Debug.Diagnostics.HighResolutionTimer("QuotingActivityServiceTest"))
      {
        QuoteResponse response = null;
        var client = new QuotingService_CreateQuote_Client
        {
          UserName = "su",
          Password = "su123",
          In_quoteRequest = request,
          Out_quoteResponse = response
        };
        client.Invoke();
        response = client.Out_quoteResponse; 
        return response;
      }
    }
  }
}
