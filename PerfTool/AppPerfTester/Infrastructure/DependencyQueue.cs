using System;
using System.Data;
using System.Threading;
using MetraTech.DomainModel.BaseTypes;


namespace BaselineGUI
{
    /// <summary>
    /// This is like a queue except that not all elements are ready
    /// to be dequeued.  We scan the queue looking for the next
    /// item that is ready to go.
    /// Each item has a sequence number.  The item can specify a
    /// predecessor dependency by giving its sequence number.
    /// 
    /// The descriptor states are:
    /// 0 - empty
    /// 1 - needs to be processed
    /// 2 - in process
    /// 3 - done
    /// </summary>
    /// 
    public class DependencyQueue
    {
        static int ringSize = 400;
        int newest = 0;
        int oldest = 0;
        int count = 0;

        public DataTable ringState;

        public AccountLoadDesc[] accountsToLoad = new AccountLoadDesc[ringSize];

        public bool[] corpAcctBinBusy;

        public DependencyQueue()
        {
            ringState = new DataTable();
            ringState.Columns.Add(new DataColumn("Pos", typeof(int)));
            ringState.Columns.Add(new DataColumn("State", typeof(int)));
            ringState.Columns.Add(new DataColumn("Sequence", typeof(int)));
            ringState.Columns.Add(new DataColumn("Predecessor", typeof(int)));

            ringState.Columns.Add(new DataColumn("Type", typeof(string)));
            ringState.Columns.Add(new DataColumn("UserName", typeof(string)));
            ringState.Columns.Add(new DataColumn("Message", typeof(string)));

            ringState.Columns.Add(new DataColumn("Queued", typeof(DateTime)));
            ringState.Columns.Add(new DataColumn("Completion", typeof(DateTime)));

            for (int ix = 0; ix < ringSize; ix++)
            {
                AccountLoadDesc ld = new AccountLoadDesc();
                DataRow r = ringState.NewRow();
                r["Pos"] = ix;
                ringState.Rows.Add(r);
                ld.status = r;
                ld.state = 0;
                accountsToLoad[ix] = ld;
            }

            corpAcctBinBusy = new bool[1000];
            for (int ix = 0; ix < 1000; ix++)
            {
                corpAcctBinBusy[ix] = false;
            }

        }

        public AccountLoadDesc at(int pos)
        {
            return accountsToLoad[pos];
        }

        public void Enqueue(Account acct, int seq, int predecessor, int corpAcctBin)
        {
            if (acct == null)
            {
                Console.WriteLine("Enqueued a null account");
                Exception e = new Exception("Enqueued a null account");
                throw e;
            }

            while (true)
            {
                lock (accountsToLoad)
                {
                    if (count < ringSize)
                        break;
                }
                Thread.Sleep(1000);
            }

            lock (accountsToLoad)
            {
                AccountLoadDesc ld;

                int pos = seq % ringSize;
                ld = accountsToLoad[pos];
                ld.acct = acct;
                ld.sequence = seq;
                ld.predecessor = predecessor;
                ld.state = 1;
                ld.timeOfQueue = DateTime.Now;
                ld.corpAccountBin = corpAcctBin;

                newest++;
                if (newest >= ringSize)
                    newest = 0;
                count++;
                Monitor.Pulse(accountsToLoad);
            }

        }


        public int scanForNext()
        {
            int p = oldest;

            for (int ix = 0; ix < count; ix++)
            {
                AccountLoadDesc ld = accountsToLoad[p];
                if (ld.state == 1  && !corpAcctBinBusy[ld.corpAccountBin]) // needs to be loaded
                {
                    if (ld.predecessor == -1)
                        return p;
                    if (ld.predecessor < accountsToLoad[oldest].sequence)
                        return p;
                    int pos = ld.predecessor % ringSize;
                    if (accountsToLoad[pos].state == 3)
                        return p;
                }
                p++;
                if (p >= ringSize)
                    p = 0;
            }
            return -1;

        }


        public int Dequeue(int maxWait = -1)
        {
            lock (accountsToLoad)
            {
            loop:
                int pos = scanForNext();
                if (pos != -1)
                {
                    AccountLoadDesc ld = accountsToLoad[pos];
                    ld.state = 2;
                    corpAcctBinBusy[ld.corpAccountBin] = true;
                    return pos;
                }

                if (maxWait == 0)
                    return pos;
                Monitor.Wait(accountsToLoad, maxWait);
                maxWait = 0;
                goto loop;
            }
        }


        public void Cleanup()
        {
            lock (accountsToLoad)
            {
                foreach (AccountLoadDesc ld in accountsToLoad)
                {
                    if (ld.state == 3)
                    {
                        corpAcctBinBusy[ld.corpAccountBin] = false;
                        ld.corpAccountBin = 999;
                    }
                }

                while (count > 0 && accountsToLoad[oldest].state == 3)
                {
                    AccountLoadDesc ld = accountsToLoad[oldest];
                    ld.acct = null;
                    oldest++;
                    if (oldest >= ringSize)
                        oldest = 0;
                    count--;
                }
            }

        }


    }
}
