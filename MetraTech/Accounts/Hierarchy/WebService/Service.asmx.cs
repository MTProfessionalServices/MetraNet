using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Web;
using System.Web.Services;
using System.Xml.Serialization;
using System.Text;
using System.Xml;

using MetraTech;
using MetraTech.Xml;
using MetraTech.DataAccess;
using MetraTech.Interop.RCD;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTAccount;
using MetraTech.Interop.MTYAAC;
//using MetraTech.Interop.MTServiceEndpointsExec;


namespace MetraTech.Accounts.Hierarchy.WebService
{
	/// <summary>
	/// MAMHierarchyWebSvc is used to get the hierarchy one level at a time by calling GetHierarchyLevel.
  /// It also can return the field id "demo (123)" when given an account id.
	/// </summary>
  [WebService(Namespace="http://www.metratech.com/webservices/")]
  public class MAMHierarchyWebSvc : System.Web.Services.WebService
  {
    private Logger mLogger = new Logger("[MAMHierarchyWebSvc]");

    private ArrayList mSelectiveLevels = new ArrayList();

    /// <summary>
    /// Folder IDs can be specified, and will load accounts selectively
    /// </summary>
    private ArrayList mSelectiveFolderIDs = new ArrayList();

    /// <summary>
    /// Set always selective to true if you only want to load selected accounts
    /// </summary>
    private bool mAlwaysSelective = false;

    /// <summary>
    /// Determines how many accounts can be displayed directly under hierarchy root
    /// </summary>
    private int mRootNodeCapacity;
    
    /// <summary>
    /// Determines how many accounts can be displayed on every page under nested nodes in the hierarchy tree
    /// </summary>
    private int mNestedNodePageSize;

    /// <summary>
    /// Default constructor
    /// </summary>
    public MAMHierarchyWebSvc()
    {
      //CODEGEN: This call is required by the ASP.NET Web Services Designer
      InitializeComponent();
      
      if( (Application["mSelectiveLevels"] == null) ||
          (Application["mSelectiveFolderIDs"] == null) ||
          (Application["mAlwaysSelective"] == null) ||
          (Application["mRootNodeCapacity"] == null) ||
          (Application["mNestedNodePageSize"] == null) )
      {

        // Read hierachy configuration, and cache it.  If it has
        // already been read then retreive the values from the application.
        bool status = false;
        IMTRcd rcd = new MTRcdClass();
        string configFile = rcd.ExtensionDir;
        configFile += @"\SystemConfig\config\Hierarchy\Hierarchy.xml";
			
        status = ReadConfigFile(configFile);
        if (status)
          mLogger.LogDebug("Initialize successful");
        else
          mLogger.LogError("Initialize failed, Could not read config file " + configFile);
      }
      else
      {
        mSelectiveLevels = (ArrayList)Application["mSelectiveLevels"];
        mSelectiveFolderIDs = (ArrayList)Application["mSelectiveFolderIDs"];
        mAlwaysSelective = (bool)Application["mAlwaysSelective"];
        mRootNodeCapacity = (int)Application["mRootNodeCapacity"];
        mNestedNodePageSize = (int)Application["mNestedNodePageSize"];
      }
    }

    /// <summary>
    /// Read hierarchy configuration file and pull out the selective levels, folder ids,
    /// and always selective flag.  After we read the config file - we cache it at the application
    /// level, so the next call to the web service does not have to incure the cost of the 
    /// RCD and config file reading.
    /// </summary>
    /// <param name="configFile"></param>
    /// <returns></returns>
    private bool ReadConfigFile(string configFile)
    {
      MTXmlDocument doc = new MTXmlDocument();
      doc.Load(configFile);  

      XmlNodeList nodes = doc.SelectNodes("/xmlconfig/Hierarchy/SelectiveLoading/Levels/SelectiveLevel");
      foreach(XmlNode node in nodes)
      {
        mSelectiveLevels.Add(node.InnerText.ToString());
      }
      Application["mSelectiveLevels"] = mSelectiveLevels;

      nodes = doc.SelectNodes("/xmlconfig/Hierarchy/SelectiveLoading/FolderIDs/SelectiveFolderID");
      foreach(XmlNode node in nodes)
      {
        mSelectiveFolderIDs.Add(node.InnerText.ToString());
      }
      Application["mSelectiveFolderIDs"] = mSelectiveFolderIDs;

      mAlwaysSelective = doc.GetNodeValueAsBool("/xmlconfig/Hierarchy/SelectiveLoading/AlwaysSelective");
      Application["mAlwaysSelective"] = mAlwaysSelective;

      mRootNodeCapacity = doc.GetNodeValueAsInt("/xmlconfig/Hierarchy/TreeCapacity/RootNodeCapacity", 15);
      Application["mRootNodeCapacity"] = mRootNodeCapacity;

      mNestedNodePageSize = doc.GetNodeValueAsInt("/xmlconfig/Hierarchy/TreeCapacity/NestedNodePageSize", 1000);
      Application["mNestedNodePageSize"] = mNestedNodePageSize;

      return true;
    }

