/**************************************************************************
 * FILERSLOADER
 *
 * Copyright 1997-2001 by MetraTech Corp.
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
 ***************************************************************************/

#include <metra.h>
#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#include <MTSessionBaseDef.h>
#include <FileRSLoader.h>
#include <memory>

#include <sys/types.h>
#include <sys/stat.h>



using MTPipelineLib::IMTRuleSetPtr;

#include <iostream>

using std::cout;
using std::endl;

/********************************************** FileRSLoader ***/

time_t FileRSLoader::GetLastModified(int aScheduleID)
{
  char filename[1024];
  sprintf(filename, "%s\\Schedule%d.xml", mRootDir.c_str(), aScheduleID);

  // use the file modification date
  struct _stat statBuffer;

  // get file info
  if (_stat(filename, &statBuffer) != 0)
  {
    // unable to get file modification time
    // TODO:
    ASSERT(0);
    return NULL;
  }

  return statBuffer.st_mtime;
}

// create a rate schedule with the ruleset evaluator created
// and modification date initialized.
CachedRateSchedulePropGenerator * FileRSLoader::CreateRateSchedule(int    aParamTableID,
                                                            time_t aModifiedAt)
{
  CachedRateSchedulePropGenerator * schedule = new CachedRateSchedulePropGenerator(aModifiedAt, aParamTableID);

  //RuleSetEvaluator is ONLY used by RuleSetReader for MCM display purposes and
  //is NEVER used during rating.
  //Create it on demand instead/
  //HRESULT hr = schedule->mEvaluator.CreateInstance("MetraTech.MTRuleSetEvaluator.1");
  //if (FAILED(hr))
  //{
  //  delete schedule;
  //  return NULL;
  //}


  return schedule;
}

CachedRateSchedule * FileRSLoader::LoadRateSchedule(int    aParamTableID,
                                                    int    aScheduleID,
                                                    time_t aModifiedAt)
{
  char filename[1024];
  sprintf(filename, "%s\\Schedule%d.xml", mRootDir.c_str(), aScheduleID);

  cout << "Loading rate schedule " << aScheduleID << " from file " << filename << endl;

  IMTRuleSetPtr ruleSet("MTRuleSet.MTRuleSet.1");

  ruleSet->Read(filename);

  if (aModifiedAt == 0)
  {
    // modification time is unknown - get it
    aModifiedAt = GetLastModified(aScheduleID);
  }

  CachedRateSchedulePropGenerator * rawSchedule = CreateRateSchedule(aParamTableID,
                                                                     aModifiedAt);
  if (!rawSchedule)
  {
    // TODO:
    ASSERT(0);
    return NULL;                // unable to create a schedule
  }

  std::auto_ptr<CachedRateSchedulePropGenerator> schedule(rawSchedule);

  PropGenerator* pg = schedule->GetPropGen();

  // configure the evaluator based on the rules we just loaded
  //BP TODO:
  ASSERT(false);
  //pg->Configure((MTPipelineLib::IMTRuleSet *) ruleSet.GetInterfacePtr());

  return schedule.release();
}

BOOL FileRSLoader::LoadRateSchedules(int                 aParamTableID,
                                     time_t              aModifiedAt,
                                     RATESCHEDULEVECTOR& aRateSchedInfo)
{
  // There is no performance benefit to preloading all rate schedules
  // from a parameter table when the rate schedules are in individual files.
  //
  // This routine returns FALSE because the base class defines this routine
  // as returning TRUE if rate schedules are loaded.  We might actually want
  // to implement this if we find that someone is using it.
  //
  // As far as preloading the rate schedule cache goes there is no benefit to
  // loading each of the individual rate schedule files all at plug-in
  // initialization time or waiting and loading them on demand.  In fact, if you
  // only use 99 out of 100 rate schedules and they are loaded from files it is
  // better to wait and load them when you need them.  But this all applies to
  // caching rate schedules.

  return FALSE;
}
