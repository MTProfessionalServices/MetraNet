using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using MetraTech;
using MetraTech.Messaging.Framework.Messages;
using System.Threading;

namespace MetraTech.Messaging.Framework.Worker
{
  public class ListenerWorker : BaseWorker
  {

    //Locking object for persistent dictionary
    protected object l = new object();
    protected int ThreadNumber;
    protected Configurations.QueueConfig QueueConfig;
    public Configurations.Configuration Configuration;

    public int QueuePrefetchCount = 100;

    public virtual void Initialize(int aThreadNumber, Configurations.QueueConfig aQueueConfig)
    {
      ThreadNumber = aThreadNumber;
      QueueConfig = aQueueConfig;
      factory = SharedStructures.RabbitMQFactory;
      repository = SharedStructures.Repository;
      Configuration = SharedStructures.Configuration;
    }

    private ulong DeliveryTag;
    
    protected void Acknowledge(IModel channel)
    {
      if (NeedToAcknowledge)
      {
        if (mHasUnAcknowledgedMessages)
        {
          logger.LogDebug(" [x] Acknowledging messages {0}", DeliveryTag);
          channel.BasicAck(DeliveryTag, true);
          mHasUnAcknowledgedMessages = false;
        }
        NeedToAcknowledge = false;
      }
    }

    protected IModel channel = null;


    public void ReceiveMessagesThreadStart()
    {
      logger.LogDebug("Receive Messages Thread started");
      Thread.CurrentThread.Name = string.Format("ListenerWorker: {0} ({1})", QueueConfig.Name, ThreadNumber);

      bool retryConnection = false;
      int connectionAttemptCount = 1;

      while (true)
      {
        IConnection connection = null;

        try //Used to close/dispose of connection and channel
        {
          try //Used to connect and re-try connection
          {
            connection = factory.CreateConnection();
            channel = connection.CreateModel();
          }
          catch (Exception ex)
          {
            logger.LogWarning("Error connecting to {0}:{1}", factory.HostName, ex.Message);
            Thread.Sleep(10000);
            logger.LogDebug("Retrying connection to {0}: Attempt: {1}", factory.HostName, connectionAttemptCount++);
            continue;
          }

          if (retryConnection)
            logger.LogDebug("Reconnected to {0}", factory.HostName);

          retryConnection = false;
          connectionAttemptCount = 1;

          channel.BasicQos(0, Convert.ToUInt16(QueuePrefetchCount), false);
          channel.QueueDeclare(QueueConfig.Name, true, false, false, null);
          QueueingBasicConsumer consumer = new QueueingBasicConsumer(channel);
          channel.BasicConsume(QueueConfig.Name, false, consumer);

          logger.LogInfo(" [*] Waiting for messages.");

          while (true)
          {
            //Message processing loop

            //Determine if we are shutting down, if so, acknowledge and exit message processing loop
            if (HaltProcessingCallback.IsShuttingDown) NeedToAcknowledge = true;
            Acknowledge(channel);
            if (HaltProcessingCallback.IsShuttingDown) break;

            object result = null;
            try
            {
              //Try to get a message from the queue, if we timeout waiting for a message, loop so we can determine if we need to shutdown
              if (!consumer.Queue.Dequeue(1000, out result)) continue;
            }
            catch (System.IO.EndOfStreamException ex)
            {
              //We have an exception while dequeuing that indicates we have become disconnected

              logger.LogException(string.Format("consumer.Queue.Dequeue failed on {0} queue and server {1}", this.QueueConfig.Name, factory.HostName), ex);
              //Console.WriteLine(string.Format("consumer.Queue.Dequeue failed on {0} queue and server {1}: {2}", this.QueueConfig.Name, factory.HostName, ex.Message));

              //We have an error dequeueing
              // 1. Check the exception/connection, if it is 'down' then exit this loop
              //   1.5 Would like to acknowledge any unacknowledged messages but it wouldn't work
              // 2. Try to reestablish connection in a loop, sleeping
              // 3.
              if (!channel.IsOpen || !connection.IsOpen)
              {
                //Looks like we lost the connection
                string logMessage = string.Format("Connection/Channel closed to RabbitMQ server: {0}", factory.HostName);
                if (channel.CloseReason != null)
                  logMessage += " Channel Closed:" + channel.CloseReason;
                if (connection.CloseReason != null)
                  logMessage += " Connection Closed:" + connection.CloseReason;

                logger.LogWarning(logMessage);
                //Console.WriteLine(logMessage);

                //Indicate we should retry connection
                retryConnection = true;

                break;
              }
            }

            Acknowledge(channel); //???

            //If we got a message, hand it over for processing
            if (result != null)
            {
              BasicDeliverEventArgs ea = result as BasicDeliverEventArgs;
              try
              {
                ProcessMessage(ea);
              }
              catch (Exception ex)
              {
                string logMessage = System.Text.Encoding.UTF8.GetString(ea.Body);
                logger.LogException(string.Format("Error processing Message: {0}", logMessage), ex);

                //Handle message error
                HandleCriticalErrorWhileProcessingMessage(ex, ea);
              }

              Acknowledge(channel); //TODO: Add exception handling

              DeliveryTag = ea.DeliveryTag;
              mHasUnAcknowledgedMessages = true;
            }
          }
          
          //Are we shutting down or is the connection bad and we should we retry to connect?
          if (retryConnection)
            continue;
          else
            break; //exit

        }
        catch (Exception ex)
        {
          Console.WriteLine("Unhandled exception: {0}", ex.Message);
          logger.LogException("Unhandled exception: Continuing On", ex);
        }
        finally
        {
          try
          {
            if (channel != null)
            {
              channel.Close();
              channel.Dispose();
            }
            if (connection != null)
            {
              connection.Close();
              connection.Dispose();
            }
          }
          catch (RabbitMQ.Client.Exceptions.AlreadyClosedException)
          {
            //If we become disconnected, Dispose on connection will throw; either we don't close/dispose it or we swallow the exception
          }
        }
      }

      logger.LogDebug("Receive Messages Thread ended");
    }

