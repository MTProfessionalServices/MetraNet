#ifndef _SLICE_TOKEN_H_
#define _SLICE_TOKEN_H_

#include <comdef.h>

class SliceToken
{
public:
	// Account Slices
	const static _bstr_t PAYER;
	const static _bstr_t PAYEE;
	const static _bstr_t PAYERPAYEE;
	const static _bstr_t DESCENDENT;
  const static _bstr_t PAYERPAYEEENDPOINT;
	const static _bstr_t PAYEEENDPOINT;
	// Time slices
	const static _bstr_t USAGEINTERVAL;
	const static _bstr_t DATERANGE;
	const static _bstr_t INTERSECTION;
	// Product Slices
	const static _bstr_t PITEMPLATE;
	const static _bstr_t PIINSTANCE;
  const static _bstr_t PRODUCTVIEW;
	// Session slices
	const static _bstr_t ROOT;
	const static _bstr_t SESSION;
	const static _bstr_t SESSIONCHILDREN;
	const static _bstr_t ALLSESSION;
};

#endif
