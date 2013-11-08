using System;
using System.Collections;
using System.Xml;
using System.IO;
using System.Threading;
using MetraTech.DataAccess;
using MetraTech.DataExportFramework.Common;
using MetraTech.Interop.Rowset;

using ICSharpCode.SharpZipLib.Zip;
using ICSharpCode.SharpZipLib.Checksums;

using System.Net;
using MetraTech.Security.Crypto;

namespace MetraTech.DataExportFramework.Components.DataExporter
{
	
	public interface IReportInstance
	{

		string ReportType { get;  set; }
		string Title { get; set; }
		int ScheduleId { get; set; }
		int ReportId { get; set; }
		int ReportInstanceId { get; set; }
		DateTime ExecuteStartDatetime { get; set; }
		string ScheduleType { get; set; }
		bool IsComplete { get; set; }
		DateTime InstanceScheduledDateTime { get; set; }
		string ReportExecuteType { get; set; }
		string ExecutionParameters { get; }
		DateTime ThisReportSetTobeExecutedAt { get; }
		string ExecuteDescription { get; }

		void Execute ();
	}

	public class ReportParam
	{
		private string __paramname;
		public string ParamName { get { return __paramname; } set { __paramname = value; } }

		private object __paramvalue;
		public object ParamValue { get { return __paramvalue; } set { __paramvalue = value; } }

		private string __paramtype = "SINGLE";
		public string ParamType { get { return __paramtype; } }

		public ReportParam()
		{
			//NULL CONSTRUCTOR
		}

		public ReportParam(string Paramname, object Paramvalue)
		{
			this.__paramname = Paramname;
			this.__paramvalue = Paramvalue;
		}

		public ReportParam(string Paramname, object Paramvalue, string Paramtype)
		{
			this.__paramname = Paramname;
			this.__paramvalue = Paramvalue;
			this.__paramtype = Paramtype;
		}
	}
	
	public abstract class BaseReportInstance : IReportInstance
	{
		protected string __executeType;
		protected string __loggerMsg;
		//protected Logger __logger;
		protected bool __isComplete = false;
		protected ArrayList __arParams = new ArrayList();
		protected string __paramNameValues;
		protected DateTime __executeStartdatetime;
		protected string __scheduleType;
		protected int __reportId;
		protected int __reportInstanceId;
		protected int __scheduleId;
		protected DateTime __instanceScheduledDateTime;
		protected string __title;
		protected string __defSource;		
		protected string __queryTag;
		protected string __outputType;
		protected string __distributeType;
		protected string __destination;
		protected bool __destinationDirect = false;
		protected string __destnAccessUser;
		protected string __destnAccessPwd;
		protected string __reportType;
		protected DateTime __dtlastRun;
		protected DateTime __dtNextRun;
    protected string __extension = "txt";
    protected string __tempReportFile;
		protected int __intervalId;
		protected string __workQId;
		protected string __executeDescription;
		protected bool __isCompressedBeforeDelivery;
		protected int __compressionThreshold;
		protected string __eopInstanceName;
		protected bool __bGenerateControlFile = false;
		protected string __controlFileDeliverLocation = "";
		protected int __ds_id;
		protected bool __outputExecuteParamInfo = false;
		protected bool __useQuotedIdentifiers = true;
		protected string __controlFileDataDate;
		protected string __outputFileName;

		private string __deliverThisFile;
		private string __resultFileName;		//will hold the result file name without the extension and path!
		private string __ftpRelativeLocation = "";
    private string __newExtension = "";
    
