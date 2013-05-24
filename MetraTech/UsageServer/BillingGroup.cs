using System;
using System.Diagnostics;
using System.Collections;
using System.Runtime.InteropServices;
using System.Xml;
using System.Text;

using MetraTech;
using MetraTech.DataAccess;
using Rowset = MetraTech.Interop.Rowset;

namespace MetraTech.UsageServer
{
  [Guid("5BB5883A-B45D-4613-9D9E-21B73A94C099")]
  public enum BillingGroupStatus
  {
    Open,
    SoftClosed,
    HardClosed
  }

  [Guid("AC802EF5-67B1-48ce-B850-E9EFCD74B5C9")]
  public enum UnassignedAccountStatus
  {
    All,
    Open,
    HardClosed
  }

  [Guid("9A7E86AA-E722-439e-81C9-4A65B7CF46EC")]
  public enum MaterializationStatus
  {
    InProgress,
    Succeeded,
    Failed,
    Aborted 
  }

  [Guid("8AAEDE0E-A9DF-4654-BEC7-96790C5F1F3F")]
  public enum MaterializationType
  {
    Full,
    PullList,
    UserDefined,
    Rematerialization,
    None
  }

  [Guid("4E7418A6-4A5B-4a9d-9AE9-5C308882C969")]
  public enum BillingGroupOrder
  {
    None,
    Name,
    Interval
  }

  #region Interfaces
  /// <summary>
  /// A Billing Group
  /// </summary>
  [Guid("9145B327-5C89-494c-9DDC-AB5B8CBA13DF")]
  public interface IBillingGroup
  {
    // Billing Group info
    int BillingGroupID { get; set; }
    int IntervalID { get; set; }
    string Name { get; set; }
    string Description { get; set; }
    BillingGroupStatus Status { get; set; }
    DateTime StartDate { get; set;}
    DateTime EndDate { get; set;}
    int CycleID { get; set;}
    CycleType CycleType { get; set;}
    int MemberCount {get; set;}
    bool HasChildren {get; set;}
    MaterializationType MaterializationType {get; set;} 
    
    // Information about adapters
    int AdapterCount { get; set;}
    int IntervalOnlyAdapterCount { get; set;}
    int SucceededAdapterCount { get; set;}
    int FailedAdapterCount { get; set;}

    bool CanBeHardClosed { get; set; }
  }

  /// <summary>
  /// A materialization
  /// </summary>
  [Guid("1F6F68F9-4C5C-4493-95EC-2F6D28CDD5F6")]
  public interface IMaterialization
  {
    // Billing Group info
    int MaterializationID { get; }
    int IntervalID { get; set; }
    int AccountID { get; set; }
    string DisplayName { get; set; }
    string UserName { get; set; }
    string Namespace { get; set; }
    DateTime StartDate { get; set; }
    DateTime EndDate { get; set; }
    int ParentBillingGroupID { get; set; }
    MaterializationStatus MaterializationStatus { get; set; }
    string FailureReason { get; set; }
    MaterializationType MaterializationType { get; set; }
  }

  [Guid("472EA816-473B-4eb4-984D-30820251305D")]
  public interface IBillingGroupFilter
  {
    // Billing Group info
    int IntervalId { get; set;}
    int BillingGroupId { get; set; }
    string BillingGroupName { get; set; }
    string Status { get; set; }
    bool MoreThanOneAccount { get; set; }
    bool NoAdapters {get; set; }
    BillingGroupOrder BillingGroupOrder { get; set; }
    bool NonPullList { get; set; }
    string GetWhereClause();
    string GetDescendantsWhereClause(int parentBillingGroupId);
    string GetOrderByClause();
    void ClearCriteria();
  }

  [Guid("98FEA66E-E8C5-4b37-ABAF-53B0BE639D6E")]
  public interface IUnassignedAccountsFilter
  {
    int IntervalId { get; set; }
    UnassignedAccountStatus Status { get; set; }
    string GetWhereClause();
    string GetOrderByClause();
    void ClearCriteria();
  }

  #endregion

