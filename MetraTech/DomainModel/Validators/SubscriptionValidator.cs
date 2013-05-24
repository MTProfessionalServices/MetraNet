using System;
using System.Collections.Generic;
using System.Text;

using MetraTech.Interop.MTProductCatalog;
using MetraTech.DomainModel.ProductCatalog;

namespace MetraTech.DomainModel.Validators
{
  public class SubscriptionValidator : IValidator
  {
    #region IValidator Members

    public bool Validate(object obj, out List<string> validationErrors)
    {
      bool retval = true;
      validationErrors = new List<string>();

      Subscription sub = obj as Subscription;

      if(sub == null)
      {
        validationErrors.Add(NOT_SUBSCRIPTION);
        return false;
      }

      // Validate start and end date
      if (sub.SubscriptionSpan.StartDate != null)
      {
        if (!sub.SubscriptionSpan.IsStartDateTypeDirty)
        {
          validationErrors.Add(SUB_START_DATE_TYPE_NOT_SET);
          retval = false;
        }

        if (sub.SubscriptionSpan.EndDate != null)
        {
          if (sub.SubscriptionSpan.StartDate >= sub.SubscriptionSpan.EndDate)
          {
            validationErrors.Add(START_DATE_AFTER_END_DATE);
            retval = false;
          }
        }
      }
      else
      {
        validationErrors.Add(START_DATE_NOT_SET);
        retval = false;
      }

      IMTProductCatalog prodCat = new MTProductCatalogClass();

      try
      {
        // Validate PO ID is real PO
        IMTProductOffering po = prodCat.GetProductOffering((int)sub.ProductOfferingId);

        // Validate start date is in PO effective dates
        if (sub.SubscriptionSpan.StartDate < po.EffectiveDate.StartDate)
        {
          validationErrors.Add(SUB_STARTS_BEFORE_PO);
          retval = false;
        }
      }
      catch (Exception)
      {
        validationErrors.Add(PROD_OFFERING_NOT_FOUND);
        retval = false;
      }

      return retval;
    }

    #endregion

    #region Private Methods
    #endregion

    #region Error Strings
    private const string NOT_SUBSCRIPTION = "The supplied object is not a Subscription";
    private const string PROD_OFFERING_NOT_FOUND = "The specified product offering is not valid";
    private const string START_DATE_NOT_SET = "The subscription start date is not set";
    private const string END_DATE_NOT_SET = "The subscription end date is not set";
    private const string START_DATE_AFTER_END_DATE = "The start date is later than the end date";
    private const string SUB_SPAN_TOO_SHORT = "The subscription must be more than one hour long";
    private const string SUB_STARTS_BEFORE_PO = "The subscription starts before the product offering is effective";
    private const string SUB_START_DATE_TYPE_NOT_SET = "The subscription start date type not set";
    private const string SUB_END_DATE_TYPE_NOT_SET = "The subscription end date type not set";
    #endregion
  }
}