		public string ReportType { get { return ReportType; } set { __reportType = value; } }
		public string Title { get { return __title; } set { __title = value; } }
		public int ScheduleId { get { return __scheduleId; } set { __scheduleId = value; } }
		public int ReportId { get { return __reportId; } set { __reportId = value; } }
		public int ReportInstanceId { get { return __reportInstanceId; } set { __reportInstanceId = value; } }
		public DateTime ExecuteStartDatetime { get { return __executeStartdatetime; } set { __executeStartdatetime = value; } }
		public string ScheduleType { get { return __scheduleType; } set { __scheduleType = value; } }
		public bool IsComplete { get { return __isComplete; } set { __isComplete = value; } }
		public DateTime InstanceScheduledDateTime { get { return __instanceScheduledDateTime; } set { __instanceScheduledDateTime = value; } }
		public string ReportExecuteType { get { return __executeType; } set { __executeType = value; } }
		public int IntervalId { get { return __intervalId; } }
		public DateTime ThisReportSetTobeExecutedAt { get { return this.__dtNextRun; } }
		public string ExecuteDescription { get { return this.__executeDescription; } }
		public bool IsCompressedBeforeDelivery { get { return __isCompressedBeforeDelivery; } set { __isCompressedBeforeDelivery = value; } }
		public int CompressionThreshold { get { return __compressionThreshold; } set { __compressionThreshold = value; } }
		public bool OutputExecuteParamInfo { get { return __outputExecuteParamInfo; } set { __outputExecuteParamInfo = value; } }
		public bool UseQuotedIdentifiers { get { return __useQuotedIdentifiers; } set { __useQuotedIdentifiers = value; } }
    private static string __lastDestnFileName = "";
		private static Mutex __fileNameMutex = new Mutex();
    protected readonly IConfiguration _config = Configuration.Instance;

        //private MetraTech.Interop.RCD.IMTRcd mRcd;
        //private string response = "";
       

		public string ExecutionParameters 
		{
			get
			{ 
				string _paramsvalues = "";
				IEnumerator _enP = __arParams.GetEnumerator();
				while (_enP.MoveNext())
				{
					ReportParam _prm = (ReportParam)_enP.Current;
					switch (_prm.ParamName)
					{
						case "%%START_DATE%%":
							if (_prm.ParamValue.ToString().Length > 0)
								_paramsvalues += _prm.ParamName.Replace("%", "")+"="+Convert.ToString(_prm.ParamValue)+";";
							else
								_paramsvalues += _prm.ParamName.Replace("%", "")+"="+this.__dtlastRun.ToString()+";";
							
							break;
						case "%%END_DATE%%":
							if (_prm.ParamValue.ToString().Length > 0)
								_paramsvalues += _prm.ParamName.Replace("%", "")+"="+Convert.ToString(_prm.ParamValue)+";";
							else
								_paramsvalues += _prm.ParamName.Replace("%", "")+"="+this.__dtNextRun.ToString()+";";
							
							break;
						default:
							_paramsvalues += _prm.ParamName.Replace("%", "")+"="+Convert.ToString(_prm.ParamValue)+";";
							break;
					}
				}
				return _paramsvalues;
			}
		}
		
		protected abstract void InitializeFromConfig();

		
		public BaseReportInstance() { }

		protected void AddParam(string prmName, object prmValue)
		{
			__arParams.Add(new ReportParam(prmName, prmValue));
		}

		protected string GenerateFileName()
		{
			DateTime _dt = DateTime.Now;
			//return _dt.Year.ToString()+_dt.Month.ToString()+_dt.Day.ToString()+_dt.Hour.ToString()+_dt.Minute.ToString()+_dt.Second.ToString()+_dt.Millisecond.ToString()+new Random().Next().ToString();
			return Guid.NewGuid().ToString();
		}
		
		public BaseReportInstance(int iReportId, int iReportInstanceId, int iScheduleId, string sScheduleType, string sTitle)
		{
			this.__reportInstanceId = iReportInstanceId;
			this.__scheduleId = iScheduleId;
			this.__scheduleType = sScheduleType;
			this.__title = sTitle;
			this.__reportId = iReportId;
			this.__loggerMsg = "Report:"+this.__title+", ReportInstance:"+this.__reportInstanceId.ToString();
			this.__executeStartdatetime = DateTime.Now;
		}

		public BaseReportInstance(string workQID, int iReportId, int iReportInstanceId, int iScheduleId, string sScheduleType, string sTitle)
		{
			this.__workQId = workQID;
			this.__reportInstanceId = iReportInstanceId;
			this.__scheduleId = iScheduleId;
			this.__scheduleType = sScheduleType;
			this.__title = sTitle;
			this.__reportId = iReportId;
			this.__loggerMsg = "Report:"+this.__title+", ReportInstance:"+this.__reportInstanceId.ToString();
			this.__executeStartdatetime = DateTime.Now;
		}



		public virtual void Execute()
		{
			this.__tempReportFile = Path.Combine(_config.WorkingFolder, String.Format("{0}.tmp", GenerateFileName()));
		}

		protected void DeleteLocalCopyOfDeliveredFile()
		{
           File.Delete(this.__deliverThisFile);
		}

