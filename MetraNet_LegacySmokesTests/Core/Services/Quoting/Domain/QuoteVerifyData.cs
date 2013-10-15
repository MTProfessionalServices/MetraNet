// -----------------------------------------------------------------------
// <copyright file="QuoteVerifyData.cs" company="Microsoft">
//
// Copyright 2013 by MetraTech
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
// </copyright>
// -----------------------------------------------------------------------

namespace MetraTech.Core.Services.Test.Quoting.Domain
{
  /// <summary>
    /// Uses in test for verifying 
    /// </summary>
    public class QuoteVerifyData
    {
        public int CountAccounts { get; set; }
        public int CountProducts { get; set; }
        public int CountHeaders { get; set; }
        public int CountContents { get; set; }
        public decimal Total { get; set; }
        public decimal TotalForUDRCs { get; set; }
        public string Currency { get; set; }
        public int CountFlatRCs { get; set; }
        public int CountNRCs { get; set; }
        public int? CountUDRCs { get; set; }

        public QuoteVerifyData()
        {
            Currency = "USD";
        }
    }
}
