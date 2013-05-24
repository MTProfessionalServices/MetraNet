using System.Xml;
using System.Runtime.InteropServices;
using System;
using QueryAdapter = MetraTech.Interop.QueryAdapter;

namespace MetraTech.DataAccess.MaterializedViews
{
	using MetraTech.Interop.MTProductCatalog;
	using MetraTech.Xml;

	using System.Text;
	using System.Collections;
	using System.Collections.Specialized;
	using System.Security.Cryptography;

	public class MaterializedViewEvent
	{
		public MaterializedViewEvent(string description)
		{
			mDescription = description;
		}
		
		public void AddBaseTable(string BaseTableName)
		{
			// Some base tables are materialized views.
			// In such a case we have a tag inplace of table name.
			// Substitutew the tag.
			int nIndex = BaseTableName.IndexOf("%%");
			if (nIndex != -1)
			{
				// Strip %% and add prefix.
				BaseTableName = BaseTableName.Replace("%%", "");
				BaseTableName = Bindings.GetMVTableName(BaseTableName);
			}
			
			// Do table names in lowercase
			BaseTableName =	BaseTableName.ToLower();

			// Do not add duplicates.
			if (!mBaseTables.Contains(BaseTableName))
				mBaseTables.Add(BaseTableName);
		}

		public ArrayList BaseTables
		{
			get { return mBaseTables; }
		}

		public IEnumerable Operations
		{
			get
			{
				string [] names = new string[mQueryTags.Count];
				ICollection coll = mQueryTags.Keys;
				coll.CopyTo(names, 0);
				return names;
			}
		}

		public Hashtable QueryTags
		{
			get { return mQueryTags; }
		}

		public string Description
		{
			get { return mDescription; }
		}

		public string GetQueryTag(string operationName)
		{
			return (string) mQueryTags[operationName];
		}

		private string mDescription;
		private ArrayList mBaseTables = new ArrayList();
		private Hashtable mQueryTags = new Hashtable();
	}

	public class MaterializedViewDefinition
	{
		// Materialized View operation mode enum.
		public enum Mode
		{
			TRANSACTIONAL = 0,
			DEFERRED = 1,
			OFF = 2,
		};

