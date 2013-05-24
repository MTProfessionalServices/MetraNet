using System;
using System.Runtime.Serialization;

using MetraTech.DomainModel.BaseTypes;
using MetraTech.ActivityServices.Common;
using System.Web.Script.Serialization;
using MetraTech.DomainModel.Common;

namespace MetraTech.DomainModel.Billing
{
    [DataContract]
    [Serializable]
    [KnownType(typeof(PriceableItemInstanceSlice))]
    [KnownType(typeof(PriceableItemTemplateSlice))]
    [KnownType(typeof(ProductViewSlice))]
    [KnownType(typeof(ProductViewAllUsageSlice))]
    public abstract class SingleProductSlice : BaseSlice
    {
        #region ViewID
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isViewIDDirty = false;
        private PCIdentifier m_ViewID;
        [MTDataMember(Description = "This is the identifier of the product view.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public PCIdentifier ViewID
        {
            get { return m_ViewID; }
            set
            {
                m_ViewID = value;
                isViewIDDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsViewIDDirty
        {
            get { return isViewIDDirty; }
        }
        #endregion

        public string ViewName()
        {
            return ViewID.Name;
        }

        #region ViewDisplayName
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isViewDisplayNameDirty = false;
        private string m_ViewDisplayName;
        [MTDataMember(Description = "This is the display name for the product view", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string ViewDisplayName
        {
            get { return m_ViewDisplayName; }
            set
            {
                m_ViewDisplayName = value;
                isViewDisplayNameDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsViewDisplayNameDirty
        {
            get { return isViewDisplayNameDirty; }
        }
        #endregion

    }
}