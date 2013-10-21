// -----------------------------------------------------------------------
// <copyright file="ChargeMeteringException.cs" company="Microsoft">
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

using System;
using System.Collections.Generic;
using MetraTech.Domain.Quoting;

namespace MetraTech.Core.Services.Quoting
{
  /// <summary>
    /// Exceptions for ChargeMetering
    /// </summary>
    public class ChargeMeteringException : Exception{
        
        public ChargeMeteringException(string errorMessage, Exception ex) :
            base(errorMessage, ex){}

        public ChargeMeteringException(string errorMessage)
            : base(errorMessage) { }
    }

    /// <summary>
    /// Raise the exception in case Charges were added, but not mettered 
    /// </summary>
    public class AddChargeMeteringException : Exception
    {
        public IList<ChargeData> ChargeDataCollection { get; private set; }
        public AddChargeMeteringException(IList<ChargeData> chargeDayaCollection, string errorMessage, Exception ex)
            : base(errorMessage, ex)
        {
            ChargeDataCollection = chargeDayaCollection;
        }
    }
}
