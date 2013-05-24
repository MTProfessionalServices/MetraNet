using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.BaseTypes
{
    [DataContract]
    [Serializable]
    public class TaxData : TaxAdjustments
    {
        #region TaxAmount
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isTaxAmountDirty = false;
        private decimal m_TaxAmount;
        [MTDataMember(Description = "This is the amount of tax.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal TaxAmount
        {
          get { return m_TaxAmount; }
          set
          {
              m_TaxAmount = value;
              isTaxAmountDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsTaxAmountDirty
        {
          get { return isTaxAmountDirty; }
        }
        #endregion

        #region TaxAmountAsString
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isTaxAmountAsStringDirty = false;
        private string m_TaxAmountAsString;
        [MTDataMember(Description = "This is the text representation of the tax amount.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string TaxAmountAsString
        {
          get { return m_TaxAmountAsString; }
          set
          {
              m_TaxAmountAsString = value;
              isTaxAmountAsStringDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsTaxAmountAsStringDirty
        {
          get { return isTaxAmountAsStringDirty; }
        }
        #endregion
    }

}