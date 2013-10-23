using System;
using System.Collections.Generic;
using System.Reflection;
using System.Globalization;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using MetraTech.Interop.IMTAccountType;
using MetraTech.Accounts.Type;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;

namespace MetraTech.DomainModel.Validators
{
  public class AccountValidator : IValidator
  {
    #region IValidator Methods
    public bool Validate(object obj, out List<string> validationErrors)
    {
      bool isValid = true;
      validationErrors = new List<string>();

      Account account = obj as Account;
      // Check if the input is an Account
      if (account == null)
      {
        validationErrors.Add(NOT_ACCOUNT);
        return false;
      }

      // Check if the account has an internal view
      InternalView internalView = null;
      internalView = account.GetInternalView() as InternalView;
      if (internalView == null)
      {
        validationErrors.Add(MISSING_INTERNAL_VIEW);
        return false;
      }
      
      // Check if all the required properties have been specified
      ValidateRequiredProperties(account, validationErrors);
      
      // Check user name
      ValidateUsername(account, validationErrors);

      // Check password
      ValidatePassword(account, validationErrors);

      // Check namespace
      ValidateNamespace(account, validationErrors);

      // Check account type
      if (String.IsNullOrEmpty(account.AccountType))
      {
        validationErrors.Add(String.Format(MISSING_ACCOUNT_TYPE, account.UserName));
      }

      // Check currency
      IMTAccountType accountType = m_AccountTypeCollection.GetAccountType(account.AccountType);
      if (accountType == null)
      {
        validationErrors.Add(String.Format(INVALID_ACCOUNT_TYPE, account.UserName, account.AccountType));
      }

      if (accountType.CanBePayer)
      {
        if (String.IsNullOrEmpty(internalView.Currency))
        {
          validationErrors.Add(String.Format(MISSING_CURRENCY_FOR_PAYER, account.UserName));
        }
      }

      // Check language
      if (!internalView.Language.HasValue)
      {
        validationErrors.Add(String.Format(MISSING_LANGUAGE, account.UserName));
      }

      // Check account status
      if (!account.AccountStatus.HasValue)
      {
        validationErrors.Add(String.Format(MISSING_ACCOUNT_STATUS, account.UserName));
      }

      // Validate payer and usage cycle info
      if (accountType.CanBePayer || accountType.CanSubscribe || accountType.CanParticipateInGSub)
      {
        ValidatePayer(account, validationErrors);
        ValidateUsageCycle(account, validationErrors);
      }
      else
      {
        ((InternalView)account.GetInternalView()).UsageCycleType = null;
        account.DayOfWeek = null;
        account.DayOfMonth = null;
        account.FirstDayOfMonth = null;
        account.SecondDayOfMonth = null;
        account.StartDay = null;
        account.StartMonth = null;
        account.StartYear = null;
      }

      // Validate ancestor information
      ValidateAncestor(account, accountType.CanHaveSyntheticRoot, validationErrors);

      // Check that LoginApplication is specified for a SystemAccount
      SystemAccount systemAccount = account as SystemAccount;
      if (systemAccount != null)
      {
        if (!systemAccount.LoginApplication.HasValue)
        {
          validationErrors.Add(String.Format(MISSING_LOGIN_APP, account.UserName));
        }
      }

      // Check string lengths
      account.CheckStringLengths(ref validationErrors);
      // Check string lengths for each view
      foreach (List<View> views in account.GetViews().Values)
      {
        foreach (View view in views)
        {
          view.CheckStringLengths(ref validationErrors);
        }
      }

      if (validationErrors.Count > 0)
      {
        isValid = false;
      }

      return isValid;
    }
    #endregion

    #region Public Static Methods
    public static bool ValidateUsername(Account account, List<string> validationErrors)
    {
      bool isValid = true;

      if (String.IsNullOrEmpty(account.UserName))
      {
        validationErrors.Add(MISSING_USERNAME);
        isValid = false;
      }
      else
      {
        if (account.UserName.Length > 255)
        {
          validationErrors.Add(String.Format(INVALID_ACCOUNT_USERNAME, account.UserName));
          isValid = false;
        }
      }

      return isValid;
    }

