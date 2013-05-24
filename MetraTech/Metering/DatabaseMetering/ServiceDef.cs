using System;
using System.Diagnostics;
using System.Data;
using System.Xml;
using System.Collections;
using System.Collections.Generic;
using System.Data.OleDb;
using System.Threading;
using System.Text;
using System.Text.RegularExpressions;
using System.IO;
using System.Globalization;

using MetraTech.Interop.COMMeter;

namespace MetraTech.Metering.DatabaseMetering
{
	// SC: This delegate is used to wrap CloseSessionSetThreadProc
	public delegate void AsyncDelegate(object sessionSetData);

	/// <summary>
	/// ServiceDef class is used to meter a particular service
	/// </summary>
	public class ServiceDef
	{
		/// <summary>
		/// Name of the service which is to be metered
		/// </summary>
		string strServiceName;

		/// <summary>
		/// Name of the parent table in the client database 
		/// </summary>
		string strTableName;

		/// <summary>
		/// Optional table hint
		/// </summary>
		string strTableHint = null;

		/// <summary>
		/// If true, indicates service is synchronous
		/// </summary>
		bool bSynchronousService;

		/// <summary>
		/// Data access layer object
		/// </summary>
		DAL objDAL;

		/// <summary>
		/// Array list containing primary keys.Current primary key consists of only one column. 
		/// </summary>
		ArrayList objServicePK;

		/// <summary>
		/// Contains service metering order
		/// </summary>
		ArrayList objServiceOrder;

		/// <summary>
		/// Contains properties of the service
		/// </summary>
		ArrayList objServiceProps;

		/// <summary>
		/// Contains the list of ServiceDef objects of children of a service 
		/// </summary>
		ArrayList objServiceChildren;

		/// <summary>
		/// contains batch information for differen batches  
		/// </summary>
		ArrayList objlistBatchNames;

		/// <summary>
		/// maximum size of session set  
		/// </summary>
		int iServiceMaxSessionSet;

		/// <summary>
		/// PropType object of service criteria
		/// </summary>
		PropType objServiceCriteriaField;

		/// <summary>
		///  PropType object of batch id
		/// </summary>
		PropType objBatchID;

		/// <summary>
		///  PropType object of batch namespace
		/// </summary>
		PropType objBatchNamespace;

		/// <summary>
		/// PropType object of SentTime node
		/// </summary>
		PropType objSentTimeStamp;

		/// <summary>
		/// PropType object of error message node 
		/// </summary>
		PropType objErrorMesg;

		/// <summary>
		/// Currently not used
		/// </summary>
		//bool bBatchIDExists;

		/// <summary>
		/// flag indicating whether to update sent time in the client database 
		/// </summary>
		bool bSentTimeStampExists;

		/// <summary>
		/// flag indicating if there is any error message
		/// </summary>
		bool bErrorMesgExists;

		/// <summary>
		/// Configuration object
		/// </summary>
		ConfigInfo objConfigInfo;

		/// <summary>
		/// Timezone object 
		/// </summary>
		public static ConvertTimeZoneClass objTimezone;

		/// <summary>
		/// Log object used for logging
		/// </summary>
		Log objLog = null;

		/// <summary>
		/// Database date format
		/// </summary>
		const string strDBDateFormat = "MM-dd-yyyy HH:mm:ss";

		/// <summary>
		/// Batch Date Format
		/// </summary>
		const string strBatchDateFormat = "yyyy-MM-dd HH:mm:ss";

		/// <summary>
		/// Used to log the sequence of the session set created.
		/// </summary>
		int iNoSessionSet = 0;

		/// <summary>
		/// Total number if sessions (parent+child) processed. -Used for calculating the TPS.
		/// </summary>
		int iTotalNoSessions = 0;

		/// <summary>
		/// Stores the total, min and max number of session sets for batches.
		/// </summary>
		SavingTheStatistics objSessionSetsForBatch = new SavingTheStatistics(0, int.MaxValue, -1);

		/// <summary>
		/// Stores the total, min and max number of compounds for session sets.
		/// </summary>
		SavingTheStatistics objCompoundsForSessionSet = new SavingTheStatistics(0, int.MaxValue, -1);

		/// <summary>
		/// Stores the total, min and max number of sessions for compound.
		/// </summary>
		ArrayList objSessionsForCompound = new ArrayList();

		const int MT_ERR_SYN_TIMEOUT = -516947931;

		const int MT_ERR_SERVER_BUSY = -516947930;

		const string DBL_FORMAT = "0.0";
		DateTime dtStartMeteringTime;

		bool bIsBatchCriteriaFlag;
		string strBatchDate;
		string statusTableSuffix;// = "_Status";
		string statusTableName;

		// SC: format db date string to msix date
		const string strDateFormat = "yyyy-MM-ddTHH:mm:ssZ";
		// SC: TimeZoneInformation - replacement for ConvertTimeZone
		// TimeZoneInformation timeZoneInformation;

		/// <summary>
		/// 
		/// </summary>
		private Hashtable mapBetweenGUIDAndPK;

		Hashtable arePKColumnsDate = new Hashtable();
		private MeterHelper meter;
		private Regex regex = new Regex("[<>&]");
		private OracleDB oracleDB;
		/// <summary>
		/// Default Constructor. Get the instance of the Log class.
		/// </summary>																																 
		public ServiceDef(MeterHelper meter)
		{
			this.meter = meter;
			objLog = Log.GetInstance();
			if (objLog == null)
				throw new ApplicationException("Couldn't get the instance of the Log");

			oracleDB = OracleDB.GetInstance();
			oracleDB.Logger = objLog;
		}

		/// <summary>
		/// This function is called to retrieve the list of distict Batch Id's from the DB.
		/// </summary>
		/// <param name="strBatchCriteria">Batch Criteria set in the config file</param>
		private void GetAllBatchIDs(string strBatchCriteria)
		{
			//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
			// OleDbParametr's was added to query
			List<MTDbParameter> parameters = new List<MTDbParameter>();
			string strSQL;
			OleDbDataReader objBatchRecords = null;
			try
			{
				objlistBatchNames = new ArrayList();
				strSQL = "SELECT " + objConfigInfo.strColumnPrefix + objBatchID.strPropName + ", " + objConfigInfo.strColumnPrefix + objBatchNamespace.strPropName;
				strSQL += ", count(" + objConfigInfo.strColumnPrefix + objBatchID.strPropName + ") as batchcount";
				strSQL += " from " + ServiceDBTable() + " where ";
				if (objConfigInfo.bBatchInfoPassed == true)
				{
					//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
					// OleDbParametr's was added to query
					strSQL += objConfigInfo.strColumnPrefix + objBatchID.strPropName + " = ? and " +
						objConfigInfo.strColumnPrefix + objBatchNamespace.strPropName + " = ? and ";
					parameters.Add(new MTDbParameter(objConfigInfo.strBatchName));
					parameters.Add(new MTDbParameter(objConfigInfo.strBatchNameSpace));
					//strSQL += objConfigInfo.strColumnPrefix + objBatchID.strPropName + "='" + objConfigInfo.strBatchName + "' and " +
					//			objConfigInfo.strColumnPrefix + objBatchNamespace.strPropName + "='" + objConfigInfo.strBatchNameSpace + "' and ";
				}
				switch (strBatchCriteria)
				{
					case ConfigInfo.FLAG:
						strSQL += "(" + objConfigInfo.strColumnPrefix + objServiceCriteriaField.strPropName;
						strSQL += " like '" + ConfigInfo.NOTSENT + "%' OR " + objConfigInfo.strColumnPrefix + objServiceCriteriaField.strPropName + " is NULL)";
						break;
					case ConfigInfo.TIMESTAMP:
						//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
						// OleDbParametr's was added to query
                        strSQL += "CAST(? AS DATETIME) <= CAST(" + objConfigInfo.strColumnPrefix + objServiceCriteriaField.strPropName + " AS DATETIME) AND ";
						strSQL += "CAST(" + objConfigInfo.strColumnPrefix + objServiceCriteriaField.strPropName + " AS DATETIME) < CAST(? AS DATETIME) ";
						parameters.Add(new MTDbParameter(objConfigInfo.dtLastMeteredTime.ToString(strDBDateFormat)));
						parameters.Add(new MTDbParameter(objConfigInfo.dtNextMeteredTime.ToString(strDBDateFormat)));
						/*strSQL += "CAST('" + objConfigInfo.dtLastMeteredTime.ToString(strDBDateFormat);
							strSQL += "' AS DATETIME) <= CAST(" +objConfigInfo.strColumnPrefix + objServiceCriteriaField.strPropName +" AS DATETIME) AND CAST(";
							strSQL += objConfigInfo.strColumnPrefix + objServiceCriteriaField.strPropName +" AS DATETIME) < CAST('";
							strSQL += objConfigInfo.dtNextMeteredTime.ToString(strDBDateFormat) + "' AS DATETIME) ";*/
						break;
					default:
						strSQL += "1 = 1";
						break;
				}

				strSQL += " group by ";
				strSQL += objConfigInfo.strColumnPrefix + objBatchID.strPropName + ", " + objConfigInfo.strColumnPrefix + objBatchNamespace.strPropName;

				objBatchRecords = objDAL.RunGetDataReader(strSQL, parameters.ToArray());

				if (objBatchRecords.HasRows == false)
				{
					objLog.LogString(Log.LogLevel.DEBUG, "No batches ready to send (Status=NULL Or Failed) found in the database");
				}
				else
				{
					while (objBatchRecords.Read())
					{
						//BatchID field cannot be null
						objlistBatchNames.Add((objBatchRecords.GetValue(0)).ToString() + "^" + (objBatchRecords.GetValue(1)).ToString() + "^" + (objBatchRecords.GetValue(2)).ToString());
					}
				}

			}
			catch (Exception ex)
			{
				objLog.LogString(Log.LogLevel.ERROR, "Error in the GetAllBatchIDs: " + ex.Message);
				throw;
			}
			finally
			{
				if (objDAL != null)
				{
					objDAL.Close();
				}
				if (objBatchRecords != null)
				{
					((IDisposable)objBatchRecords).Dispose();
				}
			}
		}

		/// <summary>
		/// Gets the service related data, including the child service related data. This 
		/// function is called by the init function of the metering class 
		/// </summary>
		/// <param name="objServiceXML">xml node for service definition</param>
		public void GetServiceData(ref XmlNode objServiceXML)
		{
			XmlNode objServicePropXML;
			PropType objProp = new PropType();
			ServiceDef objChild;
			string strServiceDefFileName;
			string strFileServiceDefName;
			XmlNode objSvcDefNodeXML;
			XmlDocument objSvcDefFileDomXML;
			bool blnSvcDefFile;
			try
			{
				XmlNamespaceManager nsmgr = new XmlNamespaceManager(objServiceXML.OwnerDocument.NameTable);
				nsmgr.AddNamespace(MeterHelper.defaultns, MeterHelper.urnname);
				//Read the Service Name
				strServiceName = objServiceXML.SelectSingleNode("dbmpns:ServiceName", nsmgr).InnerText;
				if (objServiceXML.SelectSingleNode("dbmpns:TableName", nsmgr) == null)
				{
					if (strServiceName.IndexOf("/") > -1)
						strTableName = strServiceName.Substring(strServiceName.IndexOf("/") + 1);
					else
						strTableName = strServiceName;
				}
				else
				{
					strTableName = objServiceXML.SelectSingleNode("dbmpns:TableName", nsmgr).InnerText;
				}

				if (objServiceXML.SelectSingleNode("dbmpns:TableHint", nsmgr) != null)
				{
					strTableHint = objServiceXML.SelectSingleNode("dbmpns:TableHint", nsmgr).InnerText;
				}

				if (objServiceXML.SelectSingleNode("dbmpns:SynchronousService", nsmgr) == null)
				{
					bSynchronousService = false;
				}
				else
				{
					bSynchronousService = bool.Parse(objServiceXML.SelectSingleNode("dbmpns:SynchronousService", nsmgr).InnerText);
				}

				//Read the max session count
				if (objServiceXML.SelectSingleNode("dbmpns:MaxSessionSet", nsmgr) == null)
				{
					iServiceMaxSessionSet = 1000;
				}
				else
				{
					iServiceMaxSessionSet = int.Parse(objServiceXML.SelectSingleNode("dbmpns:MaxSessionSet", nsmgr).InnerText);
				}

				//Read the Service Criteria Field
				//Modified the following line. Service Criteria field is now under CriteriaField tag - just for consistency sake.
				objServiceCriteriaField = new PropType();
				objServicePropXML = objServiceXML.SelectSingleNode("dbmpns:ServiceCriteriaField/dbmpns:CriteriaField", nsmgr);
				if (objServicePropXML != null)
				{
					GetPropData(ref objServiceCriteriaField, objServicePropXML.SelectSingleNode("dbmpns:ptype", nsmgr), nsmgr);
				}

				//Read the Service Primary Key
				objServicePK = new ArrayList();
				objServicePropXML = objServiceXML.SelectSingleNode("dbmpns:ServicePrimaryKey", nsmgr);
				if (objServicePropXML != null)
				{
					XmlNodeList objPTypeNodeList = objServicePropXML.SelectNodes("dbmpns:ptype", nsmgr);
					for (int iNodeCounter = 0; iNodeCounter < objPTypeNodeList.Count; iNodeCounter++)
					{
						objProp = new PropType();
						GetPropData(ref objProp, objPTypeNodeList[iNodeCounter], nsmgr);
						objServicePK.Add(objProp);
					}
				}

				//Read the special fields to update
				if ((objServiceXML.SelectSingleNode("dbmpns:BatchIdentification/dbmpns:BatchID", nsmgr) == null) ||
					(objServiceXML.SelectSingleNode("dbmpns:BatchIdentification/dbmpns:BatchNamespace", nsmgr) == null))
				{
					//bBatchIDExists = false;
				}
				else
				{
					objBatchID = new PropType();
					GetPropData(ref objBatchID, objServiceXML.SelectSingleNode("dbmpns:BatchIdentification/dbmpns:BatchID", nsmgr).SelectSingleNode("dbmpns:ptype", nsmgr), nsmgr);
					objBatchNamespace = new PropType();
					GetPropData(ref objBatchNamespace, objServiceXML.SelectSingleNode("dbmpns:BatchIdentification/dbmpns:BatchNamespace", nsmgr).SelectSingleNode("dbmpns:ptype", nsmgr), nsmgr);
					//bBatchIDExists = true;
				}

				bSentTimeStampExists = false;
				objServicePropXML = objServiceXML.SelectSingleNode("dbmpns:SpecialFieldsToUpdate/dbmpns:SentTime", nsmgr);
				if (objServicePropXML != null)
				{
					objSentTimeStamp = new PropType();
					GetPropData(ref objSentTimeStamp, objServicePropXML.SelectSingleNode("dbmpns:ptype", nsmgr), nsmgr);
					bSentTimeStampExists = true;
				}

				bErrorMesgExists = false;
				objServicePropXML = objServiceXML.SelectSingleNode("dbmpns:SpecialFieldsToUpdate/dbmpns:ErrorMesg", nsmgr);
				if (objServicePropXML != null)
				{
					objErrorMesg = new PropType();
					GetPropData(ref objErrorMesg, objServicePropXML.SelectSingleNode("dbmpns:ptype", nsmgr), nsmgr);
					bErrorMesgExists = true;
				}

				//Read the Service Metering Order
				objServiceOrder = new ArrayList();
				objServicePropXML = objServiceXML.SelectSingleNode("dbmpns:ServiceMeteringOrderFields", nsmgr);
				if (objServicePropXML != null)
				{
					XmlNodeList objPTypeNodeList = objServicePropXML.SelectNodes("dbmpns:ptype", nsmgr);
					for (int iNodeCounter = 0; iNodeCounter < objPTypeNodeList.Count; iNodeCounter++)
					{
						objProp = new PropType();
						GetPropData(ref objProp, objPTypeNodeList[iNodeCounter], nsmgr);
						objServiceOrder.Add(objProp);
					}
				}

				//Read the Service Properties
				objServiceProps = new ArrayList();
				objServicePropXML = objServiceXML.SelectSingleNode("dbmpns:ServiceProperties", nsmgr);
				objSvcDefNodeXML = objServicePropXML.SelectSingleNode("dbmpns:servicedefinitionfile", nsmgr);
				strServiceDefFileName = "";
				if (objSvcDefNodeXML != null)
				{
					strServiceDefFileName = objSvcDefNodeXML.InnerText;
				}

				if (strServiceDefFileName == null || strServiceDefFileName.Length == 0)
				{
					objLog.LogString(Log.LogLevel.DEBUG, "Service Definition Filename NOT specified - assuming inline properties");
					blnSvcDefFile = false;
				}
				else
				{
					objLog.LogString(Log.LogLevel.DEBUG, "Attempting to load and parse Service Definition Filename : " + strServiceDefFileName);
					blnSvcDefFile = true;
				}

				//If the Service Definition File Name is passed
				if (blnSvcDefFile)
				{
					objSvcDefFileDomXML = new XmlDocument();
					objSvcDefFileDomXML.PreserveWhitespace = true;
					if (!System.IO.File.Exists(strServiceDefFileName))
					{
						throw new ApplicationException("File " + strServiceDefFileName + " was not found.");
					}
					try
					{
						objSvcDefFileDomXML.Load(strServiceDefFileName);
					}
					catch (Exception ex)
					{
						throw new ApplicationException("File " + strServiceDefFileName + " is not well formed.\n" + ex.Message);
					}

					strFileServiceDefName = objSvcDefFileDomXML.SelectSingleNode("/defineservice/name").InnerText;

					//Checking whether the service name (in the mxidef file) matches with the service 
					//name in the config file
					if (strFileServiceDefName != strServiceName)
					{
						objLog.LogString(Log.LogLevel.ERROR, "Service Definition Name in File name doesn't match listed Servie Name in Configuration file");
						throw new ApplicationException("Service Definition Names don't match in Config File and Service Definition File");
					}
					XmlNodeList objPTypeNodeList = objSvcDefFileDomXML.SelectNodes("/defineservice/ptype");
					for (int iNodeCount = 0; iNodeCount < objPTypeNodeList.Count; iNodeCount++)
					{
						objProp = new PropType();
						GetPropData(ref objProp, objPTypeNodeList[iNodeCount]);
						objServiceProps.Add(objProp);
					}
				}
				else
				{
					XmlNodeList objPTypeNodeList = objServicePropXML.SelectNodes("dbmpns:ptype", nsmgr);
					//CR #12114 "Proper validation not done if both the <servicedefinitionfile> tag and Inline properties is missing."
					if (objPTypeNodeList.Count == 0)
					{
						throw new ApplicationException("Neither ServiceDefinitionFile name provided not inline properties. Service:" + strServiceName);
					}
					for (int iNodeCount = 0; iNodeCount < objPTypeNodeList.Count; iNodeCount++)
					{
						objProp = new PropType();
						GetPropData(ref objProp, objPTypeNodeList[iNodeCount], nsmgr);
						objServiceProps.Add(objProp);
					}
				}

				//Read the Service Children
				objServiceChildren = new ArrayList();
				XmlNodeList objServiceChildNodeList = objServiceXML.SelectNodes("dbmpns:ServiceChild", nsmgr);
				for (int iNodeCount = 0; iNodeCount < objServiceChildNodeList.Count; iNodeCount++)
				{
					objChild = new ServiceDef(meter);
					objChild.objConfigInfo = objConfigInfo;
					XmlNode objChildNode = (XmlNode)objServiceChildNodeList[iNodeCount];
					objChild.GetServiceData(ref objChildNode);
					objServiceChildren.Add(objChild);
				}
			}
			catch (ApplicationException aex)
			{
				objLog.LogString(Log.LogLevel.ERROR, "Application Error in the GetServiceData: " + aex.Message);
				throw;
			}
			finally
			{
				objSvcDefFileDomXML = null;
				objChild = null;
				objServicePropXML = null;
			}

		}


