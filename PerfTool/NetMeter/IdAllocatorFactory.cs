using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Data.Linq;
using System.Data.Linq.Mapping;
using System.Xml;
using System.IO;


namespace NetMeterObj
{
 


    public static class IdAllocatorFactory
    {

        static Dictionary<string, IdAllocatorBasic> idAllocs;

        static IdAllocatorFactory()
        {
            idAllocs = new Dictionary<string, IdAllocatorBasic>();
        }



        static void initID(SqlConnection conn, string key, string tableName, string column)
        {
            IdAllocatorBasic a = new IdAllocatorBasic(conn, key, tableName, column);
            idAllocs[key] = a;
        }

        public static void init(SqlConnection conn)
        {
            initID(conn, "id_acc", "t_account", "id_acc");
            initID(conn, "id_profile", "t_profile", "id_profile");
            initID(conn, "id_policy", "t_principal_policy", "id_policy");
            initID(conn, "id_dm_acc", "t_dm_account", "id_dm_acc");
            initID(conn, "id_cap_instance", "t_capability_instance", "id_cap_instance");
            initID(conn, "id_sess", "t_acc_usage", "id_sess");
        }

        public static Int32 getID32(string key)
        {
            return idAllocs[key].getID32();
        }

        public static Int64 getID64(string key)
        {
            return idAllocs[key].getID64();
        }

    }
}
