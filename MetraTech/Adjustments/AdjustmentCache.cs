using System;
using System.Collections;
//using ;
using MetraTech.Interop.GenericCollection;
using System.Runtime.InteropServices;
using MetraTech.Interop.MTProductCatalog;
using RS = MetraTech.Interop.Rowset;
using MetraTech;
using MetraTech.Interop.COMMeter;
using MetraTech.Interop.MTServerAccess;
using MetraTech.Xml;
using MetraTech.Interop.MTAuditEvents;
using MetraTech.Localization;
using PCExec = MetraTech.Interop.MTProductCatalogExec;



namespace MetraTech.Adjustments
{
  
  [ComVisible(false)]
  public class AdjustmentCache
	{
    private System.Collections.Hashtable mTemplateMap;
    private System.Collections.Hashtable mTypesMap;
    private System.Collections.Hashtable mPITypeMap;
    private System.Collections.Hashtable mApplicMap;
		MetraTech.Interop.GenericCollection.IMTCollection mReasonColl;
    private MetraTech.Logger mLog;
    private MIU mMIU;
    private IMeter mMeterServer;
    private int mBatchRetryInterval;
    private int mMAXRetries;
    private int mTimeout;
    private IAuditor mAuditor;
    private ILanguageList mLanguageList;
		private bool mbAdjustmentTypesLoaded;

    private static AdjustmentCache mInstance = null;

		private AdjustmentCache()
		{
			mTemplateMap = new Hashtable();
      mPITypeMap = new Hashtable();
      mTypesMap = new Hashtable();
      mApplicMap = new Hashtable();
			mReasonColl = new MetraTech.Interop.GenericCollection.MTCollectionClass();
      mLog = new Logger("[Adjustments]");
      mMIU = null;
      mMeterServer = null;
      mBatchRetryInterval = -1;
      mMAXRetries = -1;
      mTimeout = -1;
      mAuditor = new AuditorClass();
      mLanguageList = new LanguageList();
			mbAdjustmentTypesLoaded = false;
		}

    public static AdjustmentCache GetInstance()
    {
      //double checked locking
      if(mInstance == null)
      {
        lock(typeof(AdjustmentCache))
        {
          if(mInstance == null)
            mInstance =  new AdjustmentCache();
        }
      }
      return mInstance;
    }
    /// <summary>
    /// Retrieve records for previously adjusted transactions
    /// </summary>
    public RS.IMTSQLRowset GetAdjustedTransactionsAsRowset
      (
      IMTSessionContext apCTX,
      RS.IMTDataFilter filter
      )
    {
       IAdjustmentTransactionReader reader = new AdjustmentTransactionReader();
        return reader.GetAdjustedTransactionsAsRowset(apCTX, filter);
     
    }

    /// <summary>
    /// Retrieve records for orphan adjustments
    /// </summary>
    public RS.IMTSQLRowset GetOrphanAdjustmentsAsRowset
      (
      IMTSessionContext apCTX,
      RS.IMTDataFilter filter
      )
    {
      IAdjustmentTransactionReader reader = new AdjustmentTransactionReader();
      return reader.GetOrphanAdjustmentsAsRowset(apCTX, filter);
     
    }

    /// <summary>
    /// Retrieves charge breakdown rowset based on 
    /// adjustment transaction DB ID
    /// </summary>
    public RS.IMTSQLRowset GetAdjustmentDetailsAsRowset
      (
      IMTSessionContext apCTX,
      int aTransactionID
      )
    {
      IAdjustmentTransactionReader reader = new AdjustmentTransactionReader();
      return reader.GetAdjustmentDetailsAsRowset(apCTX, aTransactionID);
     
    }
    /// <summary>
    /// Retrieve adjustment types supported by given PI template
    /// </summary>
    public MetraTech.Interop.GenericCollection.IMTCollection GetAdjustmentTypesForPITemplate(IMTSessionContext apCTX, int aPITemplateID,bool bParentId)
    {
      MetraTech.Interop.GenericCollection.IMTCollection outptr = new MetraTech.Interop.GenericCollection.MTCollection();
      try
      {
        IAdjustmentTypeReader reader = new AdjustmentTypeReader();
        return reader.GetAdjustmentTypesForPI(apCTX, aPITemplateID,bParentId);
      }
      catch(System.Exception ex)
      {
        throw ex;
      }
    
	}

