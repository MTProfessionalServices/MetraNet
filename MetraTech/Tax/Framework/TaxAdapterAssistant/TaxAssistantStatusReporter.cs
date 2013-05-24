using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.UsageServer;

namespace MetraTech.Tax.Framework
{
    public class TaxAssistantStatusReporter : ITaxManagerStatusReporter
    {
        private IRecurringEventRunContext mContext = null;

        public TaxAssistantStatusReporter(IRecurringEventRunContext context)
        {
            mContext = context;
        }

        public void ReportInfo(string detail)
        {
            mContext.RecordInfo(detail);
        }

        public void ReportWarning(string detail)
        {
            mContext.RecordWarning(detail);
        }
    }
}
