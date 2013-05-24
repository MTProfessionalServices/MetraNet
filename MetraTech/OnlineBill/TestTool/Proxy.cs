namespace MetraTech.OnlineBill
{
	using MetraTech.Interop.MTHierarchyReports;
	using MetraTech.Xml;
	using System;
	using System.Collections;
	using System.Xml;
	using MetraTech.Interop.COMDBObjects;

	public class ProxyReportManager : IReportManager
	{
		public ProxyReportManager()
		{
			// TODO: initialize other currencies?  how do we know which ones?
			mLocaleTranslator.Init("US");
		}

		private IMPSReportInfo mReportInfo = null;
		public IMPSReportInfo ReportInfo
		{
			get{return mReportInfo;}
		}

		public void Initialize(string path)
		{
		}

		public ITimeSlice TimeSlice
		{
			get
			{ return mTimeSlice; }
			set
			{ mTimeSlice = value; }
		}

		public int LanguageID
		{
			get
			{ return mLanguageID; }
			set
			{ mLanguageID = value; }
		}

		public Level Root
		{
			get
			{ return mRoot; }
		}

		public MPS_VIEW_TYPE ViewType
		{
			get
			{ return mViewType; }
		}

		public bool ShowSecondPass
		{
			get
			{ return mShowSecondPass; }
		}

		public bool IsEstimate
		{
			get
			{ return mIsEstimate; }
		}

		public void OpenLevelByID(string id)
		{
			string xml = mHelper.GetReportLevelAsXML(id);

			MTXmlDocument xmldoc = new MTXmlDocument();
			xmldoc.LoadXml(xml);
			XmlNode levelNode = xmldoc.SelectSingleNode("level");

			Level level = (Level) mCachedLevels[id];
			ParseLevel(levelNode, level);
			level.IsOpen = true;
		}

		public void CloseLevelByID(string id)
		{
			Level level = (Level) mCachedLevels[id];
			level.IsOpen = false;
			level.InitializeSubLevels(new ArrayList());
		}

		public void OpenLevel(Level node)
		{
			string xml = mHelper.GetReportLevelAsXML(node.CacheID);

			MTXmlDocument xmldoc = new MTXmlDocument();
			xmldoc.LoadXml(xml);
			XmlNode levelNode = xmldoc.SelectSingleNode("level");

			Level level = node;
			ParseLevel(levelNode, level);
			level.IsOpen = true;
		}

		public void CloseLevel(Level node)
		{
			node.IsOpen = false;
			node.InitializeSubLevels(new ArrayList());
		}

		public ITimeSlice GetCombinedTimeSlice(ITimeSlice timeSliceIn)
		{
			if (timeSliceIn != null)
			{
				IIntersectionTimeSlice composite = new IntersectionTimeSlice();
				composite.LHS = timeSliceIn;
				composite.RHS = mTimeSlice;
				return composite;
			}
			else
				return mTimeSlice;
		}


		private string LocalizeCurrency(decimal value, string currency)
		{
			// TODO: handle ZZZ currency?
			return mLocaleTranslator.GetCurrency(value, currency);
		}

		// TODO: charges aren't adjusted.  is that OK?
		private void ParseCharge(XmlNode node, Charge charge)
		{
			charge.ID = MTXmlDocument.GetNodeValueAsString(node, "id");
			charge.Amount = LocalizeCurrency(MTXmlDocument.GetNodeValueAsDecimal(node, "amount"), MTXmlDocument.GetNodeValueAsString(node, "@uom"));
			charge.Currency = MTXmlDocument.GetNodeValueAsString(node, "@uom");
			// TODO: children?

			// TODO: internal_id
			// TODO: isaggregate
		}

		private void ParsePO(XmlNode node, ProductOffering po)
		{
			po.ID = MTXmlDocument.GetNodeValueAsString(node, "id");
			po.Amount = "TBD";

			// TODO: children?

			// TODO: internal_id
			// TODO: isaggregate

			ArrayList charges = new ArrayList();
			foreach (XmlNode chargeNode in node.SelectNodes("pi"))
			{
        Charge charge = new Charge();
        ParseCharge(chargeNode, charge);
				po.AddCharge(charge);
      }

		}

		private void ParseLevel(XmlNode node, Level level)
		{
			level.CacheID = MTXmlDocument.GetNodeValueAsString(node, "@cacheID");
			mCachedLevels[level.CacheID] = level;

			level.ID = MTXmlDocument.GetNodeValueAsString(node, "id", "");
			level.Amount = LocalizeCurrency(MTXmlDocument.GetNodeValueAsDecimal(node, "amount"),
																			MTXmlDocument.GetNodeValueAsString(node, "amount/@uom"));
			level.Currency = MTXmlDocument.GetNodeValueAsString(node, "amount/@uom");
			level.NumPreBillAdjustments = MTXmlDocument.GetNodeValueAsInt(node, "numprebilladjustments");
			level.NumPostBillAdjustments = MTXmlDocument.GetNodeValueAsInt(node, "numpostbilladjustments");
			level.PreBillAdjustmentAmount = LocalizeCurrency(MTXmlDocument.GetNodeValueAsDecimal(node, "prebilladjustmentamount"),
																											 MTXmlDocument.GetNodeValueAsString(node, "prebilladjustmentamount/@uom"));
			level.PreBillAdjustedAmount = LocalizeCurrency(MTXmlDocument.GetNodeValueAsDecimal(node, "prebilladjustedamount"),
																										 MTXmlDocument.GetNodeValueAsString(node, "prebilladjustedamount/@uom"));
			level.PostBillAdjustmentAmount = LocalizeCurrency(MTXmlDocument.GetNodeValueAsDecimal(node, "postbilladjustmentamount"),
																											 MTXmlDocument.GetNodeValueAsString(node, "postbilladjustmentamount/@uom"));
			// NOTE: wrong currency used here to work around a bug.  postbilladjustedtamount does not have a currency in the XML
			level.PostBillAdjustedAmount = LocalizeCurrency(MTXmlDocument.GetNodeValueAsDecimal(node, "postbilladjustedamount"),
																											MTXmlDocument.GetNodeValueAsString(node, "postbilladjustmentamount/@uom"));
			level.TaxedAmount = LocalizeCurrency(MTXmlDocument.GetNodeValueAsDecimal(node, "amount") + MTXmlDocument.GetNodeValueAsDecimal(node, "tax", 0), MTXmlDocument.GetNodeValueAsString(node, "amount/@uom"));
			
			// TODO: internal ID
			// TODO: account summary slice
			ArrayList charges = new ArrayList();
			foreach (XmlNode chargeNode in node.SelectNodes("charges/pi"))
			{
        Charge charge = new Charge();
        ParseCharge(chargeNode, charge);
				charges.Add(charge);
      }
			level.InitializeCharges(charges);

			ArrayList pos = new ArrayList();
			foreach (XmlNode poNode in node.SelectNodes("charges/po"))
			{
				ProductOffering po = new ProductOffering();
        ParsePO(poNode, po);
				pos.Add(po);
      }

			ArrayList sublevels = new ArrayList();
			foreach (XmlNode sublevelNode in node.SelectNodes("children/level"))
			{
				Level sublevel = new Level();
				ParseLevel(sublevelNode, sublevel);
				sublevels.Add(sublevel);
			}
			level.InitializeSubLevels(sublevels);

			level.InitializeProductOfferings(pos);
		}

		public IReportHelper Helper
		{
			set { mHelper = value; }
		}

		public void InitializeReport(	MetraTech.Interop.MTYAAC.IMTYAAC yaac, ITimeSlice timeSlice, int viewType, bool showSecondPass, bool estimate, IMPSReportInfo reportInfo, int languageID)
		{
			IMPSRenderInfo renderInfo = new MPSRenderInfo();
			// TODO: support account ID override stuff
			renderInfo.AccountID = yaac.AccountID;
			renderInfo.ViewType = (MPS_VIEW_TYPE) viewType;
			renderInfo.TimeSlice = timeSlice;
			renderInfo.LanguageCode = languageID;
			mReportInfo = reportInfo;

			mViewType = (MPS_VIEW_TYPE) viewType;
			mShowSecondPass = showSecondPass;

			renderInfo.Estimate = showSecondPass ? showSecondPass : estimate;

			mIsEstimate = renderInfo.Estimate;

			//IReportHelper helper = new ReportHelper();
			//helper.Initialize(yaac, languageID, 

			mHelper.ReportIndex = reportInfo.Index;

			mHelper.InitializeReport(timeSlice, (short) viewType, showSecondPass, estimate);

			//IHierarchyReportLevel reportLevel = new HierarchyReportLevel();
			//			reportLevel.Init((MPSRenderInfo) renderInfo, (MPSReportInfo) reportInfo);

			//string xml = mHelper.GetReportAsXML();
			string xml = mHelper.GetCacheXML();
			//			string xml = reportLevel.GetReportLevelAsXML(false);
			//Console.WriteLine(xml);

			MTXmlDocument xmldoc = new MTXmlDocument();
			mXml = xml;
			xmldoc.LoadXml(xml);
			XmlNode levelNode = xmldoc.SelectSingleNode("mt_charge_data/level");
			Level level = new Level();
			ParseLevel(levelNode, level);
			mRoot = level;
			mRoot.IsOpen = true;
			// TODO:
			//mRoot.InitializeSubLevels(new ArrayList());
    }

		public string Xml
		{
			get
			{ return mXml; }
		}

		//private bool mSecondPass;
		private MetraTech.Interop.COMDBObjects.ICOMLocaleTranslator mLocaleTranslator = new MetraTech.Interop.COMDBObjects.COMLocaleTranslator();
		private int mLanguageID;
		private MPS_VIEW_TYPE mViewType;
		private bool mShowSecondPass;
		private bool mIsEstimate;
		private ITimeSlice mTimeSlice;
		private Level mRoot;
		private IReportHelper mHelper;
		private Hashtable mCachedLevels = new Hashtable();
		private string mXml;
	}
}