    public virtual void ProcessMessage(BasicDeliverEventArgs ea)
    {
      byte[] body = ea.Body;
      string message = System.Text.Encoding.UTF8.GetString(body);
      IBasicProperties props = ea.BasicProperties;
      logger.LogDebug(" [x] Received {0}. Delivery Tag {1}", message, ea.DeliveryTag);
      Guid g = Guid.Parse(props.CorrelationId);
      /*lock (l)
      {
        //if (!dict.ContainsKey(g)) Console.WriteLine("Missing correlation id {0} for message: {1}", props.CorrelationId, message);
        //else dict.Remove(Guid.Parse(props.CorrelationId));
        string s;
        if (!db.Get(g, out s)) Console.WriteLine("Missing correlation id {0} for message: {1}", props.CorrelationId, message);
        else
        {
          //db.Set(g, (byte[])null);
          db.RemoveKey(g);
        }
      }*/
    }

    /// <summary>
    /// If a critical error (not a negative/error response from a processor) happens while processing a message, the exception and message
    /// passed to this routine will be either be returned to the requester if the response queue is readable from the ReplyTo properties;
    /// if the requestor(sender of the message) cannot be determined, it will be written to the configured error queue (MTError) for manual processing
    /// If a critical error happens while trying to preserve the message with an error, it will make a last ditch effort to preserve the
    /// message in the log.
    /// </summary>
    /// <param name="exceptionWhileProcessing"></param>
    /// <param name="ea"></param>
    public virtual void HandleCriticalErrorWhileProcessingMessage(Exception exceptionWhileProcessing, BasicDeliverEventArgs ea)
    {
      try
      {
        //If ReplyTo is specified, return error to sender
        if (string.IsNullOrEmpty(ea.BasicProperties.ReplyTo) || IsQueueThatShouldNotReceiveErrors(ea.BasicProperties.ReplyTo))
        {
          //We have no one to reply to, send it to the error/deadletter queue
          //Prepare an error message wrapper for the failed message
          MessageWithError erroredMessage = new MessageWithError() { Error = exceptionWhileProcessing.Message, Message = System.Text.Encoding.UTF8.GetString(ea.Body) };

          //Submit it to the deadletter/error queue
          channel.BasicPublish("", Configuration.ErrorQueue.Name, ea.BasicProperties, erroredMessage);
        }
        else
        {
          //We at least have a reply to, send it back to the requester as an error
          channel.BasicPublish("", ea.BasicProperties.ReplyTo, ea.BasicProperties, Response.CreateErrorResponseAsByteArray(exceptionWhileProcessing.Message, ea.Body));
        }
      }
      catch (Exception ex)
      {
        logger.LogException("Critical error while attempting to handle message processing error: error and message could not be returned to the requester or written to the error queue", ex);
        logger.LogError("Error While Processing [{0}] Message [{1}]", exceptionWhileProcessing.Message, ea.Body);
      }
    }

    /// <summary>
    /// Because the replyTo address on a mangled message may be our own Request or Response queue, provide a mechanism for checking
    /// if an error should be returned to the specified queue. If 'true', do not send error to this queue, then the message and error will
    /// be sent to the error queue.
    /// </summary>
    /// <param name="queueName">Queue name to check</param>
    public virtual bool IsQueueThatShouldNotReceiveErrors(string queueName)
    {
      //If this is our Messaging Server request queue or one of the response queues, return true as it should not receive errors
      return (string.Compare(queueName,Configuration.RequestQueue.Name,true)==0 || queueName.StartsWith(Configuration.ResponseQueue.Name));
    }
  }
}
