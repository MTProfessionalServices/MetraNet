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


namespace MetraTech.Core.Activities
{
  public class AccountMapperActivity : BaseAccountActivity
  {



    #region Output Properties
    public static DependencyProperty ARExtAccountIDProperty = System.Workflow.ComponentModel.DependencyProperty.Register("ARExtAccountID", typeof(string), typeof(AccountMapperActivity));

    [Description("ARExtAccountID for this account on the AR/External system")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public string ARExtAccountID
    {
      get
      {
        return ((string)(base.GetValue(AccountMapperActivity.ARExtAccountIDProperty)));
      }
      set
      {
        base.SetValue(AccountMapperActivity.ARExtAccountIDProperty, value);
      }
    }



    public static DependencyProperty ARExternalNameSpaceProperty = System.Workflow.ComponentModel.DependencyProperty.Register("ARExternalNameSpace", typeof(string), typeof(AccountMapperActivity));

    [Description("ARExternalNameSpace for this account on the AR/External system")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public string ARExternalNameSpace
    {
      get
      {
        return ((string)(base.GetValue(AccountMapperActivity.ARExternalNameSpaceProperty)));
      }
      set
      {
        base.SetValue(AccountMapperActivity.ARExternalNameSpaceProperty, value);
      }
    }

    #endregion

    #region Activity overrides
    protected override ActivityExecutionStatus Execute(ActivityExecutionContext executionContext)
    {       
        try
        {         
          if (MetraTech.AR.ARConfiguration.GetInstance().IsAREnabled)
          {
              InternalView internalView = (InternalView)In_Account.GetInternalView();

              //Is account billable?
              if ((bool)internalView.Billable)
              {
                MetraTech.Interop.Rowset.IMTSQLRowset rowset =
                  (MetraTech.Interop.Rowset.IMTSQLRowset)new MetraTech.Interop.Rowset.MTSQLRowset();
                rowset.Init("\\Queries\\AccountCreation");

                COMAccountMapper accountMapper = new COMAccountMapper();
                accountMapper.Initialize();              

                string CurrAcctUserName = In_Account.UserName;
                string CurrAcctNameSpace = In_Account.Name_Space;

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
          else
          {
            Console.WriteLine("AR is not  enabled");
          }       
        }
        catch (MASBasicException masBasEx)
        {
            Logger.LogException("Account Mapper Activity failed.", masBasEx);
            throw;
        }
        catch (COMException comEx)
        {
            Logger.LogException("COM Exception occurred : ", comEx);
            throw new MASBasicException(comEx.Message);
        }
        catch (Exception ex)
        {
            Logger.LogException("Exception occurred at Account Mapper Activity. ", ex);
            throw new MASBasicException("Exception occurred at Account Mapper Activity.");
        }  
      return ActivityExecutionStatus.Closed;
    }
    #endregion




    private void InitializeComponent()
    {
      this.Name = "AccountMapperActivity";
    }



  }
}
