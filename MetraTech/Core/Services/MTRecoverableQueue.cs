using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;
using System.Messaging;
using System.Xml.Serialization;
using System.Runtime.Serialization;

namespace MetraTech.Core.Services
{
    public class MTRecoverableQueue<T>
    {
        public enum QueuePriority
        {
            Normal = 0,
            High = 1
        }

        public class HandlerArgs
        {
            public string QueueName { get; set; }
            public bool IsRecovering { get; set; }
        }

        public delegate bool DoWork(T t, HandlerArgs args);

        static MTRecoverableQueue()
        {
            m_QueueName = @".\Private$\" + typeof(T) + "_";
            MessageQueue.EnableConnectionCache = true;
        }

        public MTRecoverableQueue(Logger logger, int nThreads, DoWork fn, string label, bool bRemoveOnException)
        {
            m_Logger = logger;
            m_fn = fn;
            m_Label = label;
            m_nThreads = nThreads;
            m_ThreadPool = new Thread[nThreads];
            m_bRemoveAlways = bRemoveOnException;

            try
            {
                m_MainQueue = GetMessageQueue("Main", false);
                m_MainThread = new Thread(MainThreadFn);
                m_MainThread.Start();

                int i = 0;
                for (; i < nThreads; i++)
                {
                    m_ThreadPool[i] = new Thread(new ParameterizedThreadStart(ThreadFn));
                    m_ThreadPool[i].Start(i);
                }

                RecoverExtraQueues(i);

            }
            catch (MessageQueueException e)
            {
                m_Logger.LogException(String.Format("Exception creating {0} message queue", m_Label), e);
            }
            catch (Exception e)
            {
                m_Logger.LogException("Exception starting recoverable queue", e);
            }
        }

        public void Enqueue(T item)
        {
            Enqueue(item, MTRecoverableQueue<T>.QueuePriority.Normal);
        }

        public void Enqueue(T item, QueuePriority priority)
        {
            Message message = new Message(item);
            message.Priority = (priority == MTRecoverableQueue<T>.QueuePriority.Normal ? MessagePriority.Normal : MessagePriority.High);
            message.Formatter = m_Formatter;
            message.AppSpecific = (int)MTQMessageType.Payload;
            message.Recoverable = false;
            m_MainQueue.Send(message);
            m_Logger.LogDebug(String.Format("Sent message to queue: {0}", m_MainQueue.QueueName));
        }

        public void Stop()
        {
            try
            {
                m_bStopRequested = true;

                Message msg = new Message();
                msg.Priority = MessagePriority.Highest;
                msg.AppSpecific = (int)MTQMessageType.Control;
                m_MainQueue.Send(msg);

                m_stopEvent.Set();

                m_MainThread.Join();


                for (int i = 0; i < m_nThreads; i++)
                {
                    m_ThreadPool[i].Join();
                }

                m_MainQueue.Close();
            }
            catch (MessageQueueException e)
            {
                m_Logger.LogException("Error terminationg queues", e);
            }
        }

        private MessageQueue GetMessageQueue(string suffix, bool bExistingOnly)
        {
            string name = m_QueueName + suffix;

            MessageQueue mq = null;
            if (MessageQueue.Exists(name))
            {
                mq = new MessageQueue(name);
            }
            else if (!bExistingOnly)
            {
                mq = MessageQueue.Create(name, false);
            }

            if (mq != null)
            {
                mq.Formatter = m_Formatter;
                if (mq.Formatter is XmlMessageFormatter)
                {
                    ((XmlMessageFormatter)mq.Formatter).TargetTypes = new Type[] { typeof(T) };
                }
                mq.MessageReadPropertyFilter = new MessagePropertyFilter();
                mq.MessageReadPropertyFilter.SetDefaults();
                mq.MessageReadPropertyFilter.AppSpecific = true;
                mq.DefaultPropertiesToSend.Recoverable = true;
                mq.UseJournalQueue = false;
                mq.MaximumQueueSize = MessageQueue.InfiniteQueueSize;
                mq.Label = m_Label;
                mq.SetPermissions("Administrators", MessageQueueAccessRights.FullControl);
            }

            return mq;
        }

        private MessageQueue GetMessageQueue(int suffix, bool bExistingOnly)
        {
            return GetMessageQueue(suffix.ToString(), bExistingOnly);
        }