		/// <summary>
		/// Gets the name of the service table 
		/// </summary>
		/// <returns>Name of the service table as a string</returns>
		private string ServiceDBTable()
		{
			return objConfigInfo.strTablePrefix + strTableName;
		}

		/// <summary>
		/// Gets the name of the service table
		/// </summary>
		/// <param name="strTablePrefix">Name of table prefix as a string</param>
		/// <returns>Name of the service table as a string</returns>
		private string ServiceDBTable(string strTablePrefix)
		{
			return strTablePrefix + strTableName;
		}

		/// <summary>
		/// Gets the column names list based on the properties from the service definition of 
		/// configuration file
		/// </summary>
		/// <returns>Comma seperated column name string</returns>
		private string ServiceDBFields()
		{
			try
			{
				string strDBFields = "";
				for (int iDBFieldCounter = 0; iDBFieldCounter < objServiceProps.Count; iDBFieldCounter++)
				{
					strDBFields += objConfigInfo.strColumnPrefix + ((PropType)objServiceProps[iDBFieldCounter]).strPropName + ", ";
				}

				// Append the primary key to the selection criteria to fix the bug#4992
				if ((objServicePK != null) && (objServicePK.Count > 0))
				{
					for (int iDBFieldCounter = 0; iDBFieldCounter < objServicePK.Count; iDBFieldCounter++)
					{
						strDBFields += objConfigInfo.strColumnPrefix + ((PropType)objServicePK[iDBFieldCounter]).strPropName + ", ";
					}
				}
				strDBFields = strDBFields.Substring(0, strDBFields.Length - 2);
				return strDBFields;
			}
			catch (Exception ex)
			{
				objLog.LogString(Log.LogLevel.ERROR, "Error in the ServiceDBFields: " + ex.Message);
				throw;
			}
		}

		/// <summary>
		/// Gets the column names list based on the properties from the service definition of 
		/// configuration file
		/// </summary>
		/// <param name="strColumnPrefix">Prefix of the column name as a string</param>
		/// <returns>Comma seperated column name string</returns>
		private string ServiceDBFields(string strColumnPrefix)
		{
			try
			{
				string strDBFields = "";
				for (int iDBFieldCounter = 0; iDBFieldCounter < objServiceProps.Count; iDBFieldCounter++)
				{
					strDBFields += strColumnPrefix + ((PropType)objServiceProps[iDBFieldCounter]).strPropName + ", ";
				}

				// Append the primary key to the selection criteria to fix the bug#4992
				if ((objServicePK != null) && (objServicePK.Count > 0))
				{
					for (int iDBFieldCounter = 0; iDBFieldCounter < objServicePK.Count; iDBFieldCounter++)
					{
						strDBFields += strColumnPrefix + ((PropType)objServicePK[iDBFieldCounter]).strPropName + ", ";
					}
				}
				strDBFields = strDBFields.Substring(0, strDBFields.Length - 2);
				return strDBFields;
			}
			catch (Exception ex)
			{
				objLog.LogString(Log.LogLevel.ERROR, "Error in the ServiceDBFields: " + ex.Message);
				throw;
			}
		}

		/// <summary>
		/// Fires the query for child table and gets the OleDbDataReader object
		/// </summary>
		/// <param name="strBatchCriteria">Batch Crieteria set in the config file</param>
		/// <param name="strBatchName">The Batch name for which the records to be fetched</param>
		/// <param name="strBatchSpace">The Batch namespace for which the records to be fetched</param>
		/// <param name="objFilter">stores the filter columns</param>
		/// <param name="iCount">Index of the child table in the list of childs for a particular parent</param> 
		/// <returns>OleDbDataReader/Datatable object for the child table depending on the connection mode</returns>
		private object GetChildRS(string strBatchCriteria, string strBatchName, string strBatchSpace, int iCount)
		{
			//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
			// OleDbParameter was added to query
			List<MTDbParameter> parameters = new List<MTDbParameter>();
			ServiceDef objChild = (ServiceDef)objServiceChildren[iCount];
			objChild.objServicePK = this.objServicePK;
			string strSQLSelect = "";
			//string strPrimaryKey = objConfigInfo.strColumnPrefix + ((PropType)objServicePK[0]).strPropName;
			try
			{
				//construct the query
				strSQLSelect = "Select " + objChild.ServiceDBFields("ct." + objConfigInfo.strColumnPrefix);
				strSQLSelect += " from " + objChild.ServiceDBTable(objConfigInfo.strTablePrefix) + " ct ";
				if (objChild.strTableHint != null)
				{
					strSQLSelect += " " + objChild.strTableHint;
				}
				strSQLSelect += " INNER JOIN " + ServiceDBTable() + " pt";
				if (strTableHint != null)
				{
					strSQLSelect += " " + strTableHint;
				}
				strSQLSelect += " ON ct." + objConfigInfo.strColumnPrefix + ((PropType)objServicePK[0]).strPropName + "=pt." + objConfigInfo.strColumnPrefix + ((PropType)objServicePK[0]).strPropName;
				for (int pkCount = 1; pkCount < objServicePK.Count; pkCount++)
				{
					strSQLSelect += " AND ct." + objConfigInfo.strColumnPrefix + ((PropType)objServicePK[pkCount]).strPropName + "=pt." + objConfigInfo.strColumnPrefix + ((PropType)objServicePK[pkCount]).strPropName;
				}
				//strSQLSelect += " where " + strPrimaryKey + " in (select " + strPrimaryKey + " from " + ServiceDBTable();

				switch (strBatchCriteria)
				{
					case ConfigInfo.FLAG:
						//Use this for SQL Server
						if (objConfigInfo.strDBType.ToUpper() == "MSSQL" ||
				objConfigInfo.strDBType.ToUpper() == "SYBASE" ||
				objConfigInfo.strDBType.ToUpper() == "ORACLE")
						{
							strSQLSelect += " where (pt." + objConfigInfo.strColumnPrefix + objServiceCriteriaField.strPropName;
							strSQLSelect += " like '" + ConfigInfo.NOTSENT + "%' OR pt." + objConfigInfo.strColumnPrefix + objServiceCriteriaField.strPropName + " is NULL)";
						}
						break;
					case ConfigInfo.TIMESTAMP:
						if (objConfigInfo.strDBType.ToUpper() == "MSSQL" || objConfigInfo.strDBType.ToUpper() == "SYBASE")
						{
                            //SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
                            // OleDbParametr was added to query
                            strSQLSelect += " where CAST(? AS DATETIME) <= CAST(pt." + objConfigInfo.strColumnPrefix + objServiceCriteriaField.strPropName + " AS DATETIME) AND ";
                            strSQLSelect += " CAST(pt." + objConfigInfo.strColumnPrefix + objServiceCriteriaField.strPropName + " AS DATETIME) < CAST(? AS DATETIME) ";
                            parameters.Add(new MTDbParameter(objConfigInfo.dtLastMeteredTime.ToString(strDBDateFormat)));
						    parameters.Add(new MTDbParameter(objConfigInfo.dtNextMeteredTime.ToString(strDBDateFormat)));
						    /*strSQLSelect += " where CAST('" + objConfigInfo.dtLastMeteredTime.ToString(strDBDateFormat);
                            strSQLSelect += "' AS DATETIME) <= CAST(pt." + objConfigInfo.strColumnPrefix + objServiceCriteriaField.strPropName + " AS DATETIME) AND ";
							strSQLSelect += " CAST(pt." + objConfigInfo.strColumnPrefix + objServiceCriteriaField.strPropName + " AS DATETIME) < CAST('";
							strSQLSelect += objConfigInfo.dtNextMeteredTime.ToString(strDBDateFormat) + "' AS DATETIME) ";*/
						}
						break;
					default:
						strSQLSelect += " where 1 = 1";
						break;
				}

				if (strBatchName.Length > 0)
				{
                    //SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
                    // OleDbParameter was added to query
                    parameters.Add(new MTDbParameter(strBatchName));
					parameters.Add(new MTDbParameter(strBatchSpace));
					strSQLSelect += " AND pt." + objConfigInfo.strColumnPrefix + objBatchID.strPropName + " = ? AND  pt.";
					strSQLSelect += objConfigInfo.strColumnPrefix + objBatchNamespace.strPropName + " = ?";
					/*strSQLSelect += " AND pt." + objConfigInfo.strColumnPrefix + objBatchID.strPropName + " = '" + strBatchName + "' AND  pt.";
					strSQLSelect += objConfigInfo.strColumnPrefix + objBatchNamespace.strPropName + " = '" + strBatchSpace + "'";*/
				}

				strSQLSelect += " order by ct." + objConfigInfo.strColumnPrefix + ((PropType)objServicePK[0]).strPropName; ;
				for (int pkCount = 1; pkCount < objServicePK.Count; pkCount++)
				{
					strSQLSelect += ", ct." + objConfigInfo.strColumnPrefix + ((PropType)objServicePK[pkCount]).strPropName;
				}

				//Executing the SQLQuery
				if (objConfigInfo.isConnectedMode)
				{
					OleDbDataReader objRecordsForBatch = null;
					objRecordsForBatch = objDAL.RunGetDataReader(strSQLSelect, parameters.ToArray());
					//objDAL.Run(ref objRecordsForBatch, strSQLSelect);
					return objRecordsForBatch;
				}
				else
				{
					DataTable objRecordsForBatch = objDAL.RunGetDataTable(strSQLSelect, parameters.ToArray());
					//DataTable objRecordsForBatch = new DataTable();
					//objDAL.Run(objRecordsForBatch, strSQLSelect);
					return objRecordsForBatch;
				}
			}
			catch (Exception ex)
			{
				objConfigInfo.bDataSourceConnectFailure = true;
				objLog.LogString(Log.LogLevel.ERROR, "Error in the GetChildRS: " + ex.Message);
				throw;
			}
			finally
			{

			}
		}

		/// <summary>
		/// Fires the query for parent table and gets the OleDbDataReader object
		/// </summary>
		/// <param name="strBatchCriteria">Batch Crieteria set in the config file</param>
		/// <param name="strBatchName">The Batch name for which the records to be fetched</param>
		/// <param name="strBatchSpace">The Batch namespace for which the records to be fetched</param>
		/// <returns>OleDbDataReader/DataTable object for the parent table</returns>
		private object GetParentRS(string strBatchCriteria, string strBatchName, string strBatchSpace)
		{
			string strSQLSelect = "";
			//string strPrimaryKey = null;
			bool bPKDefined = false;
			try
			{
				if (objServicePK.Count > 0)
				{
					bPKDefined = true;
					//strPrimaryKey = ((PropType)objServicePK[0]).strPropName;
				}

				strSQLSelect = "Select " + ServiceDBFields();

				// Add here for the childern count
				if (objServiceChildren.Count > 0)
				{
					ServiceDef objChild = (ServiceDef)objServiceChildren[0];
					strSQLSelect += ", ";// + "(" ;
					strSQLSelect += "(Select count(*)";
					strSQLSelect += " from " + objConfigInfo.strTablePrefix + objChild.strTableName + " ct ";

					strSQLSelect += " WHERE pt." + objConfigInfo.strColumnPrefix + ((PropType)objServicePK[0]).strPropName + "=ct." + objConfigInfo.strColumnPrefix + ((PropType)objServicePK[0]).strPropName;
					for (int pkCount = 1; pkCount < objServicePK.Count; pkCount++)
					{
						strSQLSelect += " AND pt." + objConfigInfo.strColumnPrefix + ((PropType)objServicePK[pkCount]).strPropName + "=ct." + objConfigInfo.strColumnPrefix + ((PropType)objServicePK[pkCount]).strPropName;
					}
					strSQLSelect += ") as childcount1";

					for (int iCount = 1; iCount < objServiceChildren.Count; iCount++)
					{
						objChild = (ServiceDef)objServiceChildren[iCount];
						strSQLSelect += ",(Select count(*)"; //strSQLSelect += "+(Select count(*)"; 
						strSQLSelect += " from " + objConfigInfo.strTablePrefix + objChild.strTableName + " ct" + iCount;
						strSQLSelect += " WHERE pt." + objConfigInfo.strColumnPrefix + ((PropType)objServicePK[0]).strPropName + "=ct" + iCount + "." + objConfigInfo.strColumnPrefix + ((PropType)objServicePK[0]).strPropName;
						for (int pkCount = 1; pkCount < objServicePK.Count; pkCount++)
						{
							strSQLSelect += " AND pt." + objConfigInfo.strColumnPrefix + ((PropType)objServicePK[pkCount]).strPropName + "=ct" + iCount + "." + objConfigInfo.strColumnPrefix + ((PropType)objServicePK[pkCount]).strPropName;
						}
						strSQLSelect += ") as childcount" + (iCount + 1);
					}

					//strSQLSelect += ")" + "as childcount"; 
				}

				strSQLSelect += " from " + ServiceDBTable() + " pt";
				if (strTableHint != null)
				{
					strSQLSelect += " " + strTableHint;
				}
				switch (strBatchCriteria)
				{
					case ConfigInfo.FLAG:
						//Use this for SQL Server
						if (objConfigInfo.strDBType.ToUpper() == "MSSQL" ||
				objConfigInfo.strDBType.ToUpper() == "SYBASE" ||
				objConfigInfo.strDBType.ToUpper() == "ORACLE")
						{
							strSQLSelect += " where (" + objConfigInfo.strColumnPrefix + objServiceCriteriaField.strPropName;
							strSQLSelect += " like '" + ConfigInfo.NOTSENT + "%' OR " + objConfigInfo.strColumnPrefix + objServiceCriteriaField.strPropName + " is NULL)";
						}
						break;
					case ConfigInfo.TIMESTAMP:
						if (objConfigInfo.strDBType.ToUpper() == "MSSQL" || objConfigInfo.strDBType.ToUpper() == "SYBASE")
						{
							strSQLSelect += " where CAST('" + objConfigInfo.dtLastMeteredTime.ToString(strDBDateFormat);
							strSQLSelect += "' AS DATETIME) <= CAST(" + objConfigInfo.strColumnPrefix + objServiceCriteriaField.strPropName + " AS DATETIME) AND ";
							strSQLSelect += " CAST(" + objConfigInfo.strColumnPrefix + objServiceCriteriaField.strPropName + " AS DATETIME) < CAST('";
							strSQLSelect += objConfigInfo.dtNextMeteredTime.ToString(strDBDateFormat) + "' AS DATETIME) ";
						}
						break;
					default:
						strSQLSelect += " where 1 = 1";
						break;
				}

				if (strBatchName.Length > 0)
				{
					strSQLSelect += " AND " + objConfigInfo.strColumnPrefix + objBatchID.strPropName + " = '" + strBatchName + "' AND  ";
					strSQLSelect += objConfigInfo.strColumnPrefix + objBatchNamespace.strPropName + " = '" + strBatchSpace + "'";
				}

				if (bPKDefined)
				{
					strSQLSelect += " order by " + "pt." + objConfigInfo.strColumnPrefix + ((PropType)objServicePK[0]).strPropName; ;
					for (int pkCount = 1; pkCount < objServicePK.Count; pkCount++)
					{
						strSQLSelect += ", " + "pt." + objConfigInfo.strColumnPrefix + ((PropType)objServicePK[pkCount]).strPropName; ;
					}
				}
				else if (objServiceOrder.Count > 0)
				{
					strSQLSelect += " order by " + "pt." + objConfigInfo.strColumnPrefix + ((PropType)objServiceOrder[0]).strPropName;
					for (int iServiceOrderCount = 1; iServiceOrderCount < objServiceOrder.Count; iServiceOrderCount++)
					{
						strSQLSelect += ", " + "pt." + objConfigInfo.strColumnPrefix + ((PropType)objServiceOrder[iServiceOrderCount]).strPropName;
					}
				}

				//Executing the SQLQuery
				//SECEND:
				if (objConfigInfo.isConnectedMode)
				{
					OleDbDataReader objRecordsForBatch = objDAL.RunGetDataReader(strSQLSelect, null);
					//OleDbDataReader objRecordsForBatch = null;
					//objDAL.Run(ref objRecordsForBatch, strSQLSelect);
					return objRecordsForBatch;
				}
				else
				{
					DataTable objRecordsForBatch = objDAL.RunGetDataTable(strSQLSelect, null);
					//DataTable objRecordsForBatch = new DataTable();
					//objDAL.Run(objRecordsForBatch, strSQLSelect);
					return objRecordsForBatch;
				}
			}
			catch (Exception ex)
			{
				objConfigInfo.bDataSourceConnectFailure = true;
				objLog.LogString(Log.LogLevel.ERROR, "Error in the GetParentRS: " + ex.Message);
				throw;
			}
			finally
			{
			}
		}