    protected virtual void Select(string workQId)
    {
      IMTConnection cn = null;

      using (cn = ConnectionManager.CreateConnection())
      {
        try
        {
          IMTAdapterStatement selectst = null;
          selectst = cn.CreateAdapterStatement(_config.PathToServiceQueryDir, "__GET_QUEUED_REPORT_INFORMATION__");
          selectst.AddParam("%%WORK_QUEUE_ID%%", workQId, true);
          //selectst.AddParam("%%METRATIME%%", MTParameterType.DateTime, MetraTime.Now.ToLocalTime());
          selectst.AddParam("%%METRATIME%%", MetraTime.Now.ToLocalTime());

          if (cn.ConnectionInfo.IsOracle)
          {
            selectst.ExecuteNonQuery();
            selectst = cn.CreateAdapterStatement(_config.PathToServiceQueryDir, "__GET_QUEUED_REPORT_INFO__");
          }

          using (IMTDataReader reader = selectst.ExecuteReader())
          {
            // Should create only one report, so read only one instance
            if (reader.Read())
            {
              this.__reportType = Convert.ToString(reader.GetValue("c_rep_type"));
              this.__defSource = Convert.ToString(reader.GetValue("c_rep_def_source"));
              this.__queryTag = Convert.ToString(reader.GetValue("c_rep_query_tag"));
              this.__outputType = this.__extension = Convert.ToString(reader.GetValue("c_rep_output_type"));
              this.__distributeType = Convert.ToString(reader.GetValue("c_rep_distrib_type"));
              this.__destination = Convert.ToString(reader.GetValue("c_rep_destn")).Trim();
              this.__destnAccessUser = Convert.ToString(reader.GetValue("c_destn_access_user"));
              this.__destnAccessPwd = Convert.ToString(reader.GetValue("c_destn_access_pwd"));
              this.__dtlastRun = Convert.ToDateTime(reader.GetValue("dt_last_run"));
              this.__dtNextRun = Convert.ToDateTime(reader.GetValue("dt_next_run"));
              this.__instanceScheduledDateTime = Convert.ToDateTime(reader.GetValue("dt_sched_run"));
              this.__executeType = Convert.ToString(reader.GetValue("c_exec_type")).Trim();
              this.__paramNameValues = Convert.ToString(reader.GetValue("c_param_name_values"));
              this.__destinationDirect = Convert.ToBoolean(reader.GetValue("c_destn_direct"));
              this.__isCompressedBeforeDelivery = Convert.ToBoolean(reader.GetValue("c_compressreport"));
              this.__compressionThreshold = Convert.ToInt32(reader.GetValue("c_compressthreshold"));
              this.__eopInstanceName = Convert.ToString(reader.GetValue("c_eop_step_instance_name"));
              this.__ds_id = Convert.ToInt32(reader.GetValue("c_ds_id"));
              this.__bGenerateControlFile = Convert.ToBoolean(reader.GetValue("c_generate_control_file"));
              this.__controlFileDeliverLocation = Convert.ToString(reader.GetValue("c_control_file_delivery_locati"));
              this.__outputExecuteParamInfo = Convert.ToBoolean(reader.GetValue("c_output_execute_params_info"));
              this.__useQuotedIdentifiers = Convert.ToBoolean(reader.GetValue("c_use_quoted_identifiers"));
              this.__controlFileDataDate = Convert.ToString(reader.GetValue("control_file_data_date"));


              if (reader.GetValue("c_output_file_name") == DBNull.Value)
                this.__outputFileName = this.__title;
              else
                this.__outputFileName = Convert.ToString(reader.GetValue("c_output_file_name"));
              
              //DefLog.MakeLogEntry("\t Gather Report Execution Parameters");
              if (this.__paramNameValues.Trim().Length > 0)
                SetupReportInstanceParams(_config.PathToExtensionDir);

              DefLog.MakeLogEntry(String.Format("Got queue report info id_work_queue='{0}' c_output_file_name='{1}' parameters='{2}', and c_rep_title='{3}'",
                                workQId, 
                                this.__outputFileName, 
                                this.__paramNameValues, 
                                this.__title), "debug");

              GenerateDestination();
            }
          }
        }
        catch (Exception ex)
        {
            DefLog.MakeLogEntry("Report Instance Initialization failed.\n " + this.__loggerMsg
                              + "\n Exception Stack Trace:" + ex.ToString(), "error");
            throw;
        }
      }
    }

