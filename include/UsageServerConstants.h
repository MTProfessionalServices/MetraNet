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
* Created by: Kevin Fitzgerald 
* $Header$
* 
***************************************************************************/

#ifndef __USAGESERVERCONSTANTS_H
#define __USAGESERVERCONSTANTS_H

// Usage Cycle Property Names 
#define UCP_DAY_OF_WEEK         L"DayOfWeek"
#define UCP_DAY_OF_MONTH        L"DayOfMonth"
#define UCP_FIRST_DAY_OF_MONTH  L"FirstDayOfMonth"
#define UCP_SECOND_DAY_OF_MONTH L"SecondDayOfMonth"
#define UCP_START_MONTH         L"StartMonth"
#define UCP_START_DAY           L"StartDay"
#define UCP_START_YEAR          L"StartYear"
#define UCP_CYCLE_ID            L"CycleID"

// MetraTech defined cycle types ...
#define UC_MONTHLY              1
#define UC_ON_DEMAND            2
#define UC_DAILY                3
#define UC_WEEKLY               4
#define UC_BI_WEEKLY            5
#define UC_SEMI_MONTHLY         6
#define UC_QUARTERLY            7
#define UC_ANNUALLY             8
#define UC_SEMIANNUALLY         9

#define UC_DEFAULT_STR              L"Default"

// definitions
const char USAGE_SERVER_CONFIG_DIR[] = "\\UsageServer" ;
const char USAGE_SERVER_QUERY_DIR[] = "\\Queries\\UsageServer" ;
const char RECURRING_EVENT_FILE[] = "recurring_event.xml" ;

// usage cycle period types ...
#define USAGE_CYCLE_PERIOD_BILLING    L"B"
#define USAGE_CYCLE_PERIOD_TIME       L"T"

// usage interval states ...
#define USAGE_INTERVAL_NEW                    L"N"
#define USAGE_INTERVAL_OPEN                   L"O"

#define USAGE_INTERVAL_EXPIRED                L"E"
#define USAGE_INTERVAL_PENDING_SOFT_CLOSE     L"E"

#define USAGE_INTERVAL_CLOSED                 L"C" 
#define USAGE_INTERVAL_SOFT_CLOSED            L"C"

#define USAGE_INTERVAL_SHUTDOWN               L"S" 
#define USAGE_INTERVAL_PENDING_HARD_CLOSE     L"S"

#define USAGE_INTERVAL_HARD_CLOSED            L"H"

// recurring event XML file tags ...
#define TAG_EVENT_PERIOD_BEGINNING    "beginning_period_events"
#define TAG_EVENT_PERIOD_SOFT_CLOSE   "soft_close_events"
#define TAG_EVENT_PERIOD_HARD_CLOSE   "hard_close_events"
#define TAG_ACCOUNT_HOOK              "account_hook"
#define TAG_GLOBAL_HOOK               "global_hook"
#define TAG_PERIOD_TYPE_BILLING       "billing_period"
#define TAG_PERIOD_TYPE_TIME          "time_period"
#define TAG_GROUP                     "group"
#define TAG_ADAPTER_SET               "adapter_set"
#define TAG_ADAPTER                   "adapter"
#define TAG_ADAPTER_NAME              "adapter_name"
#define TAG_CONFIG_FILE               "config_file"

#endif
