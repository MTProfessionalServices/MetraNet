/**************************************************************************
* Copyright 1997-2002 by MetraTech
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
***************************************************************************/

#ifndef __OPTIONALVARIANT_H__
#define __OPTIONALVARIANT_H__
#pragma once

inline bool OptionalVariantConversion(VARIANT src,VARENUM VariantType,_variant_t& output)
{
	_variant_t vtData(src);

	if (vtData!= vtMissing) {
		if(vtData.vt == (VT_BYREF|VT_VARIANT)) {
			variant_t inner = vtData.pvarVal;

			if(inner.vt != VariantType) {
				return false;
			}
			output = inner;
			return true;
		}
		else {
			if(vtData.vt != VariantType) {
				return false;
			}
			else {
				output = vtData;
				return true;
			}
		}
	}
	return false;
}

#endif //__OPTIONALVARIANT_H__