/**************************************************************************
 * @doc MTPROGIDS
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
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | MTPROGIDS
 ***************************************************************************/

#ifndef _MTPROGIDS_H
#define _MTPROGIDS_H

#define MTPROGID_SESSION_SERVER 	"MetraPipeline.MTSessionServer.1"
#define MTPROGID_NAMEID 			"MetraPipeline.MTNameID.1"
#define MTPROGID_SYSCONTEXT 		"MetraPipeline.MTSystemContext.1"
#define MTPROGID_LOG 				"MetraPipeline.MTLog.1"
#define MTPROGID_CONFIG 			"MetraTech.MTConfig.1"
#define MTPROGID_CONFIGLOADER		"MetraTech.MTConfigLoader.1"
#define MTPROGID_QUERYADAPTER 		"MetraTech.MTQueryAdapter.1"
#define MTPROGID_INMEMROWSET    	"MTInMemRowset.MTInMemRowset.1"
#define MTPROGID_SOURCE_SAFE		"SourceSafe"
#define MTPROGID_REPOSITORY			"Metratech.MTRepository.1"
#define MTPROGID_LABELATTACH		"Metratech.MTLabelAttach.1"
#define MTPROGID_CDISTRIBUTOR		"Metratech.MTCDistributor.1"
#define MTPROGID_DEPLOYMENT			"Metratech.MTDeployment.1"
#define MTPROGID_DEPLOYITEM			"Metratech.MTDeployItem.1"
#define MTPROGID_DEPLOYTARGETHOSTS	"Metratech.MTDeployTargetHosts.1"
#define MTPROGID_DEPLOYLABELS		"Metratech.MTDeployLabels.1"
#define MTPROGID_DEPLOYFILES		"Metratech.MTDeployFiles.1"
#define MTPROGID_MTSTAGE			"MetraPipeline.MTStage.1"
#define MTPROGID_SQLROWSET          "MTSQLRowset.MTSQLRowset.1"
#define MTPROGID_FILTER             "MTSQLRowset.MTDataFilter.1"
#define MTPROGID_FILTER_ITEM        "MTSQLRowset.MTFilterItem.1"
#define MTPROGID_USAGEINTERVAL      "COMUsageInterval.COMUsageInterval.1"
#define MTPROGID_USAGECYCLE         "COMUsageCycle.COMUsageCycle.1"
#define MTPROGID_USAGESERVER        "COMUsageServer.COMUsageServer.1"
#define MTPROGID_USAGECYCLEPROPERTYCOLL "MTUsageServer.COMUsageCyclePropertyColl.1"
#define MTPROGID_QUERYCACHE         "MTQueryCache.MTQueryCache.1"
#define MTPROGID_DATAACCESSOR       "COMDataAccessor.COMDataAccessor.1"
#define MTPROGID_MODDESCRIPT        "IMTModuleDescriptor.IMTModuleDescriptor.1"
#define MTPROGID_MTRULESET          "MTRuleSet.MTRuleSet.1"
#define MTPROGID_MTRULE             "MTRule.MTRule.1"
#define MTPROGID_ASSIGNACTION       "MTAssignmentAction.MTAssignmentAction.1"
#define MTPROGID_CONDITIONSET       "MTConditionSet.MTConditionSet.1"
#define MTPROGID_SIMPLECOND         "MTSimpleCondition.MTSimpleCondition.1"
#define MTPROGID_MTACTIONSET        "MTActionSet.MTActionSet.1"
#define MTPROGID_MODULE             "MTModule.MTModule.1"
#define MTRATETABLE_MODULE          "MTRateTable.MTRateTable.1"
#define MTPROGID_TARIFF             "MTTariff.MTTariff.1"
#define MTTARIFF_COL_MODULE         "MTTariffCollection.MTTariffCollection.1"
#define MTSERVICE_LEVEL_MODULE      "MTServiceLevel.MTServiceLevel.1"
#define MTSERVICE_LEVELS_MODULE     "MTServiceLevels.MTServiceLevels.1"
#define MTPROGID_PIPELINE           "MetraPipeline.MTPipeline.1"
#define MTPROGID_SESSIONFAILURES    "MetraPipeline.MTSessionFailures.1"
#define MTPROGID_MTTRANSACTION      "PipelineTransaction.MTTransaction.1"
#define MTPROGID_WHEREABOUTS_MANAGER "PipelineTransaction.MTWhereaboutsManager.1"
#define MTPROGID_CONFCHARGE         "MTConfCharge.MTConfCharge.1"
#define MTPROGID_CONFCHARGES        "MTConfCharges.MTConfCharges.1"
#define MTPROGID_USERCALENDAR		    "MTUserCalendar.MTUserCalendar.1"
#define MTPROGID_RANGECOLLECTION	  "MTRangeCollection.MTRangeCollection.1"
#define MTPROGID_RANGE			      	"MTRange.MTRange.1"
#define MTPROGID_DATE			        	"MTCalendarDate.MTCalendarDate.1"
#define MTPROGID_UNUSEDPORTS        "MTUnusedPorts.MTUnusedPorts.1"
#define MTPROGID_PROPGENPROC        "MTPipeline.PropGenProcessor.1"
#define MTPROGID_HOOKHANDLER        "MTHookHandler.MTHookHandler.1"
#define MTPROGID_CONMANAPP          "MTConManApplication.MTConManApplication.1"
#define MTPROGID_CONMAN							"MTConMan.MTConMan.1"
#define MTPROGID_ILOGGER            "Metratech.Logger.1"
#define MTPROGID_PHONEPARSER        "PhoneNumberParser.PhoneNumberParser.1"
#define MTPROGID_TAXCONFIG          "MTTaxConfig.MTTaxConfig.1"
#define MTPROGID_COMTAX             "MTComTax.MTComTax.1"
#define MTPROGID_COMTAXDATA         "MTComTax.MTComTaxData.1"
#define MTPROGID_COMTAXINST         "MTComTax.MTComTaxInstInfo.1"
#define MTPROGID_COMTAXCALC         "MTComTax.MTComTaxCalc.1"
#define MTPROGID_COMTAXITEM         "MTComTax.MTComTaxItem.1"
#define MTPROGID_WRITEPRODUCTVIEW   "MetraPipeline.WriteProductView.1"
#define MTPROGID_BATCHWRITEPRODUCTVIEW   "MetraPipeline.BatchWriteProductView.1"
#define MTPROGID_GEOCODER           "MTGeocoder.MTGeoCoder.1"
#define MTPROGID_GEOCODE_DATA       "MTGeocoder.MTGeoCodeData.1"
//TODO: REMOVE NEXT LINE
#define MTPROGID_ENUMTYPE           "MTEnumType.MTEnumType.1"
#define MTPROGID_CREDENTIALS    "COMCredentials.COMCredentials.1"
#define MTPROGID_VENDOR_KIOSK   "COMVendorKiosk.COMVendorKiosk.1"
#define MTPROGID_ACCOUNT_MAPPER   "COMAccountMapper.COMAccountMapper.1"
#define MTPROGID_KIOSK_AUTH				"COMKioskAuth.COMKioskAuth.1"
#define MTPROGID_KIOSK_USERCONFIG "COMUserConfig.COMUserConfig.1"
#define MTPROGID_ACCOUNTUTILS			"MTAccountUtils.MTCreateAccount.1"
#define MTPROGID_COMACCOUNT				"COMKiosk.COMAccount.1"
#define MTPROGID_LDAP_IMPL          "MTLDAP.MTLDAPImpl.1"
#define MTPROGID_TAX_SUMMARY        "MTTaxInfo.MTTaxSummary.1"
// #define MTPROGID_SE_UPDATE	"MetraPipeline.MTServiceEndpointUpdate.1"

