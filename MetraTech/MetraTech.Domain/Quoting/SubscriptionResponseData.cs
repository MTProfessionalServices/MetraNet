// -----------------------------------------------------------------------
// <copyright file="SubscriptionResponseData.cs" company="Microsoft">
//
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
// </copyright>
// -----------------------------------------------------------------------

using System.Runtime.Serialization;
using MetraTech.DomainModel.Common;

namespace MetraTech.Domain.Quoting
{
    using System.Collections.Generic;

    /// <summary>
    /// Uses in <see cref="QuoteResponse"/> class as data for created subscriptions while quots generations 
    /// </summary>
    public class SubscriptionResponseData
    {
        #region IsGroupSubcription

        /// <summary>
        /// Whether it's group subscription or not 
        /// </summary>
        [MTDataMember(Description = "Is it group subscription or not")]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public bool IsGroupSubcription { get; private set; }

        #endregion IsGroupSubcription

        #region SubscriptionsCollection

        [MTDataMember(Description = "Subscriptions data colletion")]
        [DataMember(IsRequired = true, EmitDefaultValue = false)]
        public List<PairKeyValueSerializable<int, List<int>>> SubscriptionsCollection { get; private set; }

        #endregion SubscriptionsCollection

        public SubscriptionResponseData()
        {
            SubscriptionsCollection = new List<PairKeyValueSerializable<int, List<int>>>();
        }
    }
}
