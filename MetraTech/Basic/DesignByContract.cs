using System.Diagnostics;

using MetraTech.Basic.Exception;

namespace MetraTech.Basic
{
  /// <summary>
  /// Design by Contract checks developed by http://www.codeproject.com/KB/cs/designbycontract.aspx.
  /// 
  /// Each method generates an exception or
  /// a trace assertion statement if the contract is broken.
  /// </summary>
  /// <remarks>
  /// This example shows how to call the Require method.
  /// Assume DBC_CHECK_PRECONDITION is defined.
  /// <code>
  /// public void Test(int x)
  /// {
  /// 	try
  /// 	{
  ///			Check.Require(x > 1, "x must be > 1");
  ///		}
  ///		catch (System.Exception ex)
  ///		{
  ///			Console.WriteLine(ex.ToString());
  ///		}
  ///	}
  /// </code>
  /// If you wish to use trace assertion statements, intended for Debug scenarios,
  /// rather than exception handling then set 
  /// 
  /// <code>Check.UseAssertions = true</code>
  /// 
  /// You can specify this in your application entry point and maybe make it
  /// dependent on conditional compilation flags or configuration file settings, e.g.,
  /// <code>
  /// #if DBC_USE_ASSERTIONS
  /// Check.UseAssertions = true;
  /// #endif
  /// </code>
  /// You can direct output to a Trace listener. For example, you could insert
  /// <code>
  /// Trace.Listeners.Clear();
  /// Trace.Listeners.Add(new TextWriterTraceListener(Console.Out));
  /// </code>
  /// 
  /// or direct output to a file or the Event Log.
  /// 
  /// (Note: For ASP.NET clients use the Listeners collection
  /// of the Debug, not the Trace, object and, for a Release build, only exception-handling
  /// is possible.)
  /// </remarks>
  /// 
  public static class Check
  {
      #region Interface

      /// <summary>
      /// Precondition check - should run regardless of preprocessor directives.
      /// </summary>
      public static void Require(bool assertion, string message) {
          if (UseExceptions) {
              if (!assertion) throw new PreconditionException(message);
          }
          else {
              Trace.Assert(assertion, "Precondition: " + message);
          }
      }

      /// <summary>
      /// Precondition check - should run regardless of preprocessor directives.
      /// </summary>
      public static void Require(bool assertion, string message, string component)
      {
        if (UseExceptions)
        {
          if (!assertion) throw new PreconditionException(message, component);
        }
        else
        {
          Trace.Assert(assertion, "Precondition: " + message);
        }
      }

      /// <summary>
      /// Precondition check - should run regardless of preprocessor directives.
      /// </summary>
      public static void Require(bool assertion, string message, System.Exception inner) {
          if (UseExceptions) {
              if (!assertion) throw new PreconditionException(message, inner);
          }
          else {
              Trace.Assert(assertion, "Precondition: " + message);
          }
      }

      /// <summary>
      /// Precondition check - should run regardless of preprocessor directives.
      /// </summary>
      public static void Require(bool assertion, string message, System.Exception inner, string component)
      {
        if (UseExceptions)
        {
          if (!assertion) throw new PreconditionException(message, inner, component);
        }
        else
        {
          Trace.Assert(assertion, "Precondition: " + message);
        }
      }

      /// <summary>
      /// Precondition check - should run regardless of preprocessor directives.
      /// </summary>
      public static void Require(bool assertion) {
          if (UseExceptions) {
              if (!assertion) throw new PreconditionException("Precondition failed.");
          }
          else {
              Trace.Assert(assertion, "Precondition failed.");
          }
      }


      /// <summary>
      /// Postcondition check.
      /// </summary>
      public static void Ensure(bool assertion, string message) {
          if (UseExceptions) {
              if (!assertion) throw new PostconditionException(message);
          }
          else {
              Trace.Assert(assertion, "Postcondition: " + message);
          }
      }

      /// <summary>
      /// Postcondition check.
      /// </summary>
      public static void Ensure(bool assertion, string message, string component)
      {
        if (UseExceptions)
        {
          if (!assertion) throw new PostconditionException(message, component);
        }
        else
        {
          Trace.Assert(assertion, "Postcondition: " + message);
        }
      }

      /// <summary>
      /// Postcondition check.
      /// </summary>
      public static void Ensure(bool assertion, string message, System.Exception inner) {
          if (UseExceptions) {
              if (!assertion) throw new PostconditionException(message, inner);
          }
          else {
              Trace.Assert(assertion, "Postcondition: " + message);
          }
      }

