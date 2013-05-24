using System;
using System.Collections.Generic;
using System.Text;
using System.Reflection;

using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.Accounts.Type;
using MetraTech.Interop.IMTAccountType;

namespace MetraTech.DomainModel.Validators
{
  public class AccountUpdateValidator : IValidator
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
        validationErrors.Add(AccountValidator.NOT_ACCOUNT);
        return false;
      }

      // If the password is being changed, check that 
      // the username and namespace are also being updated
      if (account.IsPassword_Dirty)
      {
        AccountValidator.ValidateUsername(account, validationErrors);
        AccountValidator.ValidatePassword(account, validationErrors);
        AccountValidator.ValidateNamespace(account, validationErrors);
      }

      // If the account state is being changed check that 
      // account start date and account end date are also being updated 
      if (account.IsAccountStatusDirty)
      {
        if (account.AccountStatus == null ||
            account.AccountStartDate == null ||
            account.AccountEndDate == null)
        {
          validationErrors.Add(BAD_STATUS_UPDATE);
        }
      }

      IMTAccountType accountType = AccountTypesCollection.GetAccountType(account.AccountType);

      // Check payer update
      if (account.IsPayerIDDirty || 
          account.IsPayerAccountDirty || 
          account.IsPayerAccountNSDirty || 
          account.IsPayment_StartDateDirty || 
          account.IsPayment_EndDateDirty)
      {
        if (!ValidIdentifier(account.PayerID, account.PayerAccount, account.PayerAccountNS) ||
            account.Payment_StartDate == null)
        {
          validationErrors.Add(BAD_PAYER_INFO);
        }
        // Validate payer and usage cycle info
        if (accountType.CanBePayer)
        {
            AccountValidator.ValidatePayer(account, validationErrors);
      }

      }

      // Check ancestor update 
      if (account.IsAncestorAccountIDDirty ||
          account.IsAncestorAccountDirty ||
          account.IsAncestorAccountNSDirty ||
          account.IsHierarchy_StartDateDirty ||
          account.IsHierarchy_EndDateDirty)
      {
        if (!ValidIdentifier(account.AncestorAccountID, account.AncestorAccount, account.AncestorAccountNS) ||
            account.Hierarchy_StartDate == null)
        {
          validationErrors.Add(BAD_ANCESTOR_INFO);
        }
        // Validate ancestor information
        AccountValidator.ValidateAncestor(account, accountType.CanHaveSyntheticRoot, validationErrors);
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

    #region Private Methods
    private bool ValidIdentifier(int? id, string username, string nameSpace)
    {
      if (id == null && String.IsNullOrEmpty(username) && String.IsNullOrEmpty(nameSpace))
      {
        return false;
      }

      if (id == null)
      {
        if (String.IsNullOrEmpty(username) || String.IsNullOrEmpty(nameSpace))
        {
          return false;
        }
      }

      return true;
    }
    #endregion

    #region Error Strings
    public const string NOT_ACCOUNT = "The given object is not an Account";
    public const string BAD_PASSWORD_UPDATE = "Login name and namespace required when changing the password.";
    public const string BAD_STATUS_UPDATE = "Partial information for updating the account state.  The system requires the new state, the start date and the end date.";
    public const string BAD_PAYER_INFO = "Partial information specified for payment redirection. Need new payer information and payment startdate";
    public const string BAD_ANCESTOR_INFO = "Partial information specified to change account hierarchy location.  Need new ancestor information and hierarchy startdate";
    #endregion

    private static AccountTypeCollection m_AccountTypeCollection = null;

    protected static AccountTypeCollection AccountTypesCollection
    {
      get
      {
        if (m_AccountTypeCollection == null)
        {
          m_AccountTypeCollection = new AccountTypeCollection();
        }

        return m_AccountTypeCollection;
      }
    }
  }
}
