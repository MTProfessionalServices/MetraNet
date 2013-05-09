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
    public partial class NetMeterObj
    {
        public static List<T> load<T>(DataContext dc, string tableName) where T : new()
        {
            List<T> list = new List<T>();
            T a = new T();
            AdapterWidget aw = AdapterWidgetFactory.find(tableName);
            if (aw.loadFromDb)
            {
                list = dc.ExecuteQuery<T>(string.Format("select * from {0}", tableName)).ToList<T>();
            }
            Console.WriteLine("Read {0} {1}", list.Count, a.GetType());
            return list;
        }

        public virtual void init(SqlConnection conn)
        {
            DataContext dc = new DataContext(conn);
            createAdapterWidgets();

            AvContact.adapterWidget.loadFromDb = false;
            PrincipalPolicy.adapterWidget.loadFromDb = false;
            CapabilityInstance.adapterWidget.loadFromDb = false;
            EnumCapability.adapterWidget.loadFromDb = false;
            PathCapability.adapterWidget.loadFromDb = false;
            UserCredentials.adapterWidget.loadFromDb = false;
            Profile.adapterWidget.loadFromDb = false;
            DmAccount.adapterWidget.loadFromDb = false;
            DmAccountAncestor.adapterWidget.loadFromDb = false;
            PolicyRole.adapterWidget.loadFromDb = false;
            AccountState.adapterWidget.loadFromDb = false;
            AccountStateHistory.adapterWidget.loadFromDb = false;
            PaymentRedirection.adapterWidget.loadFromDb = false;
            PaymentRedirHistory.adapterWidget.loadFromDb = false;
            SiteUser.adapterWidget.loadFromDb = false;

            loadLists(dc);
        }

    }

    public partial class AccountMapper
    {
        public string key()
        {
            return nm_login + "|" + nm_space;
        }
    }


    public class NetMeter : NetMeterObj
    {

        public NetMeter()
        {

        }

        public new void init(SqlConnection conn)
        {

            base.init(conn);
            IdAllocatorFactory.init(conn);
        }

        // The ID Allocation Interface
        public static Int32 getID32(string key)
        {
            return IdAllocatorFactory.getID32(key);
        }

        public static Int64 getID64(string key)
        {
            return IdAllocatorFactory.getID64(key);
        }

        public static bool doesLoginExist(string login, string space)
        {
            if (AccountMapperBy_nm_login_nm_space.ContainsKey(new Tuple<string, string>(login, space)))
            {
                return true;
            }
            return false;
        }

        public static void reserveLogin(string login, string space, int id_acc)
        {
            Tuple<string, string> key = new Tuple<string, string>(login, space);
            AccountMapper am = new AccountMapper();
            am.id_acc = id_acc;
            am.nm_login = login;
            am.nm_space = space;

            AccountMapperList.Add(am);
            AccountMapperBy_nm_login_nm_space.Add(key, am);
            AccountMapperBy_id_acc.Add(id_acc, am);
        }

    }

}
