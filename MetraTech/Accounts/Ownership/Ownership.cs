using System;
using System.Runtime.InteropServices;
using System.EnterpriseServices;
using System.Diagnostics;
using System.Collections;

[assembly: GuidAttribute ("058ceac2-4b80-4e15-b63d-f1878b973651")]


namespace MetraTech.Accounts.Ownership
{
  using RS=MetraTech.Interop.Rowset;
  using MetraTech.Interop.MTAuth;
  using YAAC=MetraTech.Interop.MTYAAC;
  using MetraTech.DataAccess;
  using MetraTech.Localization;
  using MetraTech.Interop.MTEnumConfig;
  using MetraTech.Interop.MTAuditEvents;
  using RCD = MetraTech.Interop.RCD;

  [Guid("a8e8c7a8-bb66-46b9-a6f1-7fc90f3bb359")]
  public enum ViewHint {Direct = 0, DirectDescendents, AllDescendents}
  
  [Guid("9b956d0c-b644-4112-81bd-9854aea7312b")]
  public interface IOwnershipMgr
  {
    void Initialize(IMTSessionContext ctx, IMTYAAC acc);
    IMTSQLRowset GetOwnedAccountsAsRowset(DateTime aRefDateTime);
    IMTSQLRowset GetOwnedAccountsHierarchicalAsRowset(ViewHint aHint);
    IMTSQLRowset GetOwnerAccountsAsRowset(DateTime aRefDateTime);
    void AddOwnership(IOwnershipAssociation assoc);
    void RemoveOwnership(IOwnershipAssociation assoc);
    IOwnershipAssociation CreateAssociationAsOwner();
    IOwnershipAssociation CreateAssociationAsOwned();
    IMTSQLRowset AddOwnershipBatch(IMTCollection assocs, IMTProgress progress);
    IMTSQLRowset RemoveOwnershipBatch(IMTCollection assocs, IMTProgress progress);
  }

  [Guid("3967cd20-8374-4dfc-ad0d-b48907b6a3c7")]
  public interface IOwnershipAssociation
  {
    IMTSessionContext SessionContext{get;set;}
    int OwnerAccount {get;set;}
    int OwnedAccount {get;set;}
    string RelationType {get;set;}
    int RelationTypeID {get;}
    string RelationTypeAsLocalizedString {get;}
    int PercentOwnership {get;set;}
    DateTime StartDate {get;set;}
    DateTime EndDate {get;set;}
    DateTime OldStartDate {get;set;}
    DateTime OldEndDate {get;set;}
  }

  [Guid("b63ee935-588e-47a9-a4a1-9cd0942aec50")]
  [ClassInterface(ClassInterfaceType.None)]
  public class OwnershipMgr : IOwnershipMgr
  {
    private IMTSessionContext mCtx;
    private IEnumConfig mEnumConfig = new EnumConfigClass();
    private IMTYAAC mAccount;
    public void Initialize(IMTSessionContext ctx, IMTYAAC account)
    {
      if (ctx == null)
        throw new NullReferenceException("IMTSessionContext has to be set");
      if (account == null)
        throw new NullReferenceException("IMTYAAC has to be set");
      mCtx = ctx;
      mAccount = account;
    }
    public IMTSQLRowset GetOwnedAccountsAsRowset(DateTime aRefDateTime)
    {
      OwnershipReader reader = new OwnershipReader();
      return reader.GetOwnedAccountsAsRowset(mCtx, mAccount, aRefDateTime);
    }
    public IMTSQLRowset GetOwnerAccountsAsRowset(DateTime aRefDateTime)
    {
      OwnershipReader reader = new OwnershipReader();
      return reader.GetOwnerAccountsAsRowset(mCtx, mAccount, aRefDateTime);
    }

    public IMTSQLRowset GetOwnedAccountsHierarchicalAsRowset(ViewHint aHint)
    {
      OwnershipReader reader = new OwnershipReader();
      return reader.GetOwnedAccountsHierarchicalAsRowset(mCtx, mAccount, aHint);
    }

    public void AddOwnership(IOwnershipAssociation assoc)
    {
      if (assoc == null)
        throw new NullReferenceException("IOwnershipAssociation has to be set");
      IOwnershipWriter writer = new OwnershipWriter();
      writer.AddOwnership(mCtx, assoc);
      return;
    }

