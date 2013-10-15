// -----------------------------------------------------------------------
// <copyright file="ICharge.cs" company="MetraTech">
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

using MetraTech.Domain.Quoting;

namespace MetraTech.Core.Services.Quoting.Charge
{
    /// <summary>
    /// Chrages for Quote
    /// </summary>
    public interface ICharge
    {
        /// <summary>
        /// Gets current charge type
        /// </summary>
        ChargeType ChargeType { get; }

      /// <summary>
      /// Adds Chrages by <see cref="MetraTech.Domain.Quoting.QuoteRequest"/> in DataBase and save result to existing <see cref="MetraTech.Domain.Quoting.QuoteResponse"/>
      /// </summary>
      /// <param name="quoteRequest">Initial state of Quote</param>
      /// <param name="batchId">generated bathc id for the charges</param>
      /// <param name="usageInterval">current usage interval</param>
      /// <returns>Metadata about added charges</returns>
      ChargeData Add(QuoteRequest quoteRequest, string batchId, int usageInterval);
    }
}