		/// <summary>
		/// Sets the service properties to Session Object
		/// </summary>
		/// <param name="objParentSession">Session object</param>
		/// <param name="objParentTable">OleDbDataReader object for the parent table</param>
		/// <param name="arrChildRS">List of OleDbDataReader objects for the child tables</param>
		private void SetServiceProperties(Session objParentSession, OleDbDataReader objParentTable, ArrayList arrChildRS)
		{
			PropType objProp;
			Session objChildSession;
			ServiceDef objChildSessionServiceDef;
			OleDbDataReader objChildTable = null;
			string[] parentIds = null;
			string[] childIds = null;
			int iChildSessions = 0;
			// SC: arrays to hold property names and values
			ArrayList properties = new ArrayList();
			PropertyData propertyData;

			try
			{
				if (objServiceChildren.Count > 0)
				{
					parentIds = new string[objServicePK.Count];
					for (int pkcount = 0; pkcount < objServicePK.Count; pkcount++)
					{
						parentIds[pkcount] = objParentTable[objConfigInfo.strColumnPrefix + ((PropType)objServicePK[pkcount]).strPropName].ToString();
					}
				}
				//Sets the Session properties
				objLog.LogString(Log.LogLevel.DEBUG, "Setting properties for service: " + strServiceName);
				for (int iPropCount = 0; iPropCount < objServiceProps.Count; iPropCount++)
				{
					objProp = (PropType)objServiceProps[iPropCount];
					object val = objParentTable.GetValue(iPropCount);
					if (val != DBNull.Value)
					{
						// SC: All properties are sent as strings
						propertyData =
						  GetPropertyValue(val.ToString(),
										   objProp.strPropName,
										   objProp.strPropType);

						properties.Add(propertyData);
					}
					else if (objConfigInfo.bUseDefaults)
					{
						if (objProp.strPropDefault.Trim().Length > 0)
						{
							objLog.LogString(Log.LogLevel.DEBUG, "Setting property " + objProp.strPropName + " to: " + objProp.strPropDefault.Trim() + " (property is NULL in datasource)");
							// objParentSession.InitProperty( objProp.strPropName, CastProperty(objProp.strPropDefault.Trim(), objProp.strPropType) );

							propertyData =
							  GetPropertyValue(objProp.strPropDefault.Trim(),
											   objProp.strPropName,
											   objProp.strPropType);

							properties.Add(propertyData);
						}
						//CR #12282: DBMP meters blank value, if use defaults is set as Y for no value specifted in *.msixdef file if source value is null
						else
						{
							objLog.LogString(Log.LogLevel.DEBUG, "Default value not set for the property " + objProp.strPropName + ". Won't get metered");
						}
					}
					else
					{
						//If a property is not required and no defaults should be used, then it won't be metered at all
						objLog.LogString(Log.LogLevel.DEBUG, "SKIPPING property " + objProp.strPropName + " (property is NULL in datasource)");
					}
				}

				// SC: Transfer properties using the new CreateSessionStream API
				PropertyData[] propertyDataArray =
				  properties.ToArray(typeof(PropertyData)) as PropertyData[];

				objParentSession.CreateSessionStream(propertyDataArray);

				//Sets the Children Sessions properties
				for (int iChildCount = 0; iChildCount < objServiceChildren.Count; iChildCount++)
				{
					childIds = new string[objServicePK.Count];
					iChildSessions = 0;
					objChildSessionServiceDef = (ServiceDef)objServiceChildren[iChildCount];
					objChildTable = (OleDbDataReader)arrChildRS[iChildCount];
					objLog.LogString(Log.LogLevel.DEBUG, "Retried recordset for child: " + objChildSessionServiceDef.strServiceName);
					if (objChildTable.IsClosed == false)
					{
						for (int pkcount = 0; pkcount < objServicePK.Count; pkcount++)
						{
							childIds[pkcount] = objChildTable[objConfigInfo.strColumnPrefix + ((PropType)objServicePK[pkcount]).strPropName].ToString();
						}

						while (AreBothArraysEqual(parentIds, childIds))
						{
							iChildSessions++;
							objChildSession = null;
							objChildSession = objParentSession.CreateChildSession(objChildSessionServiceDef.strServiceName);
							objLog.LogString(Log.LogLevel.DEBUG, "Created child session");
							objChildSessionServiceDef.SetServiceProperties(objChildSession, objChildTable, null);
							System.Runtime.InteropServices.Marshal.ReleaseComObject(objChildSession);
							objLog.LogString(Log.LogLevel.DEBUG, "Properties successfully set");
							if (objChildTable.Read() == false)
							{
								objChildTable.Close();
								break;
							}
							else
							{
								for (int pkcount = 0; pkcount < objServicePK.Count; pkcount++)
								{
									childIds[pkcount] = objChildTable[objConfigInfo.strColumnPrefix + ((PropType)objServicePK[pkcount]).strPropName].ToString();
								}
							}
						}
					}

					//Storing the values of the ChildSessions (min, max and total) for the compounds.
					SavingTheStatistics objStats = (SavingTheStatistics)objSessionsForCompound[iChildCount];

					objStats.totalValue += iChildSessions;
					if (objStats.minValue > iChildSessions)
						objStats.minValue = iChildSessions;
					if (objStats.maxValue < iChildSessions)
						objStats.maxValue = iChildSessions;

					objSessionsForCompound[iChildCount] = objStats;
				}
			}
			catch (Exception ex)
			{
				for (int iChildCount = 0; iChildCount < objServiceChildren.Count; iChildCount++)
				{
					childIds = new string[objServicePK.Count];
					objChildTable = (OleDbDataReader)arrChildRS[iChildCount];
					if (objChildTable.IsClosed == false)
					{
						int numchildrens = objParentTable.GetInt32(objParentTable.GetOrdinal("childcount" + (iChildCount + 1)));
						//If no childrens exist for parent then we don;t want to proceed further as it would move the
						//child cursor to wrong record
						if (numchildrens == 0)
							continue;
						for (int pkcount = 0; pkcount < objServicePK.Count; pkcount++)
						{
							childIds[pkcount] = objChildTable[objConfigInfo.strColumnPrefix + ((PropType)objServicePK[pkcount]).strPropName].ToString();
						}
						//This is done to bring the cursor in both the recordset to current level. The one case where parent has
						//been processed but child is not can be when parent/child records has some problem. So cursor in the
						//parent recordset has already been moved to next record but curson in child recordset still on 
						//the previous parent records
						while (!AreBothArraysEqual(parentIds, childIds))
						{
							if (!objChildTable.Read())
								break;
							for (int pkcount = 0; pkcount < objServicePK.Count; pkcount++)
							{
								childIds[pkcount] = objChildTable[objConfigInfo.strColumnPrefix + ((PropType)objServicePK[pkcount]).strPropName].ToString();
							}
							continue;
						}
					}
				}
				objLog.LogString(Log.LogLevel.ERROR, "Error in the SetServiceProperties: " + ex.Message);
				throw;
			}
		}

		/// <summary>
		/// Sets the service properties to Session Object for the disconnected mode
		/// </summary>
		/// <param name="objParentSession">Session object</param>
		/// <param name="objParentTable">DataRow object for the parent table</param>
		/// <param name="arrChildRS">List of DataTable objects for the child tables</param>
		private void SetServiceProperties(Session objParentSession, DataRow objParentRow, ArrayList arrChildRS)
		{
			PropType objProp;
			Session objChildSession;
			ServiceDef objChildSessionServiceDef;
			DataTable objChildTable = null;
			//string strPKColumnName = null;
			int iChildSessions = 0;
			try
			{
				//Sets the Session properties
				objLog.LogString(Log.LogLevel.DEBUG, "Setting properties for service: " + strServiceName);
				for (int iPropCount = 0; iPropCount < objServiceProps.Count; iPropCount++)
				{
					objProp = (PropType)objServiceProps[iPropCount];
					object val = objParentRow[iPropCount];
					if (val != DBNull.Value)
					{
						string propvalue;
						if (Convert.ToInt32(arePKColumnsDate[objConfigInfo.strColumnPrefix + objProp.strPropName]) == 1 && objProp.strPropType.ToUpper() == "STRING")
						{
							val = CastProperty(val, "timestamp");
							DateTime d1 = Convert.ToDateTime(val);
							propvalue = d1.ToString("yyyy-MM-ddTHH:mm:ss.fffZ");
							objLog.LogString(Log.LogLevel.DEBUG, "Setting property " + objProp.strPropName + " to: " + propvalue);
							objParentSession.InitProperty(objProp.strPropName, propvalue);
						}
						else
						{
							propvalue = val.ToString().Trim();

							objLog.LogString(Log.LogLevel.DEBUG, "Setting property " + objProp.strPropName + " to: " + propvalue);
							objParentSession.InitProperty(objProp.strPropName, CastProperty(propvalue, objProp.strPropType));
						}
					}
					else if (objConfigInfo.bUseDefaults)
					{
						if (objProp.strPropDefault.Trim().Length > 0)
						{
							objLog.LogString(Log.LogLevel.DEBUG, "Setting property " + objProp.strPropName + " to: " + objProp.strPropDefault + " (property is NULL in datasource)");
							objParentSession.InitProperty(objProp.strPropName, CastProperty(objProp.strPropDefault.Trim(), objProp.strPropType));
						}
						//CR #12282: DBMP meters blank value, if use defaults is set as Y for no value specifted in *.msixdef file if source value is null
						else
						{
							objLog.LogString(Log.LogLevel.DEBUG, "Default value not set for the property " + objProp.strPropName + ". Won't get metered");
						}
					}
					else
					{
						//If a property is not required and no defaults should be used, then it won't be metered at all
						objLog.LogString(Log.LogLevel.DEBUG, "SKIPPING property " + objProp.strPropName + " (property is NULL in datasource)");
					}
				}
				/*
				if(objServiceChildren.Count > 0)
				{
					PropType objPK = (PropType)objServicePK[0];
					strPKColumnName = objConfigInfo.strColumnPrefix + objPK.strPropName;
					strParentId = objParentRow[strPKColumnName].ToString();
				}
				*/
				//Sets the Children Sessions properties
				for (int iChildCount = 0; iChildCount < objServiceChildren.Count; iChildCount++)
				{
					objChildSessionServiceDef = (ServiceDef)objServiceChildren[iChildCount];
					objChildTable = (DataTable)arrChildRS[iChildCount];
					objLog.LogString(Log.LogLevel.DEBUG, "Retried recordset for child: " + objChildSessionServiceDef.strServiceName);


					if (objChildTable.Rows.Count > 0)
					{

						DataRow[] rows = null;
						string wherequery = "";
						FieldFilter startingfilter;
						startingfilter.strFieldName = ((PropType)objServicePK[0]).strPropName;
						startingfilter.strFieldType = ((PropType)objServicePK[0]).strPropType;
						startingfilter.strFieldValue = objParentRow[objConfigInfo.strColumnPrefix + startingfilter.strFieldName].ToString();
						wherequery = objConfigInfo.strColumnPrefix + startingfilter.strFieldName + "=" + startingfilter.Delimiter() + startingfilter.strFieldValue + startingfilter.Delimiter();
						for (int pkcount = 1; pkcount < objServicePK.Count; pkcount++)
						{
							startingfilter.strFieldName = ((PropType)objServicePK[pkcount]).strPropName;
							startingfilter.strFieldType = ((PropType)objServicePK[pkcount]).strPropType;
							startingfilter.strFieldValue = objParentRow[objConfigInfo.strColumnPrefix + startingfilter.strFieldName].ToString();
							wherequery += " AND " + objConfigInfo.strColumnPrefix + startingfilter.strFieldName + "=" + startingfilter.Delimiter() + startingfilter.strFieldValue + startingfilter.Delimiter();
						}
						rows = objChildTable.Select(wherequery);

						for (int i = 0; i < rows.Length; i++)
						{
							iChildSessions++;
							objChildSession = null;
							objChildSession = objParentSession.CreateChildSession(objChildSessionServiceDef.strServiceName);
							objLog.LogString(Log.LogLevel.DEBUG, "Created child session");
							objChildSessionServiceDef.SetServiceProperties(objChildSession, rows[i], null);
							System.Runtime.InteropServices.Marshal.ReleaseComObject(objChildSession);
							objLog.LogString(Log.LogLevel.DEBUG, "Properties successfully set");
						}
					}
					//Storing the values of the ChildSessions (min, max and total) for the compounds.
					SavingTheStatistics objStats = (SavingTheStatistics)objSessionsForCompound[iChildCount];

					objStats.totalValue += iChildSessions;
					if (objStats.minValue > iChildSessions)
						objStats.minValue = iChildSessions;
					if (objStats.maxValue < iChildSessions)
						objStats.maxValue = iChildSessions;

					objSessionsForCompound[iChildCount] = objStats;
					iChildSessions = 0;
				}
			}
			catch (Exception ex)
			{
				objLog.LogString(Log.LogLevel.ERROR, "Error in the SetServiceProperties: " + ex.Message);
				throw;
			}
		}


		/// <summary>
		/// Updates the record status for all sessions in session set
		/// </summary>
		/// <param name="strBatchDate">Date when the records are metered</param>
		/// <param name="strErrorMesg">Error message if any</param>
		/// <param name="objStartingPK">starting value of primary key </param>
		/// <param name="objEndingPK">ending value of primary key</param>
		/// <param name="strBatchName">Batch name of the service</param>
		/// <param name="strBatchSpace">Batch namespace of the service</param>
		/// <param name="strFinalStatus">Status string to be updated (either 'Sent' or 'Failed')</param>
		private void SetMeterStatusAll(string strBatchDate,
								   string strErrorMesg,
								   Hashtable startingPKs,
										 Hashtable endingPKs,
								   string strBatchName,
								   string strBatchSpace,
								   string strFinalStatus,
								   Hashtable aMapBetweenGUIDAndPKs)
		{
			lock (this)
			{
				string strSQL = null;
				DAL objDAL = null;

				try
				{
					if (objServicePK.Count <= 2)
					{
						strSQL = "update " + statusTableName + " set " + objConfigInfo.strColumnPrefix;
						strSQL += objServiceCriteriaField.strPropName + "='" + strFinalStatus + "'";
						if (bSentTimeStampExists)
						{
							strSQL += " , " + objConfigInfo.strColumnPrefix + objSentTimeStamp.strPropName + " = '" + strBatchDate + "'";
						}

						if (bErrorMesgExists)
						{
							strErrorMesg = strErrorMesg.Replace("'", "''");
							if (strErrorMesg.Length > objErrorMesg.propLength)
							{
								strErrorMesg = strErrorMesg.Substring(0, objErrorMesg.propLength);
							}
							strSQL += " ," + objConfigInfo.strColumnPrefix + objErrorMesg.strPropName + " = '" + strErrorMesg + "'";
						}

						//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
						// OleDbParameter was added to query
						List<MTDbParameter> parameters = new List<MTDbParameter>();
						strSQL += " WHERE " + BuildWHEREClause(startingPKs, endingPKs, ref parameters);
						strSQL += " AND ";

						strSQL += objConfigInfo.strColumnPrefix + objBatchID.strPropName + " = ? AND  ";
						strSQL += objConfigInfo.strColumnPrefix + objBatchNamespace.strPropName + " = ?";

						strSQL += " AND (" + objConfigInfo.strColumnPrefix + objServiceCriteriaField.strPropName;
						strSQL += " like '" + ConfigInfo.NOTSENT + "%' OR " + objConfigInfo.strColumnPrefix + objServiceCriteriaField.strPropName + " is NULL)";

                        parameters.Add(new MTDbParameter(strBatchName));
						parameters.Add(new MTDbParameter(strBatchSpace));

						objDAL = new DAL(objConfigInfo.strDBType, objConfigInfo.strDBDataSource, objConfigInfo.Provider, objConfigInfo.strDBServer,
						  objConfigInfo.strDBName, objConfigInfo.strDBUsername, objConfigInfo.strDBPassword, objConfigInfo.strAppendToConnectionString);
						objDAL.RunExecuteNonQuery(strSQL, parameters.ToArray());

						/*strSQL += " where ";
			strSQL +=	BuildWHEREClause(startingPKs,endingPKs);
			strSQL += " AND ";
  				    

			strSQL += objConfigInfo.strColumnPrefix +objBatchID.strPropName +" = '" +strBatchName + "' AND  ";
			strSQL += objConfigInfo.strColumnPrefix +objBatchNamespace.strPropName +" = '" +strBatchSpace +"'";

			strSQL += " AND (" +objConfigInfo.strColumnPrefix + objServiceCriteriaField.strPropName;
			strSQL += " like '" + ConfigInfo.NOTSENT + "%' OR " + objConfigInfo.strColumnPrefix + objServiceCriteriaField.strPropName + " is NULL)";
  				
			objDAL = new DAL( objConfigInfo.strDBType, objConfigInfo.strDBDataSource,  objConfigInfo.Provider, objConfigInfo.strDBServer,
			  objConfigInfo.strDBName, objConfigInfo.strDBUsername, objConfigInfo.strDBPassword, objConfigInfo.strAppendToConnectionString );
						objDAL.Run(strSQL);*/
					}
					else
					{
						//Calling sequential updates for PK's > 2
						IEnumerator keysenum = aMapBetweenGUIDAndPKs.Keys.GetEnumerator();
						while (keysenum.MoveNext())
						{
							string sessionId = keysenum.Current.ToString();
							SetMeterStatus(strBatchDate, strErrorMesg, sessionId, strFinalStatus, aMapBetweenGUIDAndPKs);
						}
					}
				}
				catch (Exception ex)
				{
					objLog.LogString(Log.LogLevel.ERROR, "Error in the SetMeterStatusAll: " + ex.Message);
					throw;
				}
			}
		}

