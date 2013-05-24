#include "StdAfx.h"
#include "ARInterfaceMethod.h"
#include <comdef.h>
#include <mtcomerr.h>


ARInterfaceMethod StringToARInterfaceMethod(string str)
{
  ARInterfaceMethod method;
	if (str == "CreateOrUpdateAccounts")
		method = ARMETHOD_CreateOrUpdateAccounts;
  else if (str == "UpdateAccountStatus")
		method = ARMETHOD_UpdateAccountStatus;
	else if (str == "CreateOrUpdateTerritories")
		method = ARMETHOD_CreateOrUpdateTerritories;
	else if (str == "UpdateTerritoryManagers")
		method = ARMETHOD_UpdateTerritoryManagers;
	else if (str == "CreateOrUpdateSalesPersons")
		method = ARMETHOD_CreateOrUpdateSalesPersons;
	else if (str == "MoveBalances")
		method = ARMETHOD_MoveBalances;
	else if (str == "CreateInvoices")
		method = ARMETHOD_CreateInvoices;
  else if (str == "CreateAdjustments")
    method = ARMETHOD_CreateAdjustments;
	else if (str == "CreatePayments")
		method = ARMETHOD_CreatePayments;
	else if (str == "DeleteInvoices")
		method = ARMETHOD_DeleteInvoices;
	else if (str == "DeleteAdjustments")
		method = ARMETHOD_DeleteAdjustments;
  else if (str == "DeletePayments")
		method = ARMETHOD_DeletePayments;
	else if (str == "DeleteBatches")
		method = ARMETHOD_DeleteBatches;
	else if (str == "ApplyCredits")
		method = ARMETHOD_ApplyCredits;
	else if (str == "RunAging")
		method = ARMETHOD_RunAging;
	else if (str == "DeleteAccountStatusChanges")
		method = ARMETHOD_DeleteAccountStatusChanges;
  else if (str == "GetBalances")
		method = ARMETHOD_GetBalances;
  else if (str == "GetBalanceDetails")
		method = ARMETHOD_GetBalanceDetails;
  else if (str == "GetAgingConfiguration")
		method = ARMETHOD_GetAgingConfiguration;
  else if (str == "CanDeleteInvoices")
		method = ARMETHOD_CanDeleteInvoices;
  else if (str == "CanDeleteAdjustments")
		method = ARMETHOD_CanDeleteAdjustments;
  else if (str == "CanDeletePayments")
		method = ARMETHOD_CanDeletePayments;
  else if (str == "CanDeleteBatches")
		method = ARMETHOD_CanDeleteBatches;
  else if (str == "GetAccountStatusChanges")
		method = ARMETHOD_GetAccountStatusChanges;
  else
		MT_THROW_COM_ERROR("invalid ARInterfaceMethod");

	return method;
}

string ARInterfaceMethodToString(ARInterfaceMethod method)
{
  switch(method)
  {
    case ARMETHOD_CreateOrUpdateAccounts: return "CreateOrUpdateAccounts";
    case ARMETHOD_UpdateAccountStatus: return "UpdateAccountStatus";
    case ARMETHOD_CreateOrUpdateTerritories: return "CreateOrUpdateTerritories";
    case ARMETHOD_UpdateTerritoryManagers: return "UpdateTerritoryManagers";
    case ARMETHOD_CreateOrUpdateSalesPersons: return "CreateOrUpdateSalesPersons";
    case ARMETHOD_MoveBalances: return "MoveBalances";
    case ARMETHOD_CreateInvoices: return "CreateInvoices";
    case ARMETHOD_CreateAdjustments: return "CreateAdjustments";
    case ARMETHOD_CreatePayments: return "CreatePayments";
    case ARMETHOD_DeleteInvoices: return "DeleteInvoices";
    case ARMETHOD_DeleteAdjustments: return "DeleteAdjustments";
    case ARMETHOD_DeletePayments: return "DeletePayments";
    case ARMETHOD_DeleteBatches: return "DeleteBatches";
    case ARMETHOD_ApplyCredits: return "ApplyCredits";
    case ARMETHOD_RunAging: return "RunAging";
    case ARMETHOD_DeleteAccountStatusChanges: return "DeleteAccountStatusChanges";
    case ARMETHOD_GetBalances: return"GetBalances";
    case ARMETHOD_GetBalanceDetails: return"GetBalanceDetails";
    case ARMETHOD_GetAgingConfiguration: return"GetAgingConfiguration";
    case ARMETHOD_CanDeleteInvoices: return"CanDeleteInvoices";
    case ARMETHOD_CanDeleteAdjustments: return"CanDeleteAdjustments";
    case ARMETHOD_CanDeletePayments: return"CanDeletePayments";
    case ARMETHOD_CanDeleteBatches: return"CanDeleteBatches";
    case ARMETHOD_GetAccountStatusChanges: return"GetAccountStatusChanges";
    default: return "[unknown]";
  }
}
