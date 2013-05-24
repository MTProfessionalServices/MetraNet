using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;
using System.Web.Script.Serialization;


namespace MetraTech.DomainModel.BaseTypes
{
    [DataContract]
    [Serializable]
    public enum ChangeState
    {
        [EnumMember]
        Pending,
        [EnumMember]
        ApprovedWaitingToBeApplied,
        [EnumMember]
        FailedToApply,
        [EnumMember]
        Applied,
        [EnumMember]
        Dismissed
    };

    [DataContract]
    [Serializable]
    [Guid("154A3944-D231-441A-ACF7-22AB23783754")]
    [ComVisible(true)]
    public class ChangeSummary : BaseObject
    {

        #region Id
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isIdDirty = false;
        private int m_Id;
        [MTDataMember(Description = "This is the Approval ID", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int Id
        {
            get { return m_Id; }
            set
            {
                m_Id = value;
                isIdDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsIdDirty
        {
            get { return isIdDirty; }
        }
        #endregion

        #region SubmittedDate
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isSubmittedDateDirty = false;
        private DateTime m_SubmittedDate;
        [MTDataMember(Description = "This the Approval Creation Date.", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DateTime SubmittedDate
        {
            get { return m_SubmittedDate; }
            set
            {
                m_SubmittedDate = value;
                isSubmittedDateDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsSubmittedDateDirty
        {
            get { return isSubmittedDateDirty; }
        }
        #endregion

        #region SubmitterId
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isSubmitterIdDirty = false;
        private int m_SubmitterId;
        [MTDataMember(Description = "This is the Approval Requester", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int SubmitterId
        {
            get { return m_SubmitterId; }
            set
            {
                m_SubmitterId = value;
                isSubmitterIdDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsSubmitterIdDirty
        {
            get { return isSubmitterIdDirty; }
        }
        #endregion

        #region ApproverId
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isApproverIdDirty = false;
        private int m_ApproverId;
        [MTDataMember(Description = "This is the Approval Requester", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int ApproverId
        {
            get { return m_ApproverId; }
            set
            {
                m_ApproverId = value;
                isApproverIdDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsApproverIdDirty
        {
            get { return isApproverIdDirty; }
        }
        #endregion

        #region SubmitterDisplayName
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isSubmitterDisplayNameDirty = false;
        private string m_SubmitterDisplayName;
        [MTDataMember(Description = "This is Approval Item DisplayName.", Length = 100)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string SubmitterDisplayName
        {
            get { return m_SubmitterDisplayName; }
            set
            {
                m_SubmitterDisplayName = value;
                isSubmitterDisplayNameDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsSubmitterDisplayNameDirty
        {
            get { return isSubmitterDisplayNameDirty; }
        }
        #endregion

        #region ApproverDisplayName
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isApproverDisplayNameDirty = false;
        private string m_ApproverDisplayName;
        [MTDataMember(Description = "This is Approval Item DisplayName.", Length = 100)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string ApproverDisplayName
        {
            get { return m_ApproverDisplayName; }
            set
            {
                m_ApproverDisplayName = value;
                isApproverDisplayNameDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsApproverDisplayNameDirty
        {
            get { return isApproverDisplayNameDirty; }
        }
        #endregion

        #region ChangeType
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isChangeTypeDirty = false;
        private string m_ChangeType;
        [MTDataMember(Description = "This is Approval Item Type whether account update or rate update or so on...", Length = 100)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string ChangeType
        {
            get { return m_ChangeType; }
            set
            {
                m_ChangeType = value;
                isChangeTypeDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsChangeTypeDirty
        {
            get { return isChangeTypeDirty; }
        }
        #endregion

        #region ChangeTypeDisplayName
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isChangeTypeDisplayNameDirty = false;
        private string m_ChangeTypeDisplayName;
        [MTDataMember(Description = "This is Approval Item Type whether account update or rate update or so on...", Length = 100)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string ChangeTypeDisplayName
        {
            get { return m_ChangeTypeDisplayName; }
            set
            {
                m_ChangeTypeDisplayName = value;
                isChangeTypeDisplayNameDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsChangeTypeDisplayNameDirty
        {
            get { return isChangeTypeDisplayNameDirty; }
        }
        #endregion

        #region UniqueItemId
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isUniqueItemIdDirty = false;
        private string m_UniqueItemId;
        [MTDataMember(Description = "This is Approval Item Type whether account update or rate update or so on...", Length = 100)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string UniqueItemId
        {
            get { return m_UniqueItemId; }
            set
            {
                m_UniqueItemId = value;
                isUniqueItemIdDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsUniqueItemIdDirty
        {
            get { return isUniqueItemIdDirty; }
        }
        #endregion

        #region ChangeApproverID
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isChangeApproverIDDirty = false;
        private int m_ChangeApproverID;
        [MTDataMember(Description = "This is the Approval Approver", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int ChangeApproverID
        {
            get { return m_ChangeApproverID; }
            set
            {
                m_ChangeApproverID = value;
                isChangeApproverIDDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsChangeApproverIDDirty
        {
            get { return isChangeApproverIDDirty; }
        }
        #endregion
        
        #region ChangeLastModifiedDate
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isChangeLastModifiedDateDirty = false;
        private DateTime m_ChangeLastModifiedDate;
        [MTDataMember(Description = "This the time the change or its state was last modified. Call GetChangeHistory on the approval service for more details.", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DateTime ChangeLastModifiedDate
        {
            get { return m_ChangeLastModifiedDate; }
            set
            {
                m_ChangeLastModifiedDate = value;
                isChangeLastModifiedDateDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsChangeLastModifiedDateDirty
        {
            get { return isChangeLastModifiedDateDirty; }
        }
        #endregion

        #region ItemDisplayName
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isItemDisplayNameDirty = false;
        private string m_ItemDisplayName;
        [MTDataMember(Description = "This is Approval Item DisplayName.", Length = 100)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string ItemDisplayName
        {
            get { return m_ItemDisplayName; }
            set
            {
                m_ItemDisplayName = value;
                isItemDisplayNameDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsItemDisplayNameDirty
        {
            get { return isItemDisplayNameDirty; }
        }
        #endregion

        #region Comment
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isCommentDirty = false;
        private string m_Comment;
        [MTDataMember(Description = "This is Approval Item Change Comment.", Length = 100)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string Comment
        {
            get { return m_Comment; }
            set
            {
                m_Comment = value;
                isCommentDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsCommentDirty
        {
            get { return isCommentDirty; }
        }
        #endregion

        #region CurrentState
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isCurrentStateDirty = false;
        private ChangeState m_CurrentState;
        [MTDataMember(Description = "This is Approval Item Status like Pending Approval, Denied, Deleted etc...", Length = 100)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public ChangeState CurrentState
        {
            get { return m_CurrentState; }
            set
            {
                m_CurrentState = value;
                isCurrentStateDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsCurrentStateDirty
        {
            get { return isCurrentStateDirty; }
        }
        #endregion

        #region CurrentStateDisplayName
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isCurrentStateDisplayNameDirty = false;
        private string m_CurrentStateDisplayName;
        [MTDataMember(Description = "This is Approval Item Status like Pending Approval, Denied, Deleted etc...", Length = 100)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string CurrentStateDisplayName
        {
            get { return m_CurrentStateDisplayName; }
            set
            {
                m_CurrentStateDisplayName = value;
                isCurrentStateDisplayNameDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsCurrentStateDisplayNameDirty
        {
            get { return isCurrentStateDisplayNameDirty; }
        }
        #endregion
       }

    [DataContract]
    [Serializable]
    public class Change : ChangeSummary
    {
        //public string ChangeDetailsBlob { get; set; }

        #region ChangeDetailsBlob
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isChangeDetailsBlobDirty = false;
        private string m_ChangeDetailsBlob;
        [MTDataMember(Description = "This is Approval Item DisplayName.", Length = 100)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string ChangeDetailsBlob
        {
            get { return m_ChangeDetailsBlob; }
            set
            {
                m_ChangeDetailsBlob = value;
                isChangeDetailsBlobDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsChangeDetailsBlobDirty
        {
            get { return isChangeDetailsBlobDirty; }
        }
        #endregion

        }

    [DataContract]
    [Serializable]
    public class ChangeHistoryItem : BaseObject
    {
        //public int User { get; set; }
        //public string UserDisplayName { get; set; }
        //public DateTime Date { get; set; }
        //public string Event { get; set; } //To be determined if this a string or a fixed set
        //public string Details { get; set; }

        #region Id
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isIdDirty = false;
        private int m_Id;
        [MTDataMember(Description = "This is the Audit ID", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int Id
        {
          get { return m_Id; }
          set
          {
            m_Id = value;
            isIdDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsIdDirty
        {
          get { return isIdDirty; }
        }
        #endregion


        #region User
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isUserDirty = false;
        private int m_User;
        [MTDataMember(Description = "This is the User.", Length = 100)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int User
        {
            get { return m_User; }
            set
            {
                m_User = value;
                isUserDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsUserDirty
        {
            get { return isUserDirty; }
        }
        #endregion


        #region UserDisplayName
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isUserDisplayNameDirty = false;
        private string m_UserDisplayName;
        [MTDataMember(Description = "This is the User.", Length = 100)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string UserDisplayName
        {
            get { return m_UserDisplayName; }
            set
            {
                m_UserDisplayName = value;
                isUserDisplayNameDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsUserDisplayNameDirty
        {
            get { return isUserDisplayNameDirty; }
        }
        #endregion


        #region Date
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isDateDirty = false;
        private DateTime m_Date;
        [MTDataMember(Description = "This is the User.", Length = 100)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DateTime Date
        {
            get { return m_Date; }
            set
            {
                m_Date = value;
                isDateDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsDateDirty
        {
            get { return isDateDirty; }
        }
        #endregion

        #region Event
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isEventDirty = false;
        private int m_Event;
        [MTDataMember(Description = "This is the Event Id.", Length = 100)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int Event
        {
            get { return m_Event; }
            set
            {
                m_Event = value;
                isEventDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsEventDirty
        {
            get { return isEventDirty; }
        }
        #endregion

        #region EventDisplayName
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isEventDisplayNameDirty = false;
        private string m_EventDisplayName;
        [MTDataMember(Description = "This is the Event.", Length = 100)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string EventDisplayName
        {
          get { return m_EventDisplayName; }
          set
          {
            m_EventDisplayName = value;
            isEventDisplayNameDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsEventDisplayNameDirty
        {
          get { return isEventDisplayNameDirty; }
        }
        #endregion

        #region Details
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isDetailsDirty = false;
        private string m_Details;
        [MTDataMember(Description = "This is the User.", Length = 100)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string Details
        {
            get { return m_Details; }
            set
            {
                m_Details = value;
                isDetailsDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsDetailsDirty
        {
            get { return isDetailsDirty; }
        }
        #endregion

    
    }

    [DataContract]
    [Serializable]
    public class ChangeDetailsDisplay : BaseObject
    {
        #region PropertyName
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPropertyNameDirty;
        private string m_PropertyName;

        [MTDataMember(Description = "This is the account update property Name", Length = 100)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string PropertyName
        {
            get { return m_PropertyName; }
            set
            {
                m_PropertyName = value;
                isPropertyNameDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsPropertyNameDirty
        {
            get { return isPropertyNameDirty; }
        }

        #endregion

        #region OldValue
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isOldValueDirty;
        private string m_OldValue;
        [MTDataMember(Description = "This is the account update property Name", Length = 100)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string OldValue
        {
            get { return m_OldValue; }
            set
            {
                m_OldValue = value;
                isOldValueDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsOldValueDirty
        {
            get { return isOldValueDirty; }
        }

        #endregion

        #region UpdatedValue
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isUpdatedValueDirty;
        private string m_UpdatedValue;
        [MTDataMember(Description = "This is the account update property Name", Length = 100)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string UpdatedValue
        {
            get { return m_UpdatedValue; }
            set
            {
                m_UpdatedValue = value;
                isUpdatedValueDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsUpdatedValueDirty
        {
            get { return isUpdatedValueDirty; }
        }

        #endregion
    }

    [DataContract]
  [Serializable]
  public class GroupSubscriptionChangeDetailsDisplay : BaseObject
    {
      #region GroupSubId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isGroupSubIdDirty = false;
    private int  m_GroupSubId;
    [MTDataMember(Description = "The ID of this group subscription", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int  GroupSubId
    {
      get { return m_GroupSubId; }
      set
      {
          m_GroupSubId = value;
          isGroupSubIdDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsGroupSubIdDirty
    {
      get { return isGroupSubIdDirty; }
    }
    #endregion

      #region MemberId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isMemberIdDirty = false;
    private int m_MemberId;
    [MTDataMember(Description = "The Id of this member", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int MemberId
    {
      get { return m_MemberId; }
      set
      {
          m_MemberId = value;
          isMemberIdDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsMemberIdDirty
    {
      get { return isMemberIdDirty; }
    }
    #endregion

      #region StartDate
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isStartDateDirty = false;
    private string m_StartDate;
    [MTDataMember(Description = "The start date of this subscription", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string StartDate
    {
      get { return m_StartDate; }
      set
      {
          m_StartDate = value;
          isStartDateDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsStartDateDirty
    {
      get { return isStartDateDirty; }
    }
    #endregion

      #region EndDate
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
  private bool isEndDateDirty = false;
    private string m_EndDate;
    [MTDataMember(Description = "End date of this subscription", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string EndDate
    {
      get { return m_EndDate; }
      set
      {
        m_EndDate = value;
        isEndDateDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsEndDateDirty
    {
      get { return isEndDateDirty; }
    }
    #endregion

      #region OldStartDate
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isOldStartDateDirty = false;
    private string m_OldStartDate;
    [MTDataMember(Description = "The date this subscription used to start", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string OldStartDate
    {
      get { return m_OldStartDate; }
      set
      {
          m_OldStartDate = value;
          isOldStartDateDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsOldStartDateDirty
    {
      get { return isOldStartDateDirty; }
    }
    #endregion

      #region OldEndDate
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isOldEndDateDirty = false;
    private string m_OldEndDate;
    [MTDataMember(Description = "The date this subscription used to end", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string OldEndDate
    {
      get { return m_OldEndDate; }
      set
      {
          m_OldEndDate = value;
          isOldEndDateDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsOldEndDateDirty
    {
      get { return isOldEndDateDirty; }
    }
    #endregion
    }
}