// usage server stuff 
#define MTPROGID_TAXSUMMARY         "MTTaxInfo.MTTaxSummary.1"
#define MTPROGID_USAGEINTERVALCOLL  "COMUsageIntervalColl.COMUsageIntervalColl.1"

// data export adapters 
#define MTPROGID_STDGLEXPORTER      "MTStdGLExporter.MTStdGLExporter.1"
#define MTPROGID_QUICKBOOKSEXPORTER "MTQuickBooksExporter.MTQuickBooksExporter.1"
#define MTPROGID_QB_AUDIOCONF_EXPORTER "MTStdDataExporter.MTQBAudioConfExporter.1"
#define MTPROGID_TAX_SUMMARY_EXPORTER  "MTStdDataExporter.MTVATTaxExporter.1"

// usage cycle stuff
#define MTPROGID_USAGECYCLE_MONTHLY  "MTStdMonthly.MTStdMonthly.1"
#define MTPROGID_USAGECYCLE_ONDEMAND "MTStdOnDemand.MTStdOnDemand.1"

// calendar stuff
#define MTPROGID_USER_CALENDAR      "MTUserCalendar.MTUserCalendar.1"
#define MTPROGID_RANGE_COLLECTION   "MTRangeCollection.MTRangeCollection.1"
#define MTPROGID_TIMEZONE           "MTTimezone.MTTimezone.1"

