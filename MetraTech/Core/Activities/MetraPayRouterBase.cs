using System;
using System.ComponentModel;
using System.ComponentModel.Design;
using System.Collections;
using System.Drawing;
using System.Workflow.ComponentModel;
using System.Workflow.ComponentModel.Design;
using System.Workflow.ComponentModel.Compiler;
using System.Workflow.ComponentModel.Serialization;
using System.Workflow.Runtime;
using System.Workflow.Activities;
using System.Workflow.Activities.Rules;
using MetraTech.DomainModel.MetraPay;
using MetraTech.ActivityServices.Activities;

namespace MetraTech.Core.Activities
{
	public partial class MetraPayRouterBase : MTSequentialWorkflowActivity
	{
		public MetraPayRouterBase()
		{
		}

    public static DependencyProperty PaymentMethodProperty = System.Workflow.ComponentModel.DependencyProperty.Register("PaymentMethod", typeof(MetraPaymentMethod), typeof(MetraPayRouterBase));

    [Description("This is the description which appears in the Property Browser")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public MetraPaymentMethod PaymentMethod
    {
      get
      {
        return ((MetraPaymentMethod)(base.GetValue(MetraPayRouterBase.PaymentMethodProperty)));
      }
      set
      {
        base.SetValue(MetraPayRouterBase.PaymentMethodProperty, value);
      }
    }

    public static DependencyProperty PaymentInfoProperty = System.Workflow.ComponentModel.DependencyProperty.Register("PaymentInfo", typeof(MetraPaymentInfo), typeof(MetraPayRouterBase));

    [Description("This is the description which appears in the Property Browser")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public MetraPaymentInfo PaymentInfo
    {
      get
      {
        return ((MetraPaymentInfo)(base.GetValue(MetraPayRouterBase.PaymentInfoProperty)));
      }
      set
      {
        base.SetValue(MetraPayRouterBase.PaymentInfoProperty, value);
      }
    }

    public static DependencyProperty ServiceNameProperty = System.Workflow.ComponentModel.DependencyProperty.Register("ServiceName", typeof(string), typeof(MetraPayRouterBase));

    [Description("This is the description which appears in the Property Browser")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public string ServiceName
    {
      get
      {
        return ((string)(base.GetValue(MetraPayRouterBase.ServiceNameProperty)));
      }
      set
      {
        base.SetValue(MetraPayRouterBase.ServiceNameProperty, value);
      }
    }

    public static DependencyProperty AccountIDProperty = System.Workflow.ComponentModel.DependencyProperty.Register("AccountID", typeof(int), typeof(MetraPayRouterBase));

    [Description("This is the description which appears in the Property Browser")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public int AccountID
    {
      get
      {
        return ((int)(base.GetValue(MetraPayRouterBase.AccountIDProperty)));
      }
      set
      {
        base.SetValue(MetraPayRouterBase.AccountIDProperty, value);
      }
    }

	}
}