		#region Component Designer generated code
		
    //Required by the Web Services Designer 
    private IContainer components = null;
				
    /// <summary>
    /// Required method for Designer support - do not modify
    /// the contents of this method with the code editor.
    /// </summary>
    private void InitializeComponent()
    {
    }

    /// <summary>
    /// Clean up any resources being used.
    /// </summary>
    protected override void Dispose( bool disposing )
    {
      if(disposing && components != null)
      {
        components.Dispose();
      }
      base.Dispose(disposing);		
    }
		
		#endregion

    /// <summary>
    /// Returns a FieldID for the given account ID, date, and serialized security context.
    /// For example, "123" will return "demo (123)"
    /// </summary>
    /// <param name="lAccountID">Account ID to get Field ID for.</param>
    /// <param name="dRefDate">Hierarchy Date</param>
    /// <param name="serializedContext">Serialized Security Context</param>
    [WebMethod]
    public string GetFieldIDFromAccountID(int lAccountID, DateTime dRefDate, string serializedContext)
    {
      try
      {
        mLogger.LogDebug("GetFieldIDFromAccountID: " + lAccountID);

        if(lAccountID == 1)
        {
          return "Corporate Accounts (1)"; // It would be nice to grab the dictionary entry for Corporate Accounts here
        }

        MetraTech.Interop.MTYAAC.IMTSessionContext sessionContext = (MetraTech.Interop.MTYAAC.IMTSessionContext)new MTSessionContext();
        sessionContext.FromXML(serializedContext);
        IMTAccountCatalog objAccountCatalog = new MTAccountCatalogClass();
        objAccountCatalog.Init(sessionContext);
        MetraTech.Interop.MTYAAC.IMTYAAC objYAAC = objAccountCatalog.GetAccount(lAccountID, dRefDate);

        StringBuilder sb = new StringBuilder();
        sb.Append(objYAAC.AccountName);
        sb.Append(" (");
        sb.Append(objYAAC.AccountID);
        sb.Append(")");

        return sb.ToString();
      }
      catch(Exception exp)
      {
        mLogger.LogError(exp.ToString());
      }

      return "";
    }

    /// <summary>
    /// Returns how many accounts can be displayed directly under hierarchy root
    /// </summary>
    /// <returns>A root node capacity</returns>
    [WebMethod]
    public int GetRootNodeCapacity()
    {
      return mRootNodeCapacity;
    }

    /// <summary>
    /// Returns how many accounts can be displayed on every page under nested nodes in the hierarchy tree
    /// </summary>
    /// <returns>A page size</returns>
    [WebMethod]
    public int GetNestedNodePageSize()
    {
      return mNestedNodePageSize;
    }

    /// <summary>
    /// Returns the serialized level of the hierarchy under the given account id, and reference date.
    /// You must pass the serialized context into this method.
    /// </summary>
    /// <param name="typeSpace">Namespace type to look in</param>
    /// <param name="lAccountID">Folder account ID to get accounts under.</param>
    /// <param name="dRefDate">Hierarchy Date</param>
    /// <param name="serializedContext">Serialized Security Context</param>
    /// <param name="bShowAllCorporations">True - show all corporations, False - show only visible corporations</param>
    /// <param name="visibleAccounts">ArrayList of visible Accounts on selective levels.</param>
    /// <param name="companyFilter">Filters the result by company name.</param>
    /// <param name="usernameFilter">Filters the result by user name.</param>
    /// <param name="pageNumber">Indicates a number of the page to be retrieved from the database</param>
    [WebMethod]
    [XmlInclude(typeof(MAMHierarchyItem[]))]
    public ArrayList GetHierarchyLevel(
      string typeSpace,
      long lAccountID,
      DateTime dRefDate,
      string serializedContext,
      bool bShowAllCorporations,
      ArrayList visibleAccounts,
      string companyFilter,
      string usernameFilter,
      int pageNumber)
    {
      try
      {
        ArrayList oList = new ArrayList();
        MAMHierarchyItem oItem;

        using(IMTConnection oConn = ConnectionManager.CreateConnection())
        {
          // Get accounts at this level
          using (IMTDataReader oReader = LoadLevelFromDB(
							typeSpace,
							lAccountID,
							dRefDate,
							serializedContext,
							bShowAllCorporations,
							visibleAccounts,
							oConn,
							companyFilter,
              usernameFilter,
              pageNumber))
          {
            while (oReader != null && oReader.Read())
            {
              oItem = new MAMHierarchyItem(oReader);
              oList.Add(oItem);
            }
          }
        }
        return oList;
      }
      catch(Exception exp)
      {
        mLogger.LogError(exp.ToString());
      }
      return null;
    }

