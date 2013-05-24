/**************************************************************************
* @doc DBMiscSTLUtils
* 
* @module  Miscellaneous utility functions |
* 
* This file contains miscellaneous utility functions to be used by the
* database classes. The difference from DBMiscUtils is that this file is
* RogueWave-independent.
* 
* Copyright 1998 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Created by: Michael Efimov
* $Header$
*
* @index | 
***************************************************************************/

#ifndef __DBMISCSTLUTILS_H
#define __DBMISCSTLUTILS_H

#include <DBConstants.h>
#include <time.h>
#include <string>

const int SESSIONID_TIME_START=4 ;
const int SESSIONID_TIME_END=8 ;
const int SESSIONID_RANDOM_NUM_START=8 ;
const int SESSIONID_RANDOM_NUM_END=12 ;
const int SESSIONID_SEQ_NUM_START=12 ;
const int SESSIONID_SEQ_NUM_END=16 ;
const unsigned int REFID_TIME_MASK = 0x1FFFFFFF ;
const unsigned int REFID_RANDOM_NUM_MASK = 0xFFE00000 ;
const unsigned int REFID_SEQ_NUM_MASK = 0x0000000F ;
const int REFID_RANDOM_NUM_SHIFT = 21 ;
const int REFID_RANDOM_NUM_OFFSET = 29 ;
const int REFID_SEQ_NUM_OFFSET = 40 ;
const int REFID_MAX_CHARACTERS = 9 ;
const unsigned int REFID_CHARACTER_MASK = 0x1F ;
const int REFID_CHARACTER_SHIFT= 5 ;

const wchar_t REFID_VALID_CHARACTERS [] = 
{ 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S',
'T', 'U', 'W', 'X', 'Y', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0'} ;


inline std::wstring CreatePrintableRefID_STL (unsigned char *apSessionID)
{
  // local variables ...
  std::wstring wstrString ;
  int nTime, nRandNum, nSeqNum, i ;
  unsigned char nNum ;
  DWORDLONG nRefID=0 ;

  // copy the time out of the session id (bits 4-7) ...
  nTime = 0 ;
  for (i=SESSIONID_TIME_START ; i < SESSIONID_TIME_END; i++)
  {
    nNum = *(apSessionID+i) ;
    nTime += nNum << ((i-SESSIONID_TIME_START) * 8) ;
  }

  // copy the random number out of the session id (bits 8-11) ...
  nRandNum = 0 ;
  for (i=SESSIONID_RANDOM_NUM_START ; i < SESSIONID_RANDOM_NUM_END ; i++)
  {
    nNum = *(apSessionID+i) ;
    nRandNum += nNum << ((i-SESSIONID_RANDOM_NUM_START) * 8) ;
  }

  // copy the sequence number out of the session id (bits 12-15) ...
  nSeqNum = 0 ;
  for (i=SESSIONID_SEQ_NUM_START ; i < SESSIONID_SEQ_NUM_END ; i++)
  {
    nNum = *(apSessionID+i) ;
    nSeqNum += nNum << ((i-SESSIONID_SEQ_NUM_START) * 8) ;
  }

  // create the 44 bit ref id ...
  nRefID = nTime & REFID_TIME_MASK ;
  nRefID += (DWORDLONG) (((DWORDLONG) (nRandNum & REFID_RANDOM_NUM_MASK) >> REFID_RANDOM_NUM_SHIFT) << REFID_RANDOM_NUM_OFFSET) ;
  nRefID += (DWORDLONG) (((DWORDLONG) nSeqNum & REFID_SEQ_NUM_MASK) << REFID_SEQ_NUM_OFFSET) ;

  // convert the 44 bit ref id to its character representation ...
  wstrString = L"" ;
  for (i=0; i < REFID_MAX_CHARACTERS ; i++)
  {
    // get the 5-bit character out of the refid ...
    nNum = (unsigned char) (nRefID & REFID_CHARACTER_MASK) ;

    // add the refid character to the string ...
    wstrString += REFID_VALID_CHARACTERS[nNum] ;

    // shift the refid by the appropriate amount ...
    nRefID >>= (DWORDLONG) REFID_CHARACTER_SHIFT ;
  }
  return wstrString ;
}

inline std::string ValidateSTLString (const std::string &arString)
{
  if (arString.length() == 0)
  {
    std::string strString = " " ;
    return strString ;
  }
	// only convert quotes if necessary
  if (arString.find('\'') == std::string::npos)
		return arString;

  std::string strString ;
 
  // go through the string and determine if there are any single quotes(') in it ...
  // if there are double them up ...
  for (unsigned int i=0 ; i < arString.length() ; i++)
  {
    if (arString[i] == '\'')
    {
      strString += "''" ;
    }
    else
    {
      strString += arString[i] ;
    }
  }
  if (strString.length() == 0)
  {
    strString = " " ;
  }
  return strString ;
}


#endif 
