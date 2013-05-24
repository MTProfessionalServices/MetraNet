/**************************************************************************
 * @doc FILERSLOADER
 *
 * @module |
 *
 *
 * Copyright 2001 by MetraTech Corporation
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
 *
 * @index | FILERSLOADER
 ***************************************************************************/

#ifndef _FILERSLOADER_H
#define _FILERSLOADER_H

#include <RSCache.h>

/********************************************** FileRSLoader ***/

// a simple schedule loader that works from the file system
// (mainly for testing).
class FileRSLoader : public RateScheduleLoader
{
public:

  // get the last modified date of the given rate schedule
  // (mostly for debugging)
  time_t GetLastModified(int aScheduleID);

  // create a rate schedule with the ruleset evaluator created
  // and modification date initialized.
  virtual CachedRateSchedulePropGenerator* CreateRateSchedule(int aParameterTable, time_t aModifiedAt);

  // load a rate schedule and return a pointer to it.
  // it's expected that this call allocates the CachedRateSchedule
  // with new.  If the schedule cannot be loaded, return NULL.
  virtual CachedRateSchedule* LoadRateSchedule(int    aParamTableID,
                                               int    aScheduleID,
                                               time_t aModifiedAt);

  // load all rate schedules in the specified parameter table.
  // it's expected that this call allocates the CachedRateSchedules
  // with new.  If the schedules cannot be loaded, return FALSE.
  virtual BOOL LoadRateSchedules(int                 aParamTableID,
                                 time_t              aModifiedAt,
                                 RATESCHEDULEVECTOR& aRateSchedInfo);

  // base directory under which all rate schedules are found
  void SetRootDirectory(const char * apRoot)
  { mRootDir = apRoot; }

private:
  std::string mRootDir;
};


#endif /* _FILERSLOADER_H */