    /// <summary>
    /// Load accounts from database
    /// </summary>
    /// <param name="typeSpace">Namespace type to look in</param>
    /// <param name="lAccountID"></param>
    /// <param name="dRefDate"></param>
    /// <param name="serializedContext"></param>
    /// <param name="bShowAllCorporations">Show all corporations</param>
    /// <param name="visibleAccounts">Arraylist of visible accounts</param>
    /// <param name="oConn">IMTConnection</param>
    /// <param name="companyFilter">Filters the result by company name.</param>
    /// <param name="usernameFilter">Filters the result by user name.</param>
    /// <param name="pageNumber">Indicates a number of the page to be retrieved from the database</param>
    /// <returns>IMTDataReader</returns>
    private IMTDataReader LoadLevelFromDB(
      string typeSpace,
      long lAccountID,
      DateTime dRefDate,
      string serializedContext,
      bool bShowAllCorporations,
      ArrayList visibleAccounts,
      IMTConnection oConn,
      string companyFilter,
      string usernameFilter,
      int pageNumber)
    {
      try
      {
        //MetraTech.DataAccess.ConnectionInfo oInfo;
        IMTAdapterStatement oStmt = oConn.CreateAdapterStatement("Queries\\AccHierarchies", "__LOAD_HIERACHY_LEVEL__");

        //%%FOLDERCHECK%%
        //%%REF_DATE%%
        //%%EXCLUDED_STATES%%
        //%%ANCESTOR%%
        //%%DESCENDENT_RANGE_CHECK%%
        //%%TYPE_SPACE%% 
        //%%PAGE_SIZE%%
        //%%PAGE_NUMBER%%
      
        MetraTech.Interop.MTYAAC.IMTSessionContext sessionContext = (MetraTech.Interop.MTYAAC.IMTSessionContext)new MTSessionContext();
        sessionContext.FromXML(serializedContext);
        //Ref Date and Account ID            
				oStmt.AddParam("%%REF_DATE%%", DBUtil.ToDBString(dRefDate), true);
        oStmt.AddParam("%%ANCESTOR%%", lAccountID.ToString());

        // what type of account
        oStmt.AddParam("%%TYPE_SPACE%%", typeSpace);

        // ESR-5472 Nested search doesn’t work. Search is only working for first level - should work for nested levels. Deprecated from 5.0 
        oStmt.AddParam("%%COMPANY_NAME%%", DBUtil.ToDBString(companyFilter ?? string.Empty));
        oStmt.AddParam("%%USER_NAME%%", DBUtil.ToDBString(usernameFilter ?? string.Empty));

        // ESR-5474 There is no way to display more then 1000 leaf accounts under a single root (parent) in the Account Hierarchy view
        oStmt.AddParam("%%PAGE_SIZE%%", lAccountID == 1 ? mRootNodeCapacity : mNestedNodePageSize);
        oStmt.AddParam("%%PAGE_NUMBER%%", pageNumber);

        //Folder Check, when loading synthetic root,
        //only get corporate accounts so that we don't see independent accounts
        //Also, add clause for security, and visible accounts
        if (lAccountID == 1)
        {
          // Now we get folders and non folders, and we use the visble in hierarchy
          // flag on the account type to limit results
          oStmt.AddParam("%%FOLDERCHECK%%", "", true);

          // Filter corp. accounts based on security
          MetraTech.Interop.MTYAAC.IMTYAAC objYAAC;
          MTAccountCatalogClass objAccountCatalog = new MTAccountCatalogClass();
          objAccountCatalog.Init(sessionContext);
          objYAAC = objAccountCatalog.GetActorAccount(MetraTime.Now);
          MetraTech.Interop.MTYAAC.IMTCollectionReadOnly col = objYAAC.AccessibleCorporateAccounts(MetraTime.Now);


          // Get the 1st item; if it is the hierarchy root, return all corporate accounts, or just visible ones
          if(col[1].ToString().Equals("1"))
          {
            if(bShowAllCorporations)
            {
              oStmt.AddParam("%%DESCENDENT_RANGE_CHECK%%", "");
            }
            else  
            {
              // Only show corp. accounts that have been selected and added to visibleAccounts list.
              oStmt.AddParam("%%DESCENDENT_RANGE_CHECK%%", GetVisibleAccountsCheck(visibleAccounts));
            }
          }
          else  // if auth / auth 
          {
            // if we are showing all corp. accounts only get the ones we have access to.
            if(bShowAllCorporations) 
            {
              StringBuilder rangeCheck = new StringBuilder();
              rangeCheck.Append("parent.id_descendent in (");
              for(int i=1; i <= col.Count; i++) 
              {
                if(i!=1)
                {
                  rangeCheck.Append(",");
                }
                rangeCheck.Append(col[i].ToString());
              }
              rangeCheck.Append(") and ");

              oStmt.AddParam("%%DESCENDENT_RANGE_CHECK%%", rangeCheck.ToString());
            }
            else  // only show visible ones
            {
              // Currently there is no way to select a Corporation in the UI if you do not have access to it.
              oStmt.AddParam("%%DESCENDENT_RANGE_CHECK%%", GetVisibleAccountsCheck(visibleAccounts));
            }

          }
        } 
        else 
        {
          oStmt.AddParam("%%FOLDERCHECK%%", "");
        
          // For now, no auth, except at top level
          if(IsLevelSelective(lAccountID, dRefDate, typeSpace))
          {
            if(bShowAllCorporations) // Could this be show a specific level if we had more than just the top level show all?
            {
              oStmt.AddParam("%%DESCENDENT_RANGE_CHECK%%", "");
            }
            else  
            {
              oStmt.AddParam("%%DESCENDENT_RANGE_CHECK%%", GetVisibleAccountsCheck(visibleAccounts));
            }
          }
          else
          {
            oStmt.AddParam("%%DESCENDENT_RANGE_CHECK%%", "");
          }
        }

        // Add all account states except CL (closed)
        oStmt.AddParam("%%EXCLUDED_STATES%%", "'AC','AR','PA','PF','SU'", true);
        //for Oracle execute GetAccountsWithPermission procedure to add data into the global temporary table
        if (oConn.ConnectionInfo.IsOracle)
        {
          var spOra = oConn.CreateCallableStatement("GetAccountsWithPermission");
          spOra.AddParam("AccountID", MTParameterType.Integer, sessionContext.SecurityContext.AccountID);
          spOra.ExecuteNonQuery(); 
        }  

        // Execute the query
        IMTDataReader oReader = oStmt.ExecuteReader();

        return oReader;
      }
      catch(Exception exp)
      {
        mLogger.LogError(exp.ToString());
      }
      return null;
    }

