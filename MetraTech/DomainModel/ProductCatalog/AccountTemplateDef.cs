using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.BaseTypes;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.ProductCatalog
{
    [Serializable]
    [DataContract]
    public class AccountTemplateDef : BaseObject
    {
        #region TemplateId
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isTemplateIdDirty = false;
        private int m_TemplateId;
        [MTDataMember(Description = "This is the internal identifier of the template", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int TemplateId
        {
            get { return m_TemplateId; }
            set
            {
                m_TemplateId = value;
                isTemplateIdDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsTemplateIdDirty
        {
            get { return isTemplateIdDirty; }
        }
        #endregion

        #region AccountType
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAccountTypeDirty = false;
        private string m_AccountType;
        [MTDataMember(Description = "Specifies the account type to which the template applies", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string AccountType
        {
            get { return m_AccountType; }
            set
            {
                m_AccountType = value;
                isAccountTypeDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsAccountTypeDirty
        {
            get { return isAccountTypeDirty; }
        }
        #endregion

        #region CreationDate
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isCreationDateDirty = false;
        private DateTime m_CreationDate;
        [MTDataMember(Description = "Specifies the date/time the template was created", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DateTime CreationDate
        {
            get { return m_CreationDate; }
            set
            {
                m_CreationDate = value;
                isCreationDateDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsCreationDateDirty
        {
            get { return isCreationDateDirty; }
        }
        #endregion

        #region TemplateName
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isTemplateNameDirty = false;
        private string m_TemplateName;
        [MTDataMember(Description = "This is the user specified name of the template", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string TemplateName
        {
            get { return m_TemplateName; }
            set
            {
                m_TemplateName = value;
                isTemplateNameDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsTemplateNameDirty
        {
            get { return isTemplateNameDirty; }
        }
        #endregion

        #region TemplateDescription
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isTemplateDescriptionDirty = false;
        private string m_TemplateDescription;
        [MTDataMember(Description = "This is the user specified description of the template", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string TemplateDescription
        {
            get { return m_TemplateDescription; }
            set
            {
                m_TemplateDescription = value;
                isTemplateDescriptionDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsTemplateDescriptionDirty
        {
            get { return isTemplateDescriptionDirty; }
        }
        #endregion
    }
}
