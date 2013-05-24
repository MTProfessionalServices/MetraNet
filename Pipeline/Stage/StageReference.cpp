#include <StageReference.h>
#include <MTUtil.h>
#include <msmqlib.h>
#include <makeunique.h>

/******************************************** StageReference ***/

StageReference::StageReference(const char * apName, BOOL aPrivateQueue)
	: mStageName(apName), mState(PipelineStageStatus::PIPELINE_STAGE_STARTING),
		mUsePrivateQueues(aPrivateQueue), mInstancesStarted(0)
{ }

StageReference::~StageReference()
{ }

BOOL StageReference::SendStopSignal()
{
	std::wstring queueName;
	ASCIIToWide(queueName, mStageName.c_str(), mStageName.length());
	queueName += L"Queue";
	MakeUnique(queueName);

	SetState(PipelineStageStatus::PIPELINE_STAGE_QUITTING);

	MessageQueue msgq;
	if (!msgq.Init(queueName.c_str(), mUsePrivateQueues)
			|| !msgq.Open(MQ_SEND_ACCESS, MQ_DENY_NONE))
	{
		SetError(msgq.GetLastError());
		return FALSE;
	}

	QueueMessage sendme;

	sendme.ClearProperties();
	sendme.SetExpressDelivery(TRUE);

	PipelineSysCommand command;
	command.mCommand = PipelineSysCommand::EXIT;

	sendme.SetBody((UCHAR *) &command, sizeof(command));

	sendme.SetAppSpecificLong(PIPELINE_SYSTEM_COMMAND);
	sendme.SetPriority(PIPELINE_SYSTEM_PRIORITY);

	if (!msgq.Send(sendme))
	{
		SetError(msgq.GetLastError());
		return FALSE;
	}
	return TRUE;
}

