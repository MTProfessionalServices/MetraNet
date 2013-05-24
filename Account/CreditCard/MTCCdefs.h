/**************************************************************************
 * @doc 
 *
 * @module |
 *
 *
 * Copyright 1998 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 ***************************************************************************/

#define MT_MAX_SERVERS 3		// Maximum number of servers to allow in serverlist

#define DEFAULT_SERVICE_NAME "MetraTech.com/CreditCard"
#define DEFAULT_HTTP_TIMEOUT 90
#define DEFAULT_HTTP_RETRIES 3
#define DEFAULT_CURRENCY_CODE "USD"
#define DEFAULT_CREDIT_CARD_COUNTRY "USA"

// Credit Card Definitions
#define MIN_CREDIT_CARD_NUM_LEN 12
#define ERROR_BUFFER_LEN 1024

#define MAX_CREDIT_CARD_NUM_LEN 16
//#define MASTERCARD_CC_LEN 16 
//#define VISA_CC_LEN_1 13
//#define VISA_CC_LEN_2 16
//#define AMERICAN_EXPRESS_CC_LEN 15
//#define	OPTIMA_CC_LEN 15
//// #define CARTE_BLANCHE_CC_LEN 15
//#define DINERS_CLUB_CC_LEN 14
//#define DISCOVER_CC_LEN 16
//#define JCB_CC_LEN 16
//
//#define CC_LAST_ENTRY -1
//
//// Defines number of valid credit card prefixes for each card type
//#define MASTERCARD_LOOKUP_ENTRY_COUNT 5
//#define OPTIMA_LOOKUP_ENTRY_COUNT 10
//// #define CARTE_BLANCHE_LOOKUP_ENTRY_COUNT 3
//#define VISA_LOOKUP_ENTRY_COUNT 1
//#define DINERS_LOOKUP_ENTRY_COUNT 10
//#define	VISA_PREFIX_CODES ('4')
//#define	DISCOVER_LOOKUP_ENTRY_COUNT 1
//#define AMEX_LOOKUP_ENTRY_COUNT 2
//#define JCB_LOOKUP_ENTRY_COUNT 2

/*
** These are not used - they are programmed into static _cc_lookup_map in the .cpp file
** I am just leaving them for reference - JR
#define	AMEX_PREFIX_CODES ('34', '37')
#define DISCOVER_PREFIX_CODES ('6011')
#define DINERS_CLUB_PREFIX_CODES ('30', '36', '381', '383', '384', '385', '386', '387', '388')
#define	OPTIMA_PREFIX_CODES ('3707', '3717', '3727', '3737', '3747', '3757', '3767', '3777', '3787', '3797')
#define CARTE_BLANCHE_PREFIX_CODES ('94', '95', '389')
#define MASTERCARD_PREFIX_CODES ('51','52','53','54','55')
*/

/*
 * @struct CREDITCARD_LOOKUP_STRUCT |
 * This structure is used to store a list of the valid prefix codes for a given credit card type
 */
typedef struct _cc_lookup_map {
    long		numOfChar;       // @field Number of initial characters to match
    char	    *prefixDigits;		// @field String to match against
} CREDITCARD_LOOKUP_STRUCT;


