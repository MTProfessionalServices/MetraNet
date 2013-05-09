using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using System.Data.Linq;
using System.Data.Linq.Mapping;
using System.Xml;
using DataGenerators;
using NetMeterObj;

namespace BaselineGUI
{
    public class FCNetMeter : FrameworkComponentBase, IFrameworkComponent
    {
        public NetMeter netMeter = new NetMeter();

        public FCNetMeter()
        {
            name = "NetMeter";
            fullName = "NetMeter Repository";
            priority = 2;
        }


        public void Teardown()
        {
        }



        public void Bringup()
        {
            bringupState.message = "Loading...";

            netMeter.init(Framework.conn);

            bringupState.message = "Done";
        }


        public bool doesLoginExist(string nm_login, string nm_space)
        {
            return NetMeter.AccountMapperBy_nm_login_nm_space.ContainsKey(new Tuple<string,string>(nm_login, nm_space));
        }


        public void reserveLogin(string nm_login, string nm_space)
        {
            AccountMapper am = new AccountMapper();
            am.nm_login = nm_login;
            am.nm_space = nm_space;
            am.id_acc = -2;

            NetMeter.AccountMapperBy_nm_login_nm_space.Add(new Tuple<string, string>(nm_login, nm_space), am);
        }



        int target_id_type = -1;
        public int pickReadableAccountID()
        {
            if (target_id_type == -1)
            {
                target_id_type = NetMeterObj.NetMeter.AccountTypeBy_name["CustomerAccount"].id_type;
            }

            for( int loops=0; loops<50; loops++)
            {
                int ix = DataGenerator.random.Next(Math.Min(NetMeterObj.NetMeter.AccountList.Count, 1000000));
                NetMeterObj.Account acct = NetMeterObj.NetMeter.AccountList[ix];
                if (acct.id_type == target_id_type)
                    return acct.id_acc;
            }
            throw new Exception("Failed to find a readable account");
        }


        public int pickModifiableAccountID()
        {
            if (target_id_type == -1)
            {
                target_id_type = NetMeterObj.NetMeter.AccountTypeBy_name["CustomerAccount"].id_type;
            }

            for (int loops = 0; loops < 50; loops++)
            {
                int ix = DataGenerator.random.Next(Math.Min(NetMeterObj.NetMeter.modifiableAccounts.Count, 1000000));
                NetMeterObj.Account acct = NetMeterObj.NetMeter.AccountList[ix];
                if (acct.id_type == target_id_type)
                    return acct.id_acc;
            }
            throw new Exception("Failed to find a modifiable account");
        }


    }
}
