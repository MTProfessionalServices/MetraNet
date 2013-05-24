using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.BaseTypes;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.ProductCatalog
{
    /// <summary>
    /// Object that represents an audit log entry.  The information for the
    /// audit log entry is retrieved from a single row in t_audit and the corresponding
    /// row in t_audit_details.  
    /// </summary>
    [DataContract]
    [Serializable]
    public class AuditLogEntry : BaseObject
    {
        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isOccurrenceDateDirty = false;
        private DateTime m_OccurrenceDate;

        /// <summary>
        /// Date when this audit event occurred.
        /// </summary>
        [MTDataMember(Description = "Date when audit event occurred.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DateTime OccurrenceDate
        {
            get { return m_OccurrenceDate; }
            set
            {
                m_OccurrenceDate = value;
                isOccurrenceDateDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsOccurrenceDateDirty
        {
            get { return isOccurrenceDateDirty; }
        }

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isUserNameDirty = false;
        private string m_UserName;

        /// <summary>
        /// Name of the user performing the retrieval (e.g. the CSRs login name).
        /// </summary>
        [MTDataMember(Description = "Name of the user performing the query", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string UserName
        {
            get { return m_UserName; }
            set
            {
                m_UserName = value;
                isUserNameDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsUserNameDirty
        {
            get { return isUserNameDirty; }
        }

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isUserIdDirty = false;
        private int m_UserId;

        /// <summary>
        /// Id of the user performing the query (e.g. accId of the CSR)
        /// </summary>
        [MTDataMember(Description = "Id of the user performing the query", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int UserId
        {
            get { return m_UserId; }
            set
            {
                m_UserId = value;
                isUserIdDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsUserIdDirty
        {
            get { return isUserIdDirty; }
        }

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isAuditEventTypeIdDirty = false;
        private int m_AuditEventTypeId;

        /// <summary>
        /// Id that defines the type of audit event this is 
        /// (e.g. ID associated with "Login Successful" or "CSR Notation")
        /// </summary>
        [MTDataMember(Description = "Id that defines the type of audit event this is", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int AuditEventTypeId
        {
            get { return m_AuditEventTypeId; }
            set
            {
                m_AuditEventTypeId = value;
                isAuditEventTypeIdDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsAuditEventTypeIdDirty
        {
            get { return isAuditEventTypeIdDirty; }
        }

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isAuditEventTypeDirty = false;
        private string m_AuditEventType;

        /// <summary>
        /// String representation of the type of audit event this is 
        /// (e.g. "Login Successful" or "CSR Notation")
        /// </summary>
        [MTDataMember(Description = "String representation of the type of audit event this is", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string AuditEventType
        {
            get { return m_AuditEventType; }
            set
            {
                m_AuditEventType = value;
                isAuditEventTypeDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsAuditEventTypeDirty
        {
            get { return isAuditEventTypeDirty; }
        }

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isEntityNameDirty = false;
        private string m_EntityName;

        /// <summary>
        /// Entity that the audit event applies to
        /// </summary>
        [MTDataMember(Description = "Entity that the audit event applies to", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string EntityName
        {
            get { return m_EntityName; }
            set
            {
                m_EntityName = value;
                isEntityNameDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsEntityNameDirty
        {
            get { return isEntityNameDirty; }
        }

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isEntityIdDirty = false;
        private int m_EntityId;

        /// <summary>
        /// Id of the entity that the audit event applies to 
        /// (e.g. the id_acc of account that the audit event applies to)
        /// </summary>
        [MTDataMember(Description = "Id of the entity that the audit event applies to", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int EntityId
        {
            get { return m_EntityId; }
            set
            {
                m_EntityId = value;
                isEntityIdDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsEntityIdDirty
        {
            get { return isEntityIdDirty; }
        }

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isEntityTypeDirty = false;
        private int m_EntityType;

        /// <summary>
        /// Type of entity that the audit event applies to 
        /// </summary>
        [MTDataMember(Description = "Type of entity that the audit event applies to", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int EntityType
        {
            get { return m_EntityType; }
            set
            {
                m_EntityType = value;
                isEntityTypeDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsEntityTypeDirty
        {
            get { return isEntityTypeDirty; }
        }

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isAuditDetailDirty = false;
        private string m_AuditDetail;

        /// <summary>
        /// Freeform text describing the audited event
        /// </summary>
        [MTDataMember(Description = "Freeform text describing the audited event", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string AuditDetail
        {
            get { return m_AuditDetail; }
            set
            {
                m_AuditDetail = value;
                isAuditDetailDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsAuditDetailDirty
        {
            get { return isAuditDetailDirty; }
        }

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isLoggedInAsDirty = false;
        private string m_LoggedInAs;

        /// <summary>
        /// Logged In As
        /// </summary>
        [MTDataMember(Description = "Logged In As", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string LoggedInAs
        {
            get { return m_LoggedInAs; }
            set
            {
                m_LoggedInAs = value;
                isLoggedInAsDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsLoggedInAsDirty
        {
            get { return isLoggedInAsDirty; }
        }

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isApplicationNameDirty = false;
        private string m_ApplicationName;

        /// <summary>
        /// Application Name
        /// </summary>
        [MTDataMember(Description = "Logged In As", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string ApplicationName
        {
            get { return m_ApplicationName; }
            set
            {
                m_ApplicationName = value;
                isApplicationNameDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsApplicationNameDirty
        {
            get { return isApplicationNameDirty; }
        }

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isAuditIdDirty = false;
        private int m_AuditId;

        /// <summary>
        /// Unique ID assigned to this audit event
        /// </summary>
        [MTDataMember(Description = "Unique ID assigned to this audit event", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int AuditId
        {
            get { return m_AuditId; }
            set
            {
                m_AuditId = value;
                isAuditIdDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsAuditIdDirty
        {
            get { return isAuditIdDirty; }
        }
    }
}