  #region Public Classes
  [ClassInterface(ClassInterfaceType.None)]
  [Guid("C0C389E3-2D63-4b58-A266-B76536F4B4C5")]
  public class BillingGroup : IBillingGroup
  {
    private int mBillingGroupID;
    public int BillingGroupID
    { 
      get { return mBillingGroupID; }
      set { mBillingGroupID = value; }
    }

    private int mIntervalID;
    public int IntervalID
    { 
      get { return mIntervalID; }
      set { mIntervalID = value; }
    }

    private string mName = null;
    public string Name
    { 
      get { return mName; }
      set { mName = value; }
    }

    private string mDescription = null;
    public string Description
    { 
      get { return mDescription; }
      set { mDescription = value; }
    }

    private BillingGroupStatus mStatus;
    public BillingGroupStatus Status
    { 
      get { return mStatus; }
      set { mStatus = value; }
    }

    private DateTime mStartDate;
    public DateTime StartDate
    { 
      get { return mStartDate; }
      set { mStartDate = value; }
    }

    private DateTime mEndDate;
    public DateTime EndDate
    { 
      get { return mEndDate; }
      set { mEndDate = value; }
    }

    private int mCycleID;
    public int CycleID
    { 
      get { return mCycleID; }
      set { mCycleID = value; }
    }

    private CycleType mCycleType;
    public CycleType CycleType
    { 
      get { return mCycleType; }
      set { mCycleType = value; }
    }

    private int mMemberCount;
    public int MemberCount
    { 
      get { return mMemberCount; }
      set { mMemberCount = value; }
    }
   
    private bool mHasChildren;
    public bool HasChildren
    { 
      get { return mHasChildren; }
      set { mHasChildren = value; }
    }

    private int mAdapterCount = 0;
    public int AdapterCount
    { 
      get { return mAdapterCount; }
      set { mAdapterCount = value; }
    }

    private int mIntervalOnlyAdapterCount = 0;
    public int IntervalOnlyAdapterCount
    { 
      get { return mIntervalOnlyAdapterCount; }
      set { mIntervalOnlyAdapterCount = value; }
    }

    private int mSucceededAdapterCount = 0;
    public int SucceededAdapterCount
    { 
      get { return mSucceededAdapterCount; }
      set { mSucceededAdapterCount = value; }
    }

    private int mFailedAdapterCount = 0;
    public int FailedAdapterCount
    { 
      get { return mFailedAdapterCount; }
      set { mFailedAdapterCount = value; }
    }

    private MaterializationType mMaterializationType = MaterializationType.None;
    public MaterializationType MaterializationType
    { 
      get { return mMaterializationType; }
      set { mMaterializationType = value; }
    }

    public BillingGroup(int billingGroupID)
    {
      this.mBillingGroupID = billingGroupID;
    }

    public override string ToString()
    {
      // TODO:  make sure all properties are here...
      return String.Format("IntervalID={0}, BillingGroupID={1}, Name={2}, Description={3}, Status={4}, CycleID={5}, CycleType={6}, StartDate={7}, EndDate={8}, MembersCount={9}",
                            mIntervalID, mBillingGroupID, mName, mDescription, mStatus, mCycleID, mCycleType, mStartDate, mEndDate, mMemberCount);
    }

    public static BillingGroupStatus ParseBillingGroupStatus(string billingGroupStatus)
    {
      if (String.Compare(billingGroupStatus, "Open", true) == 0 ||
          String.Compare(billingGroupStatus, "O", true) == 0)
        return BillingGroupStatus.Open;
      if (String.Compare(billingGroupStatus, "SoftClosed", true) == 0 ||
          String.Compare(billingGroupStatus, "Soft Closed", true) == 0 ||
          String.Compare(billingGroupStatus, "C", true) == 0)
        return BillingGroupStatus.SoftClosed;
      if (String.Compare(billingGroupStatus, "HardClosed", true) == 0 ||
          String.Compare(billingGroupStatus, "Hard Closed", true) == 0 ||
          String.Compare(billingGroupStatus, "H", true) == 0)
        return BillingGroupStatus.HardClosed;
      
      throw new System.ArgumentException
        (String.Format("Invalid Billing Group Status name {0}", billingGroupStatus));
    }

