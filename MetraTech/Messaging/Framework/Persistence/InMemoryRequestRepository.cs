using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.Messaging.Framework.Persistence
{
  using Messages;

  public class InMemoryRequestRepository : IRequestRepository
  {
    #region IRequestRepository Members

    public void StoreRequest(Request message)
    {
      throw new NotImplementedException();
    }

    public void DeleteRequest(Guid correlationId)
    {
      throw new NotImplementedException();
    }

    public Dictionary<Guid, Request> GetTimeouts(DateTime timeoutDate)
    {
      throw new NotImplementedException();
    }

    public bool CancelTimeout(Guid correlationId)
    {
      throw new NotImplementedException();
    }

    public int CancelTimeout(DateTime timeoutDate)
    {
      throw new NotImplementedException();
    }

    public int ArchiveOldRequests(DateTime createDate)
    {
      throw new NotImplementedException();
    }

    public void Flush()
    {
      throw new NotImplementedException();
    }

    public Request GetRequest(Guid correlationId)
    {
      throw new NotImplementedException();
    }

    #endregion
  }
}