    public void RemoveOwnership(IOwnershipAssociation assoc)
    {
      if (assoc == null)
        throw new NullReferenceException("IOwnershipAssociation has to be set");
      IOwnershipWriter writer = new OwnershipWriter();
      writer.RemoveOwnership(mCtx, assoc);
      return;
    }

    public IMTSQLRowset AddOwnershipBatch(IMTCollection assocs, IMTProgress progress)
    {
      if (assocs == null)
        throw new NullReferenceException("IMTCollection has to be set");
      IOwnershipWriter writer = new OwnershipWriter();
      return writer.AddOwnershipBatch(mCtx, assocs, progress);
    }

    public IMTSQLRowset RemoveOwnershipBatch(IMTCollection assocs, IMTProgress progress)
    {
      if (assocs == null)
        throw new NullReferenceException("IMTCollection has to be set");
      IOwnershipWriter writer = new OwnershipWriter();
      return writer.RemoveOwnershipBatch(mCtx, assocs, progress);
    }


    
    
    public IOwnershipAssociation CreateAssociationAsOwner()
    {
      IOwnershipAssociation association = new OwnershipAssociation();
      association.OwnerAccount = mAccount.AccountID;
      association.SessionContext = mCtx;

      return association;
    }
    public IOwnershipAssociation CreateAssociationAsOwned()
    {
      IOwnershipAssociation association = new OwnershipAssociation();
      association.OwnedAccount = mAccount.AccountID;
      association.SessionContext = mCtx;
      return association;
    }

    
  }

  [Guid("62e73562-8cb8-4105-89ef-252b4fe98cc7")]
  [ClassInterface(ClassInterfaceType.None)]
  public class OwnershipAssociation : IOwnershipAssociation
  {
    private IMTSessionContext mCtx;
    private IEnumConfig mEnumConfig = new EnumConfigClass();
    
    public IMTSessionContext SessionContext
    {get{return mCtx;}set{mCtx = value;}}
    private int mOwner;
    public int OwnerAccount 
    {get{return mOwner;}set{mOwner = value;}}
    private int mOwned;
    public int OwnedAccount
    {get{return mOwned;}set{mOwned = value;}}
    private string mRelationType;
    private int mRelationTypeID = -1;

    public string RelationType
    {
      get{return mRelationType;}
      set
      {
        mRelationTypeID = mEnumConfig.GetID("metratech.com", "SaleForceRelationship", value);
        mRelationType = value;
      }
    }
    public int RelationTypeID
    {
      get{return mRelationTypeID;}
      //set is only called from error handling tests
      set{mRelationTypeID = value;}
    }
    public string RelationTypeAsLocalizedString 
    {
      //get localized string given language id from IMTSessionContext
      get
      {
        if(mRelationTypeID < 0) return "";
        else
          return LocalizedDescription.GetInstance().GetByID(mCtx.LanguageID, mRelationTypeID);
      }
    
    }
    private int mPercent = -1;
    public int PercentOwnership
    {get{return mPercent;}set{mPercent = value;}}
    
    private DateTime mStartDate = DateTime.MinValue;
    public DateTime StartDate
    {	
			get
			{
				return mStartDate;
			}
			set
			{
				if(value != DateTime.MinValue)
					mStartDate = value.Date;
				else
					mStartDate = value;
			}
		}
    private DateTime mEndDate = DateTime.MinValue;
    public DateTime EndDate
    {
			get
			{
				return mEndDate;
			}
			set
			{
				if(value != DateTime.MinValue)
				{
					mEndDate = value.Date;
				}
				else
					mEndDate = value;
			}
		}

    private DateTime mOldStartDate = DateTime.MinValue;
    public DateTime OldStartDate
    {get{return mOldStartDate;}set{mOldStartDate = value;}}
    private DateTime mOldEndDate = DateTime.MinValue;
    public DateTime OldEndDate
    {get{return mOldEndDate;}set{mOldEndDate = value;}}
    
  }

