/**************************************************************************
* Copyright 1997-2000 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Created by: Boris Partensky
* 
***************************************************************************/


//C representation of PaymentStatus Metratech pipeline enum type
namespace PaymentServer
{
	typedef enum 
	{
		PS_PENDING_APPROVAL,
		PS_PENDING,
		PS_SENT,
		PS_OPEN,
		PS_SETTLED,
		PS_FAILED,
		PS_INCOMPLETE_ACCOUNT_INFO,
		PS_INVESTIGATE,
		PS_ARCHIVE,
		PS_RETRY,
		PS_NOTPAID
	} PaymentStatus;
	
	typedef enum 
	{
		PS_CREDIT_CARD,
		PS_ACH
	} PaymentType;

	typedef enum
	{
		CC_VISA = 1,
		CC_MASTERCARD,
		CC_AMEX,
		CC_DISCOVER,
		CC_JCB,
		CC_DINERSCLUB,
		CC_VISA_PURCHASE_CARD,
		CC_MASTERCARD_PURCHASE_CARD,
		CC_AMEX_PURCHASE_CARD,
		CC_VISA_PURCHASE_CARD_INTL,
		CC_MASTERCARD_PURCHASE_CARD_INTL,
		CC_AMEX_PURCHASE_CARD_INTL
	} CreditCardType;

	typedef enum 
	{
		SAVINGS,
		CHECKING
	} BankAccountType;
};

namespace BillingCycle
{
	typedef enum
	{
		UST_MONTHLY = 1,
		UST_ONDEMAND,
		UST_DAILY,
		UST_WEEKLY,
		UST_BIWEEKLY,
		UST_SEMIMONTHLY,
		UST_QUATERLY,
		UST_ANNUALLY
	} UsageCycleType;

};