		// Constructor
		public MaterializedViewDefinition(string filename)
		{
			// Load the configuration file.
			MTXmlDocument doc = new MTXmlDocument();
			doc.Load(filename);

			//-----
			// Read in all the properties from the configuration file.
			//-----

			// Required: Get name of materialized view.
			mName = doc.GetNodeValueAsString("/xmlconfig/name");
			mName =	mName.ToLower();

			// Make sure the name is valid.
			string defName = MaterializedViewDefinitionCollection.FilenameToDefName(filename);
			if (string.Compare(mName, defName, true) != 0)
				throw new MTXmlException("Name mismatch for materialized view \"" + mName + "\", " + filename);

			// Optional: Get description of materialized view.
			XmlNode tmpNode = doc.SingleNodeExists("/xmlconfig/Description");
			if (tmpNode != null)
				mDescription = tmpNode.InnerText;

			// Required: Get Update mode.
			mUpdateMode = ConvertUpdateModeNameToType(doc.GetNodeValueAsString("/xmlconfig/UpdateMode"));

			//-----
			// The following are not required in OFF mode,
			// but required in all other modes.
			//-----

			// Required: Get prog id.
			if (mUpdateMode == Mode.OFF)
			{
				tmpNode = doc.SingleNodeExists("/xmlconfig/progid");
				if (tmpNode != null)
					mProgId = tmpNode.InnerText;
			}
			else
				mProgId = doc.GetNodeValueAsString("/xmlconfig/progid");

			// Make sure the progid is valid.
			bool bSupportsCustomQueries = false;
			try
			{
				if (mProgId.Length > 0)
				{
					Type MVType = Type.GetTypeFromProgID(mProgId, true); // throws
					IQueryProvider qp = (IQueryProvider) Activator.CreateInstance(MVType);
					bSupportsCustomQueries = qp.SupportsCustomQueries;
				}
				else if (mUpdateMode != Mode.OFF)
				{
					throw new Exception("invalid argument");
				}
			}
			catch (Exception e)
			{
				string msg = "Unable to validate progid(" + mProgId;
				msg += ") for materialized view \"" + mName + "\", configuration file: " + filename;
				throw new MTXmlException(msg + ", error: " + e.Message);
			}

			// Required: Get Query Path mode.
			if (mUpdateMode == Mode.OFF)
			{
				tmpNode = doc.SingleNodeExists("/xmlconfig/QueryPath");
				if (tmpNode != null)
					mQueryPath = tmpNode.InnerText;
			}
			else
				mQueryPath = doc.GetNodeValueAsString("/xmlconfig/QueryPath");

			// Required: Get Create materialized view query tag.
			if (mUpdateMode == Mode.OFF)
			{
				tmpNode = doc.SingleNodeExists("/xmlconfig/create_query_tag");
				if (tmpNode != null)
					mCreateQueryTag = tmpNode.InnerText;
			}
			else
				mCreateQueryTag = doc.GetNodeValueAsString("/xmlconfig/create_query_tag");

			// Optional: Get Drop materialized view query tag.
			tmpNode = doc.SingleNodeExists("/xmlconfig/drop_query_tag");
			if (tmpNode != null)
				mDropQueryTag = tmpNode.InnerText;

			// Optional: Get Init materialized view query tag.
			tmpNode = doc.SingleNodeExists("/xmlconfig/init_query_tag");
			if (tmpNode != null)
				mInitQueryTag = tmpNode.InnerText;

			// Required: Get Full update materialized view query tag.
			if (mUpdateMode == Mode.OFF)
			{
				tmpNode = doc.SingleNodeExists("/xmlconfig/full_query_tag");
				if (tmpNode != null)
					mFullQueryTag = tmpNode.InnerText;
			}
			else
				mFullQueryTag = doc.GetNodeValueAsString("/xmlconfig/full_query_tag");

			// Required: Find all events if bSupportsCustomQueries if false
			foreach (XmlNode nodeEvent in doc.SelectNodes("xmlconfig/Event"))
			{
				// Optional: Get event description
				string description = null;
				tmpNode = MTXmlDocument.SingleNodeExists(nodeEvent, "Description");
				if (tmpNode != null)
					description = tmpNode.InnerText;

				// Create event object.
				MaterializedViewEvent ev = new MaterializedViewEvent(description);

				// Required: Build a list of base tables for each Event.
				foreach (XmlNode nodeBaseTable in nodeEvent.SelectNodes("base_tables/table_name"))
					ev.AddBaseTable(nodeBaseTable.InnerText);

				// Must have at least one base table.
				if (mUpdateMode != Mode.OFF && ev.BaseTables.Count == 0)
				{
					string msg = "Event " + (mEvents.Count + 1).ToString();
					throw new MTXmlException("No base tables found in materialized view, " + msg + ", configuration file: " + filename);
				}

				// Build a list of operations for current event.
				foreach (XmlNode op in nodeEvent.SelectNodes("Operation"))
				{
					// Required: Get operation name.
					XmlAttributeCollection attribs = op.Attributes;
					XmlNode nodeOpName = attribs.GetNamedItem("Name");
					string opDisplayName = nodeOpName.InnerText;
					string opName = ConvertOperationType(opDisplayName);

					// Required: update query tag if bSupportsCustomQueries is false
					XmlNode qNode = MTXmlDocument.SingleNodeExists(op, "update_query_tag");
					if (tmpNode != null)
					{
						string tag = MTXmlDocument.GetNodeValueAsString(op, "update_query_tag");
						tag = tag.Trim();
						if (tag == String.Empty)
						{
							string msg = "No value specified for required update_query_tag, operation Name=\"" + opDisplayName +"\"";
							msg += ", materialized view \"" + mName + "\", configuration file: \""
								+ filename + "\"";
							throw new MTXmlException(msg);
						}
						else
							ev.QueryTags[opName] = tag;
					}
				}

				if (!bSupportsCustomQueries)
				{
					// Must have at least one operation configured per event.
					// No query tags means no operations.
					if (ev.QueryTags.Count == 0)
					{
						string msg = "Event " + (mEvents.Count + 1).ToString();
						throw new MTXmlException("No operations found in materialized view, " + msg + ", configuration file: " + filename);
					}
				}

				// Add event.
				mEvents.Add(ev);
			}

			// Must have at least one event configured.
			if (mEvents.Count == 0)
				throw new MTXmlException("No events found in materialized view configuration file: " + filename);
		}