      /// <summary>
      /// Postcondition check.
      /// </summary>
      public static void Ensure(bool assertion, string message, System.Exception inner, string component)
      {
        if (UseExceptions)
        {
          if (!assertion) throw new PostconditionException(message, inner, component);
        }
        else
        {
          Trace.Assert(assertion, "Postcondition: " + message);
        }
      }

      /// <summary>
      /// Postcondition check.
      /// </summary>
      public static void Ensure(bool assertion) {
          if (UseExceptions) {
              if (!assertion) throw new PostconditionException("Postcondition failed.");
          }
          else {
              Trace.Assert(assertion, "Postcondition failed.");
          }
      }

      /// <summary>
      /// Invariant check.
      /// </summary>
      public static void Invariant(bool assertion, string message) {
          if (UseExceptions) {
              if (!assertion) throw new InvariantException(message);
          }
          else {
              Trace.Assert(assertion, "Invariant: " + message);
          }
      }

      /// <summary>
      /// Invariant check.
      /// </summary>
      public static void Invariant(bool assertion, string message, string component)
      {
        if (UseExceptions)
        {
          if (!assertion) throw new InvariantException(message, component);
        }
        else
        {
          Trace.Assert(assertion, "Invariant: " + message);
        }
      }

      /// <summary>
      /// Invariant check.
      /// </summary>
      public static void Invariant(bool assertion, string message, System.Exception inner) {
          if (UseExceptions) {
              if (!assertion) throw new InvariantException(message, inner);
          }
          else {
              Trace.Assert(assertion, "Invariant: " + message);
          }
      }

      /// <summary>
      /// Invariant check.
      /// </summary>
      public static void Invariant(bool assertion, string message, System.Exception inner, string component)
      {
        if (UseExceptions)
        {
          if (!assertion) throw new InvariantException(message, inner, component);
        }
        else
        {
          Trace.Assert(assertion, "Invariant: " + message);
        }
      }

      /// <summary>
      /// Invariant check.
      /// </summary>
      public static void Invariant(bool assertion) {
          if (UseExceptions) {
              if (!assertion) throw new InvariantException("Invariant failed.");
          }
          else {
              Trace.Assert(assertion, "Invariant failed.");
          }
      }

      /// <summary>
      /// Assertion check.
      /// </summary>
      public static void Assert(bool assertion, string message) {
          if (UseExceptions) {
              if (!assertion) throw new AssertionException(message);
          }
          else {
              Trace.Assert(assertion, "Assertion: " + message);
          }
      }

      /// <summary>
      /// Assertion check.
      /// </summary>
      public static void Assert(bool assertion, string message, string component)
      {
        if (UseExceptions)
        {
          if (!assertion) throw new AssertionException(message, component);
        }
        else
        {
          Trace.Assert(assertion, "Assertion: " + message);
        }
      }

      /// <summary>
      /// Assertion check.
      /// </summary>
      public static void Assert(bool assertion, string message, System.Exception inner) {
          if (UseExceptions) {
              if (!assertion) throw new AssertionException(message, inner);
          }
          else {
              Trace.Assert(assertion, "Assertion: " + message);
          }
      }

      /// <summary>
      /// Assertion check.
      /// </summary>
      public static void Assert(bool assertion, string message, System.Exception inner, string component)
      {
        if (UseExceptions)
        {
          if (!assertion) throw new AssertionException(message, inner, component);
        }
        else
        {
          Trace.Assert(assertion, "Assertion: " + message);
        }
      }

      /// <summary>
      /// Assertion check.
      /// </summary>
      public static void Assert(bool assertion) {
          if (UseExceptions) {
              if (!assertion) throw new AssertionException("Assertion failed.");
          }
          else {
              Trace.Assert(assertion, "Assertion failed.");
          }
      }


      /// <summary>
      /// Set this if you wish to use Trace Assert statements 
      /// instead of exception handling. 
      /// (The Check class uses exception handling by default.)
      /// </summary>
      public static bool UseAssertions {
          get {
              return useAssertions;
          }
          set {
              useAssertions = value;
          }
      }

      #endregion // Interface

      #region Implementation

      /// <summary>
      /// Is exception handling being used?
      /// </summary>
      private static bool UseExceptions {
          get {
              return !useAssertions;
          }
      }

      // Are trace assertion statements being used? 
      // Default is to use exception handling.
      private static bool useAssertions;

      #endregion // Implementation

  } // End Check
}