	  private void SetupReportInstanceParams(string _extensionloc)
		{
            try
            {

                //get a list of param names for this report definition
                MTSQLRowset _paramNameSet = new MTSQLRowsetClass();
                _paramNameSet.Init(_config.PathToServiceQueryDir);
                _paramNameSet.SetQueryTag("__GET_REPORT_DEFINITION_PARAMETERS__");
                _paramNameSet.AddParam("%%REPORT_ID%%", this.__reportId, true);
                _paramNameSet.ExecuteDisconnected();

                //get a list of paramname=value list for this queue instance
                string[] _paramnamevals = this.__paramNameValues.Split(new Char[] { ',' });

                //get a list of default param values for this instance
                MTSQLRowset _paramdefaultVals = new MTSQLRowsetClass();
                _paramdefaultVals.Init(_config.PathToServiceQueryDir);
                _paramdefaultVals.SetQueryTag("__GET_REPORT_DEFAULT_PARAMETER_VALUES__");
                _paramdefaultVals.AddParam("%%REPORT_ID%%", this.__reportId, true);
                _paramdefaultVals.AddParam("%%REPORT_INSTANCE_ID%%", this.__reportInstanceId, true);
                _paramdefaultVals.ExecuteDisconnected();

                while (Convert.ToInt16(_paramNameSet.EOF) >= 0)
                {
                    ReportParam _prm = new ReportParam();
                    _prm.ParamName = Convert.ToString(_paramNameSet.get_Value("c_param_name"));
                    _prm.ParamValue = GetParamValue(_prm.ParamName, _paramnamevals, _paramdefaultVals);

                    switch (_prm.ParamValue.ToString())
                    {
                        case "%%START_DATE%%":
                            DefLog.MakeLogEntry(this.__loggerMsg + "System level START DATE param value found - rolling over to use last run date time for this report instance");
                            _prm.ParamValue = this.__dtlastRun;
                            break;
                        case "%%END_DATE%%":
                            DefLog.MakeLogEntry(this.__loggerMsg + "System level END DATE param value found - rolling over to use current run date time for this report instance");
                            _prm.ParamValue = this.__dtNextRun;
                            break;
                    }

                    //DefLog.MakeLogEntry("\t ParameterName:" + _prm.ParamName +", Value:"+_prm.ParamValue.ToString());
                    this.__arParams.Add(_prm);
                    MergeOutputFilenameAndParms(_prm.ParamName.ToString(), _prm.ParamValue.ToString());
                    _paramNameSet.MoveNext();
                }

                //also add any new parameters that are specified in the param_name_values string
                //but are not defined in the parameter names set.
                ArrayList _prmnamevalsList = new ArrayList();
                foreach (string _prmnameval in _paramnamevals)
                    _prmnamevalsList.Add(_prmnameval);

                IEnumerator _enPrms = _prmnamevalsList.GetEnumerator();
                while (_enPrms.MoveNext())
                {
                    string[] _p = _enPrms.Current.ToString().Split(new Char[] { '=' });
                    MTDataFilter _mfilt = new MTDataFilterClass();
                    _mfilt.Add("c_param_name", MTOperatorType.OPERATOR_TYPE_EQUAL, _p[0]);
                    _paramNameSet.Filter = _mfilt;
                    if (Convert.ToInt16(_paramNameSet.EOF) < 0)
                    {
                        ReportParam _prm = new ReportParam();
                        _prm.ParamName = _p[0];
                        _prm.ParamValue = _p[1];
                        this.__arParams.Add(_prm);
                    }
                    _paramNameSet.ResetFilter();
                }
            }
            catch (Exception ex)
            {
                DefLog.MakeLogEntry("Setup Report Instance Parameters Failed.\n " + this.__loggerMsg
                    + "\n Exception Stack Trace:" + ex.ToString(), "error");
                throw (ex);
            }
		}

