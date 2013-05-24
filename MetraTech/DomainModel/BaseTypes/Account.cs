using System;
using System.Diagnostics;
using System.Collections.Generic;
using System.Collections;
using System.Text;
using System.Runtime.Serialization;
using System.Reflection;
using System.IO;

using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.DomainModel.Enums.Core.Global;
using System.Web.Script.Serialization;
using MetraTech.Interop.MTAuditEvents;

namespace MetraTech.DomainModel.BaseTypes
{
  [KnownType("KnownTypes")]
  [DataContract]
  [Serializable]
  public class Account : AccountBase, ICloneable, IEquatable<Account>
  {
    [System.Runtime.Serialization.DataMemberAttribute(IsRequired = false, EmitDefaultValue = false)]
    private bool isAccountStatusDirty = false;

    private Nullable<Enums.Account.Metratech_com_accountcreation.AccountStatus> accountstatus;
    [MTDataMember(Description = "Account state, such as Active, Suspended, or Closed.")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Nullable<Enums.Account.Metratech_com_accountcreation.AccountStatus> AccountStatus
    {
      get { return accountstatus; }
      set
      {
        accountstatus = value;
        isAccountStatusDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsAccountStatusDirty
    {
      get { return isAccountStatusDirty; }
    }

    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account.accountstatus",
                                     DefaultValue = "AccountStatus",
                                     MTLocalizationId = "metratech.com/account/AccountStatus", 
                                     Extension = "Account", 
                                     LocaleSpace = "metratech.com/account")]
    public string AccountStatusDisplayName
    {
      get
      {
        return ResourceManager.GetString("metratech.domainmodel.basetypes.account.accountstatus");
      }
    }

    public string AccountStatusValueDisplayName
    {
      get
      {
        return GetDisplayName(this.AccountStatus);
      }
      set
      {
        this.AccountStatus = ((System.Nullable<Enums.Account.Metratech_com_accountcreation.AccountStatus>)(GetEnumInstanceByDisplayName(typeof(AccountStatus), value)));
      }
    }

    [System.Runtime.Serialization.DataMemberAttribute(IsRequired = false, EmitDefaultValue = false)]
    private bool is_AuthenticationTypeDirty = false;
    private AuthenticationType authenticationtype;
    [MTDataMember(Description = "Account authentication type, such as MetraNetInternal or ActiveDirectory.")]
    [DataMember(IsRequired = true, EmitDefaultValue = true)]
    public AuthenticationType AuthenticationType
    {
      get { return authenticationtype; }
      set
      {
        authenticationtype = value;
        is_AuthenticationTypeDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsAuthenticationTypeDirty
    {
      get { return is_AuthenticationTypeDirty; }
    }


    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account.authenticationtype",
                                DefaultValue = "AuthenticationType",
                                MTLocalizationId = "metratech.com/account/AuthenticationType",
                                 Extension = "Account",
                                 LocaleSpace = "metratech.com/account")]
    public string AuthenticationTypeDisplayName
    {
      get
      {
        return ResourceManager.GetString("metratech.domainmodel.basetypes.account.authenticationtype");
      }
    }

    public string AuthenticationTypeValueDisplayName
    {
      get
      {
        return GetDisplayName(this.AuthenticationType);
      }
      set
      {
        this.AuthenticationType = (AuthenticationType)(GetEnumInstanceByDisplayName(typeof(AuthenticationType), value));
      }
    }

    [System.Runtime.Serialization.DataMemberAttribute(IsRequired = false, EmitDefaultValue = false)]
    private bool isAccountTypeDirty = false;
    private string accountType = "CoreSubscriber";
    [MTDataMember(IsRequired = true, HasDefault = true, Description = "An account-type enumerated value, such as for System User or Core Subscriber.", Length = 200)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string AccountType
    {
      get { return accountType; }
      set
      {
        accountType = value;
        isAccountTypeDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsAccountTypeDirty
    {
      get { return isAccountTypeDirty; }
    }

   
    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account.accounttype",
                                     DefaultValue = "AccountType",
                                     MTLocalizationId = "metratech.com/account/AccountType",
                                     Extension = "Account",
                                     LocaleSpace = "metratech.com/account")]
    public string AccountTypeDisplayName
    {
      get
      {
        return ResourceManager.GetString("metratech.domainmodel.basetypes.account.accounttype");
      }
    }

    [System.Runtime.Serialization.DataMemberAttribute(IsRequired = false, EmitDefaultValue = false)]
    private bool is_AccountIDDirty = false;
    private int? id;
    [MTDataMember(Description = "A uniquely generated account ID.")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? _AccountID
    {
      get { return id; }
      set
      {
        id = value;
        is_AccountIDDirty = true;
      }
    }

    [ScriptIgnore]
    public bool Is_AccountIDDirty
    {
      get { return is_AccountIDDirty; }
    }

    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account._accountid",
                                     DefaultValue = "_AccountID",
                                     MTLocalizationId = "metratech.com/account/_AccountID",
                                     Extension = "Account",
                                     LocaleSpace = "metratech.com/account")]
    public string _AccountIDDisplayName
    {
      get
      {
        return ResourceManager.GetString("metratech.domainmodel.basetypes.account._accountid");
      }
    }

    [System.Runtime.Serialization.DataMemberAttribute(IsRequired = false, EmitDefaultValue = false)]
    private bool isAccountStartDateDirty = false;
    private DateTime? startDate;
    [MTDataMember(Description = "The date used to control the account start date and to change the account state.")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime? AccountStartDate
    {
      get { return startDate; }
      set
      {

        startDate = value;
        isAccountStartDateDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsAccountStartDateDirty
    {
      get { return isAccountStartDateDirty; }
    }

   
    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account.accountstartdate",
                                     DefaultValue = "AccountStartDate",
                                     MTLocalizationId = "metratech.com/account/AccountStartDate",
                                     Extension = "Account",
                                     LocaleSpace = "metratech.com/account")]
    public string AccountStartDateDisplayName
    {
      get
      {
        return ResourceManager.GetString("metratech.domainmodel.basetypes.account.accountstartdate");
      }
    }

    [System.Runtime.Serialization.DataMemberAttribute(IsRequired = false, EmitDefaultValue = false)]
    private bool isAccountEndDateDirty = false;
    private DateTime? endDate;
    [MTDataMember(Description = "The date used to control the account end date and to change the account state.")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime? AccountEndDate
    {
      get { return endDate; }
      set
      {

        endDate = value;
        isAccountEndDateDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsAccountEndDateDirty
    {
      get { return isAccountEndDateDirty; }
    }

    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account.accountenddate",
                                     DefaultValue = "AccountEndDate",
                                     MTLocalizationId = "metratech.com/account/AccountEndDate",
                                     Extension = "Account",
                                     LocaleSpace = "metratech.com/account")]
    public string AccountEndDateDisplayName
    {
      get
      {
        return ResourceManager.GetString("metratech.domainmodel.basetypes.account.accountenddate");
      }
    }

    [System.Runtime.Serialization.DataMemberAttribute(IsRequired = false, EmitDefaultValue = false)]
    private bool isUserNameDirty = false;
    private string userName;
    [MTDataMember(Description = "The name of the user (required).", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string UserName
    {
      get { return userName; }
      set
      {

        userName = value;
        isUserNameDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsUserNameDirty
    {
      get { return isUserNameDirty; }
    }

    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account.username",
                                    DefaultValue = "UserName",
                                    MTLocalizationId = "metratech.com/account/UserName",
                                     Extension = "Account",
                                     LocaleSpace = "metratech.com/account")]
    public string UserNameDisplayName
    {
      get
      {
        return ResourceManager.GetString("metratech.domainmodel.basetypes.account.username");
      }
    }

    [System.Runtime.Serialization.DataMemberAttribute(IsRequired = false, EmitDefaultValue = false)]
    private bool isPassword_Dirty = false;
    private string password;
    [MTDataMember(Description = "The password associated with username or login (required).", Length = 1024, IsInputOnly = true)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string Password_
    {
      get { return password; }
      set
      {

        password = value;
        isPassword_Dirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsPassword_Dirty
    {
      get { return isPassword_Dirty; }
    }

    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account.password_",
                                     DefaultValue = "Password_",
                                     MTLocalizationId = "metratech.com/account/Password_",
                                     Extension = "Account",
                                     LocaleSpace = "metratech.com/account")]
    public string Password_DisplayName
    {
      get
      {
        return ResourceManager.GetString("metratech.domainmodel.basetypes.account.password_");
      }
    }

    [System.Runtime.Serialization.DataMemberAttribute(IsRequired = false, EmitDefaultValue = false)]
    private bool isName_SpaceDirty = false;
    private string accountNamespace;
    [MTDataMember(Description = "The namespace uniquely identifying the username or login (required).", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string Name_Space
    {
      get { return accountNamespace; }
      set
      {

        accountNamespace = value;
        isName_SpaceDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsName_SpaceDirty
    {
      get { return isName_SpaceDirty; }
    }

    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account.name_space",
                                    DefaultValue = "Name_Space",
                                    MTLocalizationId = "metratech.com/account/Name_Space",
                                     Extension = "Account",
                                     LocaleSpace = "metratech.com/account")]
    public string Name_SpaceDisplayName
    {
      get
      {
        return ResourceManager.GetString("metratech.domainmodel.basetypes.account.name_space");
      }
    }

    [System.Runtime.Serialization.DataMemberAttribute(IsRequired = false, EmitDefaultValue = false)]
    private bool isDayOfMonthDirty = false;
    private int? dayOfMonth;
    [MTDataMember(Description = "The day of the month on which the user wants to be billed.")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? DayOfMonth
    {
      get { return dayOfMonth; }
      set
      {

        dayOfMonth = value;
        isDayOfMonthDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsDayOfMonthDirty
    {
      get { return isDayOfMonthDirty; }
    }

    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account.dayofmonth",
                                   DefaultValue = "DayOfMonth",
                                   MTLocalizationId = "metratech.com/account/DayOfMonth",
                                     Extension = "Account",
                                     LocaleSpace = "metratech.com/account")]
    public string DayOfMonthDisplayName
    {
      get
      {
        return ResourceManager.GetString("metratech.domainmodel.basetypes.account.dayofmonth");
      }
    }

    [System.Runtime.Serialization.DataMemberAttribute(IsRequired = false, EmitDefaultValue = false)]
    private bool isDayOfWeekDirty = false;
    private Nullable<DayOfTheWeek> dayOfWeek;
    [MTDataMember(Description = "The day of the week on which the user wants to be billed (for the weekly usage cycle type).")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Nullable<DayOfTheWeek> DayOfWeek
    {
      get { return dayOfWeek; }
      set
      {
        dayOfWeek = value;
        isDayOfWeekDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsDayOfWeekDirty
    {
      get { return isDayOfWeekDirty; }
    }

    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account.dayofweek",
                                   DefaultValue = "DayOfWeek",
                                   MTLocalizationId = "metratech.com/account/DayOfWeek",
                                     Extension = "Account",
                                     LocaleSpace = "metratech.com/account")]
    public string DayOfWeekDisplayName
    {
      get
      {
        return ResourceManager.GetString("metratech.domainmodel.basetypes.account.dayofweek");
      }
    }

    public string DayOfWeekValueDisplayName
    {
      get
      {
        return GetDisplayName(this.DayOfWeek);
      }
      set
      {
        this.DayOfWeek = ((System.Nullable<DayOfTheWeek>)(GetEnumInstanceByDisplayName(typeof(DayOfTheWeek), value)));
      }
    }

    [System.Runtime.Serialization.DataMemberAttribute(IsRequired = false, EmitDefaultValue = false)]
    private bool isFirstDayOfMonthDirty = false;
    private int? firstDayOfMonth;
    [MTDataMember(Description = "The first day of the month on which the user wants to be billed (for the semi-monthly usage cycle type).")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? FirstDayOfMonth
    {
      get { return firstDayOfMonth; }
      set
      {

        firstDayOfMonth = value;
        isFirstDayOfMonthDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsFirstDayOfMonthDirty
    {
      get { return isFirstDayOfMonthDirty; }
    }

    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account.firstdayofmonth",
                                  DefaultValue = "FirstDayOfMonth",
                                  MTLocalizationId = "metratech.com/account/FirstDayOfMonth",
                                     Extension = "Account",
                                     LocaleSpace = "metratech.com/account")]
    public string FirstDayOfMonthDisplayName
    {
      get
      {
        return ResourceManager.GetString("metratech.domainmodel.basetypes.account.firstdayofmonth");
      }
    }

    [System.Runtime.Serialization.DataMemberAttribute(IsRequired = false, EmitDefaultValue = false)]
    private bool isSecondDayOfMonthDirty = false;
    private int? secondDayOfMonth;
    [MTDataMember(Description = "The second day of the month on which the user wants to be billed (for the semi-monthly usage cycle type).")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? SecondDayOfMonth
    {
      get { return secondDayOfMonth; }
      set
      {

        secondDayOfMonth = value;
        isSecondDayOfMonthDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsSecondDayOfMonthDirty
    {
      get { return isSecondDayOfMonthDirty; }
    }

    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account.seconddayofmonth",
                                 DefaultValue = "SecondDayOfMonth",
                                 MTLocalizationId = "metratech.com/account/SecondDayOfMonth",
                                     Extension = "Account",
                                     LocaleSpace = "metratech.com/account")]
    public string SecondDayOfMonthDisplayName
    {
      get
      {
        return ResourceManager.GetString("metratech.domainmodel.basetypes.account.seconddayofmonth");
      }
    }

    [System.Runtime.Serialization.DataMemberAttribute(IsRequired = false, EmitDefaultValue = false)]
    private bool isStartDayDirty = false;
    private int? startDay;
    [MTDataMember(Description = "The first day on which to bill the user (for the biweekly, quarterly, semi-annual, and annual usage cycle types).")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? StartDay
    {
      get { return startDay; }
      set
      {

        startDay = value;
        isStartDayDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsStartDayDirty
    {
      get { return isStartDayDirty; }
    }

    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account.startday",
                                     DefaultValue = "StartDay",
                                     MTLocalizationId = "metratech.com/account/StartDay",
                                     Extension = "Account",
                                     LocaleSpace = "metratech.com/account")]
    public string StartDayDisplayName
    {
      get
      {
        return ResourceManager.GetString("metratech.domainmodel.basetypes.account.startday");
      }
    }

    [System.Runtime.Serialization.DataMemberAttribute(IsRequired = false, EmitDefaultValue = false)]
    private bool isStartMonthDirty = false;
    private Nullable<MonthOfTheYear> startMonth;
    [MTDataMember(Description = "The first month on which to bill the user (for the biweekly, quarterly, semi-annual, and annual usage cycle types).")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Nullable<MonthOfTheYear> StartMonth
    {
      get { return startMonth; }
      set
      {

        startMonth = value;
        isStartMonthDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsStartMonthDirty
    {
      get { return isStartMonthDirty; }
    }

    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account.startmonth",
                                    DefaultValue = "StartMonth",
                                    MTLocalizationId = "metratech.com/account/StartMonth",
                                     Extension = "Account",
                                     LocaleSpace = "metratech.com/account")]
    public string StartMonthDisplayName
    {
      get
      {
        return ResourceManager.GetString("metratech.domainmodel.basetypes.account.startmonth");
      }
    }

    public string StartMonthValueDisplayName
    {
      get
      {
        return GetDisplayName(this.StartMonth);
      }
      set
      {
        this.StartMonth = ((System.Nullable<MonthOfTheYear>)(GetEnumInstanceByDisplayName(typeof(MonthOfTheYear), value)));
      }
    }

    [System.Runtime.Serialization.DataMemberAttribute(IsRequired = false, EmitDefaultValue = false)]
    private bool isStartYearDirty = false;
    private int? startYear;
    [MTDataMember(Description = "The first year on which to bill the user (for the biweekly usage cycle type).")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? StartYear
    {
      get { return startYear; }
      set
      {

        startYear = value;
        isStartYearDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsStartYearDirty
    {
      get { return isStartYearDirty; }
    }

    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account.startyear",
                                   DefaultValue = "StartYear",
                                   MTLocalizationId = "metratech.com/account/StartYear",
                                     Extension = "Account",
                                     LocaleSpace = "metratech.com/account")]
    public string StartYearDisplayName
    {
      get
      {
        return ResourceManager.GetString("metratech.domainmodel.basetypes.account.startyear");
      }
    }

    [System.Runtime.Serialization.DataMemberAttribute(IsRequired = false, EmitDefaultValue = false)]
    private bool isPayerIDDirty = false;
    private int? payerId;
    [MTDataMember(Description = "The paying account identifier. It can be used in place of PayerAccount and PayerAccountNS.")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? PayerID
    {
      get { return payerId; }
      set
      {

        payerId = value;
        isPayerIDDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsPayerIDDirty
    {
      get { return isPayerIDDirty; }
    }

    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account.payerid",
                                  DefaultValue = "PayerID",
                                  MTLocalizationId = "metratech.com/account/PayerID",
                                     Extension = "Account",
                                     LocaleSpace = "metratech.com/account")]
    public string PayerIDDisplayName
    {
      get
      {
        return ResourceManager.GetString("metratech.domainmodel.basetypes.account.payerid");
      }
    }

    [System.Runtime.Serialization.DataMemberAttribute(IsRequired = false, EmitDefaultValue = false)]
    private bool isPayerAccountDirty = false;
    private string payerName;
    [MTDataMember(Description = "The paying account.")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string PayerAccount
    {
      get { return payerName; }
      set
      {

        payerName = value;
        isPayerAccountDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsPayerAccountDirty
    {
      get { return isPayerAccountDirty; }
    }

    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account.payeraccount",
                                 DefaultValue = "PayerAccount",
                                 MTLocalizationId = "metratech.com/account/PayerAccount",
                                     Extension = "Account",
                                     LocaleSpace = "metratech.com/account")]
    public string PayerAccountDisplayName
    {
      get
      {
        return ResourceManager.GetString("metratech.domainmodel.basetypes.account.payeraccount");
      }
    }

    [System.Runtime.Serialization.DataMemberAttribute(IsRequired = false, EmitDefaultValue = false)]
    private bool isPayerAccountNSDirty = false;
    private string payerNamespace;
    [MTDataMember(Description = "The paying account namespace.")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string PayerAccountNS
    {
      get { return payerNamespace; }
      set
      {

        payerNamespace = value;
        isPayerAccountNSDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsPayerAccountNSDirty
    {
      get { return isPayerAccountNSDirty; }
    }

    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account.payeraccountns",
                                DefaultValue = "PayerAccountNS",
                                MTLocalizationId = "metratech.com/account/PayerAccountNS",
                                     Extension = "Account",
                                     LocaleSpace = "metratech.com/account")]
    public string PayerAccountNSDisplayName
    {
      get
      {
        return ResourceManager.GetString("metratech.domainmodel.basetypes.account.payeraccountns");
      }
    }

    [System.Runtime.Serialization.DataMemberAttribute(IsRequired = false, EmitDefaultValue = false)]
    private bool isPayment_StartDateDirty = false;
    private DateTime? paymentStartDate;
    [MTDataMember(Description = "The payment redirection start date.")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime? Payment_StartDate
    {
      get { return paymentStartDate; }
      set
      {

        paymentStartDate = value;
        isPayment_StartDateDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsPayment_StartDateDirty
    {
      get { return isPayment_StartDateDirty; }
    }

    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account.payment_startdate",
                               DefaultValue = "Payment_StartDate",
                               MTLocalizationId = "metratech.com/account/Payment_StartDate",
                                     Extension = "Account",
                                     LocaleSpace = "metratech.com/account")]
    public string Payment_StartDateDisplayName
    {
      get
      {
        return ResourceManager.GetString("metratech.domainmodel.basetypes.account.payment_startdate");
      }
    }

    [System.Runtime.Serialization.DataMemberAttribute(IsRequired = false, EmitDefaultValue = false)]
    private bool isPayment_EndDateDirty = false;
    private DateTime? paymentEndDate;
    [MTDataMember(Description = "The payment redirection end date.")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime? Payment_EndDate
    {
      get { return paymentEndDate; }
      set
      {

        paymentEndDate = value;
        isPayment_EndDateDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsPayment_EndDateDirty
    {
      get { return isPayment_EndDateDirty; }
    }

    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account.payment_enddate",
                              DefaultValue = "Payment_EndDate",
                              MTLocalizationId = "metratech.com/account/Payment_EndDate",
                                     Extension = "Account",
                                     LocaleSpace = "metratech.com/account")]
    public string Payment_EndDateDisplayName
    {
      get
      {
        return ResourceManager.GetString("metratech.domainmodel.basetypes.account.payment_enddate");
      }
    }

    [System.Runtime.Serialization.DataMemberAttribute(IsRequired = false, EmitDefaultValue = false)]
    private bool isAncestorAccountIDDirty = false;
    private int? ancestorId;
    [MTDataMember(Description = "The ancestor account ID.")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? AncestorAccountID
    {
      get { return ancestorId; }
      set
      {

        ancestorId = value;
        isAncestorAccountIDDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsAncestorAccountIDDirty
    {
      get { return isAncestorAccountIDDirty; }
    }

    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account.ancestoraccountid",
                             DefaultValue = "AncestorAccountID",
                             MTLocalizationId = "metratech.com/account/AncestorAccountID",
                                     Extension = "Account",
                                     LocaleSpace = "metratech.com/account")]
    public string AncestorAccountIDDisplayName
    {
      get
      {
        return ResourceManager.GetString("metratech.domainmodel.basetypes.account.ancestoraccountid");
      }
    }

    [System.Runtime.Serialization.DataMemberAttribute(IsRequired = false, EmitDefaultValue = false)]
    private bool isAncestorAccountDirty = false;
    private string ancestorAccount;
    [MTDataMember(Description = "The ancestor account name.")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string AncestorAccount
    {
      get { return ancestorAccount; }
      set
      {
        if (value != ancestorAccount)
        {
          ancestorAccount = value;
          isAncestorAccountDirty = true;
        }
      }
    }

    [ScriptIgnore]
    public bool IsAncestorAccountDirty
    {
      get { return isAncestorAccountDirty; }
    }

    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account.ancestoraccount",
                                     DefaultValue = "AncestorAccount",
                                     MTLocalizationId = "metratech.com/account/AncestorAccount",
                                     Extension = "Account",
                                     LocaleSpace = "metratech.com/account")]
    public string AncestorAccountDisplayName
    {
      get
      {
        return ResourceManager.GetString("metratech.domainmodel.basetypes.account.ancestoraccount");
      }
    }

    [System.Runtime.Serialization.DataMemberAttribute(IsRequired = false, EmitDefaultValue = false)]
    private bool isAncestorAccountNSDirty = false;
    private string ancestorNamespace;
    [MTDataMember(Description = "The ancestor account namespace")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string AncestorAccountNS
    {
      get { return ancestorNamespace; }
      set
      {

        ancestorNamespace = value;
        isAncestorAccountNSDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsAncestorAccountNSDirty
    {
      get { return isAncestorAccountNSDirty; }
    }

    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account.ancestoraccountns",
                                    DefaultValue = "AncestorAccountNS",
                                    MTLocalizationId = "metratech.com/account/AncestorAccountNS",
                                     Extension = "Account",
                                     LocaleSpace = "metratech.com/account")]
    public string AncestorAccountNSDisplayName
    {
      get
      {
        return ResourceManager.GetString("metratech.domainmodel.basetypes.account.ancestoraccountns");
      }
    }

    [System.Runtime.Serialization.DataMemberAttribute(IsRequired = false, EmitDefaultValue = false)]
    private bool isHierarchy_StartDateDirty = false;
    private DateTime? hierarchyStartDate;
    [MTDataMember(Description = "The account hierarchy start date.")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime? Hierarchy_StartDate
    {
      get { return hierarchyStartDate; }
      set
      {

        hierarchyStartDate = value;
        isHierarchy_StartDateDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsHierarchy_StartDateDirty
    {
      get { return isHierarchy_StartDateDirty; }
    }

    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account.hierarchy_startdate",
                                    DefaultValue = "Hierarchy_StartDate",
                                    MTLocalizationId = "metratech.com/account/Hierarchy_StartDate",
                                      Extension = "Account",
                                      LocaleSpace = "metratech.com/account")]
    public string Hierarchy_StartDateDisplayName
    {
      get
      {
        return ResourceManager.GetString("metratech.domainmodel.basetypes.account.hierarchy_startdate");
      }
    }

    [System.Runtime.Serialization.DataMemberAttribute(IsRequired = false, EmitDefaultValue = false)]
    private bool isHierarchy_EndDateDirty = false;
    private DateTime? hierarchyEndDate;
    [MTDataMember(Description = "The account hierarchy end date.")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime? Hierarchy_EndDate
    {
      get { return hierarchyEndDate; }
      set
      {

        hierarchyEndDate = value;
        isHierarchy_EndDateDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsHierarchy_EndDateDirty
    {
      get { return isHierarchy_EndDateDirty; }
    }

    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account.hierarchy_enddate",
                                    DefaultValue = "Hierarchy_EndDate",
                                    MTLocalizationId = "metratech.com/account/Hierarchy_EndDate",
                                      Extension = "Account",
                                      LocaleSpace = "metratech.com/account")]
    public string Hierarchy_EndDateDisplayName
    {
      get
      {
        return ResourceManager.GetString("metratech.domainmodel.basetypes.account.hierarchy_enddate");
      }
    }

    [System.Runtime.Serialization.DataMemberAttribute(IsRequired = false, EmitDefaultValue = false)]
    private bool isApplyDefaultSecurityPolicyDirty = true;
    protected bool? applyDefaultSecurityPolicy;
    [MTDataMember(HasDefault = true, Description = "Apply default security policy.", IsInputOnly = true)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool? ApplyDefaultSecurityPolicy
    {
      get { return applyDefaultSecurityPolicy; }
      set
      {

        applyDefaultSecurityPolicy = value;
        isApplyDefaultSecurityPolicyDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsApplyDefaultSecurityPolicyDirty
    {
      get { return isApplyDefaultSecurityPolicyDirty; }
    }

    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account.applydefaultsecuritypolicy",
                                   DefaultValue = "ApplyDefaultSecurityPolicy",
                                   MTLocalizationId = "metratech.com/account/ApplyDefaultSecurityPolicy",
                                      Extension = "Account",
                                      LocaleSpace = "metratech.com/account")]
    public string ApplyDefaultSecurityPolicyDisplayName
    {
      get
      {
        return ResourceManager.GetString("metratech.domainmodel.basetypes.account.applydefaultsecuritypolicy");
      }
    }

    private bool? hasLogonCapability;
    private bool isHasLogonCapabilityDirty = true;
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool? HasLogonCapability
    {
        get
        {
            return hasLogonCapability;
        }
        set
        {
            hasLogonCapability = value;
            isHasLogonCapabilityDirty = true;
        }
    }

    [ScriptIgnore]
    public bool IsHasLogonCapabilityDirty
    {
        get
        {
            return isHasLogonCapabilityDirty;
        }
    }

    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account.haslogoncapability",
                                     DefaultValue = "CanHaveChildren",
                                     MTLocalizationId = "metratech.com/account/HasLogonCapability",
                                     Extension = "Account",
                                     LocaleSpace = "metratech.com/account")]
    public string HasLogonCapabilityDisplayName
    {
        get
        {
            return ResourceManager.GetString("metratech.domainmodel.basetypes.account.haslogoncapability");
        }
    }

    private bool? canHaveChildren;
    private bool isCanHaveChildrenDirty = true;
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool? CanHaveChildren
    {
        get
        {
            return canHaveChildren;
        }
        set
        {
            canHaveChildren = value;
            isCanHaveChildrenDirty = true;
        }
    }

    [ScriptIgnore]
    public bool IsCanHaveChildrenDirty
    {
        get
        {
            return isCanHaveChildrenDirty;
        }
    }

    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account.canhavechildren",
                                     DefaultValue = "CanHaveChildren",
                                     MTLocalizationId = "metratech.com/account/CanHaveChildren",
                                     Extension = "Account",
                                     LocaleSpace = "metratech.com/account")]
    public string CanHaveChildrenDisplayName
    {
        get
        {
            return ResourceManager.GetString("metratech.domainmodel.basetypes.account.canhavechildren");
        }
    }

    private int? accountTypeID;
    private bool isAccountTypeIDDirty = true;
    [MTDataMember(IsRequired = false, HasDefault = false, Description = "An account-type enumerated value ID.")]
    [ScriptIgnore]
    public int? AccountTypeID
    {
        get
        {
            return accountTypeID;
        }
        set
        {
            accountTypeID = value;
            isAccountTypeIDDirty = true;
        }
    }

    [ScriptIgnore]
    public bool IsAccountTypeIDDirty
    {
        get
        {
            return isAccountTypeIDDirty;
        }
    }

    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.account.accounttypeid",
                                     DefaultValue = "AccountTypeID",
                                     MTLocalizationId = "metratech.com/account/AccountTypeID",
                                     Extension = "Account",
                                     LocaleSpace = "metratech.com/account")]
    public string AccountTypeIDDisplayName
    {
        get
        {
            return ResourceManager.GetString("metratech.domainmodel.basetypes.account.accounttypeid");
        }
    }

    #region Public Methods
    public static Type[] KnownTypes()
    {
      return GetKnownTypes(typeof(MTAccountAttribute));
    }

    public static Account CreateAccount(string typeName)
    {
      Account account = null;

      Assembly assembly = GetAccountTypesAssembly();

      Type accountType = null;

      foreach (Type type in assembly.GetTypes())
      {
        object[] attributes = type.GetCustomAttributes(typeof(MTAccountAttribute), false);
        if (attributes != null && attributes.Length > 0)
        {
          MTAccountAttribute attribute = attributes[0] as MTAccountAttribute;

          if (type.Name.ToLower() == typeName.ToLower() ||
              type.FullName.ToLower() == typeName.ToLower())
          {
            accountType = type;
            break;
          }
        }
      }

      if (accountType == null)
      {
        //logger.LogError(String.Format("Unable to create account of type '{0}' from assembly 'MetraTech.DomainModel.BaseTypes.dll'", typeName));
        throw new ApplicationException(String.Format("Unable to create account of type '{0}' from assembly 'MetraTech.DomainModel.BaseTypes.dll'", typeName));
      }

      // Create an instance of accountType
      account = Activator.CreateInstance(accountType, false) as Account;

      // Create the InternalView
      object internalView = View.CreateView("metratech.com/internal");
      account.SetValue(accountType.GetProperty("Internal"), internalView);

      return account;
    }

    public static Account CreateAccountWithViews(string typeName)
    {
      Account account = CreateAccount(typeName);
      MTDataMemberAttribute dataMemberAttribute = null;


      foreach (PropertyInfo propertyInfo in account.GetMTProperties())
      {
        dataMemberAttribute = account.GetMTDataMemberAttribute(propertyInfo);
        if (dataMemberAttribute != null)
        {
          if (!String.IsNullOrEmpty(dataMemberAttribute.ViewType))
          {
            View view = GetView(dataMemberAttribute.ClassName);
            account.AddView(view, propertyInfo.Name);
          }
        }
      }
      return account;
    }

    /// <summary>
    ///    Returns the view based on either the type name (e.g. ContactView) or 
    ///    the MetraTech view name (e.g. "metratech.com/contact")
    /// </summary>
    /// <param name="viewName"></param>
    /// <returns></returns>
    public static View GetView(string viewName)
    {
      View view = null;

      Assembly assembly = GetAccountTypesAssembly();

      Type viewType = null;

      foreach (Type type in assembly.GetTypes())
      {
        object[] attributes = type.GetCustomAttributes(typeof(MTViewAttribute), false);
        if (attributes != null && attributes.Length > 0)
        {
          MTViewAttribute attribute = attributes[0] as MTViewAttribute;

          if (type.Name.ToLower() == viewName.ToLower() ||
              type.FullName.ToLower() == viewName.ToLower() ||
              attribute.ViewType.ToLower() == viewName.ToLower())
          {
            viewType = type;
            break;
          }
        }
      }

      if (viewType == null)
      {
        //logger.LogError(String.Format("Unable to create view of type '{0}' from assembly 'MetraTech.DomainModel.BaseTypes.dll'", viewName));
        throw new ApplicationException(String.Format("Unable to create view of type '{0}' from assembly 'MetraTech.DomainModel.BaseTypes.dll'", viewName));
      }

      // Create an instance of viewType
      view = Activator.CreateInstance(viewType, false) as View;

      return view;
    }

    public object GetInternalView()
    {
      object internalView = null;

      foreach (PropertyInfo propertyInfo in GetMTProperties())
      {
        if (propertyInfo.PropertyType.Name == "InternalView")
        {
          internalView = propertyInfo.GetValue(this, null);
          break;
        }
      }

      return internalView;
    }

    public void AddView(View view, string propertyName)
    {
      // Get the property info
      PropertyInfo propertyInfo = GetType().GetProperty(propertyName);
      Debug.Assert(propertyInfo != null);

      // Get the attribute
      MTDataMemberAttribute attribute = GetMTDataMemberAttribute(propertyInfo);
      Debug.Assert(attribute != null);

      if (attribute.IsListView)
      {
        // It's a list view
        IList list = propertyInfo.GetValue(this, null) as IList;
        if (list == null)
        {
          Type generic = typeof(List<>);
          Type specificType = generic.MakeGenericType(new System.Type[] { view.GetType() });
          list = Activator.CreateInstance(specificType) as IList;
          Debug.Assert(list != null);
          propertyInfo.SetValue(this, list, null);
        }
        else if (!IsDirty(propertyInfo))
        {
            SetDirtyFlag(propertyInfo);
        }

        list.Add(view);
      }
      else
      {
        // Could be either a view or non-view
        Debug.Assert(propertyInfo.PropertyType == view.GetType());
        propertyInfo.SetValue(this, view, null);
      }
    }

    public Dictionary<string, List<View>> GetViews()
    {
      Dictionary<string, List<View>> views = new Dictionary<string, List<View>>();
      MTDataMemberAttribute dataMemberAttribute = null;

      foreach (PropertyInfo propertyInfo in GetMTProperties())
      {
        dataMemberAttribute = GetMTDataMemberAttribute(propertyInfo);
        if (dataMemberAttribute != null)
        {
          if (!String.IsNullOrEmpty(dataMemberAttribute.ViewType))
          {
            if (dataMemberAttribute.IsListView == true)
            {
              IList list = propertyInfo.GetValue(this, null) as IList;
              if (list != null)
              {
                foreach (View view in list)
                {
                  if (!views.ContainsKey(dataMemberAttribute.ViewName))
                  {
                    views[dataMemberAttribute.ViewName] = new List<View>();
                  }

                  ((List<View>)views[dataMemberAttribute.ViewName]).Add(view);
                }
              }
            }
            else
            {
              View view = propertyInfo.GetValue(this, null) as View;
              if (view != null)
              {
                if (!views.ContainsKey(dataMemberAttribute.ViewName))
                {
                  views[dataMemberAttribute.ViewName] = new List<View>();
                }
                ((List<View>)views[dataMemberAttribute.ViewName]).Add(view);
              }
            }
          }
        }
      }

      return views;
    }

    /// <summary>
    ///   Return the list of descendent account type names. 
    ///   This method is implemented by the derived code generated classes.
    /// </summary>
    /// <returns></returns>
    public virtual List<string> GetDescendantTypes()
    {
      throw new ApplicationException("GetDescendantTypes must be called on derived type");
    }

    public String AuditDirtyProperties(Account modifiedAccount, int userAccount)
    {

      if (!this.Equals(modifiedAccount))
      {
        throw new ArgumentException("The modified account does not match this account");
      }
      var resourceManager = new ResourcesManager();
      String changedProps = "";
      
        Dictionary<string, List<View>> modifiedViews = modifiedAccount.GetViews();
        Dictionary<string, List<View>> thisViews = this.GetViews();

        foreach (KeyValuePair<string, List<View>> kvp in modifiedViews)
        {
          List<View> originalViewList = null;

          if (thisViews.ContainsKey(kvp.Key))
          {
            originalViewList = thisViews[kvp.Key];
          }

          PropertyInfo viewProp = this.GetType().GetProperty(kvp.Key);

          foreach (View modifiedView in kvp.Value)
          {
            if (originalViewList != null && originalViewList.Count > 0)
            {
              foreach (View originalView in originalViewList)
              {
                if (originalView.Equals(modifiedView))
                {
                  List<PropertyInfo> viewProps = originalView.GetMTProperties();

                  foreach (PropertyInfo prop in viewProps)
                  {
                    Object originalVal = prop.GetValue(originalView, null);
                    Object modifiedVal = prop.GetValue(modifiedView,null);
                    if (modifiedView.IsDirty(prop) && (modifiedVal != null) &&
                      //For some reason a lot of properties seem to get changed from null to "".  Skip that case
                      !((originalVal == null) && (modifiedVal.Equals(""))) &&
                      //Ignore the case where the property hasn't changed.
                      !((prop.GetValue(modifiedView, null)).Equals( prop.GetValue(originalView, null))) &&
                      //We handle the cycle type auditing in UpdateAccountAcitivity.cs
                      prop.Name != "UsageCycleType"
                      )
                    {
                      changedProps += String.Format(resourceManager.GetLocalizedResource("CHANGED_PROP"),
                        prop.Name, originalVal, modifiedVal);
                    }
                  }
                }
              }
            }
          }
        }
        return changedProps;
     }

    public void ApplyDirtyProperties(Account modifiedAccount)
    {

      if (this.Equals(modifiedAccount))
      {
        List<PropertyInfo> baseProps = GetProperties();

        foreach (PropertyInfo prop in baseProps)
        {
          if (!prop.Name.EndsWith("Dirty") && 
              !prop.Name.EndsWith("DisplayName") && 
              !prop.PropertyType.IsSubclassOf(typeof(View)) &&
              !(prop.PropertyType.IsGenericType && 
                prop.PropertyType.GetGenericArguments()[0].IsSubclassOf(typeof(View))))
          {
            if (typeof(Account).GetProperty(string.Format("Is{0}Dirty", prop.Name)) == null || modifiedAccount.IsDirty(prop))
            {
              prop.SetValue(this, prop.GetValue(modifiedAccount, null), null);

              //if (string.Compare(prop.Name, "PayerID", true) == 0)
              //{
              //    this.payerName = null;
              //    this.payerNamespace = null;
              //}
              //else if (string.Compare(prop.Name, "PayerAccount", true) == 0 ||
              //    string.Compare(prop.Name, "PayerAccountNS", true) == 0)
              //{
              //    this.payerId = null;
              //}
            }
          }
        }

        Dictionary<string, List<View>> modifiedViews = modifiedAccount.GetViews();
        Dictionary<string, List<View>> thisViews = this.GetViews();

        foreach (KeyValuePair<string, List<View>> kvp in modifiedViews)
        {
          List<View> originalViewList = null;

          if (thisViews.ContainsKey(kvp.Key))
          {
            originalViewList = thisViews[kvp.Key];
          }

          PropertyInfo viewProp = this.GetType().GetProperty(kvp.Key);
          View newView = null;

          foreach (View modifiedView in kvp.Value)
          {
            if (originalViewList != null && originalViewList.Count > 0)
            {
              bool bFound = false;

              foreach (View originalView in originalViewList)
              {
                if(originalView.Equals(modifiedView))
                {
                  originalView.ApplyDirtyProperties(modifiedView);
                  bFound = true;
                  break;
                }
              }

              if (!bFound)
              {
                newView = modifiedView.Clone() as View;
                this.AddView(newView, kvp.Key);
              }
            }
            else
            {
              newView = modifiedView.Clone() as View;
              this.AddView(newView, kvp.Key);
            }
          }
        }
      }
      else
      {
        throw new ArgumentException("The modified account does not match this account");
      }
    }
    #endregion

    #region ICloneable Members

    public object Clone()
    {
      Account newAccount = null;

      newAccount = Account.CreateAccount(this.AccountType);
      newAccount._AccountID = this._AccountID;

      newAccount.ApplyDirtyProperties(this);

      return newAccount;
    }

    #endregion


    #region IEquatable<Account> Members

    public bool Equals(Account other)
    {
      bool retval = true;

      if (this.GetType() == other.GetType())
      {
        if (!this._AccountID.Equals(other._AccountID) &&
          (!this.UserName.Equals(other.UserName) || !this.Name_Space.Equals(other.Name_Space)))
        {
          retval = false;
        }
      }
      else
      {
        retval = false;
      }

      return retval;
    }

    #endregion
  }
}
