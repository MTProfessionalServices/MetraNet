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
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using System.ServiceModel;
using YAAC = MetraTech.Interop.MTYAAC;
using System.Runtime.InteropServices;

namespace MetraTech.Core.Activities
{
	public partial class ApplyAccountTemplateSubsActivity: BaseActivity
	{
		public ApplyAccountTemplateSubsActivity()
		{
			
		}

        public static DependencyProperty AccountTemplateDefProperty = DependencyProperty.Register("AccountTemplateDef", typeof(AccountTemplate), typeof(ApplyAccountTemplateSubsActivity));

        [DescriptionAttribute("AccountTemplateDef")]
        [CategoryAttribute("AccountTemplateDef Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        public AccountTemplate AccountTemplateDef
        {
            get
            {
                return ((AccountTemplate)(base.GetValue(ApplyAccountTemplateSubsActivity.AccountTemplateDefProperty)));
            }
            set
            {
                base.SetValue(ApplyAccountTemplateSubsActivity.AccountTemplateDefProperty, value);
            }
        }

        public static DependencyProperty TargetAccountProperty = DependencyProperty.Register("TargetAccount", typeof(Account), typeof(ApplyAccountTemplateSubsActivity));

        [DescriptionAttribute("TargetAccount")]
        [CategoryAttribute("TargetAccount Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        public Account TargetAccount
        {
            get
            {
                return ((Account)(base.GetValue(ApplyAccountTemplateSubsActivity.TargetAccountProperty)));
            }
            set
            {
                base.SetValue(ApplyAccountTemplateSubsActivity.TargetAccountProperty, value);
            }
        }

        protected override ActivityExecutionStatus Execute(ActivityExecutionContext executionContext)
        {
            try
            {		
				if (AccountTemplateDef != null && 
					AccountTemplateDef.Subscriptions != null &&
					AccountTemplateDef.Subscriptions.Count > 0)
				{
					MetraTech.Interop.MTProductCatalog.IMTSessionContext context = (MetraTech.Interop.MTProductCatalog.IMTSessionContext)GetSessionContext();

					IMTProductCatalog mtProductCatalog = new MTProductCatalogClass();
					mtProductCatalog.SetSessionContext(context);

					foreach (AccountTemplateSubscription atSub in AccountTemplateDef.Subscriptions)
					{
						if (atSub.ProductOfferingId.HasValue)
						{
							#region Add Subscription
							MetraTech.Interop.MTProductCatalog.IMTSubscription pcSub = new MTSubscriptionClass();
							pcSub.SetSessionContext(context);

							pcSub.AccountID = TargetAccount._AccountID.Value;
							pcSub.ProductOfferingID = atSub.ProductOfferingId.Value;

							DateTime now = (TargetAccount.AccountStartDate.HasValue ? TargetAccount.AccountStartDate.Value : MetraTime.Now);
							pcSub.EffectiveDate = new MTPCTimeSpan();
							pcSub.EffectiveDate.StartDate = new DateTime(now.Year, now.Month, now.Day, 0, 0, 0);
							pcSub.EffectiveDate.StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE;
							pcSub.EffectiveDate.EndDate = MetraTime.Max;
							pcSub.EffectiveDate.EndDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE;

							// Save the whole mess
							pcSub.Save();
							#endregion
						}
						else
						{
							#region Add Group Subscription
							MTGroupSubscription mtGroupSubscription = mtProductCatalog.GetGroupSubscriptionByID(atSub.GroupID.Value);

							if (mtGroupSubscription == null)
							{
								throw new MASBasicException("Error finding group subscription");
							}

							MTGSubMember mtGsubMember = new MTGSubMember();
							mtGsubMember.AccountID = TargetAccount._AccountID.Value;

							DateTime startDate = (TargetAccount.AccountStartDate.HasValue ? TargetAccount.AccountStartDate.Value : MetraTime.Now);
							mtGsubMember.StartDate = (  startDate > atSub.StartDate ?
									startDate :
									atSub.StartDate);

							mtGsubMember.EndDate = atSub.EndDate;

							mtGroupSubscription.AddAccount(mtGsubMember);
							#endregion
						}
					}
				}
			}
            catch (MASBasicException masBasEx)
            {
                Logger.LogException("Apply account template subs activity failed.", masBasEx);
                throw;
            }
            catch (COMException comEx)
            {
                Logger.LogException("COM Exception occurred : ", comEx);
                throw new MASBasicException(comEx.Message);
            }
            catch (Exception ex)
            {
                Logger.LogException("Exception occurred while executing Add (Group) subscription. ", ex);
                throw new MASBasicException("Exception occurred while executing Add (Group) subscription");
            }			
            return ActivityExecutionStatus.Closed;
        }

        private YAAC.IMTSessionContext GetSessionContext()
        {
            YAAC.IMTSessionContext retval = null;

            CMASClientIdentity identity = null;
            try
            {
                identity = (CMASClientIdentity)ServiceSecurityContext.Current.PrimaryIdentity;

                retval = (YAAC.IMTSessionContext)identity.SessionContext;
            }
            catch (Exception)
            {
                throw new MASBasicException("Service security identity is of improper type");
            }

            return retval;
        }

	}
}
