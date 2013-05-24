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

using MetraTech.DomainModel.Common;
using MetraTech.DataAccess;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.IMTAccountType;
using MetraTech.Accounts.Type;
using MetraTech.ActivityServices.Common;
using MetraTech.Interop.COMKiosk;
using MetraTech.Interop.Rowset;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTARInterfaceExec;
using System.Xml;
using MetraTech.Xml;
using System.IO;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.BaseTypes;
using System.Runtime.InteropServices;

namespace MetraTech.Core.Activities
{

  //To validate arloginname and arconfigfilename properties
  // [ActivityValidator(typeof(ARPluginActivityValidator))] (TBIL)
  public class ARPluginActivity : SequenceActivity
  {
    #region Private fields
    private CodeActivity AR_Propagation;
    private CodeActivity AccountMapper;
    private object mARConfigState;
    public string ARExternalNameSpace = String.Empty;
    #endregion


    #region Output Properties


    /* public static DependencyProperty ARConfigFileLocationProperty = System.Workflow.ComponentModel.DependencyProperty.Register("ARConfigFileLocation", typeof(string), typeof(ARPluginActivity));

    [Description("This is the description which appears in the Property Browser")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public string ARConfigFileLocation
    {
      get
      {
        return ((string)(base.GetValue(ARPluginActivity.ARConfigFileLocationProperty)));
      }
      set
      {
        base.SetValue(ARPluginActivity.ARConfigFileLocationProperty, value);
      }
    }*/


   /**** public static DependencyProperty ExportToARProperty = System.Workflow.ComponentModel.DependencyProperty.Register("ExportToAR", typeof(bool), typeof(ARPluginActivity));

    [Description("This is the description which appears in the Property Browser")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public bool ExportToAR
    {
      get
      {
        return ((bool)(base.GetValue(ARPluginActivity.ExportToARProperty)));
      }
      set
      {
        base.SetValue(ARPluginActivity.ExportToARProperty, value);
      }
    }

    public static DependencyProperty ARLoginNameProperty = System.Workflow.ComponentModel.DependencyProperty.Register("ARLoginName", typeof(string), typeof(ARPluginActivity));

    [Description("NewLoginName for this account on the AR/External system")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public string ARLoginName
    {
      get
      {
        return ((string)(base.GetValue(ARPluginActivity.ARLoginNameProperty)));
      }
      set
      {
        base.SetValue(ARPluginActivity.ARLoginNameProperty, value);
      }
    }



    public static DependencyProperty ARExternalNameSpaceProperty = System.Workflow.ComponentModel.DependencyProperty.Register("ARExternalNameSpace", typeof(string), typeof(ARPluginActivity));

    [Description("ARExternalNameSpace for this account on the AR/External system")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public string ARExternalNameSpace
    {
      get
      {
        return ((string)(base.GetValue(ARPluginActivity.ARExternalNameSpaceProperty)));
      }
      set
      {
        base.SetValue(ARPluginActivity.ARExternalNameSpaceProperty, value);
      }
    }

    ****/

