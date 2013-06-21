using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accounttemplate;
using MetraTech.DomainModel.BaseTypes;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.ProductCatalog
{
    [Serializable]
    [DataContract]
    public class AccountTemplateSession : BaseObject
    {
        #region SessionId
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isSessionIdDirty = false;
        private int m_SessionId;
        [MTDataMember(Description = "The identifier of the account template session", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int SessionId
        {
            get { return m_SessionId; }
            set
            {
                m_SessionId = value;
                isSessionIdDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsSessionIdDirty
        {
            get { return isSessionIdDirty; }
        }
        #endregion

        #region TemplateOwnerId
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isTemplateOwnerIdDirty = false;
        private int m_TemplateOwnerId;
        [MTDataMember(Description = "The account ID of account that owns the template being applied", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int TemplateOwnerId
        {
            get { return m_TemplateOwnerId; }
            set
            {
                m_TemplateOwnerId = value;
                isTemplateOwnerIdDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsTemplateOwnerIdDirty
        {
            get { return isTemplateOwnerIdDirty; }
        }
        #endregion

        #region TemplateOwnerName
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isTemplateOwnerNameDirty = false;
        private string m_TemplateOwnerName;
        [MTDataMember(Description = "The name of the account that owns the template being applied", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string TemplateOwnerName
        {
            get { return m_TemplateOwnerName; }
            set
            {
                m_TemplateOwnerName = value;
                isTemplateOwnerNameDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsTemplateOwnerNameDirty
        {
            get { return isTemplateOwnerNameDirty; }
        }
        #endregion

        #region AccountType
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAccountTypeDirty = false;
        private string m_AccountType;
        [MTDataMember(Description = "The account type to which the template is being applied", Length = 40)]
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

        #region SubmissionDate
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isSubmissionDateDirty = false;
        private DateTime m_SubmissionDate;
        [MTDataMember(Description = "The date/time the template application request was received", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DateTime SubmissionDate
        {
            get { return m_SubmissionDate; }
            set
            {
                m_SubmissionDate = value;
                isSubmissionDateDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsSubmissionDateDirty
        {
            get { return isSubmissionDateDirty; }
        }
        #endregion

        #region SubmitterID
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isSubmitterIDDirty = false;
        private int m_SubmitterID;
        [MTDataMember(Description = "The account ID of the account that submitted the template application request", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int SubmitterID
        {
            get { return m_SubmitterID; }
            set
            {
                m_SubmitterID = value;
                isSubmitterIDDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsSubmitterIDDirty
        {
            get { return isSubmitterIDDirty; }
        }
        #endregion

        #region SubmitterName
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isSubmitterNameDirty = false;
        private string m_SubmitterName;
        [MTDataMember(Description = "The name of the account that submitted the template application request", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string SubmitterName
        {
            get { return m_SubmitterName; }
            set
            {
                m_SubmitterName = value;
                isSubmitterNameDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsSubmitterNameDirty
        {
            get { return isSubmitterNameDirty; }
        }
        #endregion

        #region ServerName
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isServerNameDirty = false;
        private string m_ServerName;
        [MTDataMember(Description = "The name of the server that received and is processing the request", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string ServerName
        {
            get { return m_ServerName; }
            set
            {
                m_ServerName = value;
                isServerNameDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsServerNameDirty
        {
            get { return isServerNameDirty; }
        }
        #endregion

        #region Status
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isStatusDirty = false;
        private TemplateStatus m_Status;
        [MTDataMember(Description = "This is the current status of the template application request", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public TemplateStatus Status
        {
            get { return m_Status; }
            set
            {
                m_Status = value;
                isStatusDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsStatusDirty
        {
            get { return isStatusDirty; }
        }
        #endregion

        #region Status Value Display Name
        public string StatusValueDisplayName
        {
            get
            {
                return GetDisplayName(this.Status);
            }
            set
            {
                this.Status = ((TemplateStatus)(GetEnumInstanceByDisplayName(typeof(TemplateStatus), value)));
            }
        }
        #endregion

        #region NumAccounts
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isNumAccountsDirty = false;
        private int m_NumAccounts;
        [MTDataMember(Description = "This is the number of accounts to which the template is being applied", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int NumAccounts
        {
            get { return m_NumAccounts; }
            set
            {
                m_NumAccounts = value;
                isNumAccountsDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsNumAccountsDirty
        {
            get { return isNumAccountsDirty; }
        }
        #endregion

        #region NumAccountsCompleted
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isNumAccountsCompletedDirty = false;
        private int m_NumAccountsCompleted;
        [MTDataMember(Description = "This is the number of account update request that have completed", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int NumAccountsCompleted
        {
            get { return m_NumAccountsCompleted; }
            set
            {
                m_NumAccountsCompleted = value;
                isNumAccountsCompletedDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsNumAccountsCompletedDirty
        {
            get { return isNumAccountsCompletedDirty; }
        }
        #endregion

        #region NumAccountErrors
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isNumAccountErrorsDirty = false;
        private int m_NumAccountErrors;
        [MTDataMember(Description = "This is the number of account updates that failed", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int NumAccountErrors
        {
            get { return m_NumAccountErrors; }
            set
            {
                m_NumAccountErrors = value;
                isNumAccountErrorsDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsNumAccountErrorsDirty
        {
            get { return isNumAccountErrorsDirty; }
        }
        #endregion

        #region NumSubscriptions
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isNumSubscriptionsDirty = false;
        private int m_NumSubscriptions;
        [MTDataMember(Description = "This is the number of groups subscriptions or product offerings to which the accounts are to be subscribed", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int NumSubscriptions
        {
            get { return m_NumSubscriptions; }
            set
            {
                m_NumSubscriptions = value;
                isNumSubscriptionsDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsNumSubscriptionsDirty
        {
            get { return isNumSubscriptionsDirty; }
        }
        #endregion

        #region NumSubscriptionsCompleted
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isNumSubscriptionsCompletedDirty = false;
        private int m_NumSubscriptionsCompleted;
        [MTDataMember(Description = "This is the number of subscriptions that have been completed", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int NumSubscriptionsCompleted
        {
            get { return m_NumSubscriptionsCompleted; }
            set
            {
                m_NumSubscriptionsCompleted = value;
                isNumSubscriptionsCompletedDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsNumSubscriptionsCompletedDirty
        {
            get { return isNumSubscriptionsCompletedDirty; }
        }
        #endregion

        #region NumSubscriptionErrors
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isNumSubscriptionErrorsDirty = false;
        private int m_NumSubscriptionErrors;
        [MTDataMember(Description = "This is the number of subscriptions that failed to apply", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int NumSubscriptionErrors
        {
            get { return m_NumSubscriptionErrors; }
            set
            {
                m_NumSubscriptionErrors = value;
                isNumSubscriptionErrorsDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsNumSubscriptionErrorsDirty
        {
            get { return isNumSubscriptionErrorsDirty; }
        }
        #endregion

        #region NumRetries
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isNumRetriesDirty = false;
        private int m_NumRetries;
        [MTDataMember(Description = "This is the number of times the template aplication has been re-tried.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int NumRetries
        {
            get { return m_NumRetries; }
            set
            {
                m_NumRetries = value;
                isNumRetriesDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsNumRetriesDirty
        {
            get { return isNumRetriesDirty; }
        }
        #endregion

        #region NumTemplates

        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private int m_NumTemplates;
        private bool m_IsNumTemplatesDirty;
        [MTDataMember(Description = "This is the number of the templates applied in the session.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int NumTemplates
        {
            get
            {
                return m_NumTemplates;
            }
            set
            {
                m_NumTemplates = value;
                m_IsNumTemplatesDirty = false;
            }
        }

        [ScriptIgnore]
        public bool IsNumTemplatesDirty
        {
            get
            {
                return m_IsNumTemplatesDirty;
            }
        }

        #endregion

        #region NumTemplatesApplied

        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private int m_NumTemplatesApplied;
        private bool m_IsNumTemplatesAppliedDirty;
        [MTDataMember(Description = "This is the number of the templates applied in the session.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int NumTemplatesApplied
        {
            get
            {
                return m_NumTemplatesApplied;
            }
            set
            {
                m_NumTemplatesApplied = value;
                m_IsNumTemplatesAppliedDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsNumTemplatesAppliedDirty
        {
            get
            {
                return m_IsNumTemplatesAppliedDirty;
            }
        }

        #endregion
    }

    [Serializable]
    [DataContract]
    public class AccountTemplateSessionDetail : BaseObject
    {
        #region DetailId
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isDetailIdDirty = false;
        private int m_DetailId;
        [MTDataMember(Description = "Unique identifier for the account template session detail", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int DetailId
        {
            get { return m_DetailId; }
            set
            {
                m_DetailId = value;
                isDetailIdDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsDetailIdDirty
        {
            get { return isDetailIdDirty; }
        }
        #endregion

        #region SequenceId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSequenceIdDirty = false;
    private int m_SequenceId;
    [MTDataMember(Description = "This is a auto-generated sequence number for ordering", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int SequenceId
    {
      get { return m_SequenceId; }
      set
      {
          m_SequenceId = value;
          isSequenceIdDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSequenceIdDirty
    {
      get { return isSequenceIdDirty; }
    }
    #endregion

        #region SessionId
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isSessionIdDirty = false;
        private int m_SessionId;
        [MTDataMember(Description = "This is the identifier of the session to which this detail belongs", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int SessionId
        {
            get { return m_SessionId; }
            set
            {
                m_SessionId = value;
                isSessionIdDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsSessionIdDirty
        {
            get { return isSessionIdDirty; }
        }
        #endregion

        #region Type
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isTypeDirty = false;
        private DetailType m_Type;
        [MTDataMember(Description = "Specifies the type of the detail record", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DetailType Type
        {
            get { return m_Type; }
            set
            {
                m_Type = value;
                isTypeDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsTypeDirty
        {
            get { return isTypeDirty; }
        }
        #endregion

        #region Type Value Display Name
        public string TypeValueDisplayName
        {
            get
            {
                return GetDisplayName(this.Type);
            }
            set
            {
                this.Type = ((DetailType)(GetEnumInstanceByDisplayName(typeof(DetailType), value)));
            }
        }
        #endregion

        #region Result
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isResultDirty = false;
        private DetailResult m_Result;
        [MTDataMember(Description = "Specifies the result of the operation the detail record represents", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DetailResult Result
        {
            get { return m_Result; }
            set
            {
                m_Result = value;
                isResultDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsResultDirty
        {
            get { return isResultDirty; }
        }
        #endregion

        #region Result Value Display Name
        public string ResultValueDisplayName
        {
            get
            {
                return GetDisplayName(this.Result);
            }
            set
            {
                this.Result = ((DetailResult)(GetEnumInstanceByDisplayName(typeof(DetailResult), value)));
            }
        }
        #endregion

        #region DetailDate
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isDetailDateDirty = false;
        private DateTime m_DetailDate;
        [MTDataMember(Description = "Date/Time of the detail event", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DateTime DetailDate
        {
            get { return m_DetailDate; }
            set
            {
                m_DetailDate = value;
                isDetailDateDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsDetailDateDirty
        {
            get { return isDetailDateDirty; }
        }
        #endregion

        #region Detail
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isDetailDirty = false;
        private string m_Detail;
        [MTDataMember(Description = "The text of the detail record", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string Detail
        {
            get { return m_Detail; }
            set
            {
                m_Detail = value;
                isDetailDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsDetailDirty
        {
            get { return isDetailDirty; }
        }
        #endregion

        #region NumRetries
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isNumRetriesDirty = false;
        private int m_NumRetries;
        [MTDataMember(Description = "This is the number of times the template aplication has been re-tried.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int NumRetries
        {
            get { return m_NumRetries; }
            set
            {
                m_NumRetries = value;
                isNumRetriesDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsNumRetriesDirty
        {
            get { return isNumRetriesDirty; }
        }
        #endregion
    }

}