#ifndef __ARINTERFACEMETHOD_H_
#define __ARINTERFACEMETHOD_H_

#include <string>

using std::wstring;
using std::string;

enum ARInterfaceMethod
{
  //writer methods:
  ARMETHOD_UNKNOWN = 0,
  ARMETHOD_CreateOrUpdateAccounts,
  ARMETHOD_UpdateAccountStatus,
  ARMETHOD_CreateOrUpdateTerritories,
  ARMETHOD_UpdateTerritoryManagers,
  ARMETHOD_CreateOrUpdateSalesPersons,
  ARMETHOD_MoveBalances,
  ARMETHOD_CreateInvoices,
  ARMETHOD_CreateInvoicesWithTaxDetails,
  ARMETHOD_CreateAdjustments,
  ARMETHOD_CreatePayments,
  ARMETHOD_DeleteInvoices,
  ARMETHOD_DeleteAdjustments,
  ARMETHOD_DeletePayments,
  ARMETHOD_DeleteBatches,
  ARMETHOD_ApplyCredits,
  ARMETHOD_RunAging,
  ARMETHOD_DeleteAccountStatusChanges,
  
  //reader methods:
  ARMETHOD_GetBalances,
  ARMETHOD_GetBalanceDetails,
  ARMETHOD_GetAgingConfiguration,
  ARMETHOD_CanDeleteInvoices,
  ARMETHOD_CanDeleteAdjustments,
  ARMETHOD_CanDeletePayments,
  ARMETHOD_CanDeleteBatches,
  ARMETHOD_GetAccountStatusChanges
};

ARInterfaceMethod StringToARInterfaceMethod(string str);
string ARInterfaceMethodToString(ARInterfaceMethod method);

#endif