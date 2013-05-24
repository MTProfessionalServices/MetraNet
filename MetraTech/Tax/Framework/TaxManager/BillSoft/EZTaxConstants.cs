/*************************************************************************/
/*                                                                       */
/* Copyright 2007 - 2011 by BillSoft, Inc.                               */
/*   All Rights Reserved. No part of this publication may be reproduced, */
/*   stored in a retrieval system, or transmitted, in any form, by any   */
/*   means, without the prior written permission of the publisher.       */
/*                                                                       */
/*                                                                       */
/*************************************************************************/

namespace MetraTech.Tax.Framework.MtBillSoft
{
  /// <summary>
  /// Transaction types.
  /// </summary>
  public class TransactionType
  {
    /// <summary>
    /// For failure handling
    /// </summary>
    public const short UNDEFINED = -1;

    /// <summary>
    /// Do Not Apply Tax
    /// </summary>
    public const short DO_NOT_APPLY_TAX = 0;

    /// <summary>
    /// Interstate transaction type
    /// </summary>
    public const short INTERSTATE = 1;

    /// <summary>
    /// Interprovincial transaction type
    /// </summary>
    public const short INTERPROVINCIAL = 1;

    /// <summary>
    /// Intrastate transaction type
    /// </summary>
    public const short INTRASTATE = 2;

    /// <summary>
    /// Intraprovincial transaction type
    /// </summary>
    public const short INTRAPROVINCIAL = 2;

    /// <summary>
    /// Other transaction type
    /// </summary>
    public const short OTHER = 3;

    /// <summary>
    /// Non-Recurring transaction type
    /// </summary>
    public const short NON_RECURRING = 4;

    /// <summary>
    /// Internet transaction type
    /// </summary>
    public const short INTERNET = 5;

    /// <summary>
    /// Paging transaction type
    /// </summary>
    public const short PAGING = 6;

    /// <summary>
    /// Local transaction type
    /// </summary>
    public const short LOCAL = 7;

    /// <summary>
    /// Fax transaction type
    /// </summary>
    public const short FAX = 8;

    /// <summary>
    /// Voice Mail transaction type
    /// </summary>
    public const short VOICE_MAIL = 9;

    /// <summary>
    /// Sales transaction type
    /// </summary>
    public const short SALES = 10;

    /// <summary>
    /// Shipping transaction type
    /// </summary>
    public const short SHIPPING = 11;

    /// <summary>
    /// Natural Gas transaction type
    /// </summary>
    public const short NATURAL_GAS = 12;

    /// <summary>
    /// Cellular transaction type
    /// </summary>
    public const short CELLULAR = 13;

    /// <summary>
    /// Wireless transaction type
    /// </summary>
    public const short WIRELESS = 13;

    /// <summary>
    /// International transaction type
    /// </summary>
    public const short INTERNATIONAL = 14;

    /// <summary>
    /// Telephony transaction type
    /// </summary>
    public const short TELEPHONY = 15;

    /// <summary>
    /// Cable Television transaction type
    /// </summary>
    public const short CABLE_TELEVISION = 16;

    /// <summary>
    /// For BillSoft internal use only
    /// </summary>
    private const short SGT = 17;

    /// <summary>
    /// Satellite Television transaction type
    /// </summary>
    public const short SATELLITE_TELEVISION = 18;

    /// <summary>
    /// VOIP transaction type
    /// </summary>
    public const short VOIP = 19;

    /// <summary>
    /// VOIPA transaction type
    /// </summary>
    public const short VOIPA = 20;

    /// <summary>
    /// Payphone transaction type
    /// </summary>
    public const short PAYPHONE = 21;

    /// <summary>
    /// Software transaction type
    /// </summary>
    public const short SOFTWARE = 24;

    /// <summary>
    /// Timesharing transaction type
    /// </summary>
    public const short TIMESHARING = 25;

    /// <summary> Alcohol </summary>
    public const short ALCOHOL = 27;

    /// <summary> Beverages </summary>
    public const short BEVERAGES = 28;

    /// <summary> Books </summary>
    public const short BOOKS = 29;

    /// <summary> Clothing </summary>
    public const short CLOTHING = 30;

    /// <summary> Drugs </summary>
    public const short DRUGS = 31;

    /// <summary> Electronic Equipment and Computer Hardware </summary>
    public const short ELECTRONIC_EQUIPMENT_AND_COMPUTER_HARDWARE = 32;

    /// <summary> Fuel </summary>
    public const short FUEL = 33;

    /// <summary> General Merchandise </summary>
    public const short GENERAL_MERCHANDISE = 34;

    /// <summary> Groceries </summary>
    public const short GROCERIES = 35;

    /// <summary> Magazines </summary>
    public const short MAGAZINES = 36;

    /// <summary> Manufacturing </summary>
    public const short MANUFACTURING = 37;

    /// <summary> Medical Durable Equipment </summary>
    public const short MEDICAL_DURABLE_EQUIPMENT = 38;

    /// <summary> Medical Mobility Enhancing Equipment </summary>
    public const short MEDICAL_MOBILITY_ENHANCING_EQUIPMENT = 39;

    /// <summary> Medical Prosthetic Devices </summary>
    public const short MEDICAL_PROSTHETIC_DEVICES = 40;

    /// <summary> Motor Vehicles </summary>
    public const short MOTOR_VEHICLES = 41;

    /// <summary> Newspaper </summary>
    public const short NEWSPAPER = 42;

    /// <summary> Prepared Food </summary>
    public const short PREPARED_FOOD = 43;

    /// <summary> Rentals and Leasing </summary>
    public const short RENTALS_AND_LEASING = 44;

    /// <summary> Services Cleaning </summary>
    public const short SERVICES_CLEANING = 45;

    /// <summary> Services Lodging </summary>
    public const short SERVICES_LODGING = 46;

    /// <summary> Services Printing </summary>
    public const short SERVICES_PRINTING = 47;

    /// <summary> Services Professional </summary>
    public const short SERVICES_PROFESSIONAL = 48;

    /// <summary> Services Recreation </summary>
    public const short SERVICES_RECREATION = 49;

    /// <summary> Services Repair </summary>
    public const short SERVICES_REPAIR = 50;

    /// <summary> Services Storage </summary>
    public const short SERVICES_STORAGE = 51;

    /// <summary> Tires </summary>
    public const short TIRES = 52;

    /// <summary> Tobacco </summary>
    public const short TOBACCO = 53;

    /// <summary> Tooling </summary>
    public const short TOOLING = 54;

    /// <summary> Vending </summary>
    public const short VENDING = 55;

    /// <summary> Information Services </summary>
    public const short INFORMATION_SERVICES = 56;

    /// <summary>Digital Goods</summary>
    public const short DIGITAL_GOODS = 57;

    /// <summary>Dark Fiber</summary>
    public const short DARK_FIBER = 58;

    /// <summary>VoIP Nomadic</summary>
    public const short VOIP_NOMADIC = 59;

    /// <summary>Satellite Phone</summary>
    public const short SATELLITE_PHONE = 60;

    /// <summary>VPN</summary>
    public const short VPN = 61;

    /// <summary>RESERVED_62</summary>
    public const short RESERVED_62 = 62;
  }

  /// <summary>
  /// Service types.
  /// </summary>
  public class ServiceType
  {
    /// <summary>
    /// For failure handling
    /// </summary>
    public const short UNDEFINED = -1;

    /// <summary>
    /// Toll service type
    /// </summary>
    public const short TOLL = 1;

    /// <summary>
    /// N800 service type
    /// </summary>
    public const short N800 = 2;

    /// <summary>
    /// WATS service type
    /// </summary>
    public const short WATS = 3;

    /// <summary>
    /// Private Line service type
    /// </summary>
    public const short PRIVATE_LINE = 4;

    /// <summary>
    /// Local Exchange service type
    /// </summary>
    public const short LOCAL_EXCHANGE = 5;

    /// <summary>
    /// Local Loop service type
    /// </summary>
    public const short LOCAL_LOOP = 6;

    /// <summary>
    /// Access Charge service type
    /// </summary>
    public const short ACCESS_CHARGE = 6;

    /// <summary>
    /// Cable Television Basic Service service type
    /// </summary>
    public const short CABLE_TELEVISION_BASIC_SERVICE = 6;

    /// <summary>
    /// Service service type
    /// </summary>
    public const short SERVICE = 7;

    /// <summary>
    /// Install service type
    /// </summary>
    public const short INSTALL = 8;

    /// <summary>
    /// Local Activation service type
    /// </summary>
    public const short LOCAL_ACTIVATION = 8;

    /// <summary>
    /// Local Install service type
    /// </summary>
    public const short LOCAL_INSTALL = 8;

    /// <summary>
    /// Directory Ads service type
    /// </summary>
    public const short DIRECTORY_ADS = 9;

    /// <summary>
    /// Directory Ads service type
    /// </summary>
    public const short DIR_AD = 9;

    /// <summary>
    /// Usage service type
    /// </summary>
    public const short USAGE = 10;

    /// <summary>
    /// Activation service type
    /// </summary>
    public const short ACTIVATION = 11;

    /// <summary>
    /// International Toll service type
    /// </summary>
    public const short INTERNATIONAL_TOLL = 12;

    /// <summary>
    /// Equipment Repair service type
    /// </summary>
    public const short EQUIPMENT_REPAIR = 13;

    /// <summary>
    /// Late Charge service type
    /// </summary>
    public const short LATE_CHARGE = 14;

    /// <summary>
    /// Product service type
    /// </summary>
    public const short PRODUCT = 15;

    /// <summary>
    /// N900 Service service type
    /// </summary>
    public const short N_900_SERVICE = 16;

    /// <summary>
    /// Fob Origin service type
    /// </summary>
    public const short FOB_ORIGIN = 17;

    /// <summary>
    /// Fob Destination service type
    /// </summary>
    public const short FOB_DESTINATION = 18;

    /// <summary>
    /// Consumption service type
    /// </summary>
    public const short CONSUMPTION = 19;

    /// <summary>
    /// FCC Subscriber Line Fee service type
    /// </summary>
    public const short FCC_SUBSCRIBER_LINE_FEE = 20;

    /// <summary>
    /// Number Portability Recovery service type
    /// </summary>
    public const short NUMBER_PORTABILITY_RECOVERY = 20;

    /// <summary>
    /// Lines service type
    /// </summary>
    public const short LINES = 21;

    /// <summary>
    /// Coin service type
    /// </summary>
    public const short COIN = 22;

    /// <summary>
    /// Location service type
    /// </summary>
    public const short LOCATION = 23;

    /// <summary>
    /// PBX Trunk service type
    /// </summary>
    public const short PBX_TRUNK = 24;

    /// <summary>
    /// USA Inbound service type
    /// </summary>
    public const short USA_INBOUND = 25;

    /// <summary>
    ///  For BillSoft internal use only
    /// </summary>
    public const short PREPAID = 26;

    /// <summary>
    /// Data service type
    /// </summary>
    public const short DATA = 27;

    /// <summary>
    /// E911 Call service type
    /// </summary>
    public const short E911_CALL = 28;

    /// <summary>
    /// Web Hosting service type
    /// </summary>
    public const short WEB_HOSTING = 29;

    /// <summary>
    /// Local Feature Charge service type
    /// </summary>
    public const short LOCAL_FEATURE_CHARGE = 30;

    /// <summary>
    /// Use service type
    /// </summary>
    public const short USE = 31;

    /// <summary>
    /// Debit service type
    /// </summary>
    public const short DEBIT = 32;

    /// <summary>
    /// Roaming Charge service type
    /// </summary>
    public const short ROAMING_CHARGE = 33;

    /// <summary>
    /// Conference Bridge service type
    /// </summary>
    public const short CONFERENCE_BRIDGE = 34;

    /// <summary>
    /// Premium Service service type
    /// </summary>
    public const short PREMIUM_SERVICE = 35;

    /// <summary>
    /// Pay Per View Service service type
    /// </summary>
    public const short PAY_PER_VIEW_SERVICE = 36;

    /// <summary>
    /// Equipment service type
    /// </summary>
    public const short EQUIPMENT_RENTAL = 37;

    /// <summary>
    /// Wire Maintenance Plan service type
    /// </summary>
    public const short WIRE_MAINTENANCE_PLAN = 38;

    /// <summary>
    /// TV Guide service type
    /// </summary>
    public const short TV_GUIDE = 39;

    /// <summary>
    /// Centrex Extension service type
    /// </summary>
    public const short CENTREX_EXTENSION = 40;

    /// <summary>
    /// PBX Extension service type
    /// </summary>
    public const short PBX_EXTENSION = 41;

    /// <summary>
    /// Trunk service type
    /// </summary>
    public const short TRUNK = 42;

    /// <summary>
    /// Centrex Trunk service type
    /// </summary>
    public const short CENTREX_TRUNK = 42;

    /// <summary>
    /// Invoice service type
    /// </summary>
    public const short INVOICE = 43;

    /// <summary>
    /// Telegraph service type
    /// </summary>
    public const short TELEGRAPH = 44;

    /// <summary>
    /// High Capacity Trunk service type
    /// </summary>
    public const short HIGH_CAPACITY_TRUNK = 45;

    /// <summary>
    /// PICC service type
    /// </summary>
    public const short PICC = 46;

    /// <summary>
    /// NO PICK PICC service type
    /// </summary>
    public const short NO_PICK_PICC = 47;

    /// <summary>
    ///  Wireless Access Charge service type
    /// </summary>
    public const short WIRELESS_ACCESS_CHARGE = 48;

    /// <summary>
    ///  Interstate Usage service type
    /// </summary>
    public const short INTERSTATE_USAGE = 49;

    /// <summary>
    ///  Intrastate Usage service type
    /// </summary>
    public const short INTRASTATE_USAGE = 50;

    /// <summary>
    ///  International Usage service type
    /// </summary>
    public const short INTERNATIONAL_USAGE = 51;

    /// <summary>
    ///  Wireless Lines service type
    /// </summary>
    public const short WIRELESS_LINES = 52;

    /// <summary>
    ///  LNP service type
    /// </summary>
    public const short LNP = 53;

    /// <summary>
    ///  Directory Assistance service type
    /// </summary>
    public const short DIRECTORY_ASSISTANCE = 54;

    /// <summary>
    ///  Local Usage service type
    /// </summary>
    public const short LOCAL_USAGE = 55;

    /// <summary>
    ///  Provisioning service type
    /// </summary>
    public const short PROVISIONING = 56;

    /// <summary>
    ///  Data Processing service type
    /// </summary>
    public const short DATA_PROCESSING = 57;

    /// <summary>
    ///  Access Line service type
    /// </summary>
    public const short ACCESS_LINE = 58;

    /// <summary>
    ///  License Software service type
    /// </summary>
    public const short LICENSE_SOFTWARE = 59;

    /// <summary>
    ///  Software Maintenance Agreement service type
    /// </summary>
    public const short SOFTWARE_MAINTENANCE_AGREEMENT = 60;

    /// <summary>
    ///  Report On CD Paper Form service type
    /// </summary>
    public const short REPORT_ON_CD_PAPER_FORM = 61;

    /// <summary>
    ///  Informational Retrieval service type
    /// </summary>
    public const short INFORMATION_RETRIEVAL = 62;

    /// <summary>
    ///  Restocking Fee Rental service type
    /// </summary>
    public const short RESTOCKING_FEE_RENTAL = 63;

    /// <summary>
    ///  Restocking Fee Purchase service type
    /// </summary>
    public const short RESTOCKING_FEE_PURCHASE = 64;

    /// <summary>
    ///  Partial Credit service type
    /// </summary>
    public const short PARTIAL_CREDIT = 65;

    /// <summary>
    ///  Late Charge Bundle service type
    /// </summary>
    public const short LATE_CHARGE_BUNDLE = 84;

    /// <summary>
    ///  Local Exchange Bundle service type
    /// </summary>
    public const short LOCAL_EXCHANGE_BUNDLE = 85;

    /// <summary>
    ///  FCC Subscriber Line Fee Bundle service type
    /// </summary>
    public const short FCC_SUBSCRIBER_LINE_FEE_BUNDLE = 86;