        //The output file needs to be merged with any parms that match a string in the outputfilename.
        //There is a special case for reports using ID_BILLGROUP as a parm - these get changed to the corresponding billclass.
        private void MergeOutputFilenameAndParms(string ParmName, string ParmValue)
        {
            if (ParmName.ToUpper() == "%%ID_BILLGROUP%%")
            {
                MetraTech.Interop.MeterRowset.IMTSQLRowset rsGetBillClass = (MetraTech.Interop.MeterRowset.IMTSQLRowset)new MTSQLRowsetClass();
                rsGetBillClass.Init("");
                rsGetBillClass.SetQueryString("SELECT * FROM t_billgroup where id_billgroup = '" + ParmValue + "'");
                try
                {
                    rsGetBillClass.Execute();
                    this.__outputFileName = this.__outputFileName.Replace(ParmName.Replace("%", ""), Convert.ToString(rsGetBillClass.get_Value("tx_name")));
                }
                catch
                {
                    this.__outputFileName = this.__outputFileName.Replace("%", "");
                }
            }
            else
            {
                string CleanParmValue = ParmValue.Replace("/", "_");
                foreach (char c in Path.GetInvalidFileNameChars()) 
                    { 
                        CleanParmValue = CleanParmValue.Replace(c.ToString(), "");  
                    }
                this.__outputFileName = this.__outputFileName.Replace(ParmName.Replace("%", ""), CleanParmValue);
            }
        }

        private object GetParamValue(string _prmName, string[] _paramnamevals, MTSQLRowset _paramdefaultVals)
		{
			foreach(string _prmnameval in _paramnamevals)
			{
				if (_prmnameval.Split(new Char[]{'='})[0].ToLower() == _prmName.ToLower())
				{
					//found the param - return the value;
					try 
					{
						return (object)_prmnameval.Split(new Char[]{'='})[1];
					}
					catch (IndexOutOfRangeException)
					{
						return (object)"NULL";
					}
				}
			}
			//not found in the name=value string... start checking in the default value list
			try 
			{
				_paramdefaultVals.MoveFirst();
			}
			catch 
			{
				//this is encountered when there are no default param values available for the parameter name
				//that means no defined value was for the parameter was found...
				throw new Exception("No value was defined for the parameter \"" + _prmName + "\". Report cannot be executed!");
			}
			while (Convert.ToInt16(_paramdefaultVals.EOF) >= 0)
			{
				if (Convert.ToString(_paramdefaultVals.get_Value("c_param_name")).ToLower() == _prmName.ToLower())
				{
					//found the param - return the default value [return NULL if db value is System.DBNull)
					if (_paramdefaultVals.get_Value("c_param_value") == System.DBNull.Value)
						return (object)"NULL";
					else
						return _paramdefaultVals.get_Value("c_param_value");
				}
				_paramdefaultVals.MoveNext();
			}

			//if I am here - then no param value was found! I throw an exception
			throw new Exception("No value was defined for the parameter \"" + _prmName + "\". Report cannot be executed!");
		}

    // We are not using this FTP Client hence following code is being commented. Whenever we will feel the need to use other advanced features
    //of that client, we can think of putting the code back. Currently we will assume the destination folders are already created on the 
    //FTP server hence no need to create any directory structure for Data File and Control File

		/* 
     * private void FTPCreateDirectory(FTPClient ftp, string directory, bool changeDir)
		{
			try 
			{
				ftp.FTPCreateDirectory(directory);
			}
			catch { }
			finally 
			{
				if (changeDir)
					ftp.FTPSetCurrentDirectory(directory);
			}
		}
		
		private void CreateControlFileDestinationStructureFTP(FTPClient ftpClient)
		{
			//remove "ftp://" from the link 
			this.__controlFileDeliverLocation = this.__controlFileDeliverLocation.Replace("ftp://", "");
			string[] _split = this.__controlFileDeliverLocation.Split(new Char[]{'/'});
			for(int i=1;i<_split.Length;i++)
			{
				if (_split[i].Trim().Length > 0)
					this.FTPCreateDirectory(ftpClient, _split[i].ToString(), true);
			}

		}

		private void CreateDestinationStructureFTP(FTPClient ftpClient)
		{
			string[] _split = this.__destination.Split(new Char[]{'/'});
			for(int i=1;i<_split.Length;i++)
			{
				if (_split[i].Trim().Length > 0)
					this.FTPCreateDirectory(ftpClient, _split[i].ToString(), true);
			}

		}
    */

		private string GenerateDestination(string destn)
		{
			IEnumerator _enP = this.__arParams.GetEnumerator();
			string[] _dest = destn.Split(new Char[]{'/'});
			foreach (string _str in _dest)
			{
				if (_str.IndexOf("%%") >= 0)
				{
					switch (_str.ToLower())
					{
						case "%%year%%":
							destn = destn.ToLower().Replace("%%year%%", this.__executeStartdatetime.Year.ToString());
							break;
						case "%%month%%":
							destn = destn.ToLower().Replace("%%month%%", this.__executeStartdatetime.Month.ToString());
							break;
						default:
							//look for the tag in parameter list and replace it with the value
							_enP.Reset();
							while (_enP.MoveNext())
							{
								ReportParam _prm = (ReportParam)_enP.Current;
								if (_prm.ParamName.ToLower() == _str.ToLower())
								{
									destn = destn.ToLower().Replace(_str.ToLower(), _prm.ParamValue.ToString());
									break;
								}
							}
							break;
					}
				}
			}

			return destn;
		}

