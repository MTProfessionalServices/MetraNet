// -----------------------------------------------------------------------
// <copyright file="QuoteResponseArtefacts.cs" company="Microsoft">
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
using System.Web.Script.Serialization;
using MetraTech.DomainModel.Common;

namespace MetraTech.Domain.Quoting
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;

    /// <summary>
    /// Contains artefacts for created Quote and uses in <see cref="QuoteResponse"/> class
    /// </summary>
    [Serializable]
    public class QuoteResponseArtefacts
    {
        #region IdQuote

        /// <summary>
        /// The same field with the same value exists in <see cref="QuoteResponse"/>.
        /// The field is added for the simplify cleanup quote
        /// </summary>
        [MTDataMember(Description = "Quote Id")]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int IdQuote { get; set; }

        #endregion IdQuote

        #region IdUsageInterval

        /// <summary>
        /// ID Usege Interval
        /// </summary>
        [MTDataMember(Description = "ID Usage Interval")]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int IdUsageInterval { get; set; }

        #endregion IdUsageInterval

        #region  SubscriptionResponseData

        /// <summary>
        /// Contains Subscriptions artefacts information
        /// </summary>
        [MTDataMember(Description = "Contains artefact of created subscriptions")]
        [DataMember(IsRequired = true, EmitDefaultValue = false)]
        public SubscriptionResponseData Subscription { get; private set; }

        #endregion  SubscriptionResponseData

        #region Charges

        /// <summary>
        /// Contains charge artefacts collectons information
        /// </summary>
        [MTDataMember(Description = "Charges Colletion")]
        [DataMember(IsRequired = true, EmitDefaultValue = false)]
        public List<ChargeData> ChargesCollection { get; private set; }

        #endregion Charges

        public QuoteResponseArtefacts()
        {
            Subscription = new SubscriptionResponseData();
            ChargesCollection = new List<ChargeData>();
        }

        public QuoteResponseArtefacts(int idQuote)
            : this()
        {
            IdQuote = idQuote;
        }
    }
}