    /// <summary>
    ///  Lines Bundle service type
    /// </summary>
    public const short LINES_BUNDLE = 87;

    /// <summary>
    ///  service type
    /// </summary>
    public const short LOCATION_BUNDLE = 88;

    /// <summary>
    ///  PBX Trunk Bundle service type
    /// </summary>
    public const short PBX_TRUNK_BUNDLE = 89;

    /// <summary>
    ///  Local Feature Charge Bundle service type
    /// </summary>
    public const short LOCAL_FEATURE_CHARGE_BUNDLE = 90;

    /// <summary>
    ///  Centrex Extension Bundle service type
    /// </summary>
    public const short CENTREX_EXTENSION_BUNDLE = 91;

    /// <summary>
    ///  PBX Extension Bundle service type
    /// </summary>
    public const short PBX_EXTENSION_BUNDLE = 92;

    /// <summary>
    ///  Centrex Trunk Bundle service type
    /// </summary>
    public const short CENTREX_TRUNK_BUNDLE = 93;

    /// <summary>
    ///  Invoice Bundle service type
    /// </summary>
    public const short INVOICE_BUNDLE = 94;

    /// <summary>
    ///  High Capacity service type
    /// </summary>
    public const short HIGH_CAPACITY_TRUNK_BUNDLE = 95;

    /// <summary>
    ///  No Pick PICC Bundle service type
    /// </summary>
    public const short NO_PICK_PICC_BUNDLE = 96;

    /// <summary>
    ///  PICC Bundle service type
    /// </summary>
    public const short PICC_BUNDLE = 97;

    /// <summary>
    /// Acces Number service type
    /// </summary>
    public const short ACCESS_NUMBER = 98;

    /// <summary>
    /// Interstate Access Charge service type
    /// </summary>
    public const short INTERSTATE_ACCESS_CHARGE = 99;

    /// <summary>
    /// Intrastate Access Charge service type
    /// </summary>
    public const short INTRASTATE_ACCESS_CHARGE = 100;

    /// <summary>
    /// Interstate Roaming service type
    /// </summary>
    public const short INTERSTATE_ROAMING = 101;

    /// <summary>
    /// Intrastate Roaming service type
    /// </summary>
    public const short INTRASTATE_ROAMING = 102;

    /// <summary>
    /// Sales Tax and FUSF service type
    /// </summary>
    public const short SALES_TAX_AND_FUSF = 103;

    /// <summary>
    /// Reserved for internal BillSoft use
    /// </summary>
    public const short INTERNAL_SRV_TYPE_1 = 104;

    /// <summary>
    /// Reserved for internal BillSoft use
    /// </summary>
    public const short INTERNAL_SRV_TYPE_2 = 105;


    /// <summary>Licensed Software  </summary>
    public const short LICENSED_SOFTWARE = 59;

    /// <summary>General Rule  </summary>
    public const short GENERAL_RULE = 106;

    /// <summary>Beverage Above 7%  Content By Weight  </summary>
    public const short BEVERAGE_ABOVE_7_PCTCONTENT_BY_WEIGHT = 107;

    /// <summary>Beverage Below 7% Content By Weight</summary>
    public const short BEVERAGE_BELOW_7_PCT_CONTENT_BY_WEIGHT = 108;

    /// <summary>Mixed Beverage above 7% Content By Weight</summary>
    public const short MIXED_BEVERAGE_ABOVE_7_PCT_CONTENT_BY_WEIGHT = 109;

    /// <summary>Mixed Beverage below 7% Content By Weight</summary>
    public const short MIXED_BEVERAGE_BELOW_7_PCT_CONTENT_BY_WEIGHT = 110;

    /// <summary>Non Mixed Served in Restaurant Above 7%  </summary>
    public const short NON_MIXED_SERVED_IN_RESTAURANT_ABOVE_7_PCT = 111;

    /// <summary>Non Mixed Served in Restaurant Below 7%  </summary>
    public const short NON_MIXED_SERVED_IN_RESTAURANT_BELOW_7_PCT = 112;

    /// <summary>Carbonated Beverages</summary>
    public const short CARBONATED_BEVERAGES = 113;

    /// <summary>Sweetened Carbonated Beverages  </summary>
    public const short SWEETENED_CARBONATED_BEVERAGES = 114;

    /// <summary>Bottled Water </summary>
    public const short BOTTLED_WATER = 115;

    /// <summary>Bottled Water - Carbonated and/or Flavored  </summary>
    public const short BOTTLED_WATER_CARBONATED_AND_OR_FLAVORED = 116;

    /// <summary>Bottled Water - Carbonated and/or Sweetened </summary>
    public const short BOTTLED_WATER_CARBONATED_AND_OR_SWEETENED = 117;

    /// <summary>Soft Drinks</summary>
    public const short SOFT_DRINKS = 118;

    /// <summary>Natural Fruit or Vegetable Juices  </summary>
    public const short NATURAL_FRUIT_OR_VEGETABLE_JUICES = 119;

    /// <summary>Natural Contents Between 0%-24% </summary>
    public const short NATURAL_CONTENTS_BETWEEN_0_PCT_24_PCT = 120;

    /// <summary>Natural Contents Between 25%-49%</summary>
    public const short NATURAL_CONTENTS_BETWEEN_25_PCT_49_PCT = 121;

    /// <summary>Natural Contents Between 50%-69%</summary>
    public const short NATURAL_CONTENTS_BETWEEN_50_PCT_69_PCT = 122;

    /// <summary>Natural Contents Between 70%-100%  </summary>
    public const short NATURAL_CONTENTS_BETWEEN_70_PCT_100_PCT = 123;

    /// <summary>Bottled Tea</summary>
    public const short BOTTLED_TEA = 124;

    /// <summary>Coffee  </summary>
    public const short COFFEE = 125;

    /// <summary>Religious  </summary>
    public const short RELIGIOUS = 126;

    /// <summary>Educational-Kindergarten Through 12th Grade </summary>
    public const short EDUCATIONAL_KINDERGARTEN_THROUGH_12TH_GRADE = 127;

    /// <summary>Educational-College and Trade School </summary>
    public const short EDUCATIONAL_COLLEGE_OR_TRADE_SCHOOL = 128;

    /// <summary>Everyday</summary>
    public const short EVERYDAY = 129;

    /// <summary>Sporting Activities </summary>
    public const short SPORTING_ACTIVITIES = 130;

    /// <summary>Sporting Equipment  </summary>
    public const short SPORTING_EQUIPMENT = 131;

    /// <summary>Protective </summary>
    public const short PROTECTIVE = 132;

    /// <summary>Protective/Manufacturing  </summary>
    public const short PROTECTIVE_MANUFACTURING = 133;

    /// <summary>Furs </summary>
    public const short FURS = 134;

    /// <summary>Uniforms</summary>
    public const short UNIFORMS = 135;

    /// <summary>Formal or Special Occasion Wear </summary>
    public const short FORMAL_OR_SPECIAL_OCCASION_WEAR = 136;

    /// <summary>Costumes</summary>
    public const short COSTUMES = 137;

    /// <summary>Accessories</summary>
    public const short ACCESSORIES = 138;

    /// <summary>Display Samples  </summary>
    public const short DISPLAY_SAMPLES = 139;

    /// <summary>Cloth Diapers </summary>
    public const short CLOTH_DIAPERS = 140;

    /// <summary>Clean Room </summary>
    public const short CLEAN_ROOM = 141;

    /// <summary>Bathing Caps  </summary>
    public const short BATHING_CAPS = 142;

    /// <summary>Belt Buckles  </summary>
    public const short BELT_BUCKLES = 143;

    /// <summary>Bowling Shoes </summary>
    public const short BOWLING_SHOES = 144;

    /// <summary>Ski Boots  </summary>
    public const short SKI_BOOTS = 145;

    /// <summary>Waders  </summary>
    public const short WADERS = 146;

    /// <summary>Shoe Laces </summary>
    public const short SHOE_LACES = 147;

    /// <summary>Prescription - Legend  </summary>
    public const short PRESCRIPTION_LEGEND = 148;

    /// <summary>Prescription - Over the Counter-Human </summary>
    public const short PRESCRIPTION_OVER_THE_COUNTER_HUMAN = 149;

    /// <summary>Nonprescription - Over the Counter-Human </summary>
    public const short NONPRESCRIPTION_OVER_THE_COUNTER_HUMAN = 150;

    /// <summary>Prescription - Over the Counter-Animal</summary>
    public const short PRESCRIPTION_OVER_THE_COUNTER_ANIMAL = 151;

    /// <summary>Nonprescription - Over the Counter-Animal</summary>
    public const short NONPRESCRIPTION_OVER_THE_COUNTER_ANIMAL = 152;

    /// <summary>Cough Drops</summary>
    public const short COUGH_DROPS = 153;

    /// <summary>Prescription - Insulin - Human Use </summary>
    public const short PRESCRIPTION_INSULIN_HUMAN_USE = 154;

    /// <summary>Nonprescription - Insulin - Human Use </summary>
    public const short NONPRESCRIPTION_INSULIN_HUMAN_USE = 155;

    /// <summary>Prescription - Insulin - Animal Use</summary>
    public const short PRESCRIPTION_INSULIN_ANIMAL_USE = 156;

    /// <summary>Nonprescription - Insulin - Animal Use</summary>
    public const short NONPRESCRIPTION_INSULIN_ANIMAL_USE = 157;

    /// <summary>Prescription - Oxygen-Human Use </summary>
    public const short PRESCRIPTION_OXYGEN_HUMAN_USE = 158;

    /// <summary>Nonprescription - Oxygen-Medicinal-Human Use</summary>
    public const short NONPRESCRIPTION_OXYGEN_MEDICINAL_HUMAN_USE = 159;

    /// <summary>Prescription - Oxygen-Animal Use</summary>
    public const short PRESCRIPTION_OXYGEN_ANIMAL_USE = 160;

    /// <summary>Nonprescription-Oxygen-Medicinal-Animal Use </summary>
    public const short NONPRESCRIPTION_OXYGEN_MEDICINAL_ANIMAL_USE = 161;

    /// <summary>Enemas and Suppositories  </summary>
    public const short ENEMAS_AND_SUPPOSITORIES = 162;

    /// <summary>Prescription-Animal Consumption </summary>
    public const short PRESCRIPTION_ANIMAL_CONSUMPTION = 163;

    /// <summary>Nonprescription-Animal Consumption </summary>
    public const short NONPRESCRIPTION_ANIMAL_CONSUMPTION = 164;

    /// <summary>Non-Presc Sold to Hospitals-Human  </summary>
    public const short NON_PRESC_SOLD_TO_HOSPITALS_HUMAN = 165;

    /// <summary>Presc Sold to Hospitals-Human</summary>
    public const short PRESC_SOLD_TO_HOSPITALS_HUMAN = 166;

    /// <summary>Non-Presc Sold to Hospitals-Animals</summary>
    public const short NON_PRESC_SOLD_TO_HOSPITALS_ANIMALS = 167;

    /// <summary>Presc Sold to Hospitals-Animals </summary>
    public const short PRESC_SOLD_TO_HOSPITALS_ANIMALS = 168;

    /// <summary>Taxable and Nontaxable Bundled Together  </summary>
    public const short TAXABLE_AND_NONTAXABLE_BUNDLED_TOGETHER = 169;

    /// <summary>Free Sample-Human Use  </summary>
    public const short FREE_SAMPLE_HUMAN_USE = 170;

    /// <summary>Free Sample- Presc-Human Use </summary>
    public const short FREE_SAMPLE_PRESC_HUMAN_USE = 171;

    /// <summary>Free Sample-Animal Use </summary>
    public const short FREE_SAMPLE_ANIMAL_USE = 172;

    /// <summary>Free Sample-Presc-Animal Use </summary>
    public const short FREE_SAMPLE_PRESC_ANIMAL_USE = 173;

    /// <summary>Monitors Less Than 4 Inches  </summary>
    public const short MONITORS_LESS_THAN_4_INCHES = 174;

    /// <summary>Monitors Between 5-14 inches </summary>
    public const short MONITORS_BETWEEN_5_14_INCHES = 175;

    /// <summary>Monitors Between Than 15-34 Inches </summary>
    public const short MONITORS_BETWEEN_THAN_15_34_INCHES = 176;

    /// <summary>Monitors Greater Than 35 Inches </summary>
    public const short MONITORS_GREATER_THAN_35_INCHES = 177;

    /// <summary>Unleaded Fuel w/o Excise Tax </summary>
    public const short UNLEADED_FUEL_W_O_EXCISE_TAX = 178;

    /// <summary>Diesel Fuel w/o Excise Tax</summary>
    public const short DIESEL_FUEL_W_O_EXCISE_TAX = 179;

    /// <summary>Gasohol w/o Excise Tax </summary>
    public const short GASOHOL_W_O_EXCISE_TAX = 180;

    /// <summary>Fuel to Common Carriers w/o Excise Tax</summary>
    public const short FUEL_TO_COMMON_CARRIERS_W_O_EXCISE_TAX = 181;

    /// <summary>Fuel-Passenger Common Carrier w/o Excise Tax</summary>
    public const short FUEL_PASSENGER_COMMON_CARRIER_W_O_EXCISE_TAX = 182;

    /// <summary>Unleaded Fuel w/Excise Tax</summary>
    public const short UNLEADED_FUEL_W_EXCISE_TAX = 183;

    /// <summary>Diesel Fuel w/Excise Tax  </summary>
    public const short DIESEL_FUEL_W_EXCISE_TAX = 184;

    /// <summary>Gasohol w/Excise Tax</summary>
    public const short GASOHOL_W_EXCISE_TAX = 185;

    /// <summary>Fuel to Common Carriers w/Excise Tax  </summary>
    public const short FUEL_TO_COMMON_CARRIERS_W_EXCISE_TAX = 186;

    /// <summary>Fuel-Passenger Common Carrier w/ Excise Tax </summary>
    public const short FUEL_PASSENGER_COMMON_CARRIER_W_EXCISE_TAX = 187;

    /// <summary>Fuel For Off Road Purposes</summary>
    public const short FUEL_FOR_OFF_ROAD_PURPOSES = 188;

    /// <summary>Jet Fuel</summary>
    public const short JET_FUEL = 189;

    /// <summary>Jet Fuel--Common Carriers </summary>
    public const short JET_FUEL_COMMON_CARRIERS = 190;

    /// <summary>Appliances </summary>
    public const short APPLIANCES = 191;

    /// <summary>Baby Oil</summary>
    public const short BABY_OIL = 192;

    /// <summary>Coins-Work of Art-Pure Metal </summary>
    public const short COINS_WORK_OF_ART_PURE_METAL = 194;

    /// <summary>Coins-Foreign Currency-Pure Metal  </summary>
    public const short COINS_FOREIGN_CURRENCY_PURE_METAL = 195;

    /// <summary>Coins-Collectible-Pure Metal </summary>
    public const short COINS_COLLECTIBLE_PURE_METAL = 196;

    /// <summary>Coins-Investment Purposes-Pure Metal  </summary>
    public const short COINS_INVESTMENT_PURPOSES_PURE_METAL = 197;

    /// <summary>Coins-Work of Art-90% or Greater</summary>
    public const short COINS_WORK_OF_ART_90_PCT_OR_GREATER = 198;

    /// <summary>Coins-Foreign Currency-90% or Greater </summary>
    public const short COINS_FOREIGN_CURRENCY_90_PCT_OR_GREATER = 199;

    /// <summary>Coins-Collectible-90% or Greater</summary>
    public const short COINS_COLLECTIBLE_90_PCT_OR_GREATER = 200;

    /// <summary>Coins-Investment Purposes-90% or Greater </summary>
    public const short COINS_INVESTMENT_PURPOSES_90_PCT_OR_GREATER = 201;

    /// <summary>Coins-Work of Art-Between 80-90%</summary>
    public const short COINS_WORK_OF_ART_BETWEEN_80_90_PCT = 202;

    /// <summary>Coins-Foreign Currency-Between 80-90% </summary>
    public const short COINS_FOREIGN_CURRENCY_BETWEEN_80_90_PCT = 203;