    /// <summary>
    /// Retrieve adjustment teamplates Attached to a given PI template
    /// </summary>
    public MetraTech.Interop.GenericCollection.IMTCollection GetAdjustments(IMTSessionContext apCTX, IMTPriceableItem aPI)
    {
      try
      {
        IAdjustmentReader reader = new AdjustmentReader();
        return reader.GetAdjustments(apCTX, aPI);
      }
      catch(System.Exception ex)
      {
        throw ex;
      }
    }
    /// <summary>
    /// Retrieve adjustment types supported by given PI Type
    /// </summary>
    public MetraTech.Interop.GenericCollection.IMTCollection GetAdjustmentTypes(IMTSessionContext apCTX, int aPITypeID)
    {
      lock(typeof(AdjustmentCache))
      {
        if(!mPITypeMap.Contains(aPITypeID))
          LoadAdjustmentTypes(apCTX);
        if(!mPITypeMap.Contains(aPITypeID))
          return new MTCollectionClass();
        else
          //should we just return empty collection?
          //throw new AdjustmentException(String.Format("PI Type with ID {0} has no associated adjustment types", aPITypeID));
          return (MetraTech.Interop.GenericCollection.IMTCollection)mPITypeMap[aPITypeID];
      }
    }
    /// <summary>
    /// Retrieve adjustment type by name
    /// </summary>
    public IAdjustmentType GetAdjustmentTypeByName(IMTSessionContext apCTX, string aName)
    {
      lock(typeof(AdjustmentCache))
      {
				foreach (IAdjustmentType ajt in mTypesMap.Values)
				{
					string nm = ajt.Name;
					if (string.Compare(nm, aName, true) == 0)
					{
						return ajt;
					}
				}
				LoadAdjustmentTypes(apCTX);
				foreach (IAdjustmentType ajt in mTypesMap.Values)
				{
					string nm = ajt.Name;
					if (string.Compare(nm, aName, true) == 0)
					{
						return ajt;
					}
				}
        
          throw new AdjustmentException(System.String.Format("Adjustment Type <{0}> not found", aName));
      }
    }
    /// <summary>
    /// Retrieve adjustment type by id
    /// </summary>
    public IAdjustmentType GetAdjustmentType(IMTSessionContext apCTX, int aID)
    {
      lock(typeof(AdjustmentCache))
      {
        if(!mTypesMap.Contains(aID))
        {
					LoadAdjustmentTypes(apCTX);
					if(mTypesMap.Contains(aID) == false)
            throw new AdjustmentException(System.String.Format("Adjustment Type with ID <{0}> not found", aID));
        }
        
				return (IAdjustmentType)mTypesMap[aID];
      }
    }
    public void SynchronizeTypes(IMTSessionContext apCTX)
    {
      lock(typeof(AdjustmentCache))
      {
				//CR 11980 fix: use MTDDLWriter instead (Oracle doesn't like transaction around DDL stmts)
				PCExec.IMTDDLWriter writer = new PCExec.MTDDLWriterClass();
        writer.SyncAdjustmentTables((PCExec.IMTSessionContext)apCTX);
        return;
      }
    }

