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
using MetraTech.ActivityServices.Common;
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
using MetraTech.DomainModel.BaseTypes;


namespace MetraTech.Core.Activities
{
  public class ARUpdateAccountActivity : BaseAccountActivity
  {
    
    public string ARExternalNameSpace = String.Empty; 
    
    #region Activity overrides
    protected override ActivityExecutionStatus Execute(ActivityExecutionContext executionContext)
    {

        try
        {
            object mARConfigState;
            string ARExtAccountID = String.Empty;
            if (MetraTech.AR.ARConfiguration.GetInstance().IsAREnabled)
            {
                InternalView internalView = (InternalView)In_Account.GetInternalView();

                try
                {
                    //Determine External Namespace
                    ARExtAccountID = In_Account.UserName;

                    using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\Account"))
                    {
                        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\Account",
                                                                               "__GET_ACCOUNT_MAPPER_INFO__"))
                        {
                            stmt.AddParam("%%USERNAME%%", ARExtAccountID);
                            using (IMTDataReader reader = stmt.ExecuteReader())
                            {
                                while (reader.Read())
                                {
                                    string NameSpace = reader.GetString("nm_space");
                                    if (NameSpace != "mt")
                                    {
                                        ARExternalNameSpace = NameSpace;
                                    }

                                }
                            }
                        }
                    }
                }
                catch (MASBasicException masBasEx)
                {
                    Logger.LogException("Error while retrieving from database", masBasEx);
                    throw;
                }
                catch (COMException comEx)
                {
                    Logger.LogException("COM Exception occurred : ", comEx);
                    throw;
                }
                catch (Exception DBException)
                {
                    Logger.LogException("Error while retrieving from database", DBException);
                    throw new MASBasicException(DBException.Message);
                }



                //Is account billable?
                if ((bool)internalView.Billable)
                {
                    try
                    {
                        if (ARExternalNameSpace == "")
                        {
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


                            //Create record in t_account_mapper table corresponding to new ExtNameSpace
                            MetraTech.Interop.Rowset.IMTSQLRowset rowset =
                                  (MetraTech.Interop.Rowset.IMTSQLRowset)new MetraTech.Interop.Rowset.MTSQLRowset();
                            rowset.Init("\\Queries\\AccountCreation");

                            COMAccountMapper accountMapper = new COMAccountMapper();
                            accountMapper.Initialize();


                            string CurrAcctUserName = In_Account.UserName;
                            string CurrAcctNameSpace = "mt";

                            //Create the account mapping record in t_account_mapper table (Add)
                            if (ARExternalNameSpace != "")
                            {
                                accountMapper.Modify(0, CurrAcctUserName, CurrAcctNameSpace, ARExtAccountID, ARExternalNameSpace, rowset);
                                Logger.LogInfo("Update Account: Account Mapper activity....Done...");
                            }
                            else
                            {
                                Logger.LogInfo("Update Account: Error while creating the record in t_account_mapper table");
                            }

                        }



                        ContactView cv = new ContactView();

                        IMTARConfig ARConfig = new MTARConfigClass();
                        mARConfigState = ARConfig.Configure("");

                        //check if the view is of contact type
                        foreach (string key in In_Account.GetViews().Keys)
                        {
                            List<View> views = In_Account.GetViews()[key] as List<View>;

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
                                    string CurrAcctUserName = In_Account.UserName;
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
                                    if (cv.Country.HasValue)
                                    {
                                        writer.WriteElementString("Country", cv.Country.Value.ToString());
                                    }
                                    else
                                    {
                                        writer.WriteElementString("Country", "");
                                    }
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
                            else if (NodeNameList[i].ToString() == "EMail")
                            {
                                if (PropNameList[i].ToString() == "email")
                                {
                                    writer.WriteElementString("EMail", cv.Email);
                                }
                            }
                            else if (NodeNameList[i].ToString() == "Currency")
                            {
                                if (PropNameList[i].ToString() == "currency")
                                {
                                    string CurrAcctCurrency = ((InternalView)In_Account.GetInternalView()).Currency;
                                    writer.WriteElementString("Currency", CurrAcctCurrency);
                                }
                            }
                        }

                        writer.WriteARDocumentEnd();

                        string xmlstring = writer.GetXmlAndClose();
                        Logger.LogDebug(xmlstring);


                        // Export xml to Great Plains database
                        IMTARWriter mtwriter = new MTARWriterClass();
                        mtwriter.CreateOrUpdateAccounts(xmlstring, mARConfigState);

                        Logger.LogInfo("AR Update completed successfully");
                    }
                    catch (MASBasicException masBasEx)
                    {
                        Logger.LogException("Exception in AR Update Activity", masBasEx);
                        throw;
                    }
                    catch (COMException comEx)
                    {
                        Logger.LogException("COM Exception occurred : ", comEx);
                        throw;
                    }
                    catch (Exception ex)
                    {
                        Logger.LogException("Exception in AR Update Activity", ex);
                        throw new MASBasicException(ex.Message);
                    }
                }
                else
                {
                    Logger.LogInfo("Account is not billable or ARExternalNamespace is null");
                }

            }
            else
            {
                Logger.LogDebug("AR is not enabled");
            }
        }
        catch (MASBasicException masBasEx)
        {
            Logger.LogException("AR Update Account activity failed.", masBasEx);
            throw;
        }
        catch (COMException comEx)
        {
            Logger.LogException("COM Exception occurred : ", comEx);
            throw new MASBasicException(comEx.Message);
        }
        catch (Exception ex)
        {
            Logger.LogException("Exception occurred while executing AR Update Account  activity  activity. ", ex);
            throw new MASBasicException("Exception occurred while executing AR Update Account  activity  activity.");
        }
        return ActivityExecutionStatus.Closed;
    }
    #endregion




    private void InitializeComponent()
    {

    }



  }
}