  [Guid("3832a83f-7cbc-40a8-ae90-ac2acc7e9fd5")]
  public interface IOwnershipWriter
  {
    void AddOwnership(IMTSessionContext ctx, IOwnershipAssociation assoc);
    void RemoveOwnership(IMTSessionContext ctx, IOwnershipAssociation assoc);
    IMTSQLRowset AddOwnershipBatch(IMTSessionContext ctx, IMTCollection assocs, IMTProgress progress);
    IMTSQLRowset RemoveOwnershipBatch(IMTSessionContext ctx, IMTCollection assocs, IMTProgress progress);
  }

  [ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.Required, Isolation=TransactionIsolationLevel.Any)]
  [Guid("9b560022-31fc-4ac5-bf74-4bfc3e91fce3")]
  public class OwnershipWriter : ServicedComponent, IOwnershipWriter
  {
    public OwnershipWriter() { }
    const uint MTAUTH_ACCESS_DENIED = 0xE29F0001;
    
    [AutoComplete]
    public void AddOwnership(IMTSessionContext ctx, IOwnershipAssociation assoc)
    {
      //check auth
      Auditor auditor = new AuditorClass();
      try
      {
        CheckWriteManageSFH(ctx);
      }
      catch(COMException ex)
      {
        if((uint)ex.ErrorCode == MTAUTH_ACCESS_DENIED)
        {
          auditor.FireFailureEvent
            ((int)MTAuditEvent.AUDITEVENT_ACCOUNT_OWNERSHIP_CREATE_DENIED, 
            ctx.AccountID, 
            (int)MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT,
            -1,
            ex.Message);
        }
        throw;
      }
      
      //exec SequencedUpsertAccOwnership 123, 124, 555, 10, @now, '2037-1-1', @now, '2037-1-1', @status
      //SequencedUpsertAccOwnership
      Validate(assoc, 1/*add or remove*/);
      int id_owner = assoc.OwnerAccount;
      int id_owned = assoc.OwnedAccount;
      int relation = assoc.RelationTypeID;
      int percent = assoc.PercentOwnership;
      DateTime start = assoc.StartDate;
      DateTime end = assoc.EndDate;

      DateTime oldstart = assoc.OldStartDate;
      DateTime oldend = assoc.OldEndDate;
      
      bool bPrevRecordExisted = (oldstart != DateTime.MinValue) && (oldend != DateTime.MinValue);
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        if(bPrevRecordExisted)
        {
            using (IMTCallableStatement deletestmt = conn.CreateCallableStatement("SequencedDeleteAccOwnership"))
            {
                deletestmt.AddParam("p_id_owner", MTParameterType.Integer, id_owner);
                deletestmt.AddParam("p_id_owned", MTParameterType.Integer, id_owned);
                deletestmt.AddParam("p_vt_start", MTParameterType.DateTime, oldstart);
                deletestmt.AddParam("p_vt_end", MTParameterType.DateTime, oldend);
                deletestmt.AddParam("p_tt_current", MTParameterType.DateTime, MetraTime.Now);
                deletestmt.AddParam("p_tt_max", MTParameterType.DateTime, MetraTime.Max);
                deletestmt.AddOutputParam("p_status", MTParameterType.Integer);
                deletestmt.ExecuteNonQuery();
                int delreturncode;
                delreturncode = (int)deletestmt.GetOutputValue("p_status");
                if (0 != delreturncode)
                    throw new COMException("SequencedDeleteAccOwnership stored procedure failed while deleting previous ownership record", delreturncode);
            }
        }

        using (IMTCallableStatement stmt = conn.CreateCallableStatement("SequencedUpsertAccOwnership"))
        {
            stmt.AddParam("p_id_owner", MTParameterType.Integer, id_owner);
            stmt.AddParam("p_id_owned", MTParameterType.Integer, id_owned);
            stmt.AddParam("p_id_relation_type", MTParameterType.Integer, relation);
            stmt.AddParam("p_percent", MTParameterType.Integer, percent);
            stmt.AddParam("p_vt_start", MTParameterType.DateTime, start);
            stmt.AddParam("p_vt_end", MTParameterType.DateTime, end);
            stmt.AddParam("p_tt_current", MTParameterType.DateTime, MetraTime.Now);
            stmt.AddParam("p_tt_max", MTParameterType.DateTime, MetraTime.Max);
            stmt.AddOutputParam("p_status", MTParameterType.Integer);
            stmt.ExecuteNonQuery();
            int returncode;
            returncode = (int)stmt.GetOutputValue("p_status");
            if (0 != returncode)
                throw new COMException("SequencedUpsertAccOwnership stored procedure failed", returncode);
        }

        auditor.FireEvent
          ((int)MTAuditEvent.AUDITEVENT_ACCOUNT_OWNERSHIP_CREATE, 
          ctx.AccountID, 
          (int)MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT,
          id_owned,
          string.Format("Account {0} is successfully assigned as owner to account {1}", id_owner, id_owned));
      }
      
    }
    [AutoComplete]
    public void RemoveOwnership(IMTSessionContext ctx, IOwnershipAssociation assoc)
    {
      //check auth
      Auditor auditor = new AuditorClass();
      try
      {
        CheckWriteManageSFH(ctx);
      }
      catch(COMException ex)
      {
        if((uint)ex.ErrorCode == MTAUTH_ACCESS_DENIED)
        {
          auditor.FireFailureEvent
            ((int)MTAuditEvent.AUDITEVENT_ACCOUNT_OWNERSHIP_DELETE_DENIED, 
            ctx.AccountID, 
            (int)MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT,
            -1,
            ex.Message);
        }
        throw;
      }
      
      //exec SequencedDeleteAccOwnership 123, 124, @now, '2037-1-1', @now, '2037-1-1', @status
      Validate(assoc, 0/*add or remove*/);
      int id_owner = assoc.OwnerAccount;
      int id_owned = assoc.OwnedAccount;
      DateTime start = assoc.StartDate;
      DateTime end = (assoc.EndDate == DateTime.MinValue) ? MetraTime.Max : assoc.EndDate;
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTCallableStatement stmt = conn.CreateCallableStatement("SequencedDeleteAccOwnership"))
          {
              stmt.AddParam("p_id_owner", MTParameterType.Integer, id_owner);
              stmt.AddParam("p_id_owned", MTParameterType.Integer, id_owned);
              stmt.AddParam("p_vt_start", MTParameterType.DateTime, start);
              stmt.AddParam("p_vt_end", MTParameterType.DateTime, end);
              stmt.AddParam("p_tt_current", MTParameterType.DateTime, MetraTime.Now);
              stmt.AddParam("p_tt_max", MTParameterType.DateTime, MetraTime.Max);
              stmt.AddOutputParam("p_status", MTParameterType.Integer);
              stmt.ExecuteNonQuery();
              int returncode;
              returncode = (int)stmt.GetOutputValue("p_status");
              if (0 != returncode)
                  throw new COMException("SequencedDeleteAccOwnership stored procedure failed", returncode);
          }

        try
        {
          auditor.FireEvent
            ((int)MTAuditEvent.AUDITEVENT_ACCOUNT_OWNERSHIP_DELETE, 
            ctx.AccountID, 
            (int)MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT,
            id_owned,
            string.Format("Account {0} is no longer owner of account {1}", id_owner, id_owned));
        }
        finally
        {
          Marshal.ReleaseComObject(auditor);
        }
      }

      
      
    }

    [AutoComplete]
    public IMTSQLRowset AddOwnershipBatch(IMTSessionContext ctx, IMTCollection assocs, IMTProgress progress)
    {
      IMTSQLRowset rowset = (IMTSQLRowset)new RS.MTSQLRowset();
        
      try
      {
        //check auth
        CheckWriteManageSFH(ctx);
        //Create temp table
        rowset.Init(@"Queries\AccHierarchies");
        CreateTempTable(ref rowset);
        LoadTempTableWithArgs(ref rowset, ctx, assocs, progress);
        rowset.Clear();
        rowset.SetQueryTag("__SEQUENCED_DELETE_ACC_OWNERSHIP_BATCH__");
        rowset.Execute();
        rowset.Clear();
        rowset.SetQueryTag("__SEQUENCED_INSERT_ACC_OWNERSHIP_BATCH__");
        rowset.Execute();
        rowset.Clear();
        rowset.SetQueryTag("__AUDIT_ADD_OWNERSHIP__");
        rowset.Execute();
        IMTSQLRowset errors = GetErrorRowset(ref rowset);
        DropTempTable(ref rowset);
        return errors;
      }
      finally
      {
        Marshal.ReleaseComObject(rowset);
      }
    }
    [AutoComplete]
    public IMTSQLRowset RemoveOwnershipBatch(IMTSessionContext ctx, IMTCollection assocs, IMTProgress progress)
    {
      IMTSQLRowset rowset = (IMTSQLRowset)new RS.MTSQLRowset();
        
      try
      {
        //check auth
        CheckWriteManageSFH(ctx);
        //Create temp table
        rowset.Init(@"Queries\AccHierarchies");
        CreateTempTable(ref rowset);
        LoadTempTableWithArgs(ref rowset, ctx, assocs, progress);
        rowset.Clear();
        rowset.SetQueryTag("__SEQUENCED_DELETE_ACC_OWNERSHIP_BATCH__");
        rowset.Execute();
        rowset.Clear();
        rowset.SetQueryTag("__AUDIT_DELETE_OWNERSHIP__");
        rowset.Execute();
        IMTSQLRowset errors = GetErrorRowset(ref rowset);
        DropTempTable(ref rowset);
        return errors;
      }
      finally
      {
        Marshal.ReleaseComObject(rowset);
      }
    }

    private void CheckWriteManageSFH(IMTSessionContext ctx)
    {
      IMTSecurity sec = new MTSecurityClass();
      try
      {
        IMTCompositeCapability msfh = sec.GetCapabilityTypeByName("Manage Sales Force Hierarchies").CreateInstance();
        msfh.GetAtomicEnumCapability().SetParameter("WRITE");
        msfh.GetAtomicPathCapability().SetParameter("/", MTHierarchyPathWildCard.SINGLE);
        int actorid = ctx.SecurityContext.AccountID;
        ctx.SecurityContext.CheckAccess(msfh);
      }
      finally
      {
        Marshal.ReleaseComObject(sec);
      }
    }

    private void CreateTempTable(ref IMTSQLRowset rowset)
    {
      rowset.Clear();
      rowset.SetQueryTag("__CREATE_BATCH_TEMP_TABLE__");
      rowset.Execute();
    }

    private void DropTempTable(ref IMTSQLRowset rowset)
    {
      rowset.Clear();
      rowset.SetQueryTag("__DROP_BATCH_TEMP_TABLE__");
      rowset.Execute();
    }

    private IMTSQLRowset GetErrorRowset(ref IMTSQLRowset rowset)
    {
      IMTSQLRowset errrs = (IMTSQLRowset)new RS.MTSQLRowsetClass();
      RCD.IMTRcd rcd = new RCD.MTRcd();

      errrs.InitDisconnected();
      errrs.AddColumnDefinition("id_acc","int32",10);
      errrs.AddColumnDefinition("accountname","string", 256);
      errrs.AddColumnDefinition("description","string",256);
      errrs.OpenDisconnected();
      
      rowset.Clear();
      rowset.SetQueryTag("__GET_OWNERSHIP_BATCH_ERRORS__");
      rowset.Execute();
      
      bool bAtLeastOneFailed = false;
      while(System.Convert.ToBoolean(rowset.EOF) == false)
      {
        bAtLeastOneFailed = true;
        errrs.AddRow();
        int owned  = (int)rowset.get_Value("id_owned");
        string ownedname  = (string)rowset.get_Value("OwnedName");
        int status = (int)rowset.get_Value("status");
        errrs.AddColumnData("id_acc",owned);
        try
        {
          errrs.AddColumnData("accountname",ownedname);
        }
        catch(Exception)
        {
          string msg = "Unknown or Invalid Account Name";
          errrs.AddColumnData("accountname", msg);
        }
        try
        {
          errrs.AddColumnData("description",rcd.get_ErrorMessage(status));
        }
        catch(Exception)
        {
          string msg = string.Format("Unknown or Invalid Error Message for Status '{0}'", status);
          errrs.AddColumnData("description", msg);
        }
        rowset.MoveNext();
      }
      if(bAtLeastOneFailed)
        errrs.MoveFirst();
      return errrs;
    }
    
    private void LoadTempTableWithArgs(ref IMTSQLRowset rowset, IMTSessionContext ctx, IMTCollection assocs, IMTProgress progress)
    {
			try
			{
                bool first = true;
                string qstring = string.Empty;
				//Hashtable existing = new Hashtable();
				int n = 0;
        IIdGenerator2 idAuditGenerator = new IdGenerator("id_audit", assocs.Count);
				rowset.Clear();
				/*
				 INSERT INTO #tmp_acc_ownership_batch
				VALUES(%%ID_OWNER%%, %%ID_OWNED%%, %%ID_RELATION%%, %%N_PERCENT%%, %%VT_START%%, %%VT_END%%, %%TT_START%%
				%%ID_AUDIT%%, %%ID_EVENT%%, %%ID_USER%%, %%ID_ENTITY_TYPE%%, 0)
				 */
				foreach (IOwnershipAssociation assoc in assocs)
				{
                    if (first)
                    {
                       qstring = "begin ";
                       first = false;
                    }
					AdjustEndDate(assoc);
					int owner = assoc.OwnerAccount;
					int owned = assoc.OwnedAccount;
					DateTime start = assoc.StartDate;
					DateTime end = assoc.EndDate;
					int relation = assoc.RelationTypeID;
					int percent = assoc.PercentOwnership;
					rowset.SetQueryTag("__INSERT_INTO_BATCH_TEMP_TABLE__");
					rowset.AddParam("%%ID_OWNER%%", owner, false);
					rowset.AddParam("%%ID_OWNED%%", owned, false);
					string key = MakeKey(owner, owned);
					//if(existing.ContainsKey(key))
					//  throw new OwnershipException(string.Format("Attempt was made to perform a batch ownership operation twice on the same Owner Account/Owned Account combination"));
					//else
					//  existing[key] = assoc;
					rowset.AddParam("%%ID_RELATION%%", relation, false);
					rowset.AddParam("%%N_PERCENT%%", percent, false);
					rowset.AddParam("%%VT_START%%", start, false);
					rowset.AddParam("%%VT_END%%", end, false);
					rowset.AddParam("%%TT_START%%", MetraTime.Now, false);
					//auditing params
          rowset.AddParam("%%ID_AUDIT%%", idAuditGenerator.NextId, false);
					rowset.AddParam("%%ID_EVENT%%", MTAuditEvent.AUDITEVENT_ACCOUNT_OWNERSHIP_CREATE, false);
					rowset.AddParam("%%ID_USER%%", ctx.AccountID, false);
					rowset.AddParam("%%ID_ENTITY_TYPE%%", MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT, false);
					qstring += rowset.GetQueryString();
					rowset.Clear();
					//do 100 inserts at a time
					if (++n % 100 == 0)
					{
                        first = true;
                        qstring += " end;";
						rowset.Clear();
						rowset.SetQueryString(qstring);
						rowset.Execute();
						qstring = string.Empty;
						if(progress != null)
							progress.SetProgress(n, assocs.Count);
					}
				}
				//stragglers
				if (qstring.Length > 0)
				{
                    first = true;
                    qstring += " end;";
					rowset.Clear();
					rowset.SetQueryString(qstring);
					rowset.Execute();
					qstring = string.Empty;
					if(progress != null)
						progress.SetProgress(n, assocs.Count);
				}
			}
			catch(Exception)
			{
				throw;
			}

    }
    private string MakeKey(int owner, int owned)
    {
      return string.Format("{0}_{1}", owner, owned);
    }

    
    private const uint MT_OWNERSHIP_START_DATE_AFTER_END_DATE = 0xE2FF0050;
    private const uint MT_OWNERSHIP_PERCENT_OUT_OF_RANGE = 0xE2FF0051;
    private const uint MT_OWNED_ACCOUNT_NOT_SUBSCRIBER = 0xE2FF0052;
    private const uint MT_CAN_NOT_OWN_SELF = 0xE2FF0053;
    private const uint MT_OWNERSHIP_START_DATE_NOT_SET = 0xE2FF0054;
    private const uint MT_OWNERSHIP_END_DATE_NOT_SET = 0xE2FF0055;

    private void Validate(IOwnershipAssociation assoc, int addorremove)
    {
      if(assoc.OwnerAccount == assoc.OwnedAccount)
        throw new OwnershipException("Account can not own itself", MT_CAN_NOT_OWN_SELF);
      if(assoc.StartDate == DateTime.MinValue)
      {
        throw new OwnershipException("Relationship Start Date has to be set", MT_OWNERSHIP_START_DATE_NOT_SET);
      }
      
      if (addorremove > 0)
      {
        if(assoc.PercentOwnership < 0 || assoc.PercentOwnership > 100)
          throw new OwnershipException("Ownership percentage has to be a value between 0 and 100", MT_OWNERSHIP_PERCENT_OUT_OF_RANGE);
        if(assoc.RelationTypeID < 0)
          throw new OwnershipException("Relation Type has to be set");
        if(assoc.EndDate == DateTime.MinValue)
          throw new OwnershipException("Relationship End Date has to be set", MT_OWNERSHIP_END_DATE_NOT_SET);
        if(assoc.StartDate > assoc.EndDate)
          throw new OwnershipException("Relationship Start Date has to be before End Date", MT_OWNERSHIP_START_DATE_AFTER_END_DATE);
      
      }
			AdjustEndDate(assoc);

    }

		private void AdjustEndDate(IOwnershipAssociation assoc)
		{
			if(assoc.StartDate == assoc.EndDate)
			{
				assoc.EndDate = assoc.EndDate.AddDays(1);
			}
		}

    
  }

  [Guid("1706244c-c0c0-48be-b863-4c806f218990")]
  public interface IOwnershipReader
  {
    IMTSQLRowset GetOwnedAccountsAsRowset(IMTSessionContext ctx, IMTYAAC acc, DateTime aRefDateTime);
    IMTSQLRowset GetOwnerAccountsAsRowset(IMTSessionContext ctx, IMTYAAC acc, DateTime aRefDateTime);
    int GetAuthScore(IMTSessionContext ctx);
  }

  [Guid("66dc0226-5b90-4c45-92bf-f8aa520d7c78")]
  [Transaction(TransactionOption.Supported, Isolation=TransactionIsolationLevel.Any)]
  public class OwnershipReader : ServicedComponent, IOwnershipReader
  {
    public OwnershipReader(){}

    public IMTSQLRowset GetOwnedAccountsHierarchicalAsRowset(IMTSessionContext ctx, IMTYAAC acc, ViewHint aHint)
    {
      IMTSQLRowset rowset = (IMTSQLRowset)new RS.MTSQLRowset();
      rowset.Init(@"Queries\AccHierarchies");
      rowset.SetQueryTag("__GET_OWNED_ACCOUNTS_HIERARCHICAL__");
      rowset.AddParam("%%ID_LANG%%", ctx.LanguageID, false);
      rowset.AddParam("%%ID_ACC%%", acc.AccountID, false);
      rowset.AddParam("%%MAX_DATE%%", MetraTime.Max, false);
      rowset.AddParam("%%VIEW_CONSTRAINT%%", GetGenerationConstraint(aHint, ctx), false);
      
      rowset.ExecuteDisconnected();
      ReplaceEnums(rowset);
      return rowset;
    }
    int GetGenerationConstraint(ViewHint aHint, IMTSessionContext ctx)
    {
      //Return the minimum number of generations between what's
      //the actor wants to see (view hint) and what the actor is allowed to see from
      //security point of view
      return Math.Min(GetAuthScore(ctx), GetHintScore(aHint));
    }

    public int GetAuthScore(IMTSessionContext ctx)
    {
      IMTSecurity sec = new MTSecurityClass();
      IMTCompositeCapability moa = sec.GetCapabilityTypeByName("Manage Owned Accounts").CreateInstance();
      moa.GetAtomicEnumCapability().SetParameter("READ");
      moa.GetAtomicPathCapability().SetParameter("/", MTHierarchyPathWildCard.RECURSIVE);

      bool canmanagealldescendents = ctx.SecurityContext.HasAccess(moa);
      if(canmanagealldescendents)
        return 1000000;
      moa.GetAtomicPathCapability().SetParameter("/", MTHierarchyPathWildCard.DIRECT_DESCENDENTS);
      bool canmanagedirectdescendents = ctx.SecurityContext.HasAccess(moa);
      if(canmanagedirectdescendents)
        return 2;
      moa.GetAtomicPathCapability().SetParameter("/", MTHierarchyPathWildCard.SINGLE);
      bool canmanagesingle = ctx.SecurityContext.HasAccess(moa);
      if(canmanagesingle)
        return 1;
      else
        return 0;
      
    }

    private int GetHintScore(ViewHint aHint)
    {
      switch(aHint)
      {
        case ViewHint.Direct:
          return 1;
        case ViewHint.DirectDescendents:
          return 2;
        case ViewHint.AllDescendents:
          //unrestricted view
          return 1000000;
        default: Debug.Assert(false); return 0;
      }
    }
    
    public IMTSQLRowset GetOwnedAccountsAsRowset(IMTSessionContext ctx, IMTYAAC acc, DateTime aRefDateTime)
    {
      CheckReadManageSFH(ctx);
      IMTSQLRowset rowset = (IMTSQLRowset)new RS.MTSQLRowset();
      rowset.Init(@"Queries\AccHierarchies");
      DateTime refdate = aRefDateTime;
      rowset.SetQueryTag("__GET_OWNED_ACCOUNTS__");
      rowset.AddParam("%%ID_LANG%%", ctx.LanguageID, false);
      rowset.AddParam("%%ID_ACC%%", acc.AccountID, false);
      rowset.AddParam("%%REF_DATE%%", aRefDateTime, false);
      rowset.AddParam("%%MAX_DATE%%", MetraTime.Max, false);
      rowset.ExecuteDisconnected();
      ReplaceEnums(rowset);
      return rowset;
    }
    
    public IMTSQLRowset GetOwnerAccountsAsRowset(IMTSessionContext ctx, IMTYAAC acc, DateTime aRefDateTime)
    {
      CheckReadManageSFH(ctx);
      IMTSQLRowset rowset = (IMTSQLRowset)new RS.MTSQLRowset();
      rowset.Init(@"Queries\AccHierarchies");
      DateTime refdate = aRefDateTime;
      rowset.SetQueryTag("__GET_OWNER_ACCOUNTS__");
      rowset.AddParam("%%ID_LANG%%", ctx.LanguageID, false);
      rowset.AddParam("%%ID_ACC%%", acc.AccountID, false);
      rowset.AddParam("%%REF_DATE%%", aRefDateTime, false);
      rowset.AddParam("%%MAX_DATE%%", MetraTime.Max, false);
      rowset.ExecuteDisconnected();
      ReplaceEnums(rowset);
      return rowset;
    }

    private void CheckReadManageSFH(IMTSessionContext ctx)
    {
      IMTSecurity sec = new MTSecurityClass();
      IMTCompositeCapability msfh = sec.GetCapabilityTypeByName("Manage Sales Force Hierarchies").CreateInstance();
      msfh.GetAtomicEnumCapability().SetParameter("READ");
      msfh.GetAtomicPathCapability().SetParameter("/", MTHierarchyPathWildCard.SINGLE);
      int actorid = ctx.SecurityContext.AccountID;
      ctx.SecurityContext.CheckAccess(msfh);
    }


    private void ReplaceEnums(IMTSQLRowset rs)
    {
      bool atleastone = false;
      while(System.Convert.ToBoolean(rs.EOF) == false)
      {
        atleastone = true;
        int id  = (int)rs.get_Value("id_relation_type");
        int val = 0;
        string enumval = new EnumConfigClass().GetEnumeratorValueByID(id);
        try
        {
          val = System.Convert.ToInt32(enumval); 
          rs.ModifyColumnData("id_relation_type", val);
        }
        catch(Exception e)
        {
          string msg = e.Message;
        }
        rs.MoveNext();
      }

      if(atleastone)
        rs.MoveFirst();

    }
  }


  [Guid("52016c47-67c3-4a8d-b029-a207f6f070dd")]
  [ClassInterface(ClassInterfaceType.None)]
  public class OwnershipException : COMException
  {
    public OwnershipException(string msg, uint code) : base(msg, unchecked((int)code)){}
    public OwnershipException(string msg, int code) : base(msg, code){}
    public OwnershipException(string msg) : base(msg){}
  }

	
}