    /// <summary>
    /// Return the where clause as a string for the list of visible
    /// accounts (accounts that have been selected).
    /// </summary>
    /// <param name="visibleAccounts"></param>
    /// <returns></returns>
    private string GetVisibleAccountsCheck(ArrayList visibleAccounts)
    {
      if(visibleAccounts.Count == 0)
      {
        return "";
      }

      StringBuilder rangeCheck = new StringBuilder();
      rangeCheck.Append("parent.id_descendent in (");
      int i=0;
      foreach(string id in visibleAccounts)
      {
        if(i != 0)
        {
          rangeCheck.Append(",");
        }
        rangeCheck.Append(id);
        ++i;
      }
      rangeCheck.Append(") and ");

      return rangeCheck.ToString();
    }

    /// <summary>
    /// Determine if the current level is configured to be selective by comparing
    /// it against the values that were read from the hierarchy.xml configuration
    /// file.
    /// </summary>
    /// <param name="accountID"></param> 
    /// <param name="refDate"></param>
    /// <param name="typeSpace">Namespace type to look in</param>
    /// <returns>TRUE if selective loading should be used.</returns>
    private bool IsLevelSelective(long accountID,  DateTime refDate, string typeSpace)
    {
      try
      {
        // system users do not support selective loading
        if(typeSpace.ToLower().Equals("system_user"))
        {
          return false;
        }

        // Check these first, because we don't have to hit the database if one of them is true.
        if( (mAlwaysSelective) || (mSelectiveFolderIDs.Contains(accountID.ToString())) )
        {
          return true;
        }

        using (IMTConnection oConn = ConnectionManager.CreateConnection())
        {
            using (IMTAdapterStatement oStmt = oConn.CreateAdapterStatement("Queries\\AccHierarchies", "__GET_HIERARCHY_LEVEL__"))
            {
                //%%ANCESTOR%% 
                //%%REFDATE%%

                //Ref Date and ANCESTOR            
                oStmt.AddParam("%%REFDATE%%", DBUtil.ToDBString(refDate), true);
                oStmt.AddParam("%%ANCESTOR%%", accountID.ToString());

                using (IMTDataReader oReader = oStmt.ExecuteReader())
                {
                    bool isOKtoRead = oReader.Read();

                    if (isOKtoRead)
                    {
                        long level = long.Parse(oReader.GetValue("num_generations").ToString());

                        // Determine if we are loading a level that is configured to be selective.
                        if (mSelectiveLevels.Contains(level.ToString()))
                        {
                            return true;
                        }
                    }
                    else
                    {
                        return false;
                    }
                }
            }
        }
      }
      catch(Exception exp)
      {
        mLogger.LogError(exp.ToString());
      }

      return false;
    }

  }
}