		private string BuildWHEREClause(Hashtable startingPKs, Hashtable endingPKs, ref List<MTDbParameter> parameters)
		{
			string sql = string.Empty;
			FieldFilter startingfilter, endingfilter;
			if (objServicePK.Count > 1)
			{
				//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
				// OleDbParametr's was added to query
				startingfilter.strFieldName = ((PropType)objServicePK[0]).strPropName;
				startingfilter.strFieldType = ((PropType)objServicePK[0]).strPropType;
				startingfilter.strFieldValue = startingPKs[startingfilter.strFieldName].ToString();

				endingfilter.strFieldName = ((PropType)objServicePK[0]).strPropName;
				endingfilter.strFieldType = ((PropType)objServicePK[0]).strPropType;

				sql += " ( ( " + objConfigInfo.strColumnPrefix + startingfilter.strFieldName + " > ? ";
				parameters.Add(new MTDbParameter(startingfilter.strFieldValue));

				if (endingPKs != null && endingPKs[endingfilter.strFieldName] != null)
				{
					endingfilter.strFieldValue = endingPKs[endingfilter.strFieldName].ToString();
					sql += " AND " + objConfigInfo.strColumnPrefix + endingfilter.strFieldName + " < ? ";
					parameters.Add(new MTDbParameter(endingfilter.strFieldValue));
				}
				sql += " ) ";
				/*sql += " ( "; // CR12639 need additional parens to enforce operator precedence
				startingfilter.strFieldName =  ((PropType) objServicePK[0]).strPropName;
				startingfilter.strFieldType = ((PropType) objServicePK[0]).strPropType;
				startingfilter.strFieldValue = startingPKs[startingfilter.strFieldName].ToString();
				sql +=	" ( " +objConfigInfo.strColumnPrefix + startingfilter.strFieldName +">" +startingfilter.Delimiter() +
					startingfilter.strFieldValue +startingfilter.Delimiter();

				endingfilter.strFieldName =  ((PropType) objServicePK[0]).strPropName;
				endingfilter.strFieldType = ((PropType) objServicePK[0]).strPropType;

				if(endingPKs!=null && endingPKs[endingfilter.strFieldName] != null)
				{
					endingfilter.strFieldValue = endingPKs[endingfilter.strFieldName].ToString();
					sql += " AND " +objConfigInfo.strColumnPrefix + endingfilter.strFieldName +"<" + endingfilter.Delimiter()
						+ endingfilter.strFieldValue + endingfilter.Delimiter();
				}
				sql += " ) ";*/

				for (int pkCount = 0; pkCount < objServicePK.Count - 1; pkCount++)
				{
					sql += " OR ( ";
					for (int count1 = 0; count1 <= pkCount; count1++)
					{
						startingfilter.strFieldName = ((PropType)objServicePK[count1]).strPropName;
						startingfilter.strFieldType = ((PropType)objServicePK[count1]).strPropType;
						startingfilter.strFieldValue = startingPKs[startingfilter.strFieldName].ToString();

						//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
						// OleDbParametr's was added to query
						sql += objConfigInfo.strColumnPrefix + startingfilter.strFieldName + " = ? AND ";
						parameters.Add(new MTDbParameter(startingfilter.strFieldValue));
						/*sql += objConfigInfo.strColumnPrefix + startingfilter.strFieldName + "=" + startingfilter.Delimiter() +
							startingfilter.strFieldValue +startingfilter.Delimiter();
						sql += " AND ";*/
					}

					if (endingPKs == null || (startingPKs[startingfilter.strFieldName].ToString() != endingPKs[startingfilter.strFieldName].ToString()))
					{
						startingfilter.strFieldName = ((PropType)objServicePK[pkCount + 1]).strPropName;
						startingfilter.strFieldType = ((PropType)objServicePK[pkCount + 1]).strPropType;
						startingfilter.strFieldValue = startingPKs[startingfilter.strFieldName].ToString();

						//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
						// OleDbParametr's was added to query
						sql += objConfigInfo.strColumnPrefix + startingfilter.strFieldName + " >= ?";
						parameters.Add(new MTDbParameter(startingfilter.strFieldValue));
						/*sql += objConfigInfo.strColumnPrefix + startingfilter.strFieldName + ">=" + startingfilter.Delimiter() +
							startingfilter.strFieldValue + startingfilter.Delimiter();*/
					}
					else
					{
						//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
						// OleDbParametr's was added to query
						startingfilter.strFieldName = ((PropType)objServicePK[pkCount + 1]).strPropName;
						startingfilter.strFieldType = ((PropType)objServicePK[pkCount + 1]).strPropType;
						startingfilter.strFieldValue = startingPKs[startingfilter.strFieldName].ToString();
						endingfilter.strFieldName = ((PropType)objServicePK[pkCount + 1]).strPropName;
						endingfilter.strFieldType = ((PropType)objServicePK[pkCount + 1]).strPropType;
						endingfilter.strFieldValue = endingPKs[endingfilter.strFieldName].ToString();

						sql += objConfigInfo.strColumnPrefix + startingfilter.strFieldName + " >= ?";

						sql += " AND " + objConfigInfo.strColumnPrefix + endingfilter.strFieldName + " < ? ) ) ";
						parameters.Add(new MTDbParameter(startingfilter.strFieldValue));
						parameters.Add(new MTDbParameter(endingfilter.strFieldValue));

						/*startingfilter.strFieldName = ((PropType)objServicePK[pkCount + 1]).strPropName;
						startingfilter.strFieldType = ((PropType)objServicePK[pkCount + 1]).strPropType;
						startingfilter.strFieldValue = startingPKs[startingfilter.strFieldName].ToString();

						sql +=	objConfigInfo.strColumnPrefix + startingfilter.strFieldName +">=" +startingfilter.Delimiter() +
							startingfilter.strFieldValue +startingfilter.Delimiter();
						endingfilter.strFieldName =  ((PropType) objServicePK[pkCount+1]).strPropName;
						endingfilter.strFieldType = ((PropType) objServicePK[pkCount+1]).strPropType;
						endingfilter.strFieldValue = endingPKs[endingfilter.strFieldName].ToString();
						sql += " AND " +objConfigInfo.strColumnPrefix + endingfilter.strFieldName +"<" +endingfilter.Delimiter() +
							endingfilter.strFieldValue +endingfilter.Delimiter();
						// FIXME why do we return directly from here?
						sql += " ) ";	
						sql += " ) ";*/
						return sql;
					}

					sql += " ) ";
				}

				if (endingPKs != null && endingPKs.Count > 0)
				{
					for (int pkCount = 0; pkCount < objServicePK.Count - 1; pkCount++)
					{
						sql += " OR ( ";
						for (int count1 = 0; count1 <= pkCount; count1++)
						{
							endingfilter.strFieldName = ((PropType)objServicePK[count1]).strPropName;
							endingfilter.strFieldType = ((PropType)objServicePK[count1]).strPropType;
							endingfilter.strFieldValue = endingPKs[endingfilter.strFieldName].ToString();
							//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
							// OleDbParameter was added to query
							//string parName = "@bpar14" + pkCount.ToString() + count1.ToString();
						    sql += objConfigInfo.strColumnPrefix + endingfilter.strFieldName + " = ? AND ";
							parameters.Add(new MTDbParameter(endingfilter.strFieldValue));
							/*sql += objConfigInfo.strColumnPrefix + endingfilter.strFieldName + "=" + endingfilter.Delimiter() +
								endingfilter.strFieldValue +endingfilter.Delimiter();
							sql += " AND ";*/
						}
						endingfilter.strFieldName = ((PropType)objServicePK[pkCount + 1]).strPropName;
						endingfilter.strFieldType = ((PropType)objServicePK[pkCount + 1]).strPropType;
						endingfilter.strFieldValue = endingPKs[endingfilter.strFieldName].ToString();

						//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
						// OleDbParametr's was added to query
						//string parName1 = "@bpar16" + pkCount.ToString();
						sql += objConfigInfo.strColumnPrefix + endingfilter.strFieldName + " < ? ) ";
						parameters.Add(new MTDbParameter(endingfilter.strFieldValue));
						/*sql += objConfigInfo.strColumnPrefix + endingfilter.strFieldName + "<" + endingfilter.Delimiter() +
							endingfilter.strFieldValue +endingfilter.Delimiter();
						sql += " ) ";*/
					}
				}

				sql += " ) "; // CR12639 need additional parens to enforce operator precedence
			}
			else
			{
				startingfilter.strFieldName = ((PropType)objServicePK[0]).strPropName;
				startingfilter.strFieldType = ((PropType)objServicePK[0]).strPropType;
				startingfilter.strFieldValue = startingPKs[startingfilter.strFieldName].ToString();

				//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
				// OleDbParametr's was added to query
				sql += " ( " + objConfigInfo.strColumnPrefix + startingfilter.strFieldName + " >= ?";
				parameters.Add(new MTDbParameter(startingfilter.strFieldValue));
				/*sql += " ( " + objConfigInfo.strColumnPrefix + startingfilter.strFieldName + ">=" + startingfilter.Delimiter() +
					startingfilter.strFieldValue + startingfilter.Delimiter();*/

				endingfilter.strFieldName = ((PropType)objServicePK[0]).strPropName;
				endingfilter.strFieldType = ((PropType)objServicePK[0]).strPropType;

				if (endingPKs != null && endingPKs[endingfilter.strFieldName] != null)
				{
					endingfilter.strFieldValue = endingPKs[endingfilter.strFieldName].ToString();

					//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
					// OleDbParametr's was added to query
					sql += " AND " + objConfigInfo.strColumnPrefix + endingfilter.strFieldName + " < ?";
					parameters.Add(new MTDbParameter(endingfilter.strFieldValue));
					/*sql += " AND " + objConfigInfo.strColumnPrefix + endingfilter.strFieldName + "<" + endingfilter.Delimiter()
						+ endingfilter.strFieldValue + endingfilter.Delimiter();*/
				}
				sql += " ) ";

			}

			return sql;
		}


		/// <summary>
		/// Sets the User context in the SessionSet object
		/// </summary>
		/// <param name="objSessionSet">Session set object whose details are to be set</param>
		private void SettingContextUserDetails(SessionSet objSessionSet)
		{
			if (objConfigInfo.bSessionContextDefined)
			{
				if ((objConfigInfo.strSerializedContext == null) || (objConfigInfo.strSerializedContext.Length == 0))
				{
					//					objSessionSet.SessionContextUserName = objConfigInfo.strSessionContextUserName;
					//					objSessionSet.SessionContextNamespace = objConfigInfo.strSessionContextNameSpace;
					//					objSessionSet.SessionContextPassword = objConfigInfo.strSessionContextPassword;

					objSessionSet.SetProperties(null,
												null,
												null,
												objConfigInfo.strSessionContextUserName,
												objConfigInfo.strSessionContextPassword,
												objConfigInfo.strSessionContextNameSpace);

				}
				else
				{
					// objSessionSet.SessionContext = objConfigInfo.strSerializedContext;
					objSessionSet.SetProperties(null,
												null,
												objConfigInfo.strSerializedContext,
												null,
												null,
												null);
				}
			}
		}

		/// <summary>
		/// Actual Metering is done here
		/// </summary>
		/// <param name="objMeter">Meter object used to meter the Sessions</param>
		public void Meter(ConfigInfo objConfigInfo)
		{
			object objServiceTable;
			ArrayList arrChildRS;
			Batch objBatch;
			string strLocalBatchName, strLocalBatchSpace;
			int iNumRecordsinBatch = 0;
			DateTime dtmStartTime = DateTime.Now;
			dtStartMeteringTime = DateTime.Now;
			Meter objMeter = objConfigInfo.objMeter;
			this.objConfigInfo = objConfigInfo;

			try
			{
				//Fix for CR#12826: This block got moved down after status table handling was added
				//Check if Batch Criteria is Flag and PK not defined, throw error
				if ((objConfigInfo.strBatchCriteria == ConfigInfo.FLAG) && (objServicePK.Count == 0))
				{
					throw new ApplicationException("Batch criteria is Flag and primary key definition is missing.");
				}

				if (bErrorMesgExists)
				{
					ValidationForTheMsgColumnWidth();
				}
				objTimezone = new ConvertTimeZoneClass();

				if (objConfigInfo.strBatchCriteria == ConfigInfo.FLAG)
				{
					statusTableSuffix = objConfigInfo.suffixforstatustable;
					//Setting the status table name
					statusTableName = ServiceDBTable() + statusTableSuffix;
					if ((objConfigInfo.strDBType.ToUpper() == "SYBASE") && (statusTableName.Length > 30))
					{
						int lengthofsuffix = statusTableSuffix.Length;
						if (lengthofsuffix > 30)
							throw new ApplicationException("The length of suffix can't be greater than 30");
						statusTableName = ServiceDBTable();
						statusTableName = statusTableName.Substring(0, 30 - lengthofsuffix);
						statusTableName += statusTableSuffix;
					}
					if ((objConfigInfo.strDBType.ToUpper() == "ORACLE") && (statusTableName.Length > 30))
					{
						throw new ApplicationException("The name of the status table '" + statusTableName + "' cannot exceed 30 characters");
					}

					//This call will create/recreate/validate the status table if needed based on its current state
					PreMeteringProcessingForStatus();

					switch (objConfigInfo.statusUpdateMode)
					{
						case 2: TruncateStatusTable(); break;
						case 3: UpdateMainTable(false);
							TruncateStatusTable();
							break;
						default: //Always truncate the table before inserting rows into Status table
							TruncateStatusTable();
							break;
					}

					InsertPKsIntoStatusTable();
				}



				GetColumnsDataType();

				objDAL = new DAL(objConfigInfo.strDBType, objConfigInfo.strDBDataSource, objConfigInfo.Provider, objConfigInfo.strDBServer,
					objConfigInfo.strDBName, objConfigInfo.strDBUsername, objConfigInfo.strDBPassword, objConfigInfo.strAppendToConnectionString);
				//Setting the configuration object for the Service Childrens
				for (int iChildCount = 0; iChildCount < objServiceChildren.Count; iChildCount++)
				{
					ServiceDef objChildServiceDef = (ServiceDef)objServiceChildren[iChildCount];
					objChildServiceDef.objConfigInfo = objConfigInfo;
					objChildServiceDef.GetColumnsDataType();
					//Initializing the objSessionsForCompound arraylist. It would store the total, min and max
					//child sessions for the compound sessions.
					SavingTheStatistics objSessionStats = new SavingTheStatistics(0, int.MaxValue, -1);
					objSessionsForCompound.Add(objSessionStats);
				}
				// Get all the batches present
				GetAllBatchIDs(objConfigInfo.strBatchCriteria);
				for (int iBatchCount = 0; iBatchCount < objlistBatchNames.Count; iBatchCount++)
				{
					//Get Batch Details
					string[] arrBatchDetails = objlistBatchNames[iBatchCount].ToString().Split(new char[] { '^' });
					strLocalBatchName = arrBatchDetails[0];
					strLocalBatchSpace = arrBatchDetails[1];
					iNumRecordsinBatch = int.Parse(arrBatchDetails[2]);

					objLog.LogString(Log.LogLevel.DEBUG, "Starting Metering for Service: " + strServiceName + " from Batch: " + strLocalBatchName);

					// Gets the parent record set to meter. Actual SQL statement is framed in GetParentRS method
					objServiceTable = GetParentRS(objConfigInfo.strBatchCriteria, strLocalBatchName, strLocalBatchSpace);
					objLog.LogString(Log.LogLevel.DEBUG, "Queried DB for recordset: " + /*objServiceTable.Rows.Count + */" records returned. " + " from Batch: " + strLocalBatchName);

					//GetChildRecordSets
					arrChildRS = GetChildArrayList(strLocalBatchName, strLocalBatchSpace);

					//Set Batch properties	
					objBatch = null;
					objBatch = objMeter.CreateBatch();
					objBatch.NameSpace = strLocalBatchSpace;
					objBatch.Name = strLocalBatchName;
					objBatch.ExpectedCount = iNumRecordsinBatch;
					objBatch.SourceCreationDate = DateTime.Now;
					objBatch.SequenceNumber = DateTime.Now.ToFileTime().ToString();
					try
					{
						objLog.LogString(Log.LogLevel.DEBUG, "Starting Batch.Save");
						objBatch.Save();
					}
					catch (Exception batchexception)
					{
						objLog.LogString(Log.LogLevel.ERROR, "Error found in Batch.Save. Please check the settings." + batchexception.Message);
						throw;
					}

					//If Verbose mode is set to true, print additional info on the screen
					if (MeterHelper.verboseMode)
					{
						Console.WriteLine(" Sending Batch Number: " + (iBatchCount + 1));
						objLog.LogString(Log.LogLevel.INFO, " Sending Batch Number: " + (iBatchCount + 1));
					}
					//Meter the session sets in a batch
					MeterSessionSetsInBatch(objBatch, objServiceTable, arrChildRS, strLocalBatchName, strLocalBatchSpace);
					System.Runtime.InteropServices.Marshal.ReleaseComObject(objBatch);
					objBatch = null;

					//Close the DAL object to free resources
					objDAL.Close();

					if (objServiceTable != null)
					{
						((IDisposable)objServiceTable).Dispose();
					}
					if (arrChildRS.Count > 0)
					{
						for (int iChildCount = 0; iChildCount < arrChildRS.Count; iChildCount++)
						{
							((IDisposable)(arrChildRS[iChildCount])).Dispose();
						}
					}
				}	//--End of Batch loop
				//Now, as we are now performing batch updates to status table. It can't be trucated
				//So update will happen at the end (after all batch has been processed)
				if (objConfigInfo.strBatchCriteria == ConfigInfo.FLAG)
				{
					//Update the main table from status table
					UpdateMainTable(true);
					TruncateStatusTable();
				}
				double dblTotalSeconds = ((TimeSpan)DateTime.Now.Subtract(dtmStartTime)).TotalSeconds; ;
				objLog.LogString(Log.LogLevel.DEBUG, "Total Time taken is: " + dblTotalSeconds.ToString());
				objLog.LogString(Log.LogLevel.INFO, "TPS is: " + ((double)(iTotalNoSessions / dblTotalSeconds)).ToString(DBL_FORMAT));

				//Logging the other debugging info
				LogOtherStatistics(objlistBatchNames);
				objLog.LogString(Log.LogLevel.DEBUG, "Finished Metering for Service: " + strServiceName);
			}
			catch (ApplicationException aex)
			{
				objLog.LogString(Log.LogLevel.FATAL, "Error in Metering: " + aex.Message);
				throw;
			}
			catch (Exception ex)
			{
				objLog.LogString(Log.LogLevel.FATAL, "Error in Metering: " + ex.Message);
				throw;
			}
			finally
			{
				if (objDAL != null)
				{
					objDAL.Close();
					objDAL = null;
				}
				if (objTimezone != null)
				{
					objTimezone.Close();
					objTimezone = null;
				}

			}
		}