// ConfigSetItem stuff
#define MTPROGID_CONFIGSETITEM			"ConfigSetOwner.MTConfigSetItem.1"
#define MTPROGID_CONFIGSETOWNER			"ConfigSetOwner.MTConfigSetOwner.1"
#define MTPROGID_CONFIGSETOWNERLIST	"ConfigSetOwner.MTConfigSetOwnerList.1"
#define MTPROGID_CONFIGSETOWNERHELPER "ConfigSetOwner.MTConfigOwnerHelper.1"

// reporting infrastructure stuff 
#define MTPROGID_REPORTINGVIEW      "ReportingInfo.MTReportingView.1"
#define MTPROGID_CONTACTINFO        "ReportingInfo.MTContactInfo.1"
#define MTPROGID_ENUMTYPEINFO       "ReportingInfo.MTEnumTypeInfo.1"

// server access stuff
#define MTPROGID_SERVERACCESS      "MTServerAccess.MTServerAccessDataSet.1"

// credit card stuff
#define MTPROGID_CREDITCARD      "MetraTechAccount.MTCreditCard.1"

// discounts

#define MTPROGID_DISCOUNTS "Discounts.MTDiscounts.1"
#define MTPROGID_DISCOUNT "Discounts.MTDiscount.1"

// COM SDK 
#define MTPROGID_IMETER "MetraTechSDK.Meter.1"
#define MTPROGID_ISESSION "MetraTechSDK.Session.1" 

// tiered discounts
#define MTPROGID_MTTIER "Tiered.MTTier.1"

// product view configuration COM object
#define MTPROGID_MTPRODUCTVIEWOPS "MTProductView.MTProductViewOps.1"

// account adapters
#define MTPROGID_MTINTERNALADAPTER "MTAccount.MTInternalAdapter.1"
#define MTPROGID_MTLDAPADAPTER "MTAccount.MTLDAPAdapter.1"
#define MTPROGID_MTDB2ADAPTER "MTAccount.MTDB2Adapter.1"
#define MTPROGID_MTACCOUNTSERVER "MTAccount.MTAccountServer.1"
#define MTPROGID_MTACCOUNTPROPERTY "MTAccount.MTAccountProperty.1"
#define MTPROGID_MTACCOUNTPROPERTYCOLLECTION "MTAccount.MTAccountPropertyCollection.1"
#define MTPROGID_MTACCOUNTFINDER "MTAccount.MTAccountFinder.1"
#define MTPROGID_MTSEARCHRESULTCOLLECTION "MTAccount.MTSearchResultCollection.1"


//configuration properties stuff
#define MTPROGID_CONFIG_PROPERTY	"MetraTech.MTConfigProp.1"
#define MTPROGID_CONFIG_PROPERTY_SET	"MTConfigPropSet.MTConfigPropSet.1"
#define MTPROGID_CONFIG_ATTRIB_SET	"MetraTech.MTConfigAttribSet.1"
#define MTPROGID_PROPERTY	"MetraTech.MTConfigProp.1"

