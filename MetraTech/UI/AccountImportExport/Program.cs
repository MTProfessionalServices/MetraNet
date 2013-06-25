using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Reflection;
using System.Threading;
using System.Xml.Serialization;
using MetraTech.Account.ClientProxies;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using MetraTech.UI.Tools;
using BaseTypes = MetraTech.DomainModel.BaseTypes;
using System.IO;
using System.ServiceModel;
using MetraTech.ActivityServices.Common;
using System.Xml;
using MetraTech.UI.CDT;
using MetraTech.Interop.MTServerAccess;
using RCD = MetraTech.Interop.RCD;
namespace MetraTech.UI.AccountImportExport
{
  class Program
  {
    static IMTServerAccessData AccessData;

    #region Main
    static void Main(string[] args)
    {
      try
      {
        AppDomain.CurrentDomain.AssemblyResolve += new ResolveEventHandler(CurrentDomain_AssemblyResolve);

        IMTServerAccessDataSet sa = new MTServerAccessDataSet();
        sa.Initialize();
        AccessData = sa.FindAndReturnObject("SuperUser");

        if (args.Length > 1)
        {
          switch (args[0].ToLower())
          {
            case "-i":
              if(args.Length < 2)
              {
                Console.WriteLine("You must specify the account types to work on.");
                PrintUsage();
                Environment.Exit(0);
              }
              ImportAccounts(args);
              break;

            case "-x":
              if (args.Length < 2)
              {
                Console.WriteLine("You must specify the account types to work on.");
                PrintUsage();
                Environment.Exit(0);
              }
              ExportAccounts(args);
              break;

            case "-iautosdk":
              if (args.Length != 2)
              {
                Console.WriteLine("You must specify the autoSDK file to import, and no account types.");
                PrintUsage();
                Environment.Exit(0);
              }
              ImportAutoSDKAccounts(args[1]);
              break;

            case "-getmesomeaccounts":
              if (args.Length != 5)
              {
                Console.WriteLine("You must specify the parent id, account type, name space, and number of accounts to create in that order.");
                PrintUsage();
                Environment.Exit(0);
              }
              GetMeSomeAccounts(args);
              break;

            default:
              PrintUsage();
              break;
          }
          
        }
        else
        {
          PrintUsage();
        }
      }
      catch (Exception e)
      {
        Console.WriteLine("Exception importing/exporting accounts: {0}", e.Message);
        Console.WriteLine("Error occured: {0}", e.StackTrace);
        Console.WriteLine();

        Exception inner = e.InnerException;
        while (inner != null)
        {
          Console.WriteLine("Inner Exception: {0}", inner.Message);
          Console.WriteLine("Error occured: {0}", inner.StackTrace);
          Console.WriteLine();
          inner = inner.InnerException;
        }
      }
    }

    static Assembly CurrentDomain_AssemblyResolve(object sender, ResolveEventArgs args)
    {
        Assembly retval = null;
        string searchName = args.Name.Substring(0, (args.Name.IndexOf(',') == -1 ? args.Name.Length : args.Name.IndexOf(','))).ToUpper();

        if (!searchName.Contains(".DLL"))
        {
            searchName += ".DLL";
        }

        try
        {
            AssemblyName nm = AssemblyName.GetAssemblyName(searchName);
            retval = Assembly.Load(nm);
        }
        catch (Exception)
        {
            try
            {
                retval = Assembly.LoadFrom(Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location), searchName));
            }
            catch (Exception)
            {
                RCD.IMTRcd rcd = new RCD.MTRcd();
                RCD.IMTRcdFileList fileList = rcd.RunQuery(string.Format("Bin\\{0}", searchName), false);

                if (fileList.Count > 0)
                {
                    retval = Assembly.LoadFrom(fileList[0] as string);
                }
            }
        }

        return retval;
    }

