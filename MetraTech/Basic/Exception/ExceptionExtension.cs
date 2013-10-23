// -----------------------------------------------------------------------
// <copyright file="ExceptionExtension.cs" company="Microsoft">
// TODO: Update copyright text.
// </copyright>
// -----------------------------------------------------------------------

namespace MetraTech.Basic.Exception
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;

    /// <summary>
    /// Extension for getting inner exceptions
    /// </summary>
    public static class ExceptionExtension
    {
        public static IEnumerable<Exception> FromHierarchy(
            this Exception source,
            Func<Exception, Exception> nextItem,
            Func<Exception, bool> canContinue)
        {
            for (var current = source; canContinue(current); current = nextItem(current))
            {
                yield return current;
            }
        }

        public static IEnumerable<Exception> FromHierarchy(
            this Exception source,
            Func<Exception, Exception> nextItem)
        {
            return FromHierarchy(source, nextItem, s => s != null);
        }

        public static string GetaAllMessages(this Exception exception)
        {
            var messages = exception.FromHierarchy(ex => ex.InnerException)
                .Select(ex => ex.Message);
            return String.Join(Environment.NewLine, messages);
        }
    }
}
