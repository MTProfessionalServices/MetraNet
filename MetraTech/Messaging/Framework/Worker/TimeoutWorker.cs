using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;


namespace MetraTech.Messaging.Framework.Worker
{
  using Persistence;
  using Messages;

  public class TimeoutWorker : BaseWorker
  {
    private EventWaitHandle mre = new EventWaitHandle(true, EventResetMode.AutoReset);

    public TimeoutWorker()
    {
      logger = new Logger("[TimeoutWorker]");
    }

    public void TimeoutWorkerThreadStart()
    {
      logger.LogDebug("Timeout Workers Thread started");
      while (true)
      {
        if (HaltProcessingCallback.IsShuttingDown) break;
        if (mre.WaitOne(1000))
        {
          TimeoutOldMessages();
        }
        //Not sure who/what should be triggering the checking of timed out messages
        //Commented out the code above for the moment and just having this thread check every second
        //mre.WaitOne(1000);
        //TimeoutOldMessages();
      }
      logger.LogDebug("Timeout Workers Thread ended");
    }

    private void TimeoutOldMessages()
    {
      int TimeoutSeconds = SharedStructures.Configuration.TimeoutRequestInSeconds;
      DateTime timeoutDate = MetraTime.Now.AddSeconds(-TimeoutSeconds);
      logger.LogDebug("Timing out messages older than {0}", timeoutDate);
      Dictionary<Guid, Request> timeouts = SharedStructures.Repository.GetTimeouts(timeoutDate);
      if (timeouts.Count == 0)
      {
        logger.LogTrace("No requests older than {0} that need to be timed out", timeoutDate);
      }
      else
      {
        logger.LogWarning("There are {0} requests older than {1} where the requester will be notified with a timeout message", timeouts.Count, timeoutDate);

        try
        {
          using (IConnection connection = SharedStructures.RabbitMQFactory.CreateConnection())
          using (IModel channel = connection.CreateModel())
          {
            foreach (Guid correlationId in timeouts.Keys)
            {
              logger.LogDebug("Timeout of request with CorrelationId {0}", correlationId);

              try
              {
                Request request = timeouts[correlationId];
                Response response = Response.CreateTimeoutResponse(request);
                byte[] body = System.Text.Encoding.UTF8.GetBytes(response.MessageBody);
                IBasicProperties props = channel.CreateBasicProperties();
                props.ContentType = "text/plain";
                props.CorrelationId = request.CorrelationId.ToString();
                channel.BasicPublish("", request.ReplyToAddress, props, body);
              }
              catch (Exception ex)
              {
                //This happens when things go bad, nothing to do but log it and move on
                logger.LogException(string.Format("Unable to generate timeout message for request [{0}]", correlationId), ex);
              }

            }
          }
          SharedStructures.Repository.CancelTimeout(timeoutDate);
        }
        catch (Exception ex)
        {
          logger.LogException("Unable to generate timeouts for requests but will continue on anyway", ex);
        }
      }
    }

    public void BeginTimeout()
    {
      mre.Set();
    }

  }
}
