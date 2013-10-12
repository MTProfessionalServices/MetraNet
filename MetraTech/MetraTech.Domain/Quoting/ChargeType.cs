// -----------------------------------------------------------------------
// <copyright file="ChargeType.cs" company="MetraTech">
// **************************************************************************
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
// ***************************************************************************/
// </copyright>
// -----------------------------------------------------------------------

using System;
using System.Runtime.Serialization;

namespace MetraTech.Domain.Quoting
{
    /// <summary>
    /// Chrage type
    /// </summary>
    [DataContract]
    [Serializable]
    public enum ChargeType
    {
        [EnumMember]
        None = 0,
        [EnumMember]
        RecurringCharge = 1,
        [EnumMember]
        NonRecurringCharge = 2,
        [EnumMember]
        UDRCTiered = 3,
        [EnumMember]
        UDRCTapered = 4
    }
}
