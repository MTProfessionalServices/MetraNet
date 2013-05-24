using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.Messaging.Framework.Persistence
{
  using Messages;

  /// <summary>
  /// All messages are persisted through this class.
  /// </summary>
  public interface IRequestRepository
  {
    /// <summary>
    /// Stores a message in Repository
    /// </summary>
    /// <param name="correlationId"></param>
    /// <param name="message"></param>
    void StoreRequest(Request message);

    /// <summary>
    /// Reads a message from a repository
    /// </summary>
    /// <param name="correlationId"></param>
    /// <returns></returns>
    Request GetRequest(Guid correlationId);

    /// <summary>
    /// Delete a Message from Repository
    /// </summary>
    /// <param name="correlationId"></param>
    void DeleteRequest(Guid correlationId);
    
    /// <summary>
    /// Get All the messages that are stored in repository, that have timed out at the specified date
    /// Timed out messages are messages that have 
    ///   IsTimeoutNeeded = true
    ///   TimeoutDate less than timeoutDate
    /// </summary>
    /// <param name="timeoutDate">messages older than this date have timedout</param>
    /// <returns>timedout messages</returns>
    Dictionary<Guid,Request> GetTimeouts(DateTime timeoutDate);
    
    /// <summary>
    /// Cancels the timeout.
    /// Mark the message identified by CorrelationId as timedout isTimeout=true
    /// </summary>
    /// <param name="correlationId">message identifier</param>
    /// <returns>true - message updated. False - message not found or already updated</returns>
    bool CancelTimeout(Guid correlationId);

    /// <summary>
    /// Cancels timeout for all messages older than timeout date
    /// </summary>
    /// <param name="timeoutDate"></param>
    /// <returns></returns>
    int CancelTimeout(DateTime timeoutDate);

    /// <summary>
    /// Deletes/archives all the messages older than date
    /// </summary>
    /// <param name="CreateDate"></param>
    /// <returns>number of messages archived</returns>
    int ArchiveOldRequests(DateTime createDate);

    /// <summary>
    /// Flushes changes to Disk, Commits to the Database or nothing.
    /// </summary>
    void Flush();

  }
}
