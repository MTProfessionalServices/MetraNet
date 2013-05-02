using System;
using System.Runtime.InteropServices;
using System.Collections;
using System.Diagnostics;
using NUnit.Framework;
//using NUnit.Framework.Extensions;
using MetraTech.Test;
using MetraTech.Test.Common;
using PC=MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop;
using RS = MetraTech.Interop.Rowset;
using MetraTech.DataAccess;
using Account = MetraTech.Accounts.Type;
using YAAC = MetraTech.Interop.MTYAAC;
using ServerAccess = MetraTech.Interop.MTServerAccess;
using Coll = MetraTech.Interop.GenericCollection;
using MetraTech.Interop.COMMeter;
using PipelineTransaction = MetraTech.Interop.PipelineTransaction;

namespace MetraTech.Product.Test
{
	using System;
	using System.Runtime.InteropServices;
	using NUnit.Framework;

	using MetraTech.DataAccess;
	using MetraTech.UsageServer;

	
	//
	// To run the this test fixture:
	// nunit-console /fixture:MetraTech.Product.Test.AggregateRateTests /assembly:o:\debug\bin\MetraTech.Product.Test.dll
	//
	[TestFixture]
  [Category("NoAutoRun")]
  [ComVisible(false)]
	public class AggregateRateTests 
	{

		private PC.MTProductCatalog mPC;
    private MetraTech.Interop.MTProductView.IProductViewCatalog mPvCatalog;
		private YAAC.IMTAccountCatalog mAccCatalog;
		private IMTSessionContext mSUCtx = null;
    private string mCorporate;
    private PC.IMTProductOffering mSongDownloads;
    private PC.IMTProductOffering mSongDownloadsBCR;
    private PC.IMTProductOffering mSongSession;
    private PC.IMTProductOffering mSmokeAggregateDecProp1;		 
    private PC.IMTProductOffering mSmokeAggregateCount;	
    private IMeter mSDK;
    private RS.IMTSQLRowset mDummyRowset;

		public AggregateRateTests()
		{
      // COM+ 15 second delay workaround
			mDummyRowset = new RS.MTSQLRowsetClass();
			mDummyRowset.Init("Queries\\database");

      mPvCatalog = new MetraTech.Interop.MTProductView.ProductViewCatalog();
			mPC = new PC.MTProductCatalogClass();
			mAccCatalog = new YAAC.MTAccountCatalog();
			mSUCtx = Utils.LoginAsSU();
			mAccCatalog.Init((YAAC.IMTSessionContext)mSUCtx);
			mPC.SetSessionContext((PC.IMTSessionContext)mSUCtx);
			Utils.TurnTraceOn();

      mSDK = TestLibrary.InitSDK();
      
      string testid=Utils.GetTestId();
			Utils.GenerateSongDownloadsProductOffering();
			Utils.GenerateSongDownloadsBCRProductOffering();
			Utils.GenerateSongSessionProductOffering();
      GenerateSmokeAggregateDecProp1ProductOffering();
      GenerateSmokeAggregateCountProductOffering();
      mSmokeAggregateDecProp1 = mPC.GetProductOfferingByName(string.Format("PO_SmokeAggregateDecProp1{0}", testid));
      mSmokeAggregateCount = mPC.GetProductOfferingByName(string.Format("PO_SmokeAggregateCount{0}", testid));
      mSongDownloads = mPC.GetProductOfferingByName(string.Format("PO_Song Downloads{0}", testid));
      mSongDownloadsBCR = mPC.GetProductOfferingByName(string.Format("PO_BCR_Song Downloads{0}", testid));
      mSongSession = mPC.GetProductOfferingByName(string.Format("PO_Song Session{0}", testid));

      mCorporate = String.Format("AggregateRateTests{0}", testid);
      // We'll be back dating accounts so backdate the corporation too.
      Utils.CreateCorporation(mCorporate, MetraTime.Now.AddYears(-1));
		}

