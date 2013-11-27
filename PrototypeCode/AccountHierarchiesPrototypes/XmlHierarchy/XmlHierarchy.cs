using System;
using System.Data.SqlClient;
using System.Xml;
using System.Data;
using System.Xml.XPath;
using System.Collections.Specialized;
using System.Collections;
using Auth;
using Auth.Capabilities;
using Auth.SecurityFramework;
using Auth.Exceptions;


namespace XmlHierarchy
{
	/// <summary>
	/// Summary description for Class1.
	/// </summary>
	public class XmlHierarchy
	{
		public XmlHierarchy()
		{
		}
		
		public void Init()
		{
			netmeter = new SqlConnection("Data Source=ragnarok;" +
				"Initial Catalog=netmeter;User ID=nmdbo;Password=nmdbo");
			netmeter.Open();
		}
		
		private string AccountNameFromID(int accountID)
		{
			SqlDataAdapter workDA = 
				new SqlDataAdapter("select nm_name from t_account_test where id_acc = " + 
				accountID, netmeter);
		
			DataSet workDS = new DataSet("accoutname");
			workDA.Fill(workDS,"accoutname");
			
			DataRow aRow;
			aRow = workDS.Tables["accoutname"].Rows[0];
			
			return (string)aRow["nm_name"];
		}
		
		
		public string GenerateFragment(int aAccountID)
		{
			SqlDataAdapter workDA = 
				new SqlDataAdapter("exec GenHierarchyOnAcc " + aAccountID , netmeter);
			DataSet workDS = new DataSet("fragment");
						
			DataTable ParentTable = new DataTable("parent");
			ParentTable.Columns.Add("parent_name",typeof(string));
			ParentTable.Columns.Add("parent_id", typeof(Int32));
						
			// construct parent row
			DataRow ParentRow = ParentTable.NewRow();
			ParentRow["parent_name"] = AccountNameFromID(aAccountID);
			ParentRow["parent_id"] = aAccountID;
			ParentTable.Rows.Add(ParentRow);
						
			// add the ParentRow to the dataset
			workDS.Tables.Add(ParentTable);
			workDA.Fill(workDS, "hierarchy");
						
			// construct the relationship between the data
			DataRelation ParentToChild = workDS.Relations.Add(workDS.Tables["parent"].Columns["parent_id"],
				workDS.Tables["hierarchy"].Columns["parent_id"]);
			ParentToChild.Nested = true;
			// setup children as an attribute
			workDS.Tables["hierarchy"].Columns["bChildren"].ColumnMapping = MappingType.Attribute;
						
			return workDS.GetXml();
					
		}
		
		public string GenerateFragmentByName(string aAccountString)
		{
			SqlDataAdapter workDA = 
				new SqlDataAdapter("exec GenHierarchy '" + aAccountString + "'", netmeter);
			DataSet workDS = new DataSet("fragment");
									
			DataTable ParentTable = new DataTable("parent");
			ParentTable.Columns.Add("parent_name",typeof(string));
			ParentTable.Columns.Add("parent_id", typeof(Int32));
									
			// construct parent row
			DataRow ParentRow = ParentTable.NewRow();
			ParentRow["parent_name"] = aAccountString;
			ParentRow["parent_id"] = 1;
			ParentTable.Rows.Add(ParentRow);
									
			// add the ParentRow to the dataset
			workDS.Tables.Add(ParentTable);
			workDA.Fill(workDS, "hierarchy");
									
			// construct the relationship between the data
			DataRelation ParentToChild = workDS.Relations.Add(workDS.Tables["parent"].Columns["parent_id"],
				workDS.Tables["hierarchy"].Columns["parent_id"]);
			ParentToChild.Nested = true;
			// setup children as an attribute
			workDS.Tables["hierarchy"].Columns["bChildren"].ColumnMapping = MappingType.Attribute;
									
			return workDS.GetXml();
		}
		public string LoadEntity(string strID,string strIDType, SecurityContext aContext)
		{
			string xml;
			
			if(strIDType.CompareTo("BY_ID") == 0) 
			{
				xml = GenerateFragment(System.Int32.Parse(strID));
			}
			else if(strIDType.CompareTo("BY_NAME") == 0) 
			{
				xml = GenerateFragmentByName(strID);
			}
			else 
			{
				return "<xml><msg>Error!</msg></xml>";
			}
			
			if(!aContext.CheckAccess(new ManageAHCapability()))
			{
				throw new AuthException("Sorry, can't view requested entity");
			}
			else
				return xml;

			


		}
		
		public bool SaveEntity(string XmlFragment)
		{
			/*
					' <hierarchy>
				'   <parent_id />
				'   <child />
				'   <id_acc />
				' </hiearchy>
				*/
		
			// save the XML document
			
			XmlDocument aDoc = new XmlDocument();
			//XmlDocument
			aDoc.LoadXml(XmlFragment);
			string aParentID = aDoc.SelectSingleNode("/hierarchy/parent_id").InnerText;
			string aChildID = aDoc.SelectSingleNode("/hierarchy/id_acc").InnerText;
			
			SqlDataAdapter MoveAccount = 
				new SqlDataAdapter("exec MoveAccount " + 
				System.Int32.Parse(aChildID) + ", " + 
				System.Int32.Parse(aParentID), netmeter);
				
			// I don't think I need the dataset but I haven't figure out a way
			// to simply just execute the stored procedure
			DataSet unused = new DataSet("foo");
			MoveAccount.Fill(unused);
			
			return true;
		
		}
		
		// members
		protected SqlConnection netmeter;
	}
}
