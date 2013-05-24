/**************************************************************************
* @doc
* 
* Copyright 1998 by MetraTech
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
* Created by: Boris Partensky
* $Header$
**************************************************************************/

#include <MTSQLParam.h>


MTSQLParam::~MTSQLParam()
{
}
void MTSQLParam::SetName(const char* pName) { mName = pName; }
void MTSQLParam::SetName(const string& pName) { mName = pName; }
void MTSQLParam::SetDirection(ParamDirection pDirection) { mDirection = pDirection; }
void MTSQLParam::SetType(int aType) 
{ 
	mType = (MTSQLType)aType; 
}
const string& MTSQLParam::GetName() const 
{ 
	return mName; 
}
const ParamDirection MTSQLParam::GetDirection() const
{ 
	return mDirection; 
}
const int MTSQLParam::GetType() const
{ 
	return mType; 
}
/*
const int GetStringType() 
{ 
return MTSQLTreeParser::getType(mType); 
}
*/
