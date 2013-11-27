using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using System.Text;
using MetraTech.Account.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
//using MetraTech.DomainModel.Enums.GSM.Metratech_com_GSM;
//using MetraTech.DomainModel.Enums.GSM.Metratech_com_GSMReference;
using System.Diagnostics;
using DataGenerators;
using System.Data;
using System.Data.SqlClient;
using System.IO;

namespace BaselineGUI
{

    public class MASAccount
    {
        DataGenerator dg;
        public static Random random = new Random();

        int sequence = 0;
        static int corpIx = random.Next(100);

        public MASAccount()
        {
            //this.liveStatus = liveStatus;
            dg = DataGenerator.instance;
            // openClient();
        }





        ContactView makeContactView()
        {
            ContactView cView = new ContactView();

            cView.ContactType = ContactType.None;

            while (true)
            {
                cView.FirstName = dg.pickFirst();
                cView.MiddleInitial = dg.pickFirst().Substring(0, 1);
                cView.LastName = dg.pickLast();

                string login = getLogin(cView);
                if (Framework.netMeter.doesLoginExist(login, "mt"))
                    continue;

                Framework.netMeter.reserveLogin(login, "mt");
                break;
            }

            City city = dg.pickCity();

            cView.City = city.Name;
            cView.State = city.State;

            setEmail(cView);

            return cView;
        }

        void setEmail(ContactView cView)
        {
            cView.Email = cView.FirstName.Substring(0, 1) +
                   cView.MiddleInitial +
                   cView.LastName +
                   "@coldmail.com";
        }


        string getLogin(ContactView cView)
        {
            return cView.FirstName.Substring(0, 1) +
                    cView.MiddleInitial +
                    cView.LastName;
        }


        InternalView makeInternalView()
        {
            InternalView iView = new InternalView();

            iView = new InternalView();
            iView.Language = LanguageCode.US;
            iView.Currency = "USD";
            iView.UsageCycleType = UsageCycleType.Monthly;
            iView.Billable = true;
            iView.InvoiceMethod = InvoiceMethod.Standard;
            iView.TimezoneID = TimeZoneID._GMT_05_00__Eastern_Time__US___Canada_;
            return iView;

        }


        ServiceView makeServiceView()
        {
            ServiceView sView = new ServiceView();
            sView.IMSI = dg.pickIMSI();
            sView.MSISDN = sView.IMSI;

            return sView;
        }

        void setAccountDefaults(Account acct)
        {
            acct.AncestorAccount = "Bad boyz";
            acct.AncestorAccountNS = "mt";

            acct.Name_Space = "mt";
            acct.UserName = "test";
            acct.Password_ = "MetraTech1";
            acct.DayOfMonth = 1;
            acct.AccountStatus = AccountStatus.Active;
        }


        public CorporateAccount makeCorporateAccount(string userName)
        {
            CorporateAccount acct = new CorporateAccount();
            setAccountDefaults(acct);
            acct.AncestorAccount = null;
            acct.AncestorAccountNS = null;

            acct.Internal = makeInternalView();
            acct.Internal.Folder = true;
            acct.Internal.Billable = true;

            acct.UserName = userName;

            return acct;
        }


        public CustomerAccount makeCustomerAccount()
        {
            CustomerAccount acct = new CustomerAccount();
            setAccountDefaults(acct);

            string s;
            s = string.Format("Corp{0:D3}", corpIx);
            corpIx++;
            if (corpIx >= 100)
                corpIx = 0;

            acct.AncestorAccount = s;
            acct.Internal = makeInternalView();
            acct.Internal.Billable = true;

            acct.LDAP = new List<ContactView>();
            ContactView contact = makeContactView();
            acct.LDAP.Add(contact);
            acct.UserName = getLogin(contact);

            return acct;
        }


        public SubscriberAccount makeSubscriberAccount(CustomerAccount parent)
        {
            SubscriberAccount acct = new SubscriberAccount();
            setAccountDefaults(acct);
            acct.AncestorAccount = parent.UserName;
            acct.AncestorAccountNS = parent.Name_Space;

            acct.Internal = makeInternalView();

            acct.LDAP = new List<ContactView>();
            ContactView contact = makeContactView();
            acct.LDAP.Add(contact);
            acct.UserName = getLogin(contact);

            return acct;
        }

        public ServiceAccount makeServiceAccount(SubscriberAccount parent)
        {
            ServiceAccount acct = new ServiceAccount();
            setAccountDefaults(acct);
            acct.AncestorAccount = parent.UserName;
            acct.AncestorAccountNS = parent.Name_Space;

            acct.Internal = makeInternalView();

            while (true)
            {
                acct.Service = makeServiceView();
                if (Framework.netMeter.doesLoginExist(acct.Service.IMSI, "mt"))
                    continue;

                Framework.netMeter.reserveLogin(acct.Service.IMSI, "mt");
                break;
            }

            acct.UserName = acct.Service.IMSI;
            acct.Name_Space = "mt";

            // TODO Remove once payer direction is working in the pipeline
            acct.LDAP = new List<ContactView>();
            ContactView contact = makeContactView();
            acct.LDAP.Add(contact);

            return acct;
        }



        public StreamWriter contactViewWriter;
        public StreamWriter internalViewWriter;
        public StreamWriter serviceViewWriter;

        public StreamWriter customerWriter;
        public StreamWriter subscriberWriter;
        public StreamWriter serviceWriter;

        public bool writersAreOpen = false;

