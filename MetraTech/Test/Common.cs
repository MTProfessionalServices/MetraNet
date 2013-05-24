using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Collections;
using System.Diagnostics;
using NUnit.Framework;
using PC=MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop;
using RS = MetraTech.Interop.Rowset;
using MetraTech.DataAccess;
using YAAC = MetraTech.Interop.MTYAAC;
using ServerAccess = MetraTech.Interop.MTServerAccess;
using Coll = MetraTech.Interop.GenericCollection;
using MetraTech.Interop.COMMeter;
using PipelineTransaction = MetraTech.Interop.PipelineTransaction;
using Account = MetraTech.Accounts.Type;
using MetraTech.Security;



namespace MetraTech.Test.Common
{

	public class SubscriberAccountIds
	{
		private static Hashtable mAccIDs;

		static SubscriberAccountIds()
		{
			mAccIDs = new Hashtable();
		}
		public int this [string loginname]   // Indexer declaration
		{
			get
			{
				if(mAccIDs.ContainsKey(loginname.ToUpper()) == false)
				{
					IMTSessionContext ctx = Utils.LoginAsSU();
					YAAC.IMTAccountCatalog cat = new YAAC.MTAccountCatalogClass();
					cat.Init((MetraTech.Interop.MTYAAC.IMTSessionContext)ctx);
					YAAC.IMTYAAC acc = cat.GetAccountByName(loginname, "mt", MetraTime.Now);
					mAccIDs.Add(loginname.ToUpper(), acc.AccountID);
				}
				return (int)mAccIDs[loginname.ToUpper()];
			}
		}
	

	}

	public class SystemUserAccountIds
	{
		private static Hashtable mAccIDs;

		static SystemUserAccountIds()
		{
			mAccIDs = new Hashtable();
		}
		public int this [string loginname]   // Indexer declaration
		{
			get
			{
				if(mAccIDs.ContainsKey(loginname.ToUpper()) == false)
				{
					IMTSessionContext ctx = Utils.LoginAsSU();
					YAAC.IMTAccountCatalog cat = new YAAC.MTAccountCatalogClass();
					cat.Init((MetraTech.Interop.MTYAAC.IMTSessionContext)ctx);
					YAAC.IMTYAAC acc = cat.GetAccountByName(loginname, "system_user", MetraTime.Now);
					mAccIDs.Add(loginname.ToUpper(), acc.AccountID);
				}
				return (int)mAccIDs[loginname.ToUpper()];
			}
		}
	

	}


	public class Utils
	{
		public static SubscriberAccountIds mSubAccIDs;
		public static SystemUserAccountIds mSystemUserAccIDs;
		public static string mTestId = "";
		public static bool bTrace = false;


		private static IMTSessionContext mSUCtx = null;
		private static PC.MTProductCatalog mPC;
		private static YAAC.IMTAccountCatalog mAccCatalog;
		private static bool bFirstTraceRequest = true;
		
		static Utils()
		{
			mPC = new PC.MTProductCatalogClass();
			mAccCatalog = new YAAC.MTAccountCatalog();
			mSUCtx = Utils.LoginAsSU();
			mAccCatalog.Init((YAAC.IMTSessionContext)mSUCtx);
		}
		
		public static void TurnTraceOn()
		{
			bTrace = true;
		}

		public static void TurnTraceOff()
		{
			bTrace = false;
		}

		public static int GetSubscriberAccountID(string login)
		{
			if(mSubAccIDs == null)
				mSubAccIDs = new SubscriberAccountIds();
			return mSubAccIDs[login];
		}

		
		public static int GetSystemUserAccountID(string login)
		{
			if(mSystemUserAccIDs == null)
				mSystemUserAccIDs = new SystemUserAccountIds();
			return mSystemUserAccIDs[login];
		}

		public static void Trace(string message)
		{
			if(bTrace)
				TestLibrary.Trace(message);
			else if (bFirstTraceRequest)
			{
				TestLibrary.Trace("Trace turned off, will not be tracing. Call TurnTraceOn() if tracing required");
				bFirstTraceRequest = false;
			}
		}
		public static IMTSessionContext LoginAsSU()
		{
			// sets the SU session context on the client
			IMTLoginContext loginContext = new MTLoginContextClass();
			ServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
			sa.Initialize();
			ServerAccess.IMTServerAccessData accessData = sa.FindAndReturnObject("SuperUser");
			string suName = accessData.UserName;
			string suPassword = accessData.Password;
			return loginContext.Login(suName, "system_user", suPassword);
		}

		public static IMTSessionContext Login1(string name, string pw, string ns)
		{
			// sets the SU session context on the client
			IMTLoginContext loginContext = new MTLoginContextClass();
			return loginContext.Login(name, ns, pw);
		}

		private static string mSUUSerName = string.Empty;
		private static string mSUPassword = string.Empty;

		public static string SUName
		{
			get
			{
				if(mSUUSerName == string.Empty)
				{
					ServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
					sa.Initialize();
					ServerAccess.IMTServerAccessData accessData = sa.FindAndReturnObject("SuperUser");
					mSUUSerName = accessData.UserName;
					mSUPassword = accessData.Password;
				}
				return mSUUSerName;
			}
		}
		public static string SUPassword
		{
			get
			{
				if(mSUPassword == string.Empty)
				{
					ServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
					sa.Initialize();
					ServerAccess.IMTServerAccessData accessData = sa.FindAndReturnObject("SuperUser");
					mSUUSerName = accessData.UserName;
					mSUPassword = accessData.Password;
				}
				return mSUPassword;

			}
		}

		public static string SUNamespace
		{
			get
			{
				return "system_user";
			}
		}

    public static int GetAccountID(string userName)
    {
      IMTSessionContext ctx = Utils.LoginAsSU();
      YAAC.IMTAccountCatalog cat = new YAAC.MTAccountCatalogClass();
      cat.Init((MetraTech.Interop.MTYAAC.IMTSessionContext)ctx);
      YAAC.IMTYAAC acc = cat.GetAccountByName(userName, "mt", MetraTime.Now);
      return acc.AccountID;
    }

		public static string GetTestId()
		{
			if(mTestId.Equals(""))
			{
				try
				{
					PropertyBag config = new PropertyBag();
					config.Initialize("SmokeTest");
					mTestId = config["TestID"].ToString();
				}
				catch(Exception)
				{ 
					//not running in test harness
				}
				DateTime now = DateTime.Now;
				//mTestId = string.Format("{0}_{1}_{2}_{3}_{4}_{5}_{6}", 
				//	now.Year, now.Month, now.Day, now.Hour, now.Minute, now.Second, now.Millisecond);
				mTestId = mTestId + "_" + string.Format("{0}_{1}", now.Second, now.Millisecond);
				
			}
			return mTestId;
		}

		public static IMTSessionContext Login(string name, string ns, string password)
		{
			// sets the SU session context on the client
			IMTLoginContext loginContext = new MTLoginContextClass();
			return loginContext.Login(name + GetTestId(), ns, password);
		}

		public static void DumpErrorRowset(YAAC.IMTSQLRowset rowset)
		{
			bool atleastone = false;
			while(System.Convert.ToBoolean(rowset.EOF) == false)
			{
				atleastone = true;
				int acc  = (int)rowset.get_Value("id_acc");
				string accname  = (string)rowset.get_Value("accountname");
				string description  = (string)rowset.get_Value("description");
				string msg = string.Format("Error Rowset Row: id_acc: {0}, Name: {1}, Description: {2}", 
					acc, accname, description); 

				Utils.Trace(msg);

				rowset.MoveNext();
			}
			if(atleastone)
				rowset.MoveFirst();
		}

    public enum CycleType { MONTHLY = 1, DAILY = 3, WEEKLY = 4, ANNUAL = 8 };

    public class BillingCycle
    {
      public CycleType CycleTypeID;
      public int Day;
      public BillingCycle(CycleType cycleTypeID, int day)
      {
        this.CycleTypeID = cycleTypeID;
        this.Day = day;
      }

      public void GetPCInterval(System.DateTime timePoint, 
                                out int interval, 
                                out System.DateTime intervalStart,
                                out System.DateTime intervalEnd)
      {
        string formatString = "SELECT ui.id_interval, ui.dt_start, ui.dt_end \n" +
        "FROM t_pc_interval ui " +
        "INNER JOIN t_usage_cycle uc ON ui.id_cycle=uc.id_usage_cycle " +
        "WHERE ? BETWEEN ui.dt_start AND ui.dt_end AND {0}";

        string cycleClause="";
        switch(this.CycleTypeID)
        {
        case CycleType.MONTHLY:
          cycleClause = String.Format("uc.id_cycle_type=1 AND uc.day_of_month={0}", this.Day);
          break;
        case CycleType.DAILY:
          cycleClause = String.Format("uc.id_cycle_type=3");
          break;
        case CycleType.WEEKLY:
          cycleClause = String.Format("uc.id_cycle_type=4 AND uc.day_of_week={0}", this.Day);
          break;
        case CycleType.ANNUAL:
          cycleClause = String.Format("uc.id_cycle_type=8 AND uc.start_day={0} AND uc.start_month=1", 
                                      this.Day);
          break;
        }
        using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
        {
            using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(String.Format(formatString, cycleClause)))
            {
                stmt.AddParam(MTParameterType.DateTime, timePoint);
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    reader.Read();
                    interval = reader.GetInt32("id_interval");
                    intervalStart = reader.GetDateTime("dt_start");
                    intervalEnd = reader.GetDateTime("dt_end");
                }
            }
        }
      }

