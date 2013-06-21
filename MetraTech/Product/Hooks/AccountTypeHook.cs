using System;
using System.Runtime.InteropServices;
using System.Collections;
using System.Collections.Specialized;
using System.Text;
using MetraTech;
using MetraTech.Collections;
using MetraTech.Xml;
using System.Xml;
using MetraTech.Pipeline;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.DataAccess;
using System.Collections.Generic;

namespace MetraTech.Product.Hooks
{

  [ComVisible(false)]
  public class AVDDLCreator
  {
    public AVDDLCreator(string prefix, IServiceDefinition serviceDef)
    {
      mTablePrefix = prefix;
      mServiceDef = serviceDef;
      connInfo = new ConnectionInfo(Common.NetMeterDb);
    }

    public string GenerateCreateTableStatement()
    {
      // for each property in the service def, add a column, take type,
      // length, required/notrequired into account.
      StringBuilder additionalProps = new StringBuilder();
      StringBuilder columnsDescription = new StringBuilder();
      foreach (IMTPropertyMetaData propMeta in mServiceDef.OrderedProperties)
      {
        additionalProps.Append(GetPropDDL(propMeta));
        columnsDescription.AppendLine(DDLCreator.GenerateColumnDescriptionQuery(GetTableName(), propMeta));
      }

      // trace: Console.WriteLine("\n---8<--query-\n" + query.ToString() + "\n-query-->8---\n");

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(
               Common.AccountQueryPath, "__CREATE_ACCOUNT_VIEW_TABLE_IF_NOT_EXISTS__"))
          {
              var tableName = GetTableName();
              stmt.AddParam(Common.TableNameParam, tableName);
              stmt.AddParam(Common.AdditionalColumnsParam, additionalProps.ToString(), true);
              // makes id_acc and any other property that has the "partofkey" attribute as the primary key
              stmt.AddParam(Common.PartOfKeyParam, GeneratePartOfPrimary(), true);
              //generates additional foreign keys if specified
              stmt.AddParam(Common.ForiegnConstrainsParam, GetForeignConstraintsDDL(), true);
              //generates additional single indexes if specified
              stmt.AddParam(Common.SingleIndexesParam, GetSingleIndexesDDL(), true);
              //generates additional composite indexes if specified
              stmt.AddParam(Common.CompositeIndexesParam, GetCompositeIndexesDDL(), true);
              // adds table description
              var createTableDesciption = DDLCreator.GenerateTableDescriptionQuery(tableName,
                                                                                   mServiceDef.Description.Trim());
              stmt.AddParam(Common.CreateTableDescriptionParam, createTableDesciption, true);
              // adds create columns description
              stmt.AddParam(Common.CreateColumnsDescriptionParam, columnsDescription.ToString(), true);

              return stmt.Query;
          } // using IMTAdapterStatement
      }	// using connection
    }
   
     private string GeneratePartOfPrimary()
    {
      // separate from previous clause
      StringBuilder query = new StringBuilder();

      foreach (IMTPropertyMetaData propMeta in mServiceDef.OrderedProperties)
      {
        IMTAttributes attributes= propMeta.Attributes;
        if(attributes.Exists("partofkey"))
        {
          if (IsTrue(((IMTAttribute) attributes["partofkey"]).Value))
          {
             query.AppendFormat(" , c_{0}", propMeta.Name);
          }
        }
      }

      return query.ToString();
    }

    private string GetForeignConstraintsDDL()
    {
      StringBuilder foreignKeyQuery = new StringBuilder();
			using(IMTConnection conn = ConnectionManager.CreateConnection())
			{
				int count = 1;
				string tablename = GetTableName();

                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(
                    Common.AccountQueryPath, "__ADD_ACCOUNT_VIEW_FK__"))
                {

                    foreach (IMTPropertyMetaData propMeta in mServiceDef.OrderedProperties)
                    {
                        IMTAttributes attributes = propMeta.Attributes;
                        if (attributes.Exists("reference") && attributes.Exists("ref_column"))
                        {
                            string refTableName = ((IMTAttribute)attributes["reference"]).Value.ToString();
                            string refColumnName = ((IMTAttribute)attributes["ref_column"]).Value.ToString();

                            stmt.ClearQuery();

                            stmt.AddParam(Common.AccViewNameParam, tablename, false);

                            string keyName = String.Format("{0}_FK{1}", tablename, count);
                            stmt.AddParam(Common.FkNameParam, keyName, false);

                            stmt.AddParam(Common.AccViewColumnNameParam, ("c_" + propMeta.Name), false);

                            stmt.AddParam(Common.ForiegnTableParam, refTableName, false);
                            stmt.AddParam(Common.ForiegnColumnParam, refColumnName, false);

                            foreignKeyQuery.Append(stmt.Query + " ");

                        }	// if reference exists
                    }	// foreach prop
                } // using IMTAdapterStatement
			}	// using connection
      return foreignKeyQuery.ToString();
    }

    private string GetSingleIndexesDDL()
    {
      StringBuilder singleIndexQuery = new StringBuilder(); 
			using(IMTConnection conn = ConnectionManager.CreateConnection())
			{
				string tablename = GetTableName();
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(
                    Common.AccountQueryPath, "__ADD_ACCOUNT_VIEW_SINGLE_INDEX__"))
                {

                    foreach (IMTPropertyMetaData propMeta in mServiceDef.OrderedProperties)
                    {
                        IMTAttributes attributes = propMeta.Attributes;
                        if (attributes.Exists("index"))
                        {
                            IMTAttribute indexAttr = (IMTAttribute)attributes["index"];
                            string indexType = indexAttr.Value.ToString().ToUpper();
                            if (indexType == "SINGLE")
                            {
                                stmt.ClearQuery();
                                stmt.AddParam(Common.AccViewNameParam, tablename, false);

                                string columnName = "c_" + propMeta.Name;
                                string suffix = columnName.Substring(0, 4);
                                stmt.AddParam(Common.IndexSuffixParam, suffix, false);
                                stmt.AddParam(Common.IndexColumnParam, columnName, false);

                                singleIndexQuery.Append(stmt.Query + " ");
                            }
                        } // if attribute exists
                    }	// foreach metadata property
                } // using IMTAdapterStatement
			}	// using connection
      return singleIndexQuery.ToString();
    }

    private string GetCompositeIndexesDDL()
    {
      StringBuilder compositeIndexQuery = new StringBuilder();
      StringBuilder suffix = new StringBuilder();
      StringBuilder columnNames = new StringBuilder();

      bool isSecondOrMore = false;
      bool isCreateQuery = false;
      foreach(IMTPropertyMetaData propMeta in mServiceDef.OrderedProperties)
      {
        IMTAttributes attributes= propMeta.Attributes;
        if(attributes.Exists("index")
            && IsComposite(((IMTAttribute)attributes["index"]).Value))
        {
            isCreateQuery = true;

            if(isSecondOrMore)
            {
              suffix.Append("_");
              columnNames.Append(", ");
            }
            else
              isSecondOrMore = true;

            string columnName = "c_" + propMeta.Name;
            suffix.Append(columnName.Substring(0,4));
            columnNames.Append(columnName);
        }
      }
      
      if (isCreateQuery)
      {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
              using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(
                  Common.AccountQueryPath, "__ADD_ACCOUNT_VIEW_COMPOSITE_INDEX__"))
              {
                  stmt.AddParam(Common.AccViewNameParam, GetTableName(), false);
                  stmt.AddParam(Common.IndexSuffixParam, suffix.ToString(), false);
                  stmt.AddParam(Common.IndexColumnParam, columnNames.ToString(), false);
                  compositeIndexQuery.Append(stmt.Query);
              }
          }
      }
      return compositeIndexQuery.ToString();
     }

    private bool IsComposite(object value)
    {
        string strValue = value.ToString().ToUpper().Trim();
        return strValue == "COMPOSITE" 
            || strValue == "SINGLECOMPOSITE";
    }

    private bool IsTrue(object value)
    {
        string strValue = value.ToString().ToUpper().Trim();
        return strValue == "Y"
               || strValue == "YES"
               || strValue == "T"
               || strValue == "TRUE";
    }

    private string GetPropDDL(IMTPropertyMetaData prop)
    {
      StringBuilder propDDL = new StringBuilder();
			string datatype = "forgot to set this?";
			
			// separate from previous clause
			propDDL.Append(",\n   ");
			
			propDDL.Append("c_" + prop.Name + " ");

      switch (prop.DataType)
      {
        case PropValType.PROP_TYPE_STRING:
					if (connInfo.IsOracle)
						datatype = "nvarchar2";
					else
						datatype = "nvarchar";
					propDDL.Append(datatype + "(" + prop.Length +")");
					break;
				case PropValType.PROP_TYPE_ENUM:
				case PropValType.PROP_TYPE_INTEGER:
					if (connInfo.IsOracle)
						datatype = "number(10)";
					else
						datatype = "integer";
					propDDL.Append(datatype);
					break;
        case PropValType.PROP_TYPE_BIGINTEGER:
					if (connInfo.IsOracle)
						datatype = "number(20)";
					else
						datatype = "bigint";
					propDDL.Append(datatype);
          break;
        case PropValType.PROP_TYPE_DATETIME:
				case PropValType.PROP_TYPE_TIME:
					if (connInfo.IsOracle)
						datatype = "date";
					else
						datatype = "datetime";
					propDDL.Append(datatype);
          break;
        case PropValType.PROP_TYPE_BOOLEAN:
          propDDL.Append("char(1)");
          break;
        case PropValType.PROP_TYPE_DOUBLE:
        case PropValType.PROP_TYPE_DECIMAL:
          propDDL.Append(Constants.METRANET_NUMERIC_PRECISION_AND_SCALE_MAX_STR);
          break;
      }
      if (prop.Required)
        propDDL.Append(" not null");

      return propDDL.ToString();
    }

    public string GetTableName()
    {
      //truncate the name to 19 characters. This is done to preserve the backwards compatibility with the old code
      // in MSIXDefinition.cpp.  Oracle can handle 30 characters, but the old code restricted it to 23/24 chars only.
    
      return mTablePrefix + mServiceDef.TableName;
    }

    private string mTablePrefix;
    private IServiceDefinition mServiceDef;
    private ConnectionInfo connInfo;
  }


  [ComVisible(false)]
  public class AccountTypeHelper
  { 
    private string mCanBePayer;
    private string mCanSubscribe;
    private string mCanHaveSyntheticRoot;
    private string mCanParticipateInGSub;
    private string mCanHaveTemplates;
    private string mIsCorporate;
    private string mIsVisibleInHierarchy;
    private string mName;
    private string mDescription;
    private NameValueCollection operationServiceDefPairs = new NameValueCollection();
    private MTStringCollection mAccountViews = new MTStringCollection();
    private MTStringCollection mDescendentTypes = new MTStringCollection();
    private MTStringCollection mAncestorTypes = new MTStringCollection();
		private Dictionary<string, string> _accountViewsNames = new Dictionary<string, string>();

    public string CanBePayer {get {return mCanBePayer; }}
    public string CanSubscribe {get {return mCanSubscribe; }}
    public string CanHaveSyntheticRoot {get {return mCanHaveSyntheticRoot; }}
    public string CanParticipateInGSub {get {return mCanParticipateInGSub; }}
    public string CanHaveTemplates {get {return mCanHaveTemplates; }}
    public string IsCorporate {get {return mIsCorporate; }}
    public string IsVisibleInHierarchy {get {return mIsVisibleInHierarchy; }}
    public string Name {get {return mName; }}
    public string Desc {get {return mDescription; }}
    public NameValueCollection ServiceDefOpPair {get {return operationServiceDefPairs; }}
    public MTStringCollection AccountViews {get {return mAccountViews; }}
    public MTStringCollection DescendentTypes {get {return mDescendentTypes; }}
    public MTStringCollection AncestorTypes { get { return mAncestorTypes; } }
		public Dictionary<string, string> AccountViewsNames { get { return _accountViewsNames; } }

    public AccountTypeHelper(string name, string desc, string canBePayer, string canSubscribe, 
                            string canHaveSyntheticRoot, string CanParticipateInGSub, string CanHaveTemplates,
                            string IsCorporate, string IsVisibleInHierarchy)
    {
      mCanBePayer = canBePayer;
      mCanSubscribe = canSubscribe;
      mCanHaveSyntheticRoot = canHaveSyntheticRoot;
      mIsCorporate = IsCorporate;
      mIsVisibleInHierarchy = IsVisibleInHierarchy;
      mCanParticipateInGSub = CanParticipateInGSub;
      mCanHaveTemplates = CanHaveTemplates;

      mName = name;
      mDescription = desc;
    }
    public void AddServiceDefOpPair(string servicename, string operation)
    {
      operationServiceDefPairs[operation] = servicename;
    }
    public void AddAccountView(string accountviewname)
    {
      mAccountViews.Add(accountviewname);
    }
    public void AddDescendentType(string descendentname)
    {
      mDescendentTypes.Add(descendentname);
    }

    public void AddAncestorType(string ancestorName)
    {
      mAncestorTypes.Add(ancestorName);
    }
  }


  
  [ComVisible(false)]
  public class AccountTypeFileReader
  {
    public  AccountTypeHelper ReadAccounTypeConfigFile(string filename)
    {
      MTXmlDocument doc = new MTXmlDocument();
      try 
      {
      doc.Load(filename);

      string name = doc.GetNodeValueAsString("//AccountType/Name");
      string desc = doc.GetNodeValueAsString("//Description");

      string canBePayer;
      if(doc.GetNodeValueAsBool("//CanBePayer")) canBePayer = "1"; else canBePayer = "0";

      string canSubscribe;
      if(doc.GetNodeValueAsBool("//CanSubscribe")) canSubscribe = "1"; else canSubscribe = "0";

      string canHaveSyntheticRoot;
      if(doc.GetNodeValueAsBool("//CanHaveSyntheticRoot")) canHaveSyntheticRoot = "1"; else canHaveSyntheticRoot = "0";

      string isCorporate;
      if(doc.GetNodeValueAsBool("//IsCorporate")) isCorporate = "1"; else isCorporate = "0";

      string isVisibleInHieararchy;
      if(doc.GetNodeValueAsBool("//IsVisibleInHierarchy")) isVisibleInHieararchy = "1"; else isVisibleInHieararchy = "0";

      string canHaveTemplates;
      if(doc.GetNodeValueAsBool("//CanHaveTemplates")) canHaveTemplates = "1"; else canHaveTemplates = "0";

      string canParticipateInGsub;
      if(doc.GetNodeValueAsBool("//CanParticipateInGSub")) canParticipateInGsub = "1"; else canParticipateInGsub = "0";

      AccountTypeHelper thisAccount = new AccountTypeHelper(name, desc, canBePayer, canSubscribe, 
        canHaveSyntheticRoot, canParticipateInGsub, canHaveTemplates,
        isCorporate, isVisibleInHieararchy);

      XmlNodeList nodeList = doc.SelectNodes("//AccountType/ServiceDefinitions/ServiceDef");
      foreach (XmlNode ServiceDef in nodeList)
      {
        XmlNode op = ServiceDef.SelectSingleNode("Operation");
          if (op == null)
            throw new ApplicationException (string.Format("Could not find tag {0}, ", "Operation"));
        string operation = op.InnerText;

        XmlNode service = ServiceDef.SelectSingleNode("Name");
          if (service == null)
              throw new ApplicationException (string.Format("Could not find tag {0}, ", "Name"));
        string servicename = service.InnerText;

        if((servicename.Length > 0) && (operation.Length > 0))
        {
          thisAccount.AddServiceDefOpPair(servicename, operation);
        }
      }

      XmlNodeList anotherNodeList = doc.SelectNodes("//AccountType/AccountViews/AdapterSet");
      foreach (XmlNode adapterset in anotherNodeList)
      {
        XmlNode nodeViewName = adapterset.SelectSingleNode("ConfigFile");
          if (nodeViewName == null)
              throw new ApplicationException (string.Format("Could not find tag {0}, ", "ConfigFile"));
        if(nodeViewName.InnerText.Length > 0)
        {
          thisAccount.AddAccountView(nodeViewName.InnerText);
        }

					XmlNode nodeRealViewName = adapterset.SelectSingleNode("Name");
					if (nodeRealViewName == null)
						throw new ApplicationException(string.Format("Could not find tag {0}, ", "Name"));

					if (!string.IsNullOrEmpty(nodeRealViewName.InnerText))
					{
						thisAccount.AccountViewsNames[nodeViewName.InnerText] = nodeRealViewName.InnerText;
					}
      }

      XmlNodeList yetAnotherNodeList = doc.SelectNodes("//AccountType/DirectDescendentAccountTypes/Descendent");
      foreach (XmlNode nodeDescendentAccount in yetAnotherNodeList)
      {
        XmlNode nameNode = nodeDescendentAccount.SelectSingleNode("Name");
        if(nameNode.InnerText.Length > 0)
        {
          thisAccount.AddDescendentType(nameNode.InnerText);
        }
      }

      XmlNodeList yetAnotherAnotherNodeList = doc.SelectNodes("//AccountType/DirectAncestorAccountTypes/Ancestor");
      foreach (XmlNode nodeDescendentAccount in yetAnotherAnotherNodeList)
      {
        XmlNode nameNode = nodeDescendentAccount.SelectSingleNode("Name");
        if (nameNode.InnerText.Length > 0)
        {
          thisAccount.AddAncestorType(nameNode.InnerText);
        }
      }
      return thisAccount;
    }
      catch(System.Exception ex)
      {
        throw new ApplicationException (string.Format("{0}/ Incorrectly configured account type file, {1}.", ex.ToString(), filename));
      }
    
    }
   
  }

  [Guid("546B1BCF-3688-4ba4-B7AD-3D1B8C5EEC8B")]
  public interface IAccountTypeHook : MetraTech.Interop.MTHooklib.IMTHook
  {
  }

  /// <summary>
  /// Summary description for AccountTypeHook
  /// </summary>
  [Guid("EF8B5630-8727-42be-B4B8-8E653202F850")]
  [ClassInterface(ClassInterfaceType.None)]
  public class AccountTypeHook : IAccountTypeHook
  {
    private MetraTech.Logger mLog;
    private ServiceDefinitionCollection mAvCollection;

    // use string case-insensitive collections
    private NameValueCollection mAccountTypesFromFiles = new NameValueCollection(new CaseInsensitiveHashCodeProvider(), new CaseInsensitiveComparer()); //key is accounttypename
    private MTStringCollection mAccounTypesInDB = new MTStringCollection();
    private MTStringCollection mAccountTypesToAdd = new MTStringCollection();
    private MTStringCollection mAccountTypesToDelete = new MTStringCollection();
    private MTStringCollection mAccountTypesToUpdate = new MTStringCollection();
    
    IMTConnection mConn = null;

		public AccountTypeHook()
    {
      mLog = new Logger("[AccountTypeHook]");
    }

    private struct UpdatePossibilities
    {
      //no default constructor created, all flags are automatically initialized to false
      public bool updateNeeded;
      public bool propertiesNeedUpdate;
      public bool propertiesUpdateYesToNo;
      public bool viewsToBeAdded;
      public bool viewsToBeDeleted;
      public bool viewsToBeUpdated;
      public bool opsToBeAdded;     // new op service def pair to be added
      public bool opsToBeDeleted;   // op service def pair to be deleted
      public bool opsToBeModified;  // for the same operation, a new servicedef
      public bool childToBeAdded;
//      public bool childToBeDeleted;
    }

    private void InitAccountTypeList()
    {
      string query;
      query = "config\\AccountType\\*.xml";

      foreach (string filename in MTXmlDocument.FindFilesInExtensions(query))
      {
        string accountTypeName = FilenameToDefName(filename);
        mAccountTypesFromFiles[accountTypeName] = filename;
      }
    }

    private string FilenameToDefName(string filename)
    {
      // r:\extensions\account\config\AccountType\metratech.com\CoreSubscriber.xml
      int delim = filename.IndexOf("AccountType\\");

      if (delim == -1)
        throw new System.ArgumentException(filename +
          " is not a valid account type name");

      // don't want the namespace, if any
      // and we are assuming no backward slashes in the name!!
      delim = filename.LastIndexOf("\\");

      string suffix = filename.Substring(delim + 1);
      suffix = suffix.Replace(".xml", "");

      return suffix;
    }

     //TODo: This will need to change when the t_account has id_account_type as int.
    private bool DoAccountsOfThisTypeExist(string accountTypeName)
    {
        using (IMTAdapterStatement stmt = mConn.CreateAdapterStatement(
            @"Queries\Account", "__SELECT_FROM_ACCOUNT_BY_TYPE__"))
        {

            stmt.AddParam("%%ACCTYPENAME%%", accountTypeName, false);

            bool accountsExist = false;
            using (IMTDataReader rdr = stmt.ExecuteReader())
                accountsExist = rdr.Read();

            return accountsExist;
        }
    }

    private bool ChecksumMatches(string accountViewName, string filechkSum)
    {
      bool chkSumSame = false;
      using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTAdapterStatement adapstmt = conn.CreateAdapterStatement("queries\\AccountView", "__SELECT_CHECKSUM_FROM_AV_LOG__"))
          {
              adapstmt.AddParam("%%AV_NAME%%", accountViewName);
              using (IMTDataReader reader = adapstmt.ExecuteReader())
              {
                  string dbchecksum = null;
                  if (reader.Read())
                      dbchecksum = reader.GetString("tx_checksum");
                  if (dbchecksum == filechkSum)
                  {
                      chkSumSame = true;
                  }
              }
          }
      }

      return chkSumSame;

    }

    private UpdatePossibilities CheckForUpdate(AccountTypeHelper currentAccountType)
    {
      UpdatePossibilities updateFlags = new UpdatePossibilities();
      //fill the structure in
      /////////////////
      ///          

      //deal with possible update of properties.
      //need to figure out if properties were updated and if any were updated from yes to no.
      string cansubscribe, canbepayer, canhavesyntheticroot, canHaveTemplates, canParticipateInGSub, isCorporate, isVisibleInHierarchy;
      string description;

      using (IMTAdapterStatement stmt = mConn.CreateAdapterStatement(@"queries\Account",
          "__FIND_ACCOUNT_TYPE_PROPERTIES__"))
      {

          stmt.AddParam("%%ACCOUNT_TYPE_NAME%%", currentAccountType.Name, false);

          using (IMTDataReader rdr = stmt.ExecuteReader())
          {
              if (!rdr.Read())
                  throw new ApplicationException(string.Format(
                      "Could not find properties for account type {0}", currentAccountType.Name));

              cansubscribe = rdr.GetString("cansubscribe");
              canbepayer = rdr.GetString("canbepayer");
              canhavesyntheticroot = rdr.GetString("canhavesyntheticroot");
              canHaveTemplates = rdr.GetString("canhavetemplates");
              canParticipateInGSub = rdr.GetString("canparticipateingsub");
              isVisibleInHierarchy = rdr.GetString("isvisibleinhierarchy");
              isCorporate = rdr.GetString("iscorporate");
              description = rdr.GetString("description");
          }
      }

      //check to see if update is needed and possible. if it is needed but not possible, throw error
      if ((currentAccountType.CanSubscribe != cansubscribe) ||
        (currentAccountType.CanBePayer != canbepayer) ||
        (currentAccountType.CanHaveSyntheticRoot != canhavesyntheticroot) ||
        (currentAccountType.CanParticipateInGSub != canParticipateInGSub) ||
        (currentAccountType.IsVisibleInHierarchy != isVisibleInHierarchy) ||
        (currentAccountType.IsCorporate != isCorporate) ||
        (currentAccountType.CanHaveTemplates != canHaveTemplates))
      {
        updateFlags.updateNeeded = true;
        updateFlags.propertiesNeedUpdate = true;

   
        if ((currentAccountType.CanSubscribe != cansubscribe) && (cansubscribe == "1"))
          updateFlags.propertiesUpdateYesToNo = true;
        if ((currentAccountType.CanBePayer != canbepayer) && (canbepayer == "1"))
          updateFlags.propertiesUpdateYesToNo = true;
        if ((currentAccountType.CanHaveSyntheticRoot != canhavesyntheticroot) && (canhavesyntheticroot == "1"))
          updateFlags.propertiesUpdateYesToNo = true;
        if ((currentAccountType.CanParticipateInGSub != canParticipateInGSub) && (canParticipateInGSub == "1"))
          updateFlags.propertiesUpdateYesToNo = true;
        if ((currentAccountType.IsVisibleInHierarchy != isVisibleInHierarchy) && (isVisibleInHierarchy == "1"))
          updateFlags.propertiesUpdateYesToNo = true;
        if ((currentAccountType.IsCorporate != isCorporate) && (isCorporate == "1"))
          updateFlags.propertiesUpdateYesToNo = true;
        if ((currentAccountType.CanHaveTemplates != canHaveTemplates) && (canHaveTemplates == "1"))
          updateFlags.propertiesUpdateYesToNo = true;

      }
      //deal with possible update of views.
      
      MTStringCollection viewsInDB = new MTStringCollection();
      using (IMTAdapterStatement stmt = mConn.CreateAdapterStatement(
          @"queries\Account", "__FIND_ACCOUNT_VIEWS_FOR_TYPE__"))
      {

          stmt.AddParam("%%ACCOUNT_TYPE_NAME%%", currentAccountType.Name, false);

          using (IMTDataReader rdr = stmt.ExecuteReader())
          {
              while (rdr.Read())
              {
                  viewsInDB.Add(rdr.GetString("AccountView"));
              }
          }
      }
					
      foreach (string viewFromFile in currentAccountType.AccountViews)
      {
        if (viewsInDB.ContainsCaseInsensitive(viewFromFile))
        {
          //ok view is in both places, maybe update is needed? 
          MetraTech.Interop.PropSet.IMTConfig config = new MetraTech.Interop.PropSet.MTConfig();
					bool ck=false;
					string chkSum = config.ReadConfiguration(mAvCollection.GetServiceDefFileName(viewFromFile), out ck).Checksum;
					bool checksummatches = ChecksumMatches(viewFromFile, chkSum);
          if (!checksummatches)
          {
            updateFlags.updateNeeded = true;
            updateFlags.viewsToBeUpdated = true;
          }
      
        }
        else
        {
          // new view is being added to the type.
          updateFlags.updateNeeded = true;
          updateFlags.viewsToBeAdded = true;
        }
      }
      foreach (string viewFromDB in viewsInDB)
      {
        if (!currentAccountType.AccountViews.ContainsCaseInsensitive(viewFromDB))
        {
          updateFlags.updateNeeded = true;
          updateFlags.viewsToBeDeleted = true;
        }

      }

      //deal with service definition and operation pairs.
      //possibilities are new service-def op pair is added.
      //service-def op pair is deleted.
      //the service def for an operation is modified.

      NameValueCollection svcdefOpPairInDB = new NameValueCollection();
			string op;

            using (IMTAdapterStatement stmt = mConn.CreateAdapterStatement(
                @"queries\Account", "__FIND_SERVICE_DEFINTIONS_FOR_TYPE__"))
            {

                stmt.AddParam("%%ACCOUNT_TYPE_NAME%%", currentAccountType.Name, false);

                using (IMTDataReader rdr = stmt.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        op = rdr.GetString("Operation");
                        svcdefOpPairInDB[op] = rdr.GetString("ServiceDefinition");
                    }
                }
            }

      foreach (string op1 in currentAccountType.ServiceDefOpPair)
      {
        if (svcdefOpPairInDB[op1] != null)
        {
          //ok operation is in both places, maybe update is needed? 
          if (string.Compare(currentAccountType.ServiceDefOpPair[op1], svcdefOpPairInDB[op1], true) != 0)
          {
            updateFlags.updateNeeded = true;
            updateFlags.opsToBeModified = true;
          }
        }
        else
        {
          // new operation is being added to the type.
          updateFlags.updateNeeded = true;
          updateFlags.opsToBeAdded = true;
        }
      }
      foreach (string op2 in svcdefOpPairInDB)
      {
        if (currentAccountType.ServiceDefOpPair[op2] == null)
        {
          updateFlags.updateNeeded = true;
          updateFlags.opsToBeDeleted = true;
        }
      }

      MTStringCollection descendentsDB = new MTStringCollection();
      using (IMTAdapterStatement stmt = mConn.CreateAdapterStatement(
          @"queries\Account", "__FIND_DESCENDENT_ACCOUNT_TYPES_FOR_TYPE__"))
      {

          stmt.AddParam("%%ACCOUNT_TYPE_NAME%%", currentAccountType.Name, false);

          //deal with descendent types.
          using (IMTDataReader rdr = stmt.ExecuteReader())
          {
              while (rdr.Read())
              {
                  descendentsDB.Add(rdr.GetString("DescendentAccountTypeName"));
              }
          }
      }

      foreach (string dd in currentAccountType.DescendentTypes)
      {
        if (!descendentsDB.ContainsCaseInsensitive(dd))
        {
          // new descendent is being added to the type.
          updateFlags.updateNeeded = true;
          updateFlags.childToBeAdded = true;
        }
      }
      // TRW - Drop check for descendents being in DB but not in XML file since
      // they can now be defined in other XML files
      //foreach (string dd in descendentsDB)
      //{
      //  if (!currentAccountType.DescendentTypes.ContainsCaseInsensitive(dd))
      //  {
      //    updateFlags.updateNeeded = true;
      //    updateFlags.childToBeDeleted = true;
      //  }
      //}

      // Check ancestor types
      MTStringCollection ancestorsDB = new MTStringCollection();
      using (IMTAdapterStatement stmt = mConn.CreateAdapterStatement(
        @"queries\Account", "__FIND_ANCESTOR_ACCOUNT_TYPES_FOR_TYPE__"))
      {

          stmt.AddParam("%%ACCOUNT_TYPE_NAME%%", currentAccountType.Name, false);

          //deal with descendent types.
          using (IMTDataReader rdr = stmt.ExecuteReader())
          {
              while (rdr.Read())
              {
                  ancestorsDB.Add(rdr.GetString("AncestorAccountTypeName"));
              }
          }
      }

      foreach (string dd in currentAccountType.AncestorTypes)
      {
        if (!ancestorsDB.ContainsCaseInsensitive(dd))
        {
          // new descendent is being added to the type.
          updateFlags.updateNeeded = true;
          updateFlags.childToBeAdded = true;
        }
      }
      // TRW - Drop check for ancestors being in DB but not in XML file since
      // they can now be defined in other XML files
      //foreach (string dd in ancestorsDB)
      //{
      //  if (!currentAccountType.AncestorTypes.ContainsCaseInsensitive(dd))
      //  {
      //    updateFlags.updateNeeded = true;
      //    updateFlags.childToBeDeleted = true;
      //  }
      //}
      return updateFlags;
    }

    public void Execute(/*[in]*/ object var,/*[in, out]*/ ref int pVal)
    {
      bool error = false;
      try
      { 
        mLog.LogDebug("Starting Account Type hook execution.");

				// use this connection throughout the hook (unless you want another)
				mConn =  ConnectionManager.CreateConnection();

        //this is the collection of all account types on the machine based on the filesystem.
        InitAccountTypeList();

        //this is the collection of all account views on the machine based on the filesystem.
        mAvCollection = new ServiceDefinitionCollection("accountview");
  
				//load the account types from the database.
        using (IMTAdapterStatement stmt = mConn.CreateAdapterStatement(
            @"queries\Account", "__SELECT_FROM_ACCOUNTTYPE__"))
        {

            //deal with descendent types.
            using (IMTDataReader rdr = stmt.ExecuteReader())
            {
                while (rdr.Read())
                {
                    mAccounTypesInDB.Add(rdr.GetString(0));
                }
            }
        }
						
        foreach (string accountTypeName in mAccountTypesFromFiles)
        {
          //read the file
          AccountTypeFileReader reader = new AccountTypeFileReader();
          AccountTypeHelper currentAccountType = reader.ReadAccounTypeConfigFile(mAccountTypesFromFiles[accountTypeName]);

          //does this account type already exist in the database?
          if (mAccounTypesInDB.ContainsCaseInsensitive(accountTypeName))
          {
            mLog.LogDebug("{0}: already exists in the database", accountTypeName);

            //check to see if update is needed.

            UpdatePossibilities updateFlags = new UpdatePossibilities();
            updateFlags = CheckForUpdate(currentAccountType);


            if (!updateFlags.updateNeeded)
            {
              mLog.LogDebug("{0}: No update needed.", accountTypeName);
            }

            else if (updateFlags.updateNeeded && !DoAccountsOfThisTypeExist(accountTypeName))
            {
              mLog.LogDebug("{0}: Need to update account type.  No accounts of this type exist yet, so update is allowed.", accountTypeName);
              mAccountTypesToUpdate.Add(accountTypeName);
            }

            else //here update is needed and accounts of this type do exist.  Determine if update is allowed.
            {

              bool updateAllowed;

              if (updateFlags.viewsToBeDeleted || updateFlags.propertiesUpdateYesToNo) // || updateFlags.childToBeDeleted)
                updateAllowed = false;
              else
                updateAllowed = true;

              if (updateAllowed)
              {
                mLog.LogDebug("{0}: Need to update account type.  Accounts of this type exist and the update will add to the account type, hence allowed.", accountTypeName);
                mAccountTypesToUpdate.Add(accountTypeName);
              }
              else
              {
                mLog.LogError("{0}: This account type is to be updated. Accounts of this type already have been created. Update will take away from account type, hence not allowed", accountTypeName);
                error = true;
              }
            }

          }
     
          else //need to add the new account type.
          {
            mLog.LogDebug("{0}: Need to add account type", accountTypeName);
            mAccountTypesToAdd.Add(accountTypeName);
          }
        }

        //now for the account types for whom no xml files exist.  These need to be dropped only if no accounts of these types have been
        //created.
        //for (int ii = 0; ii < mAccounTypesInDB.Count; ii++)
        foreach (string namefromDB in mAccounTypesInDB)
        {
          //string namefromDB = (string)mAccounTypesInDB[ii];
          string fileName = mAccountTypesFromFiles[namefromDB];
          if (fileName == null)
          {
            // the file for this account type does not exist.  
            // it can be deleted only id no accounts of this type
            // exist, otherwise, throw exception
            if (DoAccountsOfThisTypeExist(namefromDB))
            {
              //at least one account of this type exists, the type cannot be deleted.
              //add it to the error list.
              mLog.LogError("{0}: Needs to be deleted.  However accounts of this type have already been created.", namefromDB);
              error = true;
            }
            else
            {
              //delete this account type.
              mLog.LogDebug("{0}: Need to delete account type", namefromDB);
              mAccountTypesToDelete.Add(namefromDB);
            }
          }
        } //end for

        //finally do the database work.
        if (!error)
        {
          AccountTypeWriter writer = new AccountTypeWriter();
          writer.DoIt(mAccountTypesToAdd, mAccountTypesToUpdate, mAccountTypesToDelete, mAccountTypesFromFiles);
          mLog.LogDebug("Account Type Hook completed.");
        }
        else
        {
          mLog.LogError("Account Type Hook cannot be run due to errors as shown earlier.  Please fix configuration files and run hook again.");
          throw new ApplicationException("Account Type Hook cannot be run due to errors as shown earlier.  Please fix configuration files and run hook again.");
        }
									
      }
      catch(System.Exception ex)
      {
        mLog.LogError(ex.ToString());
        throw ex;
      }
			finally
			{
				if (mConn != null)
					mConn.Dispose();
			}
    }
  }
}

