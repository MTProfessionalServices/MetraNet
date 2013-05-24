using System;
using System.Collections;
using System.IO;
using System.Text;
using System.Data;
using System.Xml;

using MetraTech.Interop.Rowset;
using MetraTech.Interop.RCD;
using MetraTech.DataAccess;
using MetraTech.dtcc.Services.DataFormatters;

namespace MetraTech.Reports
{
	/// <summary>
	/// Summary description for DataFeedReportInstance.
	/// </summary>
	public class DataFeedReportInstance : BaseReportInstance
	{
		private ArrayList __arFieldDefs = new ArrayList(); 
		private string __extensionLocation;

		private ArrayList __headerFields = new ArrayList();
		private ArrayList __trailerFeilds = new ArrayList();

		private string __dataFieldsdelimiter = "";
		private string __headerFieldsdelimiter = "";
		private string __trailerFieldsdelimiter = "";

		public DataFeedReportInstance() : base() { }
//		public DataFeedReportInstance(int iReportId, int iReportInstanceId, int iScheduleId, string sScheduleType, string sTitle) : base(iReportId, iReportInstanceId, iScheduleId, sScheduleType, sTitle)
//		{
//			//this.__logger = new Logger("[QUERYREPORTINSTANCE]");
//			this.Select();
//			this.InitializeFromConfig();
//		}
//		
		public DataFeedReportInstance (string workQID, int iReportId, int iReportInstanceId, int iScheduleId, string sScheduleType, string sTitle) : base(workQID, iReportId, iReportInstanceId, iScheduleId, sScheduleType, sTitle)
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

		private ReportParam GetReportParam(string paramName)
		{
			IEnumerator _enParams = this.__arParams.GetEnumerator();
			while (_enParams.MoveNext())
			{
				ReportParam _rp = (ReportParam)_enParams.Current;
				if (_rp.ParamName.ToLower() == paramName.ToLower())
					return _rp;
			}
			return null;
		}

		private ArrayList CollectFieldInfo(XmlNode underThisNode, string nowProcessing)
		{
			ArrayList _collectionBin = new ArrayList();
			foreach (XmlNode _node in underThisNode.ChildNodes)
			{
				//Check just in case this node is a comment node
				if (_node.NodeType == XmlNodeType.Element)
				{
					FieldDefinition _fldDef = new FieldDefinition();
					if (_node.Attributes["value"] != null)
					{
						string _value = _node.Attributes["value"].Value;
						ReportParam _rp = this.GetReportParam(_value);
						if (_rp != null)
							_fldDef.Value = _rp.ParamValue;
						else
							_fldDef.Value = (object)_value;
					}
					_fldDef.FieldName = _node.Attributes["name"].Value;

					if (_node.Attributes["format"] != null)
						_fldDef.DataFormat = _node.Attributes["format"].Value;

					if (_node.Attributes["length"] != null)
						_fldDef.Length = Convert.ToInt32(_node.Attributes["length"].Value);

					if (_node.Attributes["nopad"] != null)
						_fldDef.NoPadding = (_node.Attributes["nopad"].Value.ToLower() == "true")?true:false;

					if (_node.Attributes["datatype"] != null)
						_fldDef.Datatype = _node.Attributes["datatype"].Value;

					if (_node.Attributes["align"] != null)
						_fldDef.Align = _node.Attributes["align"].Value;

					if (_node.Attributes["padchar"] != null)
						_fldDef.PadCharacter = _node.Attributes["padchar"].Value;
						
					_collectionBin.Add(_fldDef);
				}
			}
			return _collectionBin;
		}
	