        private void RecoverExtraQueues(int i)
        {
            while (true)
            {
                MessageQueue mq = GetMessageQueue(i, true);
                if (mq != null)
                {
                    bool bException = false;

                    using (MQMessageEnumerator it = new MTRecoverableQueue<T>.MQMessageEnumerator(mq, m_Logger))
                    {
                        Message message = null;

                        while (it.MoveNext())
                        {
                            try
                            {
                                message = it.Current;
                                if (message.AppSpecific != (int)MTQMessageType.Control)
                                {
                                    m_MainQueue.Send(it.Current);
                                }
                                it.RemoveCurrent();
                            }
                            catch (Exception e)
                            {
                                if (!m_bRemoveAlways)
                                {
                                    bException = true;

                                    if (message != null)
                                    {
                                        m_Logger.LogException(String.Format("{0} : Exception while recovering extra queues. Message id = {1}. ", mq.QueueName, message.Id), e);
                                    }
                                    else
                                    {
                                        m_Logger.LogException(String.Format("{0} : Exception while recovering extra queues. The message is not available. ", mq.QueueName), e);
                                    }
                                }
                                else
                                {
                                    it.RemoveCurrent();
                                    m_Logger.LogException(String.Format("{0} : Exception in payload execution. The message has been removed. ", mq.QueueName), e);
                                }
                            }
                        }
                    }

                    string qPath = mq.Path;
                    mq.Close();

                    if (!bException)
                    {
                        MessageQueue.Delete(qPath);
                    }
                }
                else
                {
                    break;
                }

                i++;
            }
        }

        private void MainThreadFn()
        {
            WaitHandle[] signals = new WaitHandle[2];
            signals[idxMessageHandled] = m_MessageHandled;
            signals[idxStopEvent] = m_stopEvent;

            while (true)
            {
                Message message = m_MainQueue.Peek();

                if (message.AppSpecific == (int)MTQMessageType.Control)
                {
                    m_MainQueue.Receive();

                    if (m_bStopRequested)
                    {
                        break;
                    }
                }

                m_MessageArrived.Set();

                int signal = WaitHandle.WaitAny(signals);

                if (m_bStopRequested || signal == idxStopEvent)
                {
                    break;
                }
            }
        }

