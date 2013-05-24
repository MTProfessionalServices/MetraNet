// AudioConfMeteringTestAppDlg.cpp : implementation file
//
#include "StdAfx.h"
#include "AudioConfMeteringTestApp.h"
#include "AudioConfMeteringTestAppDlg.h"

#import "AudioConfMeterTestLib.tlb" no_namespace

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CAboutDlg dialog used for App About

class CAboutDlg : public CDialog
{
public:
	CAboutDlg();

// Dialog Data
	enum { IDD = IDD_ABOUTBOX };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

// Implementation
protected:
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)
{
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
END_MESSAGE_MAP()


// CAudioConfMeteringTestAppDlg dialog


HRESULT  CAudioConfMeteringTestAppDlg::mThreadResult = S_OK;

CAudioConfMeteringTestAppDlg::CAudioConfMeteringTestAppDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CAudioConfMeteringTestAppDlg::IDD, pParent)
  , mSessionSetSize(1000)
  , mNumberOfCalls(0)
  , mConnectionsPerCall(0)
  , mRandomizeConnectionCount(0)
  , mFeaturesPerCall(0)
  , mRandomizeFeatures(0)
  , mNumberOfAccounts(0)
  , mIncludeNonSubscribers(0)
  , mStartDate(COleDateTime::GetCurrentTime())
  , mEndDate(COleDateTime::GetCurrentTime())
  , mLimitAccountRange(0)
  , mAccountRangeStart(0)
  , mAccountRangeEnd(0)
{
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);


}

void CAudioConfMeteringTestAppDlg::DoDataExchange(CDataExchange* pDX)
{
  CDialog::DoDataExchange(pDX);

  DDX_DateTimeCtrl(pDX, IDC_DATETIMEPICKER1, mStartDate);
  DDX_DateTimeCtrl(pDX, IDC_DATETIMEPICKER2, mEndDate);
  DDX_Control(pDX, IDCANCEL, mExitButton);
  DDX_Control(pDX, IDC_BUTTON1, mStartMeteringButton);
  DDX_Check(pDX, IDC_CHECK1, mRandomizeConnectionCount);
  DDX_Check(pDX, IDC_CHECK2, mRandomizeFeatures);
  DDX_Check(pDX, IDC_CHECK3, mIncludeNonSubscribers);
  DDX_Text(pDX, IDC_EDIT1, this->mNumberOfCalls);
  DDX_Text(pDX, IDC_EDIT2, this->mConnectionsPerCall);
  DDX_Text(pDX, IDC_EDIT3, this->mFeaturesPerCall);
  DDX_Text(pDX, IDC_EDIT4, this->mNumberOfAccounts);
  DDX_Text(pDX, IDC_EDIT5, this->mSessionSetSize);
  DDX_Text(pDX, IDC_EDIT8, this->mOfferingName);

  DDV_MinMaxInt(pDX, mNumberOfCalls, 0, 5000000);
  DDV_MinMaxInt(pDX, mConnectionsPerCall, 0, 100);
  DDV_MinMaxInt(pDX, mFeaturesPerCall, 0, 10);
  DDV_MinMaxInt(pDX, mNumberOfAccounts, 0, 5000000);
  DDV_MinMaxInt(pDX, mSessionSetSize, 0, 100000);
  
  mStartDate.SetDateTime(mStartDate.GetYear(), mStartDate.GetMonth(), mStartDate.GetDay(), 0, 0, 0);
  mEndDate.SetDateTime(mEndDate.GetYear(), mEndDate.GetMonth(), mEndDate.GetDay(), 0, 0, 0);

  if(mStartDate.m_dt > mEndDate.m_dt)
  {
    ::MessageBox(this->m_hWnd, L"Please enter start date that is prior to the end date.", L"Warning", MB_OK | MB_ICONEXCLAMATION | MB_APPLMODAL );

    pDX->Fail();
  }

  DDX_Check(pDX, IDC_CHECK4, mLimitAccountRange);
  DDX_Text(pDX,IDC_EDIT6, this->mAccountRangeStart);
  DDX_Text(pDX,IDC_EDIT7, this->mAccountRangeEnd);
  DDX_Control(pDX, IDC_EDIT6, mAcctRangeStartEdit);
  DDX_Control(pDX, IDC_EDIT7, mAcctRangeEndEdit);
}

BEGIN_MESSAGE_MAP(CAudioConfMeteringTestAppDlg, CDialog)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	//}}AFX_MSG_MAP
  ON_BN_CLICKED(IDC_BUTTON1, &CAudioConfMeteringTestAppDlg::StartMeteringButton_Clicked)
  ON_BN_CLICKED(IDC_CHECK4, &CAudioConfMeteringTestAppDlg::OnLimitAccountIdRangeClicked)
END_MESSAGE_MAP()


// CAudioConfMeteringTestAppDlg message handlers

BOOL CAudioConfMeteringTestAppDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Add "About..." menu item to system menu.

	// IDM_ABOUTBOX must be in the system command range.
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		CString strAboutMenu;
		strAboutMenu.LoadString(IDS_ABOUTBOX);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon

  return TRUE;  // return TRUE  unless you set the focus to a control
}

void CAudioConfMeteringTestAppDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialog::OnSysCommand(nID, lParam);
	}
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CAudioConfMeteringTestAppDlg::OnPaint()
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

// The system calls this function to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CAudioConfMeteringTestAppDlg::OnQueryDragIcon()
{
	return static_cast<HCURSOR>(m_hIcon);
}


void CAudioConfMeteringTestAppDlg::StartMeteringButton_Clicked()
{
    if(UpdateData())
    {
      CWinThread *pThread = NULL;

      {
        CWaitCursor curs;
      
        pThread = AfxBeginThread(CAudioConfMeteringTestAppDlg::OnStartMeteringThread,(void *)this);
        pThread->m_bAutoDelete = false;
        
        while(WaitForSingleObject(pThread->m_hThread, 0))
        {
          MSG dispatch;
          while (::PeekMessage( &dispatch, NULL, 0, 0, PM_NOREMOVE))
          {
			if (!AfxGetThread()->PumpMessage())   
            {
                break;
            }

          }

          curs.Restore();
        }
      }

      if( SUCCEEDED(mThreadResult) )
      {
        wchar_t buf[100];

        swprintf(buf, 100, L"GenerateTestData completed successfully.");

        ::MessageBox(m_hWnd, buf, L"SUCCESS", MB_OK | MB_ICONINFORMATION | MB_APPLMODAL );
      }
      else
      {
        wchar_t buf[100];

        swprintf(buf, 100, L"GenerateTestData returned an error.  Error was: 0x%08x", mThreadResult);

        ::MessageBox(m_hWnd, buf, L"Warning", MB_OK | MB_ICONEXCLAMATION | MB_APPLMODAL );
      }
        
      delete pThread;
    }
}

void CAudioConfMeteringTestAppDlg::OnLimitAccountIdRangeClicked()
{
  if( UpdateData(true) )
  {
    if( this->mLimitAccountRange )
    {
      this->mAcctRangeStartEdit.EnableWindow(true);
      this->mAcctRangeEndEdit.EnableWindow(true);
    }
    else
    {
      this->mAcctRangeStartEdit.EnableWindow(false);
      this->mAcctRangeEndEdit.EnableWindow(false);
    }
  }
}


UINT __cdecl CAudioConfMeteringTestAppDlg::OnStartMeteringThread(void * pParam)
{
  HRESULT hr;
  IAudioConfMeterTestCtl *iTest;
  CLSID theCLSID;
  CAudioConfMeteringTestAppDlg *dlg = (CAudioConfMeteringTestAppDlg *)pParam;

  hr = CLSIDFromProgID(L"AudioConfMeterTestLib.AudioConfMeterTes", &theCLSID);

  hr = ::CoCreateInstance(theCLSID, NULL, CLSCTX_SERVER, __uuidof(IAudioConfMeterTestCtl), (void **)&iTest);

  if(SUCCEEDED(hr))
  {
    iTest->SetSessionSetSize(dlg->mSessionSetSize);
    
    iTest->SetCallCount(dlg->mNumberOfCalls);
    
    iTest->SetConnsPerCall(dlg->mConnectionsPerCall,dlg->mRandomizeConnectionCount);
    iTest->SetFeaturesPerCall(dlg->mFeaturesPerCall, dlg->mRandomizeFeatures);
    
    iTest->SetNumberOfAccounts(dlg->mNumberOfAccounts, dlg->mOfferingName.AllocSysString());
    if(dlg->mLimitAccountRange)
    {
      iTest->SetAccountRange(dlg->mAccountRangeStart, dlg->mAccountRangeEnd);
    }
    else
    {
      iTest->ClearAccountRange();
    }

    if(dlg->mIncludeNonSubscribers)
    {
      iTest->IncludeUnsubscribedAccounts();
    }
    else
    {
      iTest->ClearUnsubscribedAccounts();
    }

    BSTR startDt = SysAllocString(dlg->mStartDate.Format());
    BSTR endDt = SysAllocString(dlg->mEndDate.Format());
    iTest->SetCallDateRange(startDt, endDt);

    mThreadResult = iTest->GenerateTestData();

    iTest->Release();
  }
  else
  {
    wchar_t buf[100];

    swprintf(buf, 100, L"Failed to create instance of AudioConfMeterTestCtl.  Error was: 0x%08x", hr);

    ::MessageBox(dlg->m_hWnd, buf, L"Warning", MB_OK | MB_ICONEXCLAMATION | MB_APPLMODAL );
    }
  return 0;
}
