using System;
using System.Collections.Generic;
using System.ServiceModel;
using System.Text;
using System.Threading;

using MetraTech;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.MetraPay;

namespace MetraTech.UsageServer.Adapters
{
  public class PreAuthRequestData
  {
    private Logger mLogger = new Logger("[PaymentAuthorizationAdapter]");
    private Guid paymentInstrumentId;
    public Guid PaymentInstrumentId
    {
        get { return paymentInstrumentId;  }
        //set { paymentIstrumentId = value; }
    }

    private MetraPaymentInfo paymentInfo;
    public MetraPaymentInfo PaymentInfo
    {
      get { return paymentInfo; }
      //set { paymentIstrumentId = value; }
    }

    private Guid authToken;
    public Guid AuthToken
    {
      get { return authToken; }
      set { authToken = value; }
    }

    private int intervalId;
    public int IntervalId
    {
      get { return intervalId; }
      set { intervalId = value; }
    }

    private int accountId;
    public int AccountId
    {
      get { return accountId; }
      set { accountId = value; }
    }

    public int PendingPaymentId { get; set; }

    private IAsyncResult asyncResult;
    public IAsyncResult AsyncResult
    {
      get {return asyncResult; }
      set {asyncResult = value;}
    }

    public PreAuthRequestData(int pendingPaymentId, Guid pId, MetraPaymentInfo mpi, int iId, int accId)
    {
        PendingPaymentId = pendingPaymentId;
      paymentInstrumentId = pId;
      paymentInfo = mpi;
      intervalId = iId;
      accountId = accId;
    }

    /*
     * TODO: Remember to delete.  Leaving in for an excercise
     * 
     * public void RequestCallBack(IAsyncResult ar)
    {
      try
      {
        RecurringPaymentsServiceClient client = (RecurringPaymentsServiceClient)ar.AsyncState;   
        client.EndPreAuthorizeCharge(out authToken, ar);
        
        // TODO: Might be unecessary . . .
        this.AuthToken = authToken;
      }
      catch (FaultException<MASBasicFaultDetail> e)
      {
        mLogger.LogError(String.Format("An error occured {0}"), e.Detail.ErrorMessages[0]);
      }
    }*/
  }
}