		/// <summary>
		/// This function is used to meter and updat status of all the session sets in a batch
		/// </summary>
		/// <param name="objBatch">Batch object</param>
		/// <param name="objParentTable">OleDbDataReader object of the parent table</param>
		/// <param name="arrChildRS">List containing OleDbDataReader objects for child tables</param>
		/// <param name="strLocalBatchName">Batch name of the service</param>
		/// <param name="strLocalBatchSpace">Batch namespace of the service</param>
		private void MeterSessionSetsInBatch(Batch objBatch, object objParentTable, ArrayList arrChildRS, string strLocalBatchName, string strLocalBatchSpace)
		{
			int iSessionCount = 0, iNumChildren = 0, iSuccess = 0;
			int threadCount = 0;
			bool bFirstRecordProcessing = true;

			Hashtable startingPKs = null;
			Hashtable endingPKs = null;
			//ArrayList pkColumnNames = new ArrayList();
			Session objSession;
			bool bSessionSetEmpty = true;
			int iCompoundSessions = 0;
			iNoSessionSet = 0;
			string strSessionCloseErrorMsg;
			DataRow parentrow = null;
			DataTable table = null;
			OleDbDataReader reader = null;
			int parentrowcounter = 0;

			bIsBatchCriteriaFlag = false;
			DateTime dtStartSessionSetSendingTime = DateTime.Now;
			mapBetweenGUIDAndPK = new Hashtable();
			// SC: Used to hold the delegates created 
			// during asynchrounous CloseSessionSet calls
			ArrayList asyncResults = new ArrayList();

			SessionSet objSessionSet = objBatch.CreateSessionSet();
			//Setting serialized context  
			SettingContextUserDetails(objSessionSet);
			//set batch date - used for monitoring metering status
			strBatchDate = GetCurrentDate(strBatchDateFormat);

			if (objConfigInfo.strBatchCriteria == ConfigInfo.FLAG)
			{
				bIsBatchCriteriaFlag = true;
				/*
				for(int pkCount=0; pkCount<objServicePK.Count; pkCount++)
				{
					PropType objPK = (PropType)objServicePK[pkCount];
					string pkColumnName = objConfigInfo.strColumnPrefix + objPK.strPropName;
					pkColumnNames.Add( pkColumnName );
				}*/

			}

			//log session set created
			objLog.LogString(Log.LogLevel.DEBUG, "Created metering session set");

			//Sets the value into the OleDbDataReader/DataTable object based on the mode of the
			//database connection (Connected/Disconnected)
			if (objConfigInfo.isConnectedMode)
				reader = (OleDbDataReader)objParentTable;
			else
				table = (DataTable)objParentTable;

			//Run the while loop until rows are available
			while (GetNextRow(reader, table, ref parentrow, ref parentrowcounter))
			{
				iCompoundSessions++;
				if (objServiceChildren.Count > 0)
				{
					iNumChildren = 0;
					for (int childs = 1; childs <= objServiceChildren.Count; childs++)
					{
						if (objConfigInfo.isConnectedMode)
						{
							int ordinal = reader.GetOrdinal("childcount" + childs);
							object value = reader.GetValue(ordinal);
							iNumChildren += Convert.ToInt32(value); // reader.GetInt32(reader.GetOrdinal("childcount" + childs));
						}
						else
						{
							iNumChildren += Convert.ToInt32(parentrow["childcount" + childs]);
						}
					}
				}
				else
				{
					iNumChildren = 0;
				}

				//Adding Parent and Child sessions
				iTotalNoSessions += iNumChildren + 1;

				//keeps track of the number of sessions added in the session set
				iSessionCount = iSessionCount + iNumChildren + 1;

				//bSessionSetEmpty flag is used to take care of the situation where Compound Session contains
				//the childrens more than the max value set (in the config file). So whenever a new SessionSet
				//is created, this value is set to true
				if ((iSessionCount > iServiceMaxSessionSet) && !bSessionSetEmpty)
				{
					bFirstRecordProcessing = true;
					if (bIsBatchCriteriaFlag)
					{
						endingPKs = new Hashtable();
						for (int pkCount = 0; pkCount < objServicePK.Count; pkCount++)
						{
							string endingPK = GetPK(parentrow, reader, objConfigInfo.strColumnPrefix + ((PropType)objServicePK[pkCount]).strPropName);
							endingPKs.Add(((PropType)objServicePK[pkCount]).strPropName, endingPK);
						}
					}

					iNoSessionSet++;

					objLog.LogString(Log.LogLevel.DEBUG, "SessionSet Number: " + iNoSessionSet.ToString() + " Total no. of sessions: " + (iSessionCount - iNumChildren - 1));
					objLog.LogString(Log.LogLevel.DEBUG, "SessionSet Number: " + iNoSessionSet.ToString() + " Sending request first time.");

					//Closing the session set
					strSessionCloseErrorMsg = "";

					// SC: In the case of asynchronous metering, delegates are used to 
					// call CloseSessionSet using threads from the C# ThreadPool.
					// http://msdn.microsoft.com/library/default.asp?url=/library/en-us/cpguide/html/cpovrasynchronousprogrammingoverview.asp

					// The main thread collects the delegates and the IAsyncResult's created
					// by delegate.BeginInvoke. At the end of this method, EndInvoke
					// is called on each delegate so that the main thread is forced to block
					// until every delegate has finished running.

					// The ordering of calls to CloseSessionSet may be different from what
					// it would have been if all the calls were done on a single thread.

					// NOTE! Threading is not used for synchronous metering since the ordering 
					// of the calls to CloseSessionSet is important.
					if (bSynchronousService == false)
					{
						// When the number of threads spawned (threadCount) exceeds
						// a threshold (numberOfOutStandingThreads) then block until all
						// the threads have finished executing
						if ((threadCount % objConfigInfo.numberOfOutStandingThreads) == 0)
						{
							foreach (DelegateData tempDelegateData in asyncResults)
							{
								tempDelegateData.AsyncDelegate.EndInvoke(tempDelegateData.IAsyncResult);
							}
							asyncResults.Clear();
						}

						SessionSetData sessionSetData = new SessionSetData();
						sessionSetData.objSessionSet = objSessionSet;
						sessionSetData.startingPKs = startingPKs;
						sessionSetData.endingPKs = endingPKs;
						sessionSetData.strLocalBatchName = strLocalBatchName;
						sessionSetData.strLocalBatchSpace = strLocalBatchSpace;
						sessionSetData.iNoSessionSet = iNoSessionSet;
						sessionSetData.dtStartSessionSetSendingTime = dtStartSessionSetSendingTime;
						sessionSetData.iSessionCount = iSessionCount;
						sessionSetData.iNumChildren = iNumChildren;
						sessionSetData.iTotalNoSessions = iTotalNoSessions;
						sessionSetData.threadCount = threadCount;

						Hashtable mapBetweenGUIDAndPKCopy =
						 new Hashtable(mapBetweenGUIDAndPK, null, null);

						sessionSetData.aMapBetweenGUIDAndPK = mapBetweenGUIDAndPKCopy;

						AsyncDelegate asyncDelegate = new AsyncDelegate(CloseSessionSetThreadProc);
						IAsyncResult asyncResult =
						  asyncDelegate.BeginInvoke(sessionSetData, null, null);

						DelegateData delegateData = new DelegateData(asyncDelegate, asyncResult);
						asyncResults.Add(delegateData);

						// increment threadCount
						threadCount++;
					}
					else
					{
						iSuccess = CloseSessionSet(objSessionSet,
												   ref strSessionCloseErrorMsg,
												   mapBetweenGUIDAndPK);

						System.Runtime.InteropServices.Marshal.ReleaseComObject(objSessionSet);
						objSessionSet = null;

						if (iSuccess != 0)
						{
							objLog.LogString(Log.LogLevel.ERROR, "SessionSet Number: " + iNoSessionSet + " failed to close.");
						}

						//update metering status to either Sent or Failed depending on the Processing
						if (bIsBatchCriteriaFlag)
						{
							//iSuccess can have 3 values. 0, 1, -1.
							//0: Success. Update All records with status Sent.
							//-1: Failure. Update All records with Failed status and same error message.
							//1: Failure. But individual records have already been updated.
							if (iSuccess == 0)
								SetMeterStatusAll(strBatchDate,
												  "",
												  startingPKs,
												  endingPKs,
												  strLocalBatchName,
												  strLocalBatchSpace,
												  ConfigInfo.SENT,
												  mapBetweenGUIDAndPK);

							if (iSuccess == -1)
								SetMeterStatusAll(strBatchDate,
												   strSessionCloseErrorMsg,
												   startingPKs,
												   endingPKs,
												   strLocalBatchName,
												   strLocalBatchSpace,
												   ConfigInfo.NOTSENT,
												   mapBetweenGUIDAndPK);
						}

						//If Verbose mode is set to true, print additional info on the screen
						if (MeterHelper.verboseMode)
						{
							LogAdditionalInfo(dtStartMeteringTime, dtStartSessionSetSendingTime, (iSessionCount - iNumChildren - 1), (iTotalNoSessions - iNumChildren - 1));
							dtStartSessionSetSendingTime = DateTime.Now;
						}
					}

					mapBetweenGUIDAndPK.Clear();
					endingPKs = null;
					startingPKs = null;
					objLog.LogString(Log.LogLevel.DEBUG, "Closed metering session set");

					//create new Session Set
					objSessionSet = objBatch.CreateSessionSet();
					bSessionSetEmpty = true;
					SettingContextUserDetails(objSessionSet);

					iSessionCount = iNumChildren + 1;
					//update date of batch
					strBatchDate = GetCurrentDate(strBatchDateFormat);
					objLog.LogString(Log.LogLevel.DEBUG, "Created metering session set");

					//Storing the values of the compound sessions in the session set 
					objCompoundsForSessionSet.totalValue += iCompoundSessions - 1;
					if (objCompoundsForSessionSet.minValue > (iCompoundSessions - 1))
						objCompoundsForSessionSet.minValue = iCompoundSessions - 1;
					if (objCompoundsForSessionSet.maxValue < (iCompoundSessions - 1))
						objCompoundsForSessionSet.maxValue = iCompoundSessions - 1;

					iCompoundSessions = 0;
				}

				//Process and meter data
				objSession = null;
				objSession = objSessionSet.CreateSession(strServiceName);

				string sessID = objSession.SessionID;
				if (bIsBatchCriteriaFlag)
				{
					//Will do it later
					ArrayList pkValues = new ArrayList();
					for (int pCount = 0; pCount < objServicePK.Count; pCount++)
					{
						string pkvalue = GetPK(parentrow, reader, objConfigInfo.strColumnPrefix + ((PropType)objServicePK[pCount]).strPropName);
						pkValues.Add(pkvalue);
					}
					mapBetweenGUIDAndPK.Add(sessID, pkValues);
				}
				//Console.WriteLine( "For Session " +iSess +" sessid: " +objSession.SessionID +" length: " +objSession.SessionID.Length );
				bSessionSetEmpty = false;
				objSession.RequestResponse = bSynchronousService;
				objLog.LogString(Log.LogLevel.DEBUG, "Created metering session object");

				//To update the database at the end, Storing the Starting PK Id
				if (bFirstRecordProcessing && bIsBatchCriteriaFlag)
				{
					bFirstRecordProcessing = false;
					startingPKs = new Hashtable();
					for (int pkCount = 0; pkCount < objServicePK.Count; pkCount++)
					{
						string startingPK = GetPK(parentrow, reader, objConfigInfo.strColumnPrefix + ((PropType)objServicePK[pkCount]).strPropName);
						startingPKs.Add(((PropType)objServicePK[pkCount]).strPropName, startingPK);
					}
				}

				try
				{
					//Set the properties of the service
					if (objConfigInfo.isConnectedMode)
						SetServiceProperties(objSession, reader, arrChildRS);
					else
						SetServiceProperties(objSession, parentrow, arrChildRS);
				}
				catch (Exception ex)
				{
					objLog.LogString(Log.LogLevel.INFO, "Abandon the sessionset and update the database");

					if (bIsBatchCriteriaFlag)
					{
						endingPKs = new Hashtable();
						for (int pkCount = 0; pkCount < objServicePK.Count; pkCount++)
						{
							string endingPK = GetPK(parentrow, reader, objConfigInfo.strColumnPrefix + ((PropType)objServicePK[pkCount]).strPropName);
							endingPKs.Add(((PropType)objServicePK[pkCount]).strPropName, endingPK);
						}

						string[] startingPKarr = new string[objServicePK.Count];
						string[] endingPKarr = new string[objServicePK.Count];
						for (int pkCount = 0; pkCount < objServicePK.Count; pkCount++)
						{
							startingPKarr[pkCount] = (string)startingPKs[((PropType)objServicePK[pkCount]).strPropName];
							endingPKarr[pkCount] = (string)endingPKs[((PropType)objServicePK[pkCount]).strPropName];
						}
						if (!AreBothArraysEqual(startingPKarr, endingPKarr))
							SetMeterStatusAll(strBatchDate,
								 "",
								 startingPKs,
								 endingPKs,
								 strLocalBatchName,
								 strLocalBatchSpace,
								 ConfigInfo.NOTSENT,
								 mapBetweenGUIDAndPK);

						SetMeterStatus(strBatchDate, ex.Message, sessID, ConfigInfo.NOTSENT, mapBetweenGUIDAndPK);
						endingPKs = null;
						startingPKs = null;
					}

					System.Runtime.InteropServices.Marshal.ReleaseComObject(objSession);
					System.Runtime.InteropServices.Marshal.ReleaseComObject(objSessionSet);
					objSessionSet = null; objSession = null;
					objSessionSet = objBatch.CreateSessionSet();

					bFirstRecordProcessing = bSessionSetEmpty = true;
					iNoSessionSet++;
					mapBetweenGUIDAndPK.Clear();
					dtStartSessionSetSendingTime = DateTime.Now;
					//strStartingPK = strEndingPK = null;

					SettingContextUserDetails(objSessionSet);
					iSessionCount = 0;
					strBatchDate = GetCurrentDate(strBatchDateFormat);

					//Storing the values of the compound sessions in the session set 
					objCompoundsForSessionSet.totalValue += iCompoundSessions - 1;
					if (objCompoundsForSessionSet.minValue > (iCompoundSessions - 1))
						objCompoundsForSessionSet.minValue = iCompoundSessions - 1;
					if (objCompoundsForSessionSet.maxValue < (iCompoundSessions - 1))
						objCompoundsForSessionSet.maxValue = iCompoundSessions - 1;

					iCompoundSessions = 0;
					continue;
				}

				System.Runtime.InteropServices.Marshal.ReleaseComObject(objSession);
				objSession = null;

			} //--End of while(read) loop

			iNoSessionSet++;
			//objSessionsForSessionSet.Add(iSessionCount);
			objLog.LogString(Log.LogLevel.DEBUG, "SessionSet Number: " + iNoSessionSet.ToString() + " Total no. of sessions: " + (iSessionCount));
			objLog.LogString(Log.LogLevel.DEBUG, "SessionSet Number: " + iNoSessionSet.ToString() + " Sending request first time.");

			//close remaining session set
			strSessionCloseErrorMsg = "";
			iSuccess = CloseSessionSet(objSessionSet, ref strSessionCloseErrorMsg, mapBetweenGUIDAndPK);

			if (iSuccess != 0)
			{
				objLog.LogString(Log.LogLevel.ERROR, "SessionSet Number: " + iNoSessionSet + " failed to close.");
			}
			//update metering status to either Sent or Failed depending on the Processing
			if (bIsBatchCriteriaFlag)
			{
				//iSuccess can have 3 values. 0, 1, -1.
				//0: Success. Update All records with status Sent.
				//-1: Failure. Update All records with Failed status and same error message.
				//1: Failure. But individual records have already been updated.
				if (iSuccess == 0)
					SetMeterStatusAll(strBatchDate, "", startingPKs, endingPKs, strLocalBatchName, strLocalBatchSpace, ConfigInfo.SENT, mapBetweenGUIDAndPK);
				if (iSuccess == -1)
					SetMeterStatusAll(strBatchDate, strSessionCloseErrorMsg, startingPKs, endingPKs, strLocalBatchName, strLocalBatchSpace, ConfigInfo.NOTSENT, mapBetweenGUIDAndPK);
			}

			mapBetweenGUIDAndPK.Clear();
			//Freeing the resources
			System.Runtime.InteropServices.Marshal.ReleaseComObject(objSessionSet);
			objSessionSet = null;

			//If Verbose mode is set to true, print additional info on the screen
			if (MeterHelper.verboseMode)
			{
				LogAdditionalInfo(dtStartMeteringTime, dtStartSessionSetSendingTime, iSessionCount, iTotalNoSessions);
			}

			//Storing the values of the compound sessions for the session sets
			objCompoundsForSessionSet.totalValue += iCompoundSessions;
			if (objCompoundsForSessionSet.minValue > iCompoundSessions)
				objCompoundsForSessionSet.minValue = iCompoundSessions;
			if (objCompoundsForSessionSet.maxValue < iCompoundSessions)
				objCompoundsForSessionSet.maxValue = iCompoundSessions;
			//Storing the values of the session sets for the batches
			objSessionSetsForBatch.totalValue += iNoSessionSet;
			if (objSessionSetsForBatch.minValue > iNoSessionSet)
				objSessionSetsForBatch.minValue = iNoSessionSet;
			if (objSessionSetsForBatch.maxValue < iNoSessionSet)
				objSessionSetsForBatch.maxValue = iNoSessionSet;

			// SC: This will force the main thread to block until all 
			// the delegates have finished.
			foreach (DelegateData delegateData in asyncResults)
			{
				delegateData.AsyncDelegate.EndInvoke(delegateData.IAsyncResult);
			}

		}


		/// <summary>
		/// Closes the session set and if an error occurs, retries it using the properties
		/// stored in the config file for that error code
		/// </summary>
		/// <param name="objSessionSet">Session set object</param>
		/// <param name="strSessionCloseErrorMsg">Stores the error message</param>
		/// <returns>0, if sessionset close was successful, else -1</returns>
		int CloseSessionSet(SessionSet objSessionSet,
						ref string strSessionCloseErrorMsg,
						Hashtable aMapBetweenGUIDAndPK)
		{
			int iReturnValue = 0;
			Hashtable retriesTable = new Hashtable();
			while (true)
			{
				try
				{
					//throw new System.Runtime.InteropServices.COMException("customized error occured", 1111);
					objSessionSet.Close();
					return iReturnValue;
				}
				catch (System.Runtime.InteropServices.COMException cex)
				{
					objLog.LogString(Log.LogLevel.ERROR, "Error encountered while closing the session set:" + iNoSessionSet);
					objLog.LogString(Log.LogLevel.ERROR, "Error code:" + cex.ErrorCode + " Error message:" + cex.Message);

					if (objConfigInfo.bInteractive)
						throw;

					int iErrorCode = cex.ErrorCode;
					strSessionCloseErrorMsg = cex.Message;

					//Code for handling the valdation errors.
					if ((iErrorCode != MT_ERR_SERVER_BUSY) && (iErrorCode != MT_ERR_SYN_TIMEOUT))
					{
						MetraTech.Interop.COMMeter.IMTCollection parentArray = (MetraTech.Interop.COMMeter.IMTCollection)objSessionSet.GetSessions();
						for (int parentlength = 1; parentlength <= parentArray.Count; parentlength++)
						{
							string msg = "";
							Session parentSession = (Session)parentArray[parentlength];
							if (parentSession.ErrorCode != 0)
								msg = parentSession.ErrorMessage + "::";

							MetraTech.Interop.COMMeter.IMTCollection childArray = (MetraTech.Interop.COMMeter.IMTCollection)parentSession.GetChildSessions();
							for (int childlength = 1; childlength <= childArray.Count; childlength++)
							{
								Session childSession = (Session)childArray[childlength];
								if (childSession.ErrorCode != 0)
									msg += childSession.ErrorMessage + "::";
							}
							SetMeterStatus(strBatchDate, msg, parentSession.SessionID, ConfigInfo.NOTSENT, aMapBetweenGUIDAndPK);
						}
						return 1;
					}

					//The next code is written for handling the other errors (Synchronous timeout & Routing queue full)
					// If ErrorHandling (retry properties) for this error code hasn't been defined
					if (objConfigInfo.errorHandlingProps[iErrorCode] == null)
					{
						return -1;
					}

					ErrorCodeProps errorProps;
					//Add the retries (already made) for the error code in the HashTable
					if (retriesTable[iErrorCode] == null)
					{
						retriesTable.Add(iErrorCode, 0);
					}

					// Reading the error code properties from the Config Info
					errorProps = (ErrorCodeProps)objConfigInfo.errorHandlingProps[iErrorCode];
					int num_retry = Convert.ToInt32(retriesTable[iErrorCode]);
					if (num_retry < errorProps.noOfretries)
					{
						//objLog.LogString( Log.LogLevel.WARNING, "Error Code " +iErrorCode.ToString() +" : " +errorProps.errorMsg ); 
						if (iErrorCode == MT_ERR_SERVER_BUSY)
						{
							double sleepingmin = ((double)(errorProps.sleepTime + errorProps.sleepIncrement * num_retry)) / 60;
							objLog.LogString(Log.LogLevel.INFO, "Sleeping for " + sleepingmin.ToString("0.00") + " minutes.");
							if (MeterHelper.verboseMode)
							{
								Console.WriteLine("Sleeping for " + sleepingmin.ToString("0.00") + " minutes.");
							}
						}

						System.Threading.Thread.Sleep((errorProps.sleepTime + errorProps.sleepIncrement * num_retry) * 1000);
						num_retry++;
						retriesTable[iErrorCode] = num_retry; //resetting the retries made
					}
					else
					{
						return -1;
					}

				}
				catch (Exception ex)
				{
					if (objConfigInfo.bInteractive)
						throw;
					else
					{
						strSessionCloseErrorMsg = ex.Message;
					}
					return -1;
				}/*Catch exception*/
			}
		}

		/// <summary>
		/// Used to cast the value into the object based on the type passed.
		/// </summary>
		/// <param name="strFieldValue">Value of the object</param>
		/// <param name="strCastType">Type of value</param>
		/// <returns></returns>
		private object CastProperty(object strFieldValue, string strCastType)
		{
			object objFieldVal;
			switch (strCastType)
			{
				case "string":
					objFieldVal = strFieldValue;
					break;
				case "unistring":
					objFieldVal = strFieldValue;
					break;
				case "int32":
					objFieldVal = Convert.ToInt32(strFieldValue);
					break;
				case "integer":
					objFieldVal = Convert.ToInt32(strFieldValue);
					break;
				case "long":
					objFieldVal = Convert.ToInt64(strFieldValue);
					break;
				case "timestamp":
					DateTime dtTime = Convert.ToDateTime(strFieldValue);
					//CR#12662: No way to disable TimeZone conversion
					if (objConfigInfo.strLocalTimeZone != null && objConfigInfo.strLocalTimeZone.Length > 0)
						objFieldVal = objTimezone.ConvertToGMT(dtTime, objConfigInfo.strLocalTimeZone);
					else
						objFieldVal = dtTime;
					objLog.LogString(Log.LogLevel.INFO, "ConvertToGMT, Before: " + dtTime.ToString() + ", After: " + objFieldVal.ToString());
					break;
				case "double":
					objFieldVal = Convert.ToDouble(strFieldValue);
					break;
				case "float":
					objFieldVal = Convert.ToDecimal(strFieldValue);
					break;
				case "bool":
					string strValue = strFieldValue.ToString().ToUpper();
					objFieldVal = (strValue == "TRUE" || strValue == "1" || strValue == "T");
					break;
				case "boolean":
					string strValue1 = strFieldValue.ToString().ToUpper();
					objFieldVal = (strValue1 == "TRUE" || strValue1 == "1" || strValue1 == "T");
					break;
				default:
					objFieldVal = strFieldValue;
					break;
			}
			return objFieldVal;
		}

