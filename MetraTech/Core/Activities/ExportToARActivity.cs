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

namespace MetraTech.Core.Activities
{

  //To validate arloginname and arconfigfilename properties
  // [ActivityValidator(typeof(ARPluginActivityValidator))] (TBIL)
 
  
  public class ExportToARActivity : SequenceActivity
  {
    private ARPropagationActivity arPropagationActivity1;
    private AccountMapperActivity accountMapperActivity1;
    public static DependencyProperty ARExtAccountIDProperty = DependencyProperty.Register("ARExtAccountID", typeof(System.String), typeof(MetraTech.Core.Activities.ExportToARActivity));
    public static DependencyProperty ARExternalNameSpaceProperty = DependencyProperty.Register("ARExternalNameSpace", typeof(System.String), typeof(MetraTech.Core.Activities.ExportToARActivity));
    public static DependencyProperty In_AccountProperty = DependencyProperty.Register("In_Account", typeof(MetraTech.DomainModel.BaseTypes.Account), typeof(MetraTech.Core.Activities.ExportToARActivity));
  
    public ExportToARActivity()
    {
      InitializeComponent();
    }

    private void InitializeComponent()
    {
      this.CanModifyActivities = true;
      System.Workflow.ComponentModel.ActivityBind activitybind1 = new System.Workflow.ComponentModel.ActivityBind();
      System.Workflow.ComponentModel.ActivityBind activitybind2 = new System.Workflow.ComponentModel.ActivityBind();
      System.Workflow.ComponentModel.ActivityBind activitybind3 = new System.Workflow.ComponentModel.ActivityBind();
      System.Workflow.ComponentModel.ActivityBind activitybind4 = new System.Workflow.ComponentModel.ActivityBind();
      System.Workflow.ComponentModel.ActivityBind activitybind5 = new System.Workflow.ComponentModel.ActivityBind();
      this.arPropagationActivity1 = new MetraTech.Core.Activities.ARPropagationActivity();
      this.accountMapperActivity1 = new MetraTech.Core.Activities.AccountMapperActivity();
      // 
      // arPropagationActivity1
      // 
      activitybind1.Name = "ExportToARActivity";
      activitybind1.Path = "ARExternalNameSpace";
      activitybind2.Name = "ExportToARActivity";
      activitybind2.Path = "In_Account";
      this.arPropagationActivity1.Name = "arPropagationActivity1";
      this.arPropagationActivity1.SetBinding(MetraTech.Core.Activities.ARPropagationActivity.ARExternalNameSpaceProperty, ((System.Workflow.ComponentModel.ActivityBind)(activitybind1)));
      this.arPropagationActivity1.SetBinding(MetraTech.Core.Activities.BaseAccountActivity.In_AccountProperty, ((System.Workflow.ComponentModel.ActivityBind)(activitybind2)));
      // 
      // accountMapperActivity1
      // 
      activitybind3.Name = "ExportToARActivity";
      activitybind3.Path = "ARExtAccountID";
      activitybind4.Name = "ExportToARActivity";
      activitybind4.Path = "ARExternalNameSpace";
      activitybind5.Name = "ExportToARActivity";
      activitybind5.Path = "In_Account";
      this.accountMapperActivity1.Name = "accountMapperActivity1";
      this.accountMapperActivity1.SetBinding(MetraTech.Core.Activities.AccountMapperActivity.ARExtAccountIDProperty, ((System.Workflow.ComponentModel.ActivityBind)(activitybind3)));
      this.accountMapperActivity1.SetBinding(MetraTech.Core.Activities.AccountMapperActivity.ARExternalNameSpaceProperty, ((System.Workflow.ComponentModel.ActivityBind)(activitybind4)));
      this.accountMapperActivity1.SetBinding(MetraTech.Core.Activities.BaseAccountActivity.In_AccountProperty, ((System.Workflow.ComponentModel.ActivityBind)(activitybind5)));
      // 
      // ExportToARActivity
      // 
      this.Activities.Add(this.accountMapperActivity1);
      this.Activities.Add(this.arPropagationActivity1);
      this.Name = "ExportToARActivity";
      this.CanModifyActivities = false;

    }

    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("This is the category which will be displayed in the Property Browser")]
    public string ARExtAccountID
    {
      get
      {
        return ((string)(base.GetValue(MetraTech.Core.Activities.ExportToARActivity.ARExtAccountIDProperty)));
      }
      set
      {
        base.SetValue(MetraTech.Core.Activities.ExportToARActivity.ARExtAccountIDProperty, value);
      }
    }

    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("This is the category which will be displayed in the Property Browser")]
    public string ARExternalNameSpace
    {
      get
      {
        return ((string)(base.GetValue(MetraTech.Core.Activities.ExportToARActivity.ARExternalNameSpaceProperty)));
      }
      set
      {
        base.SetValue(MetraTech.Core.Activities.ExportToARActivity.ARExternalNameSpaceProperty, value);
      }
    }

    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("Account creation")]
    public Account In_Account
    {
      get
      {
        return ((MetraTech.DomainModel.BaseTypes.Account)(base.GetValue(MetraTech.Core.Activities.ExportToARActivity.In_AccountProperty)));
      }
      set
      {
        base.SetValue(MetraTech.Core.Activities.ExportToARActivity.In_AccountProperty, value);
      }
    }

   



  }//class


} //namespace
