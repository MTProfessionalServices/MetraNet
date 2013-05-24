//Validation for the conversion between float,double,decimal has to be done
using System;
using System.Xml;
using System.Runtime.InteropServices;
using System.Collections;
using MetraTech;
using MetraTech.Xml;
using MetraTech.DataAccess;
using MetraTech.Interop.MTPipelineLib;
using MetraTech.Interop.RCD;
using QueryAdapter = MetraTech.Interop.QueryAdapter;
using MetraTech.Interop.SysContext;

[assembly: GuidAttribute("6FF7A8AD-6BDD-4b6e-8DDE-40D48F2DDB8C")]

namespace MetraTech.Product.Hooks.UIValidation
{
	[Guid("62C8FE65-4EBB-45e7-B440-6E39B2CDBF29")]
	public interface IValidator
	{
		void Initialize(string xml , string filepath );
		int ValidateProperty();
		//bool WasDBColumnEnum();
	}
	/// <summary>
	/// Summary description for Class1.
	/// </summary>
	[Guid("53469f0f-59c1-4466-ba5c-8e872e86304d")]
	[ClassInterface(ClassInterfaceType.None)]
	public class DBPropValidator : IValidator
	{
		const string PV_TABLE_PREFIX = "t_pv_";
		const string PT_TABLE_PREFIX = "t_pt_";
		const string AV_TABLE_PREFIX = "t_av_";
		const string SD_TABLE_PREFIX = "t_svc_";
		const string PV_CONFIG_PATH = @"\config\productview";
		const string PT_CONFIG_PATH = @"\config\ParamTable";
		const string AV_CONFIG_PATH = @"\config\accountview";
		const string SD_CONFIG_PATH = @"\config\service";

		const int ERR_NON_COMPATIBLE_CONV = 1001;
		const int ERR_LEN_INCREASED_FOR_STRING_PROP = 1002;
		const int ERR_ENUM_VALUES_CHANGED = 1003;
		const int ERR_CHARGE_PROP_NON_DEC = 1004;
		const int ERR_INDEXED_PROP_NON_DEC = 1005;
		const int ERR_DEFAULT_VALUE_NOT_SET = 1006;

		bool isGroupValidation = false;
		const string COLUMN_PREFIX= "c_";
		
        private QueryAdapter.IMTQueryAdapter mQueryAdapter;

		private string tableName;
		private string columnName;
		private string propertyname;
		private string serviceName;
		private string defaultNamespace;
		string xmlfilepath;
		PropertyMetaDataSet pset;
		System.Xml.XmlNode node;
		MetraTech.Logger mLog;
		string tablePrefix="";
		public DBPropValidator()
		{
		}