    /// <summary>Coins-Collectible-Between 80-90%</summary>
    public const short COINS_COLLECTIBLE_BETWEEN_80_90_PCT = 204;

    /// <summary>Coins-Investment Purposes-Between 80-90% </summary>
    public const short COINS_INVESTMENT_PURPOSES_BETWEEN_80_90_PCT = 205;

    /// <summary>Coins-Work of Art-Less Than 80% </summary>
    public const short COINS_WORK_OF_ART_LESS_THAN_80_PCT = 206;

    /// <summary>Coins-Foreign Currency-Less Than 80%  </summary>
    public const short COINS_FOREIGN_CURRENCY_LESS_THAN_80_PCT = 207;

    /// <summary>Coins-Collectible-Less Than 80% </summary>
    public const short COINS_COLLECTIBLE_LESS_THAN_80_PCT = 208;

    /// <summary>Coins-Investment Purposes-Less Than 80%  </summary>
    public const short COINS_INVESTMENT_PURPOSES_LESS_THAN_80_PCT = 209;

    /// <summary>Uncancelled Stamps-For Collectible Purposes </summary>
    public const short UNCANCELLED_STAMPS_FOR_COLLECTIBLE_PURPOSES = 210;

    /// <summary>Cancelled Stamps </summary>
    public const short CANCELLED_STAMPS = 211;

    /// <summary>Uncancelled Stamps-For Postage Purposes  </summary>
    public const short UNCANCELLED_STAMPS_FOR_POSTAGE_PURPOSES = 212;

    /// <summary>Caskets-For Human Remains </summary>
    public const short CASKETS_FOR_HUMAN_REMAINS = 213;

    /// <summary>Burial Vaults-For Human Remains </summary>
    public const short BURIAL_VAULTS_FOR_HUMAN_REMAINS = 214;

    /// <summary>Caskets-For All Other Remains</summary>
    public const short CASKETS_FOR_ALL_OTHER_REMAINS = 215;

    /// <summary>Burial Vaults-For All Other Remains</summary>
    public const short BURIAL_VAULTS_FOR_ALL_OTHER_REMAINS = 216;

    /// <summary>Headstone/Burial Marker-w/o Installation </summary>
    public const short HEADSTONE_BURIAL_MARKER_W_O_INSTALLATION = 217;

    /// <summary>Headstone/Burial Marker-w/ Installation  </summary>
    public const short HEADSTONE_BURIAL_MARKER_W_INSTALLATION = 218;

    /// <summary>Sanitary Napkins or Tampons  </summary>
    public const short SANITARY_NAPKINS_OR_TAMPONS = 219;

    /// <summary>Other State Flag </summary>
    public const short OTHER_STATE_FLAG = 220;

    /// <summary>Home State Flag  </summary>
    public const short HOME_STATE_FLAG = 221;

    /// <summary>POW Flag</summary>
    public const short POW_FLAG = 222;

    /// <summary>Grooming and Hygiene Products for Human Use </summary>
    public const short GROOMING_AND_HYGIENE_PRODUCTS_FOR_HUMAN_USE = 223;

    /// <summary>Grooming and Hygiene Products for Animal Use</summary>
    public const short GROOMING_AND_HYGIENE_PRODUCTS_FOR_ANIMAL_USE = 224;

    /// <summary>Toothpaste</summary>
    public const short TOOTHPASTE = 225;

    /// <summary>Gaming Coins-Metal Content is Greater than 80% </summary>
    public const short GAMING_COINS_METAL_CONTENT_IS_GREATER_THAN_80_PCT = 226;

    /// <summary>Gaming Coins-Metal Content is Less than 80% </summary>
    public const short GAMING_COINS_METAL_CONTENT_IS_LESS_THAN_80_PCT = 227;

    /// <summary>Marine Equipment </summary>
    public const short MARINE_EQUIPMENT = 228;

    /// <summary>Charcoal</summary>
    public const short CHARCOAL = 229;

    /// <summary>Coupon Books  </summary>
    public const short COUPON_BOOKS = 230;

    /// <summary>Supplies and Food for Seeing Eye Dog  </summary>
    public const short SUPPLIES_AND_FOOD_FOR_SEEING_EYE_DOG = 231;

    /// <summary>Non-Lead Based Batteries  </summary>
    public const short NON_LEAD_BASED_BATTERIES = 232;

    /// <summary>Candy</summary>
    public const short CANDY = 233;

    /// <summary>Chewing Gum</summary>
    public const short CHEWING_GUM = 234;

    /// <summary>Food Additives</summary>
    public const short FOOD_ADDITIVES = 235;

    /// <summary>Confectionary Items </summary>
    public const short CONFECTIONARY_ITEMS = 236;

    /// <summary>Ice  </summary>
    public const short ICE = 237;

    /// <summary>Dietary Supplements-Qualify  </summary>
    public const short DIETARY_SUPPLEMENTS_QUALIFY = 238;

    /// <summary>Dietary Supplements-Non Qualify </summary>
    public const short DIETARY_SUPPLEMENTS_NON_QUALIFY = 239;

    /// <summary>Retail - Published Monthly</summary>
    public const short RETAIL_PUBLISHED_MONTHLY = 240;

    /// <summary>Retail - Published Annually  </summary>
    public const short RETAIL_PUBLISHED_ANNUALLY = 241;

    /// <summary>Retail - Published Semi-Monthly </summary>
    public const short RETAIL_PUBLISHED_SEMI_MONTHLY = 242;

    /// <summary>Retail - Published Semi-Annually</summary>
    public const short RETAIL_PUBLISHED_SEMI_ANNUALLY = 243;

    /// <summary>Retail - Published Quarterly </summary>
    public const short RETAIL_PUBLISHED_QUARTERLY = 244;

    /// <summary>Retail - Published Weekly </summary>
    public const short RETAIL_PUBLISHED_WEEKLY = 245;

    /// <summary>Subscription-Monthly-US Mail </summary>
    public const short SUBSCRIPTION_MONTHLY_US_MAIL = 246;

    /// <summary>Subscription-Annually-Delivered by US Mail  </summary>
    public const short SUBSCRIPTION_ANNUALLY_DELIVERED_BY_US_MAIL = 247;

    /// <summary>Subscription-Semi-Monthly-Delivered by US Mail </summary>
    public const short SUBSCRIPTION_SEMI_MONTHLY_DELIVERED_BY_US_MAIL = 248;

    /// <summary>Subscription-Semi-Annually-Delivered by US Mail</summary>
    public const short SUBSCRIPTION_SEMI_ANNUALLY_DELIVERED_BY_US_MAIL = 249;

    /// <summary>Subscription-Quarterly-Delivered by US Mail </summary>
    public const short SUBSCRIPTION_QUARTERLY_DELIVERED_BY_US_MAIL = 250;

    /// <summary>Subscription-Weekly-Delivered by US Mail </summary>
    public const short SUBSCRIPTION_WEEKLY_DELIVERED_BY_US_MAIL = 251;

    /// <summary>Subscription-Monthly-Not Delivered by US Mail  </summary>
    public const short SUBSCRIPTION_MONTHLY_NOT_DELIVERED_BY_US_MAIL = 252;

    /// <summary>Subscription-Annually-Not Delivered by US Mail </summary>
    public const short SUBSCRIPTION_ANNUALLY_NOT_DELIVERED_BY_US_MAIL = 253;

    /// <summary>Subscription-Semi-Monthly-Not Delivered by US Mail</summary>
    public const short SUBSCRIPTION_SEMI_MONTHLY_NOT_DELIVERED_BY_US_MAIL = 254;

    /// <summary>Subscription-Semi-Annually-Not Delivered by USMail</summary>
    public const short SUBSCRIPTION_SEMI_ANNUALLY_NOT_DELIVERED_BY_USMAIL = 255;

    /// <summary>Subscription-Quarterly-Not Delivered by US Mail</summary>
    public const short SUBSCRIPTION_QUARTERLY_NOT_DELIVERED_BY_US_MAIL = 256;

    /// <summary>Subscription-Weekly-Not Delivered by US Mail</summary>
    public const short SUBSCRIPTION_WEEKLY_NOT_DELIVERED_BY_US_MAIL = 257;

    /// <summary>Subscription-Monthly-Door to Door Delivery  </summary>
    public const short SUBSCRIPTION_MONTHLY_DOOR_TO_DOOR_DELIVERY = 258;

    /// <summary>Subscription-Annually-Door to Door Delivery </summary>
    public const short SUBSCRIPTION_ANNUALLY_DOOR_TO_DOOR_DELIVERY = 259;

    /// <summary>Subscription-Semi-Monthly-Door to Door Delivery</summary>
    public const short SUBSCRIPTION_SEMI_MONTHLY_DOOR_TO_DOOR_DELIVERY = 260;

    /// <summary>Subscription-Semi-Annually-Door to Door Delivery  </summary>
    public const short SUBSCRIPTION_SEMI_ANNUALLY_DOOR_TO_DOOR_DELIVERY = 261;

    /// <summary>Subscription-Quarterly-Door to Door Delivery</summary>
    public const short SUBSCRIPTION_QUARTERLY_DOOR_TO_DOOR_DELIVERY = 262;

    /// <summary>Subscription-Weekly-Door to Door Delivery</summary>
    public const short SUBSCRIPTION_WEEKLY_DOOR_TO_DOOR_DELIVERY = 263;

    /// <summary>Equipment-Existing Facilities</summary>
    public const short EQUIPMENT_EXISTING_FACILITIES = 264;

    /// <summary>Equipment-Economic Expansion of Facilities  </summary>
    public const short EQUIPMENT_ECONOMIC_EXPANSION_OF_FACILITIES = 265;

    /// <summary>Equipment-Physical Expansion of Facilities  </summary>
    public const short EQUIPMENT_PHYSICAL_EXPANSION_OF_FACILITIES = 266;

    /// <summary>Equipment-New Facilities  </summary>
    public const short EQUIPMENT_NEW_FACILITIES = 267;

    /// <summary>Repair parts-Existing Facilities</summary>
    public const short REPAIR_PARTS_EXISTING_FACILITIES = 268;

    /// <summary>Repair Parts-Economic Expansion </summary>
    public const short REPAIR_PARTS_ECONOMIC_EXPANSION = 269;

    /// <summary>Repair Parts-Physical Expansion </summary>
    public const short REPAIR_PARTS_PHYSICAL_EXPANSION = 270;

    /// <summary>Repair Parts-New Facilities  </summary>
    public const short REPAIR_PARTS_NEW_FACILITIES = 271;

    /// <summary>Repair Labor-Separately Stated  </summary>
    public const short REPAIR_LABOR_SEPARATELY_STATED = 272;

    /// <summary>Repair Labor-Not Separately Stated </summary>
    public const short REPAIR_LABOR_NOT_SEPARATELY_STATED = 273;

    /// <summary>Installation Labor-Equipment-Separately Stated </summary>
    public const short INSTALLATION_LABOR_EQUIPMENT_SEPARATELY_STATED = 274;

    /// <summary>Installation Labor-Equipment-Not Separately Stated</summary>
    public const short INSTALLATION_LABOR_EQUIPMENT_NOT_SEPARATELY_STATED = 275;

    /// <summary>Automobile Specific -Equipment-Separately Stated  </summary>
    public const short AUTOMOBILE_SPECIFIC_EQUIPMENT_SEPARATELY_STATED = 276;

    /// <summary>Outside Installation Labor-Equip-Separately Stated</summary>
    public const short OUTSIDE_INSTALLATION_LABOR_EQUIP_SEPARATELY_STATED = 277;

    /// <summary>Repair Equipment-Separately Stated </summary>
    public const short REPAIR_EQUIPMENT_SEPARATELY_STATED = 278;

    /// <summary>Replacement Equipment-Separately Stated  </summary>
    public const short REPLACEMENT_EQUIPMENT_SEPARATELY_STATED = 279;

    /// <summary>Clean room Equipment</summary>
    public const short CLEAN_ROOM_EQUIPMENT = 280;

    /// <summary>Environmental Control Equip  </summary>
    public const short ENVIRONMENTAL_CONTROL_EQUIP = 281;

    /// <summary>Safety Equip  </summary>
    public const short SAFETY_EQUIP = 282;

    /// <summary>Packing  and Shipping Equip  </summary>
    public const short PACKING_AND_SHIPPING_EQUIP = 283;

    /// <summary>Intraplant Equip </summary>
    public const short INTRAPLANT_EQUIP = 284;

    /// <summary>Hand Tools </summary>
    public const short HAND_TOOLS = 285;

    /// <summary>Warehouse Equipment </summary>
    public const short WAREHOUSE_EQUIPMENT = 286;

    /// <summary>Not Home Use-Without A Prescription</summary>
    public const short NOT_HOME_USE_WITHOUT_A_PRESCRIPTION = 287;

    /// <summary>Not Home Use-With A Prescription</summary>
    public const short NOT_HOME_USE_WITH_A_PRESCRIPTION = 288;

    /// <summary>Not Home Use-Paid For By Medicare  </summary>
    public const short NOT_HOME_USE_PAID_FOR_BY_MEDICARE = 289;

    /// <summary>Not Home Use-Reimbursed By Medicare</summary>
    public const short NOT_HOME_USE_REIMBURSED_BY_MEDICARE = 290;

    /// <summary>Not Home Use-Paid For By Medicaid  </summary>
    public const short NOT_HOME_USE_PAID_FOR_BY_MEDICAID = 291;

    /// <summary>Not Home Use-Reimbursed By Medicaid</summary>
    public const short NOT_HOME_USE_REIMBURSED_BY_MEDICAID = 292;

    /// <summary>Home Use-Without A Prescription </summary>
    public const short HOME_USE_WITHOUT_A_PRESCRIPTION = 293;

    /// <summary>Home Use-With A Prescription </summary>
    public const short HOME_USE_WITH_A_PRESCRIPTION = 294;

    /// <summary>Home Use-Paid For By Medicare</summary>
    public const short HOME_USE_PAID_FOR_BY_MEDICARE = 295;

    /// <summary>Home Use-Reimbursed By Medicare </summary>
    public const short HOME_USE_REIMBURSED_BY_MEDICARE = 296;

    /// <summary>Home Use-Paid For By Medicaid</summary>
    public const short HOME_USE_PAID_FOR_BY_MEDICAID = 297;

    /// <summary>Home Use-Reimbursed By Medicaid </summary>
    public const short HOME_USE_REIMBURSED_BY_MEDICAID = 298;

    /// <summary>Equip Without a Prescription </summary>
    public const short EQUIP_WITHOUT_A_PRESCRIPTION = 299;

    /// <summary>Equip With a Prescription </summary>
    public const short EQUIP_WITH_A_PRESCRIPTION = 300;

    /// <summary>Equip Paid for by Medicare</summary>
    public const short EQUIP_PAID_FOR_BY_MEDICARE = 301;

    /// <summary>Equip Reimbursed by Medicare </summary>
    public const short EQUIP_REIMBURSED_BY_MEDICARE = 302;

    /// <summary>Equip Paid for by Medicaid</summary>
    public const short EQUIP_PAID_FOR_BY_MEDICAID = 303;

    /// <summary>Equip Reimbursed by Medicaid</summary>
    public const short EQUIP_REIMBURSED_BY_MEDICAID = 304;

    /// <summary>General-Without a Prescription  </summary>
    public const short GENERAL_WITHOUT_A_PRESCRIPTION = 305;

    /// <summary>General-With a Prescription  </summary>
    public const short GENERAL_WITH_A_PRESCRIPTION = 306;

    /// <summary>General-Paid for by Medicare </summary>
    public const short GENERAL_PAID_FOR_BY_MEDICARE = 307;

    /// <summary>General-Reimbursed by Medicare  </summary>
    public const short GENERAL_REIMBURSED_BY_MEDICARE = 308;

    /// <summary>General-Paid for by Medicaid </summary>
    public const short GENERAL_PAID_FOR_BY_MEDICAID = 309;

    /// <summary>General-Reimbursed by Medicaid  </summary>
    public const short GENERAL_REIMBURSED_BY_MEDICAID = 310;

