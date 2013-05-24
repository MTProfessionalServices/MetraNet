#ifndef __STAGEREFERENCE_H__
#define __STAGEREFERENCE_H__

#include <metra.h>
#include <errobj.h>
#include <pipemessages.h>
#include <string>

#if defined(STAGE_DEF)
#undef DllExport
#define DllExport __declspec(dllexport)
#else
#undef DllExport
#define DllExport
#endif

class StageReference : public virtual ObjectWithError
{
public:
	// default constructor required by STL
  DllExport StageReference() : mInstancesStarted(0)
	{ }

	DllExport StageReference(const char * apStageName, BOOL aPrivateQueue);
	DllExport virtual ~StageReference();

	DllExport const std::string & GetStageName() const
	{ return mStageName; }

	DllExport int GetStageID() const
	{ return mStageID; }

	DllExport PipelineStageStatus::StageStatus GetState() const
	{ return mState; }

	DllExport void SetState(PipelineStageStatus::StageStatus aState)
	{ mState = aState; }

  int GetInstanceCount() const
  {
    return mInstancesStarted;
  }

  void SetInstanceCount(int value)
  {
    mInstancesStarted = value;
  }

	DllExport BOOL SendStopSignal();

private:
	std::string mStageName;
	int mStageID;

	PipelineStageStatus::StageStatus mState;
	int mRetries;

  // Keep track of how many instances were started so that the same number 
  // of shutdown messages can be sent
  int mInstancesStarted;

	// if true, use a private queue when sending a message
	BOOL mUsePrivateQueues;

	enum
	{
		MAX_RETRIES = 5,
	};
};

#endif
