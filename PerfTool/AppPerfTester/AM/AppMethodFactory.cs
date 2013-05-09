using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using log4net;

namespace BaselineGUI
{
    public static class AppMethodFactory
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(AppMethodFactory));

        public static Dictionary<string, AppMethodI> appMethods;
        static Dictionary<string, Type> appTypes;

        static AppMethodFactory()
        {
            try
            {
                appMethods = new Dictionary<string, AppMethodI>();
                appTypes = new Dictionary<string, Type>();

                //install<Subscriptions>();
                install<AMGetInterval>();
                install<AMGetUsageDetails>();
                install<AMGetUsageDetailsInterval>();
                install<AMGetUsageDetailsIntervalAll>();
                install<AMGetUsageDetailsFirstTen>();
                install<AMGetUsageDetailsIntervalFirstTen>();
                install<AMGetUsageDetailsIntervalFirst20>();
                install<AMGetUsageDetailsIntervalFirst30>();
                install<AMGetByProductReport>();
                install<AMLoadAccount>();
                install<AMLoadAccountWithViews>();
                install<AMGetSubscriptionDetails>();
                install<AMUpdateSubscription>();
                install<AMSubscriptionAdd>();
                install<AMSubscriptionDel>();
                install<AMGetSubscriptions>();
                install<AMGetAccountList>();
                install<AMGetAccountIDList>();
                install<AMGetAccountListPartialUserName>();
                install<AMGetAccountListEmail>();
                install<AMGetAccountListFirstLastName>();
                install<AMGetAccountListQuery>();
                install<AMInsertAuditLog>();
                install<AMGetAuditLogsForAccount>();
                install<AMGetEligiblePOs>();
                install<AMOpenWebClient>();
                install<AMMeterUsage>();
                install<AMMeterUsageAddCharge>();
            	install<AMAddAccountWithoutWorkFlow>();
                install<AMAddBmeCallLogEntry>();
                install<AMAddBmeCallLogEntryViaMas>();
                install<AMRetrieveBmeCallLogEntryViaMas>();
                install<AMRetrieveBmeCallLogEntryViaMasTelmore>();
                install<AMRetrieveBmeCallLogEntriesForAccount>();
                
#if false
                install<AMAddBmeCallLogEntryNoHistory>();
                install<AMRetrieveBmeCallLogEntriesForAccountNoHistory>();
#endif
                install<AMUpdateAccount>();
                install<AMAccountHierarchy>();
            }
            catch( Exception ex)
            {
                log.FatalFormat("Exception caught {0}", ex.ToString());
                throw ex;
            }
        }

        public static void init()
        {
        }

        private static void install<T>() where T : AppMethodI, new()
        {
            AppMethodI method;
            method = new T();
            method.msgLogger = MsgLoggerFactory.getLogger(method.name);
            appMethods.Add(method.name.ToLower(), method);

            appTypes.Add(method.name.ToLower(), typeof( T));

            AMPreferences pref = new AMPreferences();
            pref.setToDefaults();
            pref.name = method.name.ToLower();
            PrefRepo.addAmDefault(pref);

            log.DebugFormat("Installed {0}", method.name);
        }

        public static AppMethodI find(string s)
        {
            string key = s.ToLower();
            if (appMethods.ContainsKey(key))
            {
                return appMethods[key];
            }
            return null;
        }


        public static AppMethodI create(string s)
        {
            string key = s.ToLower();
            if (appTypes.ContainsKey(key))
            {
                Type type = appTypes[key];
                return (AppMethodI)Activator.CreateInstance(type);
            }
            return null;
        }
        
        public static T find<T>()
        {
            foreach (AppMethodI comp in appMethods.Values)
            {
                if (comp is T)
                {
                    return (T)comp;
                }
            }
            return default(T);
        }

        public static List<string> getAllGroupNames()
        {
            List<string> list = new List<string>();
            foreach (AppMethodI am in appMethods.Values)
            {
                if (!list.Contains(am.group))
                    list.Add(am.group);
            }
            return list;
        }

        public static List<AppMethodI> getGroup(string groupName)
        {
            List<AppMethodI> list = new List<AppMethodI>();
            foreach (AppMethodI am in appMethods.Values)
            {
                if ( am.group == groupName)
                    list.Add(am);
            }
            return list;
        }
    
    }
}