      virtual public void Set(PC.IMTPCCycle cycle)
      {
        cycle.Mode = PC.MTCycleMode.CYCLE_MODE_FIXED;
        cycle.CycleTypeID = (int) this.CycleTypeID;
        switch(this.CycleTypeID)
        {
        case CycleType.MONTHLY:
          cycle.EndDayOfMonth = this.Day;
          break;
        case CycleType.DAILY:
          // Daily, no need for day
          break;
        case CycleType.WEEKLY:
          cycle.EndDayOfWeek = this.Day;
          break;
        case CycleType.ANNUAL:
          cycle.StartMonth = 1;
          cycle.StartDay = this.Day;
          break;
        }
      }
      public void Set(ISession session)
      {
        switch(this.CycleTypeID)
        {
        case CycleType.MONTHLY:
          session.InitProperty("usagecycletype", (int) this.CycleTypeID);
          session.InitProperty("dayofmonth", this.Day);
          break;
        case CycleType.DAILY:
          session.InitProperty("usagecycletype", (int) this.CycleTypeID);
          // Daily, no need for day
          break;
        case CycleType.WEEKLY:
          session.InitProperty("usagecycletype", (int) this.CycleTypeID);
          session.InitProperty("dayofweek", this.Day);
          break;
        case CycleType.ANNUAL:
          session.InitProperty("usagecycletype", (int) this.CycleTypeID);
          session.InitProperty("startmonth", 1);
          session.InitProperty("startday", this.Day);
          break;
        }
      }
      override public string ToString()
      {
        switch(this.CycleTypeID)
        {
        case CycleType.MONTHLY:
          return String.Format("{0}_{1}", "M", Day);
        case CycleType.DAILY:
          return String.Format("{0}", "D");
        case CycleType.WEEKLY:
          return String.Format("{0}_{1}", "W", Day);
        case CycleType.ANNUAL:
          return String.Format("{0}_1_{1}", "A", Day);
        default:
          throw new ApplicationException("Unknown CycleType value");
        }
      }
        
    }

    public class CycleOption : BillingCycle
    {
      public string Description;
      public PC.MTCycleMode Mode;

      public CycleOption(PC.MTCycleMode mode, CycleType cycleTypeID, int day)
      :
      base(cycleTypeID, day)
      {
        this.Mode = mode;
        switch(mode)
        {
        case PC.MTCycleMode.CYCLE_MODE_FIXED:
          Description = string.Format("FIXED_{0}", this.CycleTypeID);
          break;
        case PC.MTCycleMode.CYCLE_MODE_BCR:
          Description = "BCRU";
          break;
        case PC.MTCycleMode.CYCLE_MODE_BCR_CONSTRAINED:
          Description = string.Format("BCRC_{0}", this.CycleTypeID);
          break;
        case PC.MTCycleMode.CYCLE_MODE_EBCR:
          Description = string.Format("EBCR_{0}", this.CycleTypeID);
          break;
        }
      }

      override public void Set(PC.IMTPCCycle cycle)
      {
        cycle.Mode = this.Mode;
        cycle.CycleTypeID = this.Mode == PC.MTCycleMode.CYCLE_MODE_BCR ? 0 : (int) this.CycleTypeID;
        switch(this.CycleTypeID)
        {
        case CycleType.MONTHLY:
          cycle.EndDayOfMonth = this.Day;
          break;
        case CycleType.DAILY:
          // Daily, no need for day
          break;
        case CycleType.WEEKLY:
          cycle.EndDayOfWeek = this.Day;
          break;
        case CycleType.ANNUAL:
          cycle.StartMonth = 1;
          cycle.StartDay = this.Day;
          break;
        }
      }
    }

    public class AccountParameters
    {
      public string UserName;
      public BillingCycle Cycle;
      public string Pricelist;
      public AccountParameters(string userName, BillingCycle cycle)
      {
        this.UserName = userName;
        this.Cycle = cycle;
        this.Pricelist = "";
      }
      public AccountParameters(string userName, BillingCycle cycle, string pricelist)
      {
        this.UserName = userName;
        this.Cycle = cycle;
        this.Pricelist = pricelist;
      }
    }

    public static void GenerateSharedPricelist(string name)
    {
      PC.IMTPriceList pl = mPC.CreatePriceList();
      pl.Name = name;;
      pl.Description = pl.Name;
      pl.CurrencyCode = "USD";
      pl.Type = PC.MTPriceListType.PRICELIST_TYPE_REGULAR;
      pl.Save();

      // Add song downloads and song session rates.
      // Configure rates onto non-shared pricelist
      PC.IMTPriceableItem piTemplate = mPC.GetPriceableItemByName("Song Downloads");
      int idPriceList = pl.ID;
      PC.IMTParamTableDefinition pt = 
      mPC.GetParamTableDefinitionByName("metratech.com/songdownloads");
      PC.IMTRateSchedule sched = pt.CreateRateSchedule(idPriceList, piTemplate.ID);
      sched.ParameterTableID = pt.ID;
      sched.Description = "Unit test rates";
      sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");
      sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}", 
                                       Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), 
                                       "songdownloads1.xml"));
      sched.SaveWithRules();

      piTemplate = mPC.GetPriceableItemByName("Song Session");
      pt = mPC.GetParamTableDefinitionByName("metratech.com/songsession");
      sched = pt.CreateRateSchedule(idPriceList, piTemplate.ID);
      sched.ParameterTableID = pt.ID;
      sched.Description = "Unit test rates";
      sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");
      sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}", 
                                       Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), 
                                       "songsession1.xml"));
      sched.SaveWithRules();

      pt = mPC.GetParamTableDefinitionByName("metratech.com/songsessionchild");
      sched = pt.CreateRateSchedule(idPriceList, ((PC.IMTPriceableItem)piTemplate.GetChildren()[1]).ID);
      sched.ParameterTableID = pt.ID;
      sched.Description = "Unit test rates";
      sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");
      sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}", 
                                       Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), 
                                       "songsessionchild1.xml"));
      sched.SaveWithRules();

      PC.IMTPriceableItem usagePiTemplate = mPC.GetPriceableItemByName("Test Usage Charge");

      pt = mPC.GetParamTableDefinitionByName("metratech.com/rateconn");
      sched = pt.CreateRateSchedule(idPriceList, usagePiTemplate.ID);
      sched.ParameterTableID = pt.ID;
      sched.Description = "Unit test rates";
      sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");
      sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}", 
                                       Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), 
                                       "rules1.xml"));
      sched.SaveWithRules();

      pt = mPC.GetParamTableDefinitionByName("metratech.com/decimalcalc");
      sched = pt.CreateRateSchedule(idPriceList, usagePiTemplate.ID);
      sched.ParameterTableID = pt.ID;
      sched.Description = "Unit test rates";
      sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");
      sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}", 
                                       Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), 
                                       "decrules1.xml"));
      sched.SaveWithRules();

      pt = mPC.GetParamTableDefinitionByName("metratech.com/test");
      sched = pt.CreateRateSchedule(idPriceList, usagePiTemplate.ID);
      sched.ParameterTableID = pt.ID;
      sched.Description = "Unit test rates";
      sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");
      sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}", 
                                       Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), 
                                       "testrules1.xml"));
      sched.SaveWithRules();

      PC.IMTCalendar c = mPC.GetCalendarByName("AudioConf Setup Calendar");
      pt = mPC.GetParamTableDefinitionByName("metratech.com/calendar");
      sched = pt.CreateRateSchedule(idPriceList, usagePiTemplate.ID);
      sched.ParameterTableID = pt.ID;
      sched.Description = "Unit test rates";
      sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");
      MetraTech.Interop.MTRuleSet.IMTActionSet actionSet = new MetraTech.Interop.MTRuleSet.MTActionSetClass();
      MetraTech.Interop.MTRuleSet.MTAssignmentAction action = new MetraTech.Interop.MTRuleSet.MTAssignmentActionClass();
      action.PropertyName = "calendar_id";
      action.PropertyType = MetraTech.Interop.MTRuleSet.PropValType.PROP_TYPE_INTEGER;
      action.PropertyValue = c.ID;
      actionSet.Add(action);
      sched.RuleSet.DefaultActions = (PC.IMTActionSet) actionSet;
      sched.SaveWithRules();
    }

    public static void GenerateSongDownloadsProductOffering()
    {
      PC.IMTPriceableItem piTemplate = mPC.GetPriceableItemByName("Song Downloads");

      // make a product offering containing just this pi
      PC.IMTProductOffering po = mPC.CreateProductOffering();
      po.Name = string.Format("PO_{0}{1}", piTemplate.Name, Utils.GetTestId());
      po.DisplayName = po.Name;
      po.Description = po.Name;
      po.SelfSubscribable = true;
      po.SelfUnsubscribable = false;
      po.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      po.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      po.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_NULL;
      po.EffectiveDate.SetEndDateNull();
      po.SetCurrencyCode("USD");
      PC.IMTAggregateCharge aggInst = (PC.IMTAggregateCharge)po.AddPriceableItem((PC.MTPriceableItem) piTemplate);
      aggInst.Cycle.CycleTypeID = 1;
      aggInst.Cycle.EndDayOfMonth = 17;
      po.Save();
              
      // Configure rates onto non-shared pricelist
      int idPriceList = po.NonSharedPriceListID;
      PC.IMTParamTableDefinition pt = 
      mPC.GetParamTableDefinitionByName("metratech.com/songdownloads");
      PC.IMTRateSchedule sched = pt.CreateRateSchedule(idPriceList, piTemplate.ID);
      sched.ParameterTableID = pt.ID;
      sched.Description = "Unit test rates";
      sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");
      sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}", 
                                       Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), 
                                       "songdownloads1.xml"));
      sched.SaveWithRules();

      // Save PO with availability now that rates are configured.
      po.AvailabilityDate.StartDate = DateTime.Parse("1/1/2000");
      po.AvailabilityDate.SetEndDateNull();
      po.Save();
    }

    public static void GenerateSongDownloadsBCRProductOffering()
    {
      PC.IMTPriceableItem piTemplate = mPC.GetPriceableItemByName("Song Downloads");

      // make a product offering containing just this pi
      PC.IMTProductOffering po = mPC.CreateProductOffering();
      po.Name = string.Format("PO_BCR_{0}{1}", piTemplate.Name, Utils.GetTestId());
      po.DisplayName = po.Name;
      po.Description = po.Name;
      po.SelfSubscribable = true;
      po.SelfUnsubscribable = false;
      po.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      po.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      po.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_NULL;
      po.EffectiveDate.SetEndDateNull();
      po.SetCurrencyCode("USD");
      PC.IMTAggregateCharge aggInst = (PC.IMTAggregateCharge)po.AddPriceableItem((PC.MTPriceableItem) piTemplate);
      aggInst.Cycle.CycleTypeID = 1;
      aggInst.Cycle.Mode = PC.MTCycleMode.CYCLE_MODE_BCR;
      po.Save();
              
      // Configure rates onto non-shared pricelist
      int idPriceList = po.NonSharedPriceListID;
      PC.IMTParamTableDefinition pt = 
      mPC.GetParamTableDefinitionByName("metratech.com/songdownloads");
      PC.IMTRateSchedule sched = pt.CreateRateSchedule(idPriceList, piTemplate.ID);
      sched.ParameterTableID = pt.ID;
      sched.Description = "Unit test rates";
      sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");
      sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}", 
                                       Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), 
                                       "songdownloads1.xml"));
      sched.SaveWithRules();

      // Save PO with availability now that rates are configured.
      po.AvailabilityDate.StartDate = DateTime.Parse("1/1/2000");
      po.AvailabilityDate.SetEndDateNull();
      po.Save();
    }

    public static void GenerateSongSessionProductOffering()
    {
      PC.IMTPriceableItem piTemplate = mPC.GetPriceableItemByName("Song Session");
      
      // make a product offering containing just this pi
      PC.IMTProductOffering po = mPC.CreateProductOffering();
      po.Name = string.Format("PO_{0}{1}", piTemplate.Name, Utils.GetTestId());
      po.DisplayName = po.Name;
      po.Description = po.Name;
      po.SelfSubscribable = true;
      po.SelfUnsubscribable = false;
      po.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      po.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      po.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_NULL;
      po.EffectiveDate.SetEndDateNull();
      po.SetCurrencyCode("USD");
      po.AddPriceableItem((PC.MTPriceableItem) piTemplate);
      po.Save();
              
      // Configure rates onto non-shared pricelist
      int idPriceList = po.NonSharedPriceListID;
      PC.IMTParamTableDefinition pt = 
      mPC.GetParamTableDefinitionByName("metratech.com/songsession");
      PC.IMTRateSchedule sched = pt.CreateRateSchedule(idPriceList, piTemplate.ID);
      sched.ParameterTableID = pt.ID;
      sched.Description = "Unit test rates";
      sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");
      sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}", 
                                       Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), 
                                       "songsession1.xml"));
      sched.SaveWithRules();

      pt = mPC.GetParamTableDefinitionByName("metratech.com/songsessionchild");
      sched = pt.CreateRateSchedule(idPriceList, ((PC.IMTPriceableItem)piTemplate.GetChildren()[1]).ID);
      sched.ParameterTableID = pt.ID;
      sched.Description = "Unit test rates";
      sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");
      sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}", 
                                       Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), 
                                       "songsessionchild1.xml"));
      sched.SaveWithRules();

      // Save PO with availability now that rates are configured.
      po.AvailabilityDate.StartDate = DateTime.Parse("1/1/2000");
      po.AvailabilityDate.SetEndDateNull();
      po.Save();
    }

    static PC.IMTCounterPropertyDefinition GetCPDByName(PC.IMTPriceableItemType piType, string name)
    {
      PC.IMTCollection c = piType.GetCounterPropertyDefinitions();
      foreach(PC.IMTCounterPropertyDefinition cpd in c)
      {
        if (cpd.Name == name) return cpd;
      }
      return null;
    }

    public static void GenerateMonthlyFixedPercentDiscountProductOffering()
    {

      PC.IMTPriceableItemType piType = mPC.GetPriceableItemTypeByName("Percent Discount");
      PC.IMTPriceableItem piTemplate = piType.CreateTemplate(true);
      piTemplate.Name = string.Format("Percent_Discount{0}", Utils.GetTestId());
      piTemplate.DisplayName = piTemplate.Name;
      piTemplate.Description = piTemplate.Name;
      ((PC.IMTDiscount)piTemplate).Cycle.CycleTypeID = 1;
      ((PC.IMTDiscount)piTemplate).Cycle.EndDayOfMonth = 17;
      // Counter 1
      PC.IMTCounterType counterType = mPC.GetCounterTypeByName("SumOfOneProperty");
      PC.IMTCounter counter = counterType.CreateCounter();
      counter.Name = "TestPIUsageQualifier";
      counter.Description = counter.Name;
      counter.GetParameter("A").Value = "metratech.com/testpi/amount";
      ((PC.IMTDiscount)piTemplate).SetCounter(GetCPDByName(piType, "Qualifier").ID, counter);
      ((PC.IMTDiscount)piTemplate).SetDistributionCounter(counter);
      // Counter 2
      counter = counterType.CreateCounter();
      counter.Name = "TestPIUsageTarget";
      counter.Description = counter.Name;
      counter.GetParameter("A").Value = "metratech.com/testpi/amount";
      ((PC.IMTDiscount)piTemplate).SetCounter(GetCPDByName(piType, "Target").ID, counter);
       
      piTemplate.Save();

//       PC.IMTPriceableItem usagePiTemplate = mPC.GetPriceableItemByName("Test Usage Charge");

      // make a product offering containing this pi and testpi
      PC.IMTProductOffering po = mPC.CreateProductOffering();
      po.Name = string.Format("PO_{0}", piTemplate.Name);
      po.DisplayName = po.Name;
      po.Description = po.Name;
      po.SelfSubscribable = true;
      po.SelfUnsubscribable = false;
      po.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      po.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      po.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_NULL;
      po.EffectiveDate.SetEndDateNull();
      po.SetCurrencyCode("USD");
      PC.IMTDiscount discInst = (PC.IMTDiscount)po.AddPriceableItem((PC.MTPriceableItem) piTemplate);
      discInst.Cycle.CycleTypeID = 1;
      discInst.Cycle.EndDayOfMonth = 17;
//       po.AddPriceableItem((PC.MTPriceableItem) usagePiTemplate);
      po.Save();
              
      // Configure rates onto non-shared pricelist
      int idPriceList = po.NonSharedPriceListID;
      PC.IMTParamTableDefinition pt = 
      mPC.GetParamTableDefinitionByName("metratech.com/percentdiscount");
      PC.IMTRateSchedule sched = pt.CreateRateSchedule(idPriceList, piTemplate.ID);
      sched.ParameterTableID = pt.ID;
      sched.Description = "Unit test rates";
      sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");
      sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}", 
                                       Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), 
                                       "percentdiscrules1.xml"));
      sched.SaveWithRules();

