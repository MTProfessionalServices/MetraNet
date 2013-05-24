using System;
using System.ComponentModel;
using System.ComponentModel.Design;
using System.Collections;
using System.Drawing;
using System.Linq;
using System.Workflow.ComponentModel;
using System.Workflow.ComponentModel.Design;
using System.Workflow.ComponentModel.Compiler;
using System.Workflow.ComponentModel.Serialization;
using System.Workflow.Runtime;
using System.Workflow.Activities;
using System.Workflow.Activities.Rules;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.ActivityServices.Common;
using System.Runtime.InteropServices;

namespace MetraTech.Core.Activities
{
    public partial class ApplyAccountTemplatePropsActivity : BaseActivity
	{
		public ApplyAccountTemplatePropsActivity()
		{
			
		}

        public static DependencyProperty AccountTemplateDefProperty = DependencyProperty.Register("AccountTemplateDef", typeof(AccountTemplate), typeof(ApplyAccountTemplatePropsActivity));

        [DescriptionAttribute("AccountTemplateDef")]
        [CategoryAttribute("AccountTemplateDef Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        public AccountTemplate AccountTemplateDef
        {
            get
            {
                return ((AccountTemplate)(base.GetValue(ApplyAccountTemplatePropsActivity.AccountTemplateDefProperty)));
            }
            set
            {
                base.SetValue(ApplyAccountTemplatePropsActivity.AccountTemplateDefProperty, value);
            }
        }

        public static DependencyProperty TargetAccountProperty = DependencyProperty.Register("TargetAccount", typeof(Account), typeof(ApplyAccountTemplatePropsActivity));

        [DescriptionAttribute("TargetAccount")]
        [CategoryAttribute("TargetAccount Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        public Account TargetAccount
        {
            get
            {
                return ((Account)(base.GetValue(ApplyAccountTemplatePropsActivity.TargetAccountProperty)));
            }
            set
            {
                base.SetValue(ApplyAccountTemplatePropsActivity.TargetAccountProperty, value);
            }
        }

        protected override ActivityExecutionStatus Execute(ActivityExecutionContext executionContext)
        {
            try
            {
                AccountTemplateDef.ApplyTemplatePropsToAccount(TargetAccount);
            }
            catch (MASBasicException masBasEx)
            {
                Logger.LogException("Apply account template properties activity failed.", masBasEx);
                throw;
            }
            catch (COMException comEx)
            {
                Logger.LogException("COM Exception occurred : ", comEx);
                throw new MASBasicException(comEx.Message);
            }
            catch (Exception ex)
            {
                Logger.LogException("Exception occurred while executing Apply account template properties activity. ", ex);
                throw new MASBasicException("Exception occurred while executing Apply account template properties activity.");
            }

            return ActivityExecutionStatus.Closed;
        }
	}
}
