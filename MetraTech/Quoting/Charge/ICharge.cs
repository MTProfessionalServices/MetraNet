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

using MetraTech.DataAccess;
using MetraTech.Domain.Quoting;

namespace MetraTech.Quoting.Charge
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;

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
        /// <param name="transacConnection">uses connection to add charges. The connection should be in transaction scope, to have posibility to revert changes</param>
        /// <param name="quoteRequest">Initial state of Quote</param>
        /// <returns>Metadata about added charges</returns>
        ChargeData Add(IMTServicedConnection transacConnection, QuoteRequest quoteRequest);
    }
}