    /// <summary>Corrective Eyeglasses-Without a Prescription</summary>
    public const short CORRECTIVE_EYEGLASSES_WITHOUT_A_PRESCRIPTION = 311;

    /// <summary>Corrective Eyeglasses-With a Prescription</summary>
    public const short CORRECTIVE_EYEGLASSES_WITH_A_PRESCRIPTION = 312;

    /// <summary>Corrective Eyeglasses-Paid for by Medicare  </summary>
    public const short CORRECTIVE_EYEGLASSES_PAID_FOR_BY_MEDICARE = 313;

    /// <summary>Corrective Eyeglasses-Reimbursed by Medicare</summary>
    public const short CORRECTIVE_EYEGLASSES_REIMBURSED_BY_MEDICARE = 314;

    /// <summary>Corrective Eyeglasses-Paid for by Medicaid  </summary>
    public const short CORRECTIVE_EYEGLASSES_PAID_FOR_BY_MEDICAID = 315;

    /// <summary>Corrective Eyeglasses-Reimbursed by Medicaid</summary>
    public const short CORRECTIVE_EYEGLASSES_REIMBURSED_BY_MEDICAID = 316;

    /// <summary>Contact Lenses-Without a prescription </summary>
    public const short CONTACT_LENSES_WITHOUT_A_PRESCRIPTION = 317;

    /// <summary>Contact Lenses-With a prescription </summary>
    public const short CONTACT_LENSES_WITH_A_PRESCRIPTION = 318;

    /// <summary>Contact Lenses-Paid for by Medicare</summary>
    public const short CONTACT_LENSES_PAID_FOR_BY_MEDICARE = 319;

    /// <summary>Contact Lenses-Reimbursed by Medicare </summary>
    public const short CONTACT_LENSES_REIMBURSED_BY_MEDICARE = 320;

    /// <summary>Contact Lenses-Paid for by Medicaid</summary>
    public const short CONTACT_LENSES_PAID_FOR_BY_MEDICAID = 321;

    /// <summary>Contact Lenses-Reimbursed by Medicaid </summary>
    public const short CONTACT_LENSES_REIMBURSED_BY_MEDICAID = 322;

    /// <summary>Hearing Aids-Without a Prescription</summary>
    public const short HEARING_AIDS_WITHOUT_A_PRESCRIPTION = 323;

    /// <summary>Hearing Aids-With a Prescription</summary>
    public const short HEARING_AIDS_WITH_A_PRESCRIPTION = 324;

    /// <summary>Hearing Aids-Paid for by Medicare  </summary>
    public const short HEARING_AIDS_PAID_FOR_BY_MEDICARE = 325;

    /// <summary>Hearing Aids-Reimbursed by Medicare</summary>
    public const short HEARING_AIDS_REIMBURSED_BY_MEDICARE = 326;

    /// <summary>Hearing Aids-Paid for by Medicaid  </summary>
    public const short HEARING_AIDS_PAID_FOR_BY_MEDICAID = 327;

    /// <summary>Hearing Aids-Reimbursed by Medicaid</summary>
    public const short HEARING_AIDS_REIMBURSED_BY_MEDICAID = 328;

    /// <summary>Dental Prosthesis-Without a prescription </summary>
    public const short DENTAL_PROSTHESIS_WITHOUT_A_PRESCRIPTION = 329;

    /// <summary>Dental Prosthesis-With a prescription </summary>
    public const short DENTAL_PROSTHESIS_WITH_A_PRESCRIPTION = 330;

    /// <summary>Dental Prosthesis-Paid for by Medicare</summary>
    public const short DENTAL_PROSTHESIS_PAID_FOR_BY_MEDICARE = 331;

    /// <summary>Dental Prosthesis-Reimbursed by Medicare </summary>
    public const short DENTAL_PROSTHESIS_REIMBURSED_BY_MEDICARE = 332;

    /// <summary>Dental Prosthesis-Paid for by Medicaid</summary>
    public const short DENTAL_PROSTHESIS_PAID_FOR_BY_MEDICAID = 333;

    /// <summary>Dental Prosthesis-Reimbursed by Medicaid </summary>
    public const short DENTAL_PROSTHESIS_REIMBURSED_BY_MEDICAID = 334;

    /// <summary>Low Emission Vehicle exceeding 10</summary>
    public const short LOW_EMISSION_VEHICLE_EXCEEDING_10 = 335;

    /// <summary>Vehicles sold to Native Americans  </summary>
    public const short VEHICLES_SOLD_TO_NATIVE_AMERICANS = 336;

    /// <summary>Motor Vehicles using Alternative Fuels</summary>
    public const short MOTOR_VEHICLES_USING_ALTERNATIVE_FUELS = 337;

    /// <summary>Low Speed Electrical Vehicles</summary>
    public const short LOW_SPEED_ELECTRICAL_VEHICLES = 338;

    /// <summary>Sale to Non-Residents  </summary>
    public const short SALE_TO_NON_RESIDENTS = 339;

    /// <summary>Trucks - General Rule  </summary>
    public const short TRUCKS_GENERAL_RULE = 340;

    /// <summary>Used in Interstate Commerce  </summary>
    public const short USED_IN_INTERSTATE_COMMERCE = 341;

    /// <summary>Trailer 13-16.5 Tons-Interstate Commerce </summary>
    public const short TRAILER_13_16_AND_HALF_TONS_INTERSTATE_COMMERCE = 342;

    /// <summary>Tractor Exceeds 16.5 Tons-Interstate Commerce  </summary>
    public const short TRACTOR_EXCEEDS_16_AND_HALF_TONS_INTERSTATE_COMMERCE = 343;

    /// <summary>Used as a Contact Carrier </summary>
    public const short USED_AS_A_CONTACT_CARRIER = 344;

    /// <summary>Trailer Exceeds 13 Tons-Contract Carrier </summary>
    public const short TRAILER_EXCEEDS_13_TONS_CONTRACT_CARRIER = 345;

    /// <summary>Tractor Exceeds 16.5 Tons-Contract Carrier  </summary>
    public const short TRACTOR_EXCEEDS_16_AND_HALF_TONS_CONTRACT_CARRIER = 346;

    /// <summary>Motor Boats</summary>
    public const short MOTOR_BOATS = 347;

    /// <summary>Aircraft</summary>
    public const short AIRCRAFT = 348;

    /// <summary>Aircraft for Interstate Transport  </summary>
    public const short AIRCRAFT_FOR_INTERSTATE_TRANSPORT = 349;

    /// <summary>Batteries Less than 12 Volts--Lead Based </summary>
    public const short BATTERIES_LESS_THAN_12_VOLTS_LEAD_BASED = 350;

    /// <summary>Batteries Greater than 12 Volts--Lead Based </summary>
    public const short BATTERIES_GREATER_THAN_12_VOLTS_LEAD_BASED = 351;

    /// <summary>Motorcycles</summary>
    public const short MOTORCYCLES = 352;

    /// <summary>Mopeds  </summary>
    public const short MOPEDS = 353;

    /// <summary>Off-Road Vehicles</summary>
    public const short OFF_ROAD_VEHICLES = 354;

    /// <summary>Snowmobiles</summary>
    public const short SNOWMOBILES = 355;

    /// <summary>Motor Oil  </summary>
    public const short MOTOR_OIL = 356;

    /// <summary>Antifreeze </summary>
    public const short ANTIFREEZE = 357;

    /// <summary>Boat Motor </summary>
    public const short BOAT_MOTOR = 358;

    /// <summary>Retail  </summary>
    public const short RETAIL = 359;

    /// <summary>CD ROM Microfiche</summary>
    public const short CD_ROM_MICROFICHE = 360;

    /// <summary>Digital Product - Retail  </summary>
    public const short DIGITAL_PRODUCT_RETAIL = 361;

    /// <summary>Digital Product - Subscription  </summary>
    public const short DIGITAL_PRODUCT_SUBSCRIPTION = 362;

    /// <summary>Subscription Mail</summary>
    public const short SUBSCRIPTION_MAIL = 363;

    /// <summary>Subscription Delivery  </summary>
    public const short SUBSCRIPTION_DELIVERY = 364;

    /// <summary>Food sold by a Food Manufacturer</summary>
    public const short FOOD_SOLD_BY_A_FOOD_MANUFACTURER = 365;

    /// <summary>Food sold in an unheated state  </summary>
    public const short FOOD_SOLD_IN_AN_UNHEATED_STATE = 366;

    /// <summary>Bakery items  </summary>
    public const short BAKERY_ITEMS = 367;

    /// <summary>Employee Meals--Full Price</summary>
    public const short EMPLOYEE_MEALS_FULL_PRICE = 368;

    /// <summary>Employee Meals--Reduced Price</summary>
    public const short EMPLOYEE_MEALS_REDUCED_PRICE = 369;

    /// <summary>Employee Meals--Free to Employees  </summary>
    public const short EMPLOYEE_MEALS_FREE_TO_EMPLOYEES = 370;

    /// <summary>Tips</summary>
    public const short TIPS = 371;

    /// <summary>Non-Tip Based Service Charge </summary>
    public const short NON_TIP_BASED_SERVICE_CHARGE = 373;

    /// <summary>Uniform Rental Service </summary>
    public const short UNIFORM_RENTAL_SERVICE = 374;

    /// <summary>Automotive Rental--30 Days or Less </summary>
    public const short AUTOMOTIVE_RENTAL_30_DAYS_OR_LESS = 375;

    /// <summary>Automotive Rental--30-180 Days  </summary>
    public const short AUTOMOTIVE_RENTAL_30_180_DAYS = 376;

    /// <summary>Automotive Rental--180 Days to 1 Year </summary>
    public const short AUTOMOTIVE_RENTAL_180_DAYS_TO_1_YEAR = 377;

    /// <summary>Automotive Rental--1 Year or Greater  </summary>
    public const short AUTOMOTIVE_RENTAL_1_YEAR_OR_GREATER = 378;

    /// <summary>Automotive Rental-0-30 Days-Tax Paid  </summary>
    public const short AUTOMOTIVE_RENTAL_0_30_DAYS_TAX_PAID = 379;

    /// <summary>Automotive Rental-31-180 Days-Tax Paid</summary>
    public const short AUTOMOTIVE_RENTAL_31_180_DAYS_TAX_PAID = 380;

    /// <summary>Automotive Rental-180 Days-1 Year-Tax Paid  </summary>
    public const short AUTOMOTIVE_RENTAL_180_DAYS_1_YEAR_TAX_PAID = 381;

    /// <summary>Automotive Rental-Greater than 1 Year-Tax Paid </summary>
    public const short AUTOMOTIVE_RENTAL_GREATER_THAN_1_YEAR_TAX_PAID = 382;

    /// <summary>Lease of Automobile to be registered by lessee </summary>
    public const short LEASE_OF_AUTOMOBILE_TO_BE_REGISTERED_BY_LESSEE = 383;

    /// <summary>Amusement Related Property</summary>
    public const short AMUSEMENT_RELATED_PROPERTY = 384;

    /// <summary>Rentals Incidental to Service</summary>
    public const short RENTALS_INCIDENTAL_TO_SERVICE = 385;

    /// <summary>Movie Rentals--Private Use--Physical Medium </summary>
    public const short MOVIE_RENTALS_PRIVATE_USE_PHYSICAL_MEDIUM = 386;

    /// <summary>Movie Rentals--Private Use--Digital Download</summary>
    public const short MOVIE_RENTALS_PRIVATE_USE_DIGITAL_DOWNLOAD = 387;

    /// <summary>Movie Rentals--As part of exhibition to public </summary>
    public const short MOVIE_RENTALS_AS_PART_OF_EXHIBITION_TO_PUBLIC = 388;

    /// <summary>Movie Rentals--To a Television Station</summary>
    public const short MOVIE_RENTALS_TO_A_TELEVISION_STATION = 389;

    /// <summary>Dry Cleaning-Clothing  </summary>
    public const short DRY_CLEANING_CLOTHING = 390;

    /// <summary>Dry Cleaning-Non Clothing </summary>
    public const short DRY_CLEANING_NON_CLOTHING = 391;

    /// <summary>Cleaning Services</summary>
    public const short CLEANING_SERVICES = 392;

    /// <summary>Laundry and Clothing Care-Other Items</summary>
    public const short LAUNDRY_AND_CLOTHING_CARE_OTHER_ITEMS = 393;

    /// <summary>Laundry and Clothing Care-Cloth Diapers </summary>
    public const short LAUNDRY_AND_CLOTHING_CARE_CLOTH_DIAPERS = 394;

    /// <summary>Laundry and Clothing Care-Coin Operated </summary>
    public const short LAUNDRY_AND_CLOTHING_CARE_COIN_OPERATED = 395;

    /// <summary>Rug Cleaning off customer premises </summary>
    public const short RUG_CLEANING_OFF_CUSTOMER_PREMISES = 396;

    /// <summary>Rug Cleaning on customer premises  </summary>
    public const short RUG_CLEANING_ON_CUSTOMER_PREMISES = 397;

    /// <summary>Washing Motor Vehicles </summary>
    public const short WASHING_MOTOR_VEHICLES = 398;

    /// <summary>Washing Motor Vehicles-Coin Operated Device </summary>
    public const short WASHING_MOTOR_VEHICLES_COIN_OPERATED_DEVICE = 399;

    /// <summary>Solid Waste Disposal</summary>
    public const short SOLID_WASTE_DISPOSAL = 400;

    /// <summary>Swimming Pool Services </summary>
    public const short SWIMMING_POOL_SERVICES = 401;

    /// <summary>Hotel Rooms Less than 28 Days</summary>
    public const short HOTEL_ROOMS_LESS_THAN_28_DAYS = 402;

    /// <summary>Hotel Rooms 28-29 Days </summary>
    public const short HOTEL_ROOMS_28_29_DAYS = 403;

    /// <summary>Hotel Rooms 30-31 Days </summary>
    public const short HOTEL_ROOMS_30_31_DAYS = 404;

    /// <summary>Hotel Rooms 32-60 Days </summary>
    public const short HOTEL_ROOMS_32_60_DAYS = 405;

    /// <summary>Hotel Rooms 61-90 Days </summary>
    public const short HOTEL_ROOMS_61_90_DAYS = 406;

    /// <summary>Hotel Rooms-91-120 Days</summary>
    public const short HOTEL_ROOMS_91_120_DAYS = 407;

    /// <summary>Hotel Rooms 121-180 Days  </summary>
    public const short HOTEL_ROOMS_121_180_DAYS = 408;

    /// <summary>Hotel Rooms Greater than 180 Days  </summary>
    public const short HOTEL_ROOMS_GREATER_THAN_180_DAYS = 409;

    /// <summary>Photography Services-Labor Only </summary>
    public const short PHOTOGRAPHY_SERVICES_LABOR_ONLY = 410;

    /// <summary>Photography Services-Labor with pictures </summary>
    public const short PHOTOGRAPHY_SERVICES_LABOR_WITH_PICTURES = 411;

    /// <summary>Negative to Standard Sized Pictures-Labor Only </summary>
    public const short NEGATIVE_TO_STANDARD_SIZED_PICTURES_LABOR_ONLY = 412;

    /// <summary>Negative to Enlargement Sized Pictures-Labor Only </summary>
    public const short NEGATIVE_TO_ENLARGEMENT_SIZED_PICTURES_LABOR_ONLY = 413;

    /// <summary>Printing Services</summary>
    public const short PRINTING_SERVICES = 414;

    /// <summary>Copying Services </summary>
    public const short COPYING_SERVICES = 415;

    /// <summary>Credit Card Processing Fee-Part of Sale  </summary>
    public const short CREDIT_CARD_PROCESSING_FEE_PART_OF_SALE = 416;

    /// <summary>Credit Card Processing Fee-Separate Sale </summary>
    public const short CREDIT_CARD_PROCESSING_FEE_SEPARATE_SALE = 417;

    /// <summary>Professional Services  </summary>
    public const short PROFESSIONAL_SERVICES = 418;

    /// <summary>Investigative Services </summary>
    public const short INVESTIGATIVE_SERVICES = 419;

