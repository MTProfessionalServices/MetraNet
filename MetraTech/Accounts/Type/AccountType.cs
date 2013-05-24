namespace MetraTech.Accounts.Type
{
  using System;
  using System.Collections;
  using System.EnterpriseServices;
  using System.Runtime.InteropServices;

  using MetraTech;
  using MetraTech.Collections;
  using MetraTech.DataAccess;
  using MetraTech.Interop.MTProductCatalog;
  using MetraTech.Pipeline;
  using MTAccountType = MetraTech.Interop.IMTAccountType;
  using MTCollection = MetraTech.Interop.GenericCollection;
  using Rowset = MetraTech.Interop.Rowset;
 
  [ComVisible(true)]
  [Guid("FDED94BA-C79E-43a4-92D6-65B16A6F2123")]
  public class AccountType : MTAccountType.IMTAccountType
  {
    static private ServiceDefinitionCollection mAvCollection = null;

    private bool mCanBePayer;
    private bool mCanSubscribe;
    private bool mCanHaveSyntheticRoot;
    private bool mCanParticipateInGSub;
    private bool mCanHaveTemplates;
    private bool mIsVisibleInHierarchy;
    private bool mIsCorporate;
    private string mName;
    private string mDescription;
    private int mID;

    private Logger mLogger;

    public AccountType()
    {
      mLogger = new Logger("[AccountType]");
    }
    public void InitializeByName(string aName)
    {
      AccountTypeReader reader = new AccountTypeReader();
      Rowset.IMTSQLRowset rowset = reader.ReadAccountTypeProperties(aName);
      rowset.MoveFirst();
      if ((string)rowset.get_Value("cansubscribe") == "1") 
        mCanSubscribe = true;
      else
        mCanSubscribe = false;

      if ((string)rowset.get_Value("canbepayer") == "1")
        mCanBePayer = true;
      else
        mCanBePayer = false;

      if ((string)rowset.get_Value("canhavesyntheticroot") == "1")
        mCanHaveSyntheticRoot = true;
      else
        mCanHaveSyntheticRoot = false;

      if ((string)rowset.get_Value("canparticipateingsub") == "1")
        mCanParticipateInGSub = true;
      else
        mCanParticipateInGSub = false;

      if ((string)rowset.get_Value("canhavetemplates") == "1")
        mCanHaveTemplates = true;
      else
        mCanHaveTemplates = false;

      if ((string)rowset.get_Value("isvisibleinhierarchy") == "1")
        mIsVisibleInHierarchy = true;
      else
        mIsVisibleInHierarchy = false;
  
      if ((string)rowset.get_Value("iscorporate") == "1")
        mIsCorporate = true;
      else
        mIsCorporate = false;

      mDescription = (string)rowset.get_Value("description");

      mName = aName;
      mID = (int)rowset.get_Value("ID");
    }

    public void InitializeByID(int aID)
    {
      AccountTypeReader reader = new AccountTypeReader();
      Rowset.IMTSQLRowset rowset = reader.ReadAccountTypeProperties(aID);
      rowset.MoveFirst();
      if ((string)rowset.get_Value("cansubscribe") == "1") 
        mCanSubscribe = true;
      else
        mCanSubscribe = false;

      if ((string)rowset.get_Value("canbepayer") == "1")
        mCanBePayer = true;
      else
        mCanBePayer = false;

      if ((string)rowset.get_Value("canhavesyntheticroot") == "1")
        mCanHaveSyntheticRoot = true;
      else
        mCanHaveSyntheticRoot = false;

      if ((string)rowset.get_Value("canparticipateingsub") == "1")
        mCanParticipateInGSub = true;
      else
        mCanParticipateInGSub = false;

      if ((string)rowset.get_Value("canhavetemplates") == "1")
        mCanHaveTemplates = true;
      else
        mCanHaveTemplates = false;

      if ((string)rowset.get_Value("isvisibleinhierarchy") == "1")
        mIsVisibleInHierarchy = true;
      else
        mIsVisibleInHierarchy = false;
  
      if ((string)rowset.get_Value("iscorporate") == "1")
        mIsCorporate = true;
      else
        mIsCorporate = false;

      mDescription = (string)rowset.get_Value("description");

      mName = (string)rowset.get_Value("name");
      mID = aID;
    }

    public void InitializeFromRowset(Rowset.IMTSQLRowset rowset)
    {
        if ((string)rowset.get_Value("cansubscribe") == "1")
            mCanSubscribe = true;
        else
            mCanSubscribe = false;

        if ((string)rowset.get_Value("canbepayer") == "1")
            mCanBePayer = true;
        else
            mCanBePayer = false;

        if ((string)rowset.get_Value("canhavesyntheticroot") == "1")
            mCanHaveSyntheticRoot = true;
        else
            mCanHaveSyntheticRoot = false;

        if ((string)rowset.get_Value("canparticipateingsub") == "1")
            mCanParticipateInGSub = true;
        else
            mCanParticipateInGSub = false;

        if ((string)rowset.get_Value("canhavetemplates") == "1")
            mCanHaveTemplates = true;
        else
            mCanHaveTemplates = false;

        if ((string)rowset.get_Value("isvisibleinhierarchy") == "1")
            mIsVisibleInHierarchy = true;
        else
            mIsVisibleInHierarchy = false;

        if ((string)rowset.get_Value("iscorporate") == "1")
            mIsCorporate = true;
        else
            mIsCorporate = false;

        mDescription = (string)rowset.get_Value("description");

        mName = (string)rowset.get_Value("name");
        mID = (int)rowset.get_Value("ID");
    }

    public bool CanBePayer {get { return mCanBePayer; }} 

    public bool CanSubscribe {get { return mCanSubscribe; }} 
   
    public bool CanHaveSyntheticRoot {get { return mCanHaveSyntheticRoot; }} 
  
    public bool CanParticipateInGSub {get {return mCanParticipateInGSub; }}

    public bool CanHaveTemplates {get {return mCanHaveTemplates; }}

    public bool IsVisibleInHierarchy {get {return mIsVisibleInHierarchy; }}

    public bool IsCorporate {get {return mIsCorporate; }}

    public string Name {get { return mName; }} 
     
    public string Description {get { return mDescription; }} 

    public int ID {get { return mID; }}
 
    public MTAccountType.IMTCollection GetAllAccountViews()
    {
      MetraTech.Interop.GenericCollection.IMTCollection accountViews = new  MetraTech.Interop.GenericCollection.MTCollectionClass();
      MTAccountType.IMTSQLRowset myrowset = GetAccountViewsAsRowset();
      if (myrowset.RecordCount > 0)
      {
        myrowset.MoveFirst();
        while(!Convert.ToBoolean(myrowset.EOF))
        {
          accountViews.Add((string)myrowset.get_Value("AccountView"));
          myrowset.MoveNext();
        }	
      }
      return (MTAccountType.IMTCollection)accountViews;
    }

    /// <summary>
    /// GetMSIXProperties - Get a ServiceDefiniton containing all properties for this AccountType
    /// </summary>
    public object GetMSIXProperties() // as ServiceDefinition
    {
      ServiceDefinition sd = GetCoreMSIXProperties() as ServiceDefinition;

      lock(typeof(ServiceDefinitionCollection))
      {
        if(mAvCollection == null)
        {
          mAvCollection = new ServiceDefinitionCollection("accountview");
        }
      }

      foreach(string viewName in GetAllAccountViews())
      {
        IServiceDefinition accountView = mAvCollection.GetServiceDefinition(viewName);
        foreach(IMTPropertyMetaData prop in accountView.Properties)
        {
          sd.Add(prop.Name, prop);
        }
      }

      return sd;
    }

    /// <summary>
    /// GetCoreMSIXProperties - Get a ServiceDefiniton containing all Core properties
    /// </summary>
    public object GetCoreMSIXProperties() // as ServiceDefinition
    {
      MetraTech.Pipeline.ServiceDefinition sd = new MetraTech.Pipeline.ServiceDefinition();
      
      // Action type is used to indicate if you want to create account, contact or both
      IMTPropertyMetaData prop = new MTPropertyMetaData();
      prop.Name = "ActionType";
      prop.DataType = PropValType.PROP_TYPE_ENUM;
      prop.EnumSpace = "metratech.com/accountcreation";
      prop.EnumType = "ActionType";
      prop.Required = true;
      prop.Length = 0;
      sd.Add(prop.Name, prop);

      // Account Type 
      prop = new MTPropertyMetaData();
      prop.Name = "AccountType";
      prop.DataType = PropValType.PROP_TYPE_STRING;
      prop.EnumSpace = null;
      prop.EnumType = null;
      prop.Required = true;
      prop.Length = 200;
      sd.Add(prop.Name, prop);

      // A number to indicate the operation: 0 for add, 1 for update, 2 for delete and 3 for no op
      prop = new MTPropertyMetaData();
      prop.Name = "operation";
      prop.DataType = PropValType.PROP_TYPE_ENUM;
      prop.EnumSpace = "metratech.com";
      prop.EnumType = "operation";
      prop.Required = true;
      prop.Length = 0;
      sd.Add(prop.Name, prop);

      // Username or login that needs to be created.  Required for creation.
      prop = new MTPropertyMetaData();
      prop.Name = "username";
      prop.DataType = PropValType.PROP_TYPE_STRING;
      prop.EnumSpace = null;
      prop.EnumType = null;
      prop.Required = false;
      prop.Length = 40;
      sd.Add(prop.Name, prop);

      // Password associated with that username or login. Required for creation.
      prop = new MTPropertyMetaData();
      prop.Name = "password_";
      prop.DataType = PropValType.PROP_TYPE_STRING;
      prop.EnumSpace = null;
      prop.EnumType = null;
      prop.Required = false;
      prop.Length = 40;
      sd.Add(prop.Name, prop);

      // Namespace uniquely identifying that username or login. Required for creation
      prop = new MTPropertyMetaData();
      prop.Name = "name_space";
      prop.DataType = PropValType.PROP_TYPE_STRING;
      prop.EnumSpace = null;
      prop.EnumType = null;
      prop.Required = false;
      prop.Length = 40;
      sd.Add(prop.Name, prop);

      // Uniquely generated account ID.  This property gets set by the pipeline
      prop = new MTPropertyMetaData();
      prop.Name = "_Accountid";
      prop.DataType = PropValType.PROP_TYPE_INTEGER;
      prop.EnumSpace = null;
      prop.EnumType = null;
      prop.Required = false;
      prop.Length = 0;
      sd.Add(prop.Name, prop);

      // Ancestor Account ID
      prop = new MTPropertyMetaData();
      prop.Name = "AncestorAccountID";
      prop.DataType = PropValType.PROP_TYPE_INTEGER;
      prop.EnumSpace = null;
      prop.EnumType = null;
      prop.Required = false;
      prop.Length = 0;
      sd.Add(prop.Name, prop);

      // This property is used to control the account start date.  This property is also used when changing the account state.
      prop = new MTPropertyMetaData();
      prop.Name = "accountstartdate";
      prop.DataType = PropValType.PROP_TYPE_DATETIME;
      prop.EnumSpace = null;
      prop.EnumType = null;
      prop.Required = false;
      prop.Length = 0;
      sd.Add(prop.Name, prop);

      // This property is used to control the end of an account state and is only used on updates.
      prop = new MTPropertyMetaData();
      prop.Name = "accountenddate";
      prop.DataType = PropValType.PROP_TYPE_DATETIME;
      prop.EnumSpace = null;
      prop.EnumType = null;
      prop.Required = false;
      prop.Length = 0;
      sd.Add(prop.Name, prop);

      // Account State (Changed in 3.0)
      prop = new MTPropertyMetaData();
      prop.Name = "AccountStatus";
      prop.DataType = PropValType.PROP_TYPE_ENUM;
      prop.EnumSpace = "metratech.com/accountcreation";
      prop.EnumType = "AccountStatus";
      prop.Required = false;
      prop.Length = 0;
      sd.Add(prop.Name, prop);

      // Only necessary while creating system accounts.  Possible values are CSR, MCM, MOM
      prop = new MTPropertyMetaData();
      prop.Name = "LoginApplication";
      prop.DataType = PropValType.PROP_TYPE_ENUM;
      prop.EnumSpace = "metratech.com/accountcreation";
      prop.EnumType = "LoginApplication";
      prop.Required = false;
      prop.Length = 0;
      sd.Add(prop.Name, prop);

      // Flag indicates whether DSP should be applied to 
			// a newly created account
			// T for Yes or success or true or 1 and 
			// F for no or failure or false or 0.  Required for creation.
      prop = new MTPropertyMetaData();
      prop.Name = "ApplyDefaultSecurityPolicy";
      prop.DataType = PropValType.PROP_TYPE_BOOLEAN;
      prop.EnumSpace = null;
      prop.EnumType = null;
      prop.Required = false;
      prop.Length = 0;
      prop.DefaultValue = true;
      sd.Add(prop.Name, prop);
      
      // This flag indicates whether account ancestor's account template should be applied to an account.
      prop = new MTPropertyMetaData();
      prop.Name = "ApplyAccountTemplate";
      prop.DataType = PropValType.PROP_TYPE_BOOLEAN;
      prop.EnumSpace = null;
      prop.EnumType = null;
      prop.Required = false;
      prop.Length = 0;
      prop.DefaultValue = false;
      sd.Add(prop.Name, prop);
     
      // Indicates whether old subscriptions will be truncated on move account action.
			// This property is only considered on account updates when account ancestor changed (Account Move).
			// This property is only considered when ApplyAccountTemplate property is set to true.
      prop = new MTPropertyMetaData();
      prop.Name = "TruncateOldSubscriptions";
      prop.DataType = PropValType.PROP_TYPE_BOOLEAN;
      prop.EnumSpace = null;
      prop.EnumType = null;
      prop.Required = false;
      prop.Length = 0;
      prop.DefaultValue = false;
      sd.Add(prop.Name, prop);

      // Transaction cookie value used for processes to enlist in DTC
   		// transaction. Should have empty value when metered.  The value gets set
   		// once the pipeline retrieves it from each machine.  The cookie is
   		// machine specific and is unique to a machine.
      prop = new MTPropertyMetaData();
      prop.Name = "transactioncookie";
      prop.DataType = PropValType.PROP_TYPE_STRING;
      prop.EnumSpace = null;
      prop.EnumType = null;
      prop.Required = false;
      prop.Length = 255;
      prop.DefaultValue = false;
      sd.Add(prop.Name, prop);

      // Get Cycle Type Properties if this type can be a payer
      if(CanBePayer)
      {
        prop = new MTPropertyMetaData();
        prop.Name = "dayofmonth";
        prop.DataType = PropValType.PROP_TYPE_INTEGER;
        prop.EnumSpace = null;
        prop.EnumType = null;
        prop.Required = false;
        sd.Add(prop.Name, prop);

        prop = new MTPropertyMetaData();
        prop.Name = "dayofweek";
        prop.DataType = PropValType.PROP_TYPE_ENUM;
        prop.EnumSpace = "Global";
        prop.EnumType = "DayOfTheWeek";
        prop.Required = false;
        sd.Add(prop.Name, prop);

        prop = new MTPropertyMetaData();
        prop.Name = "firstdayofmonth";
        prop.DataType = PropValType.PROP_TYPE_INTEGER;
        prop.EnumSpace = null;
        prop.EnumType = null;
        prop.Required = false;
        sd.Add(prop.Name, prop);

        prop = new MTPropertyMetaData();
        prop.Name = "seconddayofmonth";
        prop.DataType = PropValType.PROP_TYPE_INTEGER;
        prop.EnumSpace = null;
        prop.EnumType = null;
        prop.Required = false;
        sd.Add(prop.Name, prop);

        prop = new MTPropertyMetaData();
        prop.Name = "startmonth";
        prop.DataType = PropValType.PROP_TYPE_ENUM;
        prop.EnumSpace = "Global";
        prop.EnumType = "MonthOfTheYear";
        prop.Required = false;
        sd.Add(prop.Name, prop);

        prop = new MTPropertyMetaData();
        prop.Name = "startday";
        prop.DataType = PropValType.PROP_TYPE_INTEGER;
        prop.EnumSpace = null;
        prop.EnumType = null;
        prop.Required = false;
        sd.Add(prop.Name, prop);

        prop = new MTPropertyMetaData();
        prop.Name = "startyear";
        prop.DataType = PropValType.PROP_TYPE_INTEGER;
        prop.EnumSpace = null;
        prop.EnumType = null;
        prop.Required = false;
        sd.Add(prop.Name, prop);
      }
      
      prop = new MTPropertyMetaData();
      prop.Name = "PayerID";
      prop.DataType = PropValType.PROP_TYPE_INTEGER;
      prop.EnumSpace = null;
      prop.EnumType = null;
      prop.Required = false;
      sd.Add(prop.Name, prop);
      
      prop = new MTPropertyMetaData();
      prop.Name = "Payment_StartDate";
      prop.DataType = PropValType.PROP_TYPE_DATETIME;
      prop.EnumSpace = null;
      prop.EnumType = null;
      prop.Required = false;
      prop.Length = 0;
      sd.Add(prop.Name, prop);

      prop = new MTPropertyMetaData();
      prop.Name = "Payment_EndDate";
      prop.DataType = PropValType.PROP_TYPE_DATETIME;
      prop.EnumSpace = null;
      prop.EnumType = null;
      prop.Required = false;
      prop.Length = 0;
      sd.Add(prop.Name, prop);
        
      prop = new MTPropertyMetaData();
      prop.Name = "Hierarchy_StartDate";
      prop.DataType = PropValType.PROP_TYPE_DATETIME;
      prop.EnumSpace = null;
      prop.EnumType = null;
      prop.Required = false;
      prop.Length = 0;
      sd.Add(prop.Name, prop);
          
      prop = new MTPropertyMetaData();
      prop.Name = "Hierarchy_EndDate";
      prop.DataType = PropValType.PROP_TYPE_DATETIME;
      prop.EnumSpace = null;
      prop.EnumType = null;
      prop.Required = false;
      prop.Length = 0;
      sd.Add(prop.Name, prop);

      return sd;
    }

    //rowset returned has column : AccountView. It can have 0 rows!
    public MTAccountType.IMTSQLRowset GetAccountViewsAsRowset()
    {
      AccountTypeReader reader = new AccountTypeReader();
      return (MTAccountType.IMTSQLRowset )reader.GetAccountViewsForType(mName);
    }

    //rowset returned has columns: Operation ServiceDefinition. It cannot have 0 rows, at least one service def needed, except for the root account type
    public MTAccountType.IMTSQLRowset  GetServiceDefinitionsAsRowset()
    {
      AccountTypeReader reader = new AccountTypeReader();
      return (MTAccountType.IMTSQLRowset )reader.GetServiceDefinitionsForType(mName); 
    }
    //rowset returnded has one column : DescendentAccountTypeName.  It can have 0 rows.
    public MTAccountType.IMTSQLRowset  GetDescendentAccountTypesAsRowset()
    {
      AccountTypeReader reader = new AccountTypeReader();
      return (MTAccountType.IMTSQLRowset)reader.GetDescendentTypesForType(mName);
    }
    public MTAccountType.IMTSQLRowset GetAllDescendentAccountTypesAsRowset()
    {
      AccountTypeReader reader = new AccountTypeReader();
      return (MTAccountType.IMTSQLRowset) reader.GetAllDescendentsTypesForType(mName);
    }
    public MTAccountType.IMTSQLRowset GetDirectDescendentsWithOperationAsRowset(string operation)
    {
      AccountTypeReader reader = new AccountTypeReader();
      return (MTAccountType.IMTSQLRowset) reader.GetDirectDescendentsWithOp(operation, mName);
    }
  }

	[ComVisible(true)]
	[Guid("48b285ee-1cd2-4ee9-81dd-acb6e8e89111")]
	public interface IAccountTypeReader
	{
		Rowset.IMTSQLRowset ReadAccountTypeProperties(string typeName);
		Rowset.IMTSQLRowset ReadAccountTypeProperties(int typeID);
		Rowset.IMTSQLRowset GetAccountViewsForType(string typeName);
		Rowset.IMTSQLRowset GetServiceDefinitionsForType(string typeName);
		Rowset.IMTSQLRowset GetAccountTypes();
		Rowset.IMTSQLRowset GetAccountTypeViewMappingsAsRowset();
    Rowset.IMTSQLRowset GetDescendentTypesForType(string typeName);
    Rowset.IMTSQLRowset GetAllDescendentsTypesForType(string typeName);
		Rowset.IMTSQLRowset GetCommonAccountViewTables(string viewtablename);
    Rowset.IMTSQLRowset GetDirectDescendentsWithOp(string operation, string typeName);
	}
  [ComVisible(true)]
  [Guid("C61829D5-6AF4-451a-B6C4-01AC3B6063A5")]
  [Transaction(TransactionOption.Supported, Timeout=0, Isolation=TransactionIsolationLevel.Any)]
	[ClassInterface(ClassInterfaceType.None)]
  public class AccountTypeReader : ServicedComponent, IAccountTypeReader
  {
    public AccountTypeReader()
    {}

    [AutoComplete]
    public Rowset.IMTSQLRowset ReadAccountTypeProperties(string typeName)
    {
      Rowset.IMTSQLRowset myrowset = new Rowset.MTSQLRowset();
      myrowset.Init(@"queries\account");
      myrowset.SetQueryTag("__FIND_ACCOUNT_TYPE_PROPERTIES__");
      myrowset.AddParam("%%ACCOUNT_TYPE_NAME%%", typeName, false);
      myrowset.Execute();
      if (myrowset.RecordCount != 1)
        throw new ApplicationException(string.Format("Could not find this account type {0}", typeName)); 
      return myrowset;
    }

    [AutoComplete]
    public Rowset.IMTSQLRowset ReadAccountTypeProperties(int typeID)
    {
      Rowset.IMTSQLRowset myrowset = new Rowset.MTSQLRowset();
      myrowset.Init(@"queries\account");
      myrowset.SetQueryTag("__FIND_ACCOUNT_TYPE_PROPERTIES_BYID__");
      myrowset.AddParam("%%ACCOUNT_TYPE_ID%%", typeID, false);
      myrowset.Execute();
      if (myrowset.RecordCount != 1)
        throw new ApplicationException(string.Format("Could not find this account type {0}", typeID.ToString())); 
      return myrowset;
    }

    [AutoComplete]
    public Rowset.IMTSQLRowset GetAccountViewsForType(string typeName)
    {
      Rowset.IMTSQLRowset myrowset = new Rowset.MTSQLRowset();
      myrowset.Init(@"queries\account");
      myrowset.SetQueryTag("__FIND_ACCOUNT_VIEWS_FOR_TYPE__");
      myrowset.AddParam("%%ACCOUNT_TYPE_NAME%%", typeName, false);
      myrowset.Execute();
   
      return myrowset;

    }
 
    [AutoComplete]
    public Rowset.IMTSQLRowset GetServiceDefinitionsForType(string typeName)
    {
      Rowset.IMTSQLRowset myrowset = new Rowset.MTSQLRowset();
      myrowset.Init(@"queries\account");
      myrowset.SetQueryTag("__FIND_SERVICE_DEFINTIONS_FOR_TYPE__");
      myrowset.AddParam("%%ACCOUNT_TYPE_NAME%%", typeName, false);
      myrowset.Execute();
      if (myrowset.RecordCount <= 0)
        throw new ApplicationException(string.Format("Could not find service definitions for account type {0}", typeName)); 
      return myrowset;

    }

    [AutoComplete]
    public Rowset.IMTSQLRowset GetAccountTypes()
    {
      Rowset.IMTSQLRowset myrowset = new Rowset.MTSQLRowset();
      myrowset.Init(@"queries\account");
      myrowset.SetQueryTag("__FIND_ACCOUNT_TYPES__");
      myrowset.Execute();
      return myrowset;

    }
		[AutoComplete]
		public Rowset.IMTSQLRowset GetAccountTypeViewMappingsAsRowset()
		{
			Rowset.IMTSQLRowset myrowset = new Rowset.MTSQLRowset();
			myrowset.Init(@"queries\account");
			myrowset.SetQueryTag("__GET_ACCOUNT_TYPE_VIEW_MAPPINGS__");
			myrowset.Execute();
			return myrowset;

		}

    [AutoComplete]
    public Rowset.IMTSQLRowset GetDescendentTypesForType(string typeName)
    {
      Rowset.IMTSQLRowset myrowset = new Rowset.MTSQLRowset();
      myrowset.Init(@"queries\account");
      myrowset.SetQueryTag("__FIND_DESCENDENT_ACCOUNT_TYPES_FOR_TYPE__");
      myrowset.AddParam("%%ACCOUNT_TYPE_NAME%%", typeName, false);
      myrowset.Execute();
      return myrowset;

    }

    [AutoComplete]
    public Rowset.IMTSQLRowset GetAllDescendentsTypesForType(string typeName)
    {
      Rowset.IMTSQLRowset myrowset = new Rowset.MTSQLRowset();
      myrowset.Init(@"queries\account");
      myrowset.SetQueryTag("__FIND__ALL_DESCENDENT_ACCOUNT_TYPES_FOR_TYPE__");
      myrowset.AddParam("%%ACCOUNT_TYPE_NAME%%", typeName, false);
      myrowset.Execute();
      return myrowset;
    }

		[AutoComplete]
		public Rowset.IMTSQLRowset GetCommonAccountViewTables(string viewtablename)
		{
			Rowset.IMTSQLRowset myrowset = new Rowset.MTSQLRowset();
			myrowset.Init(@"queries\account");
			myrowset.SetQueryTag("__GET_COMMON_ACCOUNT_VIEW_TABLES__");
			myrowset.AddParam("%%ACCOUNT_VIEW_TABLE_NAME%%", viewtablename, false);
			myrowset.Execute();
			return myrowset;

		}

    [AutoComplete]
    public Rowset.IMTSQLRowset GetDirectDescendentsWithOp(string operation, string typeName)
    {
      Rowset.IMTSQLRowset myrowset = new Rowset.MTSQLRowset();
      myrowset.Init(@"queries\account");
      myrowset.SetQueryTag("__GET_DIRECT_DESCENDENTS_WITH_OP__");
      myrowset.AddParam("%%OPERATION%%", operation, false);
      myrowset.AddParam("%%ACCOUNT_TYPE_NAME%%", typeName, false);
      myrowset.Execute();
      return myrowset;
    }

		
  }


   [ComVisible(true)]
  [Guid("F66FB0FE-3AB1-4d99-BF7A-DBC2DEB6CF2B")]
  public interface IAccountTypeCollection
  {
    MTAccountType.IMTAccountType GetAccountType(string typeName);
    IEnumerable Names{get;}
    IEnumerable AccountTypes { get; }
  }
   [ComVisible(true)]
  [Guid("FE980AD7-2FC2-488c-AF04-47997CEF2D72")]
  [ClassInterface(ClassInterfaceType.None)]
  public class AccountTypeCollection : IAccountTypeCollection
  {

    public AccountTypeCollection()
    {
      Initialize();
    }


   public MTAccountType.IMTAccountType GetAccountType(string typeName)
    {
      MTAccountType.IMTAccountType aType = (MTAccountType.IMTAccountType) mAccountTypes[typeName];
      return aType;
    }

    public IEnumerable Names
    {
      get
      {
        return mAccountTypes.Keys;
      }
    }

    public IEnumerable AccountTypes
    {
        get
        {
            return mAccountTypes.Values;
        }
    }

    private void Initialize()
    {
        lock (mAccountTypes)
        {
            if (!mInitialized)
            {
                //call the account type reader to run a query to get the names of all account types
                //foreach name, create the object, call InitializeByName and add to the collection

                MetraTech.Accounts.Type.AccountTypeReader reader = new MetraTech.Accounts.Type.AccountTypeReader();
                Rowset.IMTSQLRowset myrowset = reader.GetAccountTypes();
                if (myrowset.RecordCount <= 0)
                    throw new ApplicationException("Could not find any account types in the database!");

                while (!Convert.ToBoolean(myrowset.EOF))
                {
                    string typeName = (string)myrowset.get_Value("name");
                    MetraTech.Accounts.Type.AccountType accountTypeObject = new MetraTech.Accounts.Type.AccountType();
                    accountTypeObject.InitializeFromRowset(myrowset);
                    mAccountTypes[typeName] = (MTAccountType.IMTAccountType)accountTypeObject;
                    myrowset.MoveNext();
                }
                mInitialized = true;
            }
        }
    }
    // mapping of account type names to account type objects.
    // key is the string identifying the name of the account type.  Note - it is NOT case sensitive.
     private static Hashtable mAccountTypes = new Hashtable(new CaseInsensitiveHashCodeProvider(), new CaseInsensitiveComparer());
     private static bool mInitialized = false;
  
  }
}


