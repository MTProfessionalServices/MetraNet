//=============================================================================
// Copyright 1997-2012 by MetraTech
// All rights reserved.
//
// THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
// REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
// example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
// WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
// OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
// INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
// RIGHTS.
//
// Title to copyright in this software and any associated
// documentation shall at all times remain with MetraTech, and USER
// agrees to preserve the same.
//
//-----------------------------------------------------------------------------
using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using BillSoft.EZTaxNET;
using MetraTech.Tax.Framework.MtBillSoft;
using MetraTech.DataAccess;
using MetraTech.DomainModel.Enums.Tax.Metratech_com_tax;
using MetraTech.Tax.Framework.DataAccess;

namespace MetraTech.Tax.Framework.MtBillSoft
{
  /// <summary>
  /// BillSoftConstantConverter knows how to convert BillSoft constants and strings
  /// to MetraTech constants and strings and vice versa.
  /// </summary>
  public class BillSoftConstantConverter
  {
    /// <summary>
    /// Logging interface
    /// </summary>
    private static Logger mLogger = new Logger("[TaxManager.BillSoft.BillSoftConstantConverter]");

    /// <summary>
    /// Given the enum string, get the EZTax transactionType
    /// </summary>
    /// <param name="strTran"></param>
    /// <returns></returns>
    public static short GetEZTaxTransactionType(string strTran)
    {
      switch (strTran.ToUpper())
      {
        case "DO_NOT_APPLY_TAX":
          return TransactionType.DO_NOT_APPLY_TAX;
        case "CABLE_TELEVISION":
          return TransactionType.CABLE_TELEVISION;
        case "INTERPROVINCIAL":
          return TransactionType.INTERPROVINCIAL;
        case "INTRAPROVINCIAL":
          return TransactionType.INTRAPROVINCIAL;
        case "CELLULAR":
          return TransactionType.CELLULAR;
        case "FAX":
          return TransactionType.FAX;
        case "INTERNATIONAL":
          return TransactionType.INTERNATIONAL;
        case "INTERNET":
          return TransactionType.INTERNET;
        case "INTERSTATE":
          return TransactionType.INTERSTATE;
        case "INTRASTATE":
          return TransactionType.INTRASTATE;
        case "LOCAL":
          return TransactionType.LOCAL;
        case "NATURAL_GAS":
          return TransactionType.NATURAL_GAS;
        case "NON_RECURRING":
          return TransactionType.NON_RECURRING;
        case "OTHER":
          return TransactionType.OTHER;
        case "PAGING":
          return TransactionType.PAGING;
        case "SALES":
          return TransactionType.SALES;
        case "SHIPPING":
          return TransactionType.SHIPPING;
        case "TELEPHONY":
          return TransactionType.TELEPHONY;
        case "VOICE_MAIL":
          return TransactionType.VOICE_MAIL;
        case "WIRELESS":
          return TransactionType.WIRELESS;
        case "SATELLITE_TELEVISION":
          return TransactionType.SATELLITE_TELEVISION;
          // New Transaction Types Added 05-31-2007
        case "VOIP":
          return TransactionType.VOIP;
        case "VOIPA":
          return TransactionType.VOIPA;
        case "PAYPHONE":
          return TransactionType.PAYPHONE;
        case "SOFTWARE":
          return TransactionType.SOFTWARE;
        case "TIMESHARING":
          return TransactionType.TIMESHARING;
          // END New Transaction Types Added 05-31-2007
        default:
          return -1; /* We do not expect this condition to occur. we should have validated this pair beforehand. */
      }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="strService"></param>
    /// <returns></returns>
    public static short GetEZTaxServiceType(string strService)
    {
      switch (strService.ToUpper())
      {
        case "DO_NOT_APPLY_TAX":
          return 0;
        case "ACTIVATION":
          return ServiceType.ACTIVATION;
        case "CENTREX_EXTENSION":
          return ServiceType.CENTREX_EXTENSION;
        case "COIN":
          return ServiceType.COIN;
        case "CONFERENCE_BRIDGE":
          return ServiceType.CONFERENCE_BRIDGE;
        case "CONSUMPTION":
          return ServiceType.CONSUMPTION;
        case "DATA":
          return ServiceType.DATA;
        case "DEBIT":
          return ServiceType.DEBIT;
        case "DIRECTORY_ADS":
          return ServiceType.DIRECTORY_ADS;
        case "E911_CALL":
          return ServiceType.E911_CALL;
        case "EQUIPMENT_RENTAL":
          return ServiceType.EQUIPMENT_RENTAL; /* This is a new constant. Previously it was EQUIPMENT	*/
        case "EQUIPMENT_REPAIR":
          return ServiceType.EQUIPMENT_REPAIR; /* This is a new constant. Previously it was EQUIPMENT	*/
        case "INTERNATIONAL_TOLL":
          return ServiceType.INTERNATIONAL_TOLL;
          /* This is a new constant. previosuly they had it like EQUIPMENT_LEASE */
        case "FCC_SUBSCRIBER_LINE_FEE":
          return ServiceType.FCC_SUBSCRIBER_LINE_FEE;
        case "FOB_DESTINATION":
          return ServiceType.FOB_DESTINATION;
        case "FOB_ORIGIN":
          return ServiceType.FOB_ORIGIN;
        case "HIGH_CAPACITY_TRUNK":
          return ServiceType.HIGH_CAPACITY_TRUNK;
        case "INSTALL":
          return ServiceType.INSTALL;
        case "INVOICE":
          return ServiceType.INVOICE;
        case "LATE_CHARGE":
          return ServiceType.LATE_CHARGE;
        case "LINES":
          return ServiceType.LINES;
        case "LOCAL_EXCHANGE":
          return ServiceType.LOCAL_EXCHANGE;
        case "LOCAL_FEATURE_CHARGE":
          return ServiceType.LOCAL_FEATURE_CHARGE;
        case "LOCAL_LOOP":
          return ServiceType.LOCAL_LOOP;
        case "LOCATION":
          return ServiceType.LOCATION;
        case "N_900_SERVICE":
          return ServiceType.N_900_SERVICE;
        case "N800":
          return ServiceType.N800;
        case "PAY_PER_VIEW_SERVICE":
          return ServiceType.PAY_PER_VIEW_SERVICE;
        case "PBX_EXTENSION":
          return ServiceType.PBX_EXTENSION;
        case "PBX_TRUNK":
          return ServiceType.PBX_TRUNK;
        case "PREMIUM_SERVICE":
          return ServiceType.PREMIUM_SERVICE;
        case "PREPAID":
          return ServiceType.PREPAID;
        case "PRIVATE_LINE":
          return ServiceType.PRIVATE_LINE;
        case "PRODUCT":
          return ServiceType.PRODUCT;
        case "ROAMING_CHARGE":
          return ServiceType.ROAMING_CHARGE;
        case "SERVICE":
          return ServiceType.SERVICE;
        case "TELEGRAPH":
          return ServiceType.TELEGRAPH;
        case "TOLL":
          return ServiceType.TOLL;
        case "TRUNK":
          return ServiceType.TRUNK;
        case "TV_GUIDE":
          return ServiceType.TV_GUIDE;
        case "USA_INBOUND":
          return ServiceType.USA_INBOUND;
        case "USAGE":
          return ServiceType.USAGE;
        case "USE":
          return ServiceType.USE;
        case "WATS":
          return ServiceType.WATS;
        case "WEB_HOSTING":
          return ServiceType.WEB_HOSTING;
        case "WIRE_MAINTENANCE_PLAN":
          return ServiceType.WIRE_MAINTENANCE_PLAN;
          // New Service Types Added 05-31-2007
        case "PICC":
          return ServiceType.PICC;
        case "NO_PICK_PICC":
          return ServiceType.NO_PICK_PICC;
        case "WIRELESS_ACCESS_CHARGE":
          return ServiceType.WIRELESS_ACCESS_CHARGE;
        case "INTERSTATE_USAGE":
          return ServiceType.INTERSTATE_USAGE;
        case "INTRASTATE_USAGE":
          return ServiceType.INTRASTATE_USAGE;
        case "INTERNATIONAL_USAGE":
          return ServiceType.INTERNATIONAL_USAGE;
        case "WIRELESS_LINES":
          return ServiceType.WIRELESS_LINES;
        case "LNP":
          return ServiceType.LNP;
        case "DIRECTORY_ASSISTANCE":
          return ServiceType.DIRECTORY_ASSISTANCE;
        case "LOCAL_USAGE":
          return ServiceType.LOCAL_USAGE;
        case "PROVISIONING":
          return ServiceType.PROVISIONING;
        case "DATA_PROCESSING":
          return ServiceType.DATA_PROCESSING;
        case "ACCESS_LINE":
          return ServiceType.ACCESS_LINE;
        case "LICENSE_SOFTWARE":
          return ServiceType.LICENSE_SOFTWARE;
        case "SOFTWARE_MAINTENANCE_AGREEMENT":
          return ServiceType.SOFTWARE_MAINTENANCE_AGREEMENT;
        case "REPORT_ON_CD_PAPER_FORM":
          return ServiceType.REPORT_ON_CD_PAPER_FORM;
        case "INFORMATION_RETRIEVAL":
          return ServiceType.INFORMATION_RETRIEVAL;
        case "RESTOCKING_FEE_RENTAL":
          return ServiceType.RESTOCKING_FEE_RENTAL;
        case "RESTOCKING_FEE_PURCHASE":
          return ServiceType.RESTOCKING_FEE_PURCHASE;
        case "PARTIAL_CREDIT":
          return ServiceType.PARTIAL_CREDIT;
        case "LATE_CHARGE_BUNDLE":
          return ServiceType.LATE_CHARGE_BUNDLE;
        case "LOCAL_EXCHANGE_BUNDLE":
          return ServiceType.LOCAL_EXCHANGE_BUNDLE;
        case "FCC_SUBSCRIBER_LINE_FEE_BUNDLE":
          return ServiceType.FCC_SUBSCRIBER_LINE_FEE_BUNDLE;
        case "LINES_BUNDLE":
          return ServiceType.LINES_BUNDLE;
        case "LOCATION_BUNDLE":
          return ServiceType.LOCATION_BUNDLE;
        case "PBX_TRUNK_BUNDLE":
          return ServiceType.PBX_TRUNK_BUNDLE;
        case "LOCAL_FEATURE_CHARGE_BUNDLE":
          return ServiceType.LOCAL_FEATURE_CHARGE_BUNDLE;
        case "CENTREX_EXTENSION_BUNDLE":
          return ServiceType.CENTREX_EXTENSION_BUNDLE;
        case "PBX_EXTENSION_BUNDLE":
          return ServiceType.PBX_EXTENSION_BUNDLE;
        case "CENTREX_TRUNK_BUNDLE":
          return ServiceType.CENTREX_TRUNK_BUNDLE;
        case "INVOICE_BUNDLE":
          return ServiceType.INVOICE_BUNDLE;
        case "HIGH_CAPACITY_TRUNK_BUNDLE":
          return ServiceType.HIGH_CAPACITY_TRUNK_BUNDLE;
        case "NO_PICK_PICC_BUNDLE":
          return ServiceType.NO_PICK_PICC_BUNDLE;
        case "PICC_BUNDLE":
          return ServiceType.PICC_BUNDLE;
        case "ACCESS_NUMBER":
          return ServiceType.ACCESS_NUMBER;
        case "INTERSTATE_ACCESS_CHARGE":
          return ServiceType.INTERSTATE_ACCESS_CHARGE;
        case "INTRASTATE_ACCESS_CHARGE":
          return ServiceType.INTRASTATE_ACCESS_CHARGE;
        case "INTERSTATE_ROAMING":
          return ServiceType.INTERSTATE_ROAMING;
        case "INTRASTATE_ROAMING":
          return ServiceType.INTRASTATE_ROAMING;
        case "SALES_TAX_AND_FUSF":
          return ServiceType.SALES_TAX_AND_FUSF;
          // END New Service Types Added 05-31-2007
        default:
          return -1; /* We do not expect this condition to occur. we should have validated this pair beforehand. */
      }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="strState"></param>
    /// <returns></returns>
    public static short GetEZTaxStateConst(string strState)
    {
      switch (strState.ToUpper())
      {
        case "ALABAMA":
          return State.Alabama;
        case "ALASKA":
          return State.Alaska;
        case "ARIZONA":
          return State.Arizona;
        case "ARKANSAS":
          return State.Arkansas;
        case "CALIFORNIA":
          return State.California;
        case "COLORADO":
          return State.Colorado;
        case "CONNECTICUT":
          return State.Connecticut;
        case "DELAWARE":
          return State.Delaware;
        case "DISTRICT OF COLUMBIA":
          return State.District_of_Columbia;
        case "FLORIDA":
          return State.Florida;
        case "GEORGIA":
          return State.Georgia;
        case "HAWAII":
          return State.Hawaii;
        case "IDAHO":
          return State.Idaho;
        case "ILLINOIS":
          return State.Illinois;
        case "INDIANA":
          return State.Indiana;
        case "IOWA":
          return State.Iowa;
        case "KANSAS":
          return State.Kansas;
        case "KENTUCKY":
          return State.Kentucky;
        case "LOUISIANA":
          return State.Louisiana;
        case "MAINE":
          return State.Maine;
        case "MARYLAND":
          return State.Maryland;
        case "MASSACHUSETTS":
          return State.Massachusetts;
        case "MICHIGAN":
          return State.Michigan;
        case "MINNESOTA":
          return State.Minnesota;
        case "MISSISSIPPI":
          return State.Mississippi;
        case "MISSOURI":
          return State.Missouri;
        case "MONTANA":
          return State.Montana;
        case "NEBRASKA":
          return State.Nebraska;
        case "NEVADA":
          return State.Nevada;
        case "NEW HAMPSHIRE":
          return State.New_Hampshire;
        case "NEW JERSEY":
          return State.New_Jersey;
        case "NEW MEXICO":
          return State.New_Mexico;
        case "NEW YORK":
          return State.New_York;
        case "NORTH CAROLINA":
          return State.North_Carolina;
        case "NORTH DAKOTA":
          return State.North_Dakota;
        case "OHIO":
          return State.Ohio;
        case "OKLAHOMA":
          return State.Oklahoma;
        case "OREGON":
          return State.Oregon;
        case "PENNSYLVANIA":
          return State.Pennsylvania;
        case "RHODE ISLAND":
          return State.Rhode_Island;
        case "SOUTH CAROLINA":
          return State.South_Carolina;
        case "SOUTH DAKOTA":
          return State.South_Dakota;
        case "TENNESSEE":
          return State.Tennessee;
        case "TEXAS":
          return State.Texas;
        case "UTAH":
          return State.Utah;
        case "VERMONT":
          return State.Vermont;
        case "VIRGINIA":
          return State.Virginia;
        case "WASHINGTON":
          return State.Washington;
        case "WEST VIRGINIA":
          return State.West_Virginia;
        case "WISCONSIN":
          return State.Wisconsin;
        case "WYOMING":
          return State.Wyoming;
          /* Canadian Provinces */
        case "ALBERTA":
          return State.Alberta;
        case "BRITISH COLUMBIA":
          return State.British_Columbia;
        case "MANITOBA":
          return State.Manitoba;
        case "NEW BRUNSWICK":
          return State.New_Brunswick;
        case "NEWFOUNDLAND AND LABRADOR":
          return State.Newfoundland;
        case "NORTHWEST TERRITORIES":
          return State.Northwest_Territories;
        case "NOVA SCOTIA":
          return State.Nova_Scotia;
        case "NUNAVUT":
          return (-1); // NO_STATE has been removed
        case "ONTARIO":
          return State.Ontario;
        case "PRINCE EDWARD ISLAND":
          return State.Prince_Edward_Island;
        case "QUEBEC":
          return State.Quebec;
        case "SASKATCHEWAN":
          return State.Saskatchewan;
        case "YUKON":
          return State.Yukon_Territory;
        default:
          return (-1); // NO_STATE has been removed
      }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="strTaxType"></param>
    /// <returns></returns>
    public static short GetEZTaxType(string strTaxType)
    {
      switch (strTaxType)
      {
        case "SALES_TAX":
          return TaxType.SALES_TAX;
        case "BUSINESS_OCCUPATION_TAX":
          return TaxType.BUSINESS_OCCUPATION_TAX;
        case "CARRIER_GROSS_RECEIPTS":
          return TaxType.CARRIER_GROSS_RECEIPTS;
        case "DISTRICT_TAX":
          return TaxType.DISTRICT_TAX;
        case "EXCISE_TAX":
          return TaxType.EXCISE_TAX;
        case "FEDERAL_EXCISE":
          return TaxType.FEDERAL_EXCISE;
        case "FED_USF_SCHOOL_A":
          return TaxType.FED_USF_SCHOOL_A;
        case "LICENSE_TAX":
          return TaxType.LICENSE_TAX;
        case "PUC_FEE":
          return TaxType.PUC_FEE;
        case "E911_TAX":
          return TaxType.E911_TAX;
        case "SERVICE_TAX":
          return TaxType.SERVICE_TAX;
        case "SPECIAL_TAX":
          return TaxType.SPECIAL_TAX;
        case "STATE_USF":
          return TaxType.STATE_USF;
        case "STATUTORY_GROSS_RECEIPTS":
          return TaxType.STATUTORY_GROSS_RECEIPTS;
        case "SURCHARGE":
          return TaxType.SURCHARGE;
        case "UTILITY_USERS_TAX":
          return TaxType.UTILITY_USERS_TAX;
        case "SALES_WEB_HOSTING":
          return TaxType.SALES_WEB_HOSTING;
        case "FED_USF_HIGHCOST_B":
          return TaxType.FED_USF_HIGHCOST_B;
        case "STATE_HIGH_COST_FUND":
          return TaxType.STATE_HIGH_COST_FUND;
        case "STATE_DEAF_DISABLED_FUND":
          return TaxType.STATE_DEAF_DISABLED_FUND;
        case "CA_TELECONNECT_FUND":
          return TaxType.CA_TELECONNECT_FUND;
        case "UNIVERSAL_LIFELINE_TELEPHONE_SERVICE_CHARGE":
          return TaxType.UNIVERSAL_LIFELINE_TELEPHONE_SERVICE_CHARGE;
        case "TELECOMMUNICATIONS_RELAY_SERVICE_CHARGE":
          return TaxType.TELECOMMUNICATIONS_RELAY_SERVICE_CHARGE;
        case "TELECOMMUNICATIONS_INFRASTRUCTURE_MAINTENANCE_FEE":
          return TaxType.TELECOMMUNICATIONS_INFRASTRUCTURE_MAINTENANCE_FEE;
        case "POISON_CONTROL_FUND":
          return TaxType.POISON_CONTROL_FUND;
        case "TELCOMMUNICATIONS_INFRASTRUCTURE_FUND":
          return TaxType.TELCOMMUNICATIONS_INFRASTRUCTURE_FUND;
        case "NY_MCTD_186c":
          return TaxType.NY_MCTD_186c;
        case "NY_MCTD_184a":
          return TaxType.NY_MCTD_184a;
        case "FRANCHISE_TAX":
          return TaxType.FRANCHISE_TAX;
        case "UTILITY_USERS_TAX_BUSINESS":
          return TaxType.UTILITY_USERS_TAX_BUSINESS;
        case "FED_TELECOMMUNICATIONS_RELAY_SERVICE":
          return TaxType.FED_TELECOMMUNICATIONS_RELAY_SERVICE;
        case "DISTRICT_TAX_RESIDENTIAL_ONLY":
          return TaxType.DISTRICT_TAX_RESIDENTIAL_ONLY;
        case "TRANSIT_TAX":
          return TaxType.TRANSIT_TAX;
        case "TELECOMMUNICATIONS_ASSISTANCE_SERVICE_FUND":
          return TaxType.TELECOMMUNICATIONS_ASSISTANCE_SERVICE_FUND;
        case "E911_BUSINESS":
          return TaxType.E911_BUSINESS;
        case "TRS_BUSINESS":
          return TaxType.TRS_BUSINESS;
        case "UNIVERSAL_SERVICE_FUND_LINE":
          return TaxType.UNIVERSAL_SERVICE_FUND_LINE;
        case "UNIVERSAL_SERVICE_FUND_BUSINESS_LINE":
          return TaxType.UNIVERSAL_SERVICE_FUND_BUSINESS_LINE;
        case "E911_TAX_PBX_TRUNK_LINE":
          return TaxType.E911_TAX_PBX_TRUNK_LINE;
        case "LICENSE_TAX_BUSINESS":
          return TaxType.LICENSE_TAX_BUSINESS;
        case "OPTIONAL_TIMF":
          return TaxType.OPTIONAL_TIMF;
        case "SALES_TAX_BUSINESS":
          return TaxType.SALES_TAX_BUSINESS;
        case "E911_TAX_RESIDENTIAL":
          return TaxType.E911_TAX_RESIDENTIAL;
        case "E911_TAX_WIRELESS":
          return TaxType.E911_TAX_WIRELESS;
        case "NY_FRANCHISE_184":
          return TaxType.NY_FRANCHISE_184;
        case "NY_FRANCHISE_184_USAGE":
          return TaxType.NY_FRANCHISE_184_USAGE;
        case "NY_MCTD_184a_USAGE":
          return TaxType.NY_MCTD_184a_USAGE;
        case "UNIVERSAL_SERVICE_FUND_WIRELESS":
          return TaxType.UNIVERSAL_SERVICE_FUND_WIRELESS;
        case "USE_TAX":
          return TaxType.USE_TAX;
        case "SALES_TAX_DATA":
          return TaxType.SALES_TAX_DATA;
        case "MUNICIPAL_RIGHT_OF_WAY_RESIDENTIAL":
          return TaxType.MUNICIPAL_RIGHT_OF_WAY_RESIDENTIAL;
        case "MUNICIPAL_RIGHT_OF_WAY_BUSINESS":
          return TaxType.MUNICIPAL_RIGHT_OF_WAY_BUSINESS;
        case "MUNICIPAL_RIGHT_OF_WAY_PRIVATE_LINE":
          return TaxType.MUNICIPAL_RIGHT_OF_WAY_PRIVATE_LINE;
        case "UTILITY_USERS_TAX_WIRELESS":
          return TaxType.UTILITY_USERS_TAX_WIRELESS;
        case "FED_USF_CELLULAR":
          return TaxType.FED_USF_CELLULAR;
        case "FED_USF_PAGING":
          return TaxType.FED_USF_PAGING;
        case "SALES_TAX_INTERSTATE":
          return TaxType.SALES_TAX_INTERSTATE;
        case "UTILITY_USERS_TAX_PBX_TRUNK":
          return TaxType.UTILITY_USERS_TAX_PBX_TRUNK;
        case "DISTRICT_TAX_WEB_HOSTING":
          return TaxType.DISTRICT_TAX_WEB_HOSTING;
        case "CA_HIGH_COST_FUND_A":
          return TaxType.CA_HIGH_COST_FUND_A;
        case "TELECOMMUNICATIONS_EDUCATION_ACCESS_FUND":
          return TaxType.TELECOMMUNICATIONS_EDUCATION_ACCESS_FUND;
        case "FED_TRS_CELLULAR":
          return TaxType.FED_TRS_CELLULAR;
        case "FED_TRS_PAGING":
          return TaxType.FED_TRS_PAGING;
        case "COMMUNICATIONS_SERVICES_TAX":
          return TaxType.COMMUNICATIONS_SERVICES_TAX;
        case "VALUE_ADDED_TAX":
          return TaxType.VALUE_ADDED_TAX;
        case "GOODS_SERVICE_TAX":
          return TaxType.GOODS_SERVICE_TAX;
        case "HARMONIZED_SALES_TAX":
          return TaxType.HARMONIZED_SALES_TAX;
        case "PROVINCIAL_SALES_TAX":
          return TaxType.PROVINCIAL_SALES_TAX;
        case "QUEBEC_SALES_TAX":
          return TaxType.QUEBEC_SALES_TAX;
        case "NATIONAL_CONTRIBUTION_REGIME":
          return TaxType.NATIONAL_CONTRIBUTION_REGIME;
        case "UTILITY_USERS_TAX_CABLE_TELEVISION":
          return TaxType.UTILITY_USERS_TAX_CABLE_TELEVISION;
        case "FCC_REGULATORY_FEE":
          return TaxType.FCC_REGULATORY_FEE;
        case "FRANCHISE_TAX_CABLE":
          return TaxType.FRANCHISE_TAX_CABLE;
        case "UNIVERSAL_SERVICE_FUND_PAGING":
          return TaxType.UNIVERSAL_SERVICE_FUND_PAGING;
        case "STATUTORY_GROSS_RECEIPTS_WIRELESS":
          return TaxType.STATUTORY_GROSS_RECEIPTS_WIRELESS;
        case "SGT_E911":
          return TaxType.SGT_E911;
        case "SGT_E911_BUSINESS":
          return TaxType.SGT_E911_BUSINESS;
        case "SGT_E911_TAX_PBX_TRUNK_LINE":
          return TaxType.SGT_E911_TAX_PBX_TRUNK_LINE;
        case "SGT_E911_TAX_RESIDENTIAL":
          return TaxType.SGT_E911_TAX_RESIDENTIAL;
        case "SGT_E911_TAX_WIRELESS":
          return TaxType.SGT_E911_TAX_WIRELESS;
        case "SGT_E911_LICENSE_TAX":
          return TaxType.SGT_E911_LICENSE_TAX;
        case "FRANCISE_TAX_WIRELESS":
          return TaxType.FRANCISE_TAX_WIRELESS;
        case "FEDERAL_USF_ALTERNATE":
          return TaxType.FEDERAL_USF_ALTERNATE;
        case "PEG_ACCESS_FEE":
          return TaxType.PEG_ACCESS_FEE;
        case "COMMUNICATIONS_SERVICE_TAX_SATELLITE":
          return TaxType.COMMUNICATIONS_SERVICE_TAX_SATELLITE;
        case "FRANCHISE_TAX_SATELLITE":
          return TaxType.FRANCHISE_TAX_SATELLITE;
        case "CARRIER_COST_RECOVERY":
          return TaxType.CARRIER_COST_RECOVERY;
        case "FEDERAL_TRS_ALTERNATE":
          return TaxType.FEDERAL_TRS_ALTERNATE;
        case "TRS_CENTREX":
          return TaxType.TRS_CENTREX;
        case "UTILITY_USERS_TAX_CABLE_TELEVISION_BUSINESS":
          return TaxType.UTILITY_USERS_TAX_CABLE_TELEVISION_BUSINESS;
        case "UTILITY_USERS_TAX_CENTREX":
          return TaxType.UTILITY_USERS_TAX_CENTREX;
        case "E911_TAX_CENTREX":
          return TaxType.E911_TAX_CENTREX;
        case "UTILITY_USERS_TAX_LINE":
          return TaxType.UTILITY_USERS_TAX_LINE;
        case "CRIME_CONTROL_DISTRICT_TAX":
          return TaxType.CRIME_CONTROL_DISTRICT_TAX;
        case "LIBRARY_DISTRICT_TAX":
          return TaxType.LIBRARY_DISTRICT_TAX;
        case "HOSPITAL_DISTRICT_TAX":
          return TaxType.HOSPITAL_DISTRICT_TAX;
        case "HEALTH_SERVICES_DISTRICT_TAX":
          return TaxType.HEALTH_SERVICES_DISTRICT_TAX;
        case "EMERGENCY_SERVICES_DISTRICT_TAX":
          return TaxType.EMERGENCY_SERVICES_DISTRICT_TAX;
        case "IMPROVEMENT_DISTRICT_TAX":
          return TaxType.IMPROVEMENT_DISTRICT_TAX;
        case "DEVELOPMENT_DISTRICT_TAX":
          return TaxType.DEVELOPMENT_DISTRICT_TAX;
        case "TRANSIT_WEB_HOSTING_TAX":
          return TaxType.TRANSIT_WEB_HOSTING_TAX;
        case "AMBULANCE_DISTRICT_TAX":
          return TaxType.AMBULANCE_DISTRICT_TAX;
        case "FIRE_DISTRICT_TAX":
          return TaxType.FIRE_DISTRICT_TAX;
        case "POLICE_DISTRICT_TAX":
          return TaxType.POLICE_DISTRICT_TAX;
        case "FOOTBALL_DISTRICT_TAX":
          return TaxType.FOOTBALL_DISTRICT_TAX;
        case "BASEBALL_DISTRICT_TAX":
          return TaxType.BASEBALL_DISTRICT_TAX;
        case "CRIME_CONTROL_DISTRICT_WEB_HOSTING_TAX":
          return TaxType.CRIME_CONTROL_DISTRICT_WEB_HOSTING_TAX;
        case "LIBRARY_DISTRICT_WEB_HOSTING_TAX":
          return TaxType.LIBRARY_DISTRICT_WEB_HOSTING_TAX;
        case "HOSPITAL_DISTRICT_WEB_HOSTING_TAX":
          return TaxType.HOSPITAL_DISTRICT_WEB_HOSTING_TAX;
        case "HEALTH_SERVICES_DISTRICT_WEB_HOSTING_TAX":
          return TaxType.HEALTH_SERVICES_DISTRICT_WEB_HOSTING_TAX;
        case "EMERGENCY_SERVICES_DISTRICT_WEB_HOSTING_TAX":
          return TaxType.EMERGENCY_SERVICES_DISTRICT_WEB_HOSTING_TAX;
        case "IMPROVEMENT_DISTRICT_WEB_HOSTING_TAX":
          return TaxType.IMPROVEMENT_DISTRICT_WEB_HOSTING_TAX;
        case "DEVELOPMENT_DISTRICT_WEB_HOSTING_TAX":
          return TaxType.DEVELOPMENT_DISTRICT_WEB_HOSTING_TAX;
        case "UTILITY_USERS_TAX_INTERSTATE":
          return TaxType.UTILITY_USERS_TAX_INTERSTATE;
        case "UTILITY_USERS_TAX_TELEGRAPH":
          return TaxType.UTILITY_USERS_TAX_TELEGRAPH;
        case "E911_NETWORK_AND_DATABASE_SURCHARGE":
          return TaxType.E911_NETWORK_AND_DATABASE_SURCHARGE;
        case "LICENSE_TAX_EMERGENCY":
          return TaxType.LICENSE_TAX_EMERGENCY;
        case "LICENSE_TAX_EMERGENCY_BUSINESS":
          return TaxType.LICENSE_TAX_EMERGENCY_BUSINESS;
        case "EDUCATIONAL_SALES_TAX":
          return TaxType.EDUCATIONAL_SALES_TAX;
        case "EDUCATIONAL_USE_TAX":
          return TaxType.EDUCATIONAL_USE_TAX;
        case "E911_OPERATIONAL_SURCHARGE_COUNTY_COMMISSION":
          return TaxType.E911_OPERATIONAL_SURCHARGE_COUNTY_COMMISSION;
        case "E911_OPERATIONAL_SURCHARGE_VOTER_APPROVED":
          return TaxType.E911_OPERATIONAL_SURCHARGE_VOTER_APPROVED;
        case "SALES_TAX_NINE_HUNDRED":
          return TaxType.SALES_TAX_NINE_HUNDRED;
        case "CONVENTION_CENTER_TAX":
          return TaxType.CONVENTION_CENTER_TAX;
        case "E911_HIGH_CAPACITY_TRUNK":
          return TaxType.E911_HIGH_CAPACITY_TRUNK;
        case "SCHOOL_BOARD_TAX_A":
          return TaxType.SCHOOL_BOARD_TAX_A;
        case "SCHOOL_BOARD_TAX_B":
          return TaxType.SCHOOL_BOARD_TAX_B;
        case "SCHOOL_BOARD_TAX_C":
          return TaxType.SCHOOL_BOARD_TAX_C;
        case "SCHOOL_BOARD_TAX_D":
          return TaxType.SCHOOL_BOARD_TAX_D;
        case "SCHOOL_BOARD_TAX_E":
          return TaxType.SCHOOL_BOARD_TAX_E;
        case "SCHOOL_BOARD_TAX_F":
          return TaxType.SCHOOL_BOARD_TAX_F;
        case "SCHOOL_DISTRICT_TAX":
          return TaxType.SCHOOL_DISTRICT_TAX;
        case "POLICE_JURY_TAX_B":
          return TaxType.POLICE_JURY_TAX_B;
        case "POLICE_JURY_TAX_C":
          return TaxType.POLICE_JURY_TAX_C;
        case "POLICE_JURY_TAX_E":
          return TaxType.POLICE_JURY_TAX_E;
        case "COMMUNICATIONS_SERVICE_TAX_WIRELESS":
          return TaxType.COMMUNICATIONS_SERVICE_TAX_WIRELESS;
        case "SERVICE_PROVIDER_TAX":
          return TaxType.SERVICE_PROVIDER_TAX;
        case "TELECOMMUNICATIONS_SALES_TAX":
          return TaxType.TELECOMMUNICATIONS_SALES_TAX;
        case "ADVANCED_TRANSIT_TAX":
          return TaxType.ADVANCED_TRANSIT_TAX;
        case "ADVANCED_TRANSIT_WEB_HOSTING_TAX":
          return TaxType.ADVANCED_TRANSIT_WEB_HOSTING_TAX;
        case "MISSOURI_UNIVERSAL_SERVICE_FUND":
          return TaxType.MISSOURI_UNIVERSAL_SERVICE_FUND;
        case "BUSINESS_OCCUPATION_TAX_WHOLESALE":
          return TaxType.BUSINESS_OCCUPATION_TAX_WHOLESALE;
        case "TELECOMMUNICATIONS_EDUCATION_ACCESS_FUND_CENTREX":
          return TaxType.TELECOMMUNICATIONS_EDUCATION_ACCESS_FUND_CENTREX;
        case "BUSINESS_OCCUPATION_TAX_OTHER":
          return TaxType.BUSINESS_OCCUPATION_TAX_OTHER;
        case "TRIBAL_SALES_TAX":
          return TaxType.TRIBAL_SALES_TAX;
        case "SALES_TAX_DATA_PROCESSING":
          return TaxType.SALES_TAX_DATA_PROCESSING;
        case "TRANSIT_TAX_DATA_PROCESSING":
          return TaxType.TRANSIT_TAX_DATA_PROCESSING;
        case "CRIME_CONTROL_DISTRICT_TAX_DATA_PROCESSING":
          return TaxType.CRIME_CONTROL_DISTRICT_TAX_DATA_PROCESSING;
        case "LIBRARY_DISTRICT_TAX_DATA_PROCESSING":
          return TaxType.LIBRARY_DISTRICT_TAX_DATA_PROCESSING;
        case "HOSPITAL_DISTRICT_TAX_DATA_PROCESSING":
          return TaxType.HOSPITAL_DISTRICT_TAX_DATA_PROCESSING;
        case "HEALTH_SERVICES_DISTRICT_TAX_DATA_PROCESSING":
          return TaxType.HEALTH_SERVICES_DISTRICT_TAX_DATA_PROCESSING;
        case "EMERGENCY_SERVICES_DISTRICT_TAX_DATA_PROCESSING":
          return TaxType.EMERGENCY_SERVICES_DISTRICT_TAX_DATA_PROCESSING;
        case "IMPROVEMENT_DISTRICT_TAX_DATA_PROCESSING":
          return TaxType.IMPROVEMENT_DISTRICT_TAX_DATA_PROCESSING;
        case "DEVELOPMENT_DISTRICT_TAX_DATA_PROCESSING":
          return TaxType.DEVELOPMENT_DISTRICT_TAX_DATA_PROCESSING;
        case "ADVANCED_TRANSIT_TAX_DATA_PROCESSING":
          return TaxType.ADVANCED_TRANSIT_TAX_DATA_PROCESSING;
        case "CA_PSPE_SURCHARGE":
          return TaxType.CA_PSPE_SURCHARGE;
        case "DISTRICT_TAX_DATA_PROCESSING":
          return TaxType.DISTRICT_TAX_DATA_PROCESSING;
        case "RESERVED_158":
          return TaxType.RESERVED_158;
        case "CABLE_FRANCHISE_FEE":
          return TaxType.CABLE_FRANCHISE_FEE;
        case "STATUTORY_GROSS_RECEIPTS_BUSINESS":
          return TaxType.STATUTORY_GROSS_RECEIPTS_BUSINESS;
        case "E911_VOIP":
          return TaxType.E911_VOIP;
        case "FUSF_VOIP":
          return TaxType.FUSF_VOIP;
        case "FUSF":
          return TaxType.FUSF;
        case "COST_RECOVERY_SURCHARGE":
          return TaxType.COST_RECOVERY_SURCHARGE;
        case "STATE_USF_VOIP":
          return TaxType.STATE_USF_VOIP;
        case "COMMUNICATIONS_SERVICES_TAX_CABLE":
          return TaxType.COMMUNICATIONS_SERVICES_TAX_CABLE;
        case "MUNICIPAL_RIGHT_OF_WAY_CABLE":
          return TaxType.MUNICIPAL_RIGHT_OF_WAY_CABLE;
        case "FCC_REGULATORY_FEE_WIRELINE":
          return TaxType.FCC_REGULATORY_FEE_WIRELINE;
        case "FCC_REGULATORY_FEE_WIRELESS":
          return TaxType.FCC_REGULATORY_FEE_WIRELESS;
        case "TELECOMM_SALE_TAX":
          return TaxType.TELECOMM_SALE_TAX;
          // New tax types added 04-30-2007
        case "STATUTORY_GROSS_RECEIPTS_VIDEO":
          return TaxType.STATUTORY_GROSS_RECEIPTS_VIDEO;
        case "UTILITY_USERS_TAX_LIFELINE":
          return TaxType.UTILITY_USERS_TAX_LIFELINE;
        case "TRS_LONG_DISTANCE":
          return TaxType.TRS_LONG_DISTANCE;
        case "TRS_WIRELESS":
          return TaxType.TRS_WIRELESS;
        case "SALES_TAX_SENIOR_CITIZEN":
          return TaxType.SALES_TAX_SENIOR_CITIZEN;
        case "REGULATORY_COST_CHARGE_LOCAL":
          return TaxType.REGULATORY_COST_CHARGE_LOCAL;
        case "REGULATORY_COST_CHARGE_INTRASTATE":
          return TaxType.REGULATORY_COST_CHARGE_INTRASTATE;
        case "REGULATORY_COST_CHARGE_CABLE":
          return TaxType.REGULATORY_COST_CHARGE_CABLE;
        case "PUC_FEE_CABLE":
          return TaxType.PUC_FEE_CABLE;
        case "PROVINCIAL_SALES_TAX_TOLL":
          return TaxType.PROVINCIAL_SALES_TAX_TOLL;
          // END New tax types added 04-30-2007
        default:
          return 0;
      }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="iTaxType"></param>
    /// <returns></returns>
    public static string GetEZTaxType(short iTaxType)
    {
      switch (iTaxType)
      {
        case TaxType.SALES_TAX:
          return "SALES_TAX";
        case TaxType.BUSINESS_OCCUPATION_TAX:
          return "BUSINESS_OCCUPATION_TAX";
        case TaxType.CARRIER_GROSS_RECEIPTS:
          return "CARRIER_GROSS_RECEIPTS";
        case TaxType.DISTRICT_TAX:
          return "DISTRICT_TAX";
        case TaxType.EXCISE_TAX:
          return "EXCISE_TAX";
        case TaxType.FEDERAL_EXCISE:
          return "FEDERAL_EXCISE";
        case TaxType.FED_USF_SCHOOL_A:
          return "FED_USF_SCHOOL_A";
        case TaxType.LICENSE_TAX:
          return "LICENSE_TAX";
        case TaxType.PUC_FEE:
          return "PUC_FEE";
        case TaxType.E911_TAX:
          return "E911_TAX";
        case TaxType.SERVICE_TAX:
          return "SERVICE_TAX";
        case TaxType.SPECIAL_TAX:
          return "SPECIAL_TAX";
        case TaxType.STATE_USF:
          return "STATE_USF";
        case TaxType.STATUTORY_GROSS_RECEIPTS:
          return "STATUTORY_GROSS_RECEIPTS";
        case TaxType.SURCHARGE:
          return "SURCHARGE";
        case TaxType.UTILITY_USERS_TAX:
          return "UTILITY_USERS_TAX";
        case TaxType.SALES_WEB_HOSTING:
          return "SALES_WEB_HOSTING";
        case TaxType.FED_USF_HIGHCOST_B:
          return "FED_USF_HIGHCOST_B";
        case TaxType.STATE_HIGH_COST_FUND:
          return "STATE_HIGH_COST_FUND";
        case TaxType.STATE_DEAF_DISABLED_FUND:
          return "STATE_DEAF_DISABLED_FUND";
        case TaxType.CA_TELECONNECT_FUND:
          return "CA_TELECONNECT_FUND";
        case TaxType.UNIVERSAL_LIFELINE_TELEPHONE_SERVICE_CHARGE:
          return "UNIVERSAL_LIFELINE_TELEPHONE_SERVICE_CHARGE";
        case TaxType.TELECOMMUNICATIONS_RELAY_SERVICE_CHARGE:
          return "TELECOMMUNICATIONS_RELAY_SERVICE_CHARGE";
        case TaxType.TELECOMMUNICATIONS_INFRASTRUCTURE_MAINTENANCE_FEE:
          return "TELECOMMUNICATIONS_INFRASTRUCTURE_MAINTENANCE_FEE";
        case TaxType.POISON_CONTROL_FUND:
          return "POISON_CONTROL_FUND";
        case TaxType.TELCOMMUNICATIONS_INFRASTRUCTURE_FUND:
          return "TELCOMMUNICATIONS_INFRASTRUCTURE_FUND";
        case TaxType.NY_MCTD_186c:
          return "NY_MCTD_186c";
        case TaxType.NY_MCTD_184a:
          return "NY_MCTD_184a";
        case TaxType.FRANCHISE_TAX:
          return "FRANCHISE_TAX";
        case TaxType.UTILITY_USERS_TAX_BUSINESS:
          return "UTILITY_USERS_TAX_BUSINESS";
        case TaxType.FED_TELECOMMUNICATIONS_RELAY_SERVICE:
          return "FED_TELECOMMUNICATIONS_RELAY_SERVICE";
        case TaxType.DISTRICT_TAX_RESIDENTIAL_ONLY:
          return "DISTRICT_TAX_RESIDENTIAL_ONLY";
        case TaxType.TRANSIT_TAX:
          return "TRANSIT_TAX";
        case TaxType.TELECOMMUNICATIONS_ASSISTANCE_SERVICE_FUND:
          return "TELECOMMUNICATIONS_ASSISTANCE_SERVICE_FUND";
        case TaxType.E911_BUSINESS:
          return "E911_BUSINESS";
        case TaxType.TRS_BUSINESS:
          return "TRS_BUSINESS";
        case TaxType.UNIVERSAL_SERVICE_FUND_LINE:
          return "UNIVERSAL_SERVICE_FUND_LINE";
        case TaxType.UNIVERSAL_SERVICE_FUND_BUSINESS_LINE:
          return "UNIVERSAL_SERVICE_FUND_BUSINESS_LINE";
        case TaxType.E911_TAX_PBX_TRUNK_LINE:
          return "E911_TAX_PBX_TRUNK_LINE";
        case TaxType.LICENSE_TAX_BUSINESS:
          return "LICENSE_TAX_BUSINESS";
        case TaxType.OPTIONAL_TIMF:
          return "OPTIONAL_TIMF";
        case TaxType.SALES_TAX_BUSINESS:
          return "SALES_TAX_BUSINESS";
        case TaxType.E911_TAX_RESIDENTIAL:
          return "E911_TAX_RESIDENTIAL";
        case TaxType.E911_TAX_WIRELESS:
          return "E911_TAX_WIRELESS";
        case TaxType.NY_FRANCHISE_184:
          return "NY_FRANCHISE_184";
        case TaxType.NY_FRANCHISE_184_USAGE:
          return "NY_FRANCHISE_184_USAGE";
        case TaxType.NY_MCTD_184a_USAGE:
          return "NY_MCTD_184a_USAGE";
        case TaxType.UNIVERSAL_SERVICE_FUND_WIRELESS:
          return "UNIVERSAL_SERVICE_FUND_WIRELESS";
        case TaxType.USE_TAX:
          return "USE_TAX";
        case TaxType.SALES_TAX_DATA:
          return "SALES_TAX_DATA";
        case TaxType.MUNICIPAL_RIGHT_OF_WAY_RESIDENTIAL:
          return "MUNICIPAL_RIGHT_OF_WAY_RESIDENTIAL";
        case TaxType.MUNICIPAL_RIGHT_OF_WAY_BUSINESS:
          return "MUNICIPAL_RIGHT_OF_WAY_BUSINESS";
        case TaxType.MUNICIPAL_RIGHT_OF_WAY_PRIVATE_LINE:
          return "MUNICIPAL_RIGHT_OF_WAY_PRIVATE_LINE";
        case TaxType.UTILITY_USERS_TAX_WIRELESS:
          return "UTILITY_USERS_TAX_WIRELESS";
        case TaxType.FED_USF_CELLULAR:
          return "FED_USF_CELLULAR";
        case TaxType.FED_USF_PAGING:
          return "FED_USF_PAGING";
        case TaxType.SALES_TAX_INTERSTATE:
          return "SALES_TAX_INTERSTATE";
        case TaxType.UTILITY_USERS_TAX_PBX_TRUNK:
          return "UTILITY_USERS_TAX_PBX_TRUNK";
        case TaxType.DISTRICT_TAX_WEB_HOSTING:
          return "DISTRICT_TAX_WEB_HOSTING";
        case TaxType.CA_HIGH_COST_FUND_A:
          return "CA_HIGH_COST_FUND_A";
        case TaxType.TELECOMMUNICATIONS_EDUCATION_ACCESS_FUND:
          return "TELECOMMUNICATIONS_EDUCATION_ACCESS_FUND";
        case TaxType.FED_TRS_CELLULAR:
          return "FED_TRS_CELLULAR";
        case TaxType.FED_TRS_PAGING:
          return "FED_TRS_PAGING";
        case TaxType.COMMUNICATIONS_SERVICES_TAX:
          return "COMMUNICATIONS_SERVICES_TAX";
        case TaxType.VALUE_ADDED_TAX:
          return "VALUE_ADDED_TAX";
        case TaxType.GOODS_SERVICE_TAX:
          return "GOODS_SERVICE_TAX";
        case TaxType.HARMONIZED_SALES_TAX:
          return "HARMONIZED_SALES_TAX";
        case TaxType.PROVINCIAL_SALES_TAX:
          return "PROVINCIAL_SALES_TAX";
        case TaxType.QUEBEC_SALES_TAX:
          return "QUEBEC_SALES_TAX";
        case TaxType.NATIONAL_CONTRIBUTION_REGIME:
          return "NATIONAL_CONTRIBUTION_REGIME";
        case TaxType.UTILITY_USERS_TAX_CABLE_TELEVISION:
          return "UTILITY_USERS_TAX_CABLE_TELEVISION";
        case TaxType.FCC_REGULATORY_FEE:
          return "FCC_REGULATORY_FEE";
        case TaxType.FRANCHISE_TAX_CABLE:
          return "FRANCHISE_TAX_CABLE";
        case TaxType.UNIVERSAL_SERVICE_FUND_PAGING:
          return "UNIVERSAL_SERVICE_FUND_PAGING";
        case TaxType.STATUTORY_GROSS_RECEIPTS_WIRELESS:
          return "STATUTORY_GROSS_RECEIPTS_WIRELESS";
        case TaxType.SGT_E911:
          return "SGT_E911";
        case TaxType.SGT_E911_BUSINESS:
          return "SGT_E911_BUSINESS";
        case TaxType.SGT_E911_TAX_PBX_TRUNK_LINE:
          return "SGT_E911_TAX_PBX_TRUNK_LINE";
        case TaxType.SGT_E911_TAX_RESIDENTIAL:
          return "SGT_E911_TAX_RESIDENTIAL";
        case TaxType.SGT_E911_TAX_WIRELESS:
          return "SGT_E911_TAX_WIRELESS";
        case TaxType.SGT_E911_LICENSE_TAX:
          return "SGT_E911_LICENSE_TAX";
        case TaxType.FRANCISE_TAX_WIRELESS:
          return "FRANCISE_TAX_WIRELESS";
        case TaxType.FEDERAL_USF_ALTERNATE:
          return "FEDERAL_USF_ALTERNATE";
        case TaxType.PEG_ACCESS_FEE:
          return "PEG_ACCESS_FEE";
        case TaxType.COMMUNICATIONS_SERVICE_TAX_SATELLITE:
          return "COMMUNICATIONS_SERVICE_TAX_SATELLITE";
        case TaxType.FRANCHISE_TAX_SATELLITE:
          return "FRANCHISE_TAX_SATELLITE";
        case TaxType.CARRIER_COST_RECOVERY:
          return "CARRIER_COST_RECOVERY";
        case TaxType.FEDERAL_TRS_ALTERNATE:
          return "FEDERAL_TRS_ALTERNATE";
        case TaxType.TRS_CENTREX:
          return "TRS_CENTREX";
        case TaxType.UTILITY_USERS_TAX_CABLE_TELEVISION_BUSINESS:
          return "UTILITY_USERS_TAX_CABLE_TELEVISION_BUSINESS";
        case TaxType.UTILITY_USERS_TAX_CENTREX:
          return "UTILITY_USERS_TAX_CENTREX";
        case TaxType.E911_TAX_CENTREX:
          return "E911_TAX_CENTREX";
        case TaxType.UTILITY_USERS_TAX_LINE:
          return "UTILITY_USERS_TAX_LINE";
        case TaxType.CRIME_CONTROL_DISTRICT_TAX:
          return "CRIME_CONTROL_DISTRICT_TAX";
        case TaxType.LIBRARY_DISTRICT_TAX:
          return "LIBRARY_DISTRICT_TAX";
        case TaxType.HOSPITAL_DISTRICT_TAX:
          return "HOSPITAL_DISTRICT_TAX";
        case TaxType.HEALTH_SERVICES_DISTRICT_TAX:
          return "HEALTH_SERVICES_DISTRICT_TAX";
        case TaxType.EMERGENCY_SERVICES_DISTRICT_TAX:
          return "EMERGENCY_SERVICES_DISTRICT_TAX";
        case TaxType.IMPROVEMENT_DISTRICT_TAX:
          return "IMPROVEMENT_DISTRICT_TAX";
        case TaxType.DEVELOPMENT_DISTRICT_TAX:
          return "DEVELOPMENT_DISTRICT_TAX";
        case TaxType.TRANSIT_WEB_HOSTING_TAX:
          return "TRANSIT_WEB_HOSTING_TAX";
        case TaxType.AMBULANCE_DISTRICT_TAX:
          return "AMBULANCE_DISTRICT_TAX";
        case TaxType.FIRE_DISTRICT_TAX:
          return "FIRE_DISTRICT_TAX";
        case TaxType.POLICE_DISTRICT_TAX:
          return "POLICE_DISTRICT_TAX";
        case TaxType.FOOTBALL_DISTRICT_TAX:
          return "FOOTBALL_DISTRICT_TAX";
        case TaxType.BASEBALL_DISTRICT_TAX:
          return "BASEBALL_DISTRICT_TAX";
        case TaxType.CRIME_CONTROL_DISTRICT_WEB_HOSTING_TAX:
          return "CRIME_CONTROL_DISTRICT_WEB_HOSTING_TAX";
        case TaxType.LIBRARY_DISTRICT_WEB_HOSTING_TAX:
          return "LIBRARY_DISTRICT_WEB_HOSTING_TAX";
        case TaxType.HOSPITAL_DISTRICT_WEB_HOSTING_TAX:
          return "HOSPITAL_DISTRICT_WEB_HOSTING_TAX";
        case TaxType.HEALTH_SERVICES_DISTRICT_WEB_HOSTING_TAX:
          return "HEALTH_SERVICES_DISTRICT_WEB_HOSTING_TAX";
        case TaxType.EMERGENCY_SERVICES_DISTRICT_WEB_HOSTING_TAX:
          return "EMERGENCY_SERVICES_DISTRICT_WEB_HOSTING_TAX";
        case TaxType.IMPROVEMENT_DISTRICT_WEB_HOSTING_TAX:
          return "IMPROVEMENT_DISTRICT_WEB_HOSTING_TAX";
        case TaxType.DEVELOPMENT_DISTRICT_WEB_HOSTING_TAX:
          return "DEVELOPMENT_DISTRICT_WEB_HOSTING_TAX";
        case TaxType.UTILITY_USERS_TAX_INTERSTATE:
          return "UTILITY_USERS_TAX_INTERSTATE";
        case TaxType.UTILITY_USERS_TAX_TELEGRAPH:
          return "UTILITY_USERS_TAX_TELEGRAPH";
        case TaxType.E911_NETWORK_AND_DATABASE_SURCHARGE:
          return "E911_NETWORK_AND_DATABASE_SURCHARGE";
        case TaxType.LICENSE_TAX_EMERGENCY:
          return "LICENSE_TAX_EMERGENCY";
        case TaxType.LICENSE_TAX_EMERGENCY_BUSINESS:
          return "LICENSE_TAX_EMERGENCY_BUSINESS";
        case TaxType.EDUCATIONAL_SALES_TAX:
          return "EDUCATIONAL_SALES_TAX";
        case TaxType.EDUCATIONAL_USE_TAX:
          return "EDUCATIONAL_USE_TAX";
        case TaxType.E911_OPERATIONAL_SURCHARGE_COUNTY_COMMISSION:
          return "E911_OPERATIONAL_SURCHARGE_COUNTY_COMMISSION";
        case TaxType.E911_OPERATIONAL_SURCHARGE_VOTER_APPROVED:
          return "E911_OPERATIONAL_SURCHARGE_VOTER_APPROVED";
        case TaxType.SALES_TAX_NINE_HUNDRED:
          return "SALES_TAX_NINE_HUNDRED";
        case TaxType.CONVENTION_CENTER_TAX:
          return "CONVENTION_CENTER_TAX";
        case TaxType.E911_HIGH_CAPACITY_TRUNK:
          return "E911_HIGH_CAPACITY_TRUNK";
        case TaxType.SCHOOL_BOARD_TAX_A:
          return "SCHOOL_BOARD_TAX_A";
        case TaxType.SCHOOL_BOARD_TAX_B:
          return "SCHOOL_BOARD_TAX_B";
        case TaxType.SCHOOL_BOARD_TAX_C:
          return "SCHOOL_BOARD_TAX_C";
        case TaxType.SCHOOL_BOARD_TAX_D:
          return "SCHOOL_BOARD_TAX_D";
        case TaxType.SCHOOL_BOARD_TAX_E:
          return "SCHOOL_BOARD_TAX_E";
        case TaxType.SCHOOL_BOARD_TAX_F:
          return "SCHOOL_BOARD_TAX_F";
        case TaxType.SCHOOL_DISTRICT_TAX:
          return "SCHOOL_DISTRICT_TAX";
        case TaxType.POLICE_JURY_TAX_B:
          return "POLICE_JURY_TAX_B";
        case TaxType.POLICE_JURY_TAX_C:
          return "POLICE_JURY_TAX_C";
        case TaxType.POLICE_JURY_TAX_E:
          return "POLICE_JURY_TAX_E";
        case TaxType.COMMUNICATIONS_SERVICE_TAX_WIRELESS:
          return "COMMUNICATIONS_SERVICE_TAX_WIRELESS";
        case TaxType.SERVICE_PROVIDER_TAX:
          return "SERVICE_PROVIDER_TAX";
        case TaxType.TELECOMMUNICATIONS_SALES_TAX:
          return "TELECOMMUNICATIONS_SALES_TAX";
        case TaxType.ADVANCED_TRANSIT_TAX:
          return "ADVANCED_TRANSIT_TAX";
        case TaxType.ADVANCED_TRANSIT_WEB_HOSTING_TAX:
          return "ADVANCED_TRANSIT_WEB_HOSTING_TAX";
        case TaxType.MISSOURI_UNIVERSAL_SERVICE_FUND:
          return "MISSOURI_UNIVERSAL_SERVICE_FUND";
        case TaxType.BUSINESS_OCCUPATION_TAX_WHOLESALE:
          return "BUSINESS_OCCUPATION_TAX_WHOLESALE";
        case TaxType.TELECOMMUNICATIONS_EDUCATION_ACCESS_FUND_CENTREX:
          return "TELECOMMUNICATIONS_EDUCATION_ACCESS_FUND_CENTREX";
        case TaxType.BUSINESS_OCCUPATION_TAX_OTHER:
          return "BUSINESS_OCCUPATION_TAX_OTHER";
        case TaxType.TRIBAL_SALES_TAX:
          return "TRIBAL_SALES_TAX";
        case TaxType.SALES_TAX_DATA_PROCESSING:
          return "SALES_TAX_DATA_PROCESSING";
        case TaxType.TRANSIT_TAX_DATA_PROCESSING:
          return "TRANSIT_TAX_DATA_PROCESSING";
        case TaxType.CRIME_CONTROL_DISTRICT_TAX_DATA_PROCESSING:
          return "CRIME_CONTROL_DISTRICT_TAX_DATA_PROCESSING";
        case TaxType.LIBRARY_DISTRICT_TAX_DATA_PROCESSING:
          return "LIBRARY_DISTRICT_TAX_DATA_PROCESSING";
        case TaxType.HOSPITAL_DISTRICT_TAX_DATA_PROCESSING:
          return "HOSPITAL_DISTRICT_TAX_DATA_PROCESSING";
        case TaxType.HEALTH_SERVICES_DISTRICT_TAX_DATA_PROCESSING:
          return "HEALTH_SERVICES_DISTRICT_TAX_DATA_PROCESSING";
        case TaxType.EMERGENCY_SERVICES_DISTRICT_TAX_DATA_PROCESSING:
          return "EMERGENCY_SERVICES_DISTRICT_TAX_DATA_PROCESSING";
        case TaxType.IMPROVEMENT_DISTRICT_TAX_DATA_PROCESSING:
          return "IMPROVEMENT_DISTRICT_TAX_DATA_PROCESSING";
        case TaxType.DEVELOPMENT_DISTRICT_TAX_DATA_PROCESSING:
          return "DEVELOPMENT_DISTRICT_TAX_DATA_PROCESSING";
        case TaxType.ADVANCED_TRANSIT_TAX_DATA_PROCESSING:
          return "ADVANCED_TRANSIT_TAX_DATA_PROCESSING";
        case TaxType.CA_PSPE_SURCHARGE:
          return "CA_PSPE_SURCHARGE";
        case TaxType.DISTRICT_TAX_DATA_PROCESSING:
          return "DISTRICT_TAX_DATA_PROCESSING";
        case TaxType.RESERVED_158:
          return "RESERVED_158";
        case TaxType.CABLE_FRANCHISE_FEE:
          return "CABLE_FRANCHISE_FEE";
        case TaxType.STATUTORY_GROSS_RECEIPTS_BUSINESS:
          return "STATUTORY_GROSS_RECEIPTS_BUSINESS";
        case TaxType.E911_VOIP:
          return "E911_VOIP";
        case TaxType.FUSF_VOIP:
          return "FUSF_VOIP";
        case TaxType.FUSF:
          return "FUSF";
        case TaxType.COST_RECOVERY_SURCHARGE:
          return "COST_RECOVERY_SURCHARGE";
        case TaxType.STATE_USF_VOIP:
          return "STATE_USF_VOIP";
        case TaxType.COMMUNICATIONS_SERVICES_TAX_CABLE:
          return "COMMUNICATIONS_SERVICES_TAX_CABLE";
        case TaxType.MUNICIPAL_RIGHT_OF_WAY_CABLE:
          return "MUNICIPAL_RIGHT_OF_WAY_CABLE";
        case TaxType.FCC_REGULATORY_FEE_WIRELINE:
          return "FCC_REGULATORY_FEE_WIRELINE";
        case TaxType.FCC_REGULATORY_FEE_WIRELESS:
          return "FCC_REGULATORY_FEE_WIRELESS";
        case TaxType.TELECOMM_SALE_TAX:
          return "TELECOMM_SALE_TAX";
          // New tax types added 04-30-2007
        case TaxType.STATUTORY_GROSS_RECEIPTS_VIDEO:
          return "STATUTORY_GROSS_RECEIPTS_VIDEO";
        case TaxType.UTILITY_USERS_TAX_LIFELINE:
          return "UTILITY_USERS_TAX_LIFELINE";
        case TaxType.TRS_LONG_DISTANCE:
          return "TRS_LONG_DISTANCE";
        case TaxType.TRS_WIRELESS:
          return "TRS_WIRELESS";
        case TaxType.SALES_TAX_SENIOR_CITIZEN:
          return "SALES_TAX_SENIOR_CITIZEN";
        case TaxType.REGULATORY_COST_CHARGE_LOCAL:
          return "REGULATORY_COST_CHARGE_LOCAL";
        case TaxType.REGULATORY_COST_CHARGE_INTRASTATE:
          return "REGULATORY_COST_CHARGE_INTRASTATE";
        case TaxType.REGULATORY_COST_CHARGE_CABLE:
          return "REGULATORY_COST_CHARGE_CABLE";
        case TaxType.PUC_FEE_CABLE:
          return "PUC_FEE_CABLE";
        case TaxType.PROVINCIAL_SALES_TAX_TOLL:
          return "PROVINCIAL_SALES_TAX_TOLL";
          // END New tax types added 04-30-2007
        default:
          return "";
      }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="strTaxLevel"></param>
    /// <returns></returns>
    public static TaxLevel GetEZTaxLevel(string strTaxLevel)
    {
      switch (strTaxLevel.ToUpper())
      {
        case "COUNTY_LEVEL":
          return TaxLevel.County;
        case "COUNTY_LOCAL_LEVEL":
          return TaxLevel.County_Local;
        case "FEDERAL_LEVEL":
          return TaxLevel.Federal;
        case "LOCAL_LEVEL":
          return TaxLevel.Local;
        case "STATE_LEVEL":
          return TaxLevel.State;
        case "STATE_COUNTY_LOCAL_LEVEL":
          return TaxLevel.State_County_Local;
        case "UNINCORPORATED_LEVEL":
          return TaxLevel.Unincorporated;
        case "OTHER_LEVEL":
          return TaxLevel.Other;
        default:
          return (TaxLevel) (-1);
      }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="iTaxLevel"></param>
    /// <returns></returns>
    public static string GetEZTaxLevel(TaxLevel iTaxLevel)
    {
      switch (iTaxLevel)
      {
        case TaxLevel.County:
          return "COUNTY_LEVEL";
        case TaxLevel.County_Local:
          return "COUNTY_LOCAL_LEVEL";
        case TaxLevel.Federal:
          return "FEDERAL_LEVEL";
        case TaxLevel.Local:
          return "LOCAL_LEVEL";
        case TaxLevel.State:
          return "STATE_LEVEL";
        case TaxLevel.State_County_Local:
          return "STATE_COUNTY_LOCAL_LEVEL";
        case TaxLevel.Unincorporated:
          return "UNINCORPORATED_LEVEL";
        case TaxLevel.Other:
          return "OTHER_LEVEL";
        default:
          return "";
      }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="iTaxLevel"></param>
    /// <returns></returns>
    public static TaxJurisdiction GetTaxLevel(TaxLevel iTaxLevel)
    {
      switch (iTaxLevel)
      {
        case TaxLevel.Federal:
          return TaxJurisdiction.Federal;
        case TaxLevel.State:
          return TaxJurisdiction.State;
        case TaxLevel.County:
          return TaxJurisdiction.County;
        case TaxLevel.Local:
          return TaxJurisdiction.Local;
        case TaxLevel.Other:
          return TaxJurisdiction.Other;
        case TaxLevel.State_County_Local:
          throw new NotImplementedException("STATE_COUNTY_LOCAL_LEVEL");
        case TaxLevel.Unincorporated:
          throw new NotImplementedException("UNINCORPORATED_LEVEL");
        case TaxLevel.County_Local:
          throw new NotImplementedException("COUNTY_LOCAL_LEVEL");
      }
      throw new NotImplementedException("Unknown level : " + iTaxLevel);
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="iTaxType"></param>
    /// <returns></returns>
    public static TaxLevel GetTaxLevel(TaxJurisdiction iTaxType)
    {
      switch (iTaxType)
      {
        case TaxJurisdiction.Federal:
          return TaxLevel.Federal;
        case TaxJurisdiction.State:
          return TaxLevel.State;
        case TaxJurisdiction.County:
          return TaxLevel.County;
        case TaxJurisdiction.Local:
          return TaxLevel.Local;
        case TaxJurisdiction.Other:
          return TaxLevel.Other;
        default:
          throw new NotImplementedException("UnknownLevel(" + iTaxType.ToTaxTypeName() + ")");
      }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="iBusinessLevel"></param>
    /// <returns></returns>
    public static string GetEZTaxBusinessClass(BusinessClass iBusinessLevel)
    {
      switch (iBusinessLevel)
      {
        case BusinessClass.CLEC:
          return "C-CLEC";
        case BusinessClass.ILEC:
          return "I-ILEC";
        default:
          return "";
      }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="iBusinessLevel"></param>
    /// <returns></returns>
    public static BusinessClass GetEZTaxBusinessClass(string iBusinessLevel)
    {
      switch (iBusinessLevel)
      {
        case "C-CLEC":
          return BusinessClass.CLEC;
        case "I-ILEC":
          return BusinessClass.ILEC;
      }
      throw new TaxException("Unknown business class " + iBusinessLevel);
    }

    /// <summary>
    /// Given the string form, returns the CustomerType
    /// </summary>
    /// <param name="customer_type"></param>
    /// <returns></returns>
    public static CustomerType GetEZTaxCustomerType(string customer_type)
    {
      switch (customer_type.ToLower().Trim())
      {
        default:
        case "b":
        case "business":
          return CustomerType.Business;
        case "i":
        case "industrial":
          return CustomerType.Industrial;
        case "r":
        case "residential":
          return CustomerType.Residential;
        case "s":
        case "seniorcitizen":
          return CustomerType.SeniorCitizen;
      }
    }

    /// <summary>
    /// Returns string form of the CustomerType
    /// </summary>
    /// <param name="customer_type"></param>
    /// <returns></returns>
    public static string GetEZTaxCustomerType(CustomerType customer_type)
    {
      switch (customer_type)
      {
        default:
        case CustomerType.Business:
          return "b";
        case CustomerType.Industrial:
          return "i";
        case CustomerType.Residential:
          return "r";
        case CustomerType.SeniorCitizen:
          return "s";
      }
    }

    /// <summary>
    /// Returns DiscountType provided the string form
    /// </summary>
    /// <param name="discount_type"></param>
    /// <returns></returns>
    public static DiscountType GetEXTaxDiscountType(string discount_type)
    {
      switch (discount_type.ToLower().Trim())
      {
        default:
        case "none":
          return DiscountType.None;
        case "accountlevel":
          return DiscountType.AccountLevel;
        case "goodwill":
          return DiscountType.Goodwill;
        case "manufacturerproduct":
          return DiscountType.ManufacturerProduct;
        case "retailproduct":
          return DiscountType.RetailProduct;
        case "subsidized":
          return DiscountType.Subsidized;
      }
    }

    /// <summary>
    /// Returns string form of the DiscountType
    /// </summary>
    /// <param name="discount_type"></param>
    /// <returns></returns>
    public static string GetEXTaxDiscountType(DiscountType discount_type)
    {
      switch (discount_type)
      {
        default:
        case DiscountType.None:
          return "none";
        case DiscountType.AccountLevel:
          return "accountlevel";
        case DiscountType.Goodwill:
          return "goodwill";
        case DiscountType.ManufacturerProduct:
          return "manufacturerproduct";
        case DiscountType.RetailProduct:
          return "retailproduct";
        case DiscountType.Subsidized:
          return "subsidized";
      }
    }

    /// <summary>
    /// Provided a string, returns the ServiceClass
    /// </summary>
    /// <param name="svcClass"></param>
    /// <returns></returns>
    public static ServiceClass ServiceClass(string svcClass)
    {
      // Long Distance or Local primary (D or L)
      switch (svcClass.ToUpper().Trim())
      {
        default:
        case "L":
        case "LOCAL":
        case "PRIMARYLOCAL":
          return BillSoft.EZTaxNET.ServiceClass.PrimaryLocal;
        case "D":
        case "LONGDISTANCE":
        case "PRIMARYLONGDISTANCE":
          return BillSoft.EZTaxNET.ServiceClass.PrimaryLongDistance;
      }
    }

    /// <summary>
    /// Returns the string version of the ServiceClass
    /// </summary>
    /// <param name="svcClass"></param>
    /// <returns></returns>
    public static string ServiceClass(ServiceClass svcClass)
    {
      // Long Distance or Local primary (D or L)
      switch (svcClass)
      {
        default:
        case BillSoft.EZTaxNET.ServiceClass.PrimaryLocal:
          return "L";
        case BillSoft.EZTaxNET.ServiceClass.PrimaryLongDistance:
          return "D";
      }
    }

    /// <summary>
    /// Converts the string flag to a real boolean.
    /// </summary>
    /// <param name="flag">string flag, acceptable values (true, false, 0, 1, t, f, y, n, yes, no)</param>
    /// <returns>boolean representation</returns>
    public static bool ConvertStringToBoolean(string flag)
    {
      switch (flag.ToUpper().Trim())
      {
        case "TRUE":
        case "YES":
        case "Y":
        case "T":
        case "1":
          return true;
        case "FALSE":
        case "NO":
        case "N":
        case "F":
        case "0":
        default:
          return false;
      }
    }

    /// <summary>
    /// DB input conversion method
    /// </summary>
    /// <param name="flag"></param>
    /// <returns></returns>
    public static bool LifeLine(string flag)
    {
      //L- lifeline customer, I - not lifeline
      return TestFlag("L", flag);
    }
    /// <summary>
    /// DB input conversion method
    /// </summary>
    /// <param name="flag"></param>
    /// <returns></returns>
    public static bool Facilities(string flag)
    {
      // (F or N)
      return TestFlag("F", flag);
    }
    /// <summary>
    /// DB input conversion method
    /// </summary>
    /// <param name="flag"></param>
    /// <returns></returns>
    public static bool Franchise(string flag)
    {
      // Franchise or Non-Franchise (F or N)
      return TestFlag("F", flag);
    }
    /// <summary>
    /// DB input conversion method
    /// </summary>
    /// <param name="flag"></param>
    /// <returns></returns>
    public static bool ClientResale(string flag)
    {
      //	S-Sale, R-Resale
      return TestFlag("S", flag);
    }
    /// <summary>
    /// DB input conversion method
    /// </summary>
    /// <param name="flag"></param>
    /// <returns></returns>
    public static bool InsideCustomer(string flag)
    {
      // Customer Inside or Outside incorporated area
      return TestFlag("I", flag);
    }
    /// <summary>
    /// DB input conversion method
    /// </summary>
    /// <param name="flag"></param>
    /// <returns></returns>
    public static bool Regulated(string flag)
    {
      //R-Regulated, U-Unregulated
      return TestFlag("R", flag);
    }

    /// <summary>
    /// Tests for a match
    /// </summary>
    /// <param name="matchme"></param>
    /// <param name="value"></param>
    /// <returns></returns>
    public static bool TestFlag(string matchme, string value)
    {
      return matchme.ToLower().Trim() == value.ToLower().Trim();
    }
  }
}