		public void Initialize(string xml, string filepath, bool group)
		{
			mLog = new Logger("[DBPropValidator]");
			mLog.LogDebug("Initializing the table name and column for file " + filepath);

			filepath=filepath.Replace("/", @"\");
			xmlfilepath = filepath;
			isGroupValidation = group;

            mQueryAdapter = new QueryAdapter.MTQueryAdapter();
            mQueryAdapter.Init(@"Queries\\DynamicTable");

			if (filepath.IndexOf( PV_CONFIG_PATH ) >= 0)
				tablePrefix = PV_TABLE_PREFIX;
			else if (filepath.IndexOf( PT_CONFIG_PATH ) >= 0)
				tablePrefix = PT_TABLE_PREFIX;
			//else if (filepath.IndexOf( AV_CONFIG_PATH ) >= 0)
			//	tablePrefix = AV_TABLE_PREFIX;
			else if (filepath.IndexOf( SD_CONFIG_PATH ) >= 0)
				tablePrefix = SD_TABLE_PREFIX;
			else
				return;
			//Fix for CR#12476. As MTFleXML is generic code, the call comes to this hook.	Also when the new PI is created,
			//at that time the msixdef file doesn't exist

			MetaDataParser parser = new MetaDataParser();
			pset = new PropertyMetaDataSet();
			parser.ReadMetaDataFromFile(pset, filepath, tablePrefix );
			parser = null;
			if (tablePrefix == PV_TABLE_PREFIX || tablePrefix == PT_TABLE_PREFIX)
				tableName = pset.TableName;
			else if (tablePrefix == SD_TABLE_PREFIX)
				tableName = pset.LongTableName;

			serviceName = pset.Name;
			defaultNamespace = serviceName;

            MTXmlDocument document = new MTXmlDocument();
			document.LoadXml(xml); 
			node = document.ChildNodes[0];
			propertyname = node.SelectSingleNode("dn").InnerText;
			columnName = COLUMN_PREFIX + propertyname;
			mLog.LogDebug("Table, Column Name is: " + tableName + "," +columnName);
		}

		public void Initialize(string xml, string filepath)
		{
			this.Initialize (xml, filepath, false);
		}
		
		/// <summary>
		/// This function is used to validate the property
		/// </summary>
		/// <returns></returns>
		public int ValidateProperty()
		{
			mLog.LogDebug("Starting ValidateProperty function");

			// Skip validation if no table prefix.
			if (tablePrefix == "")
			{
				mLog.LogDebug("Table prefix is blank. Skip the validation");
				return 0;
			}

			// Currently, we support only validations for PV and SD. We do not
			// want to continue if request comes for Charges, or AV.
			// As MTFleXml code is generic and all (PV, PT ...) use the same
            // code path (asp file) to generate the page, call would come to this component.
            if (tablePrefix != SD_TABLE_PREFIX && tablePrefix != PV_TABLE_PREFIX && tablePrefix != PT_TABLE_PREFIX)
				return 0;
            
			Hashtable columnMetaData = RetrieveColumnMetaData();
			mLog.LogDebug("Column metadata retrieved");

			// If columnMetaData is null => Its a new property or name has been changed
			// (System would treat it as new property)
			int retValue=0;
			if (columnMetaData != null && columnMetaData.Count > 0)
				retValue = CompareTheResults(columnMetaData);
			else
			{
				//New Property added.
				//The validation for default value set would not be done for the row operator columns for PT(ends with _op)
				if (tablePrefix != PT_TABLE_PREFIX || !node.SelectSingleNode("dn").InnerText.EndsWith("_op"))
				{
					if (node.SelectSingleNode("required").InnerText.ToUpper()== "Y" &&
                        node.SelectSingleNode("defaultvalue").InnerText.Length == 0
                        && TableHasRows(tableName) /* If table is empty do not throw error */)
					{
                        mLog.LogError("Default value is required for added property({0}), table({1}) in order to populate existing table.",
                                      node.SelectSingleNode("dn").InnerText, tableName);
						return ERR_DEFAULT_VALUE_NOT_SET;
					}
				}
			}

			// We would like to continue validating the charge & indexed property
			// validation for the new properties. Also, one extra validation for
			// the modification of the properties used in the charge.
			if ((retValue==0) && xmlfilepath.IndexOf( PV_CONFIG_PATH ) >= 0)
			{
				//Check whether the property is non-decimal
				if (node.SelectSingleNode("type").InnerText.ToLower() != "decimal")
				{
					//find the service path
					retValue = ValidateForTheChargeProperty(xmlfilepath, PV_CONFIG_PATH);
				}
			}
			
			// One extra validation for the modification of the properties set as indesed
			if (retValue == 0 && xmlfilepath.IndexOf(PT_CONFIG_PATH) >= 0)
			{
				// Check whether the property is non-decimal
				if (node.SelectSingleNode("type").InnerText.ToLower() != "decimal")
				{
					// Find the service path
					retValue = ValidateForTheIndexedProperty(xmlfilepath, PT_CONFIG_PATH);
				}
			}

			mLog.LogDebug("Ending ValidateProperty function");
			return retValue;
		}
		
		/// <summary>
		/// This function is used to validate for the charged property. 
		/// </summary>
		/// <param name="xmlfilepath"></param>
		/// <param name="searchedpath"></param>
		/// <returns></returns>
		private int ValidateForTheChargeProperty(string xmlfilepath, string searchedpath)
		{
			mLog.LogDebug("Starting ValidateForTheChargeProperty function. Values passed {0}, {1}",xmlfilepath,searchedpath );
			string extensionpath, pvname;
			IMTRcdFileList files = (IMTRcdFileList)MetraTech.Xml.MTXmlDocument.FindFilesInExtensions("config\\PriceableItems\\*.xml");
			extensionpath = xmlfilepath.Remove(xmlfilepath.IndexOf(searchedpath),xmlfilepath.Length-xmlfilepath.IndexOf(searchedpath)); 
			
			MTXmlDocument pvdoc = new MTXmlDocument();
			pvdoc.Load(xmlfilepath);
			pvname = pvdoc.SelectSingleNode("defineservice/name").InnerText;
			foreach(string file in files)
			{
				string tmpfile = file.Replace("/", @"\");
				//To ignore the files who doesn't at the required path
				if(!tmpfile.StartsWith(extensionpath))
					continue;
				
				MTXmlDocument doc = new MTXmlDocument();
				doc.Load(file);
				//To ignore the parent/child PI files as they also lie at the same path. so we would be matching the
				//Product View name in both the files.
				if (doc.SelectSingleNode("/priceable_item/pipeline/product_view").InnerText.ToLower() != pvname.ToLower())
					continue;

				foreach(XmlNode chargenode in doc.SelectNodes("/priceable_item/charges/charge") )
				{
					if (chargenode.SelectSingleNode("name").InnerText.ToLower() == node.SelectSingleNode ("dn").InnerText.ToLower())
					{
						mLog.LogError( "Property associated with charge has to be of decimal datatype only, Name: {0}", node.SelectSingleNode ("dn").InnerText);
						return ERR_CHARGE_PROP_NON_DEC;
					}
				}
				//If the cursor comes to this point => It has already validated the charge from the correct file
				break;
			}
			mLog.LogDebug("Ending ValidateForTheChargeProperty function");
			return 0;
		}

		/// <summary>
		/// This function is used to do the validation for the indexed property. The data type of the property
		/// marked as indexed has to be decimal only
		/// </summary>
		/// <param name="xmlfilepath"></param>
		/// <param name="searchedpath"></param>
		/// <returns></returns>
		private int ValidateForTheIndexedProperty(string xmlfilepath, string searchedpath)
		{
            MTXmlDocument document = new MTXmlDocument();
			document.Load( xmlfilepath ); 
			
			XmlNode namenode = document.SelectSingleNode("/defineservice/name");
			XmlAttribute attr = namenode.Attributes["indexed_property"];
			if(attr != null)
				if(attr.InnerText.ToLower() == node.SelectSingleNode("dn").InnerText.ToLower())
					return ERR_INDEXED_PROP_NON_DEC;

			return 0;
		}

		/// <summary>
		/// 
		/// </summary>
		/// <param name="row"></param>
		/// <returns></returns>
		private int CompareTheResults(Hashtable row)
		{
			mLog.LogDebug("Starting CompareTheResults function");

			// Check for compatible data type conversion
			string targetdatatype = node.SelectSingleNode("type").InnerText.ToLower();
			string basedatatype = row["type"].ToString().ToLower();
			string enumData = null;
			
			if (basedatatype == "int32")
			{
				enumData = RetrieveTheEnumData(columnName, tableName);
				if (enumData != null && enumData.Length > 0)
					basedatatype = "enum";
			}

			// Check for compatible conversions
			if(!IsCompatibleConversion(targetdatatype, basedatatype))
			{
				mLog.LogError("Incompatible coversion in file " +xmlfilepath +" from " +basedatatype +" to " +targetdatatype +" for " +node.SelectSingleNode ("dn").InnerText );
				return ERR_NON_COMPATIBLE_CONV;
			}

			// Would be habdling 2 cases
			// 1. type:string and length increased
			// 2. type:enum and enumspace/enumname changed
			if (basedatatype == targetdatatype) 
			{
				if (targetdatatype == "string" && !(xmlfilepath.IndexOf(SD_CONFIG_PATH) >= 0))
				{
					int basedatalength = Convert.ToInt16(row["length"]);
					int targetdatalength = Convert.ToInt16(node.SelectSingleNode("length").InnerText);
					if (targetdatalength < basedatalength)
					{
						mLog.LogError("Length of string data type decreased in file " + xmlfilepath + ". property: " + node.SelectSingleNode ("dn").InnerText);
						return ERR_LEN_INCREASED_FOR_STRING_PROP;
					}
				}

				if (targetdatatype == "enum")
				{
                    XmlAttributeCollection AttribCol = node.SelectSingleNode("type").Attributes;

                    // Do an case insensitive find.
                    string enumspace = String.Empty;
                    string enumtype = String.Empty;
                    foreach (XmlAttribute attrib in AttribCol)
                    {
                        string attribName = attrib.Name.ToLower();
                        if (attribName == "enumspace")
                            enumspace = attrib.InnerText;
                        else if (attribName == "enumtype")
                            enumtype = attrib.InnerText;

                        // We only care about the above two attributes.
                        if (enumspace != String.Empty && enumtype != String.Empty)
                            break;
                    }

					// If attributes are missing default to using namespace of service def.
                    if (enumspace == String.Empty)
						enumspace = defaultNamespace;

                    if (enumtype == String.Empty)
						enumtype = node.SelectSingleNode("dn").InnerText;
			
					string baseenum = enumspace + "/" + enumtype;
					if (baseenum.ToLower() != enumData.ToLower())
					{
						mLog.LogError("Enum values changed in file " + xmlfilepath + ". property: " + node.SelectSingleNode("dn").InnerText +
                                      " changed from " + enumData + " to " + baseenum);
						return ERR_ENUM_VALUES_CHANGED;				//Enum values has been changed
					}
				}
			}

			// Validation for the property modified to required. This wouldn't be done for the opearator column of PT's
			if (tablePrefix != PT_TABLE_PREFIX || !node.SelectSingleNode("dn").InnerText.EndsWith("_op"))
			{
				if (node.SelectSingleNode("required").InnerText.ToUpper() == "Y" &&
					row["required"].ToString() == "N")
				{
					// Calling one more function to check whether targeted column has any NULL
					// values. If yes, then only check for the defaul value condition
					if (node.SelectSingleNode("defaultvalue").InnerText.Length == 0 &&
						ColumnHasNullValues(columnName, tableName))
					{
						mLog.LogError("Default value not set for modified required property. Name: " + node.SelectSingleNode("dn").InnerText);
						return ERR_DEFAULT_VALUE_NOT_SET;
					}
				}
			}

			mLog.LogDebug("Ending CompareTheResults function");
			return 0;
		}
		
		/// <summary>
		/// This function is used
		/// </summary>
		/// <param name="targettype"></param>
		/// <param name="dbdatatype"></param>
		/// <returns></returns>
		private bool IsCompatibleConversion(string targettype, string dbdatatype)
		{
			// For data type decimal, float, numeric column gets created
			// For data type double, float column gets created in the database
			switch (targettype)
			{
				case "string":
					//All the conversions are valid
					break;
				case "timestamp":
					if (targettype != dbdatatype)
						return false;
					break;
				case "int32":
					if (targettype != dbdatatype)
						return false;
					break;
				case "int64":
					if ((targettype != dbdatatype) && (dbdatatype!="int32"))
						return false;
					break;
				case "double":
					if ((targettype!=dbdatatype) && (dbdatatype!="int32") && (dbdatatype!="decimal"))
						return false;
					break;
				case "float":
					if ((targettype!=dbdatatype) && (dbdatatype!="int32") && (dbdatatype!="decimal"))
						return false;
					break;
				case "decimal":
					if ((targettype!=dbdatatype) && (dbdatatype!="int32") && (dbdatatype!="decimal"))
						return false;
					break;
				case "boolean":
					if (targettype != dbdatatype)
						return false;
					break;
				case "enum":
					if ((dbdatatype!="enum") && (dbdatatype!="string"))
						return false;
					break;
			}

			return true;
		}

		/// <summary>
		/// This function is used to return the metadata for the tabe columns
		/// </summary>
		/// <returns></returns>
		private Hashtable RetrieveColumnMetaData()
		{
			mLog.LogDebug("Starting RetrieveColumnMetaData function");
			Hashtable columnMetaData = null;
            using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("GetMetaDataForProps"))
                {
                    stmt.AddParam("tablename", MTParameterType.String, tableName);
                    stmt.AddParam("columnname", MTParameterType.String, columnName);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        if (reader.Read())
                            columnMetaData = ConvertDBValuesToMetraConfig(reader);
                    }
                }
            }