		/// <summary>
		/// Sets the ConfigInfo object
		/// </summary>
		/// <param name="objConInfo">ConfigInfo object</param>
		public void SetConfigInfo(ConfigInfo objConInfo)
		{
			this.objConfigInfo = objConInfo;
		}

		/// <summary>
		/// Gets the propert data in PropType object given the xml node
		/// </summary>
		/// <param name="objPropType">PropType object</param>
		/// <param name="objPropXML">xml node</param>
		public void GetPropData(ref PropType objPropType, XmlNode objPropXML)
		{
			objPropType.strPropName = objPropXML.SelectSingleNode("dn").InnerText;
			objPropType.strPropType = objPropXML.SelectSingleNode("type").InnerText;
			objPropType.strPropDefault = objPropXML.SelectSingleNode("defaultvalue").InnerText;
			objPropType.propLength = 0;
			if (objPropXML.SelectSingleNode("length").InnerText.Trim().Length > 0)
			{
				objPropType.propLength = Convert.ToInt32(objPropXML.SelectSingleNode("length").InnerText);
			}
		}

		/// <summary>
		/// Gets the propert data in PropType object given the xml node
		/// </summary>
		/// <param name="objPropType">PropType object</param>
		/// <param name="objPropXML">xml node</param>
		/// <param name="nsmgr">The namespacemanger where to look for the tags</param>
		public void GetPropData(ref PropType objPropType, XmlNode objPropXML, XmlNamespaceManager nsmgr)
		{
			objPropType.strPropName = objPropXML.SelectSingleNode("dbmpns:dn", nsmgr).InnerText;
			objPropType.strPropType = objPropXML.SelectSingleNode("dbmpns:type", nsmgr).InnerText;
			objPropType.strPropDefault = objPropXML.SelectSingleNode("dbmpns:defaultvalue", nsmgr).InnerText;
			objPropType.propLength = 0;
			if (objPropXML.SelectSingleNode("dbmpns:length", nsmgr).InnerText.Length > 0)
			{
				objPropType.propLength = Convert.ToInt32(objPropXML.SelectSingleNode("dbmpns:length", nsmgr).InnerText);
			}
		}

		/// <summary>
		/// This function is used to log the other statistics needed for debugging
		/// </summary>
		/// <param name="objBatchList">Arraylist stores the list of batches</param>
		private void LogOtherStatistics(ArrayList objBatchList)
		{
			try
			{
				objLog.LogString(Log.LogLevel.INFO, "--------------------- Other Statistics ---------------------");
				objLog.LogString(Log.LogLevel.INFO, "Total number of batches created: " + objBatchList.Count);
				objLog.LogString(Log.LogLevel.INFO, "Total number of session sets created: " + objSessionSetsForBatch.totalValue);
				objLog.LogString(Log.LogLevel.INFO, "Total number of compounds created: " + objCompoundsForSessionSet.totalValue);
				objLog.LogString(Log.LogLevel.INFO, "Total number of sessions created: " + iTotalNoSessions);
				objLog.LogString(Log.LogLevel.INFO, "Min/Max/Avg session sets for a batch: " + objSessionSetsForBatch.minValue + ", " +
						objSessionSetsForBatch.maxValue + ", " + ((double)(((double)objSessionSetsForBatch.totalValue) / objBatchList.Count)).ToString(DBL_FORMAT));

				objLog.LogString(Log.LogLevel.INFO, "Min/Max/Avg compounds for a session set: " + objCompoundsForSessionSet.minValue + ", " +
					objCompoundsForSessionSet.maxValue + ", " + ((double)(((double)objCompoundsForSessionSet.totalValue) / objSessionSetsForBatch.totalValue)).ToString(DBL_FORMAT));

				for (int iChildCount = 0; iChildCount < objServiceChildren.Count; iChildCount++)
				{
					string strServiceName = ((ServiceDef)objServiceChildren[iChildCount]).strServiceName;
					int iMinChildSessions = ((SavingTheStatistics)(objSessionsForCompound[iChildCount])).minValue;
					int iMaxChildSessions = ((SavingTheStatistics)(objSessionsForCompound[iChildCount])).maxValue;
					double dblAvgChildSessions = Convert.ToDouble(((SavingTheStatistics)(objSessionsForCompound[iChildCount])).totalValue) / objCompoundsForSessionSet.totalValue;

					objLog.LogString(Log.LogLevel.INFO, "Min/Max/Avg child sessions(" + strServiceName + ") for a compound: " + (iMinChildSessions == int.MaxValue ? 0 : iMinChildSessions) +
						", " + (iMaxChildSessions == -1 ? 0 : iMaxChildSessions) + ", " + dblAvgChildSessions.ToString(DBL_FORMAT));

				}
				objLog.LogString(Log.LogLevel.INFO, "------------------------------------------------------------");
			}
			catch (Exception exp)
			{
				objLog.LogString(Log.LogLevel.ERROR, "Error while logging the statistics: " + exp.Message);
			}

		}

		/// <summary>
		/// Logging additional info needed for debugging the problem.
		/// </summary>
		/// <param name="dtMeteringStartTime"></param>
		/// <param name="dtSessionSetStartTime"></param>
		/// <param name="noOfLastSessions"></param>
		/// <param name="noOfTotalSessions"></param>
		private void LogAdditionalInfo(DateTime dtMeteringStartTime, DateTime dtSessionSetStartTime, int noOfLastSessions, int noOfTotalSessions)
		{
			try
			{
				double timeforBuildingSession = ((TimeSpan)DateTime.Now.Subtract(dtSessionSetStartTime)).TotalSeconds;
				double totaltime = ((TimeSpan)DateTime.Now.Subtract(dtMeteringStartTime)).TotalSeconds;

				double tpsforlastsession = ((double)noOfLastSessions) / timeforBuildingSession;
				double tpsout = ((double)noOfTotalSessions) / totaltime; ;
				Console.WriteLine(" Total SessionSets Sent: " + iNoSessionSet.ToString());
				Console.WriteLine(" Total Sessions sent:  " + noOfTotalSessions.ToString());
				Console.WriteLine(" Time taken to build and send the last session set: " + timeforBuildingSession.ToString(DBL_FORMAT));
				Console.WriteLine(" TPS for the last session: " + tpsforlastsession.ToString(DBL_FORMAT));
				Console.WriteLine(" Average TPS out: " + tpsout.ToString(DBL_FORMAT));
				objLog.LogString(Log.LogLevel.INFO, " Total SessionSets Sent: " + iNoSessionSet.ToString());
				objLog.LogString(Log.LogLevel.INFO, " Total Sessions sent:  " + noOfTotalSessions.ToString());
				objLog.LogString(Log.LogLevel.INFO, " Time taken to build and send the last session set: " + timeforBuildingSession.ToString(DBL_FORMAT));
				objLog.LogString(Log.LogLevel.INFO, " TPS for the last session: " + tpsforlastsession.ToString(DBL_FORMAT));
				objLog.LogString(Log.LogLevel.INFO, " Average TPS out: " + tpsout.ToString(DBL_FORMAT));
			}
			catch (Exception ex)
			{
				Console.WriteLine("Error while logging additional info:" + ex.Message);
			}
		}

		/// <summary>
		/// Returns the value for the PK
		/// </summary>
		/// <param name="parentRow">DataRow object</param>
		/// <param name="parentReader">OleDbDataReader object</param>
		/// <param name="pkColumnName">PK column name</param>
		/// <returns>value for the PK</returns>
		private string GetPK(DataRow parentRow, OleDbDataReader parentReader, string pkColumnName)
		{

			if (objConfigInfo.isConnectedMode)
			{
				if (Convert.ToInt32(arePKColumnsDate[pkColumnName]) == 1)
				{
					DateTime d = Convert.ToDateTime(parentReader[pkColumnName]);
					return d.ToString("yyyy-M-dd HH:mm:ss.fff");
				}
				else
					return parentReader[pkColumnName].ToString();
			}
			else
			{
				if (Convert.ToInt32(arePKColumnsDate[pkColumnName]) == 1)
				{
					DateTime d1 = Convert.ToDateTime(parentRow[pkColumnName]);
					return d1.ToString("yyyy-M-dd HH:mm:ss.fff");
				}
				else
				{
					return parentRow[pkColumnName].ToString();
				}
			}
		}


		/// <summary>
		/// This function is used to retrieve the Data Types for the column to handle the validation
		/// for the DateTime columns
		/// </summary>
		private void GetColumnsDataType()
		{
			try
			{
				//SECEND:
				List<MTDbParameter> parameters = new List<MTDbParameter>();
				string tableName = objConfigInfo.strTablePrefix + strTableName;
				string query = String.Empty;
				if (arePKColumnsDate.Count > 0)
					return;

				if (objConfigInfo.strDBType.ToUpper() == "MSSQL" || objConfigInfo.strDBType.ToUpper() == "SYBASE")
				{
					if (objConfigInfo.strDBType.ToUpper() == "MSSQL")
					{
						query = "SELECT so.name name, systypes.name type from syscolumns so inner join sysobjects on " +
						  "so.id = sysobjects.id inner join systypes on systypes.xtype = so.xtype and systypes.xusertype = so.xusertype " +
									  "where sysobjects.name = ?";
						parameters.Add(new MTDbParameter(tableName));
					}
					else if (objConfigInfo.strDBType.ToUpper() == "SYBASE")
					{
						query = "SELECT so.name name, systypes.name type from syscolumns so inner join sysobjects on " +
						  "so.id = sysobjects.id inner join systypes on systypes.usertype = so.usertype where " +
									  "sysobjects.name = ?";
						parameters.Add(new MTDbParameter(tableName));
					}


					DAL objDAL = null;
					objDAL = new DAL(objConfigInfo.strDBType, objConfigInfo.strDBDataSource, objConfigInfo.Provider, objConfigInfo.strDBServer,
					  objConfigInfo.strDBName, objConfigInfo.strDBUsername, objConfigInfo.strDBPassword, objConfigInfo.strAppendToConnectionString);

					//SECEND:
					DataTable columnTypes = objDAL.RunGetDataTable(query, parameters.ToArray());
					//DataTable columnTypes = new DataTable();
					//objDAL.Run(columnTypes, query);
					//objDAL.Close();
					for (int totalcolumns = 0; totalcolumns < columnTypes.Rows.Count; totalcolumns++)
					{
						string columnname = columnTypes.Rows[totalcolumns]["name"].ToString();
						string datatype = columnTypes.Rows[totalcolumns]["type"].ToString().ToUpper();
						if (datatype == "DATETIME")
							arePKColumnsDate.Add(columnname, 1);
						else
							arePKColumnsDate.Add(columnname, 0);

					}
				}
				else if (objConfigInfo.strDBType.ToUpper() == "ORACLE")
				{
					oracleDB.MarkDateColumns(arePKColumnsDate, tableName);
				}
				else
				{
					throw new ApplicationException("The DB type(" + objConfigInfo.strDBType + ") is not supported");
				}
			}
			catch (Exception ex)
			{
				objLog.LogString(Log.LogLevel.ERROR, "Error encountered while retrieving the column datatypes:" + ex.Message);
				throw;
			}

		}


		/// <summary>
		/// Returns true/false if finds next row.
		/// Also moves to next row. 
		/// </summary>
		/// <param name="reader">OleDbDataReader object</param>
		/// <param name="table">DataTable object</param>
		/// <param name="parentRow">DataRow object</param>
		/// <param name="counter">points to the current row in the DataTable</param>
		/// <returns>true/false</returns>
		private bool GetNextRow(OleDbDataReader reader, DataTable table, ref DataRow parentRow, ref int counter)
		{
			bool nextRowFound = false;
			if (!objConfigInfo.isConnectedMode)
			{
				if (counter < table.Rows.Count)
				{
					parentRow = null;
					parentRow = table.Rows[counter];
					nextRowFound = true;
					counter++;
				}
			}
			else
			{
				nextRowFound = reader.Read();
			}
			return nextRowFound;
		}

		/// <summary>
		/// This function is used to return the arraylist containing the child objects
		/// of type DataTable/OleDbDataReader.
		/// </summary>
		/// <param name="batchname"></param>
		/// <param name="batchspace"></param>
		/// <returns>ArrayList containing child objects</returns>
		private ArrayList GetChildArrayList(string batchname, string batchspace)
		{
			ArrayList arrChildList = new ArrayList();
			for (int iChildCount = 0; iChildCount < objServiceChildren.Count; iChildCount++)
			{
				object objChildTable = GetChildRS(objConfigInfo.strBatchCriteria, batchname, batchspace, iChildCount);
				if (objConfigInfo.isConnectedMode)
				{
					if (((OleDbDataReader)objChildTable).Read() == false)
					{
						((OleDbDataReader)objChildTable).Close();
					}
				}
				arrChildList.Add(objChildTable);
			}
			return arrChildList;

		}

		/// <summary>
		/// This function is called to update the database if the validation error occured while 
		/// parsing the session set.
		/// </summary>
		/// <param name="strBatchDate">date to be updated in the senttimestamp column</param>
		/// <param name="strErrorMesg">message string to be updated in the Error message column</param>
		/// <param name="sessionId">Unique id for the session</param>
		/// <param name="strFinalStatus">Status to be updated in the db</param>
		private void SetMeterStatus(string strBatchDate,
								string strErrorMesg,
								string sessionId,
								string strFinalStatus,
								Hashtable aMapBetweenGUIDAndPK)
		{
			string strSQL = null;
			//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
			// OleDbParametr's was added to query
			DAL objDAL = null;
			List<MTDbParameter> parameters = new List<MTDbParameter>();
			ArrayList pkIDs;
			FieldFilter startingfilter;
			try
			{
				if (!bIsBatchCriteriaFlag)
					return;

				pkIDs = (ArrayList)(aMapBetweenGUIDAndPK[sessionId]);
				//Retrieve the PK for the passed session id
				strSQL = "update " + statusTableName + " set " + objConfigInfo.strColumnPrefix;
				//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
				// OleDbParametr's was added to query
				strSQL += objServiceCriteriaField.strPropName + " = ? ";
				parameters.Add(new MTDbParameter(strFinalStatus));
				//strSQL += objServiceCriteriaField.strPropName + "='" + strFinalStatus + "'";


				if (bSentTimeStampExists)
				{
					//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
					// OleDbParametr's was added to query
					strSQL += " , " + objConfigInfo.strColumnPrefix + objSentTimeStamp.strPropName + " = ? ";
					parameters.Add(new MTDbParameter(strBatchDate));
					//strSQL += " , " + objConfigInfo.strColumnPrefix + objSentTimeStamp.strPropName + " = '" + strBatchDate + "'";
				}

				if (bErrorMesgExists)
				{
					strErrorMesg = strErrorMesg.Replace("'", "''");
					if (strErrorMesg.Length > objErrorMesg.propLength)
					{
						strErrorMesg = strErrorMesg.Substring(0, objErrorMesg.propLength);
					}
					//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
					// OleDbParametr's was added to query
					strSQL += " ," + objConfigInfo.strColumnPrefix + objErrorMesg.strPropName + " = ? ";
					parameters.Add(new MTDbParameter(strErrorMesg));
					//strSQL += " ," + objConfigInfo.strColumnPrefix + objErrorMesg.strPropName + " = '" + strErrorMesg + "'";
				}

				strSQL += " where ";

				startingfilter.strFieldName = ((PropType)objServicePK[0]).strPropName;
				startingfilter.strFieldType = ((PropType)objServicePK[0]).strPropType;
				startingfilter.strFieldValue = pkIDs[0].ToString();
				//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
				// OleDbParametr's was added to query
				strSQL += objConfigInfo.strColumnPrefix + startingfilter.strFieldName + " = ? ";
				parameters.Add(new MTDbParameter(startingfilter.strFieldValue));
				//strSQL += objConfigInfo.strColumnPrefix + startingfilter.strFieldName + "=" + startingfilter.Delimiter() + startingfilter.strFieldValue + startingfilter.Delimiter();

				for (int pkcount = 1; pkcount < objServicePK.Count; pkcount++)
				{
					startingfilter.strFieldName = ((PropType)objServicePK[pkcount]).strPropName;
					startingfilter.strFieldType = ((PropType)objServicePK[pkcount]).strPropType;
					startingfilter.strFieldValue = pkIDs[pkcount].ToString();
					//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
					// OleDbParametr's was added to query
					//string parameterName = "@SetMeterStatus_par" + pkcount.ToString();
					strSQL += " AND " + objConfigInfo.strColumnPrefix + startingfilter.strFieldName + " = ? ";
					parameters.Add(new MTDbParameter(startingfilter.strFieldValue));
					//strSQL += " AND " + objConfigInfo.strColumnPrefix + startingfilter.strFieldName + "=" + 
					//	startingfilter.Delimiter() + startingfilter.strFieldValue + startingfilter.Delimiter();
				}

				objDAL = new DAL(objConfigInfo.strDBType, objConfigInfo.strDBDataSource, objConfigInfo.Provider, objConfigInfo.strDBServer,
					objConfigInfo.strDBName, objConfigInfo.strDBUsername, objConfigInfo.strDBPassword, objConfigInfo.strAppendToConnectionString);
				//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
				// method for query to DB was replaced
				objDAL.RunExecuteNonQuery(strSQL, parameters.ToArray());
				//objDAL.Run(strSQL);
			}
			catch (Exception ex)
			{
				objLog.LogString(Log.LogLevel.ERROR, "Error in the SetMeterStatus: " + ex.Message);
				throw;
			}
			finally
			{
				if (objDAL != null)
					objDAL.Close();
			}
		}

		/// <summary>
		/// This function is used to do the validation for the error message column in the database
		/// </summary>
		private void ValidationForTheMsgColumnWidth()
		{
			//SECEND:
			List<MTDbParameter> parameters = new List<MTDbParameter>();
			string strSQL;
			DAL objDAL = null;
			string databasecolumn = "";
			int errorcolumnlength = 0;

			DataTable errorTable = new DataTable();

			if (objConfigInfo.strDBType.ToUpper() == "MSSQL")
				databasecolumn = "prec";
			else if (objConfigInfo.strDBType.ToUpper() == "SYBASE")
				databasecolumn = "length";

			if (objConfigInfo.strDBType.ToUpper() == "MSSQL" || objConfigInfo.strDBType.ToUpper() == "SYBASE")
			{
				strSQL = "SELECT " + databasecolumn + " from syscolumns inner join sysobjects on syscolumns.id = sysobjects.id where ";
				strSQL += "sysobjects.name = ? and syscolumns.name = ?";
				//SECEND:
				parameters.Add(new MTDbParameter(ServiceDBTable()));
				parameters.Add(new MTDbParameter(objConfigInfo.strColumnPrefix + objErrorMesg.strPropName));

				objDAL = new DAL(objConfigInfo.strDBType, objConfigInfo.strDBDataSource, objConfigInfo.Provider, objConfigInfo.strDBServer,
				  objConfigInfo.strDBName, objConfigInfo.strDBUsername, objConfigInfo.strDBPassword, objConfigInfo.strAppendToConnectionString);
				errorTable = objDAL.RunGetDataTable(strSQL, parameters.ToArray());
				//objDAL.Run(errorTable, strSQL);
				errorcolumnlength = Convert.ToInt32(errorTable.Rows[0][0]);
				//objDAL.Close();
			}
			else if (objConfigInfo.strDBType.ToUpper() == "ORACLE")
			{
				oracleDB.ConnectionString = objConfigInfo.GetOracleConnectionString();
				errorcolumnlength = oracleDB.GetColumnWidth(ServiceDBTable(), objConfigInfo.strColumnPrefix + objErrorMesg.strPropName);
			}
			else
			{
				throw new ApplicationException("The DB type(" + objConfigInfo.strDBType + ") is not supported");
			}

			if (errorcolumnlength < objErrorMesg.propLength)
			{
				throw new ApplicationException("The length of the error message column is less than that defined in the config file.");
			}
		}