//enum types stuff
#define MTPROGID_ENUM_CONFIG "Metratech.MTEnumConfig.1"
#define MTPROGID_ENUMERATOR "Metratech.MTEnumerator.1"
#define MTPROGID_ENUMERATOR_COLLECTION "Metratech.MTEnumeratorCollection.1"
#define MTPROGID_ENUM_TYPE "Metratech.MTEnumType.1"
#define MTPROGID_ENUMTYPE_COLLECTION "Metratech.MTEnumTypeCollection.1"
#define MTPROGID_ENUMSPACE "Metratech.MTEnumSpace.1"
#define MTPROGID_ENUMSPACE_COLLECTION "Metratech.MTEnumSpaceCollection.1"

//localization stuff
#define MTPROGID_LOCALE_CONFIG "Metratech.LocaleConfig.1"
#define MTPROGID_LOCALE_ENTRY "Metratech.MTLocalizedEntry.1"
#define MTPROGID_LOCALE_COLLECTION "Metratech.MTLocalizedCollection.1"

// RCD objects
#define MTPROGID_RCD "MetraTech.Rcd.1"
#define MTPROGID_RCDFILELIST "MetraTech.RcdFileList.1"

#define MTPROGID_MTPRODUCTCATALOG "Metratech.MTProductCatalog.1"
#define MTPROGID_MTCOLLECTION "Metratech.MTCollection.1"
#define MTPROGID_MTCOUNTERTYPE "Metratech.MTCounterType.1"
#define MTPROGID_MTCOUNTER "Metratech.MTCounter.1"
#define MTPROGID_MTCOUNTERPARAMETER "MetraTech.MTCounterParameter.1"
#define MTPROGID_MTCOUNTERPROPDEF "MetraTech.MTCounterPropertyDefinition.1"

// properties
#define MTPROGID_MTPROPERTY "Metratech.MTProperty.1"
#define MTPROGID_MTPROPERTIES "Metratech.MTProperties.1"
#define MTPROGID_MTPROPERTY_METADATA "Metratech.MTPropertyMetaData.1"
#define MTPROGID_MTPROPERTY_METADATASET "Metratech.MTPropertyMetaDataSet.1"

// account state objects
#define MTPROGID_MTACCOUNTSTATEMANAGER "MTAccountStates.MTAccountStateManager.1"
#define MTPROGID_MTACCOUNTSTATEMETADATA "MTAccountStates.MTAccountStateMetaData.1"
#define MTPROGID_MTPENDINGACTIVEAPPROVALSTATE "MTAccountStates.PendingActiveApproval.1"
#define MTPROGID_MTACTIVESTATE "MTAccountStates.Active.1"
#define MTPROGID_MTSUSPENDEDSTATE "MTAccountStates.Suspended.1"
#define MTPROGID_MTPENDINGFINALBILLSTATE "MTAccountStates.PendingFinalBill.1"
#define MTPROGID_MTCLOSEDSTATE "MTAccountStates.Closed.1"
#define MTPROGID_MTARCHIVEDSTATE "MTAccountStates.Archived.1"

#define MTPROGID_AUDITOR "MetraTech.Auditor.1"

#define MTPROGID_MTSESSIONCONTEXT "MetraTech.MTSessionContext.1"
#define MTPROGID_MTSECURITY "MetraTech.MTSecurity.1"
#define MTPROGID_MTLOGINCONTEXT "MetraTech.MTLoginContext.1"
#define MTPROGID_MTISSUECREDITCAPABILITY "MetraTech.MTIssueCreditCapability.1"
#define MTPROGID_MTROLE "MetraTech.MTRole"
#define MTPROGID_MTYAAC "MetraTech.MTYAAC"
#define MTPROGID_COMPOSITE_CAPABILITY_TYPE "MetraTech.MTCompositeCapabilityType"

#define MTPROGID_MTACCOUNTCATALOG "Metratech.MTAccountCatalog"

#define MTPROGID_MTSERVICEENDPOINT "MetraTech.MTServiceEndpoint"

//AR interface
#define MTPROGID_MTARCONFIG "MetraTech.MTARConfig"
#define MTPROGID_MTARWRITER "MetraTech.MTARWriter"
#define MTPROGID_MTARREADER "MetraTech.MTARReader"



#endif /* _MTPROGIDS_H */