		private void GenerateDestination()
		{
			this.__destination = GenerateDestination(this.__destination);
			this.__controlFileDeliverLocation = GenerateDestination(this.__controlFileDeliverLocation);
		}

		private string GetDestinationFTPLocation()
		{
			string _destn = this.__destination.Replace("ftp://", "");
			if (_destn.IndexOf("/") >= 0)
			{
				this.__ftpRelativeLocation = _destn.Substring(_destn.IndexOf("/")+1);
				if (!this.__ftpRelativeLocation.EndsWith("/"))
					this.__ftpRelativeLocation += "/";

				return _destn.Split(new Char[]{'/'})[0];
			}
			else
			{
				return _destn;
			}
		}

    //This is new code using .Net FTP Class, FtpWebRequest  
		
    protected void SendThroughFTP()
    {
			try 
			{
        string ftpurl = "";

        if (__newExtension == "zip")
        {
          ftpurl = "ftp://" + __destination + "/" + this.__resultFileName + "." + __newExtension;
        }
        else
        {
          ftpurl = "ftp://" + __destination + "/" + this.__resultFileName + "." + __extension;
        }

        FtpWebRequest ftpreq = (FtpWebRequest)WebRequest.Create(ftpurl);
        
        ftpreq.Method = WebRequestMethods.Ftp.UploadFile;
        
        ftpreq.UseBinary = true;
        //Decrypt the password first
        var cryptoManager = new CryptoManager();
        string strdecryptedPassword = "";
        strdecryptedPassword = cryptoManager.Decrypt(CryptKeyClass.DatabasePassword, this.__destnAccessPwd);
        
        //ftpreq.Credentials = new NetworkCredential(this.__destnAccessUser, this.__destnAccessPwd);
        ftpreq.Credentials = new NetworkCredential(this.__destnAccessUser, strdecryptedPassword);
        
        // the default when logged into Windows is HTTP proxy. This will unset the default.
        ftpreq.Proxy = null;
        
        ftpreq.UsePassive = true;

        byte[] by = File.ReadAllBytes(this.__deliverThisFile);

        ftpreq.ContentLength = by.Length;

        Stream rs = ftpreq.GetRequestStream();

        rs.Write(by, 0, by.Length);

        rs.Close();

        FtpWebResponse resp = (FtpWebResponse)ftpreq.GetResponse();

        resp.Close();

        //If control file to be uploaded, do that seperately

        if (this.__bGenerateControlFile)
        {
          this.__ftpRelativeLocation = __destination;
          XmlDocument _controlDoc = CreateControlFile();
          FileInfo _fInfo = new FileInfo(this.__deliverThisFile);
          string _controlFileName = _fInfo.DirectoryName + "\\" + this.__resultFileName + ".ctf";
          _controlDoc.Save(_controlFileName);

          string ftpurlcntl = "";

          ftpurlcntl = "ftp://" + __destination + "/" + new FileInfo(_controlFileName).Name;

          FtpWebRequest FTPreq = (FtpWebRequest) WebRequest.Create(ftpurlcntl);

          FTPreq.Method = WebRequestMethods.Ftp.UploadFile;

          FTPreq.UseBinary = true;

          FTPreq.Credentials = new NetworkCredential(this.__destnAccessUser, this.__destnAccessPwd);
          // the default when logged into Windows is HTTP proxy. This will unset the default.

          FTPreq.Proxy = null;

          FTPreq.UsePassive = true;

          byte[] bycntl = File.ReadAllBytes(_controlFileName);

          FTPreq.ContentLength = bycntl.Length;

          Stream rscntl = FTPreq.GetRequestStream();

          rscntl.Write(bycntl, 0, bycntl.Length);

          rscntl.Close();

          FtpWebResponse respcntl = (FtpWebResponse) FTPreq.GetResponse();

          respcntl.Close();

          //We may want to keep the control file hence commenting the delete file call
          //File.Delete(_controlFileName);
        }
			}
			catch (Exception ex)
			{
				//Unable to connect to FTP site
                DefLog.MakeLogEntry("FTP Error" + ex.ToString(), "error");
				throw;
			}
		}