    public static MaterializationType ParseMaterializationType(string materializationType)
    {
      if (String.Compare(materializationType, MaterializationType.Full.ToString(), true) == 0)
        return MaterializationType.Full;
      if (String.Compare(materializationType, MaterializationType.PullList.ToString(), true) == 0)
        return MaterializationType.PullList;
      if (String.Compare(materializationType, MaterializationType.Rematerialization.ToString(), true) == 0)
        return MaterializationType.Rematerialization;
      if (String.Compare(materializationType, MaterializationType.UserDefined.ToString(), true) == 0)
        return MaterializationType.UserDefined;
      
      throw new System.ArgumentException
        (String.Format("Invalid billing group materialization type {0}", materializationType));
    }
    /// <summary>
    ///    Return the current row in the given rowset as an IBillingGroup.
    ///    Rowset matches the query __GET_BILLING_GROUPS__
    /// </summary>
    /// <param name="rowset"></param>
    /// <returns></returns>
    public static IBillingGroup GetBillingGroup(Rowset.IMTSQLRowset rowset)
    {
      IBillingGroup billingGroup = new BillingGroup((int)rowset.get_Value("BillingGroupID"));
      billingGroup.Name = (string)rowset.get_Value("Name");
      if (rowset.get_Value("Description") != DBNull.Value)
      {
        billingGroup.Description = (string)rowset.get_Value("Description");
      }
      billingGroup.IntervalID = (int)rowset.get_Value("IntervalID");
      billingGroup.CycleID = (int)rowset.get_Value("CycleID");

      billingGroup.CycleType = 
        CycleUtils.ParseCycleType((string)rowset.get_Value("CycleType"));

      billingGroup.Status = 
        BillingGroup.ParseBillingGroupStatus
        ((string)rowset.get_Value("Status"));

      billingGroup.MaterializationType = 
        BillingGroup.ParseMaterializationType
          ((string)rowset.get_Value("Type"));

      billingGroup.StartDate = (DateTime)rowset.get_Value("StartDate");
      billingGroup.EndDate = (DateTime)rowset.get_Value("EndDate");
      billingGroup.MemberCount = Convert.ToInt32(rowset.get_Value("MemberCount"));

      billingGroup.AdapterCount = 
        Convert.ToInt32(rowset.get_Value("AdapterCount"));

      billingGroup.IntervalOnlyAdapterCount = 
        Convert.ToInt32(rowset.get_Value("IntervalOnlyAdapterCount"));

      billingGroup.FailedAdapterCount = 
        Convert.ToInt32(rowset.get_Value("AdapterFailedCount")) + 
        Convert.ToInt32(rowset.get_Value("IntervalOnlyAdapterFailedCount"));

      billingGroup.SucceededAdapterCount = 
        Convert.ToInt32(rowset.get_Value("AdapterSucceededCount")) +
        Convert.ToInt32(rowset.get_Value("IntervalOnlyAdapterSucceedCnt"));
                               
      string hasChildren = (string)rowset.get_Value("HasChildren");
      if (hasChildren.Equals("Y")) 
      {
        billingGroup.HasChildren = true;
      }
      else 
      {
        billingGroup.HasChildren = false;
      }

      string canBeHardClosed = (string)rowset.get_Value("CanBeHardClosed");
      if (canBeHardClosed.Equals("Y"))
      {
          billingGroup.CanBeHardClosed = true;
      }
      else
      {
          billingGroup.CanBeHardClosed = false;
      }

      return billingGroup;
    }
    /// <summary>
    /// Loads billing groups from the database and 
    /// returns an array filled with IBillingGroup objects
    /// </summary>
    internal static ArrayList Load(IMTDataReader reader)
    {
      ArrayList billingGroups = new ArrayList();

      while (reader.Read())
      {
        IBillingGroup billingGroup = 
          new BillingGroup(reader.GetInt32("id_billgroup"));
        billingGroup.IntervalID = reader.GetInt32("id_interval");
        billingGroup.StartDate = reader.GetDateTime("dt_start");
        billingGroup.EndDate = reader.GetDateTime("dt_end");
        string rawStatus = reader.GetString("tx_billgroup_status");
        billingGroup.Status = 
          BillingGroup.ParseBillingGroupStatus(rawStatus);

        billingGroup.CycleID = reader.GetInt32("id_usage_cycle");
        billingGroup.CycleType = 
          (CycleType) reader.GetInt32("id_cycle_type");

        billingGroups.Add(billingGroup);
      }

      return billingGroups;
    }

