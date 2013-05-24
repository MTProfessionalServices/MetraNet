using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.DataAccess;

namespace MetraTech.ActivityServices.Services.Common
{
    public class PTTableDef
    {
        public int ID { get; set; }
        public string Name { get; set; }
        public string TableName { get; set; }
    }

    public class CacheManager
    {
        #region Parameter Table Name-ID Cache
        #region Members
        private static bool m_IsPTCacheInitialized = false;
        private static object m_PTLockObject = new Object();
        private const string SERVICEBASE_QUERY_FOLDER = @"queries\ServiceBase";
        #endregion

        #region Properties
        public static Dictionary<int, PTTableDef> ParamTableIdToNameMap { get; private set; }
        public static Dictionary<string, PTTableDef> ParamTableNameToIdMap { get; private set; }
        #endregion

        #region Initialization Functions
        public static void InitializeParameterTableCache()
        {
            lock (m_PTLockObject)
            {
                if (!m_IsPTCacheInitialized)
                {
                    ParamTableIdToNameMap = new Dictionary<int, PTTableDef>();
                    ParamTableNameToIdMap = new Dictionary<string, PTTableDef>();

                    using (IMTConnection conn = ConnectionManager.CreateConnection())
                    {

                        #region Load Parameter Table Map
                        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(SERVICEBASE_QUERY_FOLDER, "__LOAD_PT_MAP__"))
                        {
                            using (IMTDataReader rdr = stmt.ExecuteReader())
                            {
                                while (rdr.Read())
                                {
                                    PTTableDef tableDef = new PTTableDef();
                                    tableDef.ID = rdr.GetInt32("id_paramtable");
                                    tableDef.Name = rdr.GetString("nm_name");
                                    tableDef.TableName = rdr.GetString("nm_instance_tablename");

                                    ParamTableIdToNameMap.Add(tableDef.ID, tableDef);
                                    ParamTableNameToIdMap.Add(tableDef.Name.ToUpper(), tableDef);
                                }
                            }
                        }
                        #endregion
                    }

                    m_IsPTCacheInitialized = true;
                }
            }
        }
        #endregion
        #endregion
    }
}
