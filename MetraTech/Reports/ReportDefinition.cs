using System;
using System.Runtime.InteropServices;
using MetraTech;
using MetraTech.Xml;
using MetraTech.UsageServer;

namespace MetraTech.Reports
{
  /// <summary>
  /// Report Definition - Property Bag that stores contents of a <Report/> entry in ReportList.xml file
  /// </summary>
  
	
  [Guid("b27649f3-929f-4295-9147-5caaaad76636")]
  public interface IReportDefinition
  {
		string GroupName										{ get; }
		string UniqueName										{ get; }
		string SourceFile										{ get; }
		string DisplayName										{ get; }
		string InputQuery										{ get; }
		string SampleModeInputQuery					{ get; }
    RecurringEventType ReportRecurringEventType { get; }
		bool OverwriteReportTemplateDestination	{ get; }
		bool OverwriteReportTemplateFormat				{ get; }
		bool OverwriteReportOriginalDataSource				{ get; }
		
		
  };

	[Guid("7203dd9e-d84b-4c3a-ac44-8900a8f868bc")]
	public class ReportDefinition : IReportDefinition
	{
		private string mUniqueName;
		private string mGroupName;
		private string mSourceFile;
		private string mDisplayName;
		private string mInputQuery;
		private string mSampleModeInputQuery;
		private RecurringEventType mRecurringEventType;
		private bool mOverwriteReportTemplateDestination;
		private bool mOverwriteReportTemplateFormat;
		private bool mOverwriteReportOriginalDataSource;
		
		
		public string GroupName					{ get { return mGroupName; } set { mGroupName = value; }}
		public string UniqueName				{ get { return mUniqueName; } set { mUniqueName = value; }}
		public string SourceFile				{ get { return mSourceFile; } set { mSourceFile = value; }}
		public string DisplayName				{ get { return mDisplayName;} set { mDisplayName = value; }}
		public string InputQuery				{get { return mInputQuery; }	set { mInputQuery = value; }}
		public string SampleModeInputQuery		
		{ 
			get { return mSampleModeInputQuery; }
			set { mSampleModeInputQuery = value; }
		}
		public RecurringEventType ReportRecurringEventType		
		{ 
			get { return mRecurringEventType; }
			set { mRecurringEventType = value; }
		}
		public bool OverwriteReportTemplateDestination	
		{ 
			get { return mOverwriteReportTemplateDestination; }
			set { mOverwriteReportTemplateDestination = value; }
		}
		public bool OverwriteReportTemplateFormat				
		{ 
			get { return mOverwriteReportTemplateFormat; }
			set { mOverwriteReportTemplateFormat = value; }
		}
		public bool OverwriteReportOriginalDataSource				
		{ 
			get { return mOverwriteReportOriginalDataSource; }
			set { mOverwriteReportOriginalDataSource = value; }
		}
		//internal constructor - only ReportConfiguration object creates these
		internal ReportDefinition(){}
		
			
	}

}