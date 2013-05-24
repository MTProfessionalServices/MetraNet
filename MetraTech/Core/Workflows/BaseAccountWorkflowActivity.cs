using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.ActivityServices.Activities;
using System.ComponentModel;
using System.Workflow.ComponentModel;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.ProductCatalog;
using ProdCatalog = MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.ActivityServices.Services.Common;
using System.ServiceModel;
using YAAC = MetraTech.Interop.MTYAAC;
using MetraTech.Interop.GenericCollection;

namespace MetraTech.Core.Workflows
{
	public class BaseAccountWorkflowActivity : MTSequentialWorkflowActivity
	{
        public static DependencyProperty In_AccountProperty = DependencyProperty.Register("In_Account", typeof(MetraTech.DomainModel.BaseTypes.Account), typeof(MetraTech.Core.Workflows.BaseAccountWorkflowActivity));

        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [BrowsableAttribute(true)]
        [CategoryAttribute("Account creation")]
        [Input]
        public MetraTech.DomainModel.BaseTypes.Account In_Account
        {
            get
            {
                return ((MetraTech.DomainModel.BaseTypes.Account)(base.GetValue(MetraTech.Core.Workflows.BaseAccountWorkflowActivity.In_AccountProperty)));
            }
            set
            {
                base.SetValue(MetraTech.Core.Workflows.BaseAccountWorkflowActivity.In_AccountProperty, value);
            }
        }

        public static DependencyProperty In_ApplyTemplateProperty = DependencyProperty.Register("In_ApplyTemplate", typeof(bool?), typeof(BaseAccountWorkflowActivity));

        [DescriptionAttribute("Specifies whether or not to apply the account template")]
        [CategoryAttribute("Account Creation")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [Input]
        public bool? In_ApplyTemplate
        {
            get
            {
                return ((bool?)(base.GetValue(BaseAccountWorkflowActivity.In_ApplyTemplateProperty)));
            }
            set
            {
                base.SetValue(BaseAccountWorkflowActivity.In_ApplyTemplateProperty, value);
            }
        }

        public static DependencyProperty AccountTemplateDefProperty = DependencyProperty.Register("AccountTemplateDef", typeof(AccountTemplate), typeof(BaseAccountWorkflowActivity));

        [DescriptionAttribute("AccountTemplateDef")]
        [CategoryAttribute("Internal")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        public AccountTemplate AccountTemplateDef
        {
            get
            {
                return ((AccountTemplate)(base.GetValue(BaseAccountWorkflowActivity.AccountTemplateDefProperty)));
            }
            set
            {
                base.SetValue(BaseAccountWorkflowActivity.AccountTemplateDefProperty, value);
            }
        }

        public static DependencyProperty TemplateOwnerProperty = DependencyProperty.Register("TemplateOwner", typeof(AccountIdentifier), typeof(BaseAccountWorkflowActivity));

        [DescriptionAttribute("TemplateOwner")]
        [CategoryAttribute("Internal")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        public AccountIdentifier TemplateOwner
        {
            get
            {
                return ((AccountIdentifier)(base.GetValue(BaseAccountWorkflowActivity.TemplateOwnerProperty)));
            }
            set
            {
                base.SetValue(BaseAccountWorkflowActivity.TemplateOwnerProperty, value);
            }
        }

        public static DependencyProperty EffectiveDateProperty = DependencyProperty.Register("EffectiveDate", typeof(DateTime), typeof(BaseAccountWorkflowActivity));

        [DescriptionAttribute("EffectiveDate")]
        [CategoryAttribute("Internal")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        public DateTime EffectiveDate
        {
            get
            {
                return ((DateTime)(base.GetValue(BaseAccountWorkflowActivity.EffectiveDateProperty)));
            }
            set
            {
                base.SetValue(BaseAccountWorkflowActivity.EffectiveDateProperty, value);
            }
        }

        public void InitForGetTemplateDef_ExecuteCode(object sender, EventArgs e)
        {
            if (In_Account.AncestorAccountID.HasValue)
            {
                TemplateOwner = new AccountIdentifier(In_Account.AncestorAccountID.Value);
            }
            else
            {
                TemplateOwner = new AccountIdentifier(In_Account.AncestorAccount, In_Account.AncestorAccountNS);
            }

            EffectiveDate = MetraTime.Now;
        }
	}
}
