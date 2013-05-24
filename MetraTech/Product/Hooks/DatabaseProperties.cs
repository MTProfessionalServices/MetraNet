using System;
using System.Collections;
using System.Xml;
using System.Runtime.InteropServices;
using System.Runtime.CompilerServices;

using MetraTech;
using MetraTech.Xml;
using MetraTech.DataAccess;
using MetraTech.Interop.MTHooklib;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.OnlineBill;
using Auth = MetraTech.Interop.MTAuth;
using System.EnterpriseServices;

[assembly: GuidAttribute("943C4ABB-3259-3963-9661-F6AC7AB5EFFA")]

//[assembly: GuidAttribute ("486ab632-6ab2-4c3a-a722-70c7ae5ee86e")]

namespace MetraTech.Product.Hooks
{
	/// <summary>
	/// Summary description for DatabaseProperties
	/// </summary>
	/// 
	[Guid("7F078E2D-B0EA-48a1-BC80-B52254A48D29")]
	[ClassInterface(ClassInterfaceType.None)]
	public class DatabaseProperties : IMTSecuredHook
	{
		public void Execute(MetraTech.Interop.MTHooklib.IMTSessionContext context, object var, ref int val)
		{
			new DBPropWriter().AddDatabaseProperty();
		}
	}
	[Guid("bcdb0e5f-7528-444e-ab93-8bc1f27bd3b2")]
	public class DatabasePropertiesException : ApplicationException
	{
		public DatabasePropertiesException(String msg) : base(msg) { }
		public DatabasePropertiesException(String msg, Exception inner) : base(msg, inner) { }
	}


	[Guid("9743e259-48b7-43a2-a8c1-3cb8b405f806")]
	public interface IDBPropWriter
	{
		void AddDatabaseProperty();
	}

	[ClassInterface(ClassInterfaceType.None)]
	[Transaction(TransactionOption.Required, Isolation = TransactionIsolationLevel.Any)]
	[Guid("399f2249-e2c7-44fb-8f4a-e82e8a307a6c")]
	public class DBPropWriter : ServicedComponent, IDBPropWriter
	{
		[AutoComplete]
		public void AddDatabaseProperty()
		{
			bool bHierarchyRestrictedOperations;
			MetraTech.Interop.MTProductCatalog.IMTProductCatalog pc;
			pc = (IMTProductCatalog)Activator.CreateInstance(Types.MTProductCatalog);
			// read the check for relaxed business rules
			if (pc.IsBusinessRuleEnabled(MetraTech.Interop.MTProductCatalog.MTPC_BUSINESS_RULE.MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations))
				bHierarchyRestrictedOperations = true;
			else
				bHierarchyRestrictedOperations = false;

			// insert into database
			using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
			{
                try
                {
                    using (IMTCallableStatement stmt = conn.CreateCallableStatement("AddDatabaseProperty"))
                    {
                        stmt.AddParam("property", MTParameterType.String, "Hierarchy_RestrictedOperations");
                        stmt.AddParam("value", MTParameterType.String, bHierarchyRestrictedOperations ? "true" : "false");
                        stmt.ExecuteNonQuery();
                    }
                }
                catch (Exception e)
                {
                    string msg = String.Format("Insert to t_db_values table failed!");
                    DatabasePropertiesException ex = new DatabasePropertiesException(msg, e);
                    throw ex;
                }
			}
		}
	}
}

// EOF 