// -----------------------------------------------------------------------
// <copyright file="SubscriptionResponseData.cs" company="Microsoft">
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

using System;
using System.Collections;
using System.Runtime.Serialization;
using System.Xml.Serialization;
using MetraTech.DomainModel.Common;

namespace MetraTech.Domain.Quoting
{
    using System.Collections.Generic;

    /// <summary>
    /// Uses in <see cref="QuoteResponse"/> class as data for created subscriptions while quots generations 
    /// </summary>
    [Serializable]
    [XmlRoot("Subscriptions")]
    public class SubscriptionResponseData : IEnumerable<PairKeyValueSerializable<int, List<int>>>
    {
        #region IsGroupSubcription

        /// <summary>
        /// Whether it's group subscription or not 
        /// </summary>
        [MTDataMember(Description = "Is it group subscription or not")]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public bool IsGroupSubcription { get; private set; }

        public void SetIsGroupSubscriptionType(bool isGroupSubscription)
        {
            IsGroupSubcription = isGroupSubscription;
        }

        #endregion IsGroupSubcription

        #region Subscription Collection
        [XmlArray(ElementName = "Collection")]
        [XmlArrayItem(typeof(int),
            ElementName = "IdSubscription"),
         XmlArrayItem(typeof(List<int>),
             ElementName = "SubscribedAccounts")]
        [MTDataMember(Description = "Contains subscription, where Key - ID subscription and value - list of Subscribed ID accounts. If IsGroupSubcription == true that meand that Key contains 'Group Subscription Id'")]
        [DataMember(IsRequired = true, EmitDefaultValue = false)]
        public List<PairKeyValueSerializable<int, List<int>>> Collection { get; private set; }


        public void AddSubscriptions(int idSubscription, List<int> idSubscribedAccounts)
        {
            Collection.Add(new PairKeyValueSerializable<int, List<int>>(idSubscription, idSubscribedAccounts));
        }

        public List<int> this[int idSubscription]
        {
            get
            {
                return Collection[idSubscription].Value;
            }
        }

        #endregion Subscription Collection

        public SubscriptionResponseData()
        {
            Collection = new List<PairKeyValueSerializable<int, List<int>>>();
        }

        public SubscriptionResponseData(QuoteRequest request)
            : this()
        {
            IsGroupSubcription = request.SubscriptionParameters.IsGroupSubscription;
        }

        #region IEnumerable Members

        public IEnumerator<PairKeyValueSerializable<int, List<int>>> GetEnumerator()
        {
            return Collection.GetEnumerator();
        }

        IEnumerator IEnumerable.GetEnumerator()
        {
            return GetEnumerator();
        }

        #endregion
    }
}