    /// <summary>Protection and Security Services  </summary>
    public const short PROTECTION_AND_SECURITY_SERVICES = 420;

    /// <summary>Pest Control  </summary>
    public const short PEST_CONTROL = 421;

    /// <summary>Interior Design Services  </summary>
    public const short INTERIOR_DESIGN_SERVICES = 422;

    /// <summary>Skin Alteration and Care </summary>
    public const short SKIN_ALTERATION_AND_CARE = 423;

    /// <summary>Manicure and Pedicure </summary>
    public const short MANICURE_AND_PEDICURE = 424;

    /// <summary>Funeral Services </summary>
    public const short FUNERAL_SERVICES = 425;

    /// <summary>Cosmetic Medical Procedures  </summary>
    public const short COSMETIC_MEDICAL_PROCEDURES = 426;

    /// <summary>Professional Medical Services</summary>
    public const short PROFESSIONAL_MEDICAL_SERVICES = 427;

    /// <summary>Title</summary>
    public const short TITLE = 428;

    /// <summary>Dating Service</summary>
    public const short DATING_SERVICE = 429;

    /// <summary>Escrow  </summary>
    public const short ESCROW = 430;

    /// <summary>Massages</summary>
    public const short MASSAGES = 431;

    /// <summary>Gift Wrapping </summary>
    public const short GIFT_WRAPPING = 432;

    /// <summary>Floral Services  </summary>
    public const short FLORAL_SERVICES = 433;

    /// <summary>Advertising</summary>
    public const short ADVERTISING = 434;

    /// <summary>Credit and Reporting Services</summary>
    public const short CREDIT_AND_REPORTING_SERVICES = 435;

    /// <summary>Personnel Services  </summary>
    public const short PERSONNEL_SERVICES = 436;

    /// <summary>Lettering Services  </summary>
    public const short LETTERING_SERVICES = 437;

    /// <summary>Collection Services </summary>
    public const short COLLECTION_SERVICES = 438;

    /// <summary>Background Music Services </summary>
    public const short BACKGROUND_MUSIC_SERVICES = 439;

    /// <summary>Locksmith Services  </summary>
    public const short LOCKSMITH_SERVICES = 440;

    /// <summary>Lobbying</summary>
    public const short LOBBYING = 441;

    /// <summary>Flight Instruction  </summary>
    public const short FLIGHT_INSTRUCTION = 442;

    /// <summary>Investment Counseling  </summary>
    public const short INVESTMENT_COUNSELING = 443;

    /// <summary>Service Chg. Financial Institution </summary>
    public const short SERVICE_CHG_FINANCIAL_INSTITUTION = 444;

    /// <summary>Tow Service</summary>
    public const short TOW_SERVICE = 445;

    /// <summary>Taxidermy  </summary>
    public const short TAXIDERMY = 446;

    /// <summary>Telephone Answering Service  </summary>
    public const short TELEPHONE_ANSWERING_SERVICE = 447;

    /// <summary>Limousine Service</summary>
    public const short LIMOUSINE_SERVICE = 448;

    /// <summary>Architecture  </summary>
    public const short ARCHITECTURE = 449;

    /// <summary>Tanning Services </summary>
    public const short TANNING_SERVICES = 450;

    /// <summary>Pet Grooming--Not done in medical setting</summary>
    public const short PET_GROOMING_NOT_DONE_IN_MEDICAL_SETTING = 451;

    /// <summary>Pet Grooming--Done in Medical Setting </summary>
    public const short PET_GROOMING_DONE_IN_MEDICAL_SETTING = 452;

    /// <summary>Engraving  </summary>
    public const short ENGRAVING = 453;

    /// <summary>House Moving  </summary>
    public const short HOUSE_MOVING = 454;

    /// <summary>Counseling </summary>
    public const short COUNSELING = 455;

    /// <summary>Day Care Services</summary>
    public const short DAY_CARE_SERVICES = 456;

    /// <summary>Investment Commissions </summary>
    public const short INVESTMENT_COMMISSIONS = 457;

    /// <summary>Sale of Insurance</summary>
    public const short SALE_OF_INSURANCE = 458;

    /// <summary>Sporting Event with Food or Property  </summary>
    public const short SPORTING_EVENT_WITH_FOOD_OR_PROPERTY = 459;

    /// <summary>Sporting Event without Food or Property  </summary>
    public const short SPORTING_EVENT_WITHOUT_FOOD_OR_PROPERTY = 460;

    /// <summary>Amusement Park Entry with Food or Property  </summary>
    public const short AMUSEMENT_PARK_ENTRY_WITH_FOOD_OR_PROPERTY = 461;

    /// <summary>Amusement Park Entry without Food or Property  </summary>
    public const short AMUSEMENT_PARK_ENTRY_WITHOUT_FOOD_OR_PROPERTY = 462;

    /// <summary>Other Amusement Entry with Food or Property </summary>
    public const short OTHER_AMUSEMENT_ENTRY_WITH_FOOD_OR_PROPERTY = 463;

    /// <summary>Other Amusement Entry without Food or Property </summary>
    public const short OTHER_AMUSEMENT_ENTRY_WITHOUT_FOOD_OR_PROPERTY = 464;

    /// <summary>Admission to Boxing and Wrestling  </summary>
    public const short ADMISSION_TO_BOXING_AND_WRESTLING = 465;

    /// <summary>Admission to Horse Racing </summary>
    public const short ADMISSION_TO_HORSE_RACING = 466;

    /// <summary>Admission to a Motion Picture</summary>
    public const short ADMISSION_TO_A_MOTION_PICTURE = 467;

    /// <summary>Tours for 8-25 people  </summary>
    public const short TOURS_FOR_8_25_PEOPLE = 468;

    /// <summary>Tours for more than 25 people</summary>
    public const short TOURS_FOR_MORE_THAN_25_PEOPLE = 469;

    /// <summary>Tours for 8-25 people--Commissions </summary>
    public const short TOURS_FOR_8_25_PEOPLE_COMMISSIONS = 470;

    /// <summary>Tours for more than 25 people--Commissions  </summary>
    public const short TOURS_FOR_MORE_THAN_25_PEOPLE_COMMISSIONS = 471;

    /// <summary>Sport</summary>
    public const short SPORT = 472;

    /// <summary>Repair Parts - General Rule  </summary>
    public const short REPAIR_PARTS_GENERAL_RULE = 473;

    /// <summary>Repair and Labor Combined </summary>
    public const short REPAIR_AND_LABOR_COMBINED = 474;

    /// <summary>Parts used in Clothing or Shoes </summary>
    public const short PARTS_USED_IN_CLOTHING_OR_SHOES = 475;

    /// <summary>Parts used in repair of Commercial Airplanes</summary>
    public const short PARTS_USED_IN_REPAIR_OF_COMMERCIAL_AIRPLANES = 476;

    /// <summary>Extended Warranty - Repair Parts Used </summary>
    public const short EXTENDED_WARRANTY_REPAIR_PARTS_USED = 477;

    /// <summary>Extended Warranty - Service Repairs Used </summary>
    public const short EXTENDED_WARRANTY_SERVICE_REPAIRS_USED = 478;

    /// <summary>Repair Labor - General Rule  </summary>
    public const short REPAIR_LABOR_GENERAL_RULE = 479;

    /// <summary>Repairs of Clothing </summary>
    public const short REPAIRS_OF_CLOTHING = 480;

    /// <summary>Repair of Railroad Rolling Stock and Engines</summary>
    public const short REPAIR_OF_RAILROAD_ROLLING_STOCK_AND_ENGINES = 481;

    /// <summary>Repair of Motor Vehicle</summary>
    public const short REPAIR_OF_MOTOR_VEHICLE = 482;

    /// <summary>Shoe Repair and Cleaning  </summary>
    public const short SHOE_REPAIR_AND_CLEANING = 483;

    /// <summary>Automotive Painting </summary>
    public const short AUTOMOTIVE_PAINTING = 484;

    /// <summary>Landscaping and Lawn Care</summary>
    public const short LANDSCAPING_AND_LAWN_CARE = 485;

    /// <summary>Snow Removal  </summary>
    public const short SNOW_REMOVAL = 486;

    /// <summary>Repair of Commercial Jet Aircraft  </summary>
    public const short REPAIR_OF_COMMERCIAL_JET_AIRCRAFT = 487;

    /// <summary>Jewelry Repair</summary>
    public const short JEWELRY_REPAIR = 488;

    /// <summary>Storage </summary>
    public const short STORAGE = 489;

    /// <summary>Parking </summary>
    public const short PARKING = 490;

    /// <summary>Canned Software  </summary>
    public const short CANNED_SOFTWARE = 491;

    /// <summary>Modified Charges </summary>
    public const short MODIFIED_CHARGES = 492;

    /// <summary>Modified Software</summary>
    public const short MODIFIED_SOFTWARE = 493;

    /// <summary>Custom Software  </summary>
    public const short CUSTOM_SOFTWARE = 494;

    /// <summary>Canned Software-Load and Leave  </summary>
    public const short CANNED_SOFTWARE_LOAD_AND_LEAVE = 495;

    /// <summary>Custom Software-Load and Leave  </summary>
    public const short CUSTOM_SOFTWARE_LOAD_AND_LEAVE = 496;

    /// <summary>Licensed Software-Load and Leave</summary>
    public const short LICENSED_SOFTWARE_LOAD_AND_LEAVE = 497;

    /// <summary>Modified Software-Load and Leave</summary>
    public const short MODIFIED_SOFTWARE_LOAD_AND_LEAVE = 498;

    /// <summary>Downloaded Custom Software</summary>
    public const short DOWNLOADED_CUSTOM_SOFTWARE = 499;

    /// <summary>Downloaded Canned Software</summary>
    public const short DOWNLOADED_CANNED_SOFTWARE = 500;

    /// <summary>Licensed Software-Download</summary>
    public const short LICENSED_SOFTWARE_DOWNLOAD = 501;

    /// <summary>Modified Software-Download</summary>
    public const short MODIFIED_SOFTWARE_DOWNLOAD = 502;

    /// <summary>Software Set Up-Optional-Canned </summary>
    public const short SOFTWARE_SET_UP_OPTIONAL_CANNED = 503;

    /// <summary>Software Set Up-Optional-Custom </summary>
    public const short SOFTWARE_SET_UP_OPTIONAL_CUSTOM = 504;

    /// <summary>Software Set Up-Optional-Downloaded</summary>
    public const short SOFTWARE_SET_UP_OPTIONAL_DOWNLOADED = 505;

    /// <summary>Software Set Up-Optional-Load and Leave  </summary>
    public const short SOFTWARE_SET_UP_OPTIONAL_LOAD_AND_LEAVE = 506;

    /// <summary>Software Set Up-Optional-Modified  </summary>
    public const short SOFTWARE_SET_UP_OPTIONAL_MODIFIED = 507;

    /// <summary>Software Set Up-Mandatory-Canned</summary>
    public const short SOFTWARE_SET_UP_MANDATORY_CANNED = 508;

    /// <summary>Software Set Up-Mandatory-Custom</summary>
    public const short SOFTWARE_SET_UP_MANDATORY_CUSTOM = 509;

    /// <summary>Software Set Up-Mandatory-Downloaded  </summary>
    public const short SOFTWARE_SET_UP_MANDATORY_DOWNLOADED = 510;

    /// <summary>Software Set Up-Mandatory-Load and Leave </summary>
    public const short SOFTWARE_SET_UP_MANDATORY_LOAD_AND_LEAVE = 511;

    /// <summary>Software Set Up-Mandatory-Modified </summary>
    public const short SOFTWARE_SET_UP_MANDATORY_MODIFIED = 512;

    /// <summary>Computer Consulting-Optional-Canned</summary>
    public const short COMPUTER_CONSULTING_OPTIONAL_CANNED = 513;

    /// <summary>Computer Consulting-Mandatory-Canned  </summary>
    public const short COMPUTER_CONSULTING_MANDATORY_CANNED = 514;

    /// <summary>Computer Consulting-Optional-Custom</summary>
    public const short COMPUTER_CONSULTING_OPTIONAL_CUSTOM = 515;

    /// <summary>Computer Consulting-Mandatory-Custom  </summary>
    public const short COMPUTER_CONSULTING_MANDATORY_CUSTOM = 516;

    /// <summary>Computer Consulting-Optional-Downloaded  </summary>
    public const short COMPUTER_CONSULTING_OPTIONAL_DOWNLOADED = 517;

    /// <summary>Computer Consulting-Mandatory-Downloaded </summary>
    public const short COMPUTER_CONSULTING_MANDATORY_DOWNLOADED = 518;

    /// <summary>Computer Consulting-Optional-Load and Leave </summary>
    public const short COMPUTER_CONSULTING_OPTIONAL_LOAD_AND_LEAVE = 519;

    /// <summary>Computer Consulting-Mandatory-Load and Leave</summary>
    public const short COMPUTER_CONSULTING_MANDATORY_LOAD_AND_LEAVE = 520;

    /// <summary>Computer Consulting-Optional-Modified </summary>
    public const short COMPUTER_CONSULTING_OPTIONAL_MODIFIED = 521;

    /// <summary>Computer Consulting-Mandatory-Modified</summary>
    public const short COMPUTER_CONSULTING_MANDATORY_MODIFIED = 522;

    /// <summary>Computer Training-Optional-Canned  </summary>
    public const short COMPUTER_TRAINING_OPTIONAL_CANNED = 523;

    /// <summary>Computer Training-Mandatory-Canned </summary>
    public const short COMPUTER_TRAINING_MANDATORY_CANNED = 524;

    /// <summary>Computer Training-Optional-Custom  </summary>
    public const short COMPUTER_TRAINING_OPTIONAL_CUSTOM = 525;

    /// <summary>Computer Training-Mandatory-Custom </summary>
    public const short COMPUTER_TRAINING_MANDATORY_CUSTOM = 526;

    /// <summary>Computer Training-Optional-Downloaded </summary>
    public const short COMPUTER_TRAINING_OPTIONAL_DOWNLOADED = 527;

    /// <summary>Computer Training-Mandatory-Downloaded</summary>
    public const short COMPUTER_TRAINING_MANDATORY_DOWNLOADED = 528;

    /// <summary>Computer Training-Optional-Load and Leave</summary>
    public const short COMPUTER_TRAINING_OPTIONAL_LOAD_AND_LEAVE = 529;

    /// <summary>Computer Training-Mandatory-Load and Leave  </summary>
    public const short COMPUTER_TRAINING_MANDATORY_LOAD_AND_LEAVE = 530;

    /// <summary>Computer Training-Optional-Modified</summary>
    public const short COMPUTER_TRAINING_OPTIONAL_MODIFIED = 531;

    /// <summary>Computer Training-Mandatory-Modified  </summary>
    public const short COMPUTER_TRAINING_MANDATORY_MODIFIED = 532;

    /// <summary>Cigarettes </summary>
    public const short CIGARETTES = 535;

    /// <summary>Useful Life Between 12 Months and 3 years</summary>
    public const short USEFUL_LIFE_BETWEEN_12_MONTHS_AND_3_YEARS = 536;

    /// <summary>Useful Life Between 6-12 Months </summary>
    public const short USEFUL_LIFE_BETWEEN_6_12_MONTHS = 537;

    /// <summary>Useful Life Exceeds 3 years  </summary>
    public const short USEFUL_LIFE_EXCEEDS_3_YEARS = 538;

    /// <summary>Useful Life Less Than 6 Months  </summary>
    public const short USEFUL_LIFE_LESS_THAN_6_MONTHS = 539;

    /// <summary>Candy Sold For $0.76 or More </summary>
    public const short CANDY_SOLD_FOR_76_CENTS_OR_MORE = 540;

    /// <summary>Candy Sold For $0.50 or Less </summary>
    public const short CANDY_SOLD_FOR_50_CENTS_OR_LESS = 541;

    /// <summary>Candy Between $0.51 and $0.75</summary>
    public const short CANDY_BETWEEN_51_AND_75_CENTS = 542;

