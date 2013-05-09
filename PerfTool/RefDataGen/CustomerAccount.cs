using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using DataGenerators;
using NetMeterObj;

namespace AppRefData
{
    public class CustomerAccount : AccountAggregate
    {
        public static DataGenerator dg;
        public static Random random = new Random();
        static int corpIx = random.Next(100);

        static CustomerAccount()
        {
            dg = DataGenerator.instance;
        }


        public CustomerAccount()
        {
        }

        public void populate()
        {
            id_type = NetMeter.AccountTypeBy_name["CustomerAccount"].id_type;
            setContactView();
        }

        void setEmail(AvContact cView)
        {
            cView.c_Email = cView.c_FirstName.Substring(0, 1) +
                   cView.c_MiddleInitial +
                   cView.c_LastName +
                   "@coldmail.com";
        }


        string getLogin(AvContact cView)
        {
            return cView.c_FirstName.Substring(0, 1) +
                    cView.c_MiddleInitial +
                    cView.c_LastName;
        }


        void setContactView()
        {
            AvContact cView = avContacts[0];

            while (true)
            {
                cView.c_FirstName = dg.pickFirst();
                cView.c_MiddleInitial = dg.pickFirst().Substring(0, 1);
                cView.c_LastName = dg.pickLast();

                nm_login = getLogin(cView);
                if (NetMeter.doesLoginExist(nm_login, "mt"))
                    continue;

                NetMeter.reserveLogin(nm_login, "mt", id_acc);
                break;
            }

            City city = dg.pickCity();

            cView.c_City = city.Name;
            cView.c_State = city.State;

            setEmail(cView);
        }
    }
}
