// -----------------------------------------------------------------------
// <copyright file="IChargeMetering.cs" company="Microsoft">
// TODO: Update copyright text.
// </copyright>
// -----------------------------------------------------------------------

using MetraTech.DataAccess;

namespace MetraTech.Quoting
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using MetraTech.Domain.Quoting;

    /// <summary>
    /// Interface for creation\removing charges from DB
    /// </summary>
    public interface IChargeMetering
    {
      /// <summary>
      /// Gets MetreNet loger in case for using in other classes
      /// </summary>
      ILogger Log { get; }

      /// <summary>
      /// Adds charges to DB and initiate metering
      /// </summary>
      /// <param name="transacConnection"></param>
      /// <param name="quoteRequest"></param>
      /// <returns></returns>
      IList<ChargeData> AddCharges(IMTServicedConnection transacConnection, QuoteRequest quoteRequest);

      /// <summary>
      /// Gets Usage Inteval ID
      /// </summary>
      /// <param name="quoteRequest"></param>
      /// <returns></returns>
      int GetUsageInterval(QuoteRequest quoteRequest);

      /// <summary>
      /// Removes charges from DB
      /// </summary>
      /// <param name="idQuote"></param>
      /// <param name="charges"></param>
      void CleanupUsageData(int idQuote, IEnumerable<ChargeData> charges);
    }
}
