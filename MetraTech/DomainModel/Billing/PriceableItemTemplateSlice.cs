using System;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.ActivityServices.Common;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.Billing
{
    [DataContract]
    [Serializable]
    public class PriceableItemTemplateSlice : SingleProductSlice
    {
        #region PITemplateID
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPITemplateIDDirty = false;
        private PCIdentifier m_PITemplateID;
        [MTDataMember(Description = "This is the priceable item template identifier.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public PCIdentifier PITemplateID
        {
          get { return m_PITemplateID; }
          set
          {
              m_PITemplateID = value;
              isPITemplateIDDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsPITemplateIDDirty
        {
          get { return isPITemplateIDDirty; }
        }
        #endregion
    }
}