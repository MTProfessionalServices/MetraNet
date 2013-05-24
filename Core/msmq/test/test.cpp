/**************************************************************************
 * @doc TEST
 *
 * Copyright 1998 by MetraTech Corporation
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
 * $Header$
 ***************************************************************************/

#include <metralite.h>
#include <msmqlib.h>

#include <stdio.h>

#include <pipemessages.h>

int main(int argc, char *argv[])
{
	try
	{
		if (argc < 2)
		{
			printf("%s queue-name [-c|-r]\n", argv[0]);
			return -1;
		}

		const char * queueNameAscii = argv[1];
		wchar_t queueName[100];
		
		int aLen = strlen(queueNameAscii);

		int len = MultiByteToWideChar(
			CP_UTF8,										// code page
			0,													// character-type options
			queueNameAscii,							// address of string to map
			aLen,												// number of bytes in string
			NULL,												// address of wide-character buffer
			0);													// size of buffer

		//wchar_t * out = new wchar_t[len];

		(void) MultiByteToWideChar(
			CP_UTF8,										// code page
			0,													// character-type options
			queueNameAscii,						// address of string to map
			aLen,												// number of bytes in string
			queueName,												// address of wide-character buffer
			len);												// size of buffer

		queueName[len] = '\0';

		if (argc > 2 && 0 == strcmp(argv[2], "-c"))
		{
			MessageQueue msgq;

			MessageQueueProps props;

			props.SetLabel(L"Queue for MetraTech Pipeline stage 1");

			if (!msgq.CreateQueue(queueName, FALSE, props))
				printf("queue creation failed: %lx\n", msgq.GetLastError()->GetCode());
			else
				printf("passed\n");
		}
		else if (argc > 2 && 0 == strcmp(argv[2], "-r"))
		{
			MessageQueue msgq;
			if (!msgq.Init(queueName, FALSE)
					|| !msgq.Open(MQ_RECEIVE_ACCESS, MQ_DENY_NONE))
				throw msgq.GetLastError()->GetCode();

			QueueMessage receiveme;

			receiveme.SetAppSpecificLong(0);

			if (!msgq.Peek(receiveme))
				throw msgq.GetLastError()->GetCode();

			const ULONG * ptype = receiveme.GetAppSpecificLong();
			ASSERT(ptype);
			PipelineMessageID type = (PipelineMessageID) *ptype;
				


			printf("message ID: %d\n", type);

			//PipelineSessionClosed closed;
			PipelineProcessSession process;

			switch (type)
			{
#if 0
			case PIPELINE_SESSION_CLOSED:
				receiveme.SetBody((UCHAR *) &closed, sizeof(closed));
				msgq.Receive(receiveme);
				printf("sessionID %ld\n", closed.mDatabaseID);
				printf("serviceID %ld\n", closed.mServiceID);
				printf("isParent %d\n", closed.mIsParent);
				printf("parentId %ld\n", closed.mParentID);
				break;
#endif
			case PIPELINE_PROCESS_SESSION:
				receiveme.SetBody((UCHAR *) &process, sizeof(process));
				if (!msgq.Receive(receiveme))
					throw msgq.GetLastError()->GetCode();
				printf("sessionID %ld\n", process.mSessionID);
				break;
			default:
				printf("UNKNOWN MESSAGE TYPE %d\n", (int) type);
				if (!msgq.Receive(receiveme)) // flush anyways
					throw msgq.GetLastError()->GetCode();
				break;
			}
		}
		else if (argc > 2 && 0 == strcmp(argv[2], "-p"))
		{
			MessageQueue msgq;
			if (!msgq.Init(queueName, FALSE))
				throw msgq.GetLastError()->GetCode();


			QUEUEPROPID ids[1];
			MQQUEUEPROPS props;
			PROPVARIANT vars[1];
			ids[0] = PROPID_Q_JOURNAL;
			//vars[0].vt = PROPID_Q_JOURNAL;
			vars[0].vt = VT_UI1;

			props.cProp = 1;
			props.aPropID = ids;
			props.aPropVar = vars;
			props.aStatus = NULL;

			HRESULT hr = ::MQGetQueueProperties(msgq.GetFormatString().c_str(), &props);
			if (FAILED(hr))
				throw hr;

			BOOL journal = (vars[0].bVal == MQ_JOURNAL);

			if (journal)
			{
				printf("Turning off journalling\n");
				vars[0].bVal = MQ_JOURNAL_NONE;
				hr = ::MQSetQueueProperties(msgq.GetFormatString().c_str(), &props);
			}
			else
				printf("Journalling is not on\n");

#if 0
			//To set PROPID_Q_JOURNAL
			aPropID[i] = PROPID_Q_JOURNAL;              // Property identifier
			aVariant[i].vt = VT_UI1;                    // Type indicator
			aVariant[i].bVal = MQ_JOURNAL;              // Journal queue is usedi++
			//To retrieve PROPID_Q_JOURNAL
			aPropID[i] = PROPID_Q_JOURNAL;              // Property identifier
			aVariant[i].vt = VT_UI1;                    // Type indicatori++


			if (!msgq.GetJournal(&journal))
 				throw msgq.GetLastError()->GetCode();

			if (journal)
				printf("Turning of journalling\n");

			if (!msgq.SetJournal(FALSE))
				throw msgq.GetLastError()->GetCode();
#endif

			if (!msgq.Open(MQ_RECEIVE_ACCESS, MQ_DENY_NONE))
				throw msgq.GetLastError()->GetCode();

			printf("Purging queue %s\n", argv[1]);
			int count = 0;
			while (TRUE)
			{
				QueueMessage receiveme;

				receiveme.SetAppSpecificLong(0);

				if (!msgq.Receive(receiveme, 0))
					break;

				count++;
			}
			printf("Purged %d messages\n", count);

			if (journal)
			{
				printf("Turning journalling back on\n");
				vars[0].bVal = MQ_JOURNAL;
				hr = ::MQSetQueueProperties(msgq.GetFormatString().c_str(), &props);
			}

#if 0
			if (journal)
			{
				printf("Turning journalling back on\n");
				if (!msgq.SetJournal(TRUE))
					throw msgq.GetLastError()->GetCode();
			}
#endif


#if 0
			if (!msgq.Peek(receiveme))
				throw msgq.GetLastError()->GetCode();

			const ULONG * ptype = receiveme.GetAppSpecificLong();
			ASSERT(ptype);
			PipelineMessageID type = (PipelineMessageID) *ptype;
				


			printf("message ID: %d\n", type);

			//PipelineSessionClosed closed;
			PipelineProcessSession process;
#endif
		}
		else
		{
			MessageQueue msgq;
			if (!msgq.Init(queueName, FALSE)
					|| !msgq.Open(MQ_SEND_ACCESS, MQ_DENY_NONE))
				throw msgq.GetLastError()->GetCode();

			QueueMessage sendme;

			sendme.ClearProperties();

				//sendme.SetPriority(5);
			sendme.SetExpressDelivery(TRUE);
			//sendme.SetLabel(L"First message");

				//printf("Enter a string (bye to exit): ");

			// dbid, serviceid, isparent, parentid
#if 0
			PipelineProcessSession process = { 3 };

			//PipelineSessionClosed closed = { 1002, 5, FALSE, 0 };

			sendme.SetBody((UCHAR *) &process, sizeof(process));

			//			sendme.SetAppSpecificLong(PIPELINE_SESSION_CLOSED);
			sendme.SetAppSpecificLong(PIPELINE_PROCESS_SESSION);
#endif
			PipelineSysCommand sys = { PipelineSysCommand::EXIT };
			sendme.SetBody((UCHAR *) &sys, sizeof(sys));
			sendme.SetAppSpecificLong(PIPELINE_SYSTEM_COMMAND);


			if (!msgq.Send(sendme))
				throw msgq.GetLastError()->GetCode();

#if 0
			PipelineSysCommand command;
			command.mCommand = PipelineSysCommand::EXIT;

			sendme.ClearProperties();

			sendme.SetExpressDelivery(TRUE);
			sendme.SetBody((UCHAR *) &command, sizeof(command));

			sendme.SetAppSpecificLong(PIPELINE_SYSTEM_COMMAND);
			sendme.SetPriority(PIPELINE_SYSTEM_PRIORITY);

			msgq.Send(sendme);
#endif


			//if (0 == strcmp(buffer, "bye"))
		}
	}
	catch (HRESULT hr)
	{
		printf("failed: %lx\n", hr);
	}

	return 0;
}