			mLog.LogDebug("Ending RetrieveColumnMetaData function");
			return columnMetaData;
		}

		/// <summary>
		/// This function is used to convert the DB values to MetraConfig types and adds them into hashtable
		/// </summary>
		/// <param name="reader"></param>
		/// <returns></returns>
		private Hashtable ConvertDBValuesToMetraConfig(IMTDataReader reader)
		{
			mLog.LogDebug("Starting ConvertDBValuesToMetraConfig function");
			Hashtable htable = new Hashtable();
			//Handling the data types
			switch (reader.GetString("type").ToLower())
			{
        case "nvarchar2":  goto case "nvarchar"; // oracle
				case "nvarchar":
					htable.Add ("type", "string");
					htable.Add( "length", Convert.ToInt32( reader.GetValue("length")));
					break;
				case "numeric":
					htable.Add( "type", "decimal" );
					break;
        case "date": goto case "datetime"; // oracle
				case "datetime":
					htable.Add( "type", "timestamp" );
					break;
				case "int":
					htable.Add( "type", "int32" );
					break;
				case "bigint":
					htable.Add( "type", "int64" );
					break;
				case "float":
					htable.Add( "type", "double" );
					break;
				case "char":
					if( Convert.ToInt32( reader.GetValue( "length" )) == 1 )
						htable.Add( "type", "boolean" );
					break;
        case "number":  // oracle
          if (Convert.ToInt32(reader.GetValue("decplaces")) > 0)
            htable.Add( "type", "decimal" );
          else
            if (Convert.ToInt32(reader.GetValue("length")) > 10)
            htable.Add( "type", "int64" );
          else
            htable.Add( "type", "int32" );
          break;
				default:
					throw new Exception( "This data type is not supported: " +reader.GetString("type").ToLower());
			}
			
			// Handling for the required property
			if (Convert.ToBoolean( reader.GetValue("required")))
				htable.Add("required", "Y");
			else
				htable.Add("required","N");
			
			mLog.LogDebug("Ending ConvertDBValuesToMetraConfig function");
			return htable;
		}
		
