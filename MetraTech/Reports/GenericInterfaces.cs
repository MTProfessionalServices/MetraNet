using System;
using System.Collections;
using System.Runtime.InteropServices;
using MetraTech;
using MetraTech.Interop.Rowset;
using MetraTech.UsageServer;

namespace MetraTech.Reports
{
	/// <summary>
	/// Indicates to DeleteInstances method, which instances should be removed
	/// Reporting provider should map them internally to provider specific enumerations
	/// </summary>
	[Guid("4e87e9af-977a-4df6-8255-ad2578acb446")]
	public enum InstanceExecutionStatus
	{
		Pending, Failed, Succeeded, All
	}
	/// <summary>
	/// This interface is used by BeginGenerateReports and CompleteGenerateReports
	/// usage server adapters. MetraTech provides out of the box Crystal Enterprise reporting provider implementation.
	/// (MetraTech.Reports.Crystal.CEReportManager). If other than Crystal reporting provider is intended to be used IReportManager,
	/// IReport, IReportParameter interfaces have to be implemented, and an appropriate provider class ProgID has to be set in 
	/// adapter configuration.
	/// Out of the box it points to CEReportManager class:
	/// <code>
	///			<ReportGeneratorProgID>MetraTech.Reports.Crystal.CEReportManager, MetraTech.Reports.Crystal</ReportGeneratorProgID>
	///	</code>
	/// </summary>
	
	[Guid("1ec4ce8a-e806-44e2-900a-af68b61d1015")]
	public interface IReportManager : IDisposable
	{
		/// <summary>
		/// Return the name for reporting provider for logging purposes
		/// <summary>
		string ProviderName{get;}

		/// <summary>
		/// Implement logic to authenticate to a reporting provider server (if needed). After a user is authenticated, 
		/// logon state should be stored in  ReportManager object state, so that it could be used in consequent method calls.
		/// This method is a first method to be called by reporting adapters. Logon information is read by adapters from 
		/// <code>extensions\Reporting\config\ServerAccess\servers.xml</code> file
		/// <summary>
		void LoginToReportingServer(string aServerName, string aUserName, string aPassword);

		/// <summary>
		/// Set parameters for reporting database
		/// <summary>
		void SetReportingDatabase(string aServerName, 
															string aDatabaseName, 
															string aDatabaseOwner,
															string aDatabaseUserName,
															string aDatabasePassword);
		
		
		/// <summary>s
		/// Add a report for processing before calling Schedule method
		/// Template name has to be unique. Crystal Enpterprise already enforces it.
		/// <summary>
        /// g. cieplik 8/25/2009 CORE-1472 use apsDatabaseName to overload with SI_NAME

		void AddReportForProcessing(
			string aTemplateName,
			int aRunID,
			int aBillGroupID,
			int aAccountID,
			string aRecordSelectionFormula, 
			string aGroupSelectionFormula, 
			IDictionary aReportParameters, 
			string aInstanceFileName,
			bool aOverwriteTemplateDestination, 
			bool aOverwriteTemplateFormat,
			bool aOverwriteReportOriginalDataSource,
            string apsdatabasename);       
		
		/// <summary>
		/// Perform actions necessary to begin report generation by a reporting provider.
		/// Since Crystal Enterprise provider only support asynchronous report generation,
		/// aRunSynchronously flag is ignored by CEReportClass
		/// <summary>
		void GenerateReports(bool aRunSynchronously);

		/// <summary>
		/// Get results of report execution by given Template Name and RunID. The system will not call this method 
		/// if reports were generated synchronously (not supported in CE provider)
		///  
		/// <summary>
		void GetExecutionResults(
				string aTemplateName, 
				int aRunID,
				int aAccountID,
				out int aNumTotalInstances, 
				out int aNumFailedInstances, 
				out int aNumSucceededInstances,
				out int aNumOutstaningInstances);

		/// <summary>
		/// Return the rowset with errors from a particular run by template name and Run ID.
		///  
		/// <summary>
		IMTRowSet GetErrors(string aTemplateName, int aRunID, int aAccountID);


		/// <summary>
		/// Removes instances by specified run id and a unique template name. 
		/// This method is called by CompleteGenerateReports adapters' Reverse() method.
		/// This method executes synchronously
		/// <summary>
		void DeleteReportInstances(string aTemplateName, int aRunID, int aBillGroupID, int aAccountID, InstanceExecutionStatus aWhichOnesToDelete);

		
		/// <summary>
		/// This method is called by CompleteGenerateReports adapter, if failed
		/// instances threshold is > 0 and it has been reached. CrystalEnterprise provider
		/// implementation of this method pauses all the instances of this Run ID that haven't been
		/// processed yet.
		/// <summary>
		void ProcessReachedFailedReportThreshold(int aRunID, int aAccountID);
		
		/// <summary>
		/// Do all necessary connection cleanup. This method is called from Shutdown() method in reporting adapters.
		/// <summary>
		void Disconnect();

		/// <summary>
		/// Sets MetraTech specific logger object. Report provider should implement all the logging
		/// <summary>
		
		ILogger LoggerObject{get;set;}

		/// <summary>
		/// Sets MetraTech IRecurringEventRunContext object. Report provider can use it for logging
		/// of adapter run information into usage server logs
		/// <summary>
		
		IRecurringEventRunContext RecurringEventRunContext{get;set;}
	}

	
}
