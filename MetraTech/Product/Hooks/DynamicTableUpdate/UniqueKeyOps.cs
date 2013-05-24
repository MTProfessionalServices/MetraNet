using System;
using System.Collections;
using System.Collections.Specialized;
using System.Xml;
using System.Xml.Schema;
using System.Xml.Serialization;
using System.Runtime.InteropServices;
using System.Diagnostics;
using System.Text;
using System.IO;

using MetraTech;
using MetraTech.Product.Hooks;
using MetraTech.DataAccess;
using MetraTech.Product.Hooks.UIValidation;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.SysContext;
using MetraTech.Interop.RCD;
using MetraTech.Pipeline;
using sqldmodotnet;

namespace MetraTech.Product.Hooks.DynamicTableUpdate
{

	// Contains unique key database operations.  Compares unique keys in an
	// MSIXDef to its corresponding datababase table and supplies diff'ing 
	// operations.
	[ComVisible(false)]
	public class UniqueKeyOps
	{
		Logger mLog = null;
		string fileName = null;	// msixdef filename
		MSIXDef msixDef = null; // msixdef object deserialized from file
		ArrayList existingKeys = new ArrayList();  // existing unique keys 

		// Change lists of unique keys
		ArrayList adds = new ArrayList();	// contains new UniqueKeys
		ArrayList upds = new ArrayList();	// contains old,new KeyPairs
		ArrayList dels = new ArrayList();	// contains deprecated UniqueKeys
		ArrayList uncs = new ArrayList();	// contains unchanged UniqueKeys
		
		public ArrayList Added
		{
			get { return adds; }
		}
		public ArrayList Updated
		{
			get { return upds; }
		}
		public ArrayList Deleted
		{
			get { return dels; }
		}

		public ArrayList Unchanged
		{
			get { return uncs; }
		}

		// A simple pair of UniqueKeys, used by the diff'ing method.
		class KeyPair
		{
			public UniqueKey existing;
			public UniqueKey defined;
			public KeyPair(UniqueKey ex, UniqueKey def)
			{
				existing = ex;
				defined = def;
			}
		}

		// Initalizes the object by loading the msixdef file, getting the key
		// metadata from database, comparing them, and producing the change
		// lists.
		public void Init(Logger logger, string filename)
		{
			// clear internal state
			existingKeys.Clear();
			fileName = filename;
			mLog = logger;

			// Load msixdef file
			msixDef = MSIXDef.FromFile(filename);

			// Get unique key metadata from database
			MSIXDef m6 = MSIXDef.FromDatabase(msixDef.name);
			existingKeys = m6.uniqueKeys;

			// Find differences and load change lists
			FindDiffs(existingKeys, msixDef.uniqueKeys);

			// testing:
			//showChangeLists();

		}  // Init()

		// A debugging convenience that shows the change lists on the console.  
		void showChangeLists()
		{
			string fn = Path.GetFileName(fileName);
			string path = Path.GetDirectoryName(fileName);

			Console.WriteLine("\n----------------------------------------------");
			Console.WriteLine("-- uniquekey changes for: ");
			Console.WriteLine("-- {0} in ({1})", fn, path);

			Console.WriteLine("\nDels:");
			foreach (UniqueKey uk in dels)
				Console.WriteLine("   {0}({1})", uk.name, uk.ColumnCNameCSV);
			
			Console.WriteLine("\nUpds:");
			foreach (KeyPair kp in upds)
				Console.WriteLine("   {0}({1}) --> {2}({3})", 
					kp.existing.name, kp.existing.ColumnCNameCSV, 
					kp.defined.name, kp.defined.ColumnCNameCSV);

			Console.WriteLine("\nAdds:");
			foreach (UniqueKey uk in adds)
				Console.WriteLine("   {0}({1})", uk.name, uk.ColumnCNameCSV);
			Console.WriteLine("\n----------------------------------------------");
		}