    /// <summary>Chewing Gum Sold For $0.76 or More </summary>
    public const short CHEWING_GUM_SOLD_FOR_76_CENTS_OR_MORE = 543;

    /// <summary>Chewing Gum Sold For $0.50 or Less </summary>
    public const short CHEWING_GUM_SOLD_FOR_50_CENTS_OR_LESS = 544;

    /// <summary>Chewing Gum Between $0.51 and $0.75</summary>
    public const short CHEWING_GUM_BETWEEN_51_AND_75_CENTS = 545;

    /// <summary>Hot Prepared Food</summary>
    public const short HOT_PREPARED_FOOD = 546;

    /// <summary>Carbonated Beverages For $0.76 or More</summary>
    public const short CARBONATED_BEVERAGES_FOR_76_CENTS_OR_MORE = 547;

    /// <summary>Carbonated Beverages For $0.51 to $0.75  </summary>
    public const short CARBONATED_BEVERAGES_FOR_51_TO_75_CENTS = 548;

    /// <summary>Carbonated Beverages For $0.50 or Less</summary>
    public const short CARBONATED_BEVERAGES_FOR_50_CENTS_OR_LESS = 549;

    /// <summary>Non-Carbonated Beverages  </summary>
    public const short NON_CARBONATED_BEVERAGES = 550;

    /// <summary>Hot Beverages </summary>
    public const short HOT_BEVERAGES = 551;

    /// <summary>Public-Physical Transmission </summary>
    public const short PUBLIC_PHYSICAL_TRANSMISSION = 552;

    /// <summary>Public-Electronic Transmission  </summary>
    public const short PUBLIC_ELECTRONIC_TRANSMISSION = 553;

    /// <summary>Private-Physical Transmission</summary>
    public const short PRIVATE_PHYSICAL_TRANSMISSION = 554;

    /// <summary>Private-Electronic Transmission </summary>
    public const short PRIVATE_ELECTRONIC_TRANSMISSION = 555;

    /// <summary> Licensed Software Physical Transmission </summary>
    public const short LICENSED_SOFTWARE_PHYSICAL_TRANSMISSION = 556;

    /// <summary> Information Systems Services	  </summary>
    public const short INFORMATION_SYSTEMS_SERVICES = 557;

    /// <summary> Report Physical Transmission </summary>
    public const short REPORT_PHYSICAL_TRANSMISSION = 558;

    /// <summary> Remote Information Retrieval</summary>
    public const short REMOTE_INFORMATION_RETRIEVAL = 559;

    /// <summary>Download from Internet</summary>
    public const short DOWNLOAD_FROM_INTERNET = 560;

    /// <summary>Download to Phone</summary>
    public const short DOWNLOAD_TO_PHONE = 561;

    /// <summary>
    /// Interstate Local Loop.
    /// </summary>
    public const short INTERSTATE_LOCAL_LOOP = 562;

    /// <summary>Lease-Facilities</summary>
    public const short LEASE_FACILITIES = 563;

    /// <summary>Lease-Non-Facilities</summary>
    public const short LEASE_NON_FACILITIES = 564;

    /// <summary>Debit-Wireless</summary>
    public const short DEBIT_WIRELESS = 565;

    /// <summary>PBX-Outbound-Channel</summary>
    public const short PBX_OUTBOUND_CHANNEL = 566;

    /// <summary>PBX-Outbound-Channel-Bundle</summary>
    public const short PBX_OUTBOUND_CHANNEL_BUNDLE = 567;

    /// <summary>Central Office Equipment-Sales</summary>
    public const short CENTRAL_OFFICE_EQUIPMENT_SALES = 568;

    /// <summary>Central Office Equipment-Use</summary>
    public const short CENTRAL_OFFICE_EQUIPMENT_USE = 569;

    /// <summary>Directory Listing</summary>
    public const short DIRECTORY_LISTING = 570;

    /// <summary>Recycling</summary>
    public const short RECYCLING = 571;

    /// <summary>Digital Download</summary>
    public const short DIGITAL_DOWNLOAD = 572;

    /// <summary>Fixture</summary>
    public const short FIXTURE = 574;

    /// <summary>Conference Bridge, Intrastate</summary>
    public const short CONFERENCE_BRIDGE_INTRASTATE = 575;

    /// <summary>Conference Bridge, Intrastate w Dial-in</summary>
    public const short CONFERENCE_BRIDGE_INTRASTATE_W_DIAL_IN = 576;

    /// <summary>Enhanced Features</summary>
    public const short ENHANCED_FEATURES = 577;

    /// <summary>PBX</summary>
    public const short PBX = 578;

    /// <summary>PBX High Capacity</summary>
    public const short PBX_HIGH_CAPACITY = 579;

    /// <summary>High Capacity Extension</summary>
    public const short HIGH_CAPACITY_EXTENSION = 580;

    /// <summary>High Capacity Extension Bundle</summary>
    public const short HIGH_CAPACITY_EXTENSION_BUNDLE = 581;

    /// <summary>High Capacity Outbound Channel</summary>
    public const short HIGH_CAPACITY_OUTBOUND_CHANNEL = 582;

    /// <summary>High Capacity Outbound Channel Bundle</summary>
    public const short HIGH_CAPACITY_OUTBOUND_CHANNEL_BUNDLE = 583;

    /// <summary>Digital Channel Tier</summary>
    public const short DIGITAL_CHANNEL_TIER = 584;

    /// <summary>Interstate MPLS</summary>
    public const short INTERSTATE_MPLS = 585;

    /// <summary>Intrastate MPLS</summary>
    public const short INTRASTATE_MPLS = 586;

    /// <summary>Centrex Outbound Channel</summary>
    public const short CENTREX_OUTBOUND_CHANNEL = 587;

    /// <summary>Centrex Outbound Channel Bundle</summary>
    public const short CENTREX_OUTBOUND_CHANNEL_BUNDLE = 588;

    /// <summary>Conference Bridge-Interstate</summary>
    public const short CONFERENCE_BRIDGE_INTERSTATE = 589;

    /// <summary>Reserved_590</summary>
    public const short RESERVED_590 = 590;

    /// <summary>Access Charge-No Contract</summary>
    public const short ACCESS_CHARGE_NO_CONTRACT = 591;

    /// <summary>Access Number-No Contract</summary>
    public const short ACCESS_NUMBER_NO_CONTRACT = 592;

    /// <summary>Info Svcs-Private Physical Trans</summary>
    public const short INFO_SVCS_PRIVATE_PHYSICAL_TRANS = 593;

    /// <summary>Info Svcs-Private Electronic Trans</summary>
    public const short INFO_SVCS_PRIVATE_ELECTRONIC_TRANS = 594;

    /// <summary>Downloaded licensed software</summary>
    public const short DOWNLOADED_LICENSED_SOFTWARE = 595;

    /// <summary>Access-Local Only Service </summary>
    public const short ACCESS_LOCAL_ONLY_SERVICE = 596;

    /// <summary>Info Svcs-Public-Electronic Trans</summary>
    public const short INFO_SVCS_PUBLIC_ELECTRONIC_TRANS = 597;

    /// <summary>Info Svcs-Public Physical Trans</summary>
    public const short INFO_SVCS_PUBLIC_PHYSICAL_TRANS = 598;

    /// <summary>E-mail hosting service</summary>
    public const short E_MAIL_HOSTING_SERVICE = 599;
  }

  /// <summary>
  /// Tax Types.
  /// </summary>
  public class TaxType
  {
    /// <summary>
    /// For failure handling
    /// </summary>
    public const short UNDEFINED = -1;

    /// <summary>
    /// Sales Tax
    /// </summary>
    public const short SALES_TAX = 1;

    /// <summary>
    /// Business and Occupation Tax
    /// </summary>
    public const short BUSINESS_OCCUPATION_TAX = 2;

    /// <summary>
    /// Carrier Gross Receipts
    /// </summary>
    public const short CARRIER_GROSS_RECEIPTS = 3;

    /// <summary>
    /// District Tax
    /// </summary>
    public const short DISTRICT_TAX = 4;

    /// <summary>
    /// Excise Tax
    /// </summary>
    public const short EXCISE_TAX = 5;

    /// <summary>
    /// Federal Excise Tax
    /// </summary>
    public const short FEDERAL_EXCISE = 6;

    /// <summary>
    /// Federal Universal Service Fund A - School
    /// </summary>
    public const short FED_USF_SCHOOL_A = 7;

    /// <summary>
    /// License Tax
    /// </summary>
    public const short LICENSE_TAX = 8;

    /// <summary>
    /// Public Utility Commission Fee
    /// </summary>
    public const short PUC_FEE = 9;

    /// <summary>
    /// E911 Tax
    /// </summary>
    public const short E911_TAX = 10;

    /// <summary>
    /// Service Tax
    /// </summary>
    public const short SERVICE_TAX = 11;

    /// <summary>
    /// Special Tax
    /// </summary>
    public const short SPECIAL_TAX = 12;

    /// <summary>
    /// State Universal Service Fund
    /// </summary>
    public const short STATE_USF = 13;

    /// <summary>
    /// Statutory Gross Receipts
    /// </summary>
    public const short STATUTORY_GROSS_RECEIPTS = 14;

    /// <summary>
    /// Surcharge
    /// </summary>
    public const short SURCHARGE = 15;

    /// <summary>
    /// Utility Users Tax
    /// </summary>
    public const short UTILITY_USERS_TAX = 16;

    /// <summary>
    /// Sales Web Hosting
    /// </summary>
    public const short SALES_WEB_HOSTING = 17;

    /// <summary>
    /// Federal USF Combined High Cost and School
    /// </summary>
    public const short FED_USF_HIGHCOST_B = 18;

    /// <summary>
    /// State High Cost Fund
    /// </summary>
    public const short STATE_HIGH_COST_FUND = 19;

    /// <summary>
    /// State Deaf and Disabled Fund
    /// </summary>
    public const short STATE_DEAF_DISABLED_FUND = 20;

    /// <summary>
    /// California Teleconnect Fund
    /// </summary>
    public const short CA_TELECONNECT_FUND = 21;

    /// <summary>
    /// Universal Lifeline Telephone Service Charge
    /// </summary>
    public const short UNIVERSAL_LIFELINE_TELEPHONE_SERVICE_CHARGE = 22;

    /// <summary>
    /// Telecommunications Relay Service Charge
    /// </summary>
    public const short TELECOMMUNICATIONS_RELAY_SERVICE_CHARGE = 23;

    /// <summary>
    /// Telecommunications Infrastructure Maintenance Fee
    /// </summary>
    public const short TELECOMMUNICATIONS_INFRASTRUCTURE_MAINTENANCE_FEE = 24;

    /// <summary>
    /// State Poison Control Fund
    /// </summary>
    public const short POISON_CONTROL_FUND = 25;

    /// <summary>
    /// Telecommunications Infrastructure Fund
    /// </summary>
    public const short TELCOMMUNICATIONS_INFRASTRUCTURE_FUND = 26;

    /// <summary>
    /// New York Metropolitan Commuter Transportation District 186c
    /// </summary>
    public const short NY_MCTD_186c = 27;

    /// <summary>
    /// New York Metropolitan Commuter Transportation District 184a
    /// </summary>
    public const short NY_MCTD_184a = 28;

    /// <summary>
    /// Franchise Tax
    /// </summary>
    public const short FRANCHISE_TAX = 29;

    /// <summary>
    /// Utility Users Tax - Business
    /// </summary>
    public const short UTILITY_USERS_TAX_BUSINESS = 30;

    /// <summary>
    /// Federal Telecommunications Relay Service
    /// </summary>
    public const short FED_TELECOMMUNICATIONS_RELAY_SERVICE = 31;

    /// <summary>
    /// District Tax (Residential)
    /// </summary>
    public const short DISTRICT_TAX_RESIDENTIAL_ONLY = 32;

    /// <summary>
    /// Transit Tax
    /// </summary>
    public const short TRANSIT_TAX = 33;

    /// <summary>
    /// Telecommunications Assistance Service Fund
    /// </summary>
    public const short TELECOMMUNICATIONS_ASSISTANCE_SERVICE_FUND = 34;

    /// <summary>
    /// Telecommunications Assistance Service Fund
    /// </summary>
    public const short TELECOMMUNICATIONS_ASSISTANCE_FUND = 34;

    /// <summary>
    /// E911 Tax (Business)
    /// </summary>
    public const short E911_BUSINESS = 35;

    /// <summary>
    /// Telecommunications Relay Service Surcharge (Business)
    /// </summary>
    public const short TRS_BUSINESS = 36;

    /// <summary>
    /// Universal Service Fund (Access/Trunk line)
    /// </summary>
    public const short UNIVERSAL_SERVICE_FUND_LINE = 37;

    /// <summary>
    /// Universal Service Fund (Business line)
    /// </summary>
    public const short UNIVERSAL_SERVICE_FUND_BUSINESS_LINE = 38;

    /// <summary>
    /// E911 Tax (PBX/Trunk line)
    /// </summary>
    public const short E911_TAX_PBX_TRUNK_LINE = 39;

    /// <summary>
    /// License Tax (Business)
    /// </summary>
    public const short LICENSE_TAX_BUSINESS = 40;

    /// <summary>
    /// Optional Telecommunications Infrastructure Maintenance Fee
    /// </summary>
    public const short OPTIONAL_TIMF = 41;

    /// <summary>
    /// Sales Tax (Business)
    /// </summary>
    public const short SALES_TAX_BUSINESS = 42;

    /// <summary>
    /// E911 Tax (Residential)
    /// </summary>
    public const short E911_TAX_RESIDENTIAL = 43;

    /// <summary>
    /// E911 Tax (Wireless)
    /// </summary>
    public const short E911_TAX_WIRELESS = 44;

    /// <summary>
    /// New York Franchise 184
    /// </summary>
    public const short NY_FRANCHISE_184 = 45;

    /// <summary>
    /// New York Franchise 184 Usage
    /// </summary>
    public const short NY_FRANCHISE_184_USAGE = 46;

    /// <summary>
    /// New York Metropolitan Commuter Transportation District 184a Usage
    /// </summary>
    public const short NY_MCTD_184a_USAGE = 47;

    /// <summary>
    /// Universal Service Fund (Wireless)
    /// </summary>
    public const short UNIVERSAL_SERVICE_FUND_WIRELESS = 48;

    /// <summary>
    /// Use Tax
    /// </summary>
    public const short USE_TAX = 49;

    /// <summary>
    /// Sales Tax (Data)
    /// </summary>
    public const short SALES_TAX_DATA = 50;

    /// <summary>
    /// Municipal Right of Way (Residential)
    /// </summary>
    public const short MUNICIPAL_RIGHT_OF_WAY_RESIDENTIAL = 51;

    /// <summary>
    /// Municipal Right of Way (Business)
    /// </summary>
    public const short MUNICIPAL_RIGHT_OF_WAY_BUSINESS = 52;

    /// <summary>
    /// Municipal Right of Way (Private Line)
    /// </summary>
    public const short MUNICIPAL_RIGHT_OF_WAY_PRIVATE_LINE = 53;

    /// <summary>
    /// Utility Users Tax (Wireless)
    /// </summary>
    public const short UTILITY_USERS_TAX_WIRELESS = 54;

    /// <summary>
    /// Federal USF Cellular
    /// </summary>
    public const short FED_USF_CELLULAR = 55;

    /// <summary>
    /// Federal USF Paging
    /// </summary>
    public const short FED_USF_PAGING = 56;

    /// <summary>
    /// Sales Tax (Interstate)
    /// </summary>
    public const short SALES_TAX_INTERSTATE = 57;

    /// <summary>
    /// Utility Users Tax PBX Trunk
    /// </summary>
    public const short UTILITY_USERS_TAX_PBX_TRUNK = 58;

    /// <summary>
    /// District Tax Web Hosting
    /// </summary>
    public const short DISTRICT_TAX_WEB_HOSTING = 59;

    /// <summary>
    /// California High Cost Fund A
    /// </summary>
    public const short CA_HIGH_COST_FUND_A = 60;

    /// <summary>
    /// Telecommunications Education Access Fund
    /// </summary>
    public const short TELECOMMUNICATIONS_EDUCATION_ACCESS_FUND = 61;

