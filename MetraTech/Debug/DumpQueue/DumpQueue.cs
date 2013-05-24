namespace MetraTech.Debug.DumpQueue
{
	using System;
	using System.Xml;
	using System.Messaging;

	class QueueDumper
	{
		[MTAThread]
		static int Main(string[] args)
		{
			QueueDumper dumper = new QueueDumper(args);
			return dumper.Execute();
		}

		
		private string[] mArgs;
		public QueueDumper(string[] args)
		{
			mArgs = args;
		}

		public int Execute()
		{

			if (mArgs.Length != 1)
			{
				DisplayUsage();
				return 1;
			}
			
			mQueueName = mArgs[0];

			DumpMessages();
			return 0;
		}

		private void DisplayUsage()
		{
			Console.WriteLine("dumps the contents of a queue to standard out");
			Console.WriteLine();
			Console.WriteLine("usage:");
			Console.WriteLine("  dumpqueue queuename");
			Console.WriteLine();
			Console.WriteLine("examples:");
			Console.WriteLine("  dumpqueue .\\Private$\\RoutingQueue\\Journal$");
			Console.WriteLine("  dumpqueue .\\Private$\\ErrorQueue");
			Console.WriteLine();
		}
		private void DumpMessages()
		{
			MessageQueue queue = new System.Messaging.MessageQueue(mQueueName);

			queue.MessageReadPropertyFilter.UseJournalQueue = true;
			queue.MessageReadPropertyFilter.SentTime = true;
			queue.MessageReadPropertyFilter.ArrivedTime = true;
			queue.MessageReadPropertyFilter.Priority = true;
			queue.MessageReadPropertyFilter.TransactionId = true;
			
			foreach (Message msg in queue.GetAllMessages())
			{
				Console.WriteLine("Label          : " + msg.Label);
				Console.WriteLine("Sent Time      : " + msg.SentTime);
				Console.WriteLine("Arrived Time   : " + msg.ArrivedTime);
				Console.WriteLine("Priority       : " + msg.Priority);
				Console.WriteLine("Transaction ID : " + msg.TransactionId);
				Console.WriteLine("Message Body   : " + ConvertBodyToString(msg) + "\n\n\n");
			}

		}

		private string ConvertBodyToString(Message msg)
		{
			System.IO.Stream bodyStream = msg.BodyStream;
			long bodyLen = bodyStream.Length;

			byte [] body = new byte[bodyLen];
			int bytesRead = bodyStream.Read(body, 0, (int) bodyLen);

			string xml = System.Text.UTF8Encoding.UTF8.GetString(body, 0, (int) bodyLen);
			return xml;
		}


		string mQueueName;

	}
}
