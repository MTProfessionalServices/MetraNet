using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ServiceModel;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.ActivityServices.Common;

namespace MetraTech.Core.Services
{
  [ServiceContract]
  public interface IQueueManagementService
  {
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [TransactionFlow(TransactionFlowOption.Allowed)]
    void ClearQueue(string queueName);
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [TransactionFlow(TransactionFlowOption.Allowed)]
    void GetQueueLength(string queueName, out int length);
  }

  [ServiceBehavior(ConcurrencyMode = ConcurrencyMode.Multiple, InstanceContextMode = InstanceContextMode.Single)]
  public class QueueManagementService : CMASServiceBase, IQueueManagementService
  {
    public void ClearQueue(string queueName)
    {
    }

    public void GetQueueLength(string queueName, out int length)
    {
      length = 55; //stubbed
    }
  }
}
