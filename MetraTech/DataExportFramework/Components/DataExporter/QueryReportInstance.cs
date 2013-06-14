using System;
using System.Collections;
using System.IO;
using System.Text;
using System.Data;
using System.Xml;
using MetraTech.DataExportFramework.Common;
using MetraTech.Interop.Rowset;
using MetraTech.Interop.RCD;
using MetraTech.DataAccess;
using MetraTech;
using MetraTech.DataExportFramework.Components.DataFormatters;

namespace MetraTech.DataExportFramework.Components.DataExporter
{
	public class QueryReportInstance : BaseReportInstance
	{
		private ArrayList __arFieldDefs = new ArrayList(); 
		private string __extensionLocation;
		private bool __showHeaderFields = true;
		private string __delimiter = ",";
		private bool __includeNonListedFields = true;

		public QueryReportInstance() : base() { }

		public QueryReportInstance (string workQID, int iReportId, int iReportInstanceId, int iScheduleId, string sScheduleType, string sTitle) : base(workQID, iReportId, iReportInstanceId, iScheduleId, sScheduleType, sTitle)
		{
			//this.__logger = new Logger("[QUERYREPORTINSTANCE]");
			this.Select(this.__workQId);
			InitializeFromConfig();
		}
	
		public override void Execute()
		{
			base.Execute ();
			try 
			{
				this.CreateReport();
			}
			catch (Exception ex)
			{
				//Console.WriteLine(ex.ToString());
				throw(ex);
			}
		}

		protected override void InitializeFromConfig()
		{
			IMTRcd _rcd = new MTRcdClass();
			_rcd.Init();
			__extensionLocation = _rcd.ExtensionDir;
			__arFieldDefs.Clear();
      
      if (__outputType == "txt")
      {
        XmlDocument fieldDefConfigXml;
        try
        {
          try
          {
            fieldDefConfigXml =
              LoadFieldDefConfigXML(Path.Combine(_config.PathToReportFieldDefDir,String.Format("{0}_{1}.xml",__title,__reportInstanceId)));
          }
          catch (FieldDefConfigFileLoadException)
          {
            try
            {
              fieldDefConfigXml = LoadFieldDefConfigXML(Path.Combine(_config.PathToReportFieldDefDir, String.Format("{0}.xml", __title)));
            }
            catch (FieldDefConfigFileLoadException)
            {
              DefLog.MakeLogEntry(String.Format("{0} Config XML with field defintions not found for the txt formatted report, defaulting to stream all fields",__loggerMsg),"info");
              try
              {
                //awk-Added logic to use default instead of throwing error.
                fieldDefConfigXml =
                  LoadFieldDefConfigXML(Path.Combine(_config.PathToReportFieldDefDir, String.Format("default_{0}.xml", __outputType)));
              }
              catch (FieldDefConfigFileLoadException)
              {
                throw;
              }
            }
          }
          
          XmlNode _node = fieldDefConfigXml.SelectSingleNode("xmlconfig/reportfielddef/fielddef");
          if (_node != null)
          {
            try
            {
              __showHeaderFields = _node.Attributes["field_header"].Value == "y";
            }
            catch
            {
              __showHeaderFields = false;
            }
            try
            {
              __delimiter = _node.Attributes["delimiter"].Value;
            }
            catch
            {
                DefLog.MakeLogEntry("No delimiter specified - falling back to default of \",\"", "debug");
            }

            if (_node.Attributes["includenonlistedfields"] != null)
            {
              switch (_node.Attributes["includenonlistedfields"].Value.ToLower())
              {
                case "false":
                case "0":
                case "f":
                case "n":
                  __includeNonListedFields = false;
                  break;
                default:
                  __includeNonListedFields = true;
                  break;
              }
            }
            else
            {
                DefLog.MakeLogEntry("IncludeNonListedfields flag not defined - defaulting to assume this as YES", "debug");
              __includeNonListedFields = true;
            }

            try
            {
              __extension = _node.Attributes["fileextension"].Value;
            }
            catch
            {
            }
            XmlNodeList _nodelist = _node.ChildNodes;
            foreach (XmlNode _fieldNode in _nodelist)
            {
              //Have to make a check that this is an element node
              //comment nodes may be included inside here which we want to ignore-lkuve
              if (_fieldNode.NodeType == XmlNodeType.Element)
              {
                FieldDefinition _fdl = new FieldDefinition();
                _fdl.FieldName = _fieldNode.Attributes["name"].Value;
                try
                {
                  _fdl.Length = Convert.ToInt32(_fieldNode.Attributes["length"].Value);
                }
                catch
                {
                }

                if (_fieldNode.Attributes["datatype"] != null)
                  _fdl.Datatype = _fieldNode.Attributes["datatype"].Value;

                if (_fieldNode.Attributes["padchar"] != null)
                  _fdl.PadCharacter = _fieldNode.Attributes["padchar"].Value;

                if (_fieldNode.Attributes["align"] != null)
                  _fdl.Align = _fieldNode.Attributes["align"].Value;

                if (_fieldNode.Attributes["format"] != null)
                  _fdl.DataFormat = _fieldNode.Attributes["format"].Value;

                if (_fieldNode.Attributes["displayname"] != null)
                  _fdl.DisplayName = _fieldNode.Attributes["displayname"].Value;

                if (_fieldNode.Attributes["decimalpoint"] != null)
                {
                  switch (_fieldNode.Attributes["decimalpoint"].Value.ToLower())
                  {
                    case "false":
                    case "0":
                    case "f":
                    case "n":
                      _fdl.DecimalPoint = false;
                      break;
                    default:
                      _fdl.DecimalPoint = true;
                      break;
                  }
                }
                __arFieldDefs.Add(_fdl);
              }
            }
          }
          else
          {
            throw new Exception("fixedlendef node not found");
          }
        }
        catch (FieldDefConfigFileLoadException)
        {
          //All fields are streamed to the output file - nothing to do here - exit out!
          if (__outputType == "csv")
          {
              DefLog.MakeLogEntry(String.Format("{0} Config XML with field defintions not found for the csv formatted report, defaulting to stream all fields", __loggerMsg), "info");
          }
          else if (__outputType == "xml")
          {
              DefLog.MakeLogEntry(String.Format("{0} Config XML with field definitions not found for the xml formatted report, defaulting to stream all fields", __loggerMsg), "info");
          }
          else
          {
                  DefLog.MakeLogEntry(String.Format("{0} Field Def Config XML not found for the textformatted Report", __loggerMsg), "error");
            throw;
          }
        }
        catch (Exception ex)
        {
            DefLog.MakeLogEntry(String.Format("{0} Unknown Error\n {1}", __loggerMsg, ex), "error");
            throw;
        }
      }
		}