    /// <summary>
    /// Retrieve applicability rule by id
    /// </summary>
    public IApplicabilityRule GetApplicabilityRule(IMTSessionContext apCTX, int aID)
    {
      lock(typeof(AdjustmentCache))
      {
        if(!mApplicMap.Contains(aID))
        {
          IApplicabilityRuleReader reader = new ApplicabilityRuleReader();
          IApplicabilityRule rule = reader.FindApplicabilityRule(apCTX, aID);
          if (rule == null)
            throw new AdjustmentException(System.String.Format("Applicability Rule with ID <{0}> not found", aID));
          return rule;
        }
        else return (IApplicabilityRule)mApplicMap[aID];
      }
    }

    
    /// <summary>
    /// Retrieve applicability rule by name
    /// </summary>
    public IApplicabilityRule GetApplicabilityRuleByName(IMTSessionContext apCTX, string aName)
    {
      lock(typeof(AdjustmentCache))
      {
        IApplicabilityRuleReader reader = new ApplicabilityRuleReader();
        IApplicabilityRule rule = reader.FindApplicabilityRuleByName(apCTX, aName);
        if (rule == null)
          throw new AdjustmentException(System.String.Format("Applicability Rule <{0}> not found", aName));
        return rule;
      }
    }
    /// <summary>
    /// Retrieve reason code by id
    /// </summary>
    public IReasonCode GetReasonCode(IMTSessionContext apCTX, int aID)
    {
      lock(typeof(AdjustmentCache))
      {
				foreach (IReasonCode rc in mReasonColl)
        {
					int id = rc.ID;
					if (id == aID)
						return rc;
				}
				GetReasonCodes(apCTX);
				foreach (IReasonCode rc in mReasonColl)
				{
					int id = rc.ID;
					if (id == aID)
						return rc;
				}
            throw new AdjustmentException(System.String.Format("Reason Code with ID <{0}> not found", aID));
      }
    }

    
    /// <summary>
    /// Retrieve reason code by name
    /// </summary>
    public IReasonCode GetReasonCodeByName(IMTSessionContext apCTX, string aName)
    {
      lock(typeof(AdjustmentCache))
      {
				foreach (IReasonCode rc in mReasonColl)
				{
					string nm = rc.Name;
					if (string.Compare(nm, aName, true) == 0)
						return rc;
				}
				GetReasonCodes(apCTX);
				foreach (IReasonCode rc in mReasonColl)
				{
					string nm = rc.Name;
					if (string.Compare(nm, aName, true) == 0)
						return rc;
				}
          throw new AdjustmentException(System.String.Format("Reason Code <{0}> not found", aName));
      }
      
    }
    /// <summary>
    /// Retrieve reason code by name
    /// </summary>
    public MetraTech.Interop.GenericCollection.IMTCollection GetReasonCodes(IMTSessionContext apCTX)
    {
      lock(typeof(AdjustmentCache))
      {
        IReasonCodeReader reader = new ReasonCodeReader();
        return mReasonColl = reader.GetReasonCodes(apCTX);
      }
    }

    /// <summary>
    /// Retrieve reason code by name
    /// </summary>
    public RS.IMTSQLRowset GetReasonCodesAsRowset(IMTSessionContext apCTX)
    {
      lock(typeof(AdjustmentCache))
      {
        IReasonCodeReader reader = new ReasonCodeReader();
        return reader.GetReasonCodesAsRowset(apCTX);
      }
    }

    public void LoadAdjustmentTypes(IMTSessionContext apCTX)
    {
			lock (typeof(AdjustmentCache))
			{
				if (mbAdjustmentTypesLoaded == true)
					return;
      ArrayList addedmappings = new ArrayList();
      IAdjustmentTypeReader reader = new AdjustmentTypeReader();
      mTypesMap = new Hashtable();
      MetraTech.Interop.GenericCollection.IMTCollection types = reader.GetAdjustmentTypes(apCTX);
      foreach(IAdjustmentType type in types)
      {
					if (!mTypesMap.Contains(type.ID))
					{
        mTypesMap[type.ID] = type;
					}
        if(!mPITypeMap.Contains(type.PriceableItemTypeID))
        {
          MetraTech.Interop.GenericCollection.IMTCollection ajtypes = new MTCollectionClass();
          mPITypeMap[type.PriceableItemTypeID] = ajtypes;
        }
        if(!addedmappings.Contains(type.ID))
        {
          MetraTech.Interop.GenericCollection.IMTCollection ajtypesref  = 
            (MetraTech.Interop.GenericCollection.IMTCollection)mPITypeMap[type.PriceableItemTypeID];
          ajtypesref.Add(type);
          //((MetraTech.Interop.GenericCollection.IMTCollection)mPITypeMap[type.PriceableItemTypeID]).Add(type);
          addedmappings.Add(type.ID);
        }

      }
				mbAdjustmentTypesLoaded = true;
			}
    }
    /// <summary>
    /// get logger instance
    /// </summary>
    public Logger GetLogger()
    {
      return mLog;
    }

    /// <summary>
    /// get Auditor instance
    /// </summary>
    public IAuditor GetAuditor()
    {
      return mAuditor;
    }

    /// <summary>
    /// get MIU parameters instance
    /// </summary>
    internal MIU GetMIU()
    {
      if(mMIU == null)
        LoadConfiguration();
      return mMIU;
    }
   
    /// <summary>
    /// get retry interval for pipeline batch operations
    /// </summary>
    internal int GetBatchRetryInterval()
    {
      if (mBatchRetryInterval < 0)
        LoadConfiguration();
      return mBatchRetryInterval;
    }

    /// <summary>
    /// get MAX retries for pipeline batch operations
    /// </summary>
    internal int GetBatchMAXRetries()
    {
      if (mMAXRetries < 0)
        LoadConfiguration();
      return mMAXRetries;
    }