        private void ThreadFn(object args)
        {
            int index = (int)args;
            bool bContinue = false;
            MessageQueue mq = null;

            HandlerArgs hargs = new MTRecoverableQueue<T>.HandlerArgs();

            WaitHandle[] signals = new WaitHandle[2];
            signals[idxMessageArrived] = m_MessageArrived;
            signals[idxStopEvent] = m_stopEvent;

            try
            {
                mq = GetMessageQueue(index, false);
                hargs.QueueName = mq.QueueName;
                hargs.IsRecovering = true;

                bContinue = true;

                while (bContinue)
                {
                    #region Process messages in the local queue 

                    using (MQMessageEnumerator it = new MTRecoverableQueue<T>.MQMessageEnumerator(mq, m_Logger))
                    {

                        while (it.MoveNext())
                        {
                            Message workMessage = null;

                            try
                            {
                                workMessage = it.Current;

                                if (m_fn((T)workMessage.Body, hargs))
                                {
                                    it.RemoveCurrent();
                                }
                            }
                            catch (Exception e)
                            {
                                if (!m_bRemoveAlways)
                                {
                                    if (workMessage != null)
                                    {
                                        m_Logger.LogException(String.Format("{0} : Exception in payload execution. Message id = {1}. ", mq.QueueName, workMessage.Id), e);
                                    }
                                    else
                                    {
                                        m_Logger.LogException(String.Format("{0} : Exception in payload execution. The message is not available. ", mq.QueueName), e);
                                    }
                                }
                                else
                                {
                                    it.RemoveCurrent();
                                    m_Logger.LogException(String.Format("{0} : Exception in payload execution. The message has been removed. ", mq.QueueName), e);
                                }
                            }
                        }
                    }

                    hargs.IsRecovering = false;

                    #endregion

                    #region Move a message from the main queue to the local queue

                    int signal = WaitHandle.WaitAny(signals);

                    if (m_bStopRequested || signal == idxStopEvent)
                    {
                        bContinue = false;
                        break;
                    }

                    if (signal == idxMessageArrived)
                    {
                        Message message = m_MainQueue.Peek();
                        if (message.AppSpecific == (int)MTQMessageType.Payload)
                        {
                            mq.Send(message);
                            m_MainQueue.Receive();
                        }

                        //Need to allow the main queue thread
                        //to wake up and check for a control message
                        m_MessageHandled.Set();
                    }

                    #endregion
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException(String.Format("Exception perfoming work on {0}", typeof(T)), e);
            }
            finally
            {
                if (mq != null)
                {
                    mq.Close();
                }

                if (bContinue)
                {
                    m_ThreadPool[index] = new Thread(new ParameterizedThreadStart(ThreadFn));
                    m_ThreadPool[index].Start(index);
                }
            }
        }

        enum MTQMessageType : int
        {
            Payload = 0,
            Control = 1
        }

        private class MQMessageEnumerator : IDisposable
        {
            public MQMessageEnumerator(MessageQueue mq, Logger logger)
            {
                m_Logger = logger;
                m_QName = mq.QueueName;
                it = mq.GetMessageEnumerator2();
            }

            ~MQMessageEnumerator()
            {
                Dispose(false);
            }

            public bool MoveNext()
            {
                if (m_bKeepProcessing)
                {
                    if (!m_bSkipMove)
                    {
                        if (it.MoveNext())
                        {
                            SetCurrent();
                            m_bKeepProcessing = true;
                        }
                        else
                        {
                            m_bKeepProcessing = false;
                        }
                    }

                    m_bSkipMove = false;
                }
                
                return m_bKeepProcessing;
            }

            public void RemoveCurrent()
            {
                try
                {
                    m_bSkipMove = true;

                    it.RemoveCurrent();
                    SetCurrent();
                }
                catch (MessageQueueException e)
                {
                    // Can get a timeout due to RemoveCurrent not finding the next message to move to (i.e. queue is empty)
                    if (e.MessageQueueErrorCode != MessageQueueErrorCode.IOTimeout)
                    {
                        m_Logger.LogException(String.Format("{0} : Message Queue Exception in payload execution.", m_QName), e);
                    }

                    m_bKeepProcessing = false;
                    m_Current = null;
                }
                catch (Exception ex)
                {
                    m_Logger.LogException(String.Format("{0} : Unknown exception navigating message queue", m_QName), ex);
                    m_bKeepProcessing = false;
                    m_Current = null;
                }

            }

            public Message Current
            {
                get
                {
                    return m_Current;
                }
            }

            private void SetCurrent()
            {
                try
                {
                    m_Current = it.Current;
                }
                catch (MessageQueueException e)
                {
                    // We're treating IOTimeout errors differently since we expect them to only be thrown when accessing
                    // the Current property of the iterator when it points to beyond the end of the queue (e.g no more items)
                    // We swallow these since we expect them often.  If we get another queue exception, we'll log and then stop
                    // processing until we get another message
                    if (e.MessageQueueErrorCode != MessageQueueErrorCode.IOTimeout)
                    {
                        m_Logger.LogException(String.Format("{0} : Message Queue Exception in payload execution.", m_QName), e);
                    }

                    m_bKeepProcessing = false;
                    m_Current = null;
                }
                catch (Exception ex)
                {
                    m_Logger.LogException(String.Format("{0} : Unknown exception navigating message queue", m_QName), ex);
                    m_bKeepProcessing = false;
                    m_Current = null;
                }
            }

            #region IDisposable Members

            public void Dispose()
            {
                Dispose(true);

                GC.SuppressFinalize(this);
            }

            #endregion

            private void Dispose(bool bDisposing)
            {
                if (!m_bDisposed)
                {
                    m_bDisposed = true;

                    it.Close();

                    if (bDisposing)
                    {
                        it.Dispose();
                    }
                }
            }


            MessageEnumerator it;
            String m_QName;
            Message m_Current = null;
            bool m_bSkipMove = false;
            bool m_bKeepProcessing = true;
            Logger m_Logger;
            bool m_bDisposed = false;

        }

        static string m_QueueName;
        static BinaryMessageFormatter m_Formatter = new BinaryMessageFormatter();

        MessageQueue m_MainQueue;
        Thread m_MainThread;
        Logger m_Logger;
        DoWork m_fn;
        String m_Label;
        int m_nThreads;
        Thread[] m_ThreadPool;
        ManualResetEvent m_stopEvent = new ManualResetEvent(false);
        AutoResetEvent m_MessageArrived = new AutoResetEvent(false);
        AutoResetEvent m_MessageHandled = new AutoResetEvent(false);
        const int idxMessageArrived = 1;
        const int idxMessageHandled = 1;
        const int idxStopEvent = 0;
        bool m_bStopRequested = false;
        bool m_bRemoveAlways = false;
    }

}