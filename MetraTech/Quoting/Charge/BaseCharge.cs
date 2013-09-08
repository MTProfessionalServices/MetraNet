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
    /// Base class for Chrages for Quote
    /// </summary>
    public abstract class BaseCharge : ICharge
    {
        protected QuotingConfiguration Config { get; private set; }
        protected IChargeMetering Metering { get; private set; }
        protected ILogger Log { get; private set; }

        protected BaseCharge(QuotingConfiguration configuration,  IChargeMetering metering,  ILogger log)
        {
            Config = configuration;
            Metering = metering;
            Log = log;
        }

        public abstract ChargeType ChargeType { get; }

        public abstract ChargeData Add(IMTServicedConnection transacConnection, QuoteRequest quoteRequest);

    }
}
