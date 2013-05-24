using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;
using System.Web.Script.Serialization;


namespace MetraTech.DomainModel.Billing
{
    [DataContract]
    [Serializable]
    public class PriceableItemInstanceSlice : SingleProductSlice
    {
        #region PIInstanceID
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPIInstanceIDDirty = false;
        private PCIdentifier m_PIInstanceID;
        [MTDataMember(Description = "This is the identifier of the priceable item instance.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public PCIdentifier PIInstanceID
        {
          get { return m_PIInstanceID; }
          set
          {
              m_PIInstanceID = value;
              isPIInstanceIDDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsPIInstanceIDDirty
        {
          get { return isPIInstanceIDDirty; }
        }
        #endregion

        #region POInstanceID
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPOInstanceIDDirty = false;
        private PCIdentifier m_POInstanceID;
        [MTDataMember(Description = "This is the product offering identifier.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public PCIdentifier POInstanceID
        {
          get { return m_POInstanceID; }
          set
          {
              m_POInstanceID = value;
              isPOInstanceIDDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsPOInstanceIDDirty
        {
          get { return isPOInstanceIDDirty; }
        }
        #endregion

    }
}