    void ValidateAggregateCount(PC.IMTProductOffering po, YAAC.IMTYAAC accs, int expectedCount, bool firstPass)
    {
      MetraTech.Interop.MTProductView.IProductView pv = mPvCatalog.GetProductViewByName(
        firstPass ?
        ((PC.IMTAggregateCharge) po.GetPriceableItems()[1]).FirstPassProductView :
        ((PC.IMTAggregateCharge) po.GetPriceableItems()[1]).PriceableItemType.ProductView);

      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            String.Format("SELECT COUNT(*) as cnt FROM t_acc_usage au " +
                          "INNER JOIN {0} pv ON au.id_sess=pv.id_sess " +
                          "WHERE au.id_acc=?", pv.tablename)))
          {

              stmt.AddParam(MTParameterType.Integer, accs.ID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  reader.Read();
                  Assert.AreEqual(expectedCount, reader.GetInt32("cnt"));
              }
          }
      }
    }

    void ValidateFirstPassCount(PC.IMTProductOffering po, YAAC.IMTYAAC accs, int expectedCount)
    {
      ValidateAggregateCount(po, accs, expectedCount, true);
    }
    void ValidateSecondPassCount(PC.IMTProductOffering po, YAAC.IMTYAAC accs, int expectedCount)
    {
      ValidateAggregateCount(po, accs, expectedCount, false);
    }
		void MeterSongSessionTestUsage(YAAC.IMTYAAC account, int count)
		{
      System.Collections.Generic.List<YAAC.IMTYAAC> list = new System.Collections.Generic.List<YAAC.IMTYAAC>();
      list.Add(account);
      MeterSongSessionTestUsage(list, count);
    }
		void MeterSongSessionTestUsage(System.Collections.Generic.ICollection<YAAC.IMTYAAC> accounts, int count)
		{
      ISessionSet sessionSet = mSDK.CreateSessionSet();
      foreach(YAAC.IMTYAAC accs in accounts)
      {
        for(int i =1; i<= count; i++)
        {
          ISession session = sessionSet.CreateSession("metratech.com/songsession");
          session.InitProperty("description", "AggregateRateTests.MeterSongSessionTestUsage");
          session.InitProperty("duration", 2.23*i);	
          session.InitProperty("accountname", accs.LoginName);
          ISession childSession = session.CreateChildSession("metratech.com/songsessionchild");
          childSession.InitProperty("description", "AggregateRateTests.MeterSongSessionTestUsage");
          childSession.InitProperty("songs", 4*i);
          childSession.InitProperty("mp3bytes", 23433*i);	
          childSession.InitProperty("wavbytes", 1888232*i); 
          childSession.InitProperty("accountname", accs.LoginName);
          System.Runtime.InteropServices.Marshal.ReleaseComObject(childSession);
          childSession = session.CreateChildSession("metratech.com/songsessionchild");
          childSession.InitProperty("description", "AggregateRateTests.MeterSongSessionTestUsage");
          childSession.InitProperty("songs", 3*i);
          childSession.InitProperty("mp3bytes", 1993433*i);	
          childSession.InitProperty("wavbytes", 88322*i); 
          childSession.InitProperty("accountname", accs.LoginName);
          System.Runtime.InteropServices.Marshal.ReleaseComObject(childSession);
          session.RequestResponse = true;
          System.Runtime.InteropServices.Marshal.ReleaseComObject(session);
        }
      }
      sessionSet.Close();    
      System.Runtime.InteropServices.Marshal.ReleaseComObject(sessionSet);
    }
		void MeterSongDownloadsTestUsage(YAAC.IMTYAAC account, int count)
		{
      System.Collections.Generic.List<YAAC.IMTYAAC> list = new System.Collections.Generic.List<YAAC.IMTYAAC>();
      list.Add(account);
      MeterSongDownloadsTestUsage(list, count);
    }
		void MeterSongDownloadsTestUsage(System.Collections.Generic.ICollection<YAAC.IMTYAAC> accounts, int count)
		{
      ISessionSet sessionSet = mSDK.CreateSessionSet();
      foreach(YAAC.IMTYAAC accs in accounts)
      {
        for(int i =1; i<= count; i++)
        {
          ISession session = sessionSet.CreateSession("metratech.com/songdownloads");
          session.InitProperty("description", "AggregateRateTests.MeterSongDownloadsTestUsage");
          session.InitProperty("songs", 4*i);
          session.InitProperty("mp3bytes", 23433*i);	
          session.InitProperty("wavbytes", 1888232*i); 
          session.InitProperty("accountname", accs.LoginName);
          session.RequestResponse = true;
          System.Runtime.InteropServices.Marshal.ReleaseComObject(session);
        }
      }
      sessionSet.Close(); 
      System.Runtime.InteropServices.Marshal.ReleaseComObject(sessionSet);
    }

    public void GenerateSmokeAggregateDecProp1ProductOffering()
    {
      PC.IMTPriceableItem piTemplate = mPC.GetPriceableItemByName("SmokeAggregateDecProp1");

      // make a product offering containing just this pi
      PC.IMTProductOffering po = mPC.CreateProductOffering();
      po.Name = string.Format("PO_{0}{1}", piTemplate.Name, Utils.GetTestId());
      po.DisplayName = po.Name;
      po.Description = po.Name;
      po.SelfSubscribable = false;
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
    }
    public void GenerateSmokeAggregateCountProductOffering()
    {
      PC.IMTPriceableItem piTemplate = mPC.GetPriceableItemByName("SmokeAggregateCount");

      // make a product offering containing just this pi
      PC.IMTProductOffering po = mPC.CreateProductOffering();
      po.Name = string.Format("PO_{0}{1}", piTemplate.Name, Utils.GetTestId());
      po.DisplayName = po.Name;
      po.Description = po.Name;
      po.SelfSubscribable = false;
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
    }

    class SongDownloadsTestRecord
    {
      public string Description;
      public Decimal Songs;
      public Decimal Mp3Bytes;
      public Decimal WavBytes;
      public string AccountName;
      public DateTime StartTime;
      public Decimal TotalSongs;
      public Decimal TotalBytes;

      public SongDownloadsTestRecord(string description, Decimal songs, 
                                     Decimal mp3Bytes, Decimal wavBytes, 
                                     string accountName, DateTime startTime,
                                     Decimal totalSongs, Decimal totalBytes)
      {
        Description = description;
        Songs = songs;
        Mp3Bytes = mp3Bytes;
        WavBytes = wavBytes;
        AccountName = accountName;
        StartTime = startTime;
        TotalSongs = totalSongs;
        TotalBytes = totalBytes;
      }
    };
		void MeterSongDownloadsTestUsage(System.Collections.Generic.ICollection<SongDownloadsTestRecord> recs)
		{
      ISessionSet sessionSet = mSDK.CreateSessionSet();
      foreach(SongDownloadsTestRecord rec in recs)
      {
        ISession session = sessionSet.CreateSession("metratech.com/songdownloads");
        session.InitProperty("description", rec.Description);
        session.InitProperty("songs", rec.Songs);
        session.InitProperty("mp3bytes", rec.Mp3Bytes);	
        session.InitProperty("wavbytes", rec.WavBytes); 
        session.InitProperty("accountname", rec.AccountName);
        session.InitProperty("starttime", rec.StartTime);
        session.RequestResponse = true;
        System.Runtime.InteropServices.Marshal.ReleaseComObject(session);
      }
      sessionSet.Close(); 
      System.Runtime.InteropServices.Marshal.ReleaseComObject(sessionSet);
    }
    class TestServiceTestRecord
    {
      public string Description;
      public string AccountName;
      public DateTime EventTimestamp;
      public Decimal Units;
      public Decimal DecProp1;
      public TestServiceTestRecord(string description,
                                   string accountName,
                                   DateTime eventTimestamp,
                                   Decimal units,
                                   Decimal decProp1)
      {
        Description = description;
        AccountName = accountName;
        EventTimestamp = eventTimestamp;
        Units = units;
        DecProp1 = decProp1;
      }
    }
		void MeterTestServiceTestUsage(System.Collections.Generic.ICollection<TestServiceTestRecord> recs)
		{
      ISessionSet sessionSet = mSDK.CreateSessionSet();
      foreach(TestServiceTestRecord rec in recs)
      {
        ISession session = sessionSet.CreateSession("metratech.com/testservice");
        session.InitProperty("description", rec.Description);
        session.InitProperty("accountname", rec.AccountName);
        session.InitProperty("Time", rec.EventTimestamp);
        session.InitProperty("Pipelinetime", rec.EventTimestamp);
        session.InitProperty("Units", rec.Units);
        session.InitProperty("DecProp1", rec.DecProp1);
        session.RequestResponse = true;
        System.Runtime.InteropServices.Marshal.ReleaseComObject(session);
      }
      sessionSet.Close(); 
      System.Runtime.InteropServices.Marshal.ReleaseComObject(sessionSet);
    }
    class SmokeAggregateTestRecord
    {
      public string Description;
      public string AccountName;
      public DateTime EventTimestamp;
      public Decimal TotalAmount;

      public SmokeAggregateTestRecord(string description, 
                                     string accountName, 
                                     DateTime eventTimestamp,
                                     Decimal totalAmount)
      {
        Description = description;
        AccountName = accountName;
        EventTimestamp = eventTimestamp;
        TotalAmount = totalAmount;
      }
    }
    class SmokeAggregateCountTestRecord
    {
      public string Description;
      public string AccountName;
      public DateTime EventTimestamp;
      public Decimal TotalAmount;

      public SmokeAggregateCountTestRecord(string description, 
                                           string accountName, 
                                           DateTime eventTimestamp,
                                           Decimal totalAmount)
      {
        Description = description;
        AccountName = accountName;
        EventTimestamp = eventTimestamp;
        TotalAmount = totalAmount;
      }
    }
		void MeterSmokeAggregateDecProp1TestUsage(System.Collections.Generic.ICollection<SmokeAggregateTestRecord> recs)
		{
      ISessionSet sessionSet = mSDK.CreateSessionSet();
      foreach(SmokeAggregateTestRecord rec in recs)
      {
        ISession session = sessionSet.CreateSession("metratech.com/smokeaggrdec");
        session.InitProperty("description", rec.Description);
        session.InitProperty("accountname", rec.AccountName);
        session.InitProperty("EventTimestamp", rec.EventTimestamp);
        session.RequestResponse = true;
        System.Runtime.InteropServices.Marshal.ReleaseComObject(session);
      }
      sessionSet.Close(); 
      System.Runtime.InteropServices.Marshal.ReleaseComObject(sessionSet);
    }
		void MeterSmokeAggregateCountTestUsage(System.Collections.Generic.ICollection<SmokeAggregateCountTestRecord> recs)
		{
      ISessionSet sessionSet = mSDK.CreateSessionSet();
      foreach(SmokeAggregateCountTestRecord rec in recs)
      {
        ISession session = sessionSet.CreateSession("metratech.com/smokeaggrcnt");
        session.InitProperty("description", rec.Description);
        session.InitProperty("accountname", rec.AccountName);
        session.InitProperty("EventTimestamp", rec.EventTimestamp);
        session.RequestResponse = true;
        System.Runtime.InteropServices.Marshal.ReleaseComObject(session);
      }
      sessionSet.Close(); 
      System.Runtime.InteropServices.Marshal.ReleaseComObject(sessionSet);
    }

    void ValidateAggregateResults(System.Collections.Generic.ICollection<SongDownloadsTestRecord> recs,
                                  int interval,
                                  string testID)
    {
      System.Collections.Generic.List<SongDownloadsTestRecord> dbRecs = 
      new System.Collections.Generic.List<SongDownloadsTestRecord>();
      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT pv.c_description, pv.c_songs, pv.c_mp3bytes, pv.c_wavbytes, pv.c_accountname, au.dt_session, pv.c_totalsongs, pv.c_totalbytes\n" +
            "FROM t_acc_usage au INNER JOIN t_pv_songdownloads pv ON pv.id_sess=au.id_sess\n" +
            "WHERE au.id_usage_interval = ? AND pv.c_accountname like ?"))
          {
              stmt.AddParam(MTParameterType.Integer, interval);
              stmt.AddParam(MTParameterType.String, "%" + testID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      dbRecs.Add(new SongDownloadsTestRecord(reader.GetString("c_description"),
                                                             reader.GetDecimal("c_songs"),
                                                             reader.GetDecimal("c_mp3bytes"),
                                                             reader.GetDecimal("c_wavbytes"),
                                                             reader.GetString("c_accountname"),
                                                             reader.GetDateTime("dt_session"),
                                                             reader.GetDecimal("c_totalsongs"),
                                                             reader.GetDecimal("c_totalbytes")));
                  }
              }
          }
      }

      Assert.AreEqual(recs.Count, dbRecs.Count);

      // Check for duplicates
      System.Collections.Generic.Dictionary<string, SongDownloadsTestRecord> dupCheck =
      new System.Collections.Generic.Dictionary<string, SongDownloadsTestRecord>();
      foreach(SongDownloadsTestRecord rec in dbRecs)
      {
        Assert.IsFalse(dupCheck.ContainsKey(rec.Description));
        dupCheck.Add(rec.Description, rec);
      }
      
      // Check Results by hash join
      System.Collections.Generic.Dictionary<string, SongDownloadsTestRecord> join =
      new System.Collections.Generic.Dictionary<string, SongDownloadsTestRecord>();
      foreach(SongDownloadsTestRecord rec in recs)
      {
        join.Add(rec.Description, rec);
      }
      foreach(SongDownloadsTestRecord rec in dbRecs)
      {
        Assert.IsTrue(join.ContainsKey(rec.Description));
        Assert.AreEqual(join[rec.Description].TotalSongs, 
                        rec.TotalSongs,
                        String.Format("TotalSongs mismatch: interval={0}; c_accountname='{1}'; c_description='{2}'",
                                      interval, rec.AccountName, rec.Description));
        Assert.AreEqual(join[rec.Description].TotalBytes, 
                        rec.TotalBytes,
                        String.Format("TotalBytes mismatch: interval={0}; c_accountname='{1}'; c_description='{2}'",
                                      interval, rec.AccountName, rec.Description));
      }
    }

    void ValidateAggregateResults(System.Collections.Generic.ICollection<SmokeAggregateTestRecord> recs,
                                  int interval,
                                  string testID)
    {
      System.Collections.Generic.List<SmokeAggregateTestRecord> dbRecs = 
      new System.Collections.Generic.List<SmokeAggregateTestRecord>();
      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT pv.c_description, pv.c_accountname, au.dt_session, pv.c_totalamount\n" +
            "FROM t_acc_usage au INNER JOIN t_pv_smokeaggrdec pv ON pv.id_sess=au.id_sess\n" +
            "WHERE au.id_usage_interval = ? AND pv.c_accountname like ?"))
          {
              stmt.AddParam(MTParameterType.Integer, interval);
              stmt.AddParam(MTParameterType.String, "%" + testID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      dbRecs.Add(new SmokeAggregateTestRecord(reader.GetString("c_description"),
                                                              reader.GetString("c_accountname"),
                                                              reader.GetDateTime("dt_session"),
                                                              reader.GetDecimal("c_totalamount")));
                  }
              }
          }
      }

      Assert.AreEqual(recs.Count, dbRecs.Count);

      // Check for duplicates
      System.Collections.Generic.Dictionary<string, SmokeAggregateTestRecord> dupCheck =
      new System.Collections.Generic.Dictionary<string, SmokeAggregateTestRecord>();
      foreach(SmokeAggregateTestRecord rec in dbRecs)
      {
        Assert.IsFalse(dupCheck.ContainsKey(rec.Description));
        dupCheck.Add(rec.Description, rec);
      }
      
      // Check Results by hash join
      System.Collections.Generic.Dictionary<string, SmokeAggregateTestRecord> join =
      new System.Collections.Generic.Dictionary<string, SmokeAggregateTestRecord>();
      foreach(SmokeAggregateTestRecord rec in recs)
      {
        join.Add(rec.Description, rec);
      }
      foreach(SmokeAggregateTestRecord rec in dbRecs)
      {
        Assert.IsTrue(join.ContainsKey(rec.Description));
        Assert.AreEqual(join[rec.Description].TotalAmount, 
                        rec.TotalAmount,
                        String.Format("TotalAmount mismatch: interval={0}; c_accountname='{1}'; c_description='{2}'",
                                      interval, rec.AccountName, rec.Description));
      }
    }

    void ValidateAggregateResults(System.Collections.Generic.ICollection<SmokeAggregateCountTestRecord> recs,
                                  int interval,
                                  string testID)
    {
      System.Collections.Generic.List<SmokeAggregateCountTestRecord> dbRecs = 
      new System.Collections.Generic.List<SmokeAggregateCountTestRecord>();
      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT pv.c_description, pv.c_accountname, au.dt_session, pv.c_totalamount\n" +
            "FROM t_acc_usage au INNER JOIN t_pv_smokeaggrcnt pv ON pv.id_sess=au.id_sess\n" +
            "WHERE au.id_usage_interval = ? AND pv.c_accountname like ?"))
          {
              stmt.AddParam(MTParameterType.Integer, interval);
              stmt.AddParam(MTParameterType.String, "%" + testID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      dbRecs.Add(new SmokeAggregateCountTestRecord(reader.GetString("c_description"),
                                                                   reader.GetString("c_accountname"),
                                                                   reader.GetDateTime("dt_session"),
                                                                   reader.GetDecimal("c_totalamount")));
                  }
              }
          }
      }

      Assert.AreEqual(recs.Count, dbRecs.Count);

      // Check for duplicates
      System.Collections.Generic.Dictionary<string, SmokeAggregateCountTestRecord> dupCheck =
      new System.Collections.Generic.Dictionary<string, SmokeAggregateCountTestRecord>();
      foreach(SmokeAggregateCountTestRecord rec in dbRecs)
      {
        Assert.IsFalse(dupCheck.ContainsKey(rec.Description));
        dupCheck.Add(rec.Description, rec);
      }
      
      // Check Results by hash join
      System.Collections.Generic.Dictionary<string, SmokeAggregateCountTestRecord> join =
      new System.Collections.Generic.Dictionary<string, SmokeAggregateCountTestRecord>();
      foreach(SmokeAggregateCountTestRecord rec in recs)
      {
        join.Add(rec.Description, rec);
      }
      foreach(SmokeAggregateCountTestRecord rec in dbRecs)
      {
        Assert.IsTrue(join.ContainsKey(rec.Description));
        Assert.AreEqual(join[rec.Description].TotalAmount, 
                        rec.TotalAmount,
                        String.Format("TotalAmount mismatch: interval={0}; c_accountname='{1}'; c_description='{2}'",
                                      interval, rec.AccountName, rec.Description));
      }
    }

    int GetOpenInterval(YAAC.IMTYAAC acc, DateTime at)
    {
        using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
        {
            using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
              "SELECT aui.id_usage_interval FROM t_acc_usage_interval aui " +
              "INNER JOIN t_usage_interval ui ON aui.id_usage_interval=ui.id_interval " +
              "WHERE aui.id_acc = ? AND ? BETWEEN ui.dt_start AND ui.dt_end AND aui.tx_status='O'"))
            {
                stmt.AddParam(MTParameterType.Integer, acc.ID);
                stmt.AddParam(MTParameterType.DateTime, at);
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    reader.Read();
                    return reader.GetInt32("id_usage_interval");
                }
            }
        }
    }

    int GetCurrentOpenInterval(YAAC.IMTYAAC acc)
    {
        using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
        {
            using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
              "SELECT aui.id_usage_interval FROM t_acc_usage_interval aui " +
              "INNER JOIN t_usage_interval ui ON aui.id_usage_interval=ui.id_interval " +
              "WHERE aui.id_acc = ? AND ? BETWEEN ui.dt_start AND ui.dt_end AND aui.tx_status='O'"))
            {
                stmt.AddParam(MTParameterType.Integer, acc.ID);
                stmt.AddParam(MTParameterType.DateTime, MetraTime.Now);
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    reader.Read();
                    return reader.GetInt32("id_usage_interval");
                }
            }
        }
    }

    void GetCurrentOpenInterval(YAAC.IMTYAAC acc, 
                                out int interval, 
                                out DateTime intervalStart, 
                                out DateTime intervalEnd)
    {
        using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
        {
            using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
              "SELECT aui.id_usage_interval, ui.dt_start, ui.dt_end FROM t_acc_usage_interval aui " +
              "INNER JOIN t_usage_interval ui ON aui.id_usage_interval=ui.id_interval " +
              "WHERE aui.id_acc = ? AND ? BETWEEN ui.dt_start AND ui.dt_end AND aui.tx_status='O'"))
            {
                stmt.AddParam(MTParameterType.Integer, acc.ID);
                stmt.AddParam(MTParameterType.DateTime, MetraTime.Now);
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    reader.Read();
                    interval = reader.GetInt32("id_usage_interval");
                    intervalStart = reader.GetDateTime("dt_start");
                    intervalEnd = reader.GetDateTime("dt_end");
                }
            }
        }
    }

    void CreateIndividualSubscription(YAAC.IMTYAAC account,
                                      System.Collections.Generic.ICollection<PC.IMTProductOffering> pos,
                                      DateTime startDate, DateTime endDate)
    {
      System.Collections.Generic.List<YAAC.IMTYAAC> accounts = new System.Collections.Generic.List<YAAC.IMTYAAC>();
      accounts.Add(account);
      CreateIndividualSubscription(accounts, pos, startDate, endDate);
    }

    void CreateIndividualSubscription(System.Collections.Generic.ICollection<YAAC.IMTYAAC> accounts,
                                      PC.IMTProductOffering po, DateTime startDate, DateTime endDate)
    {
      System.Collections.Generic.List<PC.IMTProductOffering> pos = new System.Collections.Generic.List<PC.IMTProductOffering>();
      pos.Add(po);
      CreateIndividualSubscription(accounts, pos, startDate, endDate);
    }

    void CreateIndividualSubscription(YAAC.IMTYAAC account,
                                      PC.IMTProductOffering po,
                                      DateTime startDate, 
                                      DateTime endDate)
    {
      System.Collections.Generic.List<YAAC.IMTYAAC> accounts = new System.Collections.Generic.List<YAAC.IMTYAAC>();
      accounts.Add(account);
      System.Collections.Generic.List<PC.IMTProductOffering> pos = new System.Collections.Generic.List<PC.IMTProductOffering>();
      pos.Add(po);
      CreateIndividualSubscription(accounts, pos, startDate, endDate);
    }

    void CreateIndividualSubscription(System.Collections.Generic.ICollection<YAAC.IMTYAAC> accounts,
                                      System.Collections.Generic.ICollection<PC.IMTProductOffering> pos,
                                      DateTime startDate, DateTime endDate)
    {
      foreach(PC.IMTProductOffering po in pos)
      {
        foreach(YAAC.IMTYAAC accs in accounts)
        {
          PC.IMTPCAccount pcAcc = mPC.GetAccount(accs.ID);
          PC.MTPCTimeSpan span = new PC.MTPCTimeSpanClass();
          span.StartDate = startDate;
          span.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
          span.EndDate = endDate;
          span.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
          object ignore;
          PC.IMTSubscription sub = pcAcc.Subscribe(po.ID, span, out ignore);
          sub.Save();
        }      
      }
    }

		public void CreateGroupSubscription(PC.IMTProductOffering po, 
                                        YAAC.IMTYAAC corporate, 
                                        System.Collections.Generic.List<YAAC.IMTYAAC> accounts, 
                                        Utils.BillingCycle accountBillingCycle,
                                        DateTime startDate,
                                        DateTime endDate,
                                        bool sharedCounters)
    {
			//create group subscription
			PC.IMTGroupSubscription gs  = mPC.CreateGroupSubscription();
			gs.ProductOfferingID = po.ID;
			gs.Name = String.Format("GROUPSUB_{0}_{1}", accountBillingCycle.ToString(), po.Name);
			gs.Description = gs.Name;
			gs.CorporateAccount = corporate.ID;
      gs.SupportGroupOps = sharedCounters;
			PC.MTPCTimeSpan eff = new PC.MTPCTimeSpanClass();
			eff.StartDate = startDate;
			
			PC.MTPCCycle cycle = new PC.MTPCCycleClass();
      accountBillingCycle.Set(cycle);
			
			gs.EffectiveDate = eff;
			gs.ProportionalDistribution = true;
			gs.Cycle = cycle;
			gs.Save();

      PC.IMTCollection members = (PC.IMTCollection) new Coll.MTCollectionClass();
      foreach(YAAC.IMTYAAC acc in accounts)
      {
        PC.IMTGSubMember member = new PC.MTGSubMemberClass();
        member.AccountID = acc.ID;
        member.StartDate = startDate;
        member.EndDate = endDate;
        members.Add(member);
      }
			bool mod;
      PC.IMTSQLRowset rs = (PC.IMTSQLRowset)gs.AddAccountBatch(members, null, out mod, null);
    }

		public void CreateGroupSubscription(PC.IMTProductOffering po, YAAC.IMTYAAC corporate, YAAC.IMTYAAC account, Utils.BillingCycle accountBillingCycle, DateTime startDate, DateTime endDate, bool sharedCounters)
		{
      System.Collections.Generic.List<YAAC.IMTYAAC> accounts = new System.Collections.Generic.List<YAAC.IMTYAAC>();
      accounts.Add(account);
      CreateGroupSubscription(po, corporate, accounts, accountBillingCycle, startDate, endDate, sharedCounters);
		}

    void RunAggregateAdapterWithBillingGroups(System.Collections.Generic.List<System.Collections.Generic.List<YAAC.IMTYAAC> > accounts, 
                                              int usageIntervalID)
    {
      // Setup the adapter test manager with one interval, one account and multiple billgroup
      MetraTech.UsageServer.Test.AdapterTestConfig atc = new MetraTech.UsageServer.Test.AdapterTestConfig();
      atc.Intervals = new MetraTech.UsageServer.Test.Interval[] {new MetraTech.UsageServer.Test.Interval()};
      atc.Intervals[0].Id = usageIntervalID;
      atc.Intervals[0].BillingGroups = new MetraTech.UsageServer.Test.BillingGroup[accounts.Count];
      for(int j=0; j<accounts.Count; j++)
      {
        atc.Intervals[0].BillingGroups[j] = new MetraTech.UsageServer.Test.BillingGroup();
        atc.Intervals[0].BillingGroups[j].Name = String.Format("test1_bg{0}", j);
        atc.Intervals[0].BillingGroups[j].Description = "Aggregate Usage Smoke Test";
        // All accounts into the same billing group
        System.Collections.Generic.List<YAAC.IMTYAAC> bgaccounts = accounts[j];
        atc.Intervals[0].BillingGroups[j].Accounts = new MetraTech.UsageServer.Test.Account[bgaccounts.Count];
        for(int i=0; i<bgaccounts.Count; i++)
        {
          MetraTech.UsageServer.Test.Account tmp = new MetraTech.UsageServer.Test.Account();
          tmp.Id = bgaccounts[i].ID;
          atc.Intervals[0].BillingGroups[j].Accounts[i] = tmp;
        }
      }
      atc.Adapters = new MetraTech.UsageServer.Test.Adapter[] {new MetraTech.UsageServer.Test.Adapter()};
      atc.Adapters[0].Name = "AggregateCharges";
      atc.Adapters[0].TestClass = "MetraTech.Product.Test.NullAdapterTest,MetraTech.Product.Test";
      atc.Adapters[0].Ignore = false;
      atc.Adapters[0].Reverse = false;
      atc.Adapters[0].Intervals = new MetraTech.UsageServer.Test.Interval[] {new MetraTech.UsageServer.Test.Interval()};
      atc.Adapters[0].Intervals[0].Id = usageIntervalID;
      atc.UserId = 129;
      
      string errs;
      MetraTech.UsageServer.Test.AdapterTestManager.RunTests(atc, out errs);
      Assert.AreEqual(0, errs.Length);
    }

    void RunAggregateAdapterOneBillingGroup(System.Collections.Generic.List<YAAC.IMTYAAC> accounts, int usageIntervalID)
    {
      // Setup the adapter test manager with one interval, one account and one billgroup
      MetraTech.UsageServer.Test.AdapterTestConfig atc = new MetraTech.UsageServer.Test.AdapterTestConfig();
      atc.Intervals = new MetraTech.UsageServer.Test.Interval[] {new MetraTech.UsageServer.Test.Interval()};
      atc.Intervals[0].Id = usageIntervalID;
      atc.Intervals[0].BillingGroups = new MetraTech.UsageServer.Test.BillingGroup[] {new MetraTech.UsageServer.Test.BillingGroup()};
      atc.Intervals[0].BillingGroups[0].Name = "test1";
      atc.Intervals[0].BillingGroups[0].Description = "Aggregate Usage Smoke Test";
      // All accounts into the same billing group
      atc.Intervals[0].BillingGroups[0].Accounts = new MetraTech.UsageServer.Test.Account[accounts.Count];
      for(int i=0; i<accounts.Count; i++)
      {
        MetraTech.UsageServer.Test.Account tmp = new MetraTech.UsageServer.Test.Account();
        tmp.Id = accounts[i].ID;
        atc.Intervals[0].BillingGroups[0].Accounts[i] = tmp;
      }
      atc.Adapters = new MetraTech.UsageServer.Test.Adapter[] {new MetraTech.UsageServer.Test.Adapter()};
      atc.Adapters[0].Name = "AggregateCharges";
      atc.Adapters[0].TestClass = "MetraTech.Product.Test.NullAdapterTest,MetraTech.Product.Test";
      atc.Adapters[0].Ignore = false;
      atc.Adapters[0].Reverse = false;
      atc.Adapters[0].Intervals = new MetraTech.UsageServer.Test.Interval[] {new MetraTech.UsageServer.Test.Interval()};
      atc.Adapters[0].Intervals[0].Id = usageIntervalID;
      atc.UserId = 129;
      
      string errs;
      MetraTech.UsageServer.Test.AdapterTestManager.RunTests(atc, out errs);
      Assert.AreEqual(0, errs.Length);
    }

    void RunAggregateAdapterOneBillingGroup(YAAC.IMTYAAC acc, int usageIntervalID)
    {
      System.Collections.Generic.List<YAAC.IMTYAAC> accounts =
      new System.Collections.Generic.List<YAAC.IMTYAAC>();
      accounts.Add(acc);
      RunAggregateAdapterOneBillingGroup(accounts, usageIntervalID);
    }

    void TestSongDownloads(string corporate, 
                           bool isGroupSub, 
                           DateTime startDate,
                           Utils.BillingCycle accountBillingCycle, 
                           PC.IMTProductOffering po)
    {
      // Create the account with the billing cycle
      ArrayList subs = new ArrayList();
      string accountName = String.Format(isGroupSub ? "GSUB_{0}{1}" : "SUB_{0}{1}",
                                         accountBillingCycle.ToString(),
                                         Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(accountName, accountBillingCycle));
      Utils.CreateSubscriberAccounts(corporate, subs, startDate);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = mAccCatalog.GetAccountByName(corporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC acc = mAccCatalog.GetAccountByName(accountName, "mt", MetraTime.Now);      
      int interval = GetCurrentOpenInterval(acc);
      // Subscribe individually or group.
      if (isGroupSub)
      {
        CreateGroupSubscription(po, corporateAcc, acc, accountBillingCycle, MetraTime.Now, DateTime.Parse("1/1/2038"), false);
      }
      else
      {
        CreateIndividualSubscription(acc, po, MetraTime.Now, DateTime.Parse("1/1/2038"));        
      }
      // Meter usage.
      MeterSongDownloadsTestUsage(acc, 10);
      ValidateFirstPassCount(po, acc, 10);
      // Trigger 2nd pass processing for this pi template and interval.
      PC.IMTAggregateCharge agg = (PC.IMTAggregateCharge) ((PC.IMTPriceableItem)po.GetPriceableItems()[1]).GetTemplate();
      agg.Rate(interval, 1000);
      ValidateSecondPassCount(po, acc, 10);
    }
    

    [SetUp]
    public void Init()
    {
    }

    [Test]
    public void TestMonthlyEndOfMonthIndividualSubscriptionSongDownloads()
    {
      TestSongDownloads(mCorporate, false, MetraTime.Now,
                        new Utils.BillingCycle (Utils.CycleType.MONTHLY, 31), 
                        mSongDownloads);
    }
    [Test]
    public void TestMonthlyFirstOfMonthGroupSubscriptionSongDownloads()
    {
      TestSongDownloads(mCorporate, true, MetraTime.Now,
                        new Utils.BillingCycle (Utils.CycleType.MONTHLY, 1), 
                        mSongDownloads);
    }
    [Test]
    public void TestMonthlySecondOfMonthIndividualAndGroupSubscriptionWithSharedCountersSongDownloads()
    {
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 2);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);
      // Create the accounts with the billing cycle, one for group one for individual.
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("SUB_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      string groupAccountName1 = String.Format("GSUB1_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      string groupAccountName2 = String.Format("GSUB2_{0}{1}",
                                               accountBillingCycle.ToString(),
                                               Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle));
      subs.Add(new Utils.AccountParameters(groupAccountName1, accountBillingCycle));
      subs.Add(new Utils.AccountParameters(groupAccountName2, accountBillingCycle));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = mAccCatalog.GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC indivAcc = mAccCatalog.GetAccountByName(indivAccountName, "mt", MetraTime.Now);      
      YAAC.IMTYAAC groupAcc1 = mAccCatalog.GetAccountByName(groupAccountName1, "mt", MetraTime.Now);      
      YAAC.IMTYAAC groupAcc2 = mAccCatalog.GetAccountByName(groupAccountName2, "mt", MetraTime.Now);      
      int interval = GetCurrentOpenInterval(indivAcc);
      // Subscribe individually and group at start of current interval.
      System.Collections.Generic.List<YAAC.IMTYAAC> accs = new System.Collections.Generic.List<YAAC.IMTYAAC>();
      accs.Add(groupAcc1);
      accs.Add(groupAcc2);
      CreateGroupSubscription(mSongDownloads, corporateAcc, accs, accountBillingCycle, pcIntervalStart, DateTime.Parse("1/1/2038"), true);
      CreateIndividualSubscription(indivAcc, mSongDownloads, pcIntervalStart, DateTime.Parse("1/1/2038"));        
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The aggregate instance is monthly ending on the 17th.
      System.Collections.Generic.List<SongDownloadsTestRecord> testRecs = 
      new System.Collections.Generic.List<SongDownloadsTestRecord>();
      testRecs.Add(new SongDownloadsTestRecord("1", 1, 100, 100, indivAcc.LoginName, pcIntervalStart.AddDays(1), 0, 0));
      testRecs.Add(new SongDownloadsTestRecord("2", 3, 300, 100, groupAcc2.LoginName, pcIntervalStart.AddDays(9), 5, 600));
      testRecs.Add(new SongDownloadsTestRecord("3", 2, 200, 100, groupAcc1.LoginName, pcIntervalStart.AddDays(11), 8, 1000));
      testRecs.Add(new SongDownloadsTestRecord("4", 2, 200, 100, groupAcc2.LoginName, pcIntervalStart.AddDays(19), 0, 0));
      testRecs.Add(new SongDownloadsTestRecord("5", 2, 200, 100, groupAcc1.LoginName, pcIntervalStart.AddDays(22), 2, 300));
      testRecs.Add(new SongDownloadsTestRecord("6", 2, 200, 100, groupAcc2.LoginName, pcIntervalStart.AddDays(26), 4, 600));
      testRecs.Add(new SongDownloadsTestRecord("7", 8, 800, 100, indivAcc.LoginName, pcIntervalStart.AddDays(20), 0, 0));
      testRecs.Add(new SongDownloadsTestRecord("8", 4, 400, 100, indivAcc.LoginName, pcIntervalStart.AddDays(10), 1, 200));
      testRecs.Add(new SongDownloadsTestRecord("9", 5, 500, 100, groupAcc1.LoginName, pcIntervalStart.AddDays(2), 0, 0));
      MeterSongDownloadsTestUsage(testRecs);
      // Trigger 2nd pass processing for this pi template and interval.
      PC.IMTAggregateCharge agg = (PC.IMTAggregateCharge) ((PC.IMTPriceableItem)mSongDownloads.GetPriceableItems()[1]).GetTemplate();
      agg.Rate(interval, 1000);
      ValidateAggregateResults(testRecs, interval, Utils.GetTestId());
    }
    [Test]
    public void TestMonthlyThirdOfMonthIndividualAndGroupSubscriptionSongSession()
    {
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 3);
      // Create the accounts with the billing cycle, one for group one for individual.
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("SUB_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      string groupAccountName = String.Format("GSUB_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle));
      subs.Add(new Utils.AccountParameters(groupAccountName, accountBillingCycle));
      Utils.CreateSubscriberAccounts(mCorporate, subs, MetraTime.Now);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = mAccCatalog.GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC indivAcc = mAccCatalog.GetAccountByName(indivAccountName, "mt", MetraTime.Now);      
      YAAC.IMTYAAC groupAcc = mAccCatalog.GetAccountByName(groupAccountName, "mt", MetraTime.Now);      
      int interval = GetCurrentOpenInterval(indivAcc);
      // Subscribe individually and group.
      CreateGroupSubscription(mSongSession, corporateAcc, groupAcc, 
                              accountBillingCycle, MetraTime.Now, DateTime.Parse("1/1/2038"), true);
      CreateIndividualSubscription(indivAcc, mSongSession, MetraTime.Now, DateTime.Parse("1/1/2038"));        
      // Meter usage.
      MeterSongSessionTestUsage(indivAcc, 10);
      ValidateFirstPassCount(mSongSession, indivAcc, 10);
      MeterSongSessionTestUsage(groupAcc, 10);
      ValidateFirstPassCount(mSongSession, groupAcc, 10);
      // Trigger 2nd pass processing for this pi template and interval.
      PC.IMTAggregateCharge agg = (PC.IMTAggregateCharge) ((PC.IMTPriceableItem)mSongSession.GetPriceableItems()[1]).GetTemplate();
      agg.Rate(interval, 1000);
      ValidateSecondPassCount(mSongSession, indivAcc, 10);
      ValidateSecondPassCount(mSongSession, groupAcc, 10);
    }
    [Test]
    public void TestMonthlyFourthOfMonthIndividualAndGroupSubscriptionWithNonSharedCountersSongDownloads()
    {
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 4);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);
      // Create the accounts with the billing cycle, one for group one for individual.
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("SUB_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      string groupAccountName1 = String.Format("GSUB1_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      string groupAccountName2 = String.Format("GSUB2_{0}{1}",
                                               accountBillingCycle.ToString(),
                                               Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle));
      subs.Add(new Utils.AccountParameters(groupAccountName1, accountBillingCycle));
      subs.Add(new Utils.AccountParameters(groupAccountName2, accountBillingCycle));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = mAccCatalog.GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC indivAcc = mAccCatalog.GetAccountByName(indivAccountName, "mt", MetraTime.Now);      
      YAAC.IMTYAAC groupAcc1 = mAccCatalog.GetAccountByName(groupAccountName1, "mt", MetraTime.Now);      
      YAAC.IMTYAAC groupAcc2 = mAccCatalog.GetAccountByName(groupAccountName2, "mt", MetraTime.Now);      
      int interval = GetCurrentOpenInterval(indivAcc);
      // Subscribe individually and group at start of current interval.
      System.Collections.Generic.List<YAAC.IMTYAAC> accs = new System.Collections.Generic.List<YAAC.IMTYAAC>();
      accs.Add(groupAcc1);
      accs.Add(groupAcc2);
      CreateGroupSubscription(mSongDownloads, corporateAcc, accs, accountBillingCycle, pcIntervalStart, DateTime.Parse("1/1/2038"), false);
      CreateIndividualSubscription(indivAcc, mSongDownloads, pcIntervalStart, DateTime.Parse("1/1/2038"));        
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The aggregate instance is monthly ending on the 17th.
      System.Collections.Generic.List<SongDownloadsTestRecord> testRecs = 
      new System.Collections.Generic.List<SongDownloadsTestRecord>();
      testRecs.Add(new SongDownloadsTestRecord("1", 1, 100, 100, indivAcc.LoginName, pcIntervalStart.AddDays(1), 0, 0));
      testRecs.Add(new SongDownloadsTestRecord("2", 3, 300, 100, groupAcc2.LoginName, pcIntervalStart.AddDays(9), 0, 0));
      testRecs.Add(new SongDownloadsTestRecord("3", 2, 200, 100, groupAcc1.LoginName, pcIntervalStart.AddDays(11), 5, 600));
      testRecs.Add(new SongDownloadsTestRecord("4", 2, 200, 100, groupAcc2.LoginName, pcIntervalStart.AddDays(19), 0, 0));
      testRecs.Add(new SongDownloadsTestRecord("5", 2, 200, 100, groupAcc1.LoginName, pcIntervalStart.AddDays(22), 0, 0));
      testRecs.Add(new SongDownloadsTestRecord("6", 2, 200, 100, groupAcc2.LoginName, pcIntervalStart.AddDays(26), 2, 300));
      testRecs.Add(new SongDownloadsTestRecord("7", 8, 800, 100, indivAcc.LoginName, pcIntervalStart.AddDays(20), 0, 0));
      testRecs.Add(new SongDownloadsTestRecord("8", 4, 400, 100, indivAcc.LoginName, pcIntervalStart.AddDays(10), 1, 200));
      testRecs.Add(new SongDownloadsTestRecord("9", 5, 500, 100, groupAcc1.LoginName, pcIntervalStart.AddDays(2), 0, 0));
      testRecs.Add(new SongDownloadsTestRecord("10", 3, 300, 100, indivAcc.LoginName, pcIntervalStart.AddDays(27), 8, 900));
      MeterSongDownloadsTestUsage(testRecs);
      // Trigger 2nd pass processing for this pi template and interval.
      PC.IMTAggregateCharge agg = (PC.IMTAggregateCharge) ((PC.IMTPriceableItem)mSongDownloads.GetPriceableItems()[1]).GetTemplate();
      agg.Rate(interval, 1000);
      ValidateAggregateResults(testRecs, interval, Utils.GetTestId());
    }
    [Test]
    public void TestMonthlyFifthOfMonthIndividualAndNonSharedGroupSubscriptionSameAccountSongDownloads()
    {
      // This tests the rules for guiding usage to counters in the individual and group subscription
      // cases.  The business rules look like the following:
      // If a CDRs occur during a group subscription membership period, then they are counted against
      // that group subscription counter ONLY.  If a CDR does not occur during a group subscription membership
      // period, then is treated as non-group subscription and counted against individual aggregate counter
      // attached to the payee (note that this doesn't require subscription).
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 5);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);
      // Create the accounts with the billing cycle
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("SUB_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());

      subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = mAccCatalog.GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC indivAcc = mAccCatalog.GetAccountByName(indivAccountName, "mt", MetraTime.Now);      
      int interval = GetCurrentOpenInterval(indivAcc);

      // Subscribe individually, then group and then individual again.
      CreateIndividualSubscription(indivAcc, mSongDownloads, pcIntervalStart, pcIntervalStart.AddDays(6).AddSeconds(-1));        
      System.Collections.Generic.List<YAAC.IMTYAAC> accs = new System.Collections.Generic.List<YAAC.IMTYAAC>();
      accs.Add(indivAcc);
      CreateGroupSubscription(mSongDownloads, corporateAcc, accs, accountBillingCycle, pcIntervalStart.AddDays(6), pcIntervalStart.AddDays(9).AddSeconds(-1), false);
      CreateIndividualSubscription(indivAcc, mSongDownloads, pcIntervalStart.AddDays(9), DateTime.Parse("1/1/2038"));        
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The aggregate instance is monthly ending on the 17th.
      System.Collections.Generic.List<SongDownloadsTestRecord> testRecs = 
      new System.Collections.Generic.List<SongDownloadsTestRecord>();
      // Start out off subscription
      testRecs.Add(new SongDownloadsTestRecord("1", 1, 100, 100, indivAcc.LoginName, pcIntervalStart.AddDays(1), 0, 0));
      testRecs.Add(new SongDownloadsTestRecord("2", 3, 300, 100, indivAcc.LoginName, pcIntervalStart.AddDays(2), 1, 200));
      // Move on to subscription.  Don't reset counters since non-shared group.
      testRecs.Add(new SongDownloadsTestRecord("3", 2, 200, 100, indivAcc.LoginName, pcIntervalStart.AddDays(6), 4, 600));
      testRecs.Add(new SongDownloadsTestRecord("4", 2, 200, 100, indivAcc.LoginName, pcIntervalStart.AddDays(7), 6, 900));
      testRecs.Add(new SongDownloadsTestRecord("5", 2, 200, 100, indivAcc.LoginName, pcIntervalStart.AddDays(8), 8, 1200));
      // Back off subscription.  Don't reset counters since non-shared group.
      testRecs.Add(new SongDownloadsTestRecord("6", 2, 200, 100, indivAcc.LoginName, pcIntervalStart.AddDays(9), 10, 1500));
      testRecs.Add(new SongDownloadsTestRecord("7", 8, 800, 100, indivAcc.LoginName, pcIntervalStart.AddDays(10), 12, 1800));
      // New aggregate interval off subscription
      testRecs.Add(new SongDownloadsTestRecord("8", 4, 400, 100, indivAcc.LoginName, pcIntervalStart.AddDays(12), 0, 0));
      testRecs.Add(new SongDownloadsTestRecord("9", 5, 500, 100, indivAcc.LoginName, pcIntervalStart.AddDays(13), 4, 500));
      testRecs.Add(new SongDownloadsTestRecord("10", 3, 300, 100, indivAcc.LoginName, pcIntervalStart.AddDays(14), 9, 1100));
      MeterSongDownloadsTestUsage(testRecs);
      // Trigger 2nd pass processing for this pi template and interval.
      PC.IMTAggregateCharge agg = (PC.IMTAggregateCharge) ((PC.IMTPriceableItem)mSongDownloads.GetPriceableItems()[1]).GetTemplate();
      agg.Rate(interval, 1000);
      ValidateAggregateResults(testRecs, interval, Utils.GetTestId());
    }
    [Test]
    public void TestMonthly6thNoSubscriptionThenIndividualSubscriptionSongDownloads()
    {
      // Take an interval with no aggregate usage and invoke the adapter code.
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 6);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);

      // Create the accounts with the billing cycle.  Put default pricelist on so we
      // can do aggregate usage off subscription.
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("SUB_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      string pricelistName=String.Format("PL_{0}{1}", 
                                         accountBillingCycle.ToString(),
                                         Utils.GetTestId());
      Utils.GenerateSharedPricelist(pricelistName);
      subs.Add(new Utils.AccountParameters(indivAccountName, 
                                           accountBillingCycle,
                                           pricelistName));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);
      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = mAccCatalog.GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC indivAcc = mAccCatalog.GetAccountByName(indivAccountName, "mt", MetraTime.Now);      
      int interval;
      DateTime intervalStart;
      DateTime intervalEnd;
      GetCurrentOpenInterval(indivAcc, out interval, out intervalStart, out intervalEnd);
      // Do Off Subscription, On Subscription, Off Subscription
      // What I want to verify is that individual subscription doesn't reset counters
      // and I want to see a single countable updating two counters (the template
      // weekly counter and the PO monthly counter).
      // The weekly counter makes describing the expected results a bit tough.  We start
      // metering on the first Saturday after interval start (2 days on one counter).
      // We start subscription on the first Tuesday after interval start and go till the
      // 2nd Saturday.  
      // Since the interval starts on the 6th:  
      // The first Saturday after is between the 6th and 12th.  
      // The first Tuesday is between the 9th and 15th.  
      // The 2nd Saturday is between the 13th and 19th.
      DateTime firstSaturday = intervalStart.AddDays((13 - (int) intervalStart.DayOfWeek) % 7);
      CreateIndividualSubscription(indivAcc, mSongDownloads, firstSaturday.AddDays(2), firstSaturday.AddDays(8).AddSeconds(-1));        

      System.Collections.Generic.List<SongDownloadsTestRecord> testRecs = 
      new System.Collections.Generic.List<SongDownloadsTestRecord>();
      testRecs.Add(new SongDownloadsTestRecord("1", 1, 100, 100, indivAcc.LoginName, firstSaturday.AddDays(0), 0, 0));
      testRecs.Add(new SongDownloadsTestRecord("2", 5, 500, 100, indivAcc.LoginName, firstSaturday.AddDays(1), 1, 200));
      // Off subscription weekly counter boundary
      testRecs.Add(new SongDownloadsTestRecord("3", 4, 400, 100, indivAcc.LoginName, firstSaturday.AddDays(2), 6, 800));
      // On to subscription and monthly counter
      testRecs.Add(new SongDownloadsTestRecord("4", 3, 300, 100, indivAcc.LoginName, firstSaturday.AddDays(3), 10, 1300));
      testRecs.Add(new SongDownloadsTestRecord("5", 7, 700, 100, indivAcc.LoginName, firstSaturday.AddDays(4), 13, 1700));
      // Back off subscription and on to a weekly counter
      testRecs.Add(new SongDownloadsTestRecord("6", 4, 400, 100, indivAcc.LoginName, firstSaturday.AddDays(8), 14, 1700));
      
      // Off the subscription again.
      MeterSongDownloadsTestUsage(testRecs);
      ValidateFirstPassCount(mSongDownloads, indivAcc, 6);
      // Trigger 2nd pass processing for this pi template and interval.
      PC.IMTAggregateCharge agg = (PC.IMTAggregateCharge) ((PC.IMTPriceableItem)mSongDownloads.GetPriceableItems()[1]).GetTemplate();
      agg.Rate(interval, 1000);
      ValidateAggregateResults(testRecs, interval, Utils.GetTestId());
    }
    [Test]
    public void TestMonthlySeventhAndEighthOfMonthGroupSubscriptionWithSharedCountersSongDownloads()
    {
      Utils.BillingCycle accountBillingCycle1 = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 7);
      Utils.BillingCycle accountBillingCycle2 = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 8);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle2.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);
      // Create the accounts with the billing cycle, one for group one for individual.
      ArrayList subs = new ArrayList();
      string groupAccountName1 = String.Format("GSUB1_{0}{1}",
                                              accountBillingCycle1.ToString(),
                                              Utils.GetTestId());
      string groupAccountName2 = String.Format("GSUB1_{0}{1}",
                                               accountBillingCycle2.ToString(),
                                               Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(groupAccountName1, accountBillingCycle1));
      subs.Add(new Utils.AccountParameters(groupAccountName2, accountBillingCycle2));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = mAccCatalog.GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC groupAcc1 = mAccCatalog.GetAccountByName(groupAccountName1, "mt", MetraTime.Now);      
      YAAC.IMTYAAC groupAcc2 = mAccCatalog.GetAccountByName(groupAccountName2, "mt", MetraTime.Now);      
      // For this test to work on the 8th of the month we need to make sure that we pick the interval that
      // contains the dates to which we are metering.
      int interval1 = GetOpenInterval(groupAcc1, pcIntervalStart);
      int interval2 = GetCurrentOpenInterval(groupAcc2);
      // Subscribe group at start of current interval.
      System.Collections.Generic.List<YAAC.IMTYAAC> accs = new System.Collections.Generic.List<YAAC.IMTYAAC>();
      accs.Add(groupAcc1);
      accs.Add(groupAcc2);
      CreateGroupSubscription(mSongDownloads, corporateAcc, accs, accountBillingCycle1, pcIntervalStart, DateTime.Parse("1/1/2038"), true);
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The aggregate instance is monthly ending on the 17th (9 days from when we start metering).
      // We are testing for two different things.  Firstly that the shared counter works and secondly
      // that groupAcc1's usage always appears before groupAcc2's usage in aggregate order.
      System.Collections.Generic.List<SongDownloadsTestRecord> testRecs1 = 
      new System.Collections.Generic.List<SongDownloadsTestRecord>();
      System.Collections.Generic.List<SongDownloadsTestRecord> testRecs2 = 
      new System.Collections.Generic.List<SongDownloadsTestRecord>();
      testRecs2.Add(new SongDownloadsTestRecord("1", 1, 100, 100, groupAcc2.LoginName, pcIntervalStart.AddDays(1), 11, 1400));
      testRecs1.Add(new SongDownloadsTestRecord("2", 5, 500, 100, groupAcc1.LoginName, pcIntervalStart.AddDays(2), 0, 0));
      testRecs2.Add(new SongDownloadsTestRecord("3", 3, 300, 100, groupAcc2.LoginName, pcIntervalStart.AddDays(3), 12, 1600));
      testRecs1.Add(new SongDownloadsTestRecord("4", 4, 400, 100, groupAcc1.LoginName, pcIntervalStart.AddDays(4), 5, 600));
      testRecs1.Add(new SongDownloadsTestRecord("5", 2, 200, 100, groupAcc1.LoginName, pcIntervalStart.AddDays(7), 9, 1100));
      testRecs2.Add(new SongDownloadsTestRecord("6", 2, 200, 100, groupAcc2.LoginName, pcIntervalStart.AddDays(8), 15, 2000));
      // New interval starts here.
      testRecs2.Add(new SongDownloadsTestRecord("7", 8, 800, 100, groupAcc2.LoginName, pcIntervalStart.AddDays(9), 2, 300));
      testRecs1.Add(new SongDownloadsTestRecord("8", 2, 200, 100, groupAcc1.LoginName, pcIntervalStart.AddDays(10), 0, 0));
      testRecs2.Add(new SongDownloadsTestRecord("9", 2, 200, 100, groupAcc2.LoginName, pcIntervalStart.AddDays(11), 10, 1200));
      MeterSongDownloadsTestUsage(testRecs2);
      MeterSongDownloadsTestUsage(testRecs1);
      // Trigger 2nd pass processing for this pi template and interval.
      PC.IMTAggregateCharge agg = (PC.IMTAggregateCharge) ((PC.IMTPriceableItem)mSongDownloads.GetPriceableItems()[1]).GetTemplate();
      agg.Rate(interval1, 1000);
      agg.Rate(interval2, 1000);
      ValidateAggregateResults(testRecs1, interval1, Utils.GetTestId());
      ValidateAggregateResults(testRecs2, interval2, Utils.GetTestId());
    }
    [Test]
    public void TestMonthlyNinthOfMonthIndividualAndSharedGroupSubscriptionSameAccountSongDownloads()
    {
      // This tests the rules for guiding usage to counters in the individual and group subscription
      // cases.  The business rules look like the following:
      // If a CDRs occur during a group subscription membership period, then they are counted against
      // that group subscription counter ONLY.  If a CDR does not occur during a group subscription membership
      // period, then is treated as non-group subscription and counted against individual aggregate counter
      // attached to the payee (note that this doesn't require subscription).
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 9);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);
      // Create the accounts with the billing cycle
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("SUB_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());

      subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = mAccCatalog.GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC indivAcc = mAccCatalog.GetAccountByName(indivAccountName, "mt", MetraTime.Now);      
      int interval = GetCurrentOpenInterval(indivAcc);

      // Subscribe individually, then group and then individual again.
      CreateIndividualSubscription(indivAcc, mSongDownloads, pcIntervalStart, pcIntervalStart.AddDays(6).AddSeconds(-1));        
      System.Collections.Generic.List<YAAC.IMTYAAC> accs = new System.Collections.Generic.List<YAAC.IMTYAAC>();
      accs.Add(indivAcc);
      CreateGroupSubscription(mSongDownloads, corporateAcc, accs, accountBillingCycle, pcIntervalStart.AddDays(6), pcIntervalStart.AddDays(9).AddSeconds(-1), true);
      CreateIndividualSubscription(indivAcc, mSongDownloads, pcIntervalStart.AddDays(9), DateTime.Parse("1/1/2038"));        
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The aggregate instance is monthly ending on the 17th.
      // In the shared group subscription case, counters are "reset" at group
      // subscription boundaries.
      System.Collections.Generic.List<SongDownloadsTestRecord> testRecs = 
      new System.Collections.Generic.List<SongDownloadsTestRecord>();
      // Start out off subscription (weekly)
      testRecs.Add(new SongDownloadsTestRecord("1", 1, 100, 100, indivAcc.LoginName, pcIntervalStart.AddDays(1), 0, 0));
      if (pcIntervalStart.AddDays(2).DayOfWeek == DayOfWeek.Monday)
      {
        testRecs.Add(new SongDownloadsTestRecord("2", 3, 300, 100, indivAcc.LoginName, pcIntervalStart.AddDays(2), 0, 0));
      }
      else
      {
        testRecs.Add(new SongDownloadsTestRecord("2", 3, 300, 100, indivAcc.LoginName, pcIntervalStart.AddDays(2), 1, 200));
      }

      // Move on to subscription
      testRecs.Add(new SongDownloadsTestRecord("3", 2, 200, 100, indivAcc.LoginName, pcIntervalStart.AddDays(6), 0, 0));
      testRecs.Add(new SongDownloadsTestRecord("4", 2, 200, 100, indivAcc.LoginName, pcIntervalStart.AddDays(7), 2, 300));
      // A new monthly interval here while on group subscription.
      testRecs.Add(new SongDownloadsTestRecord("5", 2, 200, 100, indivAcc.LoginName, pcIntervalStart.AddDays(8), 0, 0));
      // Back off group sub and onto individual.  Reset counter since this is group shared.
      testRecs.Add(new SongDownloadsTestRecord("6", 2, 200, 100, indivAcc.LoginName, pcIntervalStart.AddDays(9), 0, 0));
      testRecs.Add(new SongDownloadsTestRecord("7", 8, 800, 100, indivAcc.LoginName, pcIntervalStart.AddDays(10), 2, 300));
      testRecs.Add(new SongDownloadsTestRecord("8", 4, 400, 100, indivAcc.LoginName, pcIntervalStart.AddDays(12), 10, 1200));
      testRecs.Add(new SongDownloadsTestRecord("9", 5, 500, 100, indivAcc.LoginName, pcIntervalStart.AddDays(13), 14, 1700));
      testRecs.Add(new SongDownloadsTestRecord("10", 3, 300, 100, indivAcc.LoginName, pcIntervalStart.AddDays(14), 19, 2300));
      MeterSongDownloadsTestUsage(testRecs);
      // Trigger 2nd pass processing for this pi template and interval.
      PC.IMTAggregateCharge agg = (PC.IMTAggregateCharge) ((PC.IMTPriceableItem)mSongDownloads.GetPriceableItems()[1]).GetTemplate();
      agg.Rate(interval, 1000);
      ValidateAggregateResults(testRecs, interval, Utils.GetTestId());
    }
    [Test]
    public void TestMonthlyTenthOfMonthIndividualAndGroupSubscriptionWithSharedCountersSongDownloadsBCR()
    {
      // Test that shared group counters and individual counters resolve BCR cycles correctly.
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 10);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);
      // Create the accounts with the billing cycle, one for group one for individual.
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("SUB_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      string groupAccountName1 = String.Format("GSUB1_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      string groupAccountName2 = String.Format("GSUB2_{0}{1}",
                                               accountBillingCycle.ToString(),
                                               Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle));
      subs.Add(new Utils.AccountParameters(groupAccountName1, accountBillingCycle));
      subs.Add(new Utils.AccountParameters(groupAccountName2, accountBillingCycle));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = mAccCatalog.GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC indivAcc = mAccCatalog.GetAccountByName(indivAccountName, "mt", MetraTime.Now);      
      YAAC.IMTYAAC groupAcc1 = mAccCatalog.GetAccountByName(groupAccountName1, "mt", MetraTime.Now);      
      YAAC.IMTYAAC groupAcc2 = mAccCatalog.GetAccountByName(groupAccountName2, "mt", MetraTime.Now);      
      int interval = GetCurrentOpenInterval(indivAcc);
      // Subscribe individually and group at start of current interval.
      System.Collections.Generic.List<YAAC.IMTYAAC> accs = new System.Collections.Generic.List<YAAC.IMTYAAC>();
      accs.Add(groupAcc1);
      accs.Add(groupAcc2);
      CreateGroupSubscription(mSongDownloadsBCR, corporateAcc, accs, accountBillingCycle, pcIntervalStart, DateTime.Parse("1/1/2038"), true);
      CreateIndividualSubscription(indivAcc, mSongDownloadsBCR, pcIntervalStart, DateTime.Parse("1/1/2038"));        
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The aggregate instance is monthly ending on the 10th (BCR).
      System.Collections.Generic.List<SongDownloadsTestRecord> testRecs = 
      new System.Collections.Generic.List<SongDownloadsTestRecord>();
      testRecs.Add(new SongDownloadsTestRecord("1", 1, 100, 100, indivAcc.LoginName, pcIntervalStart.AddDays(1), 0, 0));
      testRecs.Add(new SongDownloadsTestRecord("2", 5, 500, 100, groupAcc1.LoginName, pcIntervalStart.AddDays(2), 0, 0));
      testRecs.Add(new SongDownloadsTestRecord("3", 3, 300, 100, groupAcc2.LoginName, pcIntervalStart.AddDays(9), 5, 600));
      testRecs.Add(new SongDownloadsTestRecord("4", 4, 400, 100, indivAcc.LoginName, pcIntervalStart.AddDays(10), 1, 200));
      testRecs.Add(new SongDownloadsTestRecord("5", 2, 200, 100, groupAcc1.LoginName, pcIntervalStart.AddDays(11), 8, 1000));
      testRecs.Add(new SongDownloadsTestRecord("6", 2, 200, 100, groupAcc2.LoginName, pcIntervalStart.AddDays(19), 10, 1300));
      testRecs.Add(new SongDownloadsTestRecord("7", 8, 800, 100, indivAcc.LoginName, pcIntervalStart.AddDays(20), 5, 700));
      testRecs.Add(new SongDownloadsTestRecord("8", 2, 200, 100, groupAcc1.LoginName, pcIntervalStart.AddDays(22), 12, 1600));
      testRecs.Add(new SongDownloadsTestRecord("9", 2, 200, 100, groupAcc2.LoginName, pcIntervalStart.AddDays(26), 14, 1900));
      MeterSongDownloadsTestUsage(testRecs);
      // Trigger 2nd pass processing for this pi template and interval.
      PC.IMTAggregateCharge agg = (PC.IMTAggregateCharge) ((PC.IMTPriceableItem)mSongDownloadsBCR.GetPriceableItems()[1]).GetTemplate();
      agg.Rate(interval, 1000);
      ValidateAggregateResults(testRecs, interval, Utils.GetTestId());
    }
    [Test]
    public void TestMonthlyEleventhOfMonthGroupSubscriptionNonSharedCountersSongDownloadsBCR()
    {
      // Test that non-shared group counters resolve BCR cycles correctly.
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 11);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);
      // Create the accounts with the billing cycle, one for group one for individual.
      ArrayList subs = new ArrayList();
      string groupAccountName1 = String.Format("GSUB1_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      string groupAccountName2 = String.Format("GSUB2_{0}{1}",
                                               accountBillingCycle.ToString(),
                                               Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(groupAccountName1, accountBillingCycle));
      subs.Add(new Utils.AccountParameters(groupAccountName2, accountBillingCycle));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = mAccCatalog.GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC groupAcc1 = mAccCatalog.GetAccountByName(groupAccountName1, "mt", MetraTime.Now);      
      YAAC.IMTYAAC groupAcc2 = mAccCatalog.GetAccountByName(groupAccountName2, "mt", MetraTime.Now);      
      int interval = GetCurrentOpenInterval(groupAcc1);
      // Subscribe individually and group at start of current interval.
      System.Collections.Generic.List<YAAC.IMTYAAC> accs = new System.Collections.Generic.List<YAAC.IMTYAAC>();
      accs.Add(groupAcc1);
      accs.Add(groupAcc2);
      CreateGroupSubscription(mSongDownloadsBCR, corporateAcc, accs, accountBillingCycle, pcIntervalStart, DateTime.Parse("1/1/2038"), false);
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The aggregate instance is monthly ending on the 11th (BCR).
      System.Collections.Generic.List<SongDownloadsTestRecord> testRecs = 
      new System.Collections.Generic.List<SongDownloadsTestRecord>();
      testRecs.Add(new SongDownloadsTestRecord("1", 1, 100, 100, groupAcc2.LoginName, pcIntervalStart.AddDays(1), 0, 0));
      testRecs.Add(new SongDownloadsTestRecord("2", 5, 500, 100, groupAcc1.LoginName, pcIntervalStart.AddDays(2), 0, 0));
      testRecs.Add(new SongDownloadsTestRecord("3", 3, 300, 100, groupAcc2.LoginName, pcIntervalStart.AddDays(9), 1, 200));
      testRecs.Add(new SongDownloadsTestRecord("4", 4, 400, 100, groupAcc2.LoginName, pcIntervalStart.AddDays(10), 4, 600));
      testRecs.Add(new SongDownloadsTestRecord("5", 2, 200, 100, groupAcc1.LoginName, pcIntervalStart.AddDays(11), 5, 600));
      testRecs.Add(new SongDownloadsTestRecord("6", 2, 200, 100, groupAcc2.LoginName, pcIntervalStart.AddDays(19), 8, 1100));
      testRecs.Add(new SongDownloadsTestRecord("7", 8, 800, 100, groupAcc1.LoginName, pcIntervalStart.AddDays(20), 7, 900));
      testRecs.Add(new SongDownloadsTestRecord("8", 2, 200, 100, groupAcc1.LoginName, pcIntervalStart.AddDays(22), 15, 1800));
      testRecs.Add(new SongDownloadsTestRecord("9", 2, 200, 100, groupAcc2.LoginName, pcIntervalStart.AddDays(26), 10, 1400));
      MeterSongDownloadsTestUsage(testRecs);
      // Trigger 2nd pass processing for this pi template and interval.
      PC.IMTAggregateCharge agg = (PC.IMTAggregateCharge) ((PC.IMTPriceableItem)mSongDownloadsBCR.GetPriceableItems()[1]).GetTemplate();
      agg.Rate(interval, 1000);
      ValidateAggregateResults(testRecs, interval, Utils.GetTestId());
    }
    [Test]
    public void TestMonthlyTwelfthOfMonthIndividualCountersPaymentRedirectionSongDownloadsBCR()
    {
      // Test that individual counters use payer cycle to resolve BCR.
      Utils.BillingCycle unusedBillingCycle = new Utils.BillingCycle (Utils.CycleType.WEEKLY, 1);
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 12);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);
      // Create the accounts with the billing cycle, one for group one for individual.
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("SUB_{0}{1}",
                                              unusedBillingCycle.ToString(),
                                              Utils.GetTestId());
      string payerAccountName = String.Format("PAY_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName, unusedBillingCycle));
      subs.Add(new Utils.AccountParameters(payerAccountName, accountBillingCycle));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = mAccCatalog.GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC indivAcc = mAccCatalog.GetAccountByName(indivAccountName, "mt", MetraTime.Now);      
      YAAC.IMTYAAC payerAcc = mAccCatalog.GetAccountByName(payerAccountName, "mt", MetraTime.Now);      
      int interval = GetCurrentOpenInterval(payerAcc);
      // Set up payer to pay for individual account.
      YAAC.IMTPaymentMgr pmt = new YAAC.MTPaymentMgrClass();
      pmt.Initialize((YAAC.IMTSessionContext) mSUCtx,true,(YAAC.MTYAAC)payerAcc);
      pmt.PayForAccount(indivAcc.ID, pcIntervalStart, DateTime.Parse("1/1/2038"));

      // Subscribe individually and group at start of current interval.
      System.Collections.Generic.List<YAAC.IMTYAAC> accs = new System.Collections.Generic.List<YAAC.IMTYAAC>();
      CreateIndividualSubscription(indivAcc, mSongDownloadsBCR, pcIntervalStart, DateTime.Parse("1/1/2038"));        
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The aggregate instance is monthly ending on the 12th (BCR).
      System.Collections.Generic.List<SongDownloadsTestRecord> testRecs = 
      new System.Collections.Generic.List<SongDownloadsTestRecord>();
      testRecs.Add(new SongDownloadsTestRecord("1", 1, 100, 100, indivAcc.LoginName, pcIntervalStart.AddDays(1), 0, 0));
      testRecs.Add(new SongDownloadsTestRecord("2", 5, 500, 100, indivAcc.LoginName, pcIntervalStart.AddDays(2), 1, 200));
      testRecs.Add(new SongDownloadsTestRecord("3", 3, 300, 100, indivAcc.LoginName, pcIntervalStart.AddDays(9), 6, 800));
      testRecs.Add(new SongDownloadsTestRecord("4", 4, 400, 100, indivAcc.LoginName, pcIntervalStart.AddDays(10), 9, 1200));
      testRecs.Add(new SongDownloadsTestRecord("5", 2, 200, 100, indivAcc.LoginName, pcIntervalStart.AddDays(11), 13, 1700));
      testRecs.Add(new SongDownloadsTestRecord("6", 2, 200, 100, indivAcc.LoginName, pcIntervalStart.AddDays(19), 15, 2000));
      testRecs.Add(new SongDownloadsTestRecord("7", 8, 800, 100, indivAcc.LoginName, pcIntervalStart.AddDays(20), 17, 2300));
      testRecs.Add(new SongDownloadsTestRecord("8", 2, 200, 100, indivAcc.LoginName, pcIntervalStart.AddDays(22), 25, 3200));
      testRecs.Add(new SongDownloadsTestRecord("9", 2, 200, 100, indivAcc.LoginName, pcIntervalStart.AddDays(26), 27, 3500));
      MeterSongDownloadsTestUsage(testRecs);
      // Trigger 2nd pass processing for this pi template and interval.
      PC.IMTAggregateCharge agg = (PC.IMTAggregateCharge) ((PC.IMTPriceableItem)mSongDownloadsBCR.GetPriceableItems()[1]).GetTemplate();
      agg.Rate(interval, 1000);
      ValidateAggregateResults(testRecs, interval, Utils.GetTestId());
    }
    [Test]
    public void TestMonthly13thNoSubscriptionSongSession()
    {
      // Take an interval with no aggregate usage and invoke the adapter code.
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 13);
      // Create the accounts with the billing cycle, one for group one for individual.
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("SUB_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      Utils.GenerateSharedPricelist(String.Format("PL_{0}{1}", 
                                                  accountBillingCycle.ToString(),
                                                  Utils.GetTestId()));
      subs.Add(new Utils.AccountParameters(indivAccountName, 
                                           accountBillingCycle,
                                           String.Format("PL_{0}{1}", 
                                                         accountBillingCycle.ToString(),
                                                         Utils.GetTestId())));
      Utils.CreateSubscriberAccounts(mCorporate, subs, MetraTime.Now);
      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = mAccCatalog.GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC indivAcc = mAccCatalog.GetAccountByName(indivAccountName, "mt", MetraTime.Now);      
      int interval = GetCurrentOpenInterval(indivAcc);
      // Don't create any subscription
      // Meter usage.
      MeterSongSessionTestUsage(indivAcc, 10);
      ValidateFirstPassCount(mSongSession, indivAcc, 10);
      // Trigger 2nd pass processing for this pi template and interval.
      PC.IMTAggregateCharge agg = (PC.IMTAggregateCharge) ((PC.IMTPriceableItem)mSongSession.GetPriceableItems()[1]).GetTemplate();
      agg.Rate(interval, 1000);
      ValidateSecondPassCount(mSongSession, indivAcc, 10);      
    }

    [Test]
    public void TestMonthly14thNoSubscriptionSongDownloads()
    {
      // Take an interval with no aggregate usage and invoke the adapter code.
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 14);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);

      // Create the accounts with the billing cycle, one for group one for individual.
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("SUB_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      string pricelistName=String.Format("PL_{0}{1}", 
                                         accountBillingCycle.ToString(),
                                         Utils.GetTestId());
      Utils.GenerateSharedPricelist(pricelistName);
      subs.Add(new Utils.AccountParameters(indivAccountName, 
                                           accountBillingCycle,
                                           pricelistName));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);
      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = mAccCatalog.GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC indivAcc = mAccCatalog.GetAccountByName(indivAccountName, "mt", MetraTime.Now);      
      int interval;
      DateTime intervalStart;
      DateTime intervalEnd;
      GetCurrentOpenInterval(indivAcc, out interval, out intervalStart, out intervalEnd);
      // I suppose it is possible for time to change so that this isn't true, but the test probably
      // won't work.
      Assert.AreEqual(interval,pcInterval);
      // Don't create any subscription
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The aggregate template is weekly ending on Sunday.
      // We start our usage on the first Saturday in the month.
      DateTime firstFriday = intervalStart.AddDays((12 - (int) intervalStart.DayOfWeek) % 7);
      System.Collections.Generic.List<SongDownloadsTestRecord> testRecs = 
      new System.Collections.Generic.List<SongDownloadsTestRecord>();
      testRecs.Add(new SongDownloadsTestRecord("1", 1, 100, 100, indivAcc.LoginName, firstFriday.AddDays(1), 0, 0));
      testRecs.Add(new SongDownloadsTestRecord("2", 5, 500, 100, indivAcc.LoginName, firstFriday.AddDays(2), 1, 200));
      testRecs.Add(new SongDownloadsTestRecord("3", 4, 400, 100, indivAcc.LoginName, firstFriday.AddDays(4), 3, 400));
      testRecs.Add(new SongDownloadsTestRecord("4", 8, 800, 100, indivAcc.LoginName, firstFriday.AddDays(7), 11, 1500));
      testRecs.Add(new SongDownloadsTestRecord("5", 2, 200, 100, indivAcc.LoginName, firstFriday.AddDays(5), 7, 900));
      testRecs.Add(new SongDownloadsTestRecord("6", 2, 200, 100, indivAcc.LoginName, firstFriday.AddDays(6), 9, 1200));
      testRecs.Add(new SongDownloadsTestRecord("7", 3, 300, 100, indivAcc.LoginName, firstFriday.AddDays(3), 0, 0));
      MeterSongDownloadsTestUsage(testRecs);
      ValidateFirstPassCount(mSongDownloads, indivAcc, 7);
      // Trigger 2nd pass processing for this pi template and interval.
      PC.IMTAggregateCharge agg = (PC.IMTAggregateCharge) ((PC.IMTPriceableItem)mSongDownloads.GetPriceableItems()[1]).GetTemplate();
      agg.Rate(interval, 1000);
      ValidateSecondPassCount(mSongDownloads, indivAcc, 7);      
      ValidateAggregateResults(testRecs, interval, Utils.GetTestId());
    }
    [Test]
    public void TestAggregateAdapterWithNoUsage()
    {
      // Take an interval with no aggregate usage and invoke the adapter code.
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 15);
      // Create the accounts with the billing cycle, one for group one for individual.
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("SUB_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle));
      Utils.CreateSubscriberAccounts(mCorporate, subs, MetraTime.Now);
      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = mAccCatalog.GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC indivAcc = mAccCatalog.GetAccountByName(indivAccountName, "mt", MetraTime.Now);      
      int interval = GetCurrentOpenInterval(indivAcc);
      // Subscribe individually and group.
      CreateIndividualSubscription(indivAcc, mSongDownloads, MetraTime.Now, DateTime.Parse("1/1/2038"));        
      // Don't Meter usage.
      ValidateFirstPassCount(mSongDownloads, indivAcc, 0);
      // Trigger 2nd pass processing for this pi template and interval.
      PC.IMTAggregateCharge agg = (PC.IMTAggregateCharge) ((PC.IMTPriceableItem)mSongDownloads.GetPriceableItems()[1]).GetTemplate();
      agg.Rate(interval, 1000);
      ValidateSecondPassCount(mSongDownloads, indivAcc, 0);
      
    }


    [Test]
    public void TestNoSubscriptionSmokeAggregateDecProp1()
    {
      // Take an interval with no aggregate usage and invoke the adapter code.
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.ANNUAL, 1);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);

      // Create the accounts with the billing cycle, one for group one for individual.
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("SUB_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName, 
                                           accountBillingCycle));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);
      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = mAccCatalog.GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC indivAcc = mAccCatalog.GetAccountByName(indivAccountName, "mt", MetraTime.Now);      
      int interval;
      DateTime intervalStart;
      DateTime intervalEnd;
      GetCurrentOpenInterval(indivAcc, out interval, out intervalStart, out intervalEnd);
      // I suppose it is possible for time to change so that this isn't true, but the test probably
      // won't work.
      Assert.AreEqual(interval,pcInterval);
      // Don't create any subscription
      // Meter usage 
      // Test Service Format:
      // Description AccountName Time Units DecProp1
      // Smoke Format:
      // Description AccountName EventTimestamp TotalAmount
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The aggregate template is weekly ending on Sunday.
      // We start our usage on the first Saturday in the cycle.
      DateTime firstFriday = intervalStart.AddDays((12 - (int) intervalStart.DayOfWeek) % 7);
      System.Collections.Generic.List<TestServiceTestRecord> testServiceRecs = 
      new System.Collections.Generic.List<TestServiceTestRecord>();
      System.Collections.Generic.List<SmokeAggregateTestRecord> smokeRecs = 
      new System.Collections.Generic.List<SmokeAggregateTestRecord>();
      testServiceRecs.Add(new TestServiceTestRecord("1", indivAcc.LoginName, firstFriday.AddDays(0), 0, 1));
      testServiceRecs.Add(new TestServiceTestRecord("2", indivAcc.LoginName, firstFriday.AddDays(1), 0, 3));
      smokeRecs.Add(new SmokeAggregateTestRecord("3", indivAcc.LoginName, firstFriday.AddDays(2), 4));
      testServiceRecs.Add(new TestServiceTestRecord("4", indivAcc.LoginName, firstFriday.AddDays(3), 0, 1));
      testServiceRecs.Add(new TestServiceTestRecord("5", indivAcc.LoginName, firstFriday.AddDays(4), 0, 3));
      testServiceRecs.Add(new TestServiceTestRecord("6", indivAcc.LoginName, firstFriday.AddDays(5), 0, 5));
      smokeRecs.Add(new SmokeAggregateTestRecord("7", indivAcc.LoginName, firstFriday.AddDays(6), 9));
      MeterTestServiceTestUsage(testServiceRecs);
      MeterSmokeAggregateDecProp1TestUsage(smokeRecs);
      // Trigger 2nd pass processing for this pi template and interval.
      PC.IMTAggregateCharge agg = (PC.IMTAggregateCharge) ((PC.IMTPriceableItem)mSmokeAggregateDecProp1.GetPriceableItems()[1]).GetTemplate();
      agg.Rate(interval, 1000);
      ValidateAggregateResults(smokeRecs, interval, Utils.GetTestId());
    }
    [Test]
    public void TestNoSubscriptionSmokeAggregateCount()
    {
      // Take an interval with no aggregate usage and invoke the adapter code.
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.ANNUAL, 2);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);

      // Create the accounts with the billing cycle, one for group one for individual.
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("SUB_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName, 
                                           accountBillingCycle));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);
      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = mAccCatalog.GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC indivAcc = mAccCatalog.GetAccountByName(indivAccountName, "mt", MetraTime.Now);      
      int interval;
      DateTime intervalStart;
      DateTime intervalEnd;
      GetCurrentOpenInterval(indivAcc, out interval, out intervalStart, out intervalEnd);
      // I suppose it is possible for time to change so that this isn't true, but the test probably
      // won't work.
      Assert.AreEqual(interval,pcInterval);
      // Don't create any subscription
      // Meter usage 
      // Test Service Format:
      // Description AccountName Time Units DecProp1
      // Smoke Format:
      // Description AccountName EventTimestamp TotalAmount
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The aggregate template is weekly ending on Sunday.
      // We start our usage on the first Saturday in the cycle.
      DateTime firstFriday = intervalStart.AddDays((12 - (int) intervalStart.DayOfWeek) % 7);
      System.Collections.Generic.List<TestServiceTestRecord> testServiceRecs = 
      new System.Collections.Generic.List<TestServiceTestRecord>();
      System.Collections.Generic.List<SmokeAggregateCountTestRecord> smokeRecs = 
      new System.Collections.Generic.List<SmokeAggregateCountTestRecord>();
      testServiceRecs.Add(new TestServiceTestRecord("1", indivAcc.LoginName, firstFriday.AddDays(0), 0, 1));
      testServiceRecs.Add(new TestServiceTestRecord("2", indivAcc.LoginName, firstFriday.AddDays(1), 0, 3));
      smokeRecs.Add(new SmokeAggregateCountTestRecord("3", indivAcc.LoginName, firstFriday.AddDays(2), 2));
      testServiceRecs.Add(new TestServiceTestRecord("4", indivAcc.LoginName, firstFriday.AddDays(3), 0, 1));
      testServiceRecs.Add(new TestServiceTestRecord("5", indivAcc.LoginName, firstFriday.AddDays(4), 0, 3));
      testServiceRecs.Add(new TestServiceTestRecord("6", indivAcc.LoginName, firstFriday.AddDays(5), 0, 5));
      smokeRecs.Add(new SmokeAggregateCountTestRecord("7", indivAcc.LoginName, firstFriday.AddDays(6), 3));
      MeterTestServiceTestUsage(testServiceRecs);
      MeterSmokeAggregateCountTestUsage(smokeRecs);
      // Trigger 2nd pass processing for this pi template and interval.
      PC.IMTAggregateCharge agg = (PC.IMTAggregateCharge) ((PC.IMTPriceableItem)mSmokeAggregateCount.GetPriceableItems()[1]).GetTemplate();
      agg.Rate(interval, 1000);
      ValidateAggregateResults(smokeRecs, interval, Utils.GetTestId());
    }
    [Test]
    public void TestMonthlyIndividualAndGroupSubscriptionWithSharedCountersSongDownloadsAdapterInvocation()
    {
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 17);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);
      // Create the accounts with the billing cycle, one for group one for individual.
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("SUB_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      string groupAccountName1 = String.Format("GSUB1_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      string groupAccountName2 = String.Format("GSUB2_{0}{1}",
                                               accountBillingCycle.ToString(),
                                               Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle));
      subs.Add(new Utils.AccountParameters(groupAccountName1, accountBillingCycle));
      subs.Add(new Utils.AccountParameters(groupAccountName2, accountBillingCycle));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = mAccCatalog.GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC indivAcc = mAccCatalog.GetAccountByName(indivAccountName, "mt", MetraTime.Now);      
      YAAC.IMTYAAC groupAcc1 = mAccCatalog.GetAccountByName(groupAccountName1, "mt", MetraTime.Now);      
      YAAC.IMTYAAC groupAcc2 = mAccCatalog.GetAccountByName(groupAccountName2, "mt", MetraTime.Now);      
      int interval = GetCurrentOpenInterval(indivAcc);
      // Subscribe individually and group at start of current interval.
      System.Collections.Generic.List<YAAC.IMTYAAC> accs = new System.Collections.Generic.List<YAAC.IMTYAAC>();
      accs.Add(groupAcc1);
      accs.Add(groupAcc2);
      CreateGroupSubscription(mSongDownloads, corporateAcc, accs, accountBillingCycle, pcIntervalStart, DateTime.Parse("1/1/2038"), true);
      CreateIndividualSubscription(indivAcc, mSongDownloads, pcIntervalStart, DateTime.Parse("1/1/2038"));        
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The aggregate instance is monthly ending on the 17th.
      System.Collections.Generic.List<SongDownloadsTestRecord> testRecs = 
      new System.Collections.Generic.List<SongDownloadsTestRecord>();
      testRecs.Add(new SongDownloadsTestRecord("1", 1, 100, 100, indivAcc.LoginName, pcIntervalStart.AddDays(1), 0, 0));
      testRecs.Add(new SongDownloadsTestRecord("2", 3, 300, 100, groupAcc2.LoginName, pcIntervalStart.AddDays(9), 5, 600));
      testRecs.Add(new SongDownloadsTestRecord("3", 2, 200, 100, groupAcc1.LoginName, pcIntervalStart.AddDays(11), 8, 1000));
      testRecs.Add(new SongDownloadsTestRecord("4", 2, 200, 100, groupAcc2.LoginName, pcIntervalStart.AddDays(19), 10, 1300));
      testRecs.Add(new SongDownloadsTestRecord("5", 2, 200, 100, groupAcc1.LoginName, pcIntervalStart.AddDays(22), 12, 1600));
      testRecs.Add(new SongDownloadsTestRecord("6", 2, 200, 100, groupAcc2.LoginName, pcIntervalStart.AddDays(26), 14, 1900));
      testRecs.Add(new SongDownloadsTestRecord("7", 8, 800, 100, indivAcc.LoginName, pcIntervalStart.AddDays(20), 5, 700));
      testRecs.Add(new SongDownloadsTestRecord("8", 4, 400, 100, indivAcc.LoginName, pcIntervalStart.AddDays(10), 1, 200));
      testRecs.Add(new SongDownloadsTestRecord("9", 5, 500, 100, groupAcc1.LoginName, pcIntervalStart.AddDays(2), 0, 0));
      MeterSongDownloadsTestUsage(testRecs);
      // Trigger 2nd pass processing for this pi template and interval.
      System.Collections.Generic.List<YAAC.IMTYAAC> accounts = 
      new System.Collections.Generic.List<YAAC.IMTYAAC>();
      accounts.Add(indivAcc);
      accounts.Add(groupAcc1);
      accounts.Add(groupAcc2);
      RunAggregateAdapterOneBillingGroup(accounts, interval);
      ValidateAggregateResults(testRecs, interval, Utils.GetTestId());
    }
    [Test]
    public void TestMonthlyGroupSubscriptionWithSharedCountersMultipleBillgroupsSongDownloads()
    {
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 18);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      // TODO: make sure that this all works when run on the 8th of the month!
      accountBillingCycle.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);
      // Create the accounts with the billing cycle, one for group one for individual.
      ArrayList subs = new ArrayList();
      string groupAccountName1 = String.Format("GSUB1_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      string groupAccountName2 = String.Format("GSUB2_{0}{1}",
                                               accountBillingCycle.ToString(),
                                               Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(groupAccountName1, accountBillingCycle));
      subs.Add(new Utils.AccountParameters(groupAccountName2, accountBillingCycle));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = mAccCatalog.GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC groupAcc1 = mAccCatalog.GetAccountByName(groupAccountName1, "mt", MetraTime.Now);      
      YAAC.IMTYAAC groupAcc2 = mAccCatalog.GetAccountByName(groupAccountName2, "mt", MetraTime.Now);      
      int interval = GetCurrentOpenInterval(groupAcc1);
      // Subscribe group at start of current interval.
      System.Collections.Generic.List<YAAC.IMTYAAC> accs = new System.Collections.Generic.List<YAAC.IMTYAAC>();
      accs.Add(groupAcc1);
      accs.Add(groupAcc2);
      CreateGroupSubscription(mSongDownloads, corporateAcc, accs, accountBillingCycle, pcIntervalStart, DateTime.Parse("1/1/2038"), true);
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The aggregate instance is monthly ending on the 17th (29/30 days from when we start metering).
      // We are testing for two different things.  Firstly that the shared counter works and secondly
      // that groupAcc1's usage always appears before groupAcc2's usage in aggregate order.
      System.Collections.Generic.List<SongDownloadsTestRecord> testRecs = 
      new System.Collections.Generic.List<SongDownloadsTestRecord>();
      testRecs.Add(new SongDownloadsTestRecord("1", 1, 100, 100, groupAcc2.LoginName, pcIntervalStart.AddDays(1), 0, 0));
      testRecs.Add(new SongDownloadsTestRecord("2", 5, 500, 100, groupAcc1.LoginName, pcIntervalStart.AddDays(2), 1, 200));
      testRecs.Add(new SongDownloadsTestRecord("3", 3, 300, 100, groupAcc2.LoginName, pcIntervalStart.AddDays(3), 6, 800));
      testRecs.Add(new SongDownloadsTestRecord("4", 4, 400, 100, groupAcc1.LoginName, pcIntervalStart.AddDays(4), 9, 1200));
      testRecs.Add(new SongDownloadsTestRecord("5", 2, 200, 100, groupAcc1.LoginName, pcIntervalStart.AddDays(7), 13, 1700));
      testRecs.Add(new SongDownloadsTestRecord("6", 2, 200, 100, groupAcc2.LoginName, pcIntervalStart.AddDays(8), 15, 2000));
      testRecs.Add(new SongDownloadsTestRecord("7", 8, 800, 100, groupAcc2.LoginName, pcIntervalStart.AddDays(9), 17, 2300));
      testRecs.Add(new SongDownloadsTestRecord("8", 2, 200, 100, groupAcc1.LoginName, pcIntervalStart.AddDays(10), 25, 3200));
      testRecs.Add(new SongDownloadsTestRecord("9", 2, 200, 100, groupAcc2.LoginName, pcIntervalStart.AddDays(11), 27, 3500));
      MeterSongDownloadsTestUsage(testRecs);
      // Trigger 2nd pass processing for this pi template and interval.  Put accounts on different bill groups.
      System.Collections.Generic.List<System.Collections.Generic.List<YAAC.IMTYAAC> > accounts = 
      new System.Collections.Generic.List<System.Collections.Generic.List<YAAC.IMTYAAC> >();
      System.Collections.Generic.List<YAAC.IMTYAAC> bg = new System.Collections.Generic.List<YAAC.IMTYAAC>();
      bg.Add(groupAcc1);
      accounts.Add(bg);
      bg = new System.Collections.Generic.List<YAAC.IMTYAAC>();
      bg.Add(groupAcc2);
      accounts.Add(bg);
      RunAggregateAdapterWithBillingGroups(accounts, interval);

      ValidateAggregateResults(testRecs, interval, Utils.GetTestId());
    }
  }
}
