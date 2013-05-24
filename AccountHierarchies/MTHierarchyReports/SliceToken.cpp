#include "StdAfx.h"
#include <SliceToken.h>

// Declare the tokens
const _bstr_t SliceToken::PAYER(L"Payer");
const _bstr_t SliceToken::PAYEE(L"Payee");
const _bstr_t SliceToken::PAYERPAYEE(L"PayerPayee");
const _bstr_t SliceToken::DESCENDENT(L"Ancestor");
const _bstr_t SliceToken::PAYEEENDPOINT(L"PayeeEndpoint");
const _bstr_t SliceToken::PAYERPAYEEENDPOINT(L"PayerPayeeEndpoint");
// Time slices
const _bstr_t SliceToken::USAGEINTERVAL(L"Interval");
const _bstr_t SliceToken::DATERANGE(L"DateRange");
const _bstr_t SliceToken::INTERSECTION(L"And");
// Product Slices
const _bstr_t SliceToken::PITEMPLATE(L"Template");
const _bstr_t SliceToken::PIINSTANCE(L"Instance");
const _bstr_t SliceToken::PRODUCTVIEW(L"ProductView");
// Session slices
const _bstr_t SliceToken::ROOT(L"ROOT");
const _bstr_t SliceToken::SESSION(L"Session");
const _bstr_t SliceToken::SESSIONCHILDREN(L"Parent");
const _bstr_t SliceToken::ALLSESSION(L"AllSessions");