		//Since we are using a static variable to store the last generated file name and 
		//need to compare that to the currently generated fiile name, we need to make this 
		//method synchronous
		private string GenerateDestinationReportName()
		{
			__fileNameMutex.WaitOne();
			string _fileName = "";

			if (this.__outputFileName.Length > 0)
			{
				if (this.__outputFileName.IndexOf(".") < 0)
				{
					_fileName = this.__outputFileName;
				}
				else
				{
					_fileName = this.__outputFileName.Substring(0, this.__outputFileName.LastIndexOf("."));
					this.__extension = this.__outputFileName.Substring(this.__outputFileName.LastIndexOf(".")+1);
				}
			}
			else
				_fileName = this.__title;

			string _newfile = _fileName + "_"+DateTime.Now.ToString("yyyyMMdd_HHmmssff");

      while (__lastDestnFileName == _newfile)
			{
                DefLog.MakeLogEntry("Rejected Result File Name: " + _newfile, "debug");
			
        Thread.Sleep(1);	//sleep for a millisecond and generate a new file name.
				
        _newfile = _fileName + "_"+DateTime.Now.ToString("yyyyMMdd_HHmmssff");
			
      }

			__lastDestnFileName = _newfile;
			
      __fileNameMutex.ReleaseMutex();

      DefLog.MakeLogEntry("Report ResultFileName: " + _newfile, "debug");
			
      return _newfile;
			
		}

		protected void SendThroughDiskCopy()
		{
            string saveDestinations = this.__destination;    
            char[] delimiters = new char[] { '|' }; //Allow all of these as breaks between addresses as we know users never follow directions.
            string[] destinations = this.__destination.Split(delimiters, StringSplitOptions.RemoveEmptyEntries);
            for (int i = 0; i < destinations.Length; i++)
            {
                try
                {
                    this.__destination = destinations[i].Trim();
                    if (!__destinationDirect)
                        CreateDestinationStructureDisk();
                    System.IO.File.Copy(this.__deliverThisFile, this.__destination + new FileInfo(this.__deliverThisFile).Name, true);
                }
                catch (Exception ex)
                {
                    DefLog.MakeLogEntry(this.__loggerMsg + "Disk Copy of report to destination failed.\n "
                        + "\n Exception Stack Trace:" + ex.ToString(), "error");
                    throw;
                }
                finally
                {
                    this.__destination = saveDestinations;
                }
            }
		}

		private void CreateDestinationStructureDisk()
		{
			string sDestn = this.__destination;
			int _ipos = 0, _inextpos = 0;
		
			if (sDestn.StartsWith(@"\\"))
			{
				//this takes care of an UNC Share location destination folder structure
				for (int i=0;i<4;i++)
				{
					_ipos = _inextpos + 1;
					_inextpos = sDestn.IndexOf("\\", _ipos);
				}
			}
			else
			{
				//this takes care of a local destination folder structure
				for (int i=0;i<2;i++)
				{
					_ipos = _inextpos + 1;
					_inextpos = sDestn.IndexOf("\\", _ipos);
				}
			}
			while (_inextpos >= 0)
			{
				string _t = sDestn.Substring(0, _inextpos);
				if (!Directory.Exists(_t))
				{
					Directory.CreateDirectory(_t);
				}
				_ipos = _inextpos + 1;
				_inextpos = sDestn.IndexOf("\\", _ipos);
			}
		}

	  
    private void CompressionDecision()
		{
			this.__resultFileName = GenerateDestinationReportName();
      this.__deliverThisFile = Path.Combine(Path.GetDirectoryName(this.__tempReportFile), String.Format("{0}.{1}", this.__resultFileName, this.__extension));

			File.Copy(this.__tempReportFile, this.__deliverThisFile, true);			 
			File.Delete(this.__tempReportFile);

			FileInfo _fInfo = new FileInfo(this.__deliverThisFile);
      
			if (this.__isCompressedBeforeDelivery)
			{
				if (this.__compressionThreshold == -1)
					CompressBeforeDelivery();
        else if ((this.__compressionThreshold >= 0) && ((_fInfo.Length / 1024) >= this.__compressionThreshold))
        {
          CompressBeforeDelivery();
        }
			}
		}