		/// <summary>
		/// This function is used to compare the 2 arrays to find out if they are equal
		/// </summary>
		/// <param name="parentIds"></param>
		/// <param name="childIds"></param>
		/// <returns></returns>
		private bool AreBothArraysEqual(string[] parentIds, string[] childIds)
		{
			bool arraysequal = true;

			for (int i = 0; i < parentIds.Length; i++)
			{
				if (parentIds[i] != childIds[i])
				{
					arraysequal = false;
					break;
				}
			}
			return arraysequal;
		}

		void InsertPKsIntoStatusTable()
		{
			string insertPKSQL = "";
			string statusfield = objConfigInfo.strColumnPrefix + objServiceCriteriaField.strPropName;
			string errorfield = objConfigInfo.strColumnPrefix + objErrorMesg.strPropName;
			string sentfield = objConfigInfo.strColumnPrefix + objSentTimeStamp.strPropName;
			string servicetable = ServiceDBTable();
			string prefix = objConfigInfo.strColumnPrefix;
			string batchid = objConfigInfo.strColumnPrefix + objBatchID.strPropName;
			string batchnamespace = objConfigInfo.strColumnPrefix + objBatchNamespace.strPropName;

			insertPKSQL = "INSERT INTO " + statusTableName + "(";
			insertPKSQL += prefix + ((PropType)objServicePK[0]).strPropName + ",";
			for (int pkCount = 1; pkCount < objServicePK.Count; pkCount++)
			{
				insertPKSQL += prefix + ((PropType)objServicePK[pkCount]).strPropName + ",";
			}
			insertPKSQL += batchid + "," + batchnamespace + ",";
			insertPKSQL += statusfield + ")";
			insertPKSQL += " SELECT " + prefix + ((PropType)objServicePK[0]).strPropName + ",";
			for (int pkCount = 1; pkCount < objServicePK.Count; pkCount++)
			{
				insertPKSQL += prefix + ((PropType)objServicePK[pkCount]).strPropName + ",";
			}
			insertPKSQL += batchid + "," + batchnamespace + ",";
			insertPKSQL += statusfield + " FROM " + servicetable + " WHERE ";
			insertPKSQL += "(" + statusfield;
			insertPKSQL += " like '" + ConfigInfo.NOTSENT + "%' OR " + statusfield + " is NULL)";

			//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
			// method for query to DB was replaced 
			DAL objDAL = new DAL(objConfigInfo.strDBType, objConfigInfo.strDBDataSource, objConfigInfo.Provider, objConfigInfo.strDBServer,
				objConfigInfo.strDBName, objConfigInfo.strDBUsername, objConfigInfo.strDBPassword, objConfigInfo.strAppendToConnectionString);
			objDAL.RunExecuteNonQuery(insertPKSQL, null);
			//objDAL.Run(insertPKSQL);
			objDAL.Close();

		}
		/// <summary>
		/// This function is used to update the service table from status table
		/// </summary>
		private void UpdateMainTable(bool lastupdate)
		{
			string updateSQL = "";
			string statusfield = objConfigInfo.strColumnPrefix + objServiceCriteriaField.strPropName;
			string errorfield = objConfigInfo.strColumnPrefix + objErrorMesg.strPropName;
			string sentfield = objConfigInfo.strColumnPrefix + objSentTimeStamp.strPropName;
			string servicetable = "";
			string prefix = objConfigInfo.strColumnPrefix;
			if (lastupdate && (objConfigInfo.updatetablename != null && objConfigInfo.updatetablename.Length > 0))
				servicetable = objConfigInfo.updatetablename;
			else
				servicetable = ServiceDBTable();

			if ((objConfigInfo.strDBType.ToUpper() == "SYBASE") ||
				(objConfigInfo.strDBType.ToUpper() == "MSSQL"))
			{
				updateSQL = "UPDATE " + servicetable + " SET " + servicetable + "." + statusfield + "=" + statusTableName + "." + statusfield;

				if (bSentTimeStampExists)
				{
					updateSQL += "," + servicetable + "." + sentfield + "=" + statusTableName + "." + sentfield;
				}
				if (bErrorMesgExists)
				{
					updateSQL += "," + servicetable + "." + errorfield + "=" + statusTableName + "." + errorfield;
				}

				updateSQL += " FROM " + servicetable + " inner join " + statusTableName + " on ";
				updateSQL += servicetable + "." + prefix + ((PropType)objServicePK[0]).strPropName + "=" + statusTableName + "." + prefix + ((PropType)objServicePK[0]).strPropName;
				for (int pkCount = 1; pkCount < objServicePK.Count; pkCount++)
				{
					updateSQL += " AND " +
								 servicetable + "." + prefix + ((PropType)objServicePK[pkCount]).strPropName + "=" +
								 statusTableName + "." + prefix + ((PropType)objServicePK[pkCount]).strPropName;
				}

				DAL objDAL = new DAL(objConfigInfo.strDBType, objConfigInfo.strDBDataSource, objConfigInfo.Provider, objConfigInfo.strDBServer,
				  objConfigInfo.strDBName, objConfigInfo.strDBUsername, objConfigInfo.strDBPassword, objConfigInfo.strAppendToConnectionString);
				//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
				// method for query to DB was replaced
				objDAL.RunExecuteNonQuery(updateSQL, null);
				//objDAL.Run(updateSQL);
				objDAL.Close();
			}
			else if (objConfigInfo.strDBType.ToUpper() == "ORACLE")
			{
				List<string> primaryKeyNames = new List<string>();
				string columnName = String.Empty;
				for (int count = 0; count < objServicePK.Count; count++)
				{
					columnName = objConfigInfo.strColumnPrefix + ((PropType)objServicePK[count]).strPropName;
					primaryKeyNames.Add(columnName.ToUpper());
				}

				List<string> otherColumnNames = new List<string>();
				columnName = objConfigInfo.strColumnPrefix + objServiceCriteriaField.strPropName;
				otherColumnNames.Add(columnName.ToUpper());
				columnName = objConfigInfo.strColumnPrefix + objErrorMesg.strPropName;
				otherColumnNames.Add(columnName.ToUpper());
				columnName = objConfigInfo.strColumnPrefix + objSentTimeStamp.strPropName;
				otherColumnNames.Add(columnName.ToUpper());

				oracleDB.UpdateServiceTable(servicetable, statusTableName, primaryKeyNames, otherColumnNames);
			}
			else
			{
				throw new ApplicationException("The DB type(" + objConfigInfo.strDBType + ") is not supported");
			}

		}

		/// <summary>
		/// This function is used to delete all rows from service table
		/// </summary>
		private void TruncateStatusTable()
		{
			if (objConfigInfo.strDBType.ToUpper() == "ORACLE")
			{
				oracleDB.TruncateTable(statusTableName);
			}
			else
			{
				string deleteSQL = "";

				deleteSQL = "TRUNCATE TABLE " + statusTableName;
				DAL objDAL = new DAL(objConfigInfo.strDBType, objConfigInfo.strDBDataSource, objConfigInfo.Provider, objConfigInfo.strDBServer,
				  objConfigInfo.strDBName, objConfigInfo.strDBUsername, objConfigInfo.strDBPassword, objConfigInfo.strAppendToConnectionString);
				//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
				// method for query to DB was replaced
				objDAL.RunExecuteNonQuery(deleteSQL, null);
				//objDAL.Run(deleteSQL);
				objDAL.Close();
			}
		}

		/// <summary>
		/// This function is used to Modify the status table before starting the metering
		/// </summary>
		private void PreMeteringProcessingForStatus()
		{
			string strSQL;
			objLog.LogString(Log.LogLevel.DEBUG, "Start of PreMeteringProcessingForStatus function");
			DAL objDAL = null;

			try
			{
				if ((objConfigInfo.strDBType.ToUpper() == "SYBASE") ||
					(objConfigInfo.strDBType.ToUpper() == "MSSQL"))
				{
					objDAL = new DAL(objConfigInfo.strDBType, objConfigInfo.strDBDataSource, objConfigInfo.Provider, objConfigInfo.strDBServer,
					  objConfigInfo.strDBName, objConfigInfo.strDBUsername, objConfigInfo.strDBPassword, objConfigInfo.strAppendToConnectionString);
					strSQL = "SELECT * FROM sysobjects where name = ?";
					//SECEND:
					MTDbParameter parameter = new MTDbParameter(statusTableName);
					DataTable table = objDAL.RunGetDataTable(strSQL, new MTDbParameter[] { parameter });
					//DataTable table = new DataTable();
					//objDAL.Run(table, strSQL);

					if (table.Rows.Count == 0) //Table doesn't exist, create it
					{
						CreateTheStatusTable();
					}
					else
					{
						//SECEND:
						strSQL = "SELECT count(*) FROM " + statusTableName;
						table = objDAL.RunGetDataTable(strSQL, null);
						//table = new DataTable();
						//objDAL.Run(table, strSQL);

						if (Convert.ToInt32(table.Rows[0][0]) == 0) //drop and recreate
						{
							DropStatusTable();
							CreateTheStatusTable();
						}
						else
						{
							ValidateTheStatusTableColumns();
						}
					}
				}
				else if (objConfigInfo.strDBType.ToUpper() == "ORACLE")
				{
					List<string> primaryKeyNames = new List<string>();
					string columnName = String.Empty;
					for (int count = 0; count < objServicePK.Count; count++)
					{
						columnName = objConfigInfo.strColumnPrefix + ((PropType)objServicePK[count]).strPropName;
						primaryKeyNames.Add(columnName.ToUpper());
					}

					List<string> otherColumnNames = new List<string>();
					columnName = objConfigInfo.strColumnPrefix + objServiceCriteriaField.strPropName;
					otherColumnNames.Add(columnName.ToUpper());
					columnName = objConfigInfo.strColumnPrefix + objErrorMesg.strPropName;
					otherColumnNames.Add(columnName.ToUpper());
					columnName = objConfigInfo.strColumnPrefix + objSentTimeStamp.strPropName;
					otherColumnNames.Add(columnName.ToUpper());
					columnName = objConfigInfo.strColumnPrefix + objBatchID.strPropName;
					otherColumnNames.Add(columnName.ToUpper());
					columnName = objConfigInfo.strColumnPrefix + objBatchNamespace.strPropName;
					otherColumnNames.Add(columnName.ToUpper());

					if (!oracleDB.TableExists(statusTableName))
					{
						oracleDB.CreateStatusTable(ServiceDBTable(), statusTableName, primaryKeyNames, otherColumnNames);
					}
					else
					{
						if (oracleDB.IsTableEmpty(statusTableName))
						{
							oracleDB.DropTable(statusTableName);
							oracleDB.CreateStatusTable(ServiceDBTable(), statusTableName, primaryKeyNames, otherColumnNames);
						}
						else
						{
							oracleDB.ValidateStatusTable(ServiceDBTable(), statusTableName, primaryKeyNames, otherColumnNames);
						}
					}
				}
				else
				{
					throw new ApplicationException("The DB type(" + objConfigInfo.strDBType + ") is not supported");
				}

				objLog.LogString(Log.LogLevel.DEBUG, "End of PreMeteringProcessingForStatus function");
			}
			catch (Exception ex)
			{
				objLog.LogString(Log.LogLevel.ERROR, "Error in PreMeteringProcessingForStatus function:" + ex.Message);
				throw;
			}
			finally
			{
				if (objDAL != null)
					objDAL.Close();
			}
		}

		/// <summary>
		/// This function is used to create the status table
		/// </summary>
		private void CreateTheStatusTable()
		{
			string createSQL;
			string pkColumnName;
			string prefix = objConfigInfo.strColumnPrefix;
			string statusfield = objConfigInfo.strColumnPrefix + objServiceCriteriaField.strPropName;
			string errorfield = objConfigInfo.strColumnPrefix + objErrorMesg.strPropName;
			string sentfield = objConfigInfo.strColumnPrefix + objSentTimeStamp.strPropName;
			string batchid = objConfigInfo.strColumnPrefix + objBatchID.strPropName;
			string batchnamespace = objConfigInfo.strColumnPrefix + objBatchNamespace.strPropName;
			DAL objDAL = null;
			//g. cieplik CR 15752 4/28/2008 Create a new Random class
			Random RandomClass = new Random();
			try
			{
				objLog.LogString(Log.LogLevel.DEBUG, "Start of CreateTheStatusTable function");
				DataTable metadata = new DataTable();
				objDAL = new DAL(objConfigInfo.strDBType, objConfigInfo.strDBDataSource, objConfigInfo.Provider, objConfigInfo.strDBServer,
					objConfigInfo.strDBName, objConfigInfo.strDBUsername, objConfigInfo.strDBPassword, objConfigInfo.strAppendToConnectionString);
				string columnSQL = null;
				//SECEND:
				MTDbParameter parameter = new MTDbParameter(ServiceDBTable());
				if (objConfigInfo.strDBType.ToUpper() == "SYBASE")
				{
					columnSQL = "SELECT so.name name, systypes.name type, so.length length from syscolumns so inner join sysobjects " +
											" on so.id = sysobjects.id inner join systypes on systypes.usertype = so.usertype " +
											" where sysobjects.name = ?";
				}
				else if (objConfigInfo.strDBType.ToUpper() == "MSSQL")
				{
					columnSQL = "SELECT so.name name, systypes.name type, so.prec length from syscolumns so inner join sysobjects " +
						" on so.id = sysobjects.id inner join systypes on systypes.xtype = so.xtype and " +
						"systypes.xusertype = so.xusertype where sysobjects.name = ?";
				}
				else
					throw new Exception("Unknown " + objConfigInfo.strDBType.ToUpper() + " specified");

				metadata = objDAL.RunGetDataTable(columnSQL, new MTDbParameter[] { parameter });
				//objDAL.Run(metadata, columnSQL);
				string pknames = "";
				createSQL = "CREATE TABLE " + statusTableName + "( ";
				//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
				// optimization code
				for (int pkCount = 0; pkCount < objServicePK.Count; pkCount++)
				{
					pkColumnName = prefix + ((PropType)objServicePK[pkCount]).strPropName;
					pknames += pkColumnName + ",";
					createSQL += CreateSql(metadata, pkColumnName, " NOT NULL,");
				}
				createSQL += CreateSql(metadata, statusfield, ",");
				createSQL += CreateSql(metadata, errorfield, ",");
				createSQL += CreateSql(metadata, sentfield, ",");
				createSQL += CreateSql(metadata, batchid, ",");
				createSQL += CreateSql(metadata, batchnamespace, ",");

				/*for (int pkCount = 0; pkCount < objServicePK.Count; pkCount++)
				{
					pkColumnName = prefix + ((PropType)objServicePK[pkCount]).strPropName;
					pknames += pkColumnName + ",";
					rows = metadata.Select( "name='" +pkColumnName +"'" );
					if(rows.Length == 0)
						throw new Exception( "Error in CreateStatusTable function:" +pkColumnName +" doesn't exixt in the Main Table.");
					datatype = rows[0]["type"].ToString().ToLower();
					createSQL += " " +pkColumnName + " " +datatype;
					length = int.Parse( rows[0]["length"].ToString());
					if(datatype.IndexOf("char") >=0 || datatype.IndexOf("string")>=0  )
					{
						createSQL += "(" +length +")";
					}
					createSQL += " NOT NULL,";
				}

				rows = metadata.Select( "name='" +statusfield +"'" );
				datatype = rows[0]["type"].ToString().ToLower();
				createSQL += " " +statusfield + " " +datatype;
				length = int.Parse( rows[0]["length"].ToString());
				if(datatype.IndexOf("char") >=0 || datatype.IndexOf("string")>=0  )
					createSQL += "(" +length +")";
				createSQL += ",";

				rows = metadata.Select( "name='" +errorfield +"'" );
				if( rows.Length >0)
				{
					datatype = rows[0]["type"].ToString().ToLower();
					createSQL += " " +errorfield + " " +datatype;
					length = int.Parse( rows[0]["length"].ToString());
					if(datatype.IndexOf("char") >=0 || datatype.IndexOf("string")>=0  )
						createSQL += "(" +length +")";
					createSQL += ",";
				}

				rows = metadata.Select( "name='" +sentfield +"'" );
				if( rows.Length >0)
				{
					datatype = rows[0]["type"].ToString().ToLower();
					createSQL += " " +sentfield + " " +datatype;
					length = int.Parse( rows[0]["length"].ToString());
					if(datatype.IndexOf("char") >=0 || datatype.IndexOf("string")>=0  )
						createSQL += "(" +length +")";
					createSQL += ",";
				}

				rows = metadata.Select( "name='" +batchid +"'" );
				if( rows.Length >0)
				{
					datatype = rows[0]["type"].ToString().ToLower();
					createSQL += " " +batchid + " " +datatype;
					length = int.Parse( rows[0]["length"].ToString());
					if(datatype.IndexOf("char") >=0 || datatype.IndexOf("string")>=0  )
						createSQL += "(" +length +")";
					createSQL += ",";
				}

				rows = metadata.Select( "name='" +batchnamespace +"'" );
				if( rows.Length >0)
				{
					datatype = rows[0]["type"].ToString().ToLower();
					createSQL += " " +batchnamespace + " " +datatype;
					length = int.Parse( rows[0]["length"].ToString());
					if(datatype.IndexOf("char") >=0 || datatype.IndexOf("string")>=0  )
						createSQL += "(" +length +")";
					createSQL += ",";
				}*/

				//createSQL = createSQL.Remove(createSQL.Length-1, 1 );
				pknames = pknames.Remove(pknames.Length - 1, 1);
				// g. cieplik 4/29/2008 CR 15752 add a six/seven digit suffix to constraint name to make unique
				string constraintname = "PK_" + DateTime.Now.Hour.ToString() + DateTime.Now.Minute.ToString() + DateTime.Now.Second.ToString() + DateTime.Now.Millisecond.ToString() + "_" + Convert.ToString(RandomClass.Next(100000, 9999999));
				//Constraint name can't be grater than 28 in Sybase
				if (constraintname.Length > 28)
					constraintname = constraintname.Substring(0, 28);

				createSQL += " CONSTRAINT " + constraintname + " PRIMARY KEY CLUSTERED(" + pknames + ")";
				createSQL += ")";
				//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
				// method for query to DB was replaced
				objDAL.RunExecuteNonQuery(createSQL, null);
				//objDAL.Run(createSQL);
				objLog.LogString(Log.LogLevel.DEBUG, "End of CreateTheStatusTable function");
			}
			catch (Exception ex)
			{
				objLog.LogString(Log.LogLevel.ERROR, "Error in CreateTheStatusTable function:" + ex.Message);
				throw;
			}
			finally
			{
				if (objDAL != null)
					objDAL.Close();
			}
		}