		public string Name
		{
			get { return mName; }
		}
		public string TableName
		{
			get { return "t_mv_" + mName; }
		}
		public string Description
		{
			get { return mDescription; }
		}
		public string ProgId
		{
			get { return mProgId; }
		}
		public string Checksum
		{
			get { return mChecksum; }
			set { mChecksum = value; }
		}
		public Mode UpdateMode
		{
			get { return mUpdateMode; }
		}

		/// <summary>
		/// Return the db value for the mode type the materialized view is configured to be in.
		/// </summary>
		public string UpdateModeDB
		{
			get
			{
				if (mUpdateMode == Mode.TRANSACTIONAL)
					return "T";
				else if (mUpdateMode == Mode.DEFERRED)
					return "D";
				else if (mUpdateMode == Mode.OFF)
					return "O";

				throw new MTXmlException("Unknown update mode");
			}
		}
		public string QueryPath
		{
			get { return mQueryPath; }
		}
		public string CreateQueryTag
		{
			get { return mCreateQueryTag; }
		}

		public string DropQueryTag
		{
			get { return mDropQueryTag; }
		}		

		public string InitQueryTag
		{
			get { return mInitQueryTag; }
		}		

 		public string FullQueryTag
		{
			get { return mFullQueryTag; }
		}
		public ArrayList Events
		{
			get { return mEvents; }
		}
		public ArrayList BaseTables
		{
			get
			{
				if (mBaseTables == null)
				{				
					// Loop through all the events and get all base tables.
					mBaseTables = new ArrayList();
					foreach(MaterializedViewEvent ev in mEvents)
					{
						foreach(string BaseTableName in ev.BaseTables)
						{
							if (mBaseTables.Contains(BaseTableName))
								continue;

							mBaseTables.Add(BaseTableName);
						}
					}
				}
				return mBaseTables;
			}
		}
		public ArrayList QueryTags
		{
			get
			{
				if (mQueryTags == null)
				{				
					mQueryTags = new ArrayList();

					// Required tag: Add the create query tag.
					if (!mQueryTags.Contains(mCreateQueryTag))
						mQueryTags.Add(mCreateQueryTag);

					// Optional tag: Add the drop query tag.
					if (mDropQueryTag != null && 
						mDropQueryTag != String.Empty &&
						!mQueryTags.Contains(mDropQueryTag))
						mQueryTags.Add(mDropQueryTag);

					// Optional tag: Add the init query tag.
					if (mInitQueryTag != null && 
						mInitQueryTag != String.Empty &&
						!mQueryTags.Contains(mInitQueryTag))
						mQueryTags.Add(mInitQueryTag);

					// Required tag: Add the full query tag.
					if (!mQueryTags.Contains(mFullQueryTag))
						mQueryTags.Add(mFullQueryTag);

					// Loop through all the events and get all base tables.
					foreach(MaterializedViewEvent ev in mEvents)
					{
						// Insert into query tag table.
						foreach(string opName in ev.Operations)
						{
							string UpdateQuery = ev.GetQueryTag(opName);
							if (!mQueryTags.Contains(UpdateQuery))
								mQueryTags.Add(UpdateQuery);
						}
					}
				}
				return mQueryTags;
			}
		}