		protected virtual void MoveReportToDestination()
		{
			CompressionDecision();

			try 
			{
				switch (this.__distributeType.Trim().ToLower())
				{
					case "ftp":
						this.SendThroughFTP();
						break;
					case "disk":
						this.SendThroughDiskCopy();
						break;
				}

        // We may need to keep the Local Copy of the file hence commenting delete file call
        
        //DeleteLocalCopyOfDeliveredFile();
			}
			catch (Exception)
			{
				throw;
			}
		}
	
		protected XmlDocument LoadFieldDefConfigXML(string sPath)
		{
			var _doc = new XmlDocument();
			try 
			{
				_doc.Load(sPath);
				return _doc;
			}
			catch(FileNotFoundException fiEx)
			{
				throw new FieldDefConfigFileLoadException("FieldDefinition Config File Not Found", fiEx);
			}
			catch (DirectoryNotFoundException diEx)
			{
				throw new FieldDefConfigFileLoadException("FieldDefinition Config File Not Found - Directory Does not exist", diEx);
			}
		}

		protected void CompressBeforeDelivery()
		{
			try 
			{
				Crc32 _crc = new Crc32();
				if (File.Exists(_config.WorkingFolder+@"\"+this.__resultFileName+".zip"))
          File.Delete(_config.WorkingFolder + @"\" + this.__resultFileName + ".zip");
        ZipOutputStream _zp = new ZipOutputStream(File.Create(_config.WorkingFolder+ @"\" + this.__resultFileName + ".zip"));
				_zp.SetLevel(6);
			
				FileStream _fs = File.OpenRead(this.__deliverThisFile);
			
				byte[] _buffer = new byte[_fs.Length];
				_fs.Read(_buffer, 0, _buffer.Length);
				ZipEntry _entry = new ZipEntry(new FileInfo(this.__deliverThisFile).Name);
			
				_entry.DateTime = DateTime.Now;
			
				_entry.Size = _fs.Length;
				_fs.Close();
			
				_crc.Reset();
				_crc.Update(_buffer);
			
				_entry.Crc  = _crc.Value;
			
				_zp.PutNextEntry(_entry);
			
				_zp.Write(_buffer, 0, _buffer.Length);

				_zp.Finish();
				_zp.Close();
				//delete the current results file and make the zip file as the results file that will be delivered.
				DeleteLocalCopyOfDeliveredFile();
				this.__deliverThisFile = _config.WorkingFolder+@"\"+this.__resultFileName+".zip";
        this.__newExtension = "zip";
			}
			catch (Exception)
			{
				throw;
			}
		}

		private XmlDocument CreateControlFile()
		{
			XmlDocument _controlDoc = new XmlDocument();
			XmlElement _topElement = _controlDoc.CreateElement("CONTROLFILE");
			
			XmlNode _node = _controlDoc.CreateNode(XmlNodeType.Element, "DS_ID", "");
			_node.InnerText = this.__ds_id.ToString();
			_topElement.AppendChild(_node);

			_node = _controlDoc.CreateNode(XmlNodeType.Element, "FILE_NAME", "");
			_node.InnerText = new FileInfo(this.__deliverThisFile).Name;
			_topElement.AppendChild(_node);

			_node = _controlDoc.CreateNode(XmlNodeType.Element, "FILE_LOCATION", "");
			_node.InnerText = this.__ftpRelativeLocation;
			_topElement.AppendChild(_node);

			_node = _controlDoc.CreateNode(XmlNodeType.Element, "DATA_DATE", "");
			_node.InnerText = this.__controlFileDataDate;
			_topElement.AppendChild(_node);

			_node = _controlDoc.CreateNode(XmlNodeType.Element, "COMMENTS", "");
			_topElement.AppendChild(_node);

			_controlDoc.AppendChild(_topElement);
			return _controlDoc;
		}

		protected string ExecuteParameterInfo()
		{
			string _sdata = "Report: " + this.__title + "\r\n" + "Executed: " 
				+ DateTime.Now.ToLongDateString() + "\r\n\r\n"
				+ "Execution Parameters:\r\n";
			IEnumerator _enParams = this.__arParams.GetEnumerator();
			while (_enParams.MoveNext())
			{
				ReportParam _rp = (ReportParam)_enParams.Current;
				_sdata += _rp.ParamName.Replace("%", "") + " = " + _rp.ParamValue.ToString() + "\r\n";
			}

			return _sdata;
		}
	}
}
