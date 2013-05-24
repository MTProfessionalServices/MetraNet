using System;
using System.Diagnostics;
using System.Reflection;
using System.ComponentModel;
using System.ComponentModel.Design;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Drawing;
using System.Transactions;
using System.Workflow.ComponentModel.Compiler;
using System.Workflow.ComponentModel.Serialization;
using System.Workflow.ComponentModel;
using System.Workflow.ComponentModel.Design;
using System.Workflow.Runtime;
using System.Workflow.Activities;
using System.Workflow.Activities.Rules;
using System.Runtime.InteropServices;

using MetraTech;
using MetraTech.DomainModel.Common;
using MetraTech.DataAccess;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.IMTAccountType;
using MetraTech.Accounts.Type;
using MetraTech.ActivityServices.Interfaces;
using MetraTech.DomainModel.Validators;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Enums;

using MetraTech.Interop.COMKiosk;
using MetraTech.Interop.Rowset;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTARInterfaceExec;
using System.Xml;
using MetraTech.Xml;
using System.IO;


namespace MetraTech.Core.Activities
{
  public class UpdateARActivity : BaseAccountActivity
  {
    private object mARConfigState;
    public string ARExternalNameSpace = String.Empty;


    public static DependencyProperty Current_AccountProperty = System.Workflow.ComponentModel.DependencyProperty.Register("Current_Account", typeof(Account), typeof(UpdateARActivity));
    [Description("Retrieves the In_Account property of the BaseAccountActivity")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    public Account Current_Account
    {
      get
      {
        return ((Account)(base.GetValue(UpdateARActivity.Current_AccountProperty)));
      }
      set
      {
        base.SetValue(UpdateARActivity.Current_AccountProperty, value);
      }
    }



 

    #region Activity overrides
    protected override ActivityExecutionStatus Execute(ActivityExecutionContext executionContext)
    {
      if (MetraTech.AR.ARConfiguration.GetInstance().IsAREnabled)
      {
        InternalView internalView = (InternalView)Current_Account.GetInternalView();

        //Determine External Namespace
        string ARExtAccountID = Current_Account.UserName;
        

        if (ARExtAccountID.Length >= 3)
        {
          string SubNameSpace = ARExtAccountID.Substring(0, 3);
         
          if (SubNameSpace == "CAN")
          {
            ARExternalNameSpace = "ar/canada";
          }
          else if (SubNameSpace == "EUR")
          {
            ARExternalNameSpace = "ar/europe";
          }
          else if (SubNameSpace == "NAR")
          {
            ARExternalNameSpace = "";
          }
          else
          {
            ARExternalNameSpace = "ar/external";
          }
        }
        else
        {
          ARExternalNameSpace = "ar/external";
        }

        //Is account billable?
        if ((bool)internalView.Billable && (ARExternalNameSpace != ""))
        {
          try
          {
            ContactView cv = new ContactView();

            IMTARConfig ARConfig = new MTARConfigClass();
            mARConfigState = ARConfig.Configure("");

            //check if the view is of contact type
            foreach (string key in Current_Account.GetViews().Keys)
            {
              List<View> views = Current_Account.GetViews()[key] as List<View>;

              foreach (View view in views)
              {
                if (view.GetType().ToString() == "MetraTech.DomainModel.AccountTypes.ContactView")
                {
                  cv = (ContactView)view;
                }
              }
            }
            const string ExConfigFile = "..\\extensions\\Account\\config\\Pipeline\\AccountCreation\\ARExport.xml";

            //load config file
            MTXmlDocument doc = new MTXmlDocument();
            doc.LoadConfigFile(ExConfigFile);

            //Generating the Xml to be exported to AR system
            string method = doc.GetNodeValueAsString("//Method");
            ArrayList PropNameList = new ArrayList();
            ArrayList NodeNameList = new ArrayList();
            XmlNodeList PropNode = doc.SelectNodes("//Property");

            for (int i = 0; i < PropNode.Count; i++)
            {
              PropNameList.Add(PropNode[i].ChildNodes[0].InnerXml);
              NodeNameList.Add(PropNode[i].ChildNodes[1].InnerXml);
            }
            MetraTech.AR.ARDocWriter writer = null;




            writer = MetraTech.AR.ARDocWriter.CreateWithARDocuments(ARExternalNameSpace);
            writer.WriteARDocumentStart("CreateOrUpdateAccount");

            for (int i = 0; i < NodeNameList.Count; i++)
            {
              if (NodeNameList[i].ToString() == "ExtAccountID")
              {
                if (PropNameList[i].ToString() == "username")
                {
                  string CurrAcctUserName = Current_Account.UserName;
                  writer.WriteElementString("ExtAccountID", CurrAcctUserName);
                }
              }
              else if (NodeNameList[i].ToString() == "AccountName")
              {
                if (PropNameList[i].ToString() == "lastname")
                {
                  writer.WriteElementString("AccountName", cv.LastName);
                }
                else if (PropNameList[i].ToString() == "firstname")
                {
                  writer.WriteElementString("AccountName", cv.FirstName);
                }
              }
              else if (NodeNameList[i].ToString() == "ContactName")
              {
                if (PropNameList[i].ToString() == "lastname")
                {
                  writer.WriteElementString("ContactName", cv.LastName);
                }
                else if (PropNameList[i].ToString() == "firstname")
                {
                  writer.WriteElementString("AccountName", cv.FirstName);
                }
              }
              else if (NodeNameList[i].ToString() == "Address1")
              {
                if (PropNameList[i].ToString() == "address1")
                {
                  writer.WriteElementString("Address1", cv.Address1);
                }
              }
              else if (NodeNameList[i].ToString() == "Address2")
              {
                if (PropNameList[i].ToString() == "address2")
                {
                  writer.WriteElementString("Address2", cv.Address2);
                }
              }
              else if (NodeNameList[i].ToString() == "Address3")
              {
                if (PropNameList[i].ToString() == "address3")
                {
                  writer.WriteElementString("Address3", cv.Address3);
                }
              }
              else if (NodeNameList[i].ToString() == "City")
              {
                if (PropNameList[i].ToString() == "city")
                {
                  writer.WriteElementString("City", cv.City);
                }
              }
              else if (NodeNameList[i].ToString() == "State")
              {
                if (PropNameList[i].ToString() == "state")
                {
                  writer.WriteElementString("State", cv.State);
                }
              }
              else if (NodeNameList[i].ToString() == "Zip")
              {
                if (PropNameList[i].ToString() == "zip")
                {
                  writer.WriteElementString("Zip", cv.Zip);
                }
              }
              else if (NodeNameList[i].ToString() == "Country")
              {
                if (PropNameList[i].ToString() == "country")
                {
                  writer.WriteElementString("Country", cv.Country.Value.ToString());
                }
              }
              else if (NodeNameList[i].ToString() == "PhoneNumber")
              {
                if (PropNameList[i].ToString() == "phonenumber")
                {
                  writer.WriteElementString("PhoneNumber", cv.PhoneNumber);
                }
              }
              else if (NodeNameList[i].ToString() == "FaxNumber")
              {
                if (PropNameList[i].ToString() == "facsimiletelephonenumber")
                {
                  writer.WriteElementString("FaxNumber", cv.FacsimileTelephoneNumber);
                }
              }
              else if (NodeNameList[i].ToString() == "Email")
              {
                if (PropNameList[i].ToString() == "email")
                {
                  writer.WriteElementString("Email", cv.Email);
                }
              }
              else if (NodeNameList[i].ToString() == "Currency")
              {
                if (PropNameList[i].ToString() == "currency")
                {
                  string CurrAcctCurrency = ((InternalView)Current_Account.GetInternalView()).Currency;
                  writer.WriteElementString("Currency", CurrAcctCurrency);
                }
              }
            }

            writer.WriteARDocumentEnd();

            string xmlstring = writer.GetXmlAndClose();
            Console.WriteLine(xmlstring); //(TBUC)
            Console.WriteLine("\n"); //(TBUC)


            // Export xml to Great Plains database
            IMTARWriter mtwriter = new MTARWriterClass();
            mtwriter.CreateOrUpdateAccounts(xmlstring, mARConfigState);

            Console.WriteLine("AR Update completed successfully");
          }
          catch (Exception ex)
          {
            Console.WriteLine("From AR Update CodeActivity:: " + ex.Message);
          }
        }
        else
        {
          Console.WriteLine("Account is not billable or ARExternalNamespace is null");
        }

      }
      else
      {
        Console.WriteLine("AR is not enabled");
      }

      return ActivityExecutionStatus.Closed;
    }
    #endregion




    private void InitializeComponent()
    {     

    }



  }
}