    public static bool ValidateNamespace(Account account, List<string> validationErrors)
    {
      bool isValid = true;

      if (String.IsNullOrEmpty(account.Name_Space))
      {
        validationErrors.Add(MISSING_NAMESPACE);
        isValid = false;
      }

      return isValid;
    }

    public static bool ValidatePassword(Account account, List<string> validationErrors)
    {
      bool isValid = true;

      if (account.AuthenticationType == AuthenticationType.MetraNetInternal)
      {
        if (String.IsNullOrEmpty(account.Password_))
        {
          validationErrors.Add(MISSING_PASSWORD);
          isValid = false;
        }
        else
        {
          if (account.Password_.Length > 1024)
          {
            validationErrors.Add(String.Format(INVALID_ACCOUNT_PASSWORD, account.UserName));
            isValid = false;
          }
        }
      }

      return isValid;
    }

    public static bool ValidateUsageCycle(Cycle cycle, List<string> validationErrors)
    {
      bool isValid = true;

      switch (cycle.CycleType)
      {
        case UsageCycleType.Daily:
          {
            cycle.DayOfWeek = null;
            cycle.DayOfMonth = null;
            cycle.FirstDayOfMonth = null;
            cycle.SecondDayOfMonth = null;
            cycle.StartDay = null;
            cycle.StartMonth = null;
            cycle.StartYear = null;

            break;
          }
        case UsageCycleType.Weekly:
          {
            if (!cycle.DayOfWeek.HasValue)
            {
              validationErrors.Add(INVALID_DATA);
              isValid = false;
            }

            cycle.DayOfMonth = null;
            cycle.FirstDayOfMonth = null;
            cycle.SecondDayOfMonth = null;
            cycle.StartDay = null;
            cycle.StartMonth = null;
            cycle.StartYear = null;

            break;
          }
        case UsageCycleType.Bi_weekly:
          {
            if (!cycle.StartMonth.HasValue)
            {
              validationErrors.Add(INVALID_DATA);
              isValid = false;
            }

            if (!cycle.StartYear.HasValue)
            {
              validationErrors.Add(INVALID_DATA);
              isValid = false;
            }
            else
            {
              if (cycle.StartYear.Value < 1970 || cycle.StartYear.Value > 2037)
              {
                validationErrors.Add(INVALID_DATA);
              }
            }

            if (!cycle.StartDay.HasValue)
            {
              validationErrors.Add(INVALID_DATA);
              isValid = false;
            }
            else
            {
              if (cycle.StartMonth.HasValue && cycle.StartYear.HasValue)
              {
                Calendar calendar = new GregorianCalendar();
                int month = Convert.ToInt32(EnumHelper.GetValueByEnum(cycle.StartMonth.Value));
                int daysInMonth = calendar.GetDaysInMonth(cycle.StartYear.Value, month);
                if (cycle.StartDay.Value > daysInMonth)
                {
                  validationErrors.Add(String.Format(INVALID_DATA));
                }
              }
            }

            cycle.DayOfWeek = null;
            cycle.DayOfMonth = null;
            cycle.FirstDayOfMonth = null;
            cycle.SecondDayOfMonth = null;

            break;
          }
        case UsageCycleType.Monthly:
          {
            if (!cycle.DayOfMonth.HasValue)
            {
              validationErrors.Add(INVALID_DATA);
              isValid = false;
            }

            cycle.DayOfWeek = null;
            cycle.FirstDayOfMonth = null;
            cycle.SecondDayOfMonth = null;
            cycle.StartDay = null;
            cycle.StartMonth = null;
            cycle.StartYear = null;

            break;
          }
        case UsageCycleType.Semi_monthly:
          {
            if (!cycle.FirstDayOfMonth.HasValue)
            {
              validationErrors.Add(INVALID_DATA);
              isValid = false;
            }

            if (!cycle.SecondDayOfMonth.HasValue)
            {
              validationErrors.Add(INVALID_DATA);
              isValid = false;
            }

            if (cycle.FirstDayOfMonth.HasValue && cycle.SecondDayOfMonth.HasValue)
            {
              if (cycle.FirstDayOfMonth.Value >= cycle.SecondDayOfMonth.Value)
              {
                validationErrors.Add(INVALID_DATA);
              }
            }

            cycle.DayOfMonth = null;
            cycle.DayOfWeek = null;
            cycle.StartDay = null;
            cycle.StartMonth = null;
            cycle.StartYear = null;

            break;
          }

        case UsageCycleType.Quarterly:
		         {
            if (!cycle.StartMonth.HasValue)
            {
              validationErrors.Add(INVALID_DATA);
              isValid = false;
            }
            else
            {
              int month = Convert.ToInt32(EnumHelper.GetValueByEnum(cycle.StartMonth.Value));
              if (month < 1 || month > 12)
              {
                validationErrors.Add(INVALID_DATA);
              }
            }

            if (!cycle.StartDay.HasValue)
            {
              validationErrors.Add(INVALID_DATA);
              isValid = false;
            }
            else if (cycle.StartDay < 1 || cycle.StartDay > 31)
            {
                validationErrors.Add(INVALID_DATA);
            }

            cycle.DayOfMonth = null;
            cycle.DayOfWeek = null;
            cycle.FirstDayOfMonth = null;
            cycle.SecondDayOfMonth = null;
            cycle.StartYear = null;

            break;
          }
        case UsageCycleType.Semi_Annually:
        case UsageCycleType.Annually:
          {
            if (!cycle.StartMonth.HasValue)
            {
              validationErrors.Add(INVALID_DATA);
              isValid = false;
            }
            else
            {
              int month = Convert.ToInt32(EnumHelper.GetValueByEnum(cycle.StartMonth.Value));
              if (month < 1 || month > 12)
              {
                validationErrors.Add(INVALID_DATA);
              }
            }

            if (!cycle.StartDay.HasValue)
            {
              validationErrors.Add(INVALID_DATA);
              isValid = false;
            }
            else
            {
              if (cycle.StartDay < 1 || cycle.StartDay > 31)
              {
                validationErrors.Add(INVALID_DATA);
              }

              // Just in case there was an empty month as input
              if (cycle.StartMonth.HasValue)
              {
                  Calendar calendar = new GregorianCalendar();
                  int month = Convert.ToInt32(EnumHelper.GetValueByEnum(cycle.StartMonth.Value));
                  int daysInMonth = calendar.GetDaysInMonth(1999, month);
                  if (cycle.StartDay.Value > daysInMonth)
                  {
                      validationErrors.Add(String.Format(INVALID_DATA));
                  }
              } // end if, Valid StartMonth Value to be processed.
            }

            cycle.DayOfMonth = null;
            cycle.DayOfWeek = null;
            cycle.FirstDayOfMonth = null;
            cycle.SecondDayOfMonth = null;
            cycle.StartYear = null;

            break;
          }
        default:
          {
            validationErrors.Add(String.Format(INVALID_DATA));
            isValid = false;
            break;
          }
      }

      return isValid;
    }