		/// <summary>
		/// This function is used to check whether the db type was enum or not
		/// </summary>
		/// <param name="columnName"></param>
		/// <param name="tableName"></param>
		/// <returns></returns>
		public string RetrieveTheEnumData(string columnName, string tableName)
		{
			string query = null;
			string enumstring = "";
            using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
            {
                switch (tablePrefix)
                {
                    case PV_TABLE_PREFIX:
                        query = string.Format(@"
                SELECT t_prod_view_prop.nm_space, t_prod_view_prop.nm_enum 
                FROM t_prod_view_prop 
                inner join t_prod_view 
                  on t_prod_view.id_prod_view = t_prod_view_prop.id_prod_view 
                where UPPER(t_prod_view.nm_name) = '{0}' 
                  and t_prod_view_prop.nm_name = '{1}'",
                          serviceName.ToUpper(), propertyname);
                        break;
                    case PT_TABLE_PREFIX:
                        query = string.Format(@"
						  SELECT t_param_table_prop.nm_space, t_param_table_prop.nm_enum 
              FROM t_param_table_prop 
              inner join t_base_props 
                on t_base_props.id_prop = t_param_table_prop.id_param_table 
              where UPPER(t_base_props.nm_name) = '{0}' 
                and t_param_table_prop.nm_name = '{1}'",
                          serviceName.ToUpper(), propertyname);
                        break;
                    case SD_TABLE_PREFIX:
                        query = string.Format(@"
						  SELECT t_service_def_prop.nm_space, t_service_def_prop.nm_enum 
              FROM t_service_def_prop 
              inner join t_service_def_log 
                on t_service_def_log.id_service_def = t_service_def_prop.id_service_def 
              where Upper(t_service_def_log.nm_service_def) = '{0}'
                and t_service_def_prop.nm_name = '{1}'",
                          serviceName.ToUpper(), propertyname);
                        break;
                }

                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(query))
                {
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string enumspace = reader.IsDBNull("nm_space")
                              ? null : reader.GetString("nm_space");
                            string enumname = reader.IsDBNull("nm_enum")
                              ? null : reader.GetString("nm_enum");

                            if (enumspace != null && enumspace.Length > 0)
                                enumstring = enumspace + "/" + enumname;
                        }
                    }
                }
            }
			return enumstring;
		}

        private bool TableHasRows(string tableName)
		{
			string query = "SELECT count(*) from " + tableName;
            using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(query))
                {
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            int rowcount = Convert.ToInt32(reader.GetValue(0));
                            if (rowcount > 0)
                                return true;
                        }
                    }
                }
            }
			return false;
		}

		private bool ColumnHasNullValues(string columnName, string tableName)
		{
            mQueryAdapter.SetQueryTag("__DOES_COLUMN_CONTAIN_NULL_VALUES__");
            mQueryAdapter.AddParam("%%TABLE_NAME%%", tableName, false);
            mQueryAdapter.AddParam("%%COLUMN_NAME%%", columnName, false);
            using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(mQueryAdapter.GetQuery()))
                {
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            int nValue = Convert.ToInt32(reader.GetValue(0));
                            if (nValue == 1)
                                return true;
                        }
                    }
                }
            }

			return false;
		}
	}
}