		// Compares existing keys (from the db) against defined keys (from
		// the msixdef) and produces the change lists.
		void FindDiffs(ArrayList existing, ArrayList defined)
		{
			// Load the existing keys into a hash table of KeyPairs.
			Hashtable hash = new Hashtable();
			foreach(UniqueKey uk in existing)
				hash[uk] = new KeyPair(uk, null);

			// Find each defined key in the hash of existing keys.
			foreach(UniqueKey uk in defined)
			{
				if (hash.Contains(uk))
				{
					// Put matching keys together
					KeyPair pair = (KeyPair)hash[uk];
					pair.defined = uk;

					// It's only an update if the names differ (rename)
					if (!uk.NameEquals(pair.existing))
					{
						// UniqueKey renames are treated as delete-add...
						dels.Add(pair.existing);
						adds.Add(pair.defined);

						// ...but saved as a change for information.
						upds.Add(pair);
					}
					// Otherwise it's unchanged.
					else
						uncs.Add(pair.defined);

					continue;
				}

				// A defined key not found among the existing is new.
				adds.Add(uk);
			}

			// Existing keys with no definition are deletes
			foreach(KeyPair pair in hash.Values)
				if (pair.defined == null)
					dels.Add(pair.existing);

			mLog.LogDebug(string.Format(
				"Unique keys Added: {0}, Changed: {1}, Deleted: {2}",
				adds.Count, upds.Count, dels.Count));

		} // FindDiffs()

		// Returns true if any change list has at least 1 item
		public bool HasChanges
		{
			get { return (adds.Count > 0 || upds.Count > 0 || dels.Count > 0); }
		}

		// Returns a list of unique keys that depend on the specified column.
		public ArrayList DependentKeys(string col)
		{
			ArrayList keys = new ArrayList();
			foreach (UniqueKey uk in msixDef.uniqueKeys)
				foreach (string ukcol in uk.cols)
					if (String.Compare(col, ukcol, true) == 0)
						if (!keys.Contains(uk))
							keys.Add(uk);
			return keys;
		}

		// Returns a list of unique keys dependent on a specified column
		// that are also not new nor changed.
		public ArrayList DependentKeysUnchanged(string col)
		{
			ArrayList keys = new ArrayList();
			foreach (UniqueKey uk in DependentKeys(col))
				if (uncs.Contains(uk))
					if (!keys.Contains(uk))
						keys.Add(uk);
			return keys;
		}

		// Performs constraint drop operations based on the dels list.
		public void PerformDeletes(IMTConnection conn)
		{
			// Drop all unique keys in the dels list
			string baseqry = @"alter table {0} drop constraint {1}";
            foreach (UniqueKey uk in dels)
            {
                string qry = string.Format(baseqry, msixDef.PVTableName, uk.name);
                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(qry))
                {
                    mLog.LogDebug(string.Format("Dropping unique key [{0}]", uk.name));
                    stmt.ExecuteNonQuery();
                }
            }
		}	// PerformDeletes()

		// Placeholder for possible future update operations.
		public void PerformUpdates(IMTConnection conn)
		{
			// Modify all uniquekeys in the upds list
			throw new NotSupportedException(
				"Unique key updates not supported, creates and drops only.");
		}	// PerformUpdates()

