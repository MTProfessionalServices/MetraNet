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
using log4net;

namespace NetMeterObj
{
    public partial class NetMeterObj
    {
        public bool partialLoad = false;
        public static Dictionary<int, int> AccountParent;

        public static List<T> load<T>(DataContext dc, string tableName) where T : IDbObj, new()
        {
            List<T> list = new List<T>();
            T a = new T();
            AdapterWidget aw = AdapterWidgetFactory.find(tableName);
            log.DebugFormat("tableName={0}", tableName);
            if (aw.loadFromDb)
            {
                list = dc.ExecuteQuery<T>(string.Format("select * from {0}", tableName)).ToList<T>();
            }
            Console.WriteLine("Read {0} {1}", list.Count, a.GetType());
            log.DebugFormat("count={0}, name={1}", list.Count, a.GetType());
            return list;
        }

        public void _init(SqlConnection conn)
        {
            DataContext dc = new DataContext(conn);
            createAdapterWidgets();
            AdapterWidgetFactory.buildWidgets(conn);

            SqlCommand cmd = new SqlCommand("select count(*) from t_account", conn);
            int count = 0;
            IDataReader reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                count = (int)reader[0];
            }
            reader.Close();

            BeLdpAudCalllogentry.adapterWidget.loadFromDb = false;
            BeLdpAudCalllogreason.adapterWidget.loadFromDb = false;
            AccUsage.adapterWidget.loadFromDb = false;
            PvLdperfSimplePV.adapterWidget.loadFromDb = false;
            PvFlatRecurringCharge.adapterWidget.loadFromDb = false;
            AvContact.adapterWidget.loadFromDb = false;
            AvInternal.adapterWidget.loadFromDb = false;
            PrincipalPolicy.adapterWidget.loadFromDb = false;
            CapabilityInstance.adapterWidget.loadFromDb = false;
            EnumCapability.adapterWidget.loadFromDb = false;
            PathCapability.adapterWidget.loadFromDb = false;
            UserCredentials.adapterWidget.loadFromDb = false;
            Profile.adapterWidget.loadFromDb = false;
            PolicyRole.adapterWidget.loadFromDb = false;
            AccountState.adapterWidget.loadFromDb = false;
            AccountStateHistory.adapterWidget.loadFromDb = false;
            PaymentRedirection.adapterWidget.loadFromDb = false;
            PaymentRedirHistory.adapterWidget.loadFromDb = false;
            SiteUser.adapterWidget.loadFromDb = false;
            SubHistory.adapterWidget.loadFromDb = false;

#if true
            if (count > 300000)
#else
            if (false)
#endif
            {
                partialLoad = true;
                AccountAncestor.adapterWidget.loadFromDb = false;
                DmAccount.adapterWidget.loadFromDb = false;
                DmAccountAncestor.adapterWidget.loadFromDb = false;
            }

            loadLists(dc);

            AccountParent = new Dictionary<int, int>();
            if (AccountAncestor.adapterWidget.loadFromDb)
            {
                foreach (AccountAncestor aa in AccountAncestorList)
                {
                    if (aa.num_generations == 1)
                    {
                        AccountParent[aa.id_descendent] = aa.id_ancestor;
                    }

                }
            }
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
        public static List<Account> modifiableAccounts = new List<Account>();

        public NetMeter()
        {

        }

        public void init(SqlConnection conn)
        {

            base._init(conn);
            IdAllocatorFactory.init(conn);

            foreach (Account acct in AccountList)
            {
                PerfAccountFlags flags = new PerfAccountFlags();
                flags.unpack(acct.id_acc_ext);
                if (flags.isModifiable)
                {
                    modifiableAccounts.Add(acct);
                }
            }
        }

        #region ID Allocation Helpers
        // The ID Allocation Interface
        public static Int32 getID32(string key)
        {
            return IdAllocatorFactory.getID32(key);
        }

        public static Int32 getMashedID32(string key)
        {
            return IdAllocatorFactory.getMashedID32(key);
        }


        public static Int64 getID64(string key)
        {
            return IdAllocatorFactory.getID64(key);
        }

        #endregion

        #region Account Mapper Assist
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
        #endregion

        #region Subscription Helpers
        public static bool existsAccPo(int id_acc, int id_po)
        {
            if (getSub(id_acc, id_po) != null)
                return true;
            return false;
        }

        public static void addSub(int id_acc, int id_po, int id_sub)
        {
            if (existsAccPo(id_acc, id_po))
                return;

            Sub sub = new Sub();
            sub.id_acc = id_acc;
            sub.id_po = id_po;
            sub.id_sub = id_sub;

            SubBy_id_acc.Add(id_acc, sub);
        }

        public static void delSub(int id_acc, int id_po)
        {
            Sub sub = getSub(id_acc, id_po);
            if (sub == null)
                return;

            SubBy_id_acc.Remove(id_acc, sub);
        }

        public static Sub getSub(int id_acc, int id_po)
        {
            if (SubBy_id_acc.ContainsKey(id_acc))
            {
                List<Sub> subs = SubBy_id_acc[id_acc];
                foreach (var sub in subs)
                {
                    if (sub.id_po == id_po)
                        return sub;
                }
            }
            return null;
        }
        #endregion

        #region partition management
        public static Partition findPartition(DateTime when)
        {
            foreach (Partition p in PartitionList)
            {
                if (p.dt_start < when && when < p.dt_end)
                    return p;
            }
            return null;
        }

        public static Partition findPartition(int id_interval)
        {
            foreach (Partition p in PartitionList)
            {
                if (p.id_interval_start < id_interval && id_interval < p.id_interval_end)
                    return p;
            }
            return null;
        }
        #endregion

    }

}