#endregion

    #region Print Usage
    /// <summary>
    /// Prints commandline usage
    /// </summary>
    private static void PrintUsage()
    {
      Console.WriteLine("Usage: AccountImportExport.exe action [filename] [options]");
      Console.WriteLine();
      Console.WriteLine("Actions:");
      Console.WriteLine("  -i                  import accounts");
      Console.WriteLine("  -x                  export accounts");
      Console.WriteLine("  -iautosdk           import account from autoSDK file");
      Console.WriteLine("  -getmesomeaccounts  generate accounts");
      Console.WriteLine();
      Console.WriteLine("Options:");
      Console.WriteLine("  [AccountTypes]      list of account types to act on (non-autoSDK mode)");
      Console.WriteLine("  [Parent ID]         parend ID (used in generate accounts)");
      Console.WriteLine("  [Account Type]      account type (used in generate accounts)");
      Console.WriteLine("  [Namespace]         namespace (used in generate accounts)");
      Console.WriteLine("  [# to create]       number of accounts to create (used in generate accounts)");
      Console.WriteLine();
      Console.WriteLine("Samples:");
      Console.WriteLine(@"  AccountImportExport.exe -i c:\acc.xml CorporateAccount DepartmentAccount");
      Console.WriteLine(@"  AccountImportExport.exe -x c:\acc.xml CorporateAccount");
      Console.WriteLine(@"  AccountImportExport.exe -iautosdk c:\auto.xml");
      Console.WriteLine(@"  AccountImportExport.exe -getmesomeaccounts 1 CorporateAccount mt 100");
      Console.WriteLine();
      Console.WriteLine("WARNING:  This tool does not export passwords, pricelists, or entities not directly on an account.");

    }
    #endregion

    #region Generate accounts
    /// <summary>
    /// Generate accounts based on the passed in args
    /// arg 0 = -getmesomeaccounts
    /// arg 1 = parent id
    /// arg 2 = account type
    /// arg 3 = namespace
    /// arg 4 = number of accounts to generate
    /// </summary>
    /// <param name="args"></param>
    private static void GetMeSomeAccounts(string[] args)
    {
      int parentID = int.Parse(args[1]);
      string accountTypeName = args[2];
      string nameSpace = args[3];
      int count = int.Parse(args[4]);

      if (count > 3)
      {
        // OK, let's create accounts on 2 threads
        GenerateAccountParameters parameters1 = new GenerateAccountParameters();
        parameters1.ParentID = parentID;
        parameters1.AccountTypeName = accountTypeName;
        parameters1.NameSpace = nameSpace;
        parameters1.Count = count/2;
        Thread t1 = new Thread(GenerateAccounts);
        t1.Start(parameters1);

        GenerateAccountParameters parameters2 = new GenerateAccountParameters();
        parameters2.ParentID = parentID;
        parameters2.AccountTypeName = accountTypeName;
        parameters2.NameSpace = nameSpace;
        parameters2.Count = count - count / 2;
        Thread t2 = new Thread(GenerateAccounts);
        t2.Start(parameters2);

        t1.Join();
        t2.Join();
      }
      else
      {
        GenerateAccounts(parentID, accountTypeName, nameSpace, count);
      }
    }

    /// <summary>
    /// internal class used to pass parameters to thread method.
    /// </summary>
    internal class GenerateAccountParameters
    {
      public int ParentID;
      public string AccountTypeName;
      public string NameSpace;
      public int Count;
    }

    /// <summary>
    /// Wrapper for GenerateAccounts used when multiple threads are in play.
    /// </summary>
    /// <param name="parameters"></param>
    private static void GenerateAccounts(object parameters)
    {
      GenerateAccountParameters obj = parameters as GenerateAccountParameters;
      if (obj != null)
      {
        GenerateAccounts(obj.ParentID, obj.AccountTypeName, obj.NameSpace, obj.Count);
      }
    }

    /// <summary>
    /// Generate account by sending it to ActivityServices.  Simple defaults, used for data load.
    /// </summary>
    /// <param name="parentID"></param>
    /// <param name="accountTypeName"></param>
    /// <param name="nameSpace"></param>
    /// <param name="count"></param>
    private static void GenerateAccounts(int parentID, string accountTypeName, string nameSpace, int count)
    {
      BaseTypes.Account account = BaseTypes.Account.CreateAccount(accountTypeName);

      // Common properties
      account.AuthenticationType = AuthenticationType.MetraNetInternal;
      if (String.IsNullOrEmpty(nameSpace))
      {
        nameSpace = "mt";
      }
      account.AncestorAccountID = parentID;
      account.Password_ = "123";
      account.Name_Space = nameSpace;
      account.DayOfMonth = 1;
      account.AccountStatus = AccountStatus.Active;

      int guid = Guid.NewGuid().GetHashCode();
      for (int i = 0; i < count; i++)
      {
        string userName = string.Format("{0}_{1}_{2}", accountTypeName, guid, i);

        account.UserName = userName;

        InternalView internalView = (InternalView)View.CreateView(@"metratech.com/internal");
        internalView.UsageCycleType = UsageCycleType.Monthly;
        internalView.Billable = true;
        internalView.Language = LanguageCode.US;
        internalView.Currency = "USD";
        internalView.TimezoneID = TimeZoneID._GMT_05_00__Eastern_Time__US___Canada_;

        if (accountTypeName.ToLower() == "gsmserviceaccount")
        {
          internalView.Billable = false;
          account.PayerID = account.AncestorAccountID;
        }

        account.AddView(internalView, "Internal");

        AccountCreationClient client = null;

        try
        {
          client = new AccountCreationClient();
          client.ClientCredentials.UserName.UserName = AccessData.UserName;
          client.ClientCredentials.UserName.Password = AccessData.Password;

          client.AddAccount(ref account, false);
          client.Close();
        }
        catch (FaultException<MASBasicFaultDetail> fe)
        {
          Console.WriteLine("Exception adding account: {0}", fe.Message);

          foreach (string detail in fe.Detail.ErrorMessages)
          {
            Console.WriteLine("Detail: {0}", detail);
          }

          Console.WriteLine();
          client.Abort();
          // recreate client
          client = new AccountCreationClient();
          client.ClientCredentials.UserName.UserName = AccessData.UserName;
          client.ClientCredentials.UserName.Password = AccessData.Password;
        }
        catch (Exception e)
        {
          Console.WriteLine(e.ToString());
          client.Abort();
          throw;
        }
      }
    }
