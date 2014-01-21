using System;
using System.Collections.Generic;

[Serializable]
public class RecentAccounts
{
  private List<RecentAccount> mListRecentAccounts = new List<RecentAccount>();
  public List<RecentAccount> ListRecentAccounts
  {
    get { return mListRecentAccounts; }
    set { mListRecentAccounts = value; }
  }

  public void Add(RecentAccount recentAccount)
  {
    // if it already exists in the list then remove it
    RecentAccount removeAcc = null;
    foreach (RecentAccount rc in mListRecentAccounts)
    {
      if (rc.AccountId == recentAccount.AccountId)
      {
        removeAcc = rc;
      }
    }
    if (mListRecentAccounts.Contains(removeAcc))
    {
      mListRecentAccounts.Remove(removeAcc);
    }

    // add new account to top of list
    mListRecentAccounts.Insert(0, recentAccount);

    // if we have more than 10, delete the oldest
    if (mListRecentAccounts.Count > 10)
    {
      mListRecentAccounts.RemoveAt(mListRecentAccounts.Count - 1);
    }

  }
}

[Serializable]
public class RecentAccount
{
  private string mFirstName;
  public string FirstName
  {
    get { return mFirstName; }
    set { mFirstName = value; }
  }

  private string mLastName;
  public string LastName
  {
    get { return mLastName; }
    set { mLastName = value; }
  }

  private string mUsername;
  public string Username
  {
    get { return mUsername; }
    set { mUsername = value; }
  }

  private string mAccountType;
  public string AccountType
  {
    get { return mAccountType; }
    set { mAccountType = value; }
  }

  private string mAccountStatus;
  public string AccountStatus
  {
    get { return mAccountStatus; }
    set { mAccountStatus = value; }
  }

  private bool mIsFolder;
  public bool IsFolder
  {
    get { return mIsFolder; }
    set { mIsFolder = value; }
  }

  private string mAccountId;
  public string AccountId
  {
    get { return mAccountId; }
    set { mAccountId = value; }
  }

  public RecentAccount(string username, string firstName, string lastName, string accountType, string accountStatus,
    bool isFolder, string accountId)
  {
    Username = username;
    FirstName = firstName;
    LastName = lastName;
    AccountType = accountType;
    AccountId = accountId;
    IsFolder = isFolder;
    AccountStatus = accountStatus;
  }
}