//       pt = mPC.GetParamTableDefinitionByName("metratech.com/rateconn");
//       sched = pt.CreateRateSchedule(idPriceList, usagePiTemplate.ID);
//       sched.ParameterTableID = pt.ID;
//       sched.Description = "Unit test rates";
//       sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
//       sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
//       sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
//       sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");
//       sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}", 
//                                        Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), 
//                                        "rules1.xml"));
//       sched.SaveWithRules();

//       pt = mPC.GetParamTableDefinitionByName("metratech.com/decimalcalc");
//       sched = pt.CreateRateSchedule(idPriceList, usagePiTemplate.ID);
//       sched.ParameterTableID = pt.ID;
//       sched.Description = "Unit test rates";
//       sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
//       sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
//       sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
//       sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");
//       sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}", 
//                                        Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), 
//                                        "decrules1.xml"));
//       sched.SaveWithRules();

//       pt = mPC.GetParamTableDefinitionByName("metratech.com/test");
//       sched = pt.CreateRateSchedule(idPriceList, usagePiTemplate.ID);
//       sched.ParameterTableID = pt.ID;
//       sched.Description = "Unit test rates";
//       sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
//       sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
//       sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
//       sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");
//       sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}", 
//                                        Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), 
//                                        "testrules1.xml"));
//       sched.SaveWithRules();