    /// <summary>
    /// Federal Telecommunications Relay Service Cellular
    /// </summary>
    public const short FED_TRS_CELLULAR = 62;

    /// <summary>
    /// Federal Telecommunications Relay Service Paging
    /// </summary>
    public const short FED_TRS_PAGING = 63;

    /// <summary>
    /// Communications Service Tax
    /// </summary>
    public const short COMMUNICATIONS_SERVICES_TAX = 64;

    /// <summary>
    /// Value Added Tax (VAT)
    /// </summary>
    public const short VALUE_ADDED_TAX = 65;

    /// <summary>
    /// Goods and Services Tax (GST)
    /// </summary>
    public const short GOODS_SERVICE_TAX = 66;

    /// <summary>
    /// Harmonized Sales Tax (HST)
    /// </summary>
    public const short HARMONIZED_SALES_TAX = 67;

    /// <summary>
    /// Provincial Sales Tax (PST)
    /// </summary>
    public const short PROVINCIAL_SALES_TAX = 68;

    /// <summary>
    /// Quebec Sales Tax
    /// </summary>
    public const short QUEBEC_SALES_TAX = 69;

    /// <summary>
    /// National Contribution Regime (NCR)
    /// </summary>
    public const short NATIONAL_CONTRIBUTION_REGIME = 70;

    /// <summary>
    /// Utility Users Tax (Cable Television)
    /// </summary>
    public const short UTILITY_USERS_TAX_CABLE_TELEVISION = 71;

    /// <summary>
    /// FCC Regulatory Fee (Cable Television)
    /// </summary>
    public const short FCC_REGULATORY_FEE = 72;

    /// <summary>
    /// Franchise Tax (Cable)
    /// </summary>
    public const short FRANCHISE_TAX_CABLE = 73;

    /// <summary>
    /// Universal Service Fund (Paging)
    /// </summary>
    public const short UNIVERSAL_SERVICE_FUND_PAGING = 74;

    /// <summary>
    /// Statutory Gross Receipts (Wireless)
    /// </summary>
    public const short STATUTORY_GROSS_RECEIPTS_WIRELESS = 75;

    /// <summary>
    ///  For BillSoft internal use only
    /// </summary>
    public const short SGT_E911 = 76;

    /// <summary>
    ///  For BillSoft internal use only
    /// </summary>
    public const short SGT_E911_BUSINESS = 77;

    /// <summary>
    ///  For BillSoft internal use only
    /// </summary>
    public const short SGT_E911_TAX_PBX_TRUNK_LINE = 78;

    /// <summary>
    ///  For BillSoft internal use only
    /// </summary>
    public const short SGT_E911_TAX_RESIDENTIAL = 79;

    /// <summary>
    ///  For BillSoft internal use only
    /// </summary>
    public const short SGT_E911_TAX_WIRELESS = 80;

    /// <summary>
    ///  For BillSoft internal use only
    /// </summary>
    public const short SGT_E911_LICENSE_TAX = 81;

    /// <summary>
    /// Franchise Tax (Wireless)
    /// </summary>
    public const short FRANCISE_TAX_WIRELESS = 82;

    /// <summary>
    /// Federal USF Alternate
    /// </summary>
    public const short FEDERAL_USF_ALTERNATE = 83;

    /// <summary>
    /// Public Education and Government (PEG) Access Fee
    /// </summary>
    public const short PEG_ACCESS_FEE = 84;

    /// <summary>
    /// Communication Service Tax (Satellite)
    /// </summary>
    public const short COMMUNICATIONS_SERVICE_TAX_SATELLITE = 85;

    /// <summary>
    /// Franchise Tax (Satellite)
    /// </summary>
    public const short FRANCHISE_TAX_SATELLITE = 86;

    /// <summary>
    /// For BillSoft internal use only at this time
    /// </summary>
    public const short CARRIER_COST_RECOVERY = 87;

    /// <summary>/
    /// <summary>
    /// Federal TRS Alternate
    /// </summary>
    public const short FEDERAL_TRS_ALTERNATE = 88;

    /// <summary>
    /// TRS Centrex
    /// </summary>
    public const short TRS_CENTREX = 89;

    /// <summary>
    /// Utility Users Tax (Cable Television - Business)
    /// </summary>
    public const short UTILITY_USERS_TAX_CABLE_TELEVISION_BUSINESS = 90;

    /// <summary>
    /// Utility Users Tax (Centrex)
    /// </summary>
    public const short UTILITY_USERS_TAX_CENTREX = 91;

    /// <summary>
    /// E911 Tax (Centrex)
    /// </summary>
    public const short E911_TAX_CENTREX = 92;

    /// <summary>
    /// Utility Users Tax (Line)
    /// </summary>
    public const short UTILITY_USERS_TAX_LINE = 93;

    /// <summary>
    /// Crime Control District Tax
    /// </summary>
    public const short CRIME_CONTROL_DISTRICT_TAX = 94;

    /// <summary>
    /// Library District Tax
    /// </summary>
    public const short LIBRARY_DISTRICT_TAX = 95;

    /// <summary>
    /// Hospital District Tax
    /// </summary>
    public const short HOSPITAL_DISTRICT_TAX = 96;

    /// <summary>
    /// Health Services District Tax
    /// </summary>
    public const short HEALTH_SERVICES_DISTRICT_TAX = 97;

    /// <summary>
    /// Emergency Services District Tax
    /// </summary>
    public const short EMERGENCY_SERVICES_DISTRICT_TAX = 98;

    /// <summary>
    /// Improvement District Tax
    /// </summary>
    public const short IMPROVEMENT_DISTRICT_TAX = 99;

    /// <summary>
    /// Development District Tax
    /// </summary>
    public const short DEVELOPMENT_DISTRICT_TAX = 100;

    /// <summary>
    /// Transit Web Hosting Tax
    /// </summary>
    public const short TRANSIT_WEB_HOSTING_TAX = 101;

    /// <summary>
    /// Ambulance District Tax
    /// </summary>
    public const short AMBULANCE_DISTRICT_TAX = 102;

    /// <summary>
    /// Fire District Tax
    /// </summary>
    public const short FIRE_DISTRICT_TAX = 103;

    /// <summary>
    /// Police District Tax
    /// </summary>
    public const short POLICE_DISTRICT_TAX = 104;

    /// <summary>
    /// Football District Tax
    /// </summary>
    public const short FOOTBALL_DISTRICT_TAX = 105;

    /// <summary>
    /// Baseball District Tax
    /// </summary>
    public const short BASEBALL_DISTRICT_TAX = 106;

    /// <summary>
    /// Crime Control District Web Hosting Tax
    /// </summary>
    public const short CRIME_CONTROL_DISTRICT_WEB_HOSTING_TAX = 107;

    /// <summary>
    /// Library District Web Hosting Tax
    /// </summary>
    public const short LIBRARY_DISTRICT_WEB_HOSTING_TAX = 108;

    /// <summary>
    /// Hospital District Web Hosting Tax
    /// </summary>
    public const short HOSPITAL_DISTRICT_WEB_HOSTING_TAX = 109;

    /// <summary>
    /// Health Services District Web Hosting Tax
    /// </summary>
    public const short HEALTH_SERVICES_DISTRICT_WEB_HOSTING_TAX = 110;

    /// <summary>
    /// Emergency Services District Web Hosting Tax
    /// </summary>
    public const short EMERGENCY_SERVICES_DISTRICT_WEB_HOSTING_TAX = 111;

    /// <summary>
    /// Improvement District Web Hosting Tax
    /// </summary>
    public const short IMPROVEMENT_DISTRICT_WEB_HOSTING_TAX = 112;

    /// <summary>
    /// Development District Web Hosting Tax
    /// </summary>
    public const short DEVELOPMENT_DISTRICT_WEB_HOSTING_TAX = 113;

    /// <summary>
    /// Utility Users Tax (Interstate)
    /// </summary>
    public const short UTILITY_USERS_TAX_INTERSTATE = 114;

    /// <summary>
    /// Utility Users Tax (Telegraph)
    /// </summary>
    public const short UTILITY_USERS_TAX_TELEGRAPH = 115;

    /// <summary>
    /// E911 Network and Database Surcharge
    /// </summary>
    public const short E911_NETWORK_AND_DATABASE_SURCHARGE = 116;

    /// <summary>
    /// License Tax Emergency
    /// </summary>
    public const short LICENSE_TAX_EMERGENCY = 117;

    /// <summary>
    /// License Tax Emergency (Business)
    /// </summary>
    public const short LICENSE_TAX_EMERGENCY_BUSINESS = 118;

    /// <summary>
    /// Educational Sales Tax
    /// </summary>
    public const short EDUCATIONAL_SALES_TAX = 119;

    /// <summary>
    /// Educational Use Tax
    /// </summary>
    public const short EDUCATIONAL_USE_TAX = 120;

    /// <summary>
    /// E911 Operational Surcharge County Commission
    /// </summary>
    public const short E911_OPERATIONAL_SURCHARGE_COUNTY_COMMISSION = 121;

    /// <summary>
    /// E911 Operational Surcharge Voter Approved
    /// </summary>
    public const short E911_OPERATIONAL_SURCHARGE_VOTER_APPROVED = 122;

    /// <summary>
    /// Sales Tax 900
    /// </summary>
    public const short SALES_TAX_NINE_HUNDRED = 123;

    /// <summary>
    /// Convention Center Tax
    /// </summary>
    public const short CONVENTION_CENTER_TAX = 124;

    /// <summary>
    /// E911 High Capacity Trunk
    /// </summary>
    public const short E911_HIGH_CAPACITY_TRUNK = 125;

    /// <summary>
    /// School Board Tax A
    /// </summary>
    public const short SCHOOL_BOARD_TAX_A = 126;

    /// <summary>
    /// School Board Tax B
    /// </summary>
    public const short SCHOOL_BOARD_TAX_B = 127;

    /// <summary>
    /// School Board Tax C
    /// </summary>
    public const short SCHOOL_BOARD_TAX_C = 128;

    /// <summary>
    /// School Board Tax D
    /// </summary>
    public const short SCHOOL_BOARD_TAX_D = 129;

    /// <summary>
    /// School Board Tax E
    /// </summary>
    public const short SCHOOL_BOARD_TAX_E = 130;

    /// <summary>
    /// School Board Tax F
    /// </summary>
    public const short SCHOOL_BOARD_TAX_F = 131;

    /// <summary>
    /// School District Tax
    /// </summary>
    public const short SCHOOL_DISTRICT_TAX = 132;

    /// <summary>
    /// Police Jury Tax B
    /// </summary>
    public const short POLICE_JURY_TAX_B = 133;

    /// <summary>
    /// Police Jury Tax C
    /// </summary>
    public const short POLICE_JURY_TAX_C = 134;

    /// <summary>
    /// Police Jury Tax E
    /// </summary>
    public const short POLICE_JURY_TAX_E = 135;

    /// <summary>
    /// Communications Service Tax (Wireless)
    /// </summary>
    public const short COMMUNICATIONS_SERVICE_TAX_WIRELESS = 136;

    /// <summary>
    /// Service provider tax
    /// </summary>
    public const short SERVICE_PROVIDER_TAX = 137;

    /// <summary>
    /// Telecommunications Sales Tax
    /// </summary>
    public const short TELECOMMUNICATIONS_SALES_TAX = 138;

    /// <summary>
    /// Advanced Transit Tax
    /// </summary>
    public const short ADVANCED_TRANSIT_TAX = 139;

    /// <summary>
    /// Advanced Transit Tax (Web Hosting)
    /// </summary>
    public const short ADVANCED_TRANSIT_WEB_HOSTING_TAX = 140;

    /// <summary>
    /// Missouri Universal Service Fund
    /// </summary>
    public const short MISSOURI_UNIVERSAL_SERVICE_FUND = 141;

    /// <summary>
    /// Business Occupation Tax (Wholesale)
    /// </summary>
    public const short BUSINESS_OCCUPATION_TAX_WHOLESALE = 142;

    /// <summary>
    /// Telecommunications Education Access Fund Centrex
    /// </summary>
    public const short TELECOMMUNICATIONS_EDUCATION_ACCESS_FUND_CENTREX = 143;

    /// <summary>
    /// Business Occupation Tax
    /// </summary>
    public const short BUSINESS_OCCUPATION_TAX_OTHER = 144;

    /// <summary>
    /// Tribal Sales Tax
    /// </summary>
    public const short TRIBAL_SALES_TAX = 145;

    /// <summary>
    /// Data Processing Sales Tax
    /// </summary>
    public const short SALES_TAX_DATA_PROCESSING = 146;

    /// <summary>
    /// Data Processing Transit Tax
    /// </summary>
    public const short TRANSIT_TAX_DATA_PROCESSING = 147;

    /// <summary>
    /// Data Processing Crime Control District Tax
    /// </summary>
    public const short CRIME_CONTROL_DISTRICT_TAX_DATA_PROCESSING = 148;

    /// <summary>
    /// Data Processing Library District Tax
    /// </summary>
    public const short LIBRARY_DISTRICT_TAX_DATA_PROCESSING = 149;

    /// <summary>
    /// Data Processing Hospital District Tax
    /// </summary>
    public const short HOSPITAL_DISTRICT_TAX_DATA_PROCESSING = 150;

    /// <summary>
    /// Data Processing Health Services District Tax
    /// </summary>
    public const short HEALTH_SERVICES_DISTRICT_TAX_DATA_PROCESSING = 151;

    /// <summary>
    /// Data Processing Emergency Services District Tax
    /// </summary>
    public const short EMERGENCY_SERVICES_DISTRICT_TAX_DATA_PROCESSING = 152;

    /// <summary>
    /// Data Processing Improvement District Tax
    /// </summary>
    public const short IMPROVEMENT_DISTRICT_TAX_DATA_PROCESSING = 153;

    /// <summary>
    /// Data Processing Development District Tax
    /// </summary>
    public const short DEVELOPMENT_DISTRICT_TAX_DATA_PROCESSING = 154;

    /// <summary>
    /// Data Processing Advanced Transit Tax
    /// </summary>
    public const short ADVANCED_TRANSIT_TAX_DATA_PROCESSING = 155;

    /// <summary>
    /// CA PSPE Surcharge
    /// </summary>
    public const short CA_PSPE_SURCHARGE = 156;

    /// <summary>
    /// Data Processing District Tax
    /// </summary>
    public const short DISTRICT_TAX_DATA_PROCESSING = 157;

    /// <summary>
    /// For BillSoft internal use only
    /// </summary>
    public const short RESERVED_158 = 158;

    /// <summary>
    /// Cable Franchise Fee
    /// </summary>
    public const short CABLE_FRANCHISE_FEE = 159;

    /// <summary>
    /// Statutory Gross Receipts Business
    /// </summary>
    public const short STATUTORY_GROSS_RECEIPTS_BUSINESS = 160;

    /// <summary>
    /// E911 VOIP
    /// </summary>
    public const short E911_VOIP = 161;

    /// <summary>
    /// FUSF VOIP
    /// </summary>
    public const short FUSF_VOIP = 162;

    /// <summary>
    /// FUSF
    /// </summary>
    public const short FUSF = 163;

    /// <summary>
    /// Cost Recovery Surcharge
    /// </summary>
    public const short COST_RECOVERY_SURCHARGE = 164;

    /// <summary>
    /// State USF VOIP
    /// </summary>
    public const short STATE_USF_VOIP = 165;

    /// <summary>
    /// Communications Service Tax Cable
    /// </summary>
    public const short COMMUNICATIONS_SERVICES_TAX_CABLE = 166;

    /// <summary>
    /// Municipal Right of Way Cable
    /// </summary>
    public const short MUNICIPAL_RIGHT_OF_WAY_CABLE = 167;

    /// <summary>
    /// Reserved 168
    /// </summary>
    public const short RESERVED_168 = 168;

    /// <summary>
    /// FCC Regulatory Fee Wireline
    /// </summary>
    public const short FCC_REGULATORY_FEE_WIRELINE = 169;