    public static DependencyProperty Current_AccountProperty = System.Workflow.ComponentModel.DependencyProperty.Register("Current_Account", typeof(Account), typeof(ARPluginActivity));
    [Description("Retrieves the In_Account property of the BaseAccountActivity")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    public Account Current_Account
    {
      get
      {
        return ((Account)(base.GetValue(ARPluginActivity.Current_AccountProperty)));
      }
      set
      {
        base.SetValue(ARPluginActivity.Current_AccountProperty, value);
      }
    }
    #endregion

    #region Properties
    public Logger Logger
    {
        get
        {
            if (logger == null)
            {
                logger = new Logger("Logging\\ActivityServices", "[" + this.GetType().Name + "]");
            }

            return logger;
        }
    }
    #endregion

    #region Data
    [NonSerialized]
    private Logger logger;

    #endregion

    public ARPluginActivity()
    {
      InitializeComponent();
    }

    private void InitializeComponent()
    {
      this.CanModifyActivities = true;
      this.AR_Propagation = new System.Workflow.Activities.CodeActivity();
      this.AccountMapper = new System.Workflow.Activities.CodeActivity();
      // 
      // AccountMapper
      // 
      this.AccountMapper.Name = "AccountMapper";
      this.AccountMapper.ExecuteCode += new System.EventHandler(this.AccountMapper_ExecuteCode);
      // 
      // AR_Propagation
      // 
      this.AR_Propagation.Name = "AR_Propagation";
      this.AR_Propagation.ExecuteCode += new System.EventHandler(this.ARPropagation_ExecuteCode);
      // 
      // ARPluginActivity
      // 
      this.Activities.Add(this.AccountMapper);
      this.Activities.Add(this.AR_Propagation);
      this.Name = "ARPluginActivity";
      this.CanModifyActivities = false;

    }

    void AccountMapper_ExecuteCode(object sender, EventArgs e)
    {
      Console.WriteLine("In event handler for {0}.ExecuteCode event...", ((Activity)sender).Name);

      try
      {
          //if (ExportToAR)
          //{
          //Is AR enabled?
          if (MetraTech.AR.ARConfiguration.GetInstance().IsAREnabled)
          {
              if (Current_Account == null)
              {
                  Console.WriteLine("Current account property not set");
              }

              else
              {
                  InternalView internalView = (InternalView)Current_Account.GetInternalView();

                  //Is account billable?
                  if ((bool)internalView.Billable)
                  {
                      MetraTech.Interop.Rowset.IMTSQLRowset rowset =
                        (MetraTech.Interop.Rowset.IMTSQLRowset)new MetraTech.Interop.Rowset.MTSQLRowset();
                      rowset.Init("\\Queries\\AccountCreation");

                      COMAccountMapper accountMapper = new COMAccountMapper();
                      accountMapper.Initialize();

                      string CurrAcctUserName = Current_Account.UserName;
                      string CurrAcctNameSpace = Current_Account.Name_Space;
                      string ARExtAccountID = Current_Account.UserName;
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

                      //Create the account mapping record in t_account_mapper table (Add)
                      if (ARExternalNameSpace != "")
                      {
                          accountMapper.Modify(0, CurrAcctUserName, CurrAcctNameSpace, ARExtAccountID, ARExternalNameSpace, rowset);
                          Console.WriteLine("Account Mapper activity....Done...");
                      }
                      else
                      {
                          Console.WriteLine("The record was not created in t_account_mapper table for the external namespace(null).");
                      }


                  }
                  else
                  {
                      Console.WriteLine("Account is not billable");
                  }
              }
          }
          else
          {
              Console.WriteLine("Account is not AR enabled");
          }
          // }
      }
      catch (MASBasicException masBasEx)
      {
          Logger.LogException("AR plugin  activity failed.", masBasEx);
          throw;
      }
      catch (COMException comEx)
      {
          Logger.LogException("COM Exception occurred : ", comEx);
          throw new MASBasicException(comEx.Message);
      }
      catch (Exception ex)
      {
          Logger.LogException("Exception occurred while executing AR plugin  activity  activity. ", ex);
          throw new MASBasicException("Exception occurred while executing AR plugin  activity  activity.");
      }


    }



    void ARPropagation_ExecuteCode(object sender, EventArgs e)
    {

      Console.WriteLine("In event handler for {0}.ExecuteCode event...", ((Activity)sender).Name);

      //if (ExportToAR)
      //{
        //Is AR enabled?
        if (MetraTech.AR.ARConfiguration.GetInstance().IsAREnabled)
        {          
                   
            if (Current_Account == null)
            {
              Console.WriteLine("Current account property not set");
            }
            else
            {
             
              InternalView internalView = (InternalView)Current_Account.GetInternalView();
             
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

                Console.WriteLine("AR Propagation activity completed successfully");
              }
              catch (Exception ex)
              {
                Console.WriteLine("From AR Propagation Activity:: " + ex.Message);
              }
            }
            else
            {
              Console.WriteLine("Account is not billable or ARExternalNamespace is null");
            }
          }
         
        }
        else
        {
          Console.WriteLine("AR is not enabled");
        }


      /*}
      else
      {
        Console.WriteLine("ExportToAR is false");
      }*/

    }//void 


  }//class


} //namespace
