// -----------------------------------------------------------------------
// <copyright file="QuoteException.cs" company="Microsoft">
// TODO: Update copyright text.
// </copyright>
// -----------------------------------------------------------------------

using System;
using MetraTech.Domain.Quoting;

namespace MetraTech.Core.Services.Quoting
{
  /// <summary>
    /// Exception for quoting functionaliy
    /// </summary>
    public class QuoteException : Exception
    {
        public QuoteResponse Response { get; private set; }
        public QuoteException(QuoteResponse response, string errorMessage, Exception ex) :
            base(errorMessage, ex)
        {
            Response = response;
        }

        public QuoteException(QuoteResponse response, string errorMessage) 
            : this(response, errorMessage, null){}
    }
}