		// Performs constraint create operations based on the adds list.
		public void PerformAdds(IMTConnection conn)
		{
			// Create all unique keys in the adds list
			string baseqry = 
				@"alter table {0} add constraint {1} " + 
				@"unique {2} ({3})";

            foreach (UniqueKey uk in adds)
            {
                string qry = string.Format(baseqry,
          msixDef.PVTableName, uk.name,
          conn.ConnectionInfo.IsOracle ? "" : "nonclustered",
          uk.ColumnCNameCSV);
                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(qry))
                {
                    mLog.LogDebug(string.Format("Creating unique key [{0}]", uk.name));
                    stmt.ExecuteNonQuery();
                }
            }
		}	// PerformAdds()

		// Delete key metadata for all unique key in delete list
		public void DeleteMetadata(IMTConnection conn)
		{
            foreach (UniqueKey uk in dels)
            {
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("DeleteUniqueKeyMetadata"))
                {
                    stmt.AddParam("consname", MTParameterType.String, uk.name);
                    mLog.LogDebug(string.Format("Deleting unique key metadata for [{0}]", uk.name));
                    stmt.ExecuteNonQuery();
                }
            }
		}
		
		// Add unique key metadata for all unique keys in adds
		public void AddMetadata(IMTConnection conn)
		{
            foreach (UniqueKey uk in adds)
            {
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("AddUniqueKeyMetadata"))
                {
                    stmt.AddParam("tabname", MTParameterType.String, msixDef.PVTableName);
                    stmt.AddParam("consname", MTParameterType.String, uk.name);
                    stmt.AddParam("cols", MTParameterType.String, uk.ColumnCNameCSV);
                    mLog.LogDebug(string.Format("Adding   unique key metadata for [{0}]", uk.name));
                    stmt.ExecuteNonQuery();
                }
            }
		}

	}	// class UniqueKeyOps
	
	#region MSIXDef classes

	/// <summary>
	/// A class representation of an msixdef xml file.  Suitable for 
	/// use with .Net serialization.
	/// </summary>
	[ComVisible(false)]
	[XmlRoot(ElementName = "defineservice")]
	public class MSIXDef
	{
		// The xml string values.  The names of these public properites
		// match the node names in the msixdef xml file
		public string name;

		// List of ptypes (columns)
		[XmlElement("ptype", Type=typeof(Ptype))]
		public ArrayList ptypes = new ArrayList();
   
		// List of unique keys
		[XmlElement("uniquekey", Type=typeof(UniqueKey))]
		public ArrayList uniqueKeys = new ArrayList();

		// SQL table name is derived from the msixdef name.  Returns name
		// with the "t_pv_" prefix.
		[XmlIgnore]
		public string PVTableName 
		{
			get { return (name == null) ? "" : "t_pv_" + name.Substring(name.LastIndexOf(@"/")+1); }
		}
    
		// Finds a Ptype in the ptype collection by name.
		public Ptype FindPtypeByName(string name)
		{
			foreach (Ptype p in ptypes)
				// Case-insensitive scan
				if (String.Compare(p.dn, name, true) == 0)
					return p;
			return null;
		}

		// Finds a UniqueKey in the unique key collection by name.
		public UniqueKey FindUniqueKeyByName(string name)
		{
			foreach (UniqueKey uk in uniqueKeys)
				// Case-insensitive scan
				if (String.Compare(uk.name, name, true) == 0)
					return uk;
			return null;
		}

		// Adds a new Ptype to the ptype collection.
		public Ptype AddPtype( string name, string datatype, string len, string req,
			string defval, string desc)
		{
			Ptype pt = new Ptype( name, datatype, len, req, defval, desc );
			ptypes.Add(pt);
			return pt;
		}

		// Deserialize an msixdef xml file into an MSIXDef class.
		public static MSIXDef FromFile(string filename)
		{
			MSIXDef m6;

			// todo: determine what species of msixdef this is (pv, pt, av, svc)
			using(StreamReader reader = new StreamReader(filename))
			{
				System.Xml.Serialization.XmlSerializer serializer = 
					new System.Xml.Serialization.XmlSerializer(typeof(MSIXDef));
				m6 = (MSIXDef)serializer.Deserialize(reader);
			}

			// todo: validations and construction:
			//		1. ptypes are unique - (already done by caller?)
			//		2. ensure key cols not duped
			//		3. convert unique key column lists to ptype refrences

			// for now, the concern is that key column lists are not
			// duplicated.  although the database server may catch such 
			// conditions, a dup might foul the FindDiffs() method.
			Hashtable ukcols = new Hashtable();
			ArrayList ukdups = new ArrayList();
			foreach (UniqueKey uk in m6.uniqueKeys)
				if (ukcols.ContainsKey(uk))
					ukdups.Add(uk.name);
				else
					ukcols.Add(uk, null);

			if (ukdups.Count > 0)
			{
				throw new ApplicationException(string.Format(
					"The following Unique Key(s) have duplicate column lists: {0}",
					String.Join(", ", (string[])ukdups.ToArray(typeof(string)))));
			}

			return m6;
		}

		// Attempts to infer an MSIXDef from a product view table
		//
		// Note: This is a partially complete implementation.
		//		Property types (class Ptype) are not converted from database types into
		//		msix types.  For instance, "char(1)" is not converted into "bool".
		//
		//		Unique keys and the MSix name are, however, properly represented.
		//
		public static MSIXDef FromDatabase(string pvName)
		{
			MSIXDef m6 = new MSIXDef();
			
			// Get table name (may be truncated), properties and unique keys from database.
			string tablename = null;
			using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
			{
				// Get msix name 
                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(nameQry))
                {
                    stmt.AddParam(MTParameterType.String, pvName);
                    using (IMTDataReader rdr = stmt.ExecuteReader())
                    {
                        if (!rdr.Read())
                            throw new ApplicationException(string.Format(
                                "Product view [{0}] not found.", pvName));

                        tablename = rdr.GetString(0);

                        if (rdr.Read())
                            throw new ApplicationException(string.Format(
                                "More than one row found for product view [{0}].", pvName));
                    }
                }

				// Get properties
				m6.name = pvName;
                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(conn.ConnectionInfo.IsOracle ? ptypesOracle : ptypesSqlServer))
                {
                    stmt.AddParam(MTParameterType.String, tablename);
                    using (IMTDataReader rdr = stmt.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            // Warning:  No attempt is made to convert database datatypes
                            //		into their corresponding msix datatypes.  The values
                            //    recorded here are the native database types.
                            //
                            Ptype prop = new Ptype();
                            prop.dn = rdr.GetString("dn");
                            prop.type = rdr.GetString("type");
                            prop.length = rdr.IsDBNull("length") ? null : rdr.GetInt32("length").ToString();
                            prop.required = rdr.GetString("required");
                            prop.defaultvalue = rdr.IsDBNull("defaultvalue") ? null : rdr.GetString("defaultvalue");
                            m6.ptypes.Add(prop);
                        }

                        if (m6.ptypes.Count < 1)
                            throw new ApplicationException(string.Format(
                                "No properties found for [{0}]", tablename));

                    }  // using property reader
                }

				// Get unique keys
                using (IMTCallableStatement ukStmt = conn.CreateCallableStatement("GetUniqueKeyMetadata"))
                {
                    ukStmt.AddParam("tabname", MTParameterType.String, tablename);

                    using (IMTDataReader rdr = ukStmt.ExecuteReader())
                    {
                        UniqueKey curkey = new UniqueKey();
                        while (rdr.Read())
                        {
                            // expect results sorted on (constraint_name, ordinal_position)
                            string consname = rdr.GetString("constraint_name");
                            int pos = rdr.GetInt32("ordinal_position");
                            string colname = rdr.GetString("column_name");

                            // detect new unique key and create
                            if (consname != curkey.name)
                                m6.uniqueKeys.Add(curkey = new UniqueKey(consname));

                            curkey.cols.Add(Ptype.DropC(colname));
                            if (pos != curkey.cols.Count)
                                throw new ApplicationException(string.Format(
                                    "Columns for unique key [{0}] on table [{1}] " +
                                    "were reported out of order.", curkey.name, tablename));
                        }
                    }  // using unique key reader
                }
			}	// using connection

			return m6;
		}

		// Save an MSIXDef object, in it's xml form, to a file.
		public void SaveToFile(string filename)
		{
			// suppress namespaces in xml output
			XmlSerializerNamespaces nss = new XmlSerializerNamespaces();
			nss.Add("", "");

			using(StreamWriter writer = new StreamWriter(filename))
			{
				System.Xml.Serialization.XmlSerializer serializer = 
					new System.Xml.Serialization.XmlSerializer(typeof(MSIXDef));
				serializer.Serialize(writer, this, nss);
			}
		}

		// convienent disply of msix on console
		public void Show()
		{
			Console.WriteLine("\n----------------------------------------------");
			Console.WriteLine("-- MSIXDef: {0}", name);

			Console.WriteLine("\nProps:");
			Console.WriteLine("\n   {0,-30} {1,-10} {2,4} {3,4} {4,-10} {5}\n", 
				"DN", "Type", "Len", "Req?", "Default", "Description");

			foreach (Ptype p in ptypes)
				Console.WriteLine("   {0,-30} {1,-10} {2,4} {3,4} {4,-10} {5}", 
					p.dn, p.type, p.length, p.required, p.defaultvalue, p.description);
			
			Console.WriteLine("\nUniqueKeys:");
			foreach (UniqueKey uk in uniqueKeys)
				Console.WriteLine("   {0}( {1} )", uk.name, uk.ColumnCNameCSV);
					
			Console.WriteLine("\n----------------------------------------------");
		}
		#region queries
		static string ptypesSqlServer = @"
				select 	
					pvp.nm_name as dn, 
					cols.data_type as type,
					cols.character_maximum_length as length,
					case when cols.is_nullable = 'No' 
						then 'Y' else 'N' end as required, 
					nm_default_value as defaultvalue
				from t_prod_view pv
				join information_schema.columns cols
					on pv.nm_table_name = cols.table_name
				left join t_prod_view_prop pvp
					on pv.id_prod_view = pvp.id_prod_view
					and cols.column_name = pvp.nm_column_name
				where pv.nm_table_name = ?
				and pvp.nm_column_name is not null
				order by id_prod_view_prop";
		
    static string ptypesOracle = @"
        select 
          pvp.nm_name as dn, 
          cols.data_type as type,
          cols.char_length as length,
          case cols.nullable
            when 'Y' then 'N' 
            else 'Y' end as required, 
          nm_default_value as defaultvalue
        from t_prod_view pv
        join user_tab_cols cols
          on upper(pv.nm_table_name) = cols.table_name
        left join t_prod_view_prop pvp
          on pv.id_prod_view = pvp.id_prod_view
          and cols.column_name = upper(pvp.nm_column_name)
        where pv.nm_table_name = ?
        and pvp.nm_column_name is not null
        order by id_prod_view_prop";

		
		static string nameQry = @"select nm_table_name from t_prod_view where nm_name = ?";

		#endregion queries
	}

	/// <summary>
	/// A property of an MSIXDefinition
	/// </summary>
	[ComVisible(false)]
	public class Ptype 
	{
		// The xml string values.  The names of these public properites
		// match the node names in the msixdef xml file.  The order here
		// is important to other xml parsers.
		// It must be: dn; type; length; required; defaultvalue; description
		public string dn;
		[XmlElement("type", Type=typeof(ColType))]
		public ColType typeAttrib = new ColType();
		public string length;
		public string required;
		public string defaultvalue;
		public string description;

		[XmlIgnore]
		public string type
		{
			get { return typeAttrib.Value; }
			set { typeAttrib.Value = value; }
		}

		// The public default ctor is required to deserialize into a collection
		public Ptype()
		{
		}
			
		// Convenience ctor
		public Ptype(string name, string datatype, string len, string req, 
			string defval, string desc)
		{
			dn = name;
			type = datatype;
			length = len;
			required = req;
			defaultvalue = defval;
			description = desc;
		}

		// Drops the "c_" prefix from a column name, if it's there.
		public static string DropC(string s)
		{
			return s.StartsWith("c_") ? s.Remove(0, 2) : s;
		}


		public override string ToString()
		{
			return dn;
		}
	}

	/// <summary>
	/// An MSIXDef property type
	/// </summary>
	[ComVisible(false)]
	public class ColType 
	{
		[XmlAttribute]
		public string EnumSpace;
    
		[XmlAttribute]
		public string EnumType;
    
		[XmlText]
		public string Value;

		public override string ToString()
		{
			return Value;
		}
	}

	/// <summary>
	/// Represents a uniqueness constraint on a msixdef
	/// </summary>
	[ComVisible(false)]
	public class UniqueKey 
	{
		// The unique constraint's name
		public string name;
    
		// Ordered list of the column names in this key. (this should really 
		// be a list of references to ptypes in the MSIXDef.ptypes collection)
		// (no time for love dr. jones)
		[XmlElement("col", Type=(typeof(string)))]
		public StringCollection cols = new StringCollection();

		// The public default ctor is required to deserialize into a collection
		public UniqueKey()
		{
		}

		// Convenience ctor.  
		// Usage: new UniqueKey("name", "column1", "column2", "columnN")
		public UniqueKey(string keyname, params string[] keycols)
		{
			name = keyname;
			cols = new StringCollection();
			foreach (string s in keycols)
				cols.Add(s);
		}
		
		// A unique key derives its identity from the ordered list of its
		// columns.  This is provided mostly for use by the Hashtable.
		public override int GetHashCode() 
		{
			// System.String gives a reasonable hashcode
			return ColumnNameCSV.GetHashCode();
		}
		
		// True if the two unique keys have the same ordered columns
		public override bool Equals(object rhs)
		{
			return rhs is UniqueKey && ColumnsEqual((UniqueKey)rhs);
		}

		// True is the two unique keys have the same ordered columns
		public static new bool Equals(object lhs, object rhs)
		{
			return lhs is UniqueKey && rhs is UniqueKey
				&& ((UniqueKey)lhs).ColumnsEqual((UniqueKey)rhs);
		}

		// Case-insensitive name comparision
		public bool NameEquals(UniqueKey rhs)
		{
			return String.Compare(name, rhs.name, true) == 0;
		}
		
		// Internal helper function that compares unique key column
		// lists.
		bool ColumnsEqual(UniqueKey rhs)
		{
			// must have same number of columns
			if (cols.Count != rhs.cols.Count)
				return false;

			// same column names in same order
			for (int i = 0; i < cols.Count; i++)
				if (cols[i] != rhs.cols[i])
					return false;

			return true;
		}

		// Joins the column names into a string of comma seperated values.
		public string ColumnNameCSV
		{
			get { return NameCSV(""); }
		}

		// Joins the column names into a csv string adding the "c_" prefix
		// to each column name.
		public string ColumnCNameCSV
		{
			get { return NameCSV("c_"); }
		}
		// Returns unique key tablename for partitioning environments
		public string TableName
		{
			get { return "t_uk_" + name; }
		}

		// Joins the column name list into a string of comma separated 
		// values adding an optional prefix to each column name.
		string NameCSV(string pre)
		{
			string prefix = (pre == null) ? "" : pre;
			StringBuilder csv = new StringBuilder();
			foreach (string col in cols)
				csv.AppendFormat("{0}{1}, ", prefix, col);
			return csv.Remove(csv.Length-2, 2).ToString();
		}
	}

	#endregion MSIXDef classes

}

#if false
		void GetUniqueKeyMetadata()
		{
			// get unique keys for this table
			using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
			{
				using(IMTCallableStatement stmt = conn.CreateCallableStatement("GetUniqueKeyMetadata"))
                {
				    stmt.AddParam( "tabname", MTParameterType.String, msixDef.PVTableName );

				    using(IMTDataReader reader = stmt.ExecuteReader())
				    {
					    UniqueKey curkey = new UniqueKey();
					    while (reader.Read())
					    {
						    // expect results sorted on (constraint_name, ordinal_position)
						    string consname = reader.GetString("constraint_name");
						    int pos = reader.GetInt32("ordinal_position");
						    string colname = reader.GetString("column_name");
    		
						    // detect new unique key and create
						    if (consname != curkey.name)
							    existingKeys.Add(curkey = new UniqueKey(consname));

						    curkey.cols.Add(Ptype.DropC(colname));
						    if (pos != curkey.cols.Count)
							    throw new ApplicationException(string.Format(
								    "Columns for unique key [{1}] on table [{}] " +
								    "were reported out of order.", curkey.name, msixDef.PVTableName));
					    } 
				    }  // using reader
                }
			}	// using connection

		}	// GetUniqueKeyMetadata()


#endif