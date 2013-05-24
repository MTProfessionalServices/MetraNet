using System;
using System.Xml;
using System.Runtime.InteropServices;
using MetraTech.Xml;
using MetraTech.DataAccess;
using System.Collections;
using MetraTech.Interop.RCD;
using MetraTech.Interop.MTProductCatalog;
using System.EnterpriseServices;

[assembly: GuidAttribute("6FF7A8AD-6BDD-4b6e-8DDE-40D48F2DDB8C")]

namespace MetraTech.Product.Hooks.InsertProdProperties 
{
	[Guid("5FC40F1D-F820-4dc9-9675-ACC67F42DAD7")]
	public interface IInsertProdProperties
	{
		void Initialize(string filepath , int fkid);
		int InsertProperties();
	}
	/// <summary>
	/// Summary description for Class1.
	/// </summary>
	[Guid("FFD8AA33-000C-4c40-B155-AE353E779E5B")]
    [ClassInterface(ClassInterfaceType.None)]
	public class InsertProdProperties : IInsertProdProperties
	{
		const string SD_TABLE_NAME = "t_service_def_prop";
		const string AV_TABLE_NAME = "t_account_view_prop";
		const string PT_TABLE_NAME = "t_param_table_prop";

		const string PT_CONFIG_PATH = @"\config\ParamTable";
		const string AV_CONFIG_PATH = @"\config\accountview";
		const string SD_CONFIG_PATH = @"\config\service";
		
		private string tableName;
		private string servicename;	
		private string fkcolumnname;
		private string pkcol; // primary key column
		private string pkgen;	// table pk sequence generator (oracle sequence)
		string xmlfilepath;
		int fkid;	//Foreign key id to be used in the child props table during insert
		MetraTech.Logger mLog;
		PropertyMetaDataSet pset = null;
		ConnectionInfo connInfo = null;
    
		public InsertProdProperties()
		{
			connInfo = new ConnectionInfo("NetMeter");
		}
	
		/// <summary>
		/// 
		/// </summary>
		/// <param name="filepath"></param>
		/// <param name="fkid"></param>
		/// <returns></returns>
		///

		public void Initialize(string filepath, int fkid)
		{
			mLog = new Logger("[InsertProdProperties]");
			mLog.LogDebug("Initializing the table name for file " +filepath);
			try
			{
				filepath=filepath.Replace("/", @"\");
				if(filepath.IndexOf(":")<=0)
				{
					IMTRcd rcd = new MTRcdClass();
					IMTRcdFileList list = rcd.RunQuery(filepath, true );
					xmlfilepath = list[0].ToString();
				}
				else
					xmlfilepath = filepath;

				this.fkid = fkid;
				if(xmlfilepath.IndexOf( PT_CONFIG_PATH ) >= 0)
				{
					tableName = PT_TABLE_NAME;
					fkcolumnname = "id_param_table";
					pkcol = "id_param_table_prop";
					pkgen = "seq_t_param_table_prop.nextval";
				}
				else if(filepath.IndexOf( AV_CONFIG_PATH ) >= 0)
				{
					tableName = AV_TABLE_NAME;
					fkcolumnname = "id_account_view";//added
					pkcol = "id_account_view_prop";
					pkgen = "seq_t_account_view_prop.nextval";
				}
				else if(filepath.IndexOf( SD_CONFIG_PATH ) >= 0)
				{
					tableName = SD_TABLE_NAME;
					fkcolumnname = "id_service_def";
					pkcol = "id_service_def_prop";
					pkgen = "seq_t_service_def_prop.nextval";
				}
				else
					throw new ApplicationException( "Wrong filename passed as a parameter");

				MetaDataParser parser = new MetaDataParser();
				pset = new PropertyMetaDataSet();
				parser.ReadMetaDataFromFile(pset, xmlfilepath, "" );
				parser = null;
				servicename = pset.Name;
			}
			catch(Exception ex)
			{
				mLog.LogError( "Exception occured while updating properties:" +ex.Message);
			}
		}


		private int GetPropertyValue(IMTPropertyMetaData prop)
		{
			switch (prop.DataType)
			{
				case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_STRING:
					return 0;
				case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_INTEGER:
					return 2;
				case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_BIGINTEGER:
					return 11;
				case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DATETIME:
					return 3;
				case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DOUBLE:
					return 5;
				case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_ENUM:
					return 8;
				case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_BOOLEAN:
					return 9;
				case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_TIME:
					return 3;
				case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DECIMAL:
					return 7;
				default:
					throw new ApplicationException( "Data type for the property couldn't be recognized:" +prop.Name);
			}
		}

		/// <summary>
		/// This function is used to validate the property
		/// </summary>
		/// <returns></returns>
		/// 
    [AutoComplete]
		public int InsertProperties()
		{
			//mLog.LogDebug("Starting InsertProperties function");
			//Console.WriteLine("InsertProperties: {0} and {1}", tableName, servicename);
			
			try
			{
        using (MetraTech.DataAccess.IMTConnection conn = ConnectionManager.CreateConnection())
        {
          if (pset == null)
            throw new ApplicationException("FileName passed to the Initialize function couldn't get loaded");
          IDictionaryEnumerator idict = pset.GetEnumerator();

          while (idict.MoveNext())
          {
              IMTPropertyMetaData propdata = (IMTPropertyMetaData)idict.Current;

              string query = "";

              query = "INSERT INTO " + tableName + "(";

              if (connInfo.IsOracle)
                  query += pkcol + ",";

              query += fkcolumnname + ",nm_name,nm_data_type,nm_column_name,b_required,b_composite_idx,b_single_idx,b_part_of_key,b_exportable,b_filterable,b_user_visible,nm_default_value,n_prop_type,nm_space,nm_enum,b_core";
              if (tableName == PT_TABLE_NAME)
              {
                  query += ",b_columnoperator,nm_operatorval";
              }
              query += ") values(";

              if (connInfo.IsOracle)
                  query += pkgen + ",";

              query += fkid + ",'" + propdata.Name + "','" + propdata.DBDataType + "','" + propdata.DBColumnName + "',";
              query += propdata.Required ? "'Y'" : "'N'";
              query += "," + "'N','N','N','Y','Y','Y',";
              if (propdata.DefaultValue.ToString().Length > 0)
                  query += "'" + propdata.DefaultValue + "'";
              else
                  query += "null";
              query += ",'" + GetPropertyValue(propdata) + "','";
              if (propdata.EnumSpace != null)
                  query += propdata.EnumSpace + "','";
              else
                  query += "" + "','";

              if (propdata.EnumSpace != null)
                  query += propdata.EnumType + "','";
              else
                  query += "" + "','";

              query += "N'";
              if (tableName == PT_TABLE_NAME)
              {
                  IMTAttributes attributes = propdata.Attributes;
                  if (attributes.Exists("column_operator"))
                  {
                      IMTAttribute columnattr = (IMTAttribute)attributes["column_operator"];
                      query += ",'Y','" + columnattr.Value.ToString() + "'";
                  }
                  else
                      query += ",'N',null";

              }
              query += ")";
              //mLog.LogDebug( "Insert query generated was: " + query);
              using (IMTStatement stmt = conn.CreateStatement(query))
              {
                  stmt.ExecuteNonQuery();
              }
          }
        }

				//mLog.LogDebug( "Ending InsertProperties function");
				return 1;
			}
			catch(Exception ex)
			{
				mLog.LogError( "Error occured during modifying the tables for " +servicename +":" +ex.Message);
				mLog.LogError( "Stack Trace:" +ex.StackTrace);
				return 0;
			}
		}
		
	}
}