    private bool mCanBeHardClosed = false;
    public bool CanBeHardClosed
    {
        get { return mCanBeHardClosed; }
        set { mCanBeHardClosed = value; }
    }
  }

  [ClassInterface(ClassInterfaceType.None)]
  [Guid("9CE8607D-114E-43be-BBF5-D890E01718AF")]
  public class Materialization : IMaterialization
  {
    private int mMaterializationID;
    public int MaterializationID
    { 
      get { return mMaterializationID; }
    }

    private int mIntervalID;
    public int IntervalID
    { 
      get { return mIntervalID; }
      set { mIntervalID = value; }
    }

    private int mAccountID;
    public int AccountID
    { 
      get { return mAccountID; }
      set { mAccountID = value; }
    }

    private string mUserName = null;
    public string UserName
    { 
      get { return mUserName; }
      set { mUserName = value; }
    }

    private string mDisplayName = null;
    public string DisplayName
    { 
      get { return mDisplayName; }
      set { mDisplayName = value; }
    }

    private string mNamespace = null;
    public string Namespace
    { 
      get { return mNamespace; }
      set { mNamespace = value; }
    }

    private DateTime mStartDate;
    public DateTime StartDate
    { 
      get { return mStartDate; }
      set { mStartDate = value; }
    }

    private DateTime mEndDate;
    public DateTime EndDate
    { 
      get { return mEndDate; }
      set { mEndDate = value; }
    }

    private int mParentBillingGroupID;
    public int ParentBillingGroupID
    { 
      get { return mParentBillingGroupID; }
      set { mParentBillingGroupID = value; }
    }

    private MaterializationStatus mMaterializationStatus;
    public MaterializationStatus MaterializationStatus
    { 
      get { return mMaterializationStatus; }
      set { mMaterializationStatus = value; }
    }

    private string mFailureReason;
    public string FailureReason
    { 
      get { return mFailureReason; }
      set { mFailureReason = value; }
    }
   
    private MaterializationType mMaterializationType;
    public MaterializationType MaterializationType
    { 
      get { return mMaterializationType; }
      set { mMaterializationType = value; }
    }

   
    public Materialization(int materializationID)
    {
      this.mMaterializationID = materializationID;
    }

    // !TODO
//    public override string ToString()
//    {
//      // TODO:  make sure all properties are here...
//      return String.Format("IntervalID={0}, BillingGroupID={1}, Name={2}, Description={3}, Status={4}, CycleID={5}, CycleType={6}, StartDate={7}, EndDate={8}, MembersCount={9}",
//        mIntervalID, mBillingGroupID, mName, mDescription, mStatus, mCycleID, mCycleType, mStartDate, mEndDate, mMemberCount);
//    }

    public static BillingGroupStatus ParseBillingGroupStatus(string billingGroupStatus)
    {
      if (String.Compare(billingGroupStatus, "Open", true) == 0)
      {
        return BillingGroupStatus.Open;
      }
      if (String.Compare(billingGroupStatus, "SoftClosed", true) == 0)
      {
        return BillingGroupStatus.SoftClosed;
      }
      if (String.Compare(billingGroupStatus, "HardClosed", true) == 0) 
      {
        return BillingGroupStatus.HardClosed;
      }
      
      throw new System.ArgumentException
        (String.Format("Invalid Billing Group Status name {0}", billingGroupStatus));
    }

    public static MaterializationStatus ParseMaterializationStatus(string materializationStatus)
    {
      if (String.Compare(materializationStatus, "InProgress", true) == 0)
      {
        return MaterializationStatus.InProgress;
      }
      if (String.Compare(materializationStatus, "Succeeded", true) == 0)
      {
        return MaterializationStatus.Succeeded;
      }
      if (String.Compare(materializationStatus, "Failed", true) == 0) 
      {
        return MaterializationStatus.Failed;
      }
      if (String.Compare(materializationStatus, "Aborted", true) == 0) 
      {
        return MaterializationStatus.Aborted;
      }
      
      throw new System.ArgumentException
        (String.Format("Invalid Materialization Status name {0}", materializationStatus));
    }

