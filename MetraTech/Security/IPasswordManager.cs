using System;
using System.Runtime.InteropServices;
using MetraTech.Interop.MTAuth;

namespace MetraTech.Security
{
  /// <summary>
  /// A common interface for password manager classes.
  /// </summary>
  [Guid("B3B69AE3-FFB2-4ebe-A2FE-EBD0E7956B6E")]
  public interface IPasswordManager
  {
    /// <summary>
    /// Gets a <see cref="Credentials"/> object.
    /// </summary>
    Credentials Credentials
    {
      get;
    }

    /// <summary>
    /// Initialize
    /// </summary>
    /// <param name="credentials"></param>
    void Initialize(Credentials credentials);
    /// <summary>
    /// HashNewPassword
    /// </summary>
    /// <param name="plainTextPassword"></param>
    /// <returns></returns>
    string HashNewPassword(string plainTextPassword);
    /// <summary>
    /// IsPasswordValid
    /// </summary>
    /// <param name="plainTextPassword"></param>
    /// <returns></returns>
    bool IsPasswordValid(string plainTextPassword);
    /// <summary>
    /// DaysUntilPasswordExpires
    /// </summary>
    /// <returns></returns>
    int DaysUntilPasswordExpires();
    /// <summary>
    /// ChangePassword
    /// </summary>
    /// <param name="password"></param>
    /// <param name="newPassword"></param>
    /// <param name="sessionContext"></param>
    /// <returns></returns>
    bool ChangePassword(string password, string newPassword, IMTSessionContext sessionContext);
    /// <summary>
    /// UnlockAccount
    /// </summary>
    /// <param name="sessionContext"></param>
    /// <returns></returns>
    bool UnlockAccount(IMTSessionContext sessionContext);
    /// <summary>
    /// LockAccount
    /// </summary>
    /// <param name="sessionContext"></param>
    /// <returns></returns>
    bool LockAccount(IMTSessionContext sessionContext);
    /// <summary>
    /// CheckPasswordStrength
    /// </summary>
    /// <param name="plainTextPassword"></param>
    /// <returns></returns>
    bool CheckPasswordStrength(string plainTextPassword);
    /// <summary>
    /// SetPasswordExpiryDate
    /// </summary>
    void SetPasswordExpiryDate();
    /// <summary>
    ///   RecordLoginFailure
    /// </summary>
    void RecordLoginFailure();
    /// <summary>
    ///   RecordSuccessfulLogin
    /// </summary>
    void RecordSuccessfulLogin();
    /// <summary>
    ///   CheckIfAccountIsDormant
    /// </summary>
    /// <returns></returns>
    bool CheckIfAccountIsDormant();
    /// <summary>
    ///   IsNewAccount
    /// </summary>
    /// <returns></returns>
    bool IsNewAccount();
    /// <summary>
    ///   GeneratePassword
    /// </summary>
    /// <returns></returns>
    string GeneratePassword();

    /// <summary>
    ///   Update the existing password with the given plain text password.
    /// </summary>
    /// <param name="password"></param>
    /// <param name="sessionContext"></param>
    void UpdatePassword(string password, IMTSessionContext sessionContext);

    /// <summary>
    ///    Email the given password using the email template in RMP\config\emailtemplate\UpdatePasswordEMailNotificationTemplate.xml
    /// </summary>
    /// <param name="emailAddress"></param>
    /// <param name="firstName"></param>
    /// <param name="lastName"></param>
    /// <param name="password"></param>
    /// <param name="updateTime"></param>
    /// <param name="languageCode"></param>
    /// <param name="sessionContext"></param>
    void EmailPasswordUpdate(string emailAddress,
                             string firstName,
                             string lastName,
                             string password,
                             DateTime updateTime,
                             string languageCode,
                             IMTSessionContext sessionContext);
  }
}
