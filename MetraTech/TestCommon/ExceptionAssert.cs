using System;
using System.Globalization;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.TestCommon
{
    /// <summary>
    /// This is help class for Assert expected exceptions in tests
    /// </summary>
    public static class ExceptionAssert
    {
        /// <summary>
        /// This method expects in action the exception of specified type or type that inherited from given
        /// </summary>
        /// <typeparam name="T">The type of expected exception</typeparam>
        /// <param name="function">The action instance of invoked method</param>
        /// <returns>The catched exception</returns>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Design", "CA1031:DoNotCatchGeneralExceptionTypes", Justification = "AZhurba: We should catch all exceptions to re-throw AsserFailedException by design")]
        public static T Expected<T>(Action function) where T : Exception
        {
            if (function == null)
            {
                throw new ArgumentNullException("function");
            }

            try
            {
                function.Invoke();
            }
            catch (T e)
            {
                return e;
            }
            catch (Exception ex)
            {
                var message = string.Format(CultureInfo.InvariantCulture, "An exception of type {0} is expected but exception of type {1} is throwed. Stack trace of the exception:\n{2}", typeof(T).FullName, ex.GetType().FullName, ex);
                throw new AssertFailedException(message, ex);
            }
            Assert.Fail("An exception of type {0} was expected.", typeof(T).FullName);
            // ReSharper disable HeuristicUnreachableCode
            return default(T);
            // ReSharper restore HeuristicUnreachableCode
        }

        /// <summary>
        /// This method expects in Action the exception of specified type and check exception message to given expected exception message.
        /// </summary>
        /// <typeparam name="T">The type of expected exception</typeparam>
        /// <param name="function">The action instance of invoked method</param>
        /// <param name="expectedExceptionMessage">The expected message of exception</param>
        /// <returns>The catched exception</returns>
        public static T Expected<T>(Action function, string expectedExceptionMessage) where T : Exception
        {
            var exception = Expected<T>(function);
            Assert.AreEqual(expectedExceptionMessage, exception.Message,
              "The message of exception doesn't equal expected.");
            return exception;
        }

        /// <summary>
        /// This method expects in Action the exception of specified typ
        /// </summary>
        /// <typeparam name="T">The type of expected exception</typeparam>
        /// <param name="function">The action instance of invoked method</param>
        /// <returns>The catched exception</returns>
        public static T ExpectedExactly<T>(Action function) where T : Exception
        {
            var exception = Expected<T>(function);
            Assert.AreEqual(exception.GetType().FullName, typeof(T).FullName,
                string.Format(CultureInfo.InvariantCulture, "An exception of type {0} is expected but exception of type {1} is throwed.", typeof(T).FullName, exception.GetType().FullName));
            return exception;
        }

        /// <summary>
        /// This method expects in Action the ArgumenNullException and check message with parameter name
        /// </summary>
        /// <param name="function">The action instance of invoked method</param>
        /// <param name="parameterName">Parameter name which null</param>
        public static void ExpectedArgumentNullException(Action function, string parameterName)
        {
            var argumentNullException = Expected<ArgumentNullException>(function);
            Assert.AreEqual(parameterName, argumentNullException.ParamName);
        }
    }
}