//       PC.IMTCalendar c = mPC.GetCalendarByName("AudioConf Setup Calendar");
//       pt = mPC.GetParamTableDefinitionByName("metratech.com/calendar");
//       sched = pt.CreateRateSchedule(idPriceList, usagePiTemplate.ID);
//       sched.ParameterTableID = pt.ID;
//       sched.Description = "Unit test rates";
//       sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
//       sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
//       sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
//       sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");
//       MetraTech.Interop.MTRuleSet.IMTActionSet actionSet = new MetraTech.Interop.MTRuleSet.MTActionSetClass();
//       MetraTech.Interop.MTRuleSet.MTAssignmentAction action = new MetraTech.Interop.MTRuleSet.MTAssignmentActionClass();
//       action.PropertyName = "calendar_id";
//       action.PropertyType = MetraTech.Interop.MTRuleSet.PropValType.PROP_TYPE_INTEGER;
//       action.PropertyValue = c.ID;
//       actionSet.Add(action);
//       sched.RuleSet.DefaultActions = (PC.IMTActionSet) actionSet;
//       sched.SaveWithRules();

      // Save PO with availability now that rates are configured.
      po.AvailabilityDate.StartDate = DateTime.Parse("1/1/2000");
      po.AvailabilityDate.SetEndDateNull();
      po.Save();
    }

    public static void GenerateMonthlyFixedPercentDiscountBCRProductOffering()
    {

      PC.IMTPriceableItemType piType = mPC.GetPriceableItemTypeByName("Percent Discount");
      PC.IMTPriceableItem piTemplate = piType.CreateTemplate(true);
      piTemplate.Name = string.Format("Percent_Discount_BCR{0}", Utils.GetTestId());
      piTemplate.DisplayName = piTemplate.Name;
      piTemplate.Description = piTemplate.Name;
      ((PC.IMTDiscount)piTemplate).Cycle.CycleTypeID = 1;
      ((PC.IMTDiscount)piTemplate).Cycle.EndDayOfMonth = 17;
      // Counter 1
      PC.IMTCounterType counterType = mPC.GetCounterTypeByName("SumOfOneProperty");
      PC.IMTCounter counter = counterType.CreateCounter();
      counter.Name = "TestPIUsageQualifier";
      counter.Description = counter.Name;
      counter.GetParameter("A").Value = "metratech.com/testpi/amount";
      ((PC.IMTDiscount)piTemplate).SetCounter(GetCPDByName(piType, "Qualifier").ID, counter);
      ((PC.IMTDiscount)piTemplate).SetDistributionCounter(counter);
      // Counter 2
      counter = counterType.CreateCounter();
      counter.Name = "TestPIUsageTarget";
      counter.Description = counter.Name;
      counter.GetParameter("A").Value = "metratech.com/testpi/amount";
      ((PC.IMTDiscount)piTemplate).SetCounter(GetCPDByName(piType, "Target").ID, counter);
       
      piTemplate.Save();

      // make a product offering containing this pi and testpi
      PC.IMTProductOffering po = mPC.CreateProductOffering();
      po.Name = string.Format("PO_{0}", piTemplate.Name);
      po.DisplayName = po.Name;
      po.Description = po.Name;
      po.SelfSubscribable = true;
      po.SelfUnsubscribable = false;
      po.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      po.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      po.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_NULL;
      po.EffectiveDate.SetEndDateNull();
      po.SetCurrencyCode("USD");
      PC.IMTDiscount discInst = (PC.IMTDiscount)po.AddPriceableItem((PC.MTPriceableItem) piTemplate);
      discInst.Cycle.CycleTypeID = 1;
      discInst.Cycle.Mode = PC.MTCycleMode.CYCLE_MODE_BCR;
      po.Save();
              
      // Configure rates onto non-shared pricelist
      int idPriceList = po.NonSharedPriceListID;
      PC.IMTParamTableDefinition pt = 
      mPC.GetParamTableDefinitionByName("metratech.com/percentdiscount");
      PC.IMTRateSchedule sched = pt.CreateRateSchedule(idPriceList, piTemplate.ID);
      sched.ParameterTableID = pt.ID;
      sched.Description = "Unit test rates";
      sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");
      sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}", 
                                       Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), 
                                       "percentdiscrules1.xml"));
      sched.SaveWithRules();

      // Save PO with availability now that rates are configured.
      po.AvailabilityDate.StartDate = DateTime.Parse("1/1/2000");
      po.AvailabilityDate.SetEndDateNull();
      po.Save();
    }

    public static void GenerateMonthlyFixedSumOfTwoPercentDiscountProductOffering()
    {

      PC.IMTPriceableItemType piType = mPC.GetPriceableItemTypeByName("Percent Discount");
      PC.IMTPriceableItem piTemplate = piType.CreateTemplate(true);
      piTemplate.Name = string.Format("Percent_Discount_Sum_Of_Two{0}", Utils.GetTestId());
      piTemplate.DisplayName = piTemplate.Name;
      piTemplate.Description = piTemplate.Name;
      ((PC.IMTDiscount)piTemplate).Cycle.CycleTypeID = 1;
      ((PC.IMTDiscount)piTemplate).Cycle.EndDayOfMonth = 17;
      // Counter 1
      PC.IMTCounterType counterType = mPC.GetCounterTypeByName("SumOfTwoProperties");
      PC.IMTCounter counter = counterType.CreateCounter();
      counter.Name = "TestPIUsageQualifier";
      counter.Description = counter.Name;
      counter.GetParameter("A").Value = "metratech.com/testpi/amount";
      counter.GetParameter("B").Value = "metratech.com/testpi/SetupCharge";
      ((PC.IMTDiscount)piTemplate).SetCounter(GetCPDByName(piType, "Qualifier").ID, counter);
      ((PC.IMTDiscount)piTemplate).SetDistributionCounter(counter);
      // Counter 2
      counter = counterType.CreateCounter();
      counter.Name = "TestPIUsageTarget";
      counter.Description = counter.Name;
      counter.GetParameter("A").Value = "metratech.com/testpi/amount";
      counter.GetParameter("B").Value = "metratech.com/testpi/SetupCharge";
      ((PC.IMTDiscount)piTemplate).SetCounter(GetCPDByName(piType, "Target").ID, counter);
       
      piTemplate.Save();

      // make a product offering containing this pi and testpi
      PC.IMTProductOffering po = mPC.CreateProductOffering();
      po.Name = string.Format("PO_{0}", piTemplate.Name);
      po.DisplayName = po.Name;
      po.Description = po.Name;
      po.SelfSubscribable = true;
      po.SelfUnsubscribable = false;
      po.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      po.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      po.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_NULL;
      po.EffectiveDate.SetEndDateNull();
      po.SetCurrencyCode("USD");
      PC.IMTDiscount discInst = (PC.IMTDiscount)po.AddPriceableItem((PC.MTPriceableItem) piTemplate);
      discInst.Cycle.CycleTypeID = 1;
      discInst.Cycle.EndDayOfMonth = 17;
      po.Save();
              
      // Configure rates onto non-shared pricelist
      int idPriceList = po.NonSharedPriceListID;
      PC.IMTParamTableDefinition pt = 
      mPC.GetParamTableDefinitionByName("metratech.com/percentdiscount");
      PC.IMTRateSchedule sched = pt.CreateRateSchedule(idPriceList, piTemplate.ID);
      sched.ParameterTableID = pt.ID;
      sched.Description = "Unit test rates";
      sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");
      sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}", 
                                       Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), 
                                       "percentdiscrules1.xml"));
      sched.SaveWithRules();

      // Save PO with availability now that rates are configured.
      po.AvailabilityDate.StartDate = DateTime.Parse("1/1/2000");
      po.AvailabilityDate.SetEndDateNull();
      po.Save();
    }

    public static void GenerateMonthlyTwoPriceableItemPercentDiscountProductOfferingBCR()
    {

      PC.IMTPriceableItemType piType = mPC.GetPriceableItemTypeByName("Percent Discount");
      PC.IMTPriceableItem piTemplate = piType.CreateTemplate(true);
      piTemplate.Name = string.Format("Percent_Discount_Sum_Of_Two_PI_BCR{0}", Utils.GetTestId());
      piTemplate.DisplayName = piTemplate.Name;
      piTemplate.Description = piTemplate.Name;
      ((PC.IMTDiscount)piTemplate).Cycle.CycleTypeID = 1;
      ((PC.IMTDiscount)piTemplate).Cycle.EndDayOfMonth = 17;
      // Counter 1
      PC.IMTCounterType counterType = mPC.GetCounterTypeByName("SumOfTwoProperties");
      PC.IMTCounter counter = counterType.CreateCounter();
      counter.Name = "TestPIUsageQualifier";
      counter.Description = counter.Name;
      counter.GetParameter("A").Value = "metratech.com/testpi/units";
      counter.GetParameter("B").Value = "metratech.com/testservice/Units";
      ((PC.IMTDiscount)piTemplate).SetCounter(GetCPDByName(piType, "Qualifier").ID, counter);
      ((PC.IMTDiscount)piTemplate).SetDistributionCounter(counter);
      // Counter 2
      counter = counterType.CreateCounter();
      counter.Name = "TestPIUsageTarget";
      counter.Description = counter.Name;
      counter.GetParameter("A").Value = "metratech.com/testpi/units";
      counter.GetParameter("B").Value = "metratech.com/testservice/Units";
      ((PC.IMTDiscount)piTemplate).SetCounter(GetCPDByName(piType, "Target").ID, counter);
       
      piTemplate.Save();

      // make a product offering containing this pi and testpi
      PC.IMTProductOffering po = mPC.CreateProductOffering();
      po.Name = string.Format("PO_{0}", piTemplate.Name);
      po.DisplayName = po.Name;
      po.Description = po.Name;
      po.SelfSubscribable = true;
      po.SelfUnsubscribable = false;
      po.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      po.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      po.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_NULL;
      po.EffectiveDate.SetEndDateNull();
      po.SetCurrencyCode("USD");
      PC.IMTDiscount discInst = (PC.IMTDiscount)po.AddPriceableItem((PC.MTPriceableItem) piTemplate);
      discInst.Cycle.CycleTypeID = 1;
      discInst.Cycle.Mode = PC.MTCycleMode.CYCLE_MODE_BCR;
      po.Save();
              
      // Configure rates onto non-shared pricelist
      int idPriceList = po.NonSharedPriceListID;
      PC.IMTParamTableDefinition pt = 
      mPC.GetParamTableDefinitionByName("metratech.com/percentdiscount");
      PC.IMTRateSchedule sched = pt.CreateRateSchedule(idPriceList, piTemplate.ID);
      sched.ParameterTableID = pt.ID;
      sched.Description = "Unit test rates";
      sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");
      sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}", 
                                       Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), 
                                       "percentdiscrules1.xml"));
      sched.SaveWithRules();

      // Save PO with availability now that rates are configured.
      po.AvailabilityDate.StartDate = DateTime.Parse("1/1/2000");
      po.AvailabilityDate.SetEndDateNull();
      po.Save();
    }

    public static void GenerateMonthlyFixedPercentDiscountProductOfferingIntegerQualifier()
    {
      PC.IMTPriceableItemType piType = mPC.GetPriceableItemTypeByName("Percent Discount");
      PC.IMTPriceableItem piTemplate = piType.CreateTemplate(true);
      piTemplate.Name = string.Format("Percent_Discount_Integer_Qualifier{0}", Utils.GetTestId());
      piTemplate.DisplayName = piTemplate.Name;
      piTemplate.Description = piTemplate.Name;
      ((PC.IMTDiscount)piTemplate).Cycle.CycleTypeID = 1;
      ((PC.IMTDiscount)piTemplate).Cycle.EndDayOfMonth = 17;
      // Counter 1
      PC.IMTCounterType counterType = mPC.GetCounterTypeByName("SumOfOneProperty");
      PC.IMTCounter counter = counterType.CreateCounter();
      counter.Name = "TestPIUsageQualifier";
      counter.Description = counter.Name;
      counter.GetParameter("A").Value = "metratech.com/testpi/duration";
      ((PC.IMTDiscount)piTemplate).SetCounter(GetCPDByName(piType, "Qualifier").ID, counter);
      ((PC.IMTDiscount)piTemplate).SetDistributionCounter(counter);
      // Counter 2
      counter = counterType.CreateCounter();
      counter.Name = "TestPIUsageTarget";
      counter.Description = counter.Name;
      counter.GetParameter("A").Value = "metratech.com/testpi/amount";
      ((PC.IMTDiscount)piTemplate).SetCounter(GetCPDByName(piType, "Target").ID, counter);
       
      piTemplate.Save();

      // make a product offering containing this pi and testpi
      PC.IMTProductOffering po = mPC.CreateProductOffering();
      po.Name = string.Format("PO_{0}", piTemplate.Name);
      po.DisplayName = po.Name;
      po.Description = po.Name;
      po.SelfSubscribable = true;
      po.SelfUnsubscribable = false;
      po.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      po.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      po.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_NULL;
      po.EffectiveDate.SetEndDateNull();
      po.SetCurrencyCode("USD");
      PC.IMTDiscount discInst = (PC.IMTDiscount)po.AddPriceableItem((PC.MTPriceableItem) piTemplate);
      discInst.Cycle.CycleTypeID = 1;
      discInst.Cycle.EndDayOfMonth = 17;
      po.Save();
              
      // Configure rates onto non-shared pricelist
      int idPriceList = po.NonSharedPriceListID;
      PC.IMTParamTableDefinition pt = 
      mPC.GetParamTableDefinitionByName("metratech.com/percentdiscount");
      PC.IMTRateSchedule sched = pt.CreateRateSchedule(idPriceList, piTemplate.ID);
      sched.ParameterTableID = pt.ID;
      sched.Description = "Unit test rates";
      sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");
      sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}", 
                                       Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), 
                                       "percentdiscrules1.xml"));
      sched.SaveWithRules();

      // Save PO with availability now that rates are configured.
      po.AvailabilityDate.StartDate = DateTime.Parse("1/1/2000");
      po.AvailabilityDate.SetEndDateNull();
      po.Save();
    }

    public static void GenerateMonthlyFixedPercentDiscountProductOfferingNoDistributionCounter()
    {

      PC.IMTPriceableItemType piType = mPC.GetPriceableItemTypeByName("Percent Discount");
      PC.IMTPriceableItem piTemplate = piType.CreateTemplate(true);
      piTemplate.Name = string.Format("Percent_Discount_No_Distribution_Counter{0}", Utils.GetTestId());
      piTemplate.DisplayName = piTemplate.Name;
      piTemplate.Description = piTemplate.Name;
      ((PC.IMTDiscount)piTemplate).Cycle.CycleTypeID = 1;
      ((PC.IMTDiscount)piTemplate).Cycle.EndDayOfMonth = 17;
      // Counter 1
      PC.IMTCounterType counterType = mPC.GetCounterTypeByName("SumOfOneProperty");
      PC.IMTCounter counter = counterType.CreateCounter();
      counter.Name = "TestPIUsageQualifier";
      counter.Description = counter.Name;
      counter.GetParameter("A").Value = "metratech.com/testpi/amount";
      ((PC.IMTDiscount)piTemplate).SetCounter(GetCPDByName(piType, "Qualifier").ID, counter);
      // Counter 2
      counter = counterType.CreateCounter();
      counter.Name = "TestPIUsageTarget";
      counter.Description = counter.Name;
      counter.GetParameter("A").Value = "metratech.com/testpi/amount";
      ((PC.IMTDiscount)piTemplate).SetCounter(GetCPDByName(piType, "Target").ID, counter);
       
      piTemplate.Save();

      // make a product offering containing this pi and testpi
      PC.IMTProductOffering po = mPC.CreateProductOffering();
      po.Name = string.Format("PO_{0}", piTemplate.Name);
      po.DisplayName = po.Name;
      po.Description = po.Name;
      po.SelfSubscribable = true;
      po.SelfUnsubscribable = false;
      po.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      po.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      po.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_NULL;
      po.EffectiveDate.SetEndDateNull();
      po.SetCurrencyCode("USD");
      PC.IMTDiscount discInst = (PC.IMTDiscount)po.AddPriceableItem((PC.MTPriceableItem) piTemplate);
      discInst.Cycle.CycleTypeID = 1;
      discInst.Cycle.EndDayOfMonth = 17;
      po.Save();
              
      // Configure rates onto non-shared pricelist
      int idPriceList = po.NonSharedPriceListID;
      PC.IMTParamTableDefinition pt = 
      mPC.GetParamTableDefinitionByName("metratech.com/percentdiscount");
      PC.IMTRateSchedule sched = pt.CreateRateSchedule(idPriceList, piTemplate.ID);
      sched.ParameterTableID = pt.ID;
      sched.Description = "Unit test rates";
      sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");
      sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}", 
                                       Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), 
                                       "percentdiscrules1.xml"));
      sched.SaveWithRules();

      // Save PO with availability now that rates are configured.
      po.AvailabilityDate.StartDate = DateTime.Parse("1/1/2000");
      po.AvailabilityDate.SetEndDateNull();
      po.Save();
    }

    public static void GenerateMonthlyFixedPercentUnconditionalDiscountProductOffering()
    {
      PC.IMTPriceableItemType piType = mPC.GetPriceableItemTypeByName("Percent Unconditional Discount");
      PC.IMTPriceableItem piTemplate = piType.CreateTemplate(true);
      piTemplate.Name = string.Format("Percent_Unconditional_Discount{0}", Utils.GetTestId());
      piTemplate.DisplayName = piTemplate.Name;
      piTemplate.Description = piTemplate.Name;
      ((PC.IMTDiscount)piTemplate).Cycle.CycleTypeID = 1;
      ((PC.IMTDiscount)piTemplate).Cycle.EndDayOfMonth = 17;
      // Counter 1
      PC.IMTCounterType counterType = mPC.GetCounterTypeByName("SumOfOneProperty");
      PC.IMTCounter counter = counterType.CreateCounter();
      counter.Name = "TestPIUsageTarget";
      counter.Description = counter.Name;
      counter.GetParameter("A").Value = "metratech.com/testpi/amount";
      ((PC.IMTDiscount)piTemplate).SetCounter(GetCPDByName(piType, "Target").ID, counter);
      ((PC.IMTDiscount)piTemplate).SetDistributionCounter(counter);

      piTemplate.Save();

      // make a product offering containing this pi and testpi
      PC.IMTProductOffering po = mPC.CreateProductOffering();
      po.Name = string.Format("PO_{0}", piTemplate.Name);
      po.DisplayName = po.Name;
      po.Description = po.Name;
      po.SelfSubscribable = true;
      po.SelfUnsubscribable = false;
      po.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      po.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      po.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_NULL;
      po.EffectiveDate.SetEndDateNull();
      po.SetCurrencyCode("USD");
      PC.IMTDiscount discInst = (PC.IMTDiscount)po.AddPriceableItem((PC.MTPriceableItem) piTemplate);
      discInst.Cycle.CycleTypeID = 1;
      discInst.Cycle.EndDayOfMonth = 17;
      po.Save();
              
      // Configure rates onto non-shared pricelist
      int idPriceList = po.NonSharedPriceListID;
      PC.IMTParamTableDefinition pt = 
      mPC.GetParamTableDefinitionByName("metratech.com/percentdiscount_nocond");
      PC.IMTRateSchedule sched = pt.CreateRateSchedule(idPriceList, piTemplate.ID);
      sched.ParameterTableID = pt.ID;
      sched.Description = "Unit test rates";
      sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");
      sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}", 
                                       Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), 
                                       "unconditionalpercentdiscrules.xml"));
      sched.SaveWithRules();


      // Save PO with availability now that rates are configured.
      po.AvailabilityDate.StartDate = DateTime.Parse("1/1/2000");
      po.AvailabilityDate.SetEndDateNull();
      po.Save();
    }

    public static void GenerateMonthlyFixedFlatDiscountProductOffering()
    {
      PC.IMTPriceableItemType piType = mPC.GetPriceableItemTypeByName("Flat Discount");
      PC.IMTPriceableItem piTemplate = piType.CreateTemplate(true);
      piTemplate.Name = string.Format("Flat_Discount{0}", Utils.GetTestId());
      piTemplate.DisplayName = piTemplate.Name;
      piTemplate.Description = piTemplate.Name;
      ((PC.IMTDiscount)piTemplate).Cycle.CycleTypeID = 1;
      ((PC.IMTDiscount)piTemplate).Cycle.EndDayOfMonth = 17;
      // Counter 1
      PC.IMTCounterType counterType = mPC.GetCounterTypeByName("SumOfOneProperty");
      PC.IMTCounter counter = counterType.CreateCounter();
      counter.Name = "TestPIUsageQualifier";
      counter.Description = counter.Name;
      counter.GetParameter("A").Value = "metratech.com/testpi/amount";
      ((PC.IMTDiscount)piTemplate).SetCounter(GetCPDByName(piType, "Qualifier").ID, counter);
      ((PC.IMTDiscount)piTemplate).SetDistributionCounter(counter);

      piTemplate.Save();

      // make a product offering containing this pi and testpi
      PC.IMTProductOffering po = mPC.CreateProductOffering();
      po.Name = string.Format("PO_{0}", piTemplate.Name);
      po.DisplayName = po.Name;
      po.Description = po.Name;
      po.SelfSubscribable = true;
      po.SelfUnsubscribable = false;
      po.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      po.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      po.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_NULL;
      po.EffectiveDate.SetEndDateNull();
      po.SetCurrencyCode("USD");
      PC.IMTDiscount discInst = (PC.IMTDiscount)po.AddPriceableItem((PC.MTPriceableItem) piTemplate);
      discInst.Cycle.CycleTypeID = 1;
      discInst.Cycle.EndDayOfMonth = 17;
      po.Save();
              
      // Configure rates onto non-shared pricelist
      int idPriceList = po.NonSharedPriceListID;
      PC.IMTParamTableDefinition pt = 
      mPC.GetParamTableDefinitionByName("metratech.com/flatdiscount");
      PC.IMTRateSchedule sched = pt.CreateRateSchedule(idPriceList, piTemplate.ID);
      sched.ParameterTableID = pt.ID;
      sched.Description = "Unit test rates";
      sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");
      sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}", 
                                       Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), 
                                       "flatdiscrules.xml"));
      sched.SaveWithRules();


      // Save PO with availability now that rates are configured.
      po.AvailabilityDate.StartDate = DateTime.Parse("1/1/2000");
      po.AvailabilityDate.SetEndDateNull();
      po.Save();
    }

    public static void GenerateMonthlyFixedFlatUnconditionalDiscountProductOffering()
    {
      PC.IMTPriceableItemType piType = mPC.GetPriceableItemTypeByName("Flat Unconditional Discount");
      PC.IMTPriceableItem piTemplate = piType.CreateTemplate(true);
      piTemplate.Name = string.Format("Flat_Unconditional_Discount{0}", Utils.GetTestId());
      piTemplate.DisplayName = piTemplate.Name;
      piTemplate.Description = piTemplate.Name;
      ((PC.IMTDiscount)piTemplate).Cycle.CycleTypeID = 1;
      ((PC.IMTDiscount)piTemplate).Cycle.EndDayOfMonth = 17;

      piTemplate.Save();

      // make a product offering containing this pi and testpi
      PC.IMTProductOffering po = mPC.CreateProductOffering();
      po.Name = string.Format("PO_{0}", piTemplate.Name);
      po.DisplayName = po.Name;
      po.Description = po.Name;
      po.SelfSubscribable = true;
      po.SelfUnsubscribable = false;
      po.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      po.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      po.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_NULL;
      po.EffectiveDate.SetEndDateNull();
      po.SetCurrencyCode("USD");
      PC.IMTDiscount discInst = (PC.IMTDiscount)po.AddPriceableItem((PC.MTPriceableItem) piTemplate);
      discInst.Cycle.CycleTypeID = 1;
      discInst.Cycle.EndDayOfMonth = 17;
      po.Save();
              
      // Configure rates onto non-shared pricelist
      int idPriceList = po.NonSharedPriceListID;
      PC.IMTParamTableDefinition pt = 
      mPC.GetParamTableDefinitionByName("metratech.com/flatdiscount_nocond");
      PC.IMTRateSchedule sched = pt.CreateRateSchedule(idPriceList, piTemplate.ID);
      sched.ParameterTableID = pt.ID;
      sched.Description = "Unit test rates";
      sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");
      sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}", 
                                       Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), 
                                       "flatunconditionaldiscrules.xml"));
      sched.SaveWithRules();


      // Save PO with availability now that rates are configured.
      po.AvailabilityDate.StartDate = DateTime.Parse("1/1/2000");
      po.AvailabilityDate.SetEndDateNull();
      po.Save();
    }

    public static void GenerateMonthlyMultipleDiscountProductOfferingBCR()
    {
      PC.IMTPriceableItemType piType1 = mPC.GetPriceableItemTypeByName("Percent Unconditional Discount");
      PC.IMTPriceableItem piTemplate1 = piType1.CreateTemplate(true);
      piTemplate1.Name = string.Format("Percent_Unconditional_Discount_Multiple_Discount{0}", Utils.GetTestId());
      piTemplate1.DisplayName = piTemplate1.Name;
      piTemplate1.Description = piTemplate1.Name;
      ((PC.IMTDiscount)piTemplate1).Cycle.CycleTypeID = 1;
      ((PC.IMTDiscount)piTemplate1).Cycle.EndDayOfMonth = 17;
      // Counter 1
      PC.IMTCounterType counterType = mPC.GetCounterTypeByName("SumOfOneProperty");
      PC.IMTCounter counter = counterType.CreateCounter();
      counter.Name = "TestPIUsageTarget";
      counter.Description = counter.Name;
      counter.GetParameter("A").Value = "metratech.com/testpi/amount";
      ((PC.IMTDiscount)piTemplate1).SetCounter(GetCPDByName(piType1, "Target").ID, counter);
      ((PC.IMTDiscount)piTemplate1).SetDistributionCounter(counter);

      piTemplate1.Save();

      PC.IMTPriceableItemType piType2 = mPC.GetPriceableItemTypeByName("Flat Discount");
      PC.IMTPriceableItem piTemplate2 = piType2.CreateTemplate(true);
      piTemplate2.Name = string.Format("Flat_Discount_Multiple_Discount{0}", Utils.GetTestId());
      piTemplate2.DisplayName = piTemplate2.Name;
      piTemplate2.Description = piTemplate2.Name;
      ((PC.IMTDiscount)piTemplate2).Cycle.CycleTypeID = 1;
      ((PC.IMTDiscount)piTemplate2).Cycle.EndDayOfMonth = 17;
      // Counter 1
      counterType = mPC.GetCounterTypeByName("SumOfOneProperty");
      counter = counterType.CreateCounter();
      counter.Name = "TestPIUsageQualifier";
      counter.Description = counter.Name;
      counter.GetParameter("A").Value = "metratech.com/testpi/amount";
      ((PC.IMTDiscount)piTemplate2).SetCounter(GetCPDByName(piType2, "Qualifier").ID, counter);
      ((PC.IMTDiscount)piTemplate2).SetDistributionCounter(counter);

      piTemplate2.Save();

      // make a product offering containing this pi and testpi
      PC.IMTProductOffering po = mPC.CreateProductOffering();
      po.Name = string.Format("PO_Multiple_Discount_BCR{0}", Utils.GetTestId());
      po.DisplayName = po.Name;
      po.Description = po.Name;
      po.SelfSubscribable = true;
      po.SelfUnsubscribable = false;
      po.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      po.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      po.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_NULL;
      po.EffectiveDate.SetEndDateNull();
      po.SetCurrencyCode("USD");
      PC.IMTDiscount discInst1 = (PC.IMTDiscount)po.AddPriceableItem((PC.MTPriceableItem) piTemplate1);
      discInst1.Cycle.CycleTypeID = 1;
      discInst1.Cycle.Mode = PC.MTCycleMode.CYCLE_MODE_BCR;
      PC.IMTDiscount discInst2 = (PC.IMTDiscount)po.AddPriceableItem((PC.MTPriceableItem) piTemplate2);
      discInst2.Cycle.CycleTypeID = 1;
      discInst2.Cycle.Mode = PC.MTCycleMode.CYCLE_MODE_BCR;
      po.Save();
              
      // Configure rates onto non-shared pricelist
      int idPriceList = po.NonSharedPriceListID;
      PC.IMTParamTableDefinition pt = 
      mPC.GetParamTableDefinitionByName("metratech.com/percentdiscount_nocond");
      PC.IMTRateSchedule sched = pt.CreateRateSchedule(idPriceList, piTemplate1.ID);
      sched.ParameterTableID = pt.ID;
      sched.Description = "Unit test rates";
      sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");
      sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}", 
                                       Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), 
                                       "unconditionalpercentdiscrules.xml"));
      sched.SaveWithRules();


      // Configure rates onto non-shared pricelist
      pt = mPC.GetParamTableDefinitionByName("metratech.com/flatdiscount");
      sched = pt.CreateRateSchedule(idPriceList, piTemplate2.ID);
      sched.ParameterTableID = pt.ID;
      sched.Description = "Unit test rates";
      sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");
      sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}", 
                                       Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), 
                                       "flatdiscrules.xml"));
      sched.SaveWithRules();


      // Save PO with availability now that rates are configured.
      po.AvailabilityDate.StartDate = DateTime.Parse("1/1/2000");
      po.AvailabilityDate.SetEndDateNull();
      po.Save();
    }

    public static void GenerateUnitDependentRecurringCharges(int idPriceList)
    {
      PC.IMTPriceableItemType piType = mPC.GetPriceableItemTypeByName("Unit Dependent Recurring Charge");

      // Options:
      // Cycle: Fixed, BCR Unconstrained, BCR Constrained, EBCR (Monthly, Weekly, Daily, Annually)
      // PerSubscription/PerParticipant
      // Arrears/Advance
      // Tiered/Tapered (UDRC only)
      ArrayList cycles = new ArrayList();
      cycles.Add(new CycleOption(PC.MTCycleMode.CYCLE_MODE_FIXED, CycleType.MONTHLY, 31));
      cycles.Add(new CycleOption(PC.MTCycleMode.CYCLE_MODE_FIXED, CycleType.DAILY, -1));
      cycles.Add(new CycleOption(PC.MTCycleMode.CYCLE_MODE_FIXED, CycleType.WEEKLY, 1));
      cycles.Add(new CycleOption(PC.MTCycleMode.CYCLE_MODE_FIXED, CycleType.ANNUAL, 1));
      cycles.Add(new CycleOption(PC.MTCycleMode.CYCLE_MODE_BCR, CycleType.ANNUAL, 1));
      cycles.Add(new CycleOption(PC.MTCycleMode.CYCLE_MODE_BCR_CONSTRAINED, CycleType.MONTHLY, -1));
      cycles.Add(new CycleOption(PC.MTCycleMode.CYCLE_MODE_BCR_CONSTRAINED, CycleType.WEEKLY, -1));
      cycles.Add(new CycleOption(PC.MTCycleMode.CYCLE_MODE_BCR_CONSTRAINED, CycleType.DAILY, -1));
      cycles.Add(new CycleOption(PC.MTCycleMode.CYCLE_MODE_BCR_CONSTRAINED, CycleType.ANNUAL, -1));
      cycles.Add(new CycleOption(PC.MTCycleMode.CYCLE_MODE_EBCR, CycleType.MONTHLY, -1));
      cycles.Add(new CycleOption(PC.MTCycleMode.CYCLE_MODE_EBCR, CycleType.WEEKLY, -1));
      cycles.Add(new CycleOption(PC.MTCycleMode.CYCLE_MODE_EBCR, CycleType.ANNUAL, -1));
      ArrayList advanceArrears = new ArrayList();
      advanceArrears.Add("ADVANCE");
      advanceArrears.Add("ARREARS");
      ArrayList perSubPerPart = new ArrayList();
      perSubPerPart.Add("PERSUB");
      perSubPerPart.Add("PERPART");
      ArrayList tieredTapered = new ArrayList();
      tieredTapered.Add("TIERED");
      tieredTapered.Add("TAPERED");
      foreach(CycleOption co in cycles)
      {
        foreach(string aa in advanceArrears)
        {
          foreach(string sp in perSubPerPart)
          {
            foreach(string tt in tieredTapered)
            {
              PC.IMTRecurringCharge piTemplate = (PC.IMTRecurringCharge) piType.CreateTemplate(false);
              string nm;
              nm = string.Format("UDRC_{0}_{1}_{2}_{3}{4}", co.Description, aa, sp, tt, Utils.GetTestId());
              piTemplate.Name = nm;
              piTemplate.DisplayName = nm;
              piTemplate.Description = "";
              piTemplate.ChargeInAdvance = aa == "ADVANCE";
              piTemplate.ProrateOnActivation = true;
//              piTemplate.ProrateInstantly = false; 
              piTemplate.ProrateOnDeactivation = true;
              piTemplate.ProrateOnRateChange = true;
              piTemplate.FixedProrationLength = false;
              piTemplate.ChargePerParticipant = sp == "PERPART";
              piTemplate.UnitName = "Simple Unit Value";
              piTemplate.RatingType = tt == "TIERED" ? PC.MTUDRCRatingType.UDRCRATING_TYPE_TIERED : PC.MTUDRCRatingType.UDRCRATING_TYPE_TAPERED;
              piTemplate.IntegerUnitValue = true;
              piTemplate.MinUnitValue = 10;
              piTemplate.MaxUnitValue = 1000;
              // Don't specify an enumeration constraint for the UDRC
              co.Set(piTemplate.Cycle);
              piTemplate.Save();

              // Put rates onto a shared pricelist
              PC.IMTParamTableDefinition pt = 
              mPC.GetParamTableDefinitionByName(tt == "TIERED" ? "metratech.com/udrctiered" : "metratech.com/udrctapered");
              PC.IMTRateSchedule sched = pt.CreateRateSchedule(idPriceList, piTemplate.ID);
              sched.ParameterTableID = pt.ID;
              sched.Description = "Unit test rates";
              sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
              sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
              sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
              sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");

              sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}", 
                                             Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), 
                                             tt == "TIERED" ? "udrcrulespersub1.xml" : "udrctaperrulespersub1.xml"));
              sched.SaveWithRules();

              // Lastly, make a product offering containing just this pi
              PC.IMTProductOffering po = mPC.CreateProductOffering();
              po.Name = string.Format("PO_{0}", piTemplate.Name);
              po.DisplayName = po.Name;
              po.Description = po.Name;
              po.SelfSubscribable = true;
              po.SelfUnsubscribable = false;
              po.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
              po.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
              po.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_NULL;
              po.EffectiveDate.SetEndDateNull();
              po.AddPriceableItem((PC.MTPriceableItem) piTemplate);
              
              po.AvailabilityDate.StartDate = DateTime.Parse("1/1/2000");
              po.AvailabilityDate.SetEndDateNull();
              po.SetCurrencyCode("USD");
              po.Save();
            }
          }
        }
      }
    }
    public static void GenerateFlatRecurringCharges(int idPriceList)
    {
      PC.IMTPriceableItemType piType = mPC.GetPriceableItemTypeByName("Flat Rate Recurring Charge");
      if (piType == null) throw new ApplicationException("Flat Rate Recurring Charge pi type not found");

      // Options:
      // Cycle: Fixed, BCR Unconstrained, BCR Constrained, EBCR (Monthly, Weekly, Daily, Annually)
      // PerSubscription/PerParticipant
      // Arrears/Advance
      ArrayList cycles = new ArrayList();
      cycles.Add(new CycleOption(PC.MTCycleMode.CYCLE_MODE_FIXED, CycleType.MONTHLY, 31));
      cycles.Add(new CycleOption(PC.MTCycleMode.CYCLE_MODE_FIXED, CycleType.DAILY, -1));
      cycles.Add(new CycleOption(PC.MTCycleMode.CYCLE_MODE_FIXED, CycleType.WEEKLY, 1));
      cycles.Add(new CycleOption(PC.MTCycleMode.CYCLE_MODE_FIXED, CycleType.ANNUAL, 1));
      cycles.Add(new CycleOption(PC.MTCycleMode.CYCLE_MODE_BCR, CycleType.ANNUAL, 1));
      cycles.Add(new CycleOption(PC.MTCycleMode.CYCLE_MODE_BCR_CONSTRAINED, CycleType.MONTHLY, -1));
      cycles.Add(new CycleOption(PC.MTCycleMode.CYCLE_MODE_BCR_CONSTRAINED, CycleType.WEEKLY, -1));
      cycles.Add(new CycleOption(PC.MTCycleMode.CYCLE_MODE_BCR_CONSTRAINED, CycleType.DAILY, -1));
      cycles.Add(new CycleOption(PC.MTCycleMode.CYCLE_MODE_BCR_CONSTRAINED, CycleType.ANNUAL, -1));
      cycles.Add(new CycleOption(PC.MTCycleMode.CYCLE_MODE_EBCR, CycleType.MONTHLY, -1));
      cycles.Add(new CycleOption(PC.MTCycleMode.CYCLE_MODE_EBCR, CycleType.WEEKLY, -1));
      cycles.Add(new CycleOption(PC.MTCycleMode.CYCLE_MODE_EBCR, CycleType.ANNUAL, -1));
      ArrayList advanceArrears = new ArrayList();
      advanceArrears.Add("ADVANCE");
      advanceArrears.Add("ARREARS");
      ArrayList perSubPerPart = new ArrayList();
      perSubPerPart.Add("PERSUB");
      perSubPerPart.Add("PERPART");
      foreach(CycleOption co in cycles)
      {
        foreach(string aa in advanceArrears)
        {
          foreach(string sp in perSubPerPart)
          {
              PC.IMTRecurringCharge piTemplate = (PC.IMTRecurringCharge) piType.CreateTemplate(false);
              string nm;
              nm = string.Format("FLATRC_{0}_{1}_{2}{3}", co.Description, aa, sp, Utils.GetTestId());
              piTemplate.Name = nm;
              piTemplate.DisplayName = nm;
              piTemplate.Description = "";
              piTemplate.ChargeInAdvance = aa == "ADVANCE";
              piTemplate.ProrateOnActivation = true;
 //             piTemplate.ProrateInstantly = false; 
              piTemplate.ProrateOnDeactivation = true;
              piTemplate.ProrateOnRateChange = true;
              piTemplate.FixedProrationLength = false;
              piTemplate.ChargePerParticipant = sp == "PERPART";
              co.Set(piTemplate.Cycle);
              piTemplate.Save();
              // Put rates onto a shared pricelist
              PC.IMTParamTableDefinition pt = 
              mPC.GetParamTableDefinitionByName("metratech.com/flatrecurringcharge");
              PC.IMTRateSchedule sched = pt.CreateRateSchedule(idPriceList, piTemplate.ID);
              sched.ParameterTableID = pt.ID;
              sched.Description = "Unit test rates";
              sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
              sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
              sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
              sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");

              sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}", 
                                             Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), 
                                             "flatrcrules1.xml"));
              sched.SaveWithRules();

              // Lastly, make a product offering containing just this pi
              PC.IMTProductOffering po = mPC.CreateProductOffering();
              po.Name = string.Format("PO_{0}", piTemplate.Name);
              po.DisplayName = po.Name;
              po.Description = po.Name;
              po.SelfSubscribable = true;
              po.SelfUnsubscribable = false;
              po.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
              po.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
              po.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_NULL;
              po.EffectiveDate.SetEndDateNull();
              po.AddPriceableItem((PC.MTPriceableItem) piTemplate);
              
              po.AvailabilityDate.StartDate = DateTime.Parse("1/1/2000");
              po.AvailabilityDate.SetEndDateNull();
              po.SetCurrencyCode("USD");
              po.Save();
          }
        }
      }
    }
    public static void GeneratePriceableItemTemplates()
    {
      // Create a pricelist for the templates
      PC.IMTPriceList pl = mPC.CreatePriceList();
      pl.Name = string.Format("PL_{0}", Utils.GetTestId());
      pl.Description = pl.Name;
      pl.CurrencyCode = "USD";
      pl.Shareable = true;
      pl.Save();
      GenerateFlatRecurringCharges(pl.ID);
      GenerateUnitDependentRecurringCharges(pl.ID);
    }

    public static void GenerateBillingCycleAccounts()
    {
      // TODO: Really create accounts will all cycles
      string corp = string.Format("ALL_CYCLES_CORP{0}", Utils.GetTestId());
      DateTime startDate = MetraTime.Now.Date;
      CreateCorporation(corp, startDate);
    }

		public static string GenerateSubscriberUserName(int i)
		{
			return string.Format("Sub_{0}_{1}", i, Utils.GetTestId());
		}
		public static string GenerateCorporateAccountName()
		{
			return string.Format("{0}UnitTest_Corp_{1}", mPrefix, Utils.GetTestId());
		}

		public static string GeneratePOName()
		{
			return string.Format("ProdCat_UnitTest_{0}", Utils.GetTestId());
		}
		public static string GenerateGSubName()
		{
			return string.Format("GSub_UnitTest_{0}", Utils.GetTestId());
		}

		public static string GenerateGSMUserName(int i)
		{
			return string.Format("GSM_{0}_{1}", i, Utils.GetTestId());
		}

		public static string GeneratePriceListName()
		{
			return string.Format("ProdCat_UnitTest_PL_{0}", Utils.GetTestId());
		}
		public static YAAC.IMTYAAC GetSubscriberAccount(string login)
		{
			IMTSessionContext ctx = Utils.LoginAsSU();
			YAAC.IMTAccountCatalog cat = new YAAC.MTAccountCatalogClass();
			cat.Init((MetraTech.Interop.MTYAAC.IMTSessionContext)ctx);
			return cat.GetAccountByName(login, "mt", MetraTime.Now);
		}

		private static string mPrefix;
		public static void SetupHierarchy(string testName)
		{
			mPrefix = testName;
			CreateCorporation(MetraTime.Now);
			CreateSubscriberAccounts(1, MetraTime.Now);
			CreateAndConnectGSM();
			//future
			CreateSubscriberAccounts(101, MetraTime.Now.AddMonths(1));
		}

		//Hierarchy Creation
		public static void CreateCorporation(DateTime aStartDate)
		{
			string CorpName = GenerateCorporateAccountName();
      CreateCorporation(CorpName, aStartDate);
    }

		public static void CreateCorporation(string CorpName, DateTime aStartDate)
		{
			IMeter sdk = null;
      try
      {
        sdk = TestLibrary.InitSDK();
        ISessionSet sessionSet = sdk.CreateSessionSet();
        sessionSet.SessionContext = mSUCtx.ToXML();

        ISession session = sessionSet.CreateSession("metratech.com/accountcreation");
        session.RequestResponse = true;
        session.InitProperty("actiontype", "both");
        session.InitProperty("username", CorpName);
        session.InitProperty("password_", "123");
        session.InitProperty("name_space", "mt");
        session.InitProperty("language", "US");
        session.InitProperty("timezoneID", "18");
        session.InitProperty("taxexempt", "F");
        session.InitProperty("city", "Stalingrad");
        session.InitProperty("state", "MA");
        session.InitProperty("zip", "01451");
        session.InitProperty("usagecycletype", "Monthly");
        session.InitProperty("dayofmonth", "1");
        session.InitProperty("paymentmethod", "1");
        session.InitProperty("InvoiceMethod", "Detailed");
        session.InitProperty("transactioncookie", "");
        session.InitProperty("operation", "Add");
        session.InitProperty("firstname", string.Format("{0} NUnit test, ", mPrefix));
        session.InitProperty("lastname", aStartDate.ToString() + " GMT");
        session.InitProperty("email", "account@unittest.com");
        session.InitProperty("phonenumber", "781-839-8300");
        session.InitProperty("company", "MetraTech");
        session.InitProperty("address1", "330 Bear Hill Road");
        session.InitProperty("address2", "Third Floor");
        session.InitProperty("address3", "");
        session.InitProperty("country", "USA");
        session.InitProperty("middleinitial", "");
        session.InitProperty("facsimiletelephonenumber", "781-839-8301");
        session.InitProperty("StatusReason", "0");
        session.InitProperty("accountstatus", "AC");
        session.InitProperty("ancestorAccountID", "1");
        session.InitProperty("folder", "T");
        session.InitProperty("billable", "T");
        session.InitProperty("currency", "USD");
        session.InitProperty("accounttype", "CORPORATEACCOUNT");
        session.InitProperty("contacttype", "bill-to");
        session.InitProperty("applydefaultsecuritypolicy", "F");
        session.InitProperty("accountstartdate", aStartDate);

        try
        {
          sessionSet.Close();
        }
        catch (COMException err)
        {
          TestLibrary.Trace(err.ToString());
        }
      }
      finally
      {
		if (sdk != null)
           Marshal.ReleaseComObject(sdk);
      }
    }

    public static void CreateDepartment(string dept, string parent, DateTime aStartDate)
    {
      IMeter sdk = null;
      try
      {
        sdk = TestLibrary.InitSDK();
        ISessionSet sessionSet = sdk.CreateSessionSet();
        sessionSet.SessionContext = mSUCtx.ToXML();

        ISession session = sessionSet.CreateSession("metratech.com/accountcreation");
        session.RequestResponse = true;
        session.InitProperty("actiontype", "both");
        session.InitProperty("username", dept);
        session.InitProperty("password_", "123");
        session.InitProperty("name_space", "mt");
        session.InitProperty("language", "US");
        session.InitProperty("timezoneID", "18");
        session.InitProperty("taxexempt", "F");
        session.InitProperty("city", "Stalingrad");
        session.InitProperty("state", "MA");
        session.InitProperty("zip", "01451");
        session.InitProperty("usagecycletype", "Monthly");
        session.InitProperty("dayofmonth", "1");
        session.InitProperty("paymentmethod", "1");
        session.InitProperty("InvoiceMethod", "Detailed");
        session.InitProperty("transactioncookie", "");
        session.InitProperty("operation", "Add");
        session.InitProperty("firstname", string.Format("{0} NUnit test, ", mPrefix));
        session.InitProperty("lastname", aStartDate.ToString() + " GMT");
        session.InitProperty("email", "account@unittest.com");
        session.InitProperty("phonenumber", "781-839-8300");
        session.InitProperty("company", "MetraTech");
        session.InitProperty("address1", "330 Bear Hill Road");
        session.InitProperty("address2", "Third Floor");
        session.InitProperty("address3", "");
        session.InitProperty("country", "USA");
        session.InitProperty("middleinitial", "");
        session.InitProperty("facsimiletelephonenumber", "781-839-8301");
        session.InitProperty("StatusReason", "0");
        session.InitProperty("accountstatus", "AC");
        session.InitProperty("ancestorAccountID", Utils.GetAccountID(parent).ToString());
        session.InitProperty("folder", "T");
        session.InitProperty("billable", "T");
        session.InitProperty("currency", "USD");
        session.InitProperty("accounttype", "DepartmentAccount");
        session.InitProperty("contacttype", "bill-to");
        session.InitProperty("applydefaultsecuritypolicy", "F");
        session.InitProperty("accountstartdate", aStartDate);

        try
        {
          sessionSet.Close();
        }
        catch (COMException err)
        {
          TestLibrary.Trace(err.ToString());
        }
      }
      finally
      {
        if (sdk != null)
           Marshal.ReleaseComObject(sdk);
      }
    }

		public static void CreateSubscriberAccounts(string CorpName, ArrayList accountSpecs, DateTime aStartDate)
		{
      IMeter sdk = null;
      try
      {
        sdk = TestLibrary.InitSDK();
        ISessionSet sessionSet = sdk.CreateSessionSet();
        sessionSet.SessionContext = mSUCtx.ToXML();

        foreach (AccountParameters ap in accountSpecs)
        {
          string fullname = ap.UserName;
          string ns = "mt";
          Auth auth = new Auth();
          auth.Initialize(fullname, ns);
          string password = auth.HashNewPassword("123"); 
          ISession session = sessionSet.CreateSession("metratech.com/accountcreation");
          session.RequestResponse = true;
          session.InitProperty("actiontype", "both");
          session.InitProperty("username", fullname);
          session.InitProperty("password_", password);
          session.InitProperty("name_space", ns);
          session.InitProperty("language", "US");
          session.InitProperty("timezoneID", "18");
          session.InitProperty("taxexempt", "F");
          session.InitProperty("city", "Stalingrad");
          session.InitProperty("state", "MA");
          session.InitProperty("zip", "01451");
          ap.Cycle.Set(session);
          session.InitProperty("paymentmethod", "1");
          session.InitProperty("InvoiceMethod", "Detailed");
          session.InitProperty("transactioncookie", "");
          session.InitProperty("operation", "Add");
          session.InitProperty("firstname", "NUnit");
          session.InitProperty("lastname", fullname);
          session.InitProperty("email", "account@unittest.com");
          session.InitProperty("phonenumber", "781-839-8300");
          session.InitProperty("company", "MetraTech");
          session.InitProperty("address1", "330 Bear Hill Road");
          session.InitProperty("address2", "Third Floor");
          session.InitProperty("address3", "");
          session.InitProperty("country", "USA");
          session.InitProperty("middleinitial", "");
          session.InitProperty("facsimiletelephonenumber", "781-839-8301");
          session.InitProperty("StatusReason", "0");
          session.InitProperty("accountstatus", "AC");
          session.InitProperty("ancestorAccount", CorpName);
          session.InitProperty("ancestorAccountNS", "mt");
          session.InitProperty("folder", "T");
          session.InitProperty("billable", "T");
          if (ap.Pricelist.Length > 0)
            session.InitProperty("pricelist", ap.Pricelist);
          session.InitProperty("currency", "USD");
          session.InitProperty("accounttype", "CORESUBSCRIBER");
          session.InitProperty("contacttype", "bill-to");
          session.InitProperty("applydefaultsecuritypolicy", "F");
          session.InitProperty("accountstartdate", aStartDate);

          System.Runtime.InteropServices.Marshal.ReleaseComObject(session);
        }

        try
        {
          sessionSet.Close();
        }
        catch (COMException err)
        {
          TestLibrary.Trace(err.ToString());
        }
      }
      finally
      {
        if (sdk != null)
           Marshal.ReleaseComObject(sdk);
      }
		}

		public static void CreateSubscriberAccounts(int aStartOffset, DateTime aStartDate)
		{
			IMeter sdk = null;
      try
      {
        sdk = TestLibrary.InitSDK();
        ISessionSet sessionSet = sdk.CreateSessionSet();
        sessionSet.SessionContext = mSUCtx.ToXML();
        string CorpName = GenerateCorporateAccountName();

        for (int i = aStartOffset; i < aStartOffset + 100; i++)
        {
          string fullname = Utils.GenerateSubscriberUserName(i);
          ISession session = sessionSet.CreateSession("metratech.com/accountcreation");
          session.RequestResponse = true;
          session.InitProperty("actiontype", "both");
          session.InitProperty("username", fullname);
          session.InitProperty("password_", "123");
          session.InitProperty("name_space", "mt");
          session.InitProperty("language", "US");
          session.InitProperty("timezoneID", "18");
          session.InitProperty("taxexempt", "F");
          session.InitProperty("city", "Stalingrad");
          session.InitProperty("state", "MA");
          session.InitProperty("zip", "01451");
          session.InitProperty("usagecycletype", "Monthly");
          session.InitProperty("dayofmonth", "1");
          session.InitProperty("paymentmethod", "1");
          session.InitProperty("InvoiceMethod", "Detailed");
          session.InitProperty("transactioncookie", "");
          session.InitProperty("operation", "Add");
          session.InitProperty("firstname", "NUnit");
          session.InitProperty("lastname", fullname);
          session.InitProperty("email", "account@unittest.com");
          session.InitProperty("phonenumber", "781-839-8300");
          session.InitProperty("company", "MetraTech");
          session.InitProperty("address1", "330 Bear Hill Road");
          session.InitProperty("address2", "Third Floor");
          session.InitProperty("address3", "");
          session.InitProperty("country", "USA");
          session.InitProperty("middleinitial", "");
          session.InitProperty("facsimiletelephonenumber", "781-839-8301");
          session.InitProperty("StatusReason", "0");
          session.InitProperty("accountstatus", "AC");
          session.InitProperty("ancestorAccount", CorpName);
          session.InitProperty("ancestorAccountNS", "mt");
          session.InitProperty("folder", "T");
          session.InitProperty("billable", "T");
          session.InitProperty("currency", "USD");
          session.InitProperty("accounttype", "CORESUBSCRIBER");
          session.InitProperty("contacttype", "bill-to");
          session.InitProperty("applydefaultsecuritypolicy", "F");
          session.InitProperty("accountstartdate", aStartDate);

          System.Runtime.InteropServices.Marshal.ReleaseComObject(session);
        }

        try
        {
          sessionSet.Close();

        }
        catch (COMException err)
        {
          TestLibrary.Trace(err.ToString());
        }
      }
      finally
      {
        if (sdk != null)
           Marshal.ReleaseComObject(sdk);
      }
    }

		public static void CreateAndConnectGSM()
		{
      IMeter sdk = null;
      try
      {
        sdk = TestLibrary.InitSDK();
        ISessionSet sessionSet = sdk.CreateSessionSet();
        sessionSet.SessionContext = mSUCtx.ToXML();

        for (int i = 1; i < 101; i++)
        {
          string fullname = Utils.GenerateGSMUserName(i);
          ISession session = sessionSet.CreateSession("metratech.com/GSMCreateAndConnect");
          session.RequestResponse = true;
          session.InitProperty("actiontype", "both");
          session.InitProperty("operation", "Add");
          session.InitProperty("username", fullname);
          session.InitProperty("password_", "123");
          session.InitProperty("name_space", "mt");
          session.InitProperty("accounttype", "GSMSERVICEACCOUNT");
          session.InitProperty("language", "US");
          session.InitProperty("timezoneID", "18");
          session.InitProperty("currency", "USD");
          session.InitProperty("accountstartdate", MetraTime.Now);
          session.InitProperty("ancestorAccount", Utils.GenerateSubscriberUserName(i));
          session.InitProperty("ancestorAccountNS", "mt");
          session.InitProperty("accountstatus", "AC");
          session.InitProperty("ApplyAccountTemplate", "F");
          session.InitProperty("ApplyDefaultSecurityPolicy", "F");
          session.InitProperty("IMSI", string.Format("123_{0}", i));
          session.InitProperty("MSISDN", string.Format("123_MSISDN_{0}", i));

          System.Runtime.InteropServices.Marshal.ReleaseComObject(session);
        }

        try
        {
          sessionSet.Close();
        }
        catch (COMException err)
        {
          TestLibrary.Trace(err.ToString());
        }
      }
      finally
      {
        if (sdk != null)
           Marshal.ReleaseComObject(sdk);
      }
    }
		
		public static void AddMapping(string accname, string ns, string newns)
		{
			IMeter sdk = null;
      try
      {
        sdk = TestLibrary.InitSDK();
        ISessionSet sessionSet = sdk.CreateSessionSet();
        sessionSet.SessionContext = mSUCtx.ToXML();
        ISession session = sessionSet.CreateSession("metratech.com/accountmapping");
        session.RequestResponse = true;
        session.InitProperty("operation", 0);
        session.InitProperty("LoginName", accname);
        session.InitProperty("NameSpace", ns);
        session.InitProperty("NewNameSpace", newns);

        try
        {
          sessionSet.Close();
        }
        catch (COMException err)
        {
          TestLibrary.Trace(err.ToString());
        }
      }
      finally
      {
        if (sdk != null)
           Marshal.ReleaseComObject(sdk);
      }
		}
		public static void RemoveConstraintFromPO(string AccountType)
		{
			PC.IMTProductOffering po = mPC.GetProductOfferingByName(Utils.GeneratePOName());
			PC.IMTSQLRowset rs = (PC.IMTSQLRowset)po.GetSubscribableAccountTypesAsRowset();
			Assert.AreEqual(1, rs.RecordCount);
			Account.AccountType coreAccount = new Account.AccountType();
			coreAccount.InitializeByName(AccountType);
			po.RemoveSubscribableAccountType(coreAccount.ID);

			rs = (PC.IMTSQLRowset)po.GetSubscribableAccountTypesAsRowset();
			Assert.AreEqual(0, rs.RecordCount);
		}
		public static void RemoveAllConstraintsFromPO()
		{
			PC.IMTProductOffering po = mPC.GetProductOfferingByName(Utils.GeneratePOName());
			PC.IMTSQLRowset rs = (PC.IMTSQLRowset)po.GetSubscribableAccountTypesAsRowset();
			while(System.Convert.ToBoolean(rs.EOF) == false)
			{
				string name = (string)rs.get_Value("AccountTypeName");
				Account.AccountType att = new Account.AccountType();
				att.InitializeByName(name);
				po.RemoveSubscribableAccountType(att.ID);
				rs.MoveNext();
			}
			rs = (PC.IMTSQLRowset)po.GetSubscribableAccountTypesAsRowset();
			Assert.AreEqual(0, rs.RecordCount);
		}
		public static void AddConstraintToPO(string AccountType)
		{
			PC.IMTProductOffering po = mPC.GetProductOfferingByName(Utils.GeneratePOName());
			PC.IMTSQLRowset rs = (PC.IMTSQLRowset)po.GetSubscribableAccountTypesAsRowset();
			Account.AccountType coreAccount = new Account.AccountType();
			coreAccount.InitializeByName(AccountType);
			po.AddSubscribableAccountType(coreAccount.ID);
		}

		public static string DumpCollection(Coll.IMTCollection coll)
		{
			string val = string.Empty;
			bool first = true;
			foreach(object item in coll)
			{
				if(first == false)
				{
					val += ", ";
				}
				else
					first = false;
				val += (string)item;
			}

			return val;
		}

		public static void MTSQLRowSetExecute(string aQuery)
		{
			RS.IMTSQLRowset rs = new RS.MTSQLRowsetClass();
			rs.Init("Queries\\database");
			rs.SetQueryString(aQuery);
			rs.Execute();
		}
		static ConnectionInfo connInfo = new ConnectionInfo("NetMeter");
		public static DBType DatabaseType
		{
			get
			{
				return connInfo.DatabaseType;
			}
		}
		public static bool IsNull(object test)
		{
			return test.GetType() == typeof(System.DBNull) || test == null;
		}
	}
}