		//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
		// optimization code
		private string CreateSql(DataTable metadata, string parameterName, string lastString)
		{
			string result = string.Empty;
			DataRow[] rows = metadata.Select("name='" + parameterName + "'");
			if (rows.Length > 0)
			{
				string datatype = rows[0]["type"].ToString().ToLower();
				result += " " + parameterName + " " + datatype;
				int length = int.Parse(rows[0]["length"].ToString());
				if (datatype.IndexOf("char") >= 0 || datatype.IndexOf("string") >= 0)
					result += "(" + length + ")";
				result += lastString;
			}
			else
			{
				throw new Exception("Error in CreateStatusTable function:" + parameterName + " doesn't exixt in the Main Table.");
			}

			return result;
		}

		/// <summary>
		/// This function will be used to drop the status table
		/// </summary>
		private void DropStatusTable()
		{
			string dropSQL;
			try
			{
				objLog.LogString(Log.LogLevel.DEBUG, "Start of DropStatusTable function");
				DAL objDAL = new DAL(objConfigInfo.strDBType, objConfigInfo.strDBDataSource, objConfigInfo.Provider, objConfigInfo.strDBServer,
					objConfigInfo.strDBName, objConfigInfo.strDBUsername, objConfigInfo.strDBPassword, objConfigInfo.strAppendToConnectionString);
				dropSQL = "DROP TABLE " + statusTableName;

				//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
				// method for query to DB was replaced
				objDAL.RunExecuteNonQuery(dropSQL, null);
				//objDAL.Run(dropSQL);
				objDAL.Close();
				objLog.LogString(Log.LogLevel.DEBUG, "End of DropStatusTable function");
			}
			catch (Exception ex)
			{
				objLog.LogString(Log.LogLevel.ERROR, "Error in DropStatusTable function:" + ex.Message);
				throw;
			}
		}

		/// <summary>
		/// This function will be used to validate the column in the status table with main table
		/// columns
		/// </summary>
		private void ValidateTheStatusTableColumns()
		{
			string pkColumnName;
			string prefix = objConfigInfo.strColumnPrefix;
			string statusfield = objConfigInfo.strColumnPrefix + objServiceCriteriaField.strPropName;
			string errorfield = objConfigInfo.strColumnPrefix + objErrorMesg.strPropName;
			string sentfield = objConfigInfo.strColumnPrefix + objSentTimeStamp.strPropName;
			DataRow[] rows = null;
			DataRow[] statusrows = null;
			int length, statuslength;
			string type, statustype;
			DAL objDAL = null;
			try
			{
				objLog.LogString(Log.LogLevel.DEBUG, "Start of CreateTheStatusTable function");
				//SECEND:
				DataTable metadata = SECENG_GetDataTable(objConfigInfo, ServiceDBTable());
				DataTable statusmetadata = SECENG_GetDataTable(objConfigInfo, statusTableName);
				/*DataTable metadata = new DataTable();
				objDAL = new DAL( objConfigInfo.strDBType, objConfigInfo.strDBDataSource,  objConfigInfo.Provider, objConfigInfo.strDBServer,
					objConfigInfo.strDBName, objConfigInfo.strDBUsername, objConfigInfo.strDBPassword, objConfigInfo.strAppendToConnectionString );
				string columnSQL;

				if( objConfigInfo.strDBType.ToUpper() == "SYBASE" )
				{
					columnSQL = "SELECT so.name name, systypes.name type, so.length length from syscolumns so inner join sysobjects " +
						" on so.id = sysobjects.id inner join systypes on systypes.usertype = so.usertype " +
						" where sysobjects.name='" +ServiceDBTable() +"'";
				}
				else if ( objConfigInfo.strDBType.ToUpper() == "MSSQL" )
				{
					columnSQL = "SELECT so.name name, systypes.name type, so.prec length from syscolumns so inner join sysobjects " +
						" on so.id = sysobjects.id inner join systypes on systypes.xtype = so.xtype and " +
						"systypes.xusertype = so.xusertype where sysobjects.name='" +ServiceDBTable() +"'";
				}
				else
					throw new Exception( "Unknown " +objConfigInfo.strDBType.ToUpper() +" specified");

				objDAL.Run(metadata, columnSQL );
				
				DataTable statusmetadata = new DataTable();
				objDAL = new DAL( objConfigInfo.strDBType, objConfigInfo.strDBDataSource,  objConfigInfo.Provider, objConfigInfo.strDBServer,
					objConfigInfo.strDBName, objConfigInfo.strDBUsername, objConfigInfo.strDBPassword, objConfigInfo.strAppendToConnectionString );
				
				if( objConfigInfo.strDBType.ToUpper() == "SYBASE" )
				{
					columnSQL = "SELECT so.name name, systypes.name type, so.length length from syscolumns so inner join sysobjects " +
						" on so.id = sysobjects.id inner join systypes on systypes.usertype = so.usertype " +
						" where sysobjects.name='" +statusTableName +"'";
				}
				else if ( objConfigInfo.strDBType.ToUpper() == "MSSQL" )
				{
					columnSQL = "SELECT so.name name, systypes.name type, so.prec length from syscolumns so inner join sysobjects " +
						" on so.id = sysobjects.id inner join systypes on systypes.xtype = so.xtype and " +
						"systypes.xusertype = so.xusertype where sysobjects.name='" +statusTableName +"'";
				}

				objDAL.Run(statusmetadata, columnSQL);*/

				for (int pkCount = 0; pkCount < objServicePK.Count; pkCount++)
				{
					pkColumnName = prefix + ((PropType)objServicePK[pkCount]).strPropName;
					rows = metadata.Select("name='" + pkColumnName + "'");
					statusrows = statusmetadata.Select("name='" + pkColumnName + "'");
					if (statusrows.Length == 0 || rows.Length == 0)
						throw new Exception("Error in ValidateTheStatusTableColumns: PK " + pkColumnName + " not present in either main or status table.");

					type = rows[0]["type"].ToString().ToLower();
					statustype = statusrows[0]["type"].ToString().ToLower();
					length = int.Parse(rows[0]["length"].ToString());
					statuslength = int.Parse(statusrows[0]["length"].ToString());
					if (type != statustype)
						throw new Exception("Error in ValidateTheStatusTableColumns: The datatype for " + pkColumnName + " differs in main & status table");
					if (statustype.IndexOf("char") >= 0 || type.IndexOf("string") >= 0) //String datatype
						if (length != statuslength)
							throw new Exception("Error in ValidateTheStatusTableColumns: The length for " + pkColumnName + " differs in main & status table");
				}
				//Validate the status column
				rows = metadata.Select("name='" + statusfield + "'");
				statusrows = statusmetadata.Select("name='" + statusfield + "'");
				if (statusrows.Length == 0 || rows.Length == 0)
					throw new Exception("Error in ValidateTheStatusTableColumns: PK " + statusfield + " not present in either main or status table.");
				type = rows[0]["type"].ToString().ToLower();
				statustype = statusrows[0]["type"].ToString().ToLower();
				length = int.Parse(rows[0]["length"].ToString());
				statuslength = int.Parse(statusrows[0]["length"].ToString());
				if (type != statustype)
					throw new Exception("Error in ValidateTheStatusTableColumns: The datatype for " + statusfield + " differs in main & status table");
				if (statustype.IndexOf("char") >= 0 || type.IndexOf("string") >= 0) //String datatype
					if (length != statuslength)
						throw new Exception("Error in ValidateTheStatusTableColumns: The length for " + statusfield + " differs in main & status table");

				//Validate for the error column
				if (bErrorMesgExists)
				{
					rows = metadata.Select("name='" + errorfield + "'");
					statusrows = statusmetadata.Select("name='" + errorfield + "'");
					if (statusrows.Length == 0 || rows.Length == 0)
						throw new Exception("Error in ValidateTheStatusTableColumns: PK " + errorfield + " not present in either main or status table.");
					type = rows[0]["type"].ToString().ToLower();
					statustype = statusrows[0]["type"].ToString().ToLower();
					length = int.Parse(rows[0]["length"].ToString());
					statuslength = int.Parse(statusrows[0]["length"].ToString());
					if (type != statustype)
						throw new Exception("Error in ValidateTheStatusTableColumns: The datatype for " + errorfield + " differs in main & status table");
					if (statustype.IndexOf("char") >= 0 || type.IndexOf("string") >= 0) //String datatype
						if (length != statuslength)
							throw new Exception("Error in ValidateTheStatusTableColumns: The length for " + errorfield + " differs in main & status table");
				}

				//Validate for the sent column
				if (bSentTimeStampExists)
				{
					rows = metadata.Select("name='" + sentfield + "'");
					statusrows = statusmetadata.Select("name='" + sentfield + "'");
					if (statusrows.Length == 0 || rows.Length == 0)
						throw new Exception("Error in ValidateTheStatusTableColumns: PK " + sentfield + " not present in either main or status table.");
					type = rows[0]["type"].ToString().ToLower();
					statustype = statusrows[0]["type"].ToString().ToLower();
					length = int.Parse(rows[0]["length"].ToString());
					statuslength = int.Parse(statusrows[0]["length"].ToString());
					if (type != statustype)
						throw new Exception("Error in ValidateTheStatusTableColumns: The datatype for " + sentfield + " differs in main & status table");
					if (statustype.IndexOf("char") >= 0 || type.IndexOf("string") >= 0) //String datatype
						if (length != statuslength)
							throw new Exception("Error in ValidateTheStatusTableColumns: The length for " + sentfield + " differs in main & status table");
				}
			}
			catch (Exception ex)
			{
				objLog.LogString(Log.LogLevel.ERROR, "Error in CreateTheStatusTable function:" + ex.Message);
				throw;
			}
			finally
			{
				if (objDAL != null)
					objDAL.Close();
			}
		}

		private DataTable SECENG_GetDataTable(ConfigInfo objConfigInfo, string parameterValue)
		{
			objDAL = new DAL(objConfigInfo.strDBType, objConfigInfo.strDBDataSource, objConfigInfo.Provider, objConfigInfo.strDBServer,
				objConfigInfo.strDBName, objConfigInfo.strDBUsername, objConfigInfo.strDBPassword, objConfigInfo.strAppendToConnectionString);
			string columnSQL;
			MTDbParameter parameter = new MTDbParameter(parameterValue);
			if (objConfigInfo.strDBType.ToUpper() == "SYBASE")
			{
				columnSQL = "SELECT so.name name, systypes.name type, so.length length from syscolumns so inner join sysobjects " +
					" on so.id = sysobjects.id inner join systypes on systypes.usertype = so.usertype " +
					" where sysobjects.name = ?";
			}
			else if (objConfigInfo.strDBType.ToUpper() == "MSSQL")
			{
				columnSQL = "SELECT so.name name, systypes.name type, so.prec length from syscolumns so inner join sysobjects " +
					" on so.id = sysobjects.id inner join systypes on systypes.xtype = so.xtype and " +
					"systypes.xusertype = so.xusertype where sysobjects.name = ?";
			}
			else
				throw new Exception("Unknown " + objConfigInfo.strDBType.ToUpper() + " specified");

			//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
			// method for query to DB was replaced
			return objDAL.RunGetDataTable(columnSQL, new MTDbParameter[] { parameter });
		}

		/// <summary>
		///    SC: This call is run on a ThreadPool thread. 
		///    It closes each SessionSet asynchronously.    
		/// </summary>
		/// <param name="data"></param>
		private void CloseSessionSetThreadProc(object data)
		{
			SessionSetData sessionSetData = (SessionSetData)data;

			string strSessionCloseErrorMsg = "";
			int iSuccess = CloseSessionSet(sessionSetData.objSessionSet,
										   ref strSessionCloseErrorMsg,
										   sessionSetData.aMapBetweenGUIDAndPK);

			System.Runtime.InteropServices.Marshal.ReleaseComObject(sessionSetData.objSessionSet);
			sessionSetData.objSessionSet = null;

			if (iSuccess != 0)
			{
				objLog.LogString(Log.LogLevel.ERROR, "[CloseSessionSetThreadProc] SessionSet Number: " +
				  sessionSetData.iNoSessionSet +
				  " failed to close.");
			}

			// objLog.LogString(Log.LogLevel.INFO, "Thread executed: {" + sessionSetData.threadCount + "}");

			//update metering status to either Sent or Failed depending on the Processing
			if (bIsBatchCriteriaFlag)
			{
				//iSuccess can have 3 values. 0, 1, -1.
				//0: Success. Update All records with status Sent.
				//-1: Failure. Update All records with Failed status and same error message.
				//1: Failure. But individual records have already been updated.
				if (iSuccess == 0)
					SetMeterStatusAll(strBatchDate,
					  "",
					  sessionSetData.startingPKs,
					  sessionSetData.endingPKs,
					  sessionSetData.strLocalBatchName,
					  sessionSetData.strLocalBatchSpace,
					  ConfigInfo.SENT,
					  sessionSetData.aMapBetweenGUIDAndPK);

				if (iSuccess == -1)
					SetMeterStatusAll(strBatchDate,
					  strSessionCloseErrorMsg,
					  sessionSetData.startingPKs,
					  sessionSetData.endingPKs,
					  sessionSetData.strLocalBatchName,
					  sessionSetData.strLocalBatchSpace,
					  ConfigInfo.NOTSENT,
					  sessionSetData.aMapBetweenGUIDAndPK);
			}

			//If Verbose mode is set to true, print additional info on the screen
			if (MeterHelper.verboseMode)
			{
				LogAdditionalInfo(dtStartMeteringTime,
				  sessionSetData.dtStartSessionSetSendingTime,
				  (sessionSetData.iSessionCount - sessionSetData.iNumChildren - 1),
				  (sessionSetData.iTotalNoSessions - sessionSetData.iNumChildren - 1));
				// dtStartSessionSetSendingTime = DateTime.Now;
			}
		}

		private string ConvertTimeZone(string propertyValue)
		{
			string value = "";

			DateTime dateTime = DateTime.Parse(propertyValue);

			if (objConfigInfo.strLocalTimeZone != null &&
			  objConfigInfo.strLocalTimeZone.Length > 0)
			{
				// Use the new and improved TimeZoneInformation if it's available
				if (meter.TimeZoneInformation != null)
				{
					value =
					  meter.TimeZoneInformation.ToUniversalTime(dateTime).ToString(strDateFormat);
				}
				else
				{
					// Use the old TimeZone conversion
					value =
					  objTimezone.ConvertToGMT
						(dateTime, objConfigInfo.strLocalTimeZone).ToString(strDateFormat);
				}
			}
			else
			{
				value = dateTime.ToString(strDateFormat);
			}

			return value;
		}

		private string ConvertBoolean(string propertyName, string propertyValue)
		{
			string value = "";

			if (propertyValue.ToUpper().Equals("TRUE") ||
				propertyValue.ToUpper().Equals("T") ||
				propertyValue.ToUpper().Equals("1") ||
				propertyValue.ToUpper().Equals("YES") ||
				propertyValue.ToUpper().Equals("Y"))
			{
				value = "T";
			}
			else if (propertyValue.ToUpper().Equals("FALSE") ||
			  propertyValue.ToUpper().Equals("F") ||
			  propertyValue.ToUpper().Equals("0") ||
			  propertyValue.ToUpper().Equals("NO") ||
			  propertyValue.ToUpper().Equals("N"))
			{
				value = "F";
			}
			else
			{
				throw new ApplicationException("The boolean property '" +
												propertyName +
												"' has an invalid value '" +
												propertyValue +
												"'");
			}

			return value;
		}

		private PropertyData GetPropertyValue(string originalValue,
										string propertyName,
										string propertyType)
		{
			PropertyData propertyData = new PropertyData();
			propertyData.Name = propertyName;
			// propertyData.Type = propertyType;

			if (propertyType.Equals("timestamp"))
			{
				propertyData.Value = ConvertTimeZone(originalValue);
			}
			else if (propertyType.Equals("bool") || propertyType.Equals("boolean"))
			{
				propertyData.Value = ConvertBoolean(propertyName, originalValue);
			}
			else if (propertyType.Equals("string") || propertyType.Equals("unistring") || propertyType.Equals("enum"))
			{
				propertyData.Type = (int)DataType.MTC_DT_WCHAR;
				propertyData.Value = EscapeXMLCharacters(originalValue);
			}
			else
			{
				propertyData.Value = originalValue;
			}

			return propertyData;
		}

		private string EscapeXMLCharacters(string originalValue)
		{
			return regex.Replace(originalValue, new MatchEvaluator(this.ReplaceText));

			//      StringBuilder escapedString = new StringBuilder(originalValue);
			//
			//      escapedString.Replace("&", "&amp;");
			//      escapedString.Replace("<", "&lt;");
			//      escapedString.Replace(">", "&gt;");

			//      return escapedString.ToString();
		}

		private string ReplaceText(Match match)
		{
			string result = "";
			string matchString = match.ToString();
			switch (matchString[0])
			{
				case '<':
					{
						result = "&lt;";
						break;
					}
				case '>':
					{
						result = "&gt;";
						break;
					}
				case '&':
					{
						result = "&amp;";
						break;
					}
				default:
					{
						throw new ApplicationException("Unexpected character '" +
														matchString +
													   "' found");
					}
			}

			return result;
		}

		private void ValidateXml(string xml)
		{
			if (xml == null)
			{
				return;
			}

			try
			{
				XmlTextReader xmlTextReader = new XmlTextReader(new StringReader(xml));
				XmlDocument doc = new XmlDocument();
				doc.Load(xmlTextReader);
			}
			catch (XmlException)
			{
				objLog.LogString(Log.LogLevel.ERROR, "[ERROR]" + xml);
			}
		}

		/// <summary>
		///   Get the current DateTime as a Gregorian date string.
		/// </summary>
		/// <returns></returns>
		private string GetCurrentDate(string formatString)
		{
			System.Globalization.DateTimeFormatInfo dtfi;
			dtfi = new System.Globalization.CultureInfo("en-US", false).DateTimeFormat;
			dtfi.Calendar = new System.Globalization.GregorianCalendar();
			return DateTime.Now.ToString(formatString, dtfi);
		}

	}

	/// <summary>
	///    SC: Data passed to the CloseSessionSetThreadProc method.
	/// </summary>
	public struct SessionSetData
	{
		public SessionSet objSessionSet;
		public Hashtable startingPKs;
		public Hashtable endingPKs;
		public string strLocalBatchName;
		public string strLocalBatchSpace;
		public int iNoSessionSet;
		public DateTime dtStartSessionSetSendingTime;
		public int iSessionCount;
		public int iNumChildren;
		public int iTotalNoSessions;
		public Hashtable aMapBetweenGUIDAndPK;
		public int threadCount;
	}

	/// <summary>
	///    Class used to hold the AsyncDelegate and IAsyncResult created as a 
	///    result of AsyncDelegate.BeginInvoke. 
	/// </summary>
	public class DelegateData
	{
		public DelegateData(AsyncDelegate asyncDelegate, IAsyncResult asyncResult)
		{
			this.asyncDelegate = asyncDelegate;
			this.asyncResult = asyncResult;
		}

		public AsyncDelegate AsyncDelegate
		{
			get
			{
				return asyncDelegate;
			}
		}

		public IAsyncResult IAsyncResult
		{
			get
			{
				return asyncResult;
			}
		}

		private AsyncDelegate asyncDelegate;
		private IAsyncResult asyncResult;
	}
}
