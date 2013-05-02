using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.DataAccess;
using MetraTech.UsageServer;
using MetraTech.Interop.MTAuth;

namespace MetraTech.Tax.Framework.Test
{
    public class MockContext : IRecurringEventRunContext
    {

        int mRunID;
        public int RunID
        {
            get
            {
                return mRunID;
            }
            set
            {
                mRunID = value;
            }
        }

        int mRunIDToReverse;
        public int RunIDToReverse
        {
            get
            {
                return mRunIDToReverse;
            }
            set
            {
                mRunIDToReverse = value;
            }
        }

        RecurringEventType mEventType;
        public RecurringEventType EventType
        {
            get
            {
                return mEventType;
            }
            set
            {
                mEventType = value;
            }
        }

        int mIntervalID;
        public int UsageIntervalID
        {
            get
            {
                return mIntervalID;
            }
            set
            {
                mIntervalID = value;
            }
        }

        DateTime mStartDate;
        public DateTime StartDate
        {
            get
            {
                return mStartDate;
            }
            set
            {
                mStartDate = value;
            }
        }

        DateTime mEndDate;
        public DateTime EndDate
        {
            get
            {
                return mEndDate;
            }
            set
            {
                mEndDate = value;
            }
        }

        int mBillingGroupID;
        public int BillingGroupID
        {
            get
            {
                return mBillingGroupID;
            }
            set
            {
                mBillingGroupID = value;
            }
        }

        public void RecordInfo(string details)
        {
        }

        public void RecordWarning(string details)
        {
        }

        public void RecordInfoBatch(MetraTech.Interop.Rowset.IMTRowSet details)
        {
        }

        public void RecordWarningBatch(MetraTech.Interop.Rowset.IMTRowSet details)
        {
        }

        public void RecordFailureAccount(int accountID)
        {
            throw new NotImplementedException("RecordFailureAccount has not been implemented");
        }

        public void RecordFailureAccountsFromFailedTransactions()
        {
            throw new NotImplementedException("RecordFailureAccountsFromFailedTransactions has not been implemented");
        }

        public string AutoReverse()
        {
            return AdapterManager.Reverse(this);
        }

        public IRecurringEventRunContext CreateDerivedEndOfPeriodContext(int usageIntervalID)
        {
            UsageServer.RecurringEventRunContext derivedContext = new UsageServer.RecurringEventRunContext();

            // the Run IDs are inherited from the original context
            // this allows the infrastructure to link the original and derived contexts as one run
            derivedContext.RunID = mRunID;
            derivedContext.RunIDToReverse = mRunIDToReverse;

            derivedContext.EventType = RecurringEventType.EndOfPeriod;
            derivedContext.UsageIntervalID = usageIntervalID;

            return derivedContext;
        }

        public IRecurringEventRunContext CreateDerivedScheduledContext(DateTime startDate, DateTime endDate)
        {
            UsageServer.RecurringEventRunContext derivedContext = new UsageServer.RecurringEventRunContext();

            // the Run IDs are inherited from the original context
            // this allows the infrastructure to link the original and derived contexts as one run
            derivedContext.RunID = mRunID;
            derivedContext.RunIDToReverse = mRunIDToReverse;

            derivedContext.EventType = RecurringEventType.Scheduled;
            derivedContext.StartDate = startDate;
            derivedContext.EndDate = endDate;

            return derivedContext;
        }

        private const int NVARCHAR_MAX = 4000;

        private void RecordDetail(string type, string details)
        {

            // detail length must be less than 4000 characters because of NVARCHAR limitations
            if (details.Length <= NVARCHAR_MAX)
                InsertDetail(type, details);
            else
            {
                // recursively breaks the detail string up into multiple bite-sized records
                InsertDetail(type, details.Substring(0, NVARCHAR_MAX));
                RecordDetail(type, details.Substring(NVARCHAR_MAX));
            }
        }

        private void InsertDetail(string type, string details)
        {
            using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\UsageServer",
                                                                                                                             "__RECORD_RECURRING_EVENT_RUN_DETAIL__"))
                {
                    stmt.AddParam("%%ID_RUN%%", mRunID);
                    stmt.AddParam("%%TX_TYPE%%", type);
                    stmt.AddParam("%%TX_DETAIL%%", details);

                    stmt.ExecuteNonQuery();
                }
            }
        }

        private void RecordDetailBatch(string type, MetraTech.Interop.Rowset.IMTRowSet aDetails)
        {

        }

        public override string ToString()
        {
            if (mEventType == RecurringEventType.EndOfPeriod)
                return String.Format("RunID={0}, EventType={1}, RunIDToReverse={2}, UsageIntervalID={3}, BillingGroupID={4}",
                                                         mRunID, mEventType, mRunIDToReverse, mIntervalID, mBillingGroupID);
            else
                return String.Format("RunID={0}, EventType={1}, RunIDToReverse={2}, StartDate={3}, EndDate={4}",
                                                         mRunID, mEventType, mRunIDToReverse, mStartDate, mEndDate);
        }
    }
}
