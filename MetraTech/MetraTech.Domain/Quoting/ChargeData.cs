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

using System;
using System.Diagnostics;
using System.Runtime.Serialization;
using System.Web.Script.Serialization;
using MetraTech.DomainModel.Common;

namespace MetraTech.Domain.Quoting
{
    /// <summary>
    /// Uses as DataContract in <see cref="QuoteResponse"/>
    /// </summary>
    [DataContract]
    [Serializable]
    public class ChargeData
    {
        #region Additional Methods for DataContract
        public static ChargeData CreateInstance(ChargeType chargeType, string idBatch)
        {
            return new ChargeData{ChargeType = chargeType, IdBatch = idBatch};
        }

        [OnSerializingAttribute]
        private void OnSerialization(StreamingContext ctx)
        {
           Debug.Assert(!(this.ChargeType == ChargeType.None
               || String.IsNullOrEmpty(IdBatch)), String.Format("The ChargeType or IdBatch properties are not set in the {0} instance. Use CreateInstance method for right initialization.", typeof(ChargeType)));
        }

        #endregion Additional Methods for DataContract

        #region Charge Type

        /// <summary>
        /// Returna Charge Type <see cref="ChargeType"/>
        /// </summary>
        [MTDataMember(Description = "Charge Type")]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public ChargeType ChargeType { get; private set; }

        #endregion Charge Type

        #region Batch ID
        /// <summary>
        /// Batch ID
        /// </summary>
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private string _idBatch;
        [MTDataMember(Description = "ID Batch")]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string IdBatch { get; private set; }

        #endregion Batch ID
        
        #region Count metered records

        /// <summary>
        /// Count metered records
        /// </summary>
        [MTDataMember(Description = "Count metered records")]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int CountMeteredRecords { get; set; }

        #endregion Count metered records
    }
}