#endregion

    #region Export accounts
    /// <summary>
    /// Export accounts to an xml file for the specified types, does not handle pricelist or passwords.
    /// arg 0 = -x
    /// arg 1 = filename
    /// arg 2 - N = account types to act on
    /// </summary>
    /// <param name="args"></param>
    private static void ExportAccounts(string[] args)
    {
      List<BaseTypes.Account> accounts = new List<BaseTypes.Account>();

      for (int i = 2; i < args.Length; i++)
      {
        AddAccountsOfType(accounts, args[i]);
      }

      TextWriter outputFile = new StreamWriter(args[1]);
      XmlSerializer serializer = new XmlSerializer(typeof(List<BaseTypes.Account>), BaseTypes.Account.KnownTypes());

      serializer.Serialize(outputFile, accounts);
      outputFile.Close();  
    }

    /// <summary>
    /// Does an account search to load accounts of the specified tye into the List of accounts being returned.
    /// </summary>
    /// <param name="accts"></param>
    /// <param name="accountType"></param>
    private static void AddAccountsOfType(ICollection<BaseTypes.Account> accts, string accountType)
    {
        AccountServiceClient client = null;

        try
        {
          client = new AccountServiceClient();
          client.ClientCredentials.UserName.UserName = AccessData.UserName;
          client.ClientCredentials.UserName.Password = AccessData.Password;

          int accountCount = 0;
          int maxAccounts;
          int currentPage = 0;

          do
          {
            MTList<BaseTypes.Account> accounts = new MTList<BaseTypes.Account>();
            accounts.Filters.Add(new MTFilterElement("AccountType", MTFilterElement.OperationType.Equal, accountType));
            accounts.PageSize = 11;
            accounts.CurrentPage = ++currentPage;

            client.GetAccountList(DateTime.Now, ref accounts, false);
            maxAccounts = accounts.TotalRows;

            foreach (BaseTypes.Account a in accounts.Items)
            {
              a._AccountID = null;
              a.PayerID = null;
              a.AncestorAccountID = null;

              accts.Add(a);

              ++accountCount;
            }
          } while (accountCount < maxAccounts);
          
          client.Close();
        }
        catch (Exception e)
        {
          Console.WriteLine(e.ToString());
          client.Abort();
          throw;
        }
    }
    #endregion

    #region Import accounts
    /// <summary>
    /// Imports accounts from xml file.
    /// arg 0 = -i
    /// arg 1 = filename
    /// arg 2 - N = account type to import
    /// </summary>
    /// <param name="args"></param>
    private static void ImportAccounts(string[] args)
    {
      List<string> accountTypes = new List<string>();
      for (int i = 2; i < args.Length; i++)
      {
        accountTypes.Add(args[i]);
      }

      List<BaseTypes.Account> accounts;
      XmlSerializer serializer = new XmlSerializer(typeof(List<BaseTypes.Account>), BaseTypes.Account.KnownTypes());
      using (TextReader reader = new StreamReader(args[1]))
      {
        accounts = (List<BaseTypes.Account>)serializer.Deserialize(reader);
      }

      AccountCreationClient client = null;

      try
      {
        client = new AccountCreationClient();
        client.ClientCredentials.UserName.UserName = AccessData.UserName;
        client.ClientCredentials.UserName.Password = AccessData.Password;

        foreach (BaseTypes.Account a in accounts)
        {
          try
          {
            BaseTypes.Account t = a;
            if (!accountTypes.Contains(t.AccountType))
                continue;

            if (t.AuthenticationType == AuthenticationType.MetraNetInternal)
            {
              t.Password_ = "123";
            }

            client.AddAccount(ref t, false);
          }
          catch (FaultException<MASBasicFaultDetail> fe)
          {
            Console.WriteLine("Exception adding account: {0}", fe.Message);

            foreach (string detail in fe.Detail.ErrorMessages)
            {
              Console.WriteLine("Detail: {0}", detail);
            }

            Console.WriteLine();

            client.Abort();

            client = new AccountCreationClient();
            client.ClientCredentials.UserName.UserName = AccessData.UserName;
            client.ClientCredentials.UserName.Password = AccessData.Password;
          }
        }

        client.Close();
      }
      catch (Exception e)
      {
        Console.WriteLine(e.ToString());
        client.Abort();
        throw;
      }
    }

    #endregion

    #region old autosdk file support

    static private readonly Dictionary<string, PropertyMap> PropertyBag = new Dictionary<string, PropertyMap>(StringComparer.InvariantCultureIgnoreCase);

    /// <summary>
    /// Internal class for mapping autoSDK flat properties to our account object structure
    /// </summary>
    internal class PropertyMap
    {
      public string PropertyName;
      public string PropertyValue;

      public PropertyMap(string name, string value)
      {
        PropertyName = name;
        PropertyValue = value;
      }
    }

    /// <summary>
    /// Send add account to ActivityServices based on an AutoSDK file.  Only supports 1 account in the file.
    /// </summary>
    /// <param name="filename"></param>
    private static void ImportAutoSDKAccounts(string filename)
    {
        XmlDocument doc = new XmlDocument();
        doc.Load(filename);
        XmlNode node = doc.SelectSingleNode("//inputs");

        foreach (XmlNode childNode in node.ChildNodes)
        {
            if (childNode.Name != "#comment")
                PropertyBag.Add(childNode.Name, new PropertyMap(childNode.Name, childNode.InnerText));
        }

        BaseTypes.Account account = BaseTypes.Account.CreateAccountWithViews(PropertyBag["accounttype"].PropertyValue);
        View billToView = View.CreateView("metratech.com/contact");

        try
        {
            if (billToView is ContactView)
            {
                ((ContactView)billToView).ContactType = ContactType.Bill_To;
            }

            // Check for LDAP property
            PropertyInfo propertyInfo = account.GetType().GetProperty("LDAP");
            if (propertyInfo != null)
            {
                account.AddView(billToView, "LDAP");
            }
        }
        catch (Exception)
        {
            // hmmm... if there is no contact view we skip it and do what we can.
        }

        View internalView = View.CreateView("metratech.com/internal");
        account.AddView(internalView, "Internal");


        List<PropertyInfo> propList = new List<PropertyInfo>();
        List<string> propListNames = new List<string>();
        GenericObjectParser.ParseType(account.GetType(), "", propList, propListNames);

        int j = 0;
        foreach (PropertyInfo info in propList)
        {
            if (PropertyBag.ContainsKey(info.Name))
            {
                object result = null;
                Type propertyType = info.PropertyType;

                // handle both enums by value and entry name
                Type enumType;
                if (Utils.IsNullableEnumType(propertyType, out enumType))
                {
                    TypeConverter converter = TypeDescriptor.GetConverter(enumType);

                    try
                    {
                        if (converter != null)
                        {
                            if (converter.CanConvertFrom(PropertyBag[info.Name].PropertyValue.GetType()))
                            {
                                result = EnumHelper.GetGeneratedEnumByValue(enumType, PropertyBag[info.Name].PropertyValue);
                            }
                        }
                    }
                    catch (Exception)
                    {

                    }

                    if (result == null)
                    {
                        try
                        {
                            if (converter != null)
                            {
                                if (converter.CanConvertFrom(PropertyBag[info.Name].PropertyValue.GetType()))
                                {
                                    result = EnumHelper.GetGeneratedEnumByValue(enumType,
                                                                                converter.ConvertFrom(
                                                                                  PropertyBag[info.Name].PropertyValue));
                                }
                            }
                        }
                        catch (Exception)
                        {

                        }
                    }

                    if (result == null)
                    {
                        try
                        {
                            result = EnumHelper.GetGeneratedEnumByEntry(enumType, PropertyBag[info.Name].PropertyValue);
                        }
                        catch (Exception)
                        {
                            Console.WriteLine("Unable to parse enum " + info.Name + " - " + PropertyBag[info.Name].PropertyValue);
                        }
                    }
                }

                // handle possible boolean values
                if (propertyType == typeof(bool?))
                {
                    result = false;
                    string val = PropertyBag[info.Name].PropertyValue;
                    switch (val.ToLower())
                    {
                        case "t":
                        case "y":
                        case "true":
                        case "1":
                            result = true;
                            break;
                    }
                }

                try
                {
                    if (result == null)
                    {
                        TypeConverter converter = TypeDescriptor.GetConverter(propertyType);
                        if (converter != null)
                        {
                            if (converter.CanConvertFrom(PropertyBag[info.Name].PropertyValue.GetType()))
                            {
                                result = converter.ConvertFrom(PropertyBag[info.Name].PropertyValue);
                            }
                        }
                    }
                }
                catch (Exception)
                {
                }

                Utils.SetPropertyEx(account, propListNames[j], result);
            }
            j++;
        }

        AccountCreationClient client = null;

        try
        {
          client = new AccountCreationClient();
          client.ClientCredentials.UserName.UserName = AccessData.UserName;
          client.ClientCredentials.UserName.Password = AccessData.Password;

          if (account.Name_Space.ToLower() == "system_user")
          {
            ((SystemAccount)account).LoginApplication = LoginApplication.CSR;
          }
          client.AddAccount(ref account, false);
          client.Close();
        }
        catch (FaultException<MASBasicFaultDetail> fe)
        {
          Console.WriteLine("Exception adding account: {0}", fe.Message);

          foreach (string detail in fe.Detail.ErrorMessages)
          {
            Console.WriteLine("Detail: {0}", detail);
          }

          Console.WriteLine();
          client.Abort();
          throw;
        }
        catch (Exception e)
        {
          Console.WriteLine(e.ToString());
          client.Abort();
          throw;
        }
    }

    #endregion

  }
}
