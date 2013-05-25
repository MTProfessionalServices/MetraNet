// MetraTimeControl.cpp : Implementation of CMetraTimeControl
#include "StdAfx.h"
#include "MetraTime.h"
#include "MetraTimeControl.h"
#include "metratimeipc.h"
#include <MTUtil.h>

/////////////////////////////////////////////////////////////////////////////
// CMetraTimeControl

STDMETHODIMP CMetraTimeControl::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMetraTimeControl
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMetraTimeControl::FinalConstruct()
{
	if (!mIPC.Init())
		return E_FAIL;

	return CoCreateFreeThreadedMarshaler(
		GetControllingUnknown(), &m_pUnkMarshaler.p);
}

void CMetraTimeControl::FinalRelease()
{
	mIPC.Reset();

	m_pUnkMarshaler.Release();
}


STDMETHODIMP CMetraTimeControl::SetSimulatedTime(long simTime)
{
  // For backward compatibility, we are restricting ourselves to 32-bit interfaces.
  // COM 32BIT TIME_T
	time_t realTime = time(NULL);
	long offset = (long)(simTime - realTime);
	return SetSimulatedTimeOffset(offset);
}

STDMETHODIMP CMetraTimeControl::SetSimulatedOLETime(VARIANT simTime)
{
	time_t realTime = time(NULL);

	// convert the OLE time to seconds in order to calculate the diff
	time_t simTimeTimet;
	TimetFromOleDate(&simTimeTimet, (DATE) _variant_t(simTime));

  // COM 32BIT TIME_T
	long offset = (long)(simTimeTimet - realTime);
	return SetSimulatedTimeOffset(offset);
}

STDMETHODIMP CMetraTimeControl::StopSimulatedTime()
{
	return E_NOTIMPL;
}

STDMETHODIMP CMetraTimeControl::StartSimulatedTime()
{
	return E_NOTIMPL;
}

STDMETHODIMP CMetraTimeControl::SetSimulatedTimeOffset(long offset)
{
	mIPC.GetWriteableData().SetOffset(offset);
	return S_OK;
}

STDMETHODIMP CMetraTimeControl::GetSimulatedTimeOffset(long *offset)
{
	*offset = mIPC.GetReadOnlyData().GetOffset();

	return S_OK;
}
