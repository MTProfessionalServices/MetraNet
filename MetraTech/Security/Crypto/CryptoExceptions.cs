using System;
using System.Runtime.InteropServices;

namespace MetraTech.Security.Crypto
{
  /// <summary>
  ///   PasswordStrengthException
  /// </summary>
  [ComVisible(false)]
  public class PasswordStrengthException : Exception
  {
    const string errorMsg = @"The new password does not meet security requirements:       
                              * Must be at least 7 characters and less than 1024 
                              * Must contain at least one lower case letter, one upper case letter, one digit and one special character 
                              * Valid special characters including space are _ !@#$%^&*+= 
                              * Passwords once changed, may not be any of the previous 4 passwords";

    /// <summary>
    ///   PasswordStrengthException
    /// </summary>
    public PasswordStrengthException(): base(errorMsg)
    { 
    }

    /// <summary>
    ///   PasswordStrengthException
    /// </summary>
    /// <param name="auxMessage"></param>
    public PasswordStrengthException(string auxMessage) : base(String.Format("{0} * {1}", errorMsg, auxMessage))
    {
    }

  }
}
