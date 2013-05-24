using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.BaseTypes;

namespace MetraTech.DomainModel.ProductCatalog
{
    [DataContract]
    [Serializable]
    public class Counter : BaseObject
    {
        #region Name
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isNameDirty = false;
        private string m_Name;
        [MTDataMember(Description = "This is the name for Counter", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string Name
        {
            get { return m_Name; }
            set
            {
                m_Name = value;
                isNameDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsNameDirty
        {
            get { return isNameDirty; }
        }
        #endregion

        

    }
}