    public static MaterializationType ParseMaterializationType(string materializationType)
    {
      if (String.Compare(materializationType, "Full", true) == 0)
      {
        return MaterializationType.Full;
      }
      if (String.Compare(materializationType, "PullList", true) == 0)
      {
        return MaterializationType.PullList;
      }
      if (String.Compare(materializationType, "UserDefined", true) == 0) 
      {
        return MaterializationType.UserDefined;
      }
      if (String.Compare(materializationType, "Rematerialization", true) == 0) 
      {
        return MaterializationType.Rematerialization;
      }
      
      throw new System.ArgumentException
        (String.Format("Invalid Materialization Type name {0}", materializationType));
    }

    /// <summary>
    /// Loads materialization from the database. Expects only one row in reader with
    /// the following columns:
    ///   MaterializationID
    ///   AccountID
    ///   DisplayName
    ///   UserName
    ///   Namespace
    ///   StartDate
    ///   EndDate
    ///   ParentBillingGroupID
    ///   IntervalID
    ///   MaterializationStatus
    ///   FailureReason
    ///   MaterializationType 
    /// </summary>
    internal static IMaterialization Load(IMTDataReader reader)
    {
      IMaterialization materialization = null;
      while (reader.Read())
      {
        materialization = new Materialization(reader.GetInt32("MaterializationID"));
        materialization.AccountID = reader.GetInt32("AccountID");
        materialization.DisplayName = reader.GetString("DisplayName");
        materialization.UserName = reader.GetString("UserName");
        materialization.Namespace = reader.GetString("Namespace");
        materialization.StartDate = reader.GetDateTime("StartDate");
        materialization.EndDate = reader.GetDateTime("EndDate");

        if (!reader.IsDBNull("ParentBillingGroupID"))
        {
          materialization.ParentBillingGroupID = reader.GetInt32("ParentBillingGroupID");
        }

        materialization.IntervalID = reader.GetInt32("IntervalID");
    
        string rawStatus = reader.GetString("MaterializationStatus");
        materialization.MaterializationStatus = 
          Materialization.ParseMaterializationStatus(rawStatus);

        if (!reader.IsDBNull("FailureReason"))
        {
          materialization.FailureReason = reader.GetString("FailureReason");
        }
  
        string rawType = reader.GetString("MaterializationType");
        materialization.MaterializationType = 
          Materialization.ParseMaterializationType(rawType);
      }

      return materialization;
    }
  }


  [ClassInterface(ClassInterfaceType.None)]
  [Guid("0C02D8FC-7BC6-4fdb-9774-A0C914A7F50C")]
  public class BillingGroupFilter : IBillingGroupFilter
  {
    #region Public methods
    public BillingGroupFilter() 
    {
      ClearCriteria();
      isOracle = new ConnectionInfo("NetMeter").IsOracle;
    }

    public void ClearCriteria() 
    {
      intervalId = invalidIntervalId;
      billingGroupId = invalidBillingGroupId;
      billingGroupName = String.Empty;
      useBillingGroupName = false;
      status = String.Empty;
      useStatus = false;
      moreThanOneAccount = false;
      useMoreThanOneAccount = false;
      noAdapters = false;
      useNoAdapters = false;
      nonPullList = null;
      billingGroupOrder = BillingGroupOrder.None;
      appendAnd = false;
    }

    #endregion