    /// <summary>
    /// FCC Regulatory Fee Wireless
    /// </summary>
    public const short FCC_REGULATORY_FEE_WIRELESS = 170;

    /// <summary>
    /// Reserved for BillSoft internal use
    /// </summary>
    public const short INTERNAL_TAX_TYPE_1 = 171;

    /// <summary>
    /// Statutory Gross Receipts (Video)
    /// </summary>
    public const short STATUTORY_GROSS_RECEIPTS_VIDEO = 172;

    /// <summary>
    /// Utility Users Tax (Lifeline)
    /// </summary>
    public const short UTILITY_USERS_TAX_LIFELINE = 173;

    /// <summary>
    /// TRS (Long Distance)
    /// </summary>
    public const short TRS_LONG_DISTANCE = 174;

    /// <summary>
    /// TRS (Wireless)
    /// </summary>
    public const short TRS_WIRELESS = 175;

    /// <summary>
    /// Sales Tax (Senior Citizen)
    /// </summary>
    public const short SALES_TAX_SENIOR_CITIZEN = 176;

    /// <summary>
    /// Regulatory Cost Charge (Local)
    /// </summary>
    public const short REGULATORY_COST_CHARGE_LOCAL = 177;

    /// <summary>
    /// Regulatory Cost Charge (Intrastate)
    /// </summary>
    public const short REGULATORY_COST_CHARGE_INTRASTATE = 178;

    /// <summary>
    /// Regulatory Cost Charge (Cable)
    /// </summary>
    public const short REGULATORY_COST_CHARGE_CABLE = 179;

    /// <summary>
    /// PUC Fee (Cable)
    /// </summary>
    public const short PUC_FEE_CABLE = 180;

    /// <summary>
    /// Provincial Sales Tax (TOLL)
    /// </summary>
    public const short PROVINCIAL_SALES_TAX_TOLL = 181;

    /// <summary>
    /// UUT
    /// </summary>
    public const short UUT = 182;

    /// <summary>Sales Tax-Manufacturing </summary>
    public const short SALES_TAX_MANUFACTURING = 184;

    /// <summary>Use Tax-Manufacturing	 </summary>
    public const short USE_TAX_MANUFACTURING = 185;

    /// <summary>Sales Tax-Motor Vehicles	 </summary>
    public const short SALES_TAX_MOTOR_VEHICLES = 186;

    /// <summary>Use Tax-Motor Vehicles	 </summary>
    public const short USE_TAX_MOTOR_VEHICLES = 187;

    /// <summary>Rental Tax	 </summary>
    public const short RENTAL_TAX = 188;

    /// <summary>Rental Tax-Linen	 </summary>
    public const short RENTAL_TAX_LINEN = 189;

    /// <summary>Sales Tax-Vending	 </summary>
    public const short SALES_TAX_VENDING = 190;

    /// <summary>Rental Tax-Motor Vehicles	 </summary>
    public const short RENTAL_TAX_MOTOR_VEHICLES = 191;

    /// <summary>Sales Tax-Wholesale	 </summary>
    public const short SALES_TAX_WHOLESALE = 192;

    /// <summary>Sales Tax-Food and Drugs	 </summary>
    public const short SALES_TAX_FOOD_AND_DRUGS = 193;

    /// <summary>Sales Tax-Food	 </summary>
    public const short SALES_TAX_FOOD = 194;

    /// <summary>Fur Tax	 </summary>
    public const short FUR_TAX = 195;

    /// <summary>Privilege Tax-Manufacturing	 </summary>
    public const short PRIVILEGE_TAX_MANUFACTURING = 196;

    /// <summary>Lead Acid Battery Fee	 </summary>
    public const short LEAD_ACID_BATTERY_FEE = 197;

    /// <summary>Sales Tax-Motor Fuel	 </summary>
    public const short SALES_TAX_MOTOR_FUEL = 198;

    /// <summary>Lead Acid Battery Fee-Larger Battery </summary>
    public const short LEAD_ACID_BATTERY_FEE_LARGER_BATTERY = 199;

    /// <summary>Sales Tax-Parking	 </summary>
    public const short SALES_TAX_PARKING = 200;

    /// <summary>Privilege Tax-Recreation	 </summary>
    public const short PRIVILEGE_TAX_RECREATION = 201;

    /// <summary>Dry Cleaning Fee </summary>
    public const short DRY_CLEANING_FEE = 202;

    /// <summary>White Goods Tax	 </summary>
    public const short WHITE_GOODS_TAX = 203;

    /// <summary>Sales Tax-Medical Equipment </summary>
    public const short SALES_TAX_MEDICAL_EQUIPMENT = 204;

    /// <summary>Electronic Waste Recycling Fee-Small	 </summary>
    public const short ELECTRONIC_WASTE_RECYCLING_FEE_SMALL = 205;

    /// <summary>Electronic Waste Recycling Fee-Medium </summary>
    public const short ELECTRONIC_WASTE_RECYCLING_FEE_MEDIUM = 206;

    /// <summary>Electronic Waste Recycling Fee-Large	 </summary>
    public const short ELECTRONIC_WASTE_RECYCLING_FEE_LARGE = 207;

    /// <summary>Alcoholic Beverage Tax	 </summary>
    public const short ALCOHOLIC_BEVERAGE_TAX = 208;

    /// <summary>Sales Tax-Alcohol	 </summary>
    public const short SALES_TAX_ALCOHOL = 209;

    /// <summary>Liquor Drink Tax </summary>
    public const short LIQUOR_DRINK_TAX = 210;

    /// <summary>Indiana Universal Service Charge </summary>
    public const short IN_UNIVERSAL_SERVICE_CHARGE = 211;

    /// <summary>
    /// TRS (Paging)
    /// </summary>
    public const short TRS_PAGING = 212;

    /// <summary>
    /// ConnectME Fund
    /// </summary>
    public const short CONNECT_ME_FUND = 213;

    /// <summary>
    /// PA PURTA Surcharge
    /// </summary>
    public const short PA_PURTA_SURCHARGE = 214;

    /// <summary>
    /// ConnectME Fund (VoIP)
    /// </summary>
    public const short CONNECT_ME_FUND_VOIP = 215;

    /// <summary>
    /// ConnectME Fund (Cable)
    /// </summary>
    public const short CONNECT_ME_FUND_CABLE = 216;

    /// <summary>
    /// TRS (VoIP)
    /// </summary>
    public const short TRS_VOIP = 217;

    /// <summary>
    /// Consumer Counsel Fee
    /// </summary>
    public const short CONSUMER_COUNSEL_FEE = 218;

    /// <summary>
    /// San Diego Underground Conversion Surcharge
    /// </summary>
    public const short SAN_DIEGO_UNDERGROUND_CONVERSION_SURCHARGE = 219;

    /// <summary>
    /// OR_RSPF
    /// </summary>
    public const short OR_RSPF = 220;

    /// <summary> Reserved </summary>
    public const short RESERVED_221 = 221;

    /// <summary> Reserved </summary>
    public const short RESERVED_222 = 222;

    /// <summary> CASF </summary>
    public const short CASF = 223;

    /// <summary>License Tax (Cable)</summary>
    public const short LICENSE_TAX_CABLE = 224;

    /// <summary>Relay Missouri Surcharge</summary>
    public const short RELAY_MISSOURI_SURCHARGE = 225;

    /// <summary>FCC Regulatory Fee (VoIP)</summary>
    public const short FCC_REGULATORY_FEE_VOIP = 226;

    /// <summary>Municipal Right of Way (Extension)</summary>
    public const short MUNICIPAL_RIGHT_OF_WAY_EXTENSION = 228;

    /// <summary>Carrier Cost Recovery (VoIP)</summary>
    public const short CARRIER_COST_RECOVERY_VOIP = 229;

    /// <summary>Sales Tax (VIDEO)</summary>
    public const short SALES_TAX_VIDEO = 230;

    /// <summary>North Carolina Telecommunications Sales Tax</summary>
    public const short NORTH_CAROLINA_TELECOMMUNICATIONS_SALES_TAX = 231;

    /// <summary>Telecommunications Relay Surcharge (Cellular)</summary>
    public const short TELECOMMUNICATIONS_RELAY_SURCHARGE_CELLULAR = 232;

    /// <summary>E-911 Prepaid Wireless</summary>
    public const short E911_PREPAID_WIRELESS = 233;

    /// <summary>Telecommunications Relay Surcharge (Paging)</summary>
    public const short TELECOMMUNICATIONS_RELAY_SURCHARGE_PAGING = 234;

    /// <summary>Telecommunications Relay Surcharge (VoIP)</summary>
    public const short TELECOMMUNICATIONS_RELAY_SURCHARGE_VOIP = 235;

    /// <summary>TDAP</summary>
    public const short TDAP = 236;

    /// <summary>TAP Surcharge</summary>
    public const short TAP_SURCHARGE = 237;

    /// <summary> Communications Service Tax (Non-Facilities) </summary>
    public const short COMMUNICATIONS_SERVICE_TAX_NON_FACILITIES = 238;

    /// <summary>E911 (VoIP) Alternate</summary>
    public const short E911_VOIP_ALTERNATE = 239;

    /// <summary>E911 (VoIP PBX)</summary>
    public const short E911_VOIP_PBX = 240;

    /// <summary>Utility Users Tax (VoIP)</summary>
    public const short UTILITY_USERS_TAX_VOIP = 241;

    /// <summary>Utility Users Tax (VoIP-Business)</summary>
    public const short UTILITY_USERS_TAX_VOIP_BUSINESS = 242;

    /// <summary>Solid Waste Collection Tax</summary>
    public const short SOLID_WASTE_COLLECTION_TAX = 243;

    /// <summary>E911 (VoIP Business)</summary>
    public const short E911_VOIP_BUSINESS = 244;

    /// <summary>E911 (VoIP Nomadic)</summary>
    public const short E911_VOIP_NOMADIC = 245;

    /// <summary>E911 Prepaid Wireless (Alternate)</summary>
    public const short E911_PREPAID_WIRELESS_ALTERNATE = 246;

    /// <summary>Police and Fire Protection Fee</summary>
    public const short POLICE_AND_FIRE_PROTECTION_FEE = 247;

    /// <summary>San Francisco Access Line Tax</summary>
    public const short SAN_FRANCISCO_ACCESS_LINE_TAX = 248;

    /// <summary>San Francisco Access Line Tax (PBX/Trunk line)</summary>
    public const short SAN_FRANCISCO_ACCESS_LINE_TAX_PBX_TRUNK_LINE = 249;

    /// <summary>San Francisco Access Line Tax (VoIP)</summary>
    public const short SAN_FRANCISCO_ACCESS_LINE_TAX_VOIP = 250;

    /// <summary>San Francisco Access Line Tax (Wireless)</summary>
    public const short SAN_FRANCISCO_ACCESS_LINE_TAX_WIRELESS = 251;

    /// <summary>San Francisco Access Line Tax High Capacity Trunk</summary>
    public const short SAN_FRANCISCO_ACCESS_LINE_TAX_HIGH_CAPACITY_TRUNK = 252;

    /// <summary>City of San Jose Telephone Line Tax</summary>
    public const short CITY_OF_SAN_JOSE_TELEPHONE_LINE_TAX = 253;

    /// <summary>City of San Jose Telephone Line Tax (PBX/Trunk line)</summary>
    public const short CITY_OF_SAN_JOSE_TELEPHONE_LINE_TAX_PBX_TRUNK_LINE = 254;

    /// <summary>City of San Jose Telephone Line Tax (VoIP)</summary>
    public const short CITY_OF_SAN_JOSE_TELEPHONE_LINE_TAX_VOIP = 255;

    /// <summary>City of San Jose Telephone Line Tax (Wireless)</summary>
    public const short CITY_OF_SAN_JOSE_TELEPHONE_LINE_TAX_WIRELESS = 256;

    /// <summary>San Leandro Emerg Com Sys Access Tax</summary>
    public const short SAN_LEANDRO_EMERG_COM_SYS_ACCESS_TAX = 257;

    /// <summary>San Leandro Emerg Com Sys Access Tax (PBX Trk Line)</summary>
    public const short SAN_LEANDRO_EMERG_COM_SYS_ACCESS_TAX_PBX_TRK_LINE = 258;

    /// <summary>San Leandro Emerg Com Sys Access Tax (VoIP)</summary>
    public const short SAN_LEANDRO_EMERG_COM_SYS_ACCESS_TAX_VOIP = 259;

    /// <summary>San Leandro Emerg Com Sys Access Tax (Wireless)</summary>
    public const short SAN_LEANDRO_EMERG_COM_SYS_ACCESS_TAX_WIRELESS = 260;

    /// <summary>San Leandro Emerg Com Sys Access Tax-High Cap Trnk</summary>
    public const short SAN_LEANDRO_EMERG_COM_SYS_ACCESS_TAX_HIGH_CAP_TRNK = 261;

    /// <summary>Police and Fire Protection Fee (Prepaid)</summary>
    public const short POLICE_AND_FIRE_PROTECTION_FEE_PREPAID = 262;

    /// <summary>Public Safety Communications Surcharge</summary>
    public const short PUBLIC_SAFETY_COMMUNICATIONS_SURCHARGE = 263;

    /// <summary>E-911 Technical Charge</summary>
    public const short E911_TECHNICAL_CHARGE = 264;

    /// <summary>Telecom Assistance Svc Fund-High Capacity Trunk</summary>
    public const short TELECOM_ASSISTANCE_SVC_FUND_HIGH_CAPACITY_TRUNK = 265;

    /// <summary>For BillSoft internal use only at this time</summary>
    public const short CRT_LEVY = 266;

    /// <summary>Access Line Tax</summary>
    public const short ACCESS_LINE_TAX = 267;

    /// <summary>Access Line Tax (PBX/Trunk Line)</summary>
    public const short ACCESS_LINE_TAX_PBX_TRUNK_LINE = 268;

    /// <summary>Access Line Tax (VoIP)</summary>
    public const short ACCESS_LINE_TAX_VOIP = 269;

    /// <summary>Access Line Tax (Wireless)</summary>
    public const short ACCESS_LINE_TAX_WIRELESS = 270;

    /// <summary>WI USF</summary>
    public const short WI_USF = 271;

    /// <summary>Network Access Fee - Interstate</summary>
    public const short NETWORK_ACCESS_FEE_INTERSTATE = 272;

    /// <summary>Sales Tax (Other)</summary>
    public const short SALES_TAX_OTHER = 273;

    /// <summary>FCC Regulatory Fee (VoIP Alternate)</summary>
    public const short FCC_REGULATORY_FEE_VOIP_ALTERNATE = 274;

    /// <summary>Excise Tax (Wireless)</summary>
    public const short EXCISE_TAX_WIRELESS = 275;

    /// <summary>Reserved 276</summary>
    public const short RESERVED_276 = 276;

    /// <summary>FUSF Nonbillable</summary>
    public const short FUSF_NONBILLABLE = 277;

    /// <summary> Municipal Right of Way - High Capacity Trunk</summary>
    public const short MUNICIPAL_RIGHT_OF_WAY_HIGH_CAPACITY_TRUNK = 278;

    /// <summary> Education Cess</summary>
    public const short EDUCATION_CESS = 279;

    /// <summary> Secondary and Higher Education Cess</summary>
    public const short SECONDARY_AND_HIGHER_EDUCATION_CESS = 280;

    /// <summary> Utility Users Tax (Video)</summary>
    public const short UTILITY_USERS_TAX_VIDEO = 281;

    /// <summary> State USF (VoIP Alternate) </summary>
    public const short STATE_USF_VOIP_ALTERNATE = 282;

    /// <summary> TRS (VoIP Business) </summary>
    public const short TRS_VOIP_BUSINESS = 283;

    /// <summary> TRS (Trunk) </summary>
    public const short TRS_TRUNK = 284;

    /// <summary> Deaf and Disabled Fund (Wireless) </summary>
    public const short DEAF_AND_DISABLED_FUND_WIRELESS = 285;

    /// <summary>
    ///  For BillSoft internal use only
    /// </summary>
    public const short TELECOMM_SALE_TAX = 32711;
  }
}