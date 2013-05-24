using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using MetraTech;

using MetraTech.Messaging.Framework.Worker;
using MetraTech.Messaging.Framework.Configurations;
using MetraTech.Messaging.Framework.Persistence;

namespace MetraTech.Messaging.Framework
{
  public class MessageProcessor
  {
    Logger logger = new Logger("[MessageProcessor]");
    Thread mControlWorkerThread;
    Thread mArchiveWorkerThread;
    Thread mTimeoutWorkerThread;
    public ConnectionFactory factory;
    WorkerPool<RequestWorker> RequestWorkerPool;
    WorkerPool<ResponseWorker> ResponseWorkerPool;
    ArchiveWorker mArchiveWorker;
    TimeoutWorker mTimeoutWorker;

    public Configuration Configuration;

    public MessageProcessor()
    {
    }

    /// <summary>
    /// Read Configuration file and store results in the Configuration object.
    /// </summary>
    public void ReadConfigFile()
    {
      logger.LogDebug("Reading configuration");
      Configuration = ConfigurationManager.ReadFromXml();
    }

    /// <summary>
    /// For Unit testing - read any config file
    /// </summary>
    /// <param name="aConfigFileName"></param>
    public void ReadConfigFile(string aConfigFileName)
    {
      Configuration = ConfigurationManager.ReadFromXml(aConfigFileName);
    }

    public void Start()
    {
      logger.LogDebug("Starting MessageProcessor");
      try
      {
        HaltProcessingCallback.IsShuttingDown = false;

        if (Configuration == null) ReadConfigFile();
        
        //Validate the configuration
        ConfigurationManager.ValidateConfiguration(Configuration, true);

        //Make the response queue name machine specific
        Configuration.ResponseQueue.Name = Configuration.ResponseQueue.Name + "@" + Configuration.MessagingServerUniqueIdentifier;
        //TODO: Would be good to verify no one else is consuming from our unique response queue

        logger.LogInfo("Starting Messaging Server: Using following configuration parameters {0}", Configuration.Server.ToString());
        
        factory = new ConnectionFactory();
        factory.HostName = Configuration.Server.Address;
        factory.UserName = Configuration.Server.UserName;
        factory.Password = Configuration.Server.Password;
        
        SharedStructures.Configuration = Configuration;
        SharedStructures.RabbitMQFactory = factory;
        SharedStructures.Repository = new JetBlueRequestRepository(Configuration.RequestPersistenceFolder);

        DeclareQueues();
        CreateRequestWorkers();
        CreateResponseWorkers();
        CreateArchiveWorker();
        CreateTimeoutWorker();
        CreateControlWorker();
      }
      catch (RabbitMQ.Client.Exceptions.BrokerUnreachableException buex)
      {
        string msg = string.Format("Unable to start MessageProcessor. Rabbit MQ is unreachable. Make sure correct parameters for rabbitmq server connection are specified in servers.xml: {0}", Configuration.Server.ToString());
        logger.LogException(msg, buex);
        throw new Exception(msg, buex);
      }
      catch (Exception ex)
      {
        logger.LogException("Unable to start MessageProcessor", ex);
        throw;
      }
      logger.LogInfo("MessageProcessor started");
    }

    private void DeclareQueues()
    {
      using (IConnection connection = factory.CreateConnection())
      using (IModel channel = connection.CreateModel())
      {
        DeclareQueue(channel, Configuration.RequestQueue, "request");
        DeclareQueue(channel, Configuration.ResponseQueue, "response");
        DeclareQueue(channel, Configuration.ErrorQueue, "error");
        foreach (MessageTypeRule rule in Configuration.MessageTypeRules.Values)
        {
          DeclareQueue(channel, rule.ForwardToQueue, string.Format("Forward queue for Message Type {0}", rule.MessageType));
        }
      }
    }

    private void DeclareQueue(IModel channel, QueueConfig queueConfig, string description)
    {
      logger.LogDebug("declaring queue {0} for {1}", queueConfig.Name, description);
      try
      {
        channel.QueueDeclare(queueConfig.Name, true, false, false, null);
      }
      catch (Exception ex)
      {
        string msg = string.Format("Unable to declare queue {0} for {1}. This usually happens when the queue was already declared with different parameters. For now Messaging Service expect it to be a Durable queue with no other options", queueConfig.Name, description);
        logger.LogException(msg, ex);
        throw new Exception(msg, ex);
      }
    }

    private void CreateArchiveWorker()
    {
      mArchiveWorker = new ArchiveWorker();
      mArchiveWorkerThread = new Thread(new ThreadStart(mArchiveWorker.ArchiveWorkerThreadStart));
      mArchiveWorkerThread.Start();
    }

    private void CreateTimeoutWorker()
    {
      mTimeoutWorker = new TimeoutWorker();
      mTimeoutWorkerThread = new Thread(new ThreadStart(mTimeoutWorker.TimeoutWorkerThreadStart));
      mTimeoutWorkerThread.Start();
    }

    private void CreateControlWorker()
    {
      ControlWorker controlWorker = new ControlWorker();
      //controlWorker.requestWorker = requestWorker;
      controlWorker.RequestWorkerPool = RequestWorkerPool;
      controlWorker.ResponseWorkerPool = ResponseWorkerPool;
      controlWorker.ArchiveWorker = mArchiveWorker;
      controlWorker.TimeoutWorker = mTimeoutWorker;
      mControlWorkerThread = new Thread(new ThreadStart(controlWorker.ControlWorkersThreadStart));
      mControlWorkerThread.Start();
    }

    private void CreateResponseWorkers()
    {
      ResponseWorkerPool = new WorkerPool<ResponseWorker>(Configuration.ThreadPool.MaxResponsePoolThreads);
      ResponseWorkerPool.QueueConfig = Configuration.ResponseQueue;
      ResponseWorkerPool.CreateWorkers();
    }

    private void CreateRequestWorkers()
    {
      RequestWorkerPool = new WorkerPool<RequestWorker>(Configuration.ThreadPool.MaxRequestPoolThreads);
      RequestWorkerPool.QueueConfig = Configuration.RequestQueue;
      RequestWorkerPool.CreateWorkers();
    }

    public void Stop()
    {
      logger.LogDebug("Stopping MessageProcessor");
      try
      {
        HaltProcessingCallback.IsShuttingDown = true;
        RequestWorkerPool.Join();
        ResponseWorkerPool.Join();
        if (!mControlWorkerThread.Join(2000))
        {
          logger.LogError("Forcing shutdown after 2 seconds");
          mControlWorkerThread.Abort();
        }
        mArchiveWorkerThread.Join();
        mTimeoutWorkerThread.Join();
        //mTimeoutWorkerThread.Join();
        logger.LogDebug("Closing Repository");
        Persistence.IRequestRepository repository = SharedStructures.Repository;
        if (repository is IDisposable) (repository as IDisposable).Dispose();
        SharedStructures.Repository = null;
        logger.LogInfo("MessageProcessor stopped");
      }
      catch (Exception ex)
      {
        logger.LogException("Error when stopping MessageProcessor", ex);
      }
    }


  }


}