    public string GetWhereClause() 
    {
      StringBuilder whereClause = new StringBuilder();

      if (intervalId != invalidIntervalId) 
      {
        AppendToWhere(whereClause, String.Format(" bg.id_usage_interval = {0} ", intervalId));
      }
      else if (billingGroupId != invalidBillingGroupId)
      {
        AppendToWhere(whereClause, String.Format(" bg.id_billgroup = {0} ", billingGroupId));
      }

      if (useBillingGroupName) 
      {
        AppendToWhere(whereClause, String.Format(" bg.tx_name = '{0}' ", billingGroupName));
      }

      if (useStatus) 
      {
        string bgStatus = GetBillingGroupStatus();
        AppendToWhere(whereClause, String.Format(" bgs.status = '{0}' ", bgStatus));
      }

      if (nonPullList != null) 
      {
        AppendToWhere(whereClause, " bg.id_parent_billgroup IS NULL ");
      }

      if (useMoreThanOneAccount) 
      {
        if (moreThanOneAccount)
        {
          AppendToWhere(whereClause, " bgAcc.numAccounts > 1 ");
        }
        else 
        {
          AppendToWhere(whereClause, " bgAcc.numAccounts = 1 ");
        }
      }

      if (useNoAdapters) 
      {
        if (noAdapters)
        {
          AppendToWhere(whereClause, "  {fn ifnull(totalAdapters.totalAdapterCount, 0)} = 0 ");
          AppendToWhere(whereClause, " {fn ifnull(totalIntervalOnlyAdapters.totalIntervalOnlyAdapterCount,0)} = 0 ");
        }
        else 
        {
          AppendToWhere(whereClause, "  {fn ifnull(totalAdapters.totalAdapterCount, 0)} > 0 ");
          AppendToWhere(whereClause, " {fn ifnull(totalIntervalOnlyAdapters.totalIntervalOnlyAdapterCount,0)} > 0 ");
        }
      }

      return whereClause.ToString();
    }

    public string GetOrderByClause() 
    {
      string orderByClause = String.Empty;

      switch(billingGroupOrder) 
      {
        case BillingGroupOrder.Name:
        {
          orderByClause = " ORDER BY bg.tx_name ";
          break;
        }
        case BillingGroupOrder.Interval:
        {
          orderByClause = " ORDER BY bg.id_usage_interval ";
          break;
        }
        default:
        {
          break;
        }
      }

      return orderByClause;
    }

    public string GetDescendantsWhereClause(int parentBillingGroupId) 
    {
      return String.Format(" WHERE bg.id_billgroup IN "
        + "(SELECT * FROM {1}GetBillingGroupDescendants({0})){2} ", 
        parentBillingGroupId, 
        isOracle ? "table(dbo." : "",
        isOracle ? ")" : "");
    }

    #region Properties
    public int IntervalId 
    {
      get 
      {
        return intervalId;
      }
      set 
      {
        if (billingGroupId != invalidBillingGroupId) 
        {
          throw new 
            UsageServerException("IntervalId filter criteria cannot be used in " +
                                 "conjunction with BillingGroupId criteria!");
        }

        intervalId = value;
      }
    }
    
    public int BillingGroupId 
    {
      get 
      {
        return billingGroupId;
      }
      set 
      {
        if (intervalId != invalidIntervalId) 
        {
          throw new 
            UsageServerException("BillingGroupId filter criteria cannot be used in " +
                                 "conjunction with IntervalId criteria!");
        }

        billingGroupId = value;
      }
    }

    public string BillingGroupName 
    {
      get 
      {
        return billingGroupName;
      }
      set 
      {
        billingGroupName = value;
        useBillingGroupName = true;
      }
    }

    public string Status 
    {
      get 
      {
        return status;
      }
      set 
      {
        status = value;
        useStatus = true;
      }
    }

    public bool MoreThanOneAccount 
    {
      get 
      {
        return moreThanOneAccount;
      }
      set 
      {
        moreThanOneAccount = value;
        useMoreThanOneAccount = true;
      }
    }

    public bool NoAdapters 
    {
      get 
      {
        return noAdapters;
      }
      set 
      {
        if (status != BillingGroupStatus.Open.ToString())
        {
          throw new UsageServerException
            ("Cannot set 'noAdapters' option on IBillingGroup when the " +
             "status is set to " + this.GetBillingGroupStatus());
                                          
        }
        noAdapters = value;
        useNoAdapters = true;
      }
    }

    public BillingGroupOrder BillingGroupOrder 
    {
      get 
      {
        return billingGroupOrder;
      }
      set 
      {
        billingGroupOrder = value;
      }
    }

    public bool NonPullList 
    {
      get 
      {
        if (nonPullList == null) 
        {
          throw new 
            UsageServerException("The non pull list criteria has not been set!");
        }
        return Convert.ToBoolean(nonPullList);
      }
      set 
      {
        nonPullList = value;
      }
    }
    #endregion

    #region Private methods
    
