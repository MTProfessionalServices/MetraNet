using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;
using MetraTech.DomainModel.Common;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.Billing
{
    [Serializable]
    [DataContract]
    public class ReportFile
    {
        #region FileName
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isFileNameDirty = false;
        private string m_FileName;
        [MTDataMember(Description = "This is the name of the report file on the reporting server", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string FileName
        {
            get { return m_FileName; }
            set
            {
                m_FileName = value;
                isFileNameDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsFileNameDirty
        {
            get { return isFileNameDirty; }
        }
        #endregion

        #region DisplayName
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isDisplayNameDirty = false;
        private string m_DisplayName;
        [MTDataMember(Description = "This is the display name for the report", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string DisplayName
        {
            get { return m_DisplayName; }
            set
            {
                m_DisplayName = value;
                isDisplayNameDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsDisplayNameDirty
        {
            get { return isDisplayNameDirty; }
        }
        #endregion
    }
}
