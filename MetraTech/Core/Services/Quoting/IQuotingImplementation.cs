// -----------------------------------------------------------------------
// <copyright file="ILogger.cs" company="MetraTech">
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


using System.Collections.Generic;
using MetraTech.Domain.Quoting;

namespace MetraTech.Core.Services.Quoting
{
  /// <summary>
    /// Interface for quote creation
    /// </summary>
    public interface IQuotingImplementation
    {
        /// <summary>
        /// Gets quote configuration data
        /// </summary>
        QuotingConfiguration Configuration { get; }

        /// <summary>
        /// Gets <see cref="QuotingRepository"/>
        /// </summary>
        IQuotingRepository QuotingRepository { get; }

        /// <summary>
        /// Creates quote anf if <see cref="QuotingConfiguration.IsCleanupQuoteAutomaticaly"/> = true the Cleanup() will be call automaticaly.
        /// </summary>
        /// <param name="quoteRequest">data for initialization and creation quote<see cref="QuoteRequest"/></param>
        /// <returns>response of creation quote <see cref="QuoteResponse"/></returns>
        QuoteResponse CreateQuote(QuoteRequest quoteRequest);

        /// <summary>
        /// Cleanups quote artefacts in case it was not cleanedup in CreateQuote() method, because <see cref="QuotingConfiguration.IsCleanupQuoteAutomaticaly"/> = false.
        /// The method uses in fuctional tests and can be used by integrators.
        /// </summary>
        /// <param name="quoteArtefact"></param>
        /// <returns>Logging collection info which can contains posible suppressed exceptions. The exception is suppressed due to we need perform cleanup for all subscriptions</returns>
        List<QuoteLogRecord> Cleanup(QuoteResponseArtefacts quoteArtefact);
    }
}