    public static bool ValidateUsageCycle(Account account, List<string> validationErrors)
    {
      bool isValid = true;
      UsageCycleType? usageCycleType = ((InternalView)account.GetInternalView()).UsageCycleType;
      if (!usageCycleType.HasValue)
      {
        AccountTypeCollection mAccountTypeCollection = new AccountTypeCollection();
        var accountType = mAccountTypeCollection.GetAccountType(account.AccountType);

        if ((accountType.CanBePayer || accountType.CanSubscribe || accountType.CanParticipateInGSub))
        {
          validationErrors.Add(String.Format(MISSING_USAGE_CYCLE_TYPE,
                                             account.UserName));
          return false;
        }

        return true;
      }

      switch (usageCycleType)
      {
        case UsageCycleType.Daily:
          {
            account.DayOfWeek = null;
            account.DayOfMonth = null;
            account.FirstDayOfMonth = null;
            account.SecondDayOfMonth = null;
            account.StartDay = null;
            account.StartMonth = null;
            account.StartYear = null;

            break;
          }
        case UsageCycleType.Weekly:
          {
            if (!account.DayOfWeek.HasValue)
            {
              validationErrors.Add(MISSING_DAY_OF_WEEK);
              isValid = false;
            }

            account.DayOfMonth = null;
            account.FirstDayOfMonth = null;
            account.SecondDayOfMonth = null;
            account.StartDay = null;
            account.StartMonth = null;
            account.StartYear = null;

            break;
          }
        case UsageCycleType.Bi_weekly:
          {
            if (!account.StartMonth.HasValue)
            {
              validationErrors.Add(string.Format(MISSING_START_MONTH, usageCycleType.Value.ToString()));
              isValid = false;
            }

            if (!account.StartYear.HasValue)
            {
              validationErrors.Add(MISSING_START_YEAR);
              isValid = false;
            }
            else
            {
              if (account.StartYear.Value < 1970 || account.StartYear.Value > 2037)
              {
                validationErrors.Add(String.Format(INVALID_START_YEAR, account.UserName));
              }
            }

            if (!account.StartDay.HasValue)
            {
              validationErrors.Add(string.Format(MISSING_START_DAY, usageCycleType.Value.ToString()));
              isValid = false;
            }
            else
            {
              if (account.StartMonth.HasValue && account.StartYear.HasValue)
              {
                Calendar calendar = new GregorianCalendar();
                int month = Convert.ToInt32(EnumHelper.GetValueByEnum(account.StartMonth.Value));
                int daysInMonth = calendar.GetDaysInMonth(account.StartYear.Value, month);
                if (account.StartDay.Value > daysInMonth)
                {
                  validationErrors.Add(String.Format(INVALID_START_DAY,
                                                     account.UserName,
                                                     account.StartMonth.Value,
                                                     account.StartYear.Value));
                }
              }
            }

            account.DayOfWeek = null;
            account.DayOfMonth = null;
            account.FirstDayOfMonth = null;
            account.SecondDayOfMonth = null;

            break;
          }
        case UsageCycleType.Monthly:
          {
            if (!account.DayOfMonth.HasValue)
            {
              validationErrors.Add(MISSING_DAY_OF_MONTH);
              isValid = false;
            }

            account.DayOfWeek = null;
            account.FirstDayOfMonth = null;
            account.SecondDayOfMonth = null;
            account.StartDay = null;
            account.StartMonth = null;
            account.StartYear = null;

            break;
          }
        case UsageCycleType.Semi_monthly:
          {
            if (!account.FirstDayOfMonth.HasValue)
            {
              validationErrors.Add(MISSING_FIRST_DAY_OF_MONTH);
              isValid = false;
            }

            if (!account.SecondDayOfMonth.HasValue)
            {
              validationErrors.Add(MISSING_SECOND_DAY_OF_MONTH);
              isValid = false;
            }

            if (account.FirstDayOfMonth.HasValue && account.SecondDayOfMonth.HasValue)
            {
              if (account.FirstDayOfMonth.Value >= account.SecondDayOfMonth.Value)
              {
                validationErrors.Add(INVALID_FIRST_DAY);
                isValid = false;
              }
            }

            account.DayOfMonth = null;
            account.DayOfWeek = null;
            account.StartDay = null;
            account.StartMonth = null;
            account.StartYear = null;

            break;
          }

        case UsageCycleType.Quarterly:
		{
		            if (!account.StartMonth.HasValue)
            {
              validationErrors.Add(string.Format(MISSING_START_MONTH, usageCycleType.Value.ToString()));
              isValid = false;
            }
            else
            {
              int month = Convert.ToInt32(EnumHelper.GetValueByEnum(account.StartMonth.Value));
              if (month < 1 || month > 12)
              {
                validationErrors.Add(INVALID_START_MONTH_RANGE);
              }
            }

            if (!account.StartDay.HasValue)
            {
              validationErrors.Add(string.Format(MISSING_START_DAY, usageCycleType.Value.ToString()));
              isValid = false;
            }
            else if (account.StartDay < 1 || account.StartDay > 31)
            {
                validationErrors.Add(INVALID_START_DAY_RANGE);
            } 
            

            account.DayOfMonth = null;
            account.DayOfWeek = null;
            account.FirstDayOfMonth = null;
            account.SecondDayOfMonth = null;
            account.StartYear = null;

            break;
		}
        case UsageCycleType.Semi_Annually:
        case UsageCycleType.Annually:
          {
            if (!account.StartMonth.HasValue)
            {
              validationErrors.Add(string.Format(MISSING_START_MONTH, usageCycleType.Value.ToString()));
              isValid = false;
            }
            else
            {
              int month = Convert.ToInt32(EnumHelper.GetValueByEnum(account.StartMonth.Value));
              if (month < 1 || month > 12)
              {
                validationErrors.Add(INVALID_START_MONTH_RANGE);
              }
            }

            if (!account.StartDay.HasValue)
            {
              validationErrors.Add(string.Format(MISSING_START_DAY, usageCycleType.Value.ToString()));
              isValid = false;
            }
            else
            {
              if (account.StartDay < 1 || account.StartDay > 31)
              {
                validationErrors.Add(INVALID_START_DAY_RANGE);
                isValid = false;
              }

              // Just in case there was an empty month as input
              if (account.StartMonth.HasValue)
              {
                  Calendar calendar = new GregorianCalendar();
                  int month = Convert.ToInt32(EnumHelper.GetValueByEnum(account.StartMonth.Value));
                  int daysInMonth = calendar.GetDaysInMonth(1999, month);
                  if (account.StartDay.Value > daysInMonth)
                  {
                      validationErrors.Add(String.Format(INVALID_START_DAY_WITHOUT_YEAR,
                                                         account.UserName,
                                                         account.StartMonth.Value));
                      isValid = false;
                  }
              } // end if, Valid StartMonth Value to be processed.
            }

            account.DayOfMonth = null;
            account.DayOfWeek = null;
            account.FirstDayOfMonth = null;
            account.SecondDayOfMonth = null;
            account.StartYear = null;

            break;
          }
        default:
          {
            validationErrors.Add(String.Format(INVALID_USAGE_CYCLE_TYPE,
                                               account.UserName,
                                               usageCycleType.Value.ToString()));
            isValid = false;
            break;
          }
      }

      return isValid;
    }
    public static bool ValidatePayer(Account account, List<string> validationErrors)
    {
      bool isValid = true;

      if (account.PayerID.HasValue && !string.IsNullOrEmpty(account.PayerAccount) && !string.IsNullOrEmpty(account.PayerAccountNS))
      {
        int acctId = AccountIdentifierResolver.ResolveAccountIdentifier(new AccountIdentifier(account.PayerAccount, account.PayerAccountNS));

        if (acctId != account.PayerID.Value)
        {
          validationErrors.Add(string.Format(PAYER_ID_MISMATCH, account.UserName, account.PayerAccount, account.PayerAccountNS, account.PayerID));
          isValid = false;
        }
      }
      else if (!account.PayerID.HasValue)
      {
        // Check if the payer login is specified without a namespace
        if (String.IsNullOrEmpty(account.PayerAccount) && !String.IsNullOrEmpty(account.PayerAccountNS))
        {
          validationErrors.Add(String.Format(MISSING_PAYER_LOGIN, account.UserName, account.PayerAccountNS));
          isValid = false;
        }
        // Check if the payer namespace is specified without a login
        if (!String.IsNullOrEmpty(account.PayerAccount) && String.IsNullOrEmpty(account.PayerAccountNS))
        {
          validationErrors.Add(String.Format(MISSING_PAYER_NAMESPACE, account.UserName, account.PayerAccount));
          isValid = false;
        }
      }

      return isValid;
    }
    public static bool ValidateAncestor(Account account, bool canHaveSyntheticRoot, List<string> validationErrors)
    {
      bool isValid = true;

      if (account.AncestorAccountID.HasValue && !string.IsNullOrEmpty(account.AncestorAccount) && !string.IsNullOrEmpty(account.AncestorAccountNS))
      {
        int acctId = AccountIdentifierResolver.ResolveAccountIdentifier(new AccountIdentifier(account.AncestorAccount, account.AncestorAccountNS));

        if (acctId != account.AncestorAccountID)
        {
          validationErrors.Add(string.Format(ANCESTOR_ID_MISMATCH, account.UserName, account.AncestorAccount, account.AncestorAccountNS, account.AncestorAccountID));
          isValid = false;
        }
      }

      if (!account.AncestorAccountID.HasValue)
      {
        // Check if the ancestor login is specified without a namespace
        if (String.IsNullOrEmpty(account.AncestorAccount) && !String.IsNullOrEmpty(account.AncestorAccountNS))
        {
          validationErrors.Add(String.Format(MISSING_ANCESTOR_LOGIN, account.UserName, account.AncestorAccountNS));
          isValid = false;
        }
        // Check if the ancestor namespace is specified without a login
        if (!String.IsNullOrEmpty(account.AncestorAccount) && String.IsNullOrEmpty(account.AncestorAccountNS))
        {
          validationErrors.Add(String.Format(MISSING_ANCESTOR_NAMESPACE, account.UserName, account.AncestorAccount));
          isValid = false;
        }
      }
      else
      {
        if (account.AncestorAccountID == -1 && !canHaveSyntheticRoot)
        {
          validationErrors.Add(String.Format(INVALID_ACCOUNT_ANCESTOR, account.UserName));
          isValid = false;
        }
      }

      // if neither the ancestor id nor the [login,namespace] is specified then set the id to be 1 or -1
      if (!account.AncestorAccountID.HasValue && 
          String.IsNullOrEmpty(account.AncestorAccount) &&
          String.IsNullOrEmpty(account.AncestorAccountNS))
      {
        if (canHaveSyntheticRoot)
        {
          account.AncestorAccountID = -1; // synthetic root
        }
        else
        {
          account.AncestorAccountID = 1; // root
        }
      }
    
      return isValid;
    }
    public static bool ValidateRequiredProperties(Account account, List<string> validationErrors)
    {
      bool isValid = true;

      List<PropertyInfo> properties = account.GetMTProperties();
      foreach (PropertyInfo propertyInfo in properties)
      {
        if (!account.IsRequiredPropertySet(propertyInfo.Name))
        {
          validationErrors.Add(String.Format(MISSING_REQUIRED_PROP_ACCOUNT, propertyInfo.Name));
          isValid = false;
        }
      }

      Dictionary<string, List<View>>.ValueCollection values = account.GetViews().Values;
      foreach (List<View> views in values)
      {
        foreach (View view in views)
        {
          foreach (PropertyInfo propertyInfo in view.GetMTProperties())
          {
            if (!view.IsRequiredPropertySet(propertyInfo.Name))
            {
              validationErrors.Add(String.Format(MISSING_REQUIRED_PROP_VIEW, propertyInfo.Name, view.GetType().Name));
              isValid = false;
            }
          }
        }
      }

      return isValid;
    }
    
