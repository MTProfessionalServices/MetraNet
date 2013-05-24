/**************************************************************************
 * @doc STAGECOMMON
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
 * @index | STAGECOMMON
 ***************************************************************************/

#ifndef _STAGECOMMON_H
#define _STAGECOMMON_H

// defined in stage.h
class PipelineStage;

/*********************************************** SessionInfo ***/

class SessionInfo
{
public:
  SessionInfo(MTPipelineLib::IMTSessionPtr aSession, PipelineStage * apStage);
	SessionInfo(MTPipelineLib::IMTSessionPtr aSession, const FILETIME & arTime,
							PipelineStage * apStage);

	int MicrosSinceEntered() const;

	MTPipelineLib::IMTSessionPtr GetSession() const
	{ return mSession; }

	void SetTimeEnteredToNow();

	PipelineStage * GetStage()
	{ return mpStage; }

private:
	MTPipelineLib::IMTSessionPtr mSession;

	// 100-nanosecond intervals since January 1, 1601.
	FILETIME mTimeEntered;

	// stage object that will process this session
	PipelineStage * mpStage;
};

class SessionSetInfo
{
public:
  SessionSetInfo(MTPipelineLib::IMTSessionSetPtr aSet, PipelineStage * apStage);

	MTPipelineLib::IMTSessionSetPtr GetSessionSet() const
	{ return mSet; }

	PipelineStage * GetStage()
	{ return mpStage; }

private:
	MTPipelineLib::IMTSessionSetPtr mSet;

	// stage object that will process this session
	PipelineStage * mpStage;
};

#endif /* _STAGECOMMON_H */