    /// <summary>
    /// get MAX retries for pipeline batch operations
    /// </summary>
    internal int GetBatchTimeout()
    {
      if (mTimeout < 0)
        LoadConfiguration();
      return mTimeout;
    }

    
    /// <summary>
    /// get IMeter instance
    /// </summary>
    internal IMeter GetMeter()
    {
      if(mMeterServer == null)
        CreateMeterServer();
      return mMeterServer;
    }

    /// <summary>
    /// get LanguageCollection instance
    /// </summary>
    internal ILanguageList GetLanguageList()
    {
      return mLanguageList;
    }



    /// <summary>
    /// read MIU parameters from file
    /// </summary>
    private void LoadConfiguration()
    {
      MTXmlDocument doc = new MTXmlDocument();
      doc.LoadConfigFile(@"Adjustments\Adjustments.xml");

      // TODO: look at the version of the file
      int AccountID = doc.GetNodeValueAsInt("xmlconfig/miu/accountid");
      int SEID = doc.GetNodeValueAsInt("xmlconfig/miu/seid");
      string AccountName = doc.GetNodeValueAsString("xmlconfig/miu/accountname");
      string SEName = doc.GetNodeValueAsString("xmlconfig/miu/sename");
      string AccountNameSpace = doc.GetNodeValueAsString("xmlconfig/miu/accountnamespace");
      string SENameSpace = doc.GetNodeValueAsString("xmlconfig/miu/senamespace");
      string SECorpName = doc.GetNodeValueAsString("xmlconfig/miu/secorpname");
      string SECorpNameSpace = doc.GetNodeValueAsString("xmlconfig/miu/secorpnamespace");
      mMIU = new MIU(AccountID, SEID, AccountName, SEName, AccountNameSpace, SENameSpace, SECorpName, SECorpNameSpace);

      mTimeout = doc.GetNodeValueAsInt("xmlconfig/batchops/batchtimeout");
      mBatchRetryInterval = doc.GetNodeValueAsInt("xmlconfig/batchops/batchretryinterval");
      mMAXRetries = doc.GetNodeValueAsInt("xmlconfig/batchops/batchmaxretries");

    }

   

    private void CreateMeterServer()
    {
      mMeterServer = new MeterClass();
      mMeterServer.Startup();
      IMTServerAccessDataSet serverAccess = new MTServerAccessDataSet();
      serverAccess.Initialize();
      
      try
      {
        IMTServerAccessData sad = serverAccess.FindAndReturnObject("AdjustmentsServer");
        mMeterServer.HTTPRetries = sad.NumRetries;
        mMeterServer.HTTPTimeout = sad.Timeout;
        mMeterServer.AddServer(0, sad.ServerName, (PortNumber)sad.PortNumber, 0, sad.UserName, sad.Password); 
      }
      catch(COMException ex)
      {
        GetLogger().LogError("servers.xml is possibly missing 'AdjustmentsServer' entry.");
          throw ex;
      }
      
    }


	}
  internal class MIU
  {
    public MIU( int aAccountID, int aSEID, 
      string aAccountName, string aSEName, 
      string aAccountNamespace, string aSENamespace,
      string aSECorpName, string aSECorpNamespace)
    {
      mAccountID = aAccountID;
      mSEID = aSEID;
      mAccountName = aAccountName;
      mSEName = aSEName;
      mAccountNamespace = aAccountNamespace;
      mSENamespace = aSENamespace;
      mSECorpName = aSECorpName;
      mSECorpNamespace = aSECorpNamespace;

    }

    public int AccountID
    {
      get{return mAccountID;}
    }
    public int SEID
    {
      get{return mSEID;}
    }
    public string AccountName
    {
      get{return mAccountName;}
    }
    public string SEName
    {
      get{return mSEName;}
    }
    public string SENamespace
    {
      get{return mSENamespace;}
    }
    public string AccountNamespace
    {
      get{return mAccountNamespace;}
    }
    public string SECorpName
    {
      get{return mSECorpName;}
    }
    public string SECorpNamespace
    {
      get{return mSECorpNamespace;}
    }

    private int mAccountID;
    private int mSEID;
    private string mAccountName;
    private string mSEName;
    private string mAccountNamespace;
    private string mSENamespace;
    private string mSECorpName;
    private string mSECorpNamespace;
   
    
  }
}