    #endregion

    #region Static Members
    private static AccountTypeCollection m_AccountTypeCollection = new AccountTypeCollection();
    #endregion

    #region Error Strings
    public const string NOT_ACCOUNT = "The given object is not an Account";
    public const string MISSING_INTERNAL_VIEW = "Account must have an InternalView";
    public const string MISSING_USERNAME = "Account must have a user name";
    public const string MISSING_PASSWORD = "Account must have a password";
    public const string MISSING_NAMESPACE = "Account must have a namespace";
    public const string MISSING_DAY_OF_MONTH = "Day of month must be specified for monthly cycle type";
    public const string MISSING_DAY_OF_WEEK = "Day of week must be specified for weekly cycle type";
    public const string MISSING_START_DAY = "Start day must be specified for {0} cycle type";
    public const string MISSING_START_MONTH = "Start month must be specified for {0} cycle type";
    public const string MISSING_START_YEAR = "Start year must be specified for bi-weekly cycle type";
    public const string MISSING_FIRST_DAY_OF_MONTH = "First day of month must be specified for semi-monthly cycle type";
    public const string MISSING_SECOND_DAY_OF_MONTH = "Second day of month must be specified for semi-monthly cycle type";
    public const string MISSING_REQUIRED_PROP_ACCOUNT = "The required account property '{0}' has not been specified";
    public const string MISSING_REQUIRED_PROP_VIEW = "The required view property '{0}' has not been specified for view '{1}'";
    public const string MISSING_CURRENCY_FOR_PAYER = "The payer account '{0}' must have a valid currency";
    public const string MISSING_ACCOUNT_TYPE = "The account '{0}' must have a valid account type";
    public const string MISSING_ACCOUNT_STATUS = "The account '{0}' must have a valid account status";
    public const string INVALID_ACCOUNT_TYPE = "The account '{0}' has an invalid account type '{1}'";
    public const string MISSING_LANGUAGE = "The account '{0}' must have a valid language";
    public const string INVALID_USAGE_CYCLE_TYPE = "The account '{0}' has an invalid usage cycle type '{1}'";
    public const string MISSING_USAGE_CYCLE_TYPE = "The account '{0}' must have a usage cycle type";
    public const string ANCESTOR_ID_MISMATCH = "The account '{0}' has a ancestor login '{1}' and namespace '{2}' that doesn't match the specifeid ancestor ID '{3}'.";
    public const string MISSING_ANCESTOR_LOGIN = "The account '{0}' has an ancestor namespace '{1}' but no login information.";
    public const string MISSING_ANCESTOR_NAMESPACE = "The account '{0}' has an ancestor login '{1}' but no namespace information.";
    public const string PAYER_ID_MISMATCH = "The account '{0}' has a payer login '{1}' and namespace '{2}' that doesn't match the specifeid payer ID '{3}'.";
    public const string MISSING_PAYER_LOGIN = "The account '{0}' has a payer namespace '{1}' but no login information.";
    public const string MISSING_PAYER_NAMESPACE = "The account '{0}' has a payer login '{1}' but no namespace information.";
    public const string MISSING_LOGIN_APP = "The system account '{0}' must have a login application";
    public const string INVALID_ACCOUNT_ANCESTOR = "The account '{0}' has an invalid ancestor id of -1";
    public const string INVALID_ACCOUNT_USERNAME = "The account '{0}' cannot have a username greater than 255 characters.";
    public const string INVALID_ACCOUNT_PASSWORD = "The account '{0}' cannot have a password greater than 1024 characters.";
    public const string INVALID_START_YEAR = "The account '{0}' must have a start year that is between 1970 and 2037.";
    public const string INVALID_START_DAY = "The account '{0}' has a start day that is greater than the number of days for the month '{1}' in year '{2}'.";
    public const string INVALID_START_DAY_WITHOUT_YEAR = "The account '{0}' has a start day that is greater than the number of days for the month '{1}'.";
    public const string INVALID_START_DAY_RANGE = "The account start day must be in the range [1 - 31].";
    public const string INVALID_START_MONTH_RANGE = "The account start month must be in the range [1 - 12].";
    public const string INVALID_FIRST_DAY = "Invalid End of Month day selected.  Day MUST be after start day.";
    public const string INVALID_DATA = "Invalid Data.";
    #endregion
  }
}