		private void CreateReport()
		{
			IMTConnection _cn = null;
			IMTDataReader _rdr = null;
			try 
			{
				_cn = ConnectionManager.CreateConnection();
				IMTAdapterStatement _select = _cn.CreateAdapterStatement(_config.PathToCustomQueryDir, this.__queryTag);
				IEnumerator _enParams = this.__arParams.GetEnumerator();
				while (_enParams.MoveNext())
				{
					ReportParam _prm = (ReportParam)_enParams.Current;
					if (_prm.ParamValue.ToString().Trim().Length == 0)
						_prm.ParamValue = "NULL";
					if (_prm.ParamValue.ToString().Trim().ToUpper() == "NULL")
						_select.AddParam(_prm.ParamName, _prm.ParamValue, true);
					else
						_select.AddParam(_prm.ParamName, "'" + _prm.ParamValue + "'", true);
				}
                DefLog.MakeLogEntry(_select.Query, "debug");
				_rdr = _select.ExecuteReader();
				BaseFormatter _ftm = null;
				//Check on out put type to call the correct formatter
				if (this.__outputType == "csv")
				{
					_ftm = new CharDelimitedFormatter();
					//this.__extension = "csv";
				}
				else if (this.__outputType == "txt")
				{
					_ftm = new FixedLengthFormatter();
				}

        else if (this.__outputType == "xml")
        {
          _ftm = new XMLFormatter();
        }



        _ftm.Delimiter = this.__delimiter; 
				_ftm.IncludeNonListedFields = this.__includeNonListedFields;

                _ftm.MTLogger = DefLog.LoggerInstance();
				_ftm.SpecialFormatInfo = this.__arFieldDefs;

				//int _rowCount = _ftm.GenerateOutFile(_rdr, this.__tempReportFile, __showHeaderFields);
				_ftm.UseQuotedIdentifiers = this.__useQuotedIdentifiers;
				_ftm.BeginFileWrite(this.__tempReportFile, this.__showHeaderFields);
				if (this.__outputExecuteParamInfo)
				{
					string _sExecuteParamInfo = ExecuteParameterInfo();
					_ftm.DoWriteFile(_sExecuteParamInfo);
				}
				int _rowCount = _ftm.DoWriteFile(_rdr, this.__showHeaderFields);
				_ftm.EndFileWrite();

                DefLog.MakeLogEntry(this.__loggerMsg + "- " + _rowCount.ToString() + " rows of data written to the output file");

				this.MoveReportToDestination();

				this.__isComplete = true;
			}
			
			catch (Exception ex)
			{
                string rptExc = ex.ToString();
                if (rptExc.Contains("deadlock"))
                    rptExc = rptExc.Replace("deadlock", "_REPORT_EXECUTE_ERROR_");

                DefLog.MakeLogEntry(this.__loggerMsg + " Report writing error\n" + rptExc, "Error");
                throw (new Exception(rptExc));
			}
			finally
			{
				if (_cn != null)
				{
					_cn.Close();
					_cn.Dispose();
				}
				if (_rdr != null)
				{
					_rdr.Close();
					_rdr.Dispose();
				}
			}
		}
	}
}
