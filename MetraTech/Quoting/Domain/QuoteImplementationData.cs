// -----------------------------------------------------------------------
// <copyright file="QuoteVerifyImplementation.cs" company="Microsoft">
// TODO: Update copyright text.
// </copyright>
// -----------------------------------------------------------------------

using MetraTech.Domain.Quoting;

namespace MetraTech.Quoting.Test.Domain
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;

    /// <summary>
    /// Uses in test for verifying 
    /// </summary>
    public class QuoteImplementationData
    {
        public IQuotingImplementation QuoteImplementation { get; set; }
        public QuoteRequest Request { get; private set; }
        public QuoteResponse Response { get; set; }

        public QuoteImplementationData()
        {
            Request = new QuoteRequest();
        }

        public QuoteImplementationData(QuoteRequest request)
        {
            Request = request;
        }
    }
}