		/// <summary>
		/// Convert configuration update mode value to mode type.
		/// </summary>
		/// <param name="UpdateMode"></param>
		/// <returns></returns>
		private Mode ConvertUpdateModeNameToType(string strUpdateMode)
		{
			if (string.Compare(strUpdateMode, "TRANSACTIONAL", true) == 0)
				return Mode.TRANSACTIONAL;
			else if (string.Compare(strUpdateMode, "DEFERRED", true) == 0)
				return Mode.DEFERRED;
			else if (string.Compare(strUpdateMode, "OFF", true) == 0)
				return Mode.OFF;
			else if (strUpdateMode == null || strUpdateMode == String.Empty)
				throw new MTXmlException("Update mode not specified");
			else
				throw new MTXmlException("Invalid update mode: " + strUpdateMode);
		}

		/// <summary>
		/// Convert configuration operation value to db value
		/// </summary>
		/// <param name="UpdateMode"></param>
		/// <returns></returns>
		private string ConvertOperationType(string operation)
		{
			if (string.Compare(operation, "delete", true) == 0)
				return "D";
			else if (string.Compare(operation, "insert", true) == 0)
				return "I";
			else if (string.Compare(operation, "update", true) == 0)
				return "U";
			else if (operation == null || operation == String.Empty)
				throw new MTXmlException("Operation Name attribute not specified");
			else
				throw new MTXmlException("Invalid Operation Name attribute: " + operation);
		}

		// Data members
		private string mName = String.Empty;
		private string mDescription = String.Empty;
		private string mProgId = String.Empty;
		private Mode mUpdateMode;
		private string mQueryPath = String.Empty;
		private string mCreateQueryTag = String.Empty;
		private string mDropQueryTag = String.Empty;
		private string mInitQueryTag = String.Empty;
		private string mFullQueryTag = String.Empty;
		private string mChecksum = String.Empty;
		private ArrayList mEvents = new ArrayList();
		private ArrayList mBaseTables = null;
		private ArrayList mQueryTags = null;
	}

	public class MaterializedViewDefinitionCollection
	{
		public MaterializedViewDefinitionCollection()
		{
			InitMaterializedViewDefList();
		}

		/// <summary>
		/// Return true if materialized view is referenced in the collection
		/// by another materialized view in specified mode.
		/// </summary>
		/// <param name="Name"></param>
		/// <param name="UpdateMode"></param>
		/// <returns></returns>
		public bool IsReferenced(string BaseTableName, MaterializedViewDefinition.Mode UpdateMode)
		{
			foreach (string Name in mMVDefFilenames)
			{
				// Get materialized view definition.
				MaterializedViewDefinition mvDef = GetMaterializedViewDefinition(Name);

				// Check if materialized view has the mode.
				if (mvDef.UpdateMode == UpdateMode)
				{
					// Loop through all the base tables to check if referenced.
					if (mvDef.BaseTables.Contains(BaseTableName))
						return true;
				}
			}
			return false;
		}

		// Initialize the materialized view collection
		private void InitMaterializedViewDefList()
		{
			string query = mDirName + "\\*.xml";

			// Find all files and populate MV def collection.
			foreach (string filename in MTXmlDocument.FindFilesInExtensions(query))
			{
				// Get MV def name.
				string defName = FilenameToDefName(filename);

				// Special case: one of these files is not like the others,
				// one of these files is a configuration file my brother!
				if (defName == "config")
					continue; // skip

				// Check if MV definition already exists.
				if (mMVDefFilenames[defName] != null)
				{
					string msg = "Materialized View (" + defName + ") configured in file: \"" + filename + "\" is already defined in file: \"" + mMVDefFilenames[defName] + "\"";
					throw new MTXmlException(msg);
				}

				// Add to collection
				mMVDefFilenames[defName] = filename;
			}
		}

		// Calculate the checksum for this materialized view base on create query.
		private string CreateChecksum(string query)
		{
			// Strip comments.
			string strNewQuery = Manager.StripComments(query);

			// Strip whitespace space.
			strNewQuery = strNewQuery.Replace(" ", "");
			strNewQuery = strNewQuery.Replace("\t", "");
			strNewQuery = strNewQuery.Replace("\r", "");
			strNewQuery = strNewQuery.Replace("\n", "");

			// Get the default encoding. 
			Encoding en = Encoding.GetEncoding(0); 

			// Encode the data and return checksum.
			MD5 md5 = new MD5CryptoServiceProvider();
			byte[] result = md5.ComputeHash(en.GetBytes(strNewQuery));
			return Convert.ToBase64String(result);
		}

