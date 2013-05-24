// AudioConfMeteringTestAppDlg.h : header file
//

#pragma once
#include <afxwin.h>


// CAudioConfMeteringTestAppDlg dialog
class CAudioConfMeteringTestAppDlg : public CDialog
{
// Construction
public:
	CAudioConfMeteringTestAppDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	enum { IDD = IDD_AUDIOCONFMETERINGTESTAPP_DIALOG };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support


// Implementation
protected:
	HICON m_hIcon;

	// Generated message map functions
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	DECLARE_MESSAGE_MAP()
private:
  long mSessionSetSize;
  long mNumberOfCalls;
  long mConnectionsPerCall;
  int mRandomizeConnectionCount;
  long mFeaturesPerCall;
  int mRandomizeFeatures;
  long mNumberOfAccounts;
  int mIncludeNonSubscribers;
  COleDateTime mStartDate;
  COleDateTime mEndDate;
  CButton mExitButton;
  CButton mStartMeteringButton;
  int mLimitAccountRange;
  int mAccountRangeStart;
  int mAccountRangeEnd;
  CEdit mAcctRangeStartEdit;
  CEdit mAcctRangeEndEdit;
  CString mOfferingName;

  static HRESULT  mThreadResult;

private:
  afx_msg void StartMeteringButton_Clicked();
  afx_msg void OnLimitAccountIdRangeClicked();
  static UINT __cdecl OnStartMeteringThread(void* pParam);
};
