// -----------------------------------------------------------------------
// <copyright file="IChargeMetering.cs" company="Microsoft">
// **************************************************************************
// Copyright 2011 by MetraTech
// All rights reserved.
//
// THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
// REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
// example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
// WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
// OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
// INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
// RIGHTS.
//
// Title to copyright in this software and any associated
// documentation shall at all times remain with MetraTech, and USER
// agrees to preserve the same.
//
//
// $Header$
// 
// ***************************************************************************/
// </copyright>
// -----------------------------------------------------------------------

using MetraTech.DataAccess;

namespace MetraTech.Quoting
{
    using System.Collections.Generic;
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
      /// <param name="quoteRequest"></param>
      /// <returns></returns>
      IList<ChargeData> AddCharges(QuoteRequest quoteRequest);

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