        public StreamWriter makeStreamWriter(string what)
        {
            string s = @"C:\MetraTech\RMP\MetraConvertData\input_files\";
            s += what;
            s += ".01";
            s += ".data";
            return new StreamWriter(s);
        }

        public void openWriters()
        {
            if (writersAreOpen)
                return;

            contactViewWriter = makeStreamWriter("CONTACT");
            internalViewWriter = new StreamWriter(@"C:\temp\acct\internalView.txt");
            serviceViewWriter = new StreamWriter(@"C:\temp\acct\serviceView.txt");

            customerWriter = makeStreamWriter("ACCOUNT_CUSTOMERACCOUNT");
            subscriberWriter = makeStreamWriter("ACCOUNT_SUBSCRIBERACCOUNT");
            serviceWriter = makeStreamWriter("ACCOUNT_SERVICEACCOUNT");

            writersAreOpen = true;
        }

        public void closeWriters()
        {
            contactViewWriter.Close();
            internalViewWriter.Close();
            serviceViewWriter.Close();

            customerWriter.Close();
            subscriberWriter.Close();
            serviceWriter.Close();
            writersAreOpen = false;
        }


        public void writeContactView(ContactView view, string nm, string username)
        {
            contactViewWriter.Write("{0}`|{1}", nm, username);
            contactViewWriter.Write("`|{0}", view.ContactType);

            contactViewWriter.Write("`|{0}", view.FirstName);
            contactViewWriter.Write("`|{0}", view.MiddleInitial);
            contactViewWriter.Write("`|{0}", view.LastName);

            contactViewWriter.Write("`|{0}", view.Address1);
            contactViewWriter.Write("`|{0}", view.Address2);

            contactViewWriter.Write("`|{0}", view.City);
            contactViewWriter.Write("`|{0}", view.State);
            contactViewWriter.WriteLine();
            contactViewWriter.Flush();
        }


        public void writeServiceView(ServiceView view, Guid acctGuid)
        {
            serviceViewWriter.Write("{0}", acctGuid);
            serviceViewWriter.Write("`|{0}", view.IMSI);
            serviceViewWriter.Write("`|{0}", view.MSISDN);

            serviceViewWriter.WriteLine();
            // internalWriter.Flush();
        }

        public void writeAccountAttrs(Account acct, Guid acctGuid, StreamWriter writer)
        {
            // writer.Write("{0}", acctGuid);
            writer.Write("{0}", acct.AncestorAccountNS);
            writer.Write("`|{0}", acct.AncestorAccount);

            writer.Write("`|{0}", acct.Name_Space);
            writer.Write("`|{0}", acct.UserName);

            writer.Write("`|{0}", acct.Password_);
            // writer.Write("`|{0}", acct.DayOfMonth);
            writer.Write("`|{0}", acct.AccountStatus);

        }


        public void writeInternalView(InternalView view, Guid acctGuid, StreamWriter writer)
        {
            //writer.Write("{0}", acctGuid);
            writer.Write("`|{0}", view.Language);
            writer.Write("`|{0}", view.Currency);
            writer.Write("`|{0}", view.UsageCycleType);

            if ((bool)view.Billable)
            {
                writer.Write("`|T", view.Billable);
            }
            else
            {
                writer.Write("`|F", view.Billable);
            }
            writer.Write("`|{0}", view.InvoiceMethod);


            // internalViewWriter.WriteLine();
            // internalWriter.Flush();
        }

        public void writeToFile(Account acct)
        {
            Guid acctGuid = Guid.NewGuid();

            if (acct is CustomerAccount)
            {
                CustomerAccount a = (CustomerAccount)acct;

                writeAccountAttrs(acct, acctGuid, customerWriter);
                writeInternalView(a.Internal, acctGuid, customerWriter);
                customerWriter.WriteLine();
                customerWriter.Flush();

                foreach (ContactView cv in a.LDAP)
                {
                    writeContactView(cv, a.Name_Space, a.UserName);
                }

            }

            if (acct is SubscriberAccount)
            {
                SubscriberAccount a = (SubscriberAccount)acct;

                writeAccountAttrs(acct, acctGuid, subscriberWriter);
                writeInternalView(a.Internal, acctGuid, subscriberWriter);
                foreach (ContactView cv in a.LDAP)
                {
                    writeContactView(cv, a.Name_Space, a.UserName);
                }
            }

            if (acct is ServiceAccount)
            {
                ServiceAccount a = (ServiceAccount)acct;

                writeAccountAttrs(acct, acctGuid, serviceWriter);
                writeInternalView(a.Internal, acctGuid, serviceWriter);
                foreach (ContactView cv in a.LDAP)
                {
                    writeContactView(cv, a.Name_Space, a.UserName);
                }
                writeServiceView(a.Service, acctGuid);
            }


        }


        public void Generate()
        {
            FCAccountLoadService als = Framework.accountLoadService;

            int custSequence;


            CustomerAccount custAcct;



            int corpAcctBin = random.Next(100);

            custAcct = makeCustomerAccount();
            custSequence = sequence++;


            als.Enqueue(custAcct, custSequence, -1, corpAcctBin);


        }



        public void GenerateCorporate()
        {
            FCAccountLoadService als = Framework.accountLoadService;

            CorporateAccount corpAcct;
            int custSequence = 0;

            for (int cx = 0; cx < 100; cx++)
            {
                string name = string.Format("Corp{0:D3}", cx);

                if (Framework.netMeter.doesLoginExist(name, "mt"))
                    continue;

                corpAcct = makeCorporateAccount(name);
                custSequence = sequence++;
                als.Enqueue(corpAcct, custSequence, -1);
            }
        }


    }


}