		// Convert file name to materialized view def name
		public static string FilenameToDefName(string filename)
		{
			int delim = filename.IndexOf(mDirName);

			if (delim == -1)
				throw new System.ArgumentException(filename + " is not a valid materialized view name");

			string defName = filename.Substring(delim + mDirName.Length + 1);
			
			// Change slashes
			defName = defName.Replace('\\', '/');
			defName = defName.Replace(".xml", "");
			defName	= defName.ToLower();
			return defName;
		}

		public MaterializedViewDefinition GetMaterializedViewDefinition(string MaterializedViewName)
		{
			string filename = mMVDefFilenames[MaterializedViewName];
			if (filename == null)
			{
				// See if materialized view table name was passed in instead of name.
				MaterializedViewName = Bindings.GetMVNameFromTableName(MaterializedViewName);
				if (MaterializedViewName != null)
					filename = mMVDefFilenames[MaterializedViewName];
	
				if (filename == null)
					return null;
			}

			// First check to see if we've already cached it.
			MaterializedViewDefinition def = (MaterializedViewDefinition) mMVDefs[filename];
			if (def != null)
				return def;

			// Not cached - read it in and cache it.
			def = new MaterializedViewDefinition(filename);

			// Do not bother validating query tags for disabled materialized views
			// or views in test mode.
			if (def.UpdateMode != MaterializedViewDefinition.Mode.OFF)
			{
				// Init query adapter.
				mQueryAdapter.Init(def.QueryPath);

				// Validate all query tags.
				foreach(string QueryTagName in def.QueryTags)
				{
					try
					{
						mQueryAdapter.SetQueryTag(QueryTagName);
					}
					catch (Exception e)
					{
						string msg = "Materialized view \"" + MaterializedViewName + "\", configuration file: \""
							+ filename + "\"";
						throw new MTXmlException(e.Message + ", " + msg);
					}
				}

				// Substitute tags
				string tag = "%%" + def.Name + "%%";
				tag = tag.ToUpper();
				mQueryAdapter.SetQueryTag(def.CreateQueryTag);
				mQueryAdapter.AddParam(tag, def.TableName, false);
				string CreateQuery = mQueryAdapter.GetQuery();

				// Calculate the checksum for the materialized view.
				def.Checksum = CreateChecksum(CreateQuery);
			}

			// Add to cache and return.
			mMVDefs[filename] = def;
			return def;
		}

		/// <summary>
		/// 
		/// </summary>
		public IEnumerable Names
		{
			get
			{
				return mMVDefFilenames.Keys;
			}
		}

		public string GetMaterializedViewFilename(string MaterializedViewName)
		{
			return mMVDefFilenames[MaterializedViewName];
		}

		public IEnumerable SortedNames
		{
			get
			{
				string [] names = new string[mMVDefFilenames.Count];
				ICollection coll = mMVDefFilenames.Keys;
				coll.CopyTo(names, 0);
				Array.Sort(names);
				return names;
			}
		}
		
		public bool Contains(string MaterializedViewName)
		{
			return (mMVDefFilenames[MaterializedViewName] == null) ? false : true;
		}

		// Mapping of materialized view def name to full filename.
		private NameValueCollection mMVDefFilenames = new NameValueCollection();

		// Directory where all materialized views are configured.
		public static string mDirName = "config\\MaterializedViews";

		// Mapping of materialized view filename to materialized view def object.
		// NOTE: this is case sensitive.
		private Hashtable mMVDefs = new Hashtable();

		// Query adapter used for query tag validation.
		QueryAdapter.IMTQueryAdapter mQueryAdapter = new QueryAdapter.MTQueryAdapter();
	}
}

// EOF