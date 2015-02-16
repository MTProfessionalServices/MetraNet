
CREATE OR REPLACE PACKAGE dbo
AS

    function maxpartitionbound return NUMBER;

    function csvtoint (p_id_instances varchar2) return tab_id_instance;
    function String2Table(p_str in clob, p_delim in varchar2 default '.') return  str_tab;
    function csvtostrtab (csv varchar2) return str_tab;
    function strtabtocsv(tab str_tab) return varchar2;
    
    FUNCTION GetEventExecutionDeps(p_dt_now DATE, p_id_instances VARCHAR2)
    RETURN int;

    FUNCTION GetEventReversalDeps(p_dt_now DATE, p_id_instances VARCHAR2)
    RETURN int;

    FUNCTION GetCompatibleConcurrentEvents
    RETURN retCompatibleEvent_table;

   FUNCTION mtmaxdate
      RETURN DATE;

   FUNCTION mtmindate
      RETURN DATE;

   FUNCTION getutcdate
      RETURN DATE;

FUNCTION to_base( p_dec in number, p_base in number ) 
RETURN VARCHAR2;

FUNCTION twos_complement( in_bin_string varchar2)
RETURN VARCHAR2;

FUNCTION to_dec( p_str in varchar2, p_from_base in number default 16 ) 
RETURN NUMBER;

   FUNCTION addsecond (refdate DATE)
      RETURN DATE;

   FUNCTION subtractsecond (refdate DATE)
      RETURN DATE;

   FUNCTION addday (dt DATE)
      RETURN DATE;

   FUNCTION subtractday (dt DATE)
      RETURN DATE;

   function diffhour (dt_start date, dt_end date)
      return number;

   FUNCTION isaccountbillable (p_id_acc IN INTEGER)
      RETURN varchar2;

   FUNCTION IsAccountFolder (p_id_acc IN INTEGER)
      RETURN VARCHAR2;

   FUNCTION encloseddaterange (
      temp_dt_start        DATE,
      temp_dt_end          DATE,
      temp_dt_checkstart   DATE,
      temp_dt_checkend     DATE
   )
      RETURN INTEGER;

   FUNCTION overlappingdaterange (
      temp_dt_start        DATE,
      temp_dt_end          DATE,
      temp_dt_checkstart   DATE,
      temp_dt_checkend     DATE
   )
      RETURN INTEGER;

   FUNCTION mtcomputeeffectivebegindate (
      TYPE                  INT,
      offset                INT,
      base                  DATE,
      sub_begin             DATE,
      temp_id_usage_cycle   INT
   )
      RETURN DATE;

   FUNCTION mtrateschedulescore (TYPE INT, begindate DATE)
      RETURN INT;

   FUNCTION mtdateinrange (startdate DATE, enddate DATE, comparedate DATE)
      RETURN INTEGER;

   FUNCTION mtminoftwodates (chargeintervalleft DATE, subintervalleft DATE)
      RETURN DATE;

   FUNCTION mtmaxoftwodates (chargeintervalleft DATE, subintervalleft DATE)
      RETURN DATE;

   FUNCTION MTMinOfThreeDates (p_date1 DATE, p_date2 DATE, p_date3 DATE)
      RETURN DATE;

   FUNCTION MTMaxOfThreeDates (p_date1 DATE, p_date2 DATE, p_date3 DATE)
      RETURN DATE;

   FUNCTION nextdateafterbillingcycle (temp_id_acc INT, temp_datecheck DATE)
      RETURN DATE;

   FUNCTION checksubscriptionconflicts (
      temp_id_acc            INT,
      temp_id_po             INT,
      temp_real_begin_date   DATE,
      temp_real_end_date     DATE,
      temp_id_sub            INT,
      p_allow_acc_po_curr_mismatch  INT,
      p_allow_multiple_pi_sub_rcnrc INT
   )
      RETURN INT;

		FUNCTION mtendofday (indate DATE) RETURN DATE;
		FUNCTION mtstartofday (indate DATE) return DATE;
		FUNCTION POContainsDiscount(p_id_po INTEGER) return INTEGER;
  
  FUNCTION IsCorporateAccount(p_id_acc IN integer,RefDate IN Date) return INTEGER;

	FUNCTION IsActive(state varchar2) return integer;
	FUNCTION IsSuspended(state varchar2) return integer;
	FUNCTION IsPendingFinalBill(state varchar2) return integer;
	FUNCTION IsClosed(state varchar2) return integer;
	FUNCTION IsArchived(state varchar2) return integer;
	FUNCTION IsInVisableState(state varchar2) return integer;
  FUNCTION mtconcat(str1 nvarchar2,str2 nvarchar2) return nvarchar2;

  FUNCTION poConstrainedCycleType(offeringID integer) return integer;
  function IsInSameCorporateAccount(acc1 IN integer,acc2 IN integer,refdate date) return integer;

  FUNCTION POContainsOnlyAbsoluteRates(p_id_po IN integer) return integer;

    FUNCTION CheckEBCRCycleTypeCompatible
      (p_EBCRCycleType INT, p_OtherCycleType INT)
    RETURN INT;

    FUNCTION CHECKGROUPMEMBERSHIPCYCLECONST(
    dt_now 	IN DATE  DEFAULT NULL,
    id_group 	IN NUMBER  DEFAULT NULL)
    RETURN NUMBER;

    FUNCTION CheckGroupMembershipEBCRConstr
    (
      p_dt_now DATE, /* system date */
      p_id_group INT     /* group ID to check */
    )
    RETURN INT;

    FUNCTION CHECKGROUPRECEIVEREBCRCONS
    (
      p_dt_now DATE, /* system date */
      p_id_group INT     /* group ID to check */
    )
    RETURN INT;

    FUNCTION DERIVEEBCRCYCLE(
    usageCycle 	IN NUMBER  DEFAULT NULL,
    subStart 	IN DATE  DEFAULT NULL,
    ebcrCycleType 	IN NUMBER  DEFAULT NULL)
    RETURN NUMBER;

    FUNCTION DOESACCOUNTHAVEPAYEES(
    id_acc 	IN NUMBER  DEFAULT NULL,
    dt_ref 	IN DATE  DEFAULT NULL)
    RETURN VARCHAR2;

    FUNCTION GETCURRENTINTERVALID(
	aDTNow 	IN DATE  DEFAULT NULL,
    aDTSession 	IN DATE  DEFAULT NULL,
    aAccountID 	IN NUMBER  DEFAULT NULL)
    RETURN NUMBER;

    FUNCTION ISACCOUNTANDPOSAMECURRENCY(
    id_acc 	IN NUMBER  DEFAULT NULL,
    id_po 	IN NUMBER  DEFAULT NULL)
    RETURN VARCHAR2;

    FUNCTION ISACCOUNTPAYINGFOROTHERS(
    id_acc 	IN NUMBER  DEFAULT NULL,
    dt_ref 	IN DATE  DEFAULT NULL)
    RETURN VARCHAR2;

    FUNCTION IsBillingCycleUpdProhibitedByG
    (
      p_dt_now DATE,
      p_id_acc INT
    )
    RETURN INT;

    FUNCTION ISINTERVALOPEN(
    aAccountID 	IN NUMBER  DEFAULT NULL,
    aIntervalID 	IN NUMBER  DEFAULT NULL)
    RETURN NUMBER;

    FUNCTION LOOKUPACCOUNT(
    login 	IN VARCHAR2  DEFAULT NULL,
    namespace 	IN VARCHAR2  DEFAULT NULL)
    RETURN NUMBER;

    FUNCTION MTCOMPUTEEFFECTIVEENDDATE(
    type_ 	IN NUMBER  DEFAULT NULL,
    offset 	IN NUMBER  DEFAULT NULL,
    base 	IN DATE  DEFAULT NULL,
    sub_begin 	IN DATE  DEFAULT NULL,
    id_usage_cycle 	IN NUMBER  DEFAULT NULL)
    RETURN DATE;

    FUNCTION WARNONEBCRMEMBERSTARTDATECHANG(
    id_sub 	IN NUMBER  DEFAULT NULL,
    id_acc 	IN NUMBER  DEFAULT NULL)
    RETURN NUMBER;

    FUNCTION WARNONEBCRSTARTDATECHANGE(
    id_sub 	IN NUMBER  DEFAULT NULL)
    RETURN NUMBER;

    FUNCTION POCONTAINSBILLINGCYCLERELATIVE(
    id_po 	IN NUMBER  DEFAULT NULL)
    RETURN NUMBER;

    function mthexformat(
      value 	in number  default null)
    return varchar2;

    function getbillinggroupancestor(p_id_current_billgroup int) 
    return int;

    function getbillinggroupdescendants(p_id_billgroup_current int)
    return billgroupdesc_results_tab;

    function getexpiredintervals(
      p_dt_now date,    
      p_not_materialized int
      ) return id_table;

	  function GetAllDescendentAccountTypes(
		  parent varchar2
		  ) return retDescendents_table;

   function IsSystemPartitioned 
      return int;

    function GetUsageIntervalID (
      p_dt_end timestamp,
      p_id_cycle int
      ) return int;
      
    function DaysFromPartitionEpoch(
      dt timestamp) 
    return int;
	
	function GenGuid return raw;
end;
				