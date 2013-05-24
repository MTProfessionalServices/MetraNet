
#ifndef __MTACCOUNTSTATESDEFS_H_
#define __MTACCOUNTDSTATESEFS_H_


// const for config path

// xml file name

// xml tag names

// tag for the mtaccount logger

// tag for the xml file
const char MTACCOUNT_STATES_XML_FILE[] = "\\config\\account\\AccountStates.xml";

// tag names
const char STATE_SET_TAG[] = "state";
const char STATETRANSITION_SET_TAG[] = "state";
const char BUSINESSRULES_SET_TAG[] = "businessrules";
const char RULE_TAG[] = "rule";
const char NAME_TAG[] = "name";
const char LONGNAME_TAG[] = "longname";
const char PROGID_TAG[] = "progID";
const char CONFIGFILE_TAG[] = "configfile";

// states tag
const wchar_t PENDING_ACTIVE_APPROVAL[] = L"PA";
const wchar_t ACTIVE[] = L"AC";
const wchar_t SUSPENDED[] = L"SU";
const wchar_t PENDING_FINAL_BILL[] = L"PF";
const wchar_t CLOSED[] = L"CL";
const wchar_t ARCHIVED[] = L"AR";

#endif
