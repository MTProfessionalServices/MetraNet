using System;
using System.Xml;
using System.Runtime.InteropServices;

namespace MetraTech.Product
{
  using MetraTech.DataAccess;
  using MetraTech.Xml;
  using MetraTech.Interop.MTProductCatalog;
  using MetraTech.Interop.MTEnumConfig;

  [ComVisible(false)]
  public class MTId
  {
    private static int mNext;
    private static bool mInit=false;
    public static int Next()
    {
      lock(typeof(MTId))
      {
        if(!mInit)
        {
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTStatement stmt = conn.CreateStatement("SELECT MAX(id_mt) FROM t_mt_id"))
                {
                    using (IMTDataReader rs = stmt.ExecuteReader())
                    {
                        if (!rs.Read()) throw new ApplicationException("Failed to read from t_mt_id");
                        mNext = rs.IsDBNull(0) ? 1 : rs.GetInt32(0) + 1;
                    }
                }
            }

          mInit = true;
        }
        
        return mNext++;
      }
    }
  };

  [ComVisible(false)]
  public class BasePropsId
  {
    private static int mNext;
    private static bool mInit=false;
    public static int Next()
    {
      lock(typeof(BasePropsId))
      {
        if(!mInit)
        {
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTStatement stmt = conn.CreateStatement("SELECT MAX(id_prop) FROM t_base_props"))
                {
                    using (IMTDataReader rs = stmt.ExecuteReader())
                    {
                        if (!rs.Read()) throw new ApplicationException("Failed to read from t_base_props");
                        mNext = rs.IsDBNull(0) ? 1 : rs.GetInt32(0) + 1;
                    }
                }
            }

          mInit = true;
        }
        
        return mNext++;
      }
    }
  };

  [ComVisible(false)]
  public class GroupSubId
  {
    private static int mNext;
    private static bool mInit=false;
    public static int Next()
    {
      lock(typeof(GroupSubId))
      {
        if(!mInit)
        {
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTStatement stmt = conn.CreateStatement("SELECT MAX(id_group) FROM t_group_sub"))
                {
                    using (IMTDataReader rs = stmt.ExecuteReader())
                    {
                        if (!rs.Read()) throw new ApplicationException("Failed to read from t_group_sub");
                        mNext = rs.IsDBNull(0) ? 1 : rs.GetInt32(0) + 1;
                    }
                }
            }

          mInit = true;
        }
        
        return mNext++;
      }
    }
  };

  [ComVisible(false)]
  public interface IBulkLoadWriter : IDisposable
  {
    void Commit();
  }

  [ComVisible(false)]
  public class BulkLoadWriter : IBulkLoadWriter
  {
    protected IBulkInsert mBulkInsert;
    protected BulkLoadWriter(string table)
    {
			mBulkInsert = BulkInsertManager.CreateBulkInsert("NetMeter");
      mBulkInsert.PrepareForInsert(table, 1000);
    }
    protected int mRowsInBatch=0;
    protected void AddBatch()
    {
      mBulkInsert.AddBatch();
      if(++mRowsInBatch >= 1000)
      {
        Commit();
        mRowsInBatch = 0;
      }
    }

    public void Commit()
    {
      mBulkInsert.ExecuteBatch();
    }

    public void Dispose()
    {
      mBulkInsert.Dispose();
    }
  }

  [ComVisible(false)]
  public class DescriptionWriter : BulkLoadWriter
  {
    public int Add(String value, int languageCode)
    {
      if (value == null)
      {
        return 0;
      }
      else
      {
        int id = MTId.Next();
        mBulkInsert.SetValue(1, MTParameterType.Integer, id);
        mBulkInsert.SetValue(2, MTParameterType.Integer, languageCode);  
        mBulkInsert.SetValue(3, MTParameterType.WideString, value);
        AddBatch();
        return id;
      }
    }

    public DescriptionWriter()
    :
    base("ld_description")
    {
    }
  }

  [ComVisible(false)]
  public class BasePropsWriter : BulkLoadWriter
  {
    DescriptionWriter mDesc;

    public int Add(int kind, string name, string displayName, string desc, int languageCode)
    {
      int id = BasePropsId.Next();
      mBulkInsert.SetValue(1, MTParameterType.Integer, id);
      mBulkInsert.SetValue(2, MTParameterType.Integer, kind);
      mBulkInsert.SetValue(3, MTParameterType.Integer, mDesc.Add(name, languageCode));
      mBulkInsert.SetValue(4, MTParameterType.Integer, mDesc.Add(desc, languageCode));
      if(name != null) mBulkInsert.SetValue(5, MTParameterType.WideString, name);
      if(desc != null) mBulkInsert.SetValue(6, MTParameterType.WideString, desc);
      mBulkInsert.SetValue(7, MTParameterType.String, "N");
      mBulkInsert.SetValue(8, MTParameterType.String, "N");
      mBulkInsert.SetValue(9, MTParameterType.Integer, mDesc.Add(displayName, languageCode));
      if(displayName != null) mBulkInsert.SetValue(10, MTParameterType.WideString, displayName);
      AddBatch();      
      return id;
    }

    public BasePropsWriter(DescriptionWriter desc)
    :
    base("ld_base_props")
    {
      mDesc = desc;

    }
  }

  [ComVisible(false)]
  public class EffectiveDateWriter : BulkLoadWriter
  {
    BasePropsWriter mBaseProps;
    public int Add(int startType, DateTime startTime, int startOffset,
                   int endType, DateTime endTime, int endOffset)
    {
      int id = mBaseProps.Add(160, null, null, null, 840);
      mBulkInsert.SetValue(1, MTParameterType.Integer, id);
      mBulkInsert.SetValue(2, MTParameterType.Integer, startType);
      mBulkInsert.SetValue(3, MTParameterType.DateTime, startTime);
      mBulkInsert.SetValue(4, MTParameterType.Integer, startOffset);
      mBulkInsert.SetValue(5, MTParameterType.Integer, endType);
      mBulkInsert.SetValue(6, MTParameterType.DateTime, endTime);
      mBulkInsert.SetValue(7, MTParameterType.Integer, endOffset);  
      AddBatch();
      return id;
    }

    public EffectiveDateWriter(BasePropsWriter bp)
    :
    base("ld_effectivedate")
    {
      mBaseProps = bp;
    }
  }

  [ComVisible(false)]
  public class RateScheduleWriter : BulkLoadWriter
  {
    private BasePropsWriter mBaseProps;
    private EffectiveDateWriter mEffDate;
    public int Add(string name, string desc, int id_pl, 
                   int startType, DateTime startTime, int startOffset,
                   int endType, DateTime endTime, int endOffset,
                   string piName,
                   string ptName)
    {
      // Always create rate schedules anonymously.
      int id = mBaseProps.Add(130, null, null, null, 840);
      mBulkInsert.SetValue(1, MTParameterType.Integer, id);
      mBulkInsert.SetValue(2, MTParameterType.Integer, id_pl);
      mBulkInsert.SetValue(3, MTParameterType.Integer, mEffDate.Add(startType, startTime, startOffset, endType, endTime, endOffset));
      mBulkInsert.SetValue(4, MTParameterType.WideString, piName);
      mBulkInsert.SetValue(5, MTParameterType.WideString, ptName);
      AddBatch();
      return id;
    }

    public RateScheduleWriter(BasePropsWriter bp, EffectiveDateWriter ed)
    :
    base("ld_rsched")
    {
      mBaseProps = bp;
      mEffDate = ed;
    }
  }
  
  [ComVisible(false)]
  public class ICBPricelistWriter : BulkLoadWriter
  {
    private BasePropsWriter mBaseProps;

    public int Add(int id_sub,
                   string poName,
                   string piName,
                   string ptName,
                   string accName,
                   string accNamespace)
    {
      int id = mBaseProps.Add(150, null, null, null, 840);
      mBulkInsert.SetValue(1, MTParameterType.Integer, id);
      mBulkInsert.SetValue(2, MTParameterType.Integer, id_sub);
      mBulkInsert.SetValue(3, MTParameterType.WideString, poName);
      mBulkInsert.SetValue(4, MTParameterType.WideString, piName);
      mBulkInsert.SetValue(5, MTParameterType.WideString, ptName);
      mBulkInsert.SetValue(6, MTParameterType.WideString, accName);
      mBulkInsert.SetValue(7, MTParameterType.WideString, accNamespace);
      AddBatch();
      return id;
    }

    public ICBPricelistWriter(BasePropsWriter bp)
    :
    base("ld_icb")
    {
      mBaseProps = bp;
    }
  }

  [ComVisible(false)]
  public class ParameterTableColumnBinding
  {
    private static System.Collections.Specialized.StringDictionary mOpToDb;
    private static string NormalizeTest(string s)
    {
      if (mOpToDb == null)
      {
        lock(typeof(ParameterTableColumnBinding))
        {
          if(mOpToDb == null)
          {
            mOpToDb = new System.Collections.Specialized.StringDictionary();
            // Initialize op hash table
            mOpToDb.Add("!=", "!=");
            mOpToDb.Add("<", "<");
            mOpToDb.Add("<=", "<=");
            mOpToDb.Add("=", "=");
            mOpToDb.Add("==", "=");
            mOpToDb.Add(">", ">");
            mOpToDb.Add(">=", ">=");
            mOpToDb.Add("equal", "=");
            mOpToDb.Add("equals", "=");
            mOpToDb.Add("great_equal", ">=");
            mOpToDb.Add("great_than", ">");
            mOpToDb.Add("greater_equal", ">=");
            mOpToDb.Add("greater_than", ">");
            mOpToDb.Add("less_equal", "<=");
            mOpToDb.Add("less_than", "<");
            mOpToDb.Add("not_equal", "!=");
            mOpToDb.Add("not_equals", "!=");
          }
        }
      }
      return mOpToDb[s];
    }

    private IEnumConfig mEnumConfig;
    
    private MTParameterType mColType;
    public MTParameterType ColumnType
    {
      get { return mColType; }
      set { mColType = value; }
    }

    private int mPosition;
    public int Position
    {
      get { return mPosition; }
      set { mPosition = value; }
    }

    private bool mIsOpPerRule;
    public bool IsOperatorPerRule
    {
      get { return mIsOpPerRule; }
    }

    private string mName;
    public string Name
    {
      get { return mName; }
      set { mName = value; }
    }

    public void SetValue(IBulkInsert bulkInsert, IMTActionSet actions)
    {
      IMTAssignmentAction action = null;
      try
      {
        action = (IMTAssignmentAction) actions[this.Name];
      }
      catch(Exception)
      {
      }
      if(action != null)
      {
        if(action.PropertyType == MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_ENUM)
        {
          bulkInsert.SetValue(this.Position, MTParameterType.Integer, mEnumConfig.GetID(action.EnumSpace,
                                                                                        action.EnumType,
                                                                                        (string) action.PropertyValue));
        }
        else if(action.PropertyType == MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_BOOLEAN)
        {
          short shortVal = (short) action.PropertyValue;
          bulkInsert.SetValue(this.Position, MTParameterType.String, shortVal != 0 ? "1" : "0");
        }
        else
        {
          bulkInsert.SetValue(this.Position, this.ColumnType, action.PropertyValue);
        }
      }
    }

    public void SetValue(IBulkInsert bulkInsert, IMTConditionSet conditions)
    {
      int position=this.Position;
      IMTSimpleCondition condition = null;
      try
      {
        condition = (IMTSimpleCondition) conditions[this.Name];
      }
      catch(Exception )
      {
      }
      if(condition != null)
      {
        if(IsOperatorPerRule)
        {
          bulkInsert.SetValue(position++, MTParameterType.WideString, NormalizeTest(condition.Test));
        }
        if(condition.ValueType == MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_ENUM)
        {
          bulkInsert.SetValue(position, MTParameterType.Integer, mEnumConfig.GetID(condition.EnumSpace,
                                                                                   condition.EnumType,
                                                                                   (string) condition.Value));
        }
        else if(condition.ValueType == MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_BOOLEAN)
        {
          short shortVal = (short) condition.Value;
          bulkInsert.SetValue(position, MTParameterType.String, shortVal != 0 ? "1" : "0");
        }
        else
        {
          bulkInsert.SetValue(position, this.ColumnType, condition.Value);
        }
      }
    }

    public ParameterTableColumnBinding(MetraTech.Interop.MTProductCatalog.PropValType propValType, int position, string name, bool isOpPerRule)
    {
      mEnumConfig = new EnumConfigClass();
      mPosition = position;
      mName = name;
      mIsOpPerRule = isOpPerRule;
      // Map MetraTech.Interop.MTProductCatalog.PropValType to MTParameterType
      switch(propValType)
      {
      case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_INTEGER:
      case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_ENUM:
        mColType = MTParameterType.Integer;
        break;
      case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_BIGINTEGER:
        mColType = MTParameterType.BigInteger;
        break;
      case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_STRING:
      case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_UNICODE_STRING:
        mColType = MTParameterType.WideString;
        break;
      case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_ASCII_STRING:
        mColType = MTParameterType.String;
        break;
      case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DECIMAL:
        mColType = MTParameterType.Decimal;
        break;
      case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DATETIME:
        mColType = MTParameterType.DateTime;
        break;
      case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_BOOLEAN:
        mColType = MTParameterType.String;
        break;
      default:
        throw new ApplicationException("Unsupported property type");
      }
    }
  }

  [ComVisible(false)]
  public class ParameterTableWriter : IBulkLoadWriter
  {
    private string mTableName;
    private System.Collections.ArrayList mConditionBindings = new System.Collections.ArrayList();
    private System.Collections.ArrayList mActionBindings = new System.Collections.ArrayList();
    private IBulkInsert mBulkInsert;

    private int mRowsInBatch=0;
    private void AddBatch()
    {
      mBulkInsert.AddBatch();
      if(++mRowsInBatch >= 1000)
      {
        Commit();
        mRowsInBatch = 0;
      }
    }
    public void Dispose()
    {
      mBulkInsert.Dispose();
    }
    
    public void Add(int id_rsched, int order, DateTime tt_start, DateTime tt_end, int id_audit, IMTActionSet actions)
    {
      mBulkInsert.SetValue(1, MTParameterType.Integer, id_rsched);
      mBulkInsert.SetValue(2, MTParameterType.Integer, order);
      mBulkInsert.SetValue(3, MTParameterType.DateTime, tt_start);
      mBulkInsert.SetValue(4, MTParameterType.DateTime, tt_end);
      mBulkInsert.SetValue(5, MTParameterType.Integer, id_audit);

      foreach(ParameterTableColumnBinding b in mActionBindings)
      {
        b.SetValue(mBulkInsert, actions);
      }
      AddBatch();
    }

    public void Add(int id_rsched, int order, DateTime tt_start, DateTime tt_end, int id_audit, IMTRule rule)
    {
      mBulkInsert.SetValue(1, MTParameterType.Integer, id_rsched);
      mBulkInsert.SetValue(2, MTParameterType.Integer, order);
      mBulkInsert.SetValue(3, MTParameterType.DateTime, tt_start);
      mBulkInsert.SetValue(4, MTParameterType.DateTime, tt_end);
      mBulkInsert.SetValue(5, MTParameterType.Integer, id_audit);

      IMTConditionSet conditions = rule.Conditions;
      foreach(ParameterTableColumnBinding b in mConditionBindings)
      {
        b.SetValue(mBulkInsert, conditions);
      }

      IMTActionSet actions = rule.Actions;
      foreach(ParameterTableColumnBinding b in mActionBindings)
      {
        b.SetValue(mBulkInsert, actions);
      }
      AddBatch();
    }

    public void Add(int id_rsched, DateTime tt_start, DateTime tt_end, int id_audit, IMTRuleSet rules)
    {
      int order = 0;
      foreach(IMTRule rule in rules)
      {
        Add(id_rsched, order++, tt_start, tt_end, id_audit, rule);
      }
      
      IMTActionSet defaultActions = rules.DefaultActions;
      if(defaultActions != null)
      {
        Add(id_rsched, order++, tt_start, tt_end, id_audit, defaultActions);
      }
    }

    public void Add(int id_rsched, DateTime tt_start, DateTime tt_end, int id_audit, string rules)
    {
      rules = rules.Trim();
      MetraTech.Interop.PropSet.IMTConfig config = new MetraTech.Interop.PropSet.MTConfigClass();
      config.AutoEnumConversion = false;
      bool dummy=false;
      MetraTech.Interop.MTRuleSet.IMTConfigPropSet propSet = 
      (MetraTech.Interop.MTRuleSet.IMTConfigPropSet)config.ReadConfigurationFromString(rules, out dummy);
      MetraTech.Interop.MTRuleSet.IMTRuleSet rs = new MetraTech.Interop.MTRuleSet.MTRuleSetClass();
      rs.ReadFromSet(propSet);
      Add(id_rsched, tt_start, tt_end, id_audit, (IMTRuleSet) rs);
    }

    public void AddFromFile(int id_rsched, DateTime tt_start, DateTime tt_end, int id_audit, string filename)
    {
      MetraTech.Interop.MTRuleSet.IMTRuleSet rs = new MetraTech.Interop.MTRuleSet.MTRuleSetClass();
      rs.Read(filename);
      Add(id_rsched, tt_start, tt_end, id_audit, (IMTRuleSet) rs);
    }

    public void Commit()
    {
      mBulkInsert.ExecuteBatch();
    }

    public ParameterTableWriter(IMTParamTableDefinition pt)
    {
      mTableName = "ld_" + pt.DBTableName.Substring(2);
      // Create a load table from the existing parameter table
      string createStmt = "if object_id('" + mTableName + "') is null SELECT * INTO " 
      + mTableName + " FROM " + pt.DBTableName + " WHERE 0=1";
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTStatement stmt = conn.CreateStatement(createStmt))
          {
              stmt.ExecuteNonQuery();
          }
      }

      // Have to be prepared for order of columns to be whacked.
      System.Collections.Hashtable columnPositions = new System.Collections.Hashtable();
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
          String queryString = "SELECT * FROM " + mTableName + " WHERE 0=1";
          using (IMTStatement stmt = conn.CreateStatement(queryString))
          {
              using (IMTDataReader rs = stmt.ExecuteReader())
              {
                  // position 1-5 is id_sched, n_order, tt_start, tt_end, id_audit.
                  // Note that IBulkInsert used 1-index columns while IMTDataReader is 0-indexed.
                  if (rs.GetOrdinal("id_sched") != 0 ||
                     rs.GetOrdinal("n_order") != 1 ||
                     rs.GetOrdinal("tt_start") != 2 ||
                     rs.GetOrdinal("tt_end") != 3 ||
                     rs.GetOrdinal("id_audit") != 4)
                  {
                      throw new ApplicationException("Parameter table columns are out of whack");
                  }

                  // Set up bindings. Get position from metadata rowset and correct for indexing.
                  IMTCollection conditions = pt.ConditionMetaData;
                  foreach (IMTConditionMetaData condition in conditions)
                  {
                      // If operator per rule, then the operator column come first, therefore correct by not adding 1.
                      int pos = condition.OperatorPerRule ? rs.GetOrdinal(condition.ColumnName) : rs.GetOrdinal(condition.ColumnName) + 1;
                      mConditionBindings.Add(new ParameterTableColumnBinding(condition.DataType, pos, condition.PropertyName, condition.OperatorPerRule));
                  }
                  IMTCollection actions = pt.ActionMetaData;
                  foreach (IMTActionMetaData action in actions)
                  {
                      int pos = rs.GetOrdinal(action.ColumnName) + 1;
                      mActionBindings.Add(new ParameterTableColumnBinding(action.DataType, pos++, action.PropertyName, false));
                  }
              }
          }
      }

			mBulkInsert = BulkInsertManager.CreateBulkInsert("NetMeter");
      mBulkInsert.PrepareForInsert(mTableName, 1000);
    }
  }

  [ComVisible(false)]
  public class GroupSubscriptionWriter : BulkLoadWriter
  {
    private IIdGenerator2 mSubscriptionId;
    private bool mIsRestrictedHierarchyRules;

    public int Add(String name, String desc, String poName, bool supportGroupOps, bool proportional, 
                   int corporateAccountId, String corporateAccountSpace, String corporateAccountName,
                   int distributionAccountId, String distributionAccountSpace, String distributionAccountName,
                   int idUsageCycle)
    {
      int subId = mSubscriptionId.NextId;
      int groupId = GroupSubId.Next();
      mBulkInsert.SetValue(1, MTParameterType.Integer, subId);
      mBulkInsert.SetValue(2, MTParameterType.Integer, groupId);
      if(name != null) mBulkInsert.SetValue(3, MTParameterType.WideString, name);
      if(desc != null) mBulkInsert.SetValue(4, MTParameterType.WideString, desc);
      if(poName != null) mBulkInsert.SetValue(5, MTParameterType.WideString, poName);
      mBulkInsert.SetValue(6, MTParameterType.String, "N");
      mBulkInsert.SetValue(7, MTParameterType.String, supportGroupOps?"Y":"N");
      mBulkInsert.SetValue(8, MTParameterType.String, proportional?"Y":"N");
      if(mIsRestrictedHierarchyRules)
      {
        mBulkInsert.SetValue(9, MTParameterType.Integer, corporateAccountId);
        if(corporateAccountSpace != null) mBulkInsert.SetValue(10, MTParameterType.WideString, corporateAccountSpace);
        if(corporateAccountName != null) mBulkInsert.SetValue(11, MTParameterType.WideString, corporateAccountName);
      }
      else
      {
        mBulkInsert.SetValue(9, MTParameterType.Integer, 1);
      }
      mBulkInsert.SetValue(12, MTParameterType.Integer, distributionAccountId);
      if(distributionAccountSpace != null) mBulkInsert.SetValue(13, MTParameterType.WideString, distributionAccountSpace);
      if(distributionAccountName != null) mBulkInsert.SetValue(14, MTParameterType.WideString, distributionAccountName);
      mBulkInsert.SetValue(15, MTParameterType.Integer, idUsageCycle);
      AddBatch();
      return subId;
    }

    public GroupSubscriptionWriter()
    :
    base("ld_group_sub")
    {
      MetraTech.Interop.MTProductCatalog.IMTProductCatalog pc = new MetraTech.Interop.MTProductCatalog.MTProductCatalogClass();
      mIsRestrictedHierarchyRules = pc.IsBusinessRuleEnabled(MetraTech.Interop.MTProductCatalog.MTPC_BUSINESS_RULE.MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations);
      mSubscriptionId = new IdGenerator("id_subscription", 1000);
    }
  }

  [ComVisible(false)]
  public class IndividualSubscriptionWriter : BulkLoadWriter
  {
    private IIdGenerator2 mSubscriptionId;

    public int Add(String poName, int accountId, String accountName, String accountSpace, DateTime start, DateTime end)
    {
      int subId = mSubscriptionId.NextId;
      mBulkInsert.SetValue(1, MTParameterType.Integer, subId);
      mBulkInsert.SetValue(2, MTParameterType.WideString, poName);
      if(accountName != null) mBulkInsert.SetValue(3, MTParameterType.WideString, accountName);
      if(accountSpace != null) mBulkInsert.SetValue(4, MTParameterType.WideString, accountSpace);
      mBulkInsert.SetValue(5, MTParameterType.Integer, accountId);
      mBulkInsert.SetValue(6, MTParameterType.DateTime, start);
      mBulkInsert.SetValue(7, MTParameterType.DateTime, end);
      AddBatch();
      return subId;
    }

    public IndividualSubscriptionWriter()
    :
    base("ld_sub")
    {
      mSubscriptionId = new IdGenerator("id_subscription", 1000);
    }
  }

  [ComVisible(false)]
  public class IndividualSubscriptionLoader : IBulkLoadWriter
  {
    private ILogger mLog;
    private DescriptionWriter mDescription;
    private BasePropsWriter mBaseProps;
    private EffectiveDateWriter mEffectiveDate;
    private RateScheduleWriter mRateSchedule;
    private ICBPricelistWriter mICB;
    private IndividualSubscriptionWriter mIndividualSubscription;
    private System.Collections.Hashtable mParamTables;
    private System.Collections.ArrayList mAllWriters;

    private MetraTech.Interop.MTProductCatalog.IMTProductCatalog mPC;

    public ParameterTableWriter GetParameterTableWriter(string ptName)
    {
      if(!mParamTables.Contains(ptName))
      {
        MetraTech.Interop.MTProductCatalog.IMTParamTableDefinition pt = mPC.GetParamTableDefinitionByName(ptName);
        if(null == pt)
        {
          throw new ApplicationException("Cannot find parameter table definition in product catalog.  Name = " + ptName);
        }
        ParameterTableWriter ptw = new ParameterTableWriter(pt);
        mParamTables.Add(ptName, ptw);
        mAllWriters.Add(ptw);
      }
      return (ParameterTableWriter) mParamTables[ptName];
    }

    public void Dispose()
    {
      foreach(IBulkLoadWriter blw in mAllWriters)
      {
        blw.Dispose();
      }
    }

    public void Commit()
    {
      foreach(IBulkLoadWriter blw in mAllWriters)
      {
        blw.Commit();
      }
    }

    public void Load(string [] filenames)
    {
      for(int i=0; i<filenames.Length; i++)
      {
        Load(filenames[i]);
      }
    }

		public void Load(string filename)
		{
			try
			{
				mLog.LogInfo("Loading from file " + filename);
				DateTime now = MetraTech.MetraTime.Now;
				DateTime maxTime = MetraTech.MetraTime.Max;
				// Don't worry about abstracting the file format yet.  
				// TODO: Use a builder pattern here...
				MTXmlDocument xml = new MTXmlDocument();
				xml.Load(filename);
        
				// The main loop is over group subs,
				// then over icb rate schedules
				foreach(XmlNode gs in xml.SelectNodes("xmlconfig/subscriptions/subscription"))
				{
					string poName = gs.Attributes["name"].Value;
					// Snarf the properties
					string accountId = MTXmlDocument.GetNodeValueAsString(gs, "property[@name='accountID']");
          DateTime subEndDate = MTXmlDocument.GetNodeValueAsDateTime(gs, "pctimespan/property[@name='EndDate']");
          int subEndDateType = MTXmlDocument.GetNodeValueAsInt(gs, "pctimespan/property[@name='EndDateType']");
          int subEndOffset = MTXmlDocument.GetNodeValueAsInt(gs, "pctimespan/property[@name='EndOffset']");
          DateTime subStartDate = MTXmlDocument.GetNodeValueAsDateTime(gs, "pctimespan/property[@name='StartDate']");
          int subStartDateType = MTXmlDocument.GetNodeValueAsInt(gs, "pctimespan/property[@name='StartDateType']");
          int subStartOffset = MTXmlDocument.GetNodeValueAsInt(gs, "pctimespan/property[@name='StartOffset']");
					string accountName = MTXmlDocument.GetNodeValueAsString(gs, "username");
					string accountSpace = MTXmlDocument.GetNodeValueAsString(gs, "namespace");

					int id_sub = mIndividualSubscription.Add(poName, -1, accountName, accountSpace, subStartDate, subEndDate);

					foreach(XmlNode icb in gs.SelectNodes("icbs/icbs_child/icb"))
					{
						// I believe the currency is no longer needed; since the currency of the po is used.
						string currency = MTXmlDocument.GetNodeValueAsString(icb, "currency");
						// ICB can have multiple rate schedules per pricelist
						// The monstrous t_pl_map is at the heart of the goofiness in the following code.
						// It is so denormalized that the same data elements wind up in both the pricelist (and its
						// icb mappings) and the rate schedule itself.
            // These are the data necessary for creating the ICB; unfortunately stored in XML with the
            // rate schedule!
            bool icbCreated = false;
            int id_pl = -1;
            string icbPiName = "";
            string icbPtName = "";
						foreach(XmlNode rsched in icb.SelectNodes("rateschedules/rateschedule"))
            {
              string rschedName = rsched.Attributes["name"].Value;
              string rschedDesc = MTXmlDocument.GetNodeValueAsString(rsched, "property[@name='Description']");
              DateTime endDate = MTXmlDocument.GetNodeValueAsDateTime(rsched, "pctimespan/property[@name='EndDate']");
              int endDateType = MTXmlDocument.GetNodeValueAsInt(rsched, "pctimespan/property[@name='EndDateType']");
              int endOffset = MTXmlDocument.GetNodeValueAsInt(rsched, "pctimespan/property[@name='EndOffset']");
              DateTime startDate = MTXmlDocument.GetNodeValueAsDateTime(rsched, "pctimespan/property[@name='StartDate']");
              int startDateType = MTXmlDocument.GetNodeValueAsInt(rsched, "pctimespan/property[@name='StartDateType']");
              int startOffset = MTXmlDocument.GetNodeValueAsInt(rsched, "pctimespan/property[@name='StartOffset']");
              string piName = MTXmlDocument.GetNodeValueAsString(rsched, "priceableitemname");
              string ptName = MTXmlDocument.GetNodeValueAsString(rsched, "parametertablename");
              if (icbCreated)
              {
                if(icbPiName != piName)
                {
                  throw new ApplicationException("Multiple rate schedules on an ICB pricelist must have the same PI");
                }
                if(icbPtName != ptName)
                {
                  throw new ApplicationException("Multiple rate schedules on an ICB pricelist must have the same paramtable");
                }
              }
              else
              {
                // Save these names so we can check subsequent rate schedules (if any).
                icbPiName = piName;
                icbPtName = ptName;
                // Save the pricelist for subsequent rate schedules (if any).
                id_pl = mICB.Add(id_sub, poName, piName, ptName, accountName, accountSpace);
                icbCreated = true;
              }
              int id_rsched = mRateSchedule.Add(rschedName, rschedDesc, id_pl, 
                                                startDateType, startDate, startOffset, 
                                                endDateType, endDate, endOffset,
                                                piName, ptName);

              // For the moment, skip processing param table data since we don't have all of Premiere's data yet.
              ParameterTableWriter ptWriter = GetParameterTableWriter(ptName);
              string rates = MTXmlDocument.GetNodeValueAsString(rsched, "ruleset");
              rates = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" + rates;
              ptWriter.Add(id_rsched, now, maxTime, 1, rates);
            }
					}
				}
			}
			finally
			{
				// Always commit work in progress against bcp.
				Commit();
			}
		}

    public IndividualSubscriptionLoader()
    {
      mLog = new MetraTech.Logger("logging", "[IndividualSubscriptionLoader]");
      mAllWriters = new System.Collections.ArrayList();
      mParamTables = new System.Collections.Hashtable();
      mPC = new MetraTech.Interop.MTProductCatalog.MTProductCatalogClass();
      mDescription = new DescriptionWriter();
      mAllWriters.Add(mDescription);
      mBaseProps = new BasePropsWriter(mDescription);
      mAllWriters.Add(mBaseProps);
      mEffectiveDate = new EffectiveDateWriter(mBaseProps);
      mAllWriters.Add(mEffectiveDate);
      mRateSchedule = new RateScheduleWriter(mBaseProps, mEffectiveDate);
      mAllWriters.Add(mRateSchedule);
      mICB = new ICBPricelistWriter(mBaseProps);
      mAllWriters.Add(mICB);
      mIndividualSubscription = new IndividualSubscriptionWriter();
      mAllWriters.Add(mIndividualSubscription);
    }
  }

  [ComVisible(false)]
  public class GroupSubscriptionLoader : IBulkLoadWriter
  {
    private ILogger mLog;
    private DescriptionWriter mDescription;
    private BasePropsWriter mBaseProps;
    private EffectiveDateWriter mEffectiveDate;
    private RateScheduleWriter mRateSchedule;
    private ICBPricelistWriter mICB;
    private GroupSubscriptionWriter mGroupSubscription;
    private System.Collections.Hashtable mParamTables;
    private System.Collections.ArrayList mAllWriters;

    private MetraTech.Interop.MTProductCatalog.IMTProductCatalog mPC;

    public ParameterTableWriter GetParameterTableWriter(string ptName)
    {
      if(!mParamTables.Contains(ptName))
      {
        MetraTech.Interop.MTProductCatalog.IMTParamTableDefinition pt = mPC.GetParamTableDefinitionByName(ptName);
        if(null == pt)
        {
          throw new ApplicationException("Cannot find parameter table definition in product catalog.  Name = " + ptName);
        }
        ParameterTableWriter ptw = new ParameterTableWriter(pt);
        mParamTables.Add(ptName, ptw);
        mAllWriters.Add(ptw);
      }
      return (ParameterTableWriter) mParamTables[ptName];
    }

    public void Dispose()
    {
      foreach(IBulkLoadWriter blw in mAllWriters)
      {
        blw.Dispose();
      }
    }

    public void Commit()
    {
      foreach(IBulkLoadWriter blw in mAllWriters)
      {
        blw.Commit();
      }
    }

    public void Load(string [] filenames)
    {
      for(int i=0; i<filenames.Length; i++)
      {
        Load(filenames[i]);
      }
    }

		public void Load(string filename)
		{
			try
			{
				mLog.LogInfo("Loading from file " + filename);
				DateTime now = MetraTech.MetraTime.Now;
				DateTime maxTime = MetraTech.MetraTime.Max;
				// Don't worry about abstracting the file format yet.  
				// TODO: Use a builder pattern here...
				MTXmlDocument xml = new MTXmlDocument();
				xml.Load(filename);
        
				// The main loop is over group subs,
				// then over icb rate schedules
				foreach(XmlNode gs in xml.SelectNodes("xmlconfig/groupsubscriptions/groupsubscription"))
				{
					string name = gs.Attributes["name"].Value;
					// Snarf the properties
					string corporateAccount = MTXmlDocument.GetNodeValueAsString(gs, "property[@name='CorporateAccount']");
					string description = MTXmlDocument.GetNodeValueAsString(gs, "property[@name='Description']");
					string distributionAccount = MTXmlDocument.GetNodeValueAsString(gs, "property[@name='DistributionAccount']");
					bool proportional = MTXmlDocument.GetNodeValueAsInt(gs, "property[@name='ProportionalDistribution']") != 0;
					bool supportGroupOps = MTXmlDocument.GetNodeValueAsInt(gs, "property[@name='supportgroupops']") != 0;
					string poName = MTXmlDocument.GetNodeValueAsString(gs, "productoffering");
					string distributionAccountName = MTXmlDocument.GetNodeValueAsString(gs, "distributionaccountusername");
					string distributionAccountSpace = MTXmlDocument.GetNodeValueAsString(gs, "distributionaccountnamespace");
					string corporateAccountName = MTXmlDocument.GetNodeValueAsString(gs, "corporation");
					string corporateAccountSpace = MTXmlDocument.GetNodeValueAsString(gs, "corporationnamespace");
					int id_usage_cycle = MTXmlDocument.GetNodeValueAsInt(gs, "pccycle/property[@name='CycleID']");
					int id_sub = mGroupSubscription.Add(name, description, poName, supportGroupOps, proportional,
						-1, corporateAccountSpace, corporateAccountName,
						-1, distributionAccountSpace, distributionAccountName,
						id_usage_cycle);
					foreach(XmlNode icb in gs.SelectNodes("icbs/icb"))
					{
						// I believe the currency is no longer needed; since the currency of the po is used.
						string currency = MTXmlDocument.GetNodeValueAsString(icb, "currency");
						// ICB can have multiple rate schedules per pricelist
						// The monstrous t_pl_map is at the heart of the goofiness in the following code.
						// It is so denormalized that the same data elements wind up in both the pricelist (and its
						// icb mappings) and the rate schedule itself.
            // These are the data necessary for creating the ICB; unfortunately stored in XML with the
            // rate schedule!
            bool icbCreated = false;
            int id_pl = -1;
            string icbPiName = "";
            string icbPtName = "";
						foreach(XmlNode rsched in icb.SelectNodes("rateschedules/rateschedule"))
            {
              string rschedName = rsched.Attributes["name"].Value;
              string rschedDesc = MTXmlDocument.GetNodeValueAsString(rsched, "property[@name='Description']");
              DateTime endDate = MTXmlDocument.GetNodeValueAsDateTime(rsched, "pctimespan/property[@name='EndDate']");
              int endDateType = MTXmlDocument.GetNodeValueAsInt(rsched, "pctimespan/property[@name='EndDateType']");
              int endOffset = MTXmlDocument.GetNodeValueAsInt(rsched, "pctimespan/property[@name='EndOffset']");
              DateTime startDate = MTXmlDocument.GetNodeValueAsDateTime(rsched, "pctimespan/property[@name='StartDate']");
              int startDateType = MTXmlDocument.GetNodeValueAsInt(rsched, "pctimespan/property[@name='StartDateType']");
              int startOffset = MTXmlDocument.GetNodeValueAsInt(rsched, "pctimespan/property[@name='StartOffset']");
              string piName = MTXmlDocument.GetNodeValueAsString(rsched, "priceableitemname");
              string ptName = MTXmlDocument.GetNodeValueAsString(rsched, "parametertablename");
              if (icbCreated)
              {
                if(icbPiName != piName)
                {
                  throw new ApplicationException("Multiple rate schedules on an ICB pricelist must have the same PI");
                }
                if(icbPtName != ptName)
                {
                  throw new ApplicationException("Multiple rate schedules on an ICB pricelist must have the same paramtable");
                }
              }
              else
              {
                // Save these names so we can check subsequent rate schedules (if any).
                icbPiName = piName;
                icbPtName = ptName;
                // Save the pricelist for subsequent rate schedules (if any).
                id_pl = mICB.Add(id_sub, poName, piName, ptName, corporateAccountName, corporateAccountSpace);
                icbCreated = true;
              }
              int id_rsched = mRateSchedule.Add(rschedName, rschedDesc, id_pl, 
                                                startDateType, startDate, startOffset, 
                                                endDateType, endDate, endOffset,
                                                piName, ptName);

              // For the moment, skip processing param table data since we don't have all of Premiere's data yet.
              ParameterTableWriter ptWriter = GetParameterTableWriter(ptName);
              string rates = MTXmlDocument.GetNodeValueAsString(rsched, "ruleset");
              rates = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" + rates;
              ptWriter.Add(id_rsched, now, maxTime, 1, rates);
            }
					}
				}
			}
			finally
			{
				// Always commit work in progress against bcp.
				Commit();
			}
		}

    public GroupSubscriptionLoader()
    {
      mLog = new MetraTech.Logger("logging", "[GroupSubscriptionLoader]");
      mAllWriters = new System.Collections.ArrayList();
      mParamTables = new System.Collections.Hashtable();
      mPC = new MetraTech.Interop.MTProductCatalog.MTProductCatalogClass();
      mDescription = new DescriptionWriter();
      mAllWriters.Add(mDescription);
      mBaseProps = new BasePropsWriter(mDescription);
      mAllWriters.Add(mBaseProps);
      mEffectiveDate = new EffectiveDateWriter(mBaseProps);
      mAllWriters.Add(mEffectiveDate);
      mRateSchedule = new RateScheduleWriter(mBaseProps, mEffectiveDate);
      mAllWriters.Add(mRateSchedule);
      mICB = new ICBPricelistWriter(mBaseProps);
      mAllWriters.Add(mICB);
      mGroupSubscription = new GroupSubscriptionWriter();
      mAllWriters.Add(mGroupSubscription);
    }
  }
}
