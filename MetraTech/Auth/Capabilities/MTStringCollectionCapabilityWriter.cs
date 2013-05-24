using System;
using System.EnterpriseServices;
using System.Transactions;

using MetraTech.Interop.MTAuth;
using MetraTech.DataAccess;
using MetraTech.Interop.QueryAdapter;
using System.Runtime.InteropServices;
/*The MTStringCollectionCapabilityWriter class is a COM+ class that provides the functionality 
 * for writing and deleting the collection of strings for the MTStringCollectionCapability.  
 * This is implemented as a separate class to keep it stateless and it is COM+ to ensure 
 * that it enlists in transactions properly when called from unmanaged code.  */
namespace MetraTech.Auth.Capabilities
{
    [Guid("C028D1A8-88F2-490f-BC32-4ED3C5638122")]
    public interface IMTStringCollectionCapabilityWriter
    {
        void CreateOrUpdate(int instanceId, IMTCollection parameters);
        void Remove(int instanceId);
    }

    [Guid("926dbf89-9268-4326-88e5-9153a30c2ae0")]
    [Transaction(TransactionOption.Supported, Isolation = TransactionIsolationLevel.Any)]
    public class MTStringCollectionCapabilityWriter : ServicedComponent, IMTStringCollectionCapabilityWriter
    {
        private const String tableName = "t_str_col_capability";
        private const String queryPath = @"Queries\Auth";

        [AutoComplete]
        public void CreateOrUpdate(int instanceId, IMTCollection parameters)
        {
            Transaction ambient = Transaction.Current;
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                {
//                    First delete the old parameter 
                    queryAdapter.Item = new MTQueryAdapter();
                    queryAdapter.Item.Init(queryPath);
                    queryAdapter.Item.SetQueryTag("__DEL_PARAMETER__");
                    queryAdapter.Item.AddParam("%%TABLE_NAME%%", tableName);
                    using (IMTPreparedStatement deleteStmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                    {
                        deleteStmt.AddParam("id", MTParameterType.Integer, instanceId);
                        deleteStmt.ExecuteNonQuery();
                    }

                    // Now add the new ones
                    queryAdapter.Item.SetQueryTag("__INS_STR_PARAMETER__");
                    queryAdapter.Item.AddParam("%%TABLE_NAME%%", tableName);
                    using (IMTPreparedStatement createStmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                    {
                        foreach (String param in parameters)
                        {
                            createStmt.ClearParams();
                            createStmt.AddParam("id", MTParameterType.Integer, instanceId);
                            createStmt.AddParam("param", MTParameterType.String, param);
                            int linesAffected = createStmt.ExecuteNonQuery();
                        }
                    }
                    ambient = Transaction.Current;                
                }
            }
        }


        [AutoComplete]
        public void Remove(int instanceId)
        {
            using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                    queryAdapter.Item = new MTQueryAdapter();
                    queryAdapter.Item.Init(queryPath);
                    queryAdapter.Item.SetQueryTag("__DEL_PARAMETER__");
                    queryAdapter.Item.AddParam("%%TABLE_NAME%%", tableName);
                    using (IMTPreparedStatement deleteStmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                    {
                        deleteStmt.AddParam("id", MTParameterType.Integer, instanceId);
                        deleteStmt.ExecuteNonQuery();
                    }
                }
            }
        }

    }

}