    private string GetBillingGroupStatus() 
    {
      string billingGroupStatus = String.Empty;

      if (status != String.Empty) 
      {
        BillingGroupStatus bgStatus = 
          BillingGroup.ParseBillingGroupStatus(status);

        switch(bgStatus) 
        {
          case BillingGroupStatus.Open: 
          {
            billingGroupStatus = "O";
            break;
          }
          case BillingGroupStatus.SoftClosed: 
          {
            billingGroupStatus = "C";
            break;
          }
          case BillingGroupStatus.HardClosed: 
          {
            billingGroupStatus = "H";
            break;
          }
          default: 
          {
            throw new 
              UsageServerException("Invalid Billing Group Status!");
          }
        }
      }

      return billingGroupStatus;
    }

    private void AppendToWhere(StringBuilder whereClause, string clause) 
    {
      if (appendAnd) 
      {
        whereClause.Append(" AND ");
        whereClause.Append(clause);
      }
      else 
      {
        whereClause.Append("WHERE ");
        whereClause.Append(clause);
        appendAnd = true;
      }
    }

    #endregion

    #region Data
    private bool isOracle;
    private int intervalId;
    private int billingGroupId;
    private string billingGroupName;
    private bool useBillingGroupName;
    private string status;
    private bool useStatus;
    private bool moreThanOneAccount;
    private bool useMoreThanOneAccount;
    private bool noAdapters;
    private bool useNoAdapters;
    private object nonPullList;
    private bool appendAnd;
    private BillingGroupOrder billingGroupOrder;
    public const int invalidBillingGroupId = -1;
    public const int invalidIntervalId = -1;
    #endregion
  }

  [ClassInterface(ClassInterfaceType.None)]
  [Guid("394BCDDA-4CAC-418d-BB6A-1492BAEC5295")]
  public class UnassignedAccountsFilter : IUnassignedAccountsFilter
  {
    #region Public methods
    public UnassignedAccountsFilter() 
    {
      ClearCriteria();
    }

    public void ClearCriteria() 
    {
      status = UnassignedAccountStatus.All;
      appendAnd = false;
    }
    #endregion

    public string GetWhereClause() 
    {
      StringBuilder whereClause = new StringBuilder();

      if (intervalId == null) 
      {
        throw new 
          UsageServerException("Interval ID not set on UnassignedAccountsFilter!", true);
      }

      AppendToWhere(whereClause, String.Format(" ua.IntervalID = {0} ", intervalId));

      if (status != UnassignedAccountStatus.All) 
      {
        string unassignedAccountStatus = GetUnassignedAccountStatus();
        AppendToWhere(whereClause, String.Format(" ua.state = '{0}' ", unassignedAccountStatus));
      }

      return whereClause.ToString();
    }

    public string GetOrderByClause() 
    {
      string orderByClause = String.Empty;
      orderByClause = " ORDER BY av.hierarchydisplayname ";
      return orderByClause;
    }

    #region Properties
    

    public UnassignedAccountStatus Status 
    {
      get 
      {
        return status;
      }
      set 
      {
        status = value;
      }
    }

    public int IntervalId 
    {
      get 
      {
        return Convert.ToInt32(intervalId);
      }
      set 
      {
        intervalId = value;
      }
    }

  
    #endregion

    #region Private methods
    
    private string GetUnassignedAccountStatus() 
    {
      string unassignedAccountStatus = String.Empty;

      switch(status) 
      {
        case UnassignedAccountStatus.Open: 
        {
          unassignedAccountStatus = "O";
          break;
        }
        case UnassignedAccountStatus.HardClosed: 
        {
          unassignedAccountStatus = "H";
          break;
        }
        default: 
        {
          throw new 
            UsageServerException("Invalid unassigned account status!", true);
        }
      }

      return unassignedAccountStatus;
    }

    private void AppendToWhere(StringBuilder whereClause, string clause) 
    {
      if (appendAnd) 
      {
        whereClause.Append(" AND ");
        whereClause.Append(clause);
      }
      else 
      {
        whereClause.Append("WHERE ");
        whereClause.Append(clause);
        appendAnd = true;
      }
    }

    #endregion

    #region Data
   
    private object intervalId;
    private UnassignedAccountStatus status;
    private bool appendAnd;
  
    #endregion
  }

  #endregion

}
