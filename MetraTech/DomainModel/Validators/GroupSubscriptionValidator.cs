using System;
using System.Collections.Generic;
using System.Text;

using MetraTech.Interop.MTProductCatalog;
using MetraTech.DomainModel.ProductCatalog;

namespace MetraTech.DomainModel.Validators
{
  public class GroupSubscriptionValidator
  {
    #region IValidator Members

    /// <summary>
    ///    The creating flag is set to true when the specified GroupSubscription object has
    ///    not been persisted.
    /// </summary>
    /// <param name="obj"></param>
    /// <param name="creating"></param>
    /// <param name="validationErrors"></param>
    /// <returns></returns>
    public bool Validate(object obj, bool creating, out List<string> validationErrors)
    {
      validationErrors = new List<string>();

      GroupSubscription groupSubscription = obj as GroupSubscription;

      if(groupSubscription == null)
      {
        validationErrors.Add(NOT_GROUP_SUBSCRIPTION);
      }

      if (String.IsNullOrEmpty(groupSubscription.Name))
      {
        validationErrors.Add(MISSING_GROUP_SUB_NAME);
      }

      if (!creating && !groupSubscription.GroupId.HasValue)
      {
        validationErrors.Add(MISSING_GROUP_SUB_ID);
      }

      if (groupSubscription.SubscriptionSpan == null)
      {
        validationErrors.Add(MISSING_GROUP_SUB_TIMESPAN);
      }

      // If the distribution is not proportional, then DiscountAccountId must be specified
      if (!groupSubscription.ProportionalDistribution && !groupSubscription.DiscountAccountId.HasValue)
      {
        validationErrors.Add(MISSING_DISCOUNT_ACCOUNT);
      }

      if (groupSubscription.Members != null && groupSubscription.Members.Items.Count > 0)
      {
        ValidateMembers(groupSubscription.Members.Items, validationErrors);
      }

      if (groupSubscription.Cycle != null)
      {
        AccountValidator.ValidateUsageCycle(groupSubscription.Cycle, validationErrors);
      }

      if (validationErrors.Count > 0)
      {
        return false;
      }

      return true;
    }

    public static bool ValidateMembers(List<GroupSubscriptionMember> members, List<string> validationErrors)
    {
      bool isValid = true;

      if (members == null)
      {
        validationErrors.Add(NULL_MEMBERS);
        return false;
      }

      // Members must have account id's and start dates.
      foreach (GroupSubscriptionMember groupSubMember in members)
      {
        if (!groupSubMember.AccountId.HasValue)
        {
          validationErrors.Add(MISSING_GROUP_SUB_MEMBER_ACCOUNT_ID);
          isValid = false;
        }

        if (groupSubMember.MembershipSpan == null)
        {
          validationErrors.Add(MISSING_GROUP_SUB_MEMBER_EFFECTIVE_DATES);
          isValid = false;
        }
        else
        {
          if (!groupSubMember.MembershipSpan.StartDate.HasValue)
          {
            validationErrors.Add(MISSING_GROUP_SUB_MEMBER_START_DATE);
            isValid = false;
          }
        }
      }
      
      return isValid;
    }

    #endregion

    #region Private Methods
    #endregion

    #region Error Strings
    private const string NULL_MEMBERS = "Null members collection";
    private const string NOT_GROUP_SUBSCRIPTION = "The supplied object is not a GroupSubscription";
    private const string MISSING_GROUP_SUB_ID = "Missing Group Subscription Id";
    private const string MISSING_GROUP_SUB_TIMESPAN = "Missing Group Subscription Start and End dates";
    private const string MISSING_GROUP_SUB_NAME = "Missing Group Subscription name";
    private const string MISSING_DISCOUNT_ACCOUNT = "Missing discount account identifier";
    private const string MISSING_GROUP_SUB_MEMBER_ACCOUNT_ID = "Missing account identifier for group subscription member";
    private const string MISSING_GROUP_SUB_MEMBER_EFFECTIVE_DATES = "Missing effective dates for group subscription member";
    private const string MISSING_GROUP_SUB_MEMBER_START_DATE = "Missing start date for group subscription member";
    #endregion
  }
}