		protected override void InitializeFromConfig()
		{
			IMTRcd _rcd = new MTRcdClass();
			_rcd.Init();
			__extensionLocation = _rcd.ExtensionDir;
			__arFieldDefs.Clear();
			XmlDocument _doc = null;
			try 
			{
				try 
				{
					_doc = LoadFieldDefConfigXML(__extensionLocation+this.__dataconfigXML+"\\"+this.__title+"_"+this.__reportInstanceId.ToString()+".xml");
				}
				catch (FieldDefConfigFileLoadException)
				{
					try 
					{
						_doc = LoadFieldDefConfigXML(__extensionLocation+this.__dataconfigXML+"\\"+this.__title+".xml");
					}
					catch (FieldDefConfigFileLoadException fdEx)
					{
						throw (fdEx);
					}
					catch (Exception ex)
					{
						throw (ex);
					}
				}
				catch (Exception ex)
				{
					throw (ex);
				}

				XmlNode _delimiters = _doc.SelectSingleNode("xmlconfig/reportfielddef/delimiters");
				if (_delimiters.Attributes["header"] != null)
					this.__headerFieldsdelimiter = _delimiters.Attributes["header"].Value;
				if (_delimiters.Attributes["trailer"] != null)
					this.__trailerFieldsdelimiter = _delimiters.Attributes["trailer"].Value;
				if (_delimiters.Attributes["body"] != null)
					this.__dataFieldsdelimiter = _delimiters.Attributes["body"].Value;

				XmlNode _headerFields = _doc.SelectSingleNode("xmlconfig/reportfielddef/header");
				if (_headerFields != null)
					__headerFields = CollectFieldInfo(_headerFields, "header");

				XmlNode _trailerFields = _doc.SelectSingleNode("xmlconfig/reportfielddef/trailer");
				if (_trailerFields != null)
					__trailerFeilds = CollectFieldInfo(_trailerFields, "trailer");

				XmlNode _outputFields = _doc.SelectSingleNode("xmlconfig/reportfielddef/outputfields");
				if (_outputFields == null)
					throw new Exception("No output field defintions defined!");
				else
				{
					this.__arFieldDefs = CollectFieldInfo(_outputFields, "output data");
				}
			} 
			catch (FieldDefConfigFileLoadException fldEx)
			{
				//All fields are streamed to the output file - nothing to do here - exit out!
				Common.MakeLogEntry(this.__loggerMsg+" Field Def Config XML not found for the DataFeed , defaulting to stream only fields with no header/trailer");
				throw (fldEx);
			}
			catch (Exception ex)
			{
				throw(ex);
			}
		}

		private void CreateReport()
		{
			/*
			 * 1. Write the header
			 * 2. Write the data
			 * 3. Write the trailer*/

			IMTConnection _cn = null;
			IMTDataReader _rdr = null;
			try 
			{
				_cn = ConnectionManager.CreateConnection();
				IMTAdapterStatement _select = _cn.CreateAdapterStatement(this.__querySource, this.__queryTag);
				IEnumerator _enParams = this.__arParams.GetEnumerator();
				while (_enParams.MoveNext())
				{
					ReportParam _prm = (ReportParam)_enParams.Current;
					_select.AddParam(_prm.ParamName, _prm.ParamValue, true);
				}
				_rdr = _select.ExecuteReader();
				CharDelimitedFormatter _ftm = new CharDelimitedFormatter();
				
				_ftm.MTLogger = Common.LoggerInstance();
				_ftm.SpecialFormatInfo = this.__arFieldDefs;
                _ftm.Delimiter = this.__dataFieldsdelimiter;
					
				_ftm.BeginFileWrite(this.__tempReportFile, false);

				if (this.__headerFieldsdelimiter.Length > 0)					
					_ftm.DoWriteFile(__headerFields, this.__headerFieldsdelimiter);
				else
					_ftm.DoWriteFile(__headerFields);
				
				int _rowCount = _ftm.DoWriteFile(_rdr, false);
				IEnumerator _en = __trailerFeilds.GetEnumerator();
				while (_en.MoveNext())
				{
					FieldDefinition _fld = (FieldDefinition)_en.Current;
					if (_fld.FieldName.ToLower() == "totalrows")
					{
						_fld.Value = (object)_rowCount;
						break;
					}
				}
				if (this.__trailerFieldsdelimiter.Length > 0)
					_ftm.DoWriteFile(__trailerFeilds, this.__trailerFieldsdelimiter);
				else
					_ftm.DoWriteFile(__trailerFeilds);
				_ftm.EndFileWrite();
				Common.MakeLogEntry(this.__loggerMsg+"- "+_rowCount.ToString() + " rows of data written to the datafeed file");

				this.MoveReportToDestination();

				this.__isComplete = true;
			}
			
			catch (Exception ex)
			{
				Common.MakeLogEntry(this.__loggerMsg+ " Report writing error\n"+ ex.ToString());
				throw (ex);
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

