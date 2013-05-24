/**************************************************************************
 * @doc INFINITE
 *
 * Copyright 1999 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>

#include <infinite.h>

#if 0

INT PageFaultExceptionFilter(DWORD dwCode)
{
  LPVOID lpvResult;

  // If the exception is not a page fault, exit.

  if (dwCode != EXCEPTION_ACCESS_VIOLATION)
    {
      printf("Exception code = %d\n", dwCode);
      return EXCEPTION_EXECUTE_HANDLER;
    }

  printf("Exception is a page fault\n");

  // If the reserved pages are used up, exit.

  if (dwPages >= PAGELIMIT)
    {
      printf("Exception: out of pages\n");
      return EXCEPTION_EXECUTE_HANDLER;
    }

  // Otherwise, commit another page.

  lpvResult = VirtualAlloc(
                           (LPVOID) lpNxtPage, // next page to commit
                           dwPageSize,         // page size, in bytes
                           MEM_COMMIT,         // allocate a committed page
                           PAGE_READWRITE);    // read/write access
  if (lpvResult == NULL )
    {
      printf("VirtualAlloc failed\n");
      return EXCEPTION_EXECUTE_HANDLER;
    } else {
      printf ("Allocating another page.\n");
    }

  // Increment the page count, and advance lpNxtPage to the next page.

  dwPages++;
  lpNxtPage += dwPageSize;

  // Continue execution where the page fault occurred.

  return EXCEPTION_CONTINUE_EXECUTION;
}

VOID ErrorExit(LPTSTR oops)
{
  printf ("Error! %s with error code of %ld\n",
          oops, GetLastError ());
  exit (0);
}

#endif

int InfiniteBuffer::mPageSize = 0;

InfiniteBuffer::InfiniteBuffer()
	: mpNextPage(NULL), mpBase(NULL), mMaxPages(0), mPages(0)
{ }

InfiniteBuffer::~InfiniteBuffer()
{
	Clear();
}

int InfiniteBuffer::GetPageSize()
{
	if (mPageSize == 0)
	{
		SYSTEM_INFO sysInfo;
		GetSystemInfo(&sysInfo);		// populate the system information structure

		mPageSize = sysInfo.dwPageSize;
	}

	return mPageSize;
}

void InfiniteBuffer::AddPage()
{
	mPages++;
	mpNextPage += GetPageSize();
}

#include <stdio.h>
int InfiniteBuffer::PageFaultExceptionFilter(InfiniteBuffer * apBuffer, DWORD dwCode)
{
	printf("fault exception\n");
	if (dwCode != EXCEPTION_GUARD_PAGE)
		// not something we recognize
		return EXCEPTION_CONTINUE_SEARCH;

	// guard page was hit - extend the buffer size

  // If the reserved pages are used up, we're in trouble.
	// I guess the buffer isn't really infinite after all.

  if (apBuffer->GetCurrentPages() >= apBuffer->GetMaxPages())
		// the handler will have to take care of it
		return EXCEPTION_EXECUTE_HANDLER;

  // Otherwise, commit another page.
	void * result = ::VirtualAlloc(
		apBuffer->GetNextPage(),		// next page to commit
		apBuffer->GetPageSize(),		// page size, in bytes
		MEM_COMMIT,									// allocate a committed page
		PAGE_READWRITE);						// read/write access

	if (result == NULL)
	{
		// virtualalloc failed
		// the handler will have to take care of it
		return EXCEPTION_EXECUTE_HANDLER;
	}

  // Increment the page count, and advance lpNxtPage to the next page.
	apBuffer->AddPage();

	// continue executing where the fault occurred
	return EXCEPTION_CONTINUE_EXECUTION;
}



BOOL InfiniteBuffer::Setup(int aInitialPages, int aMaxPages /* = 2560 */)
{
	// reserve the total number of pages as guard pages
	mpNextPage = mpBase =
		(unsigned char *) ::VirtualAlloc(NULL,	// system selects address
																		 aMaxPages * GetPageSize(), // size of allocation
																		 MEM_RESERVE, // allocate reserved pages
																		 // protection = read only guard page
																		 PAGE_READONLY | PAGE_GUARD);

	if (!mpNextPage)
		return FALSE;

	if (aInitialPages > 0)
	{
		// commit the initial number of pages
		void * result = ::VirtualAlloc(
			mpNextPage,									// next page to commit
			aInitialPages * GetPageSize(), // page size, in bytes
			MEM_COMMIT,									// allocate a committed page
			PAGE_READWRITE);						// read/write access

		if (!result)
			return FALSE;
	}

	mPages = aInitialPages;
	mpNextPage += mPages * GetPageSize();

	mMaxPages = aMaxPages;

	return TRUE;
}

BOOL InfiniteBuffer::Clear()
{
  // First, decommit the committed pages.
  BOOL success = ::VirtualFree(
		GetBase(),									// base address of block
		mPages * GetPageSize(),			// bytes of committed pages
		MEM_DECOMMIT);							// decommit the pages

  // Release the entire block.
  if (success)
	{
		success = VirtualFree(
			GetBase(),        // base address of block
			0,              // release the entire block
			MEM_RELEASE);   // release the pages
	}


	mpNextPage = mpBase = NULL;
	mPages = mMaxPages = 0;
	return success;
}

#if 0
VOID main(VOID)
{
  LPVOID lpvBase;               // base address of our test memory
  LPTSTR lpPtr;                 // generic character pointer
  BOOL bSuccess;                // flag
  DWORD i;                      // generic counter
  SYSTEM_INFO sSysInfo;         // useful information about the system

  GetSystemInfo(&sSysInfo);     // populate the system information structure

  printf ("This computer has a page size of %d.\n", sSysInfo.dwPageSize);

  dwPageSize = sSysInfo.dwPageSize;

  // Reserve pages in the process's virtual address space.

  lpvBase = VirtualAlloc(
                         NULL,                 // system selects address
                         PAGELIMIT*dwPageSize, // size of allocation
                         MEM_RESERVE,          // allocate reserved pages
                         PAGE_NOACCESS);       // protection = no access
  if (lpvBase == NULL )
    ErrorExit("VirtualAlloc reserve failed");

  lpPtr = lpNxtPage = (LPTSTR) lpvBase;

  // Use try-except structured exception handling when accessing the
  // pages. If a page fault occurs, the exception filter is executed to
  // commit another page from the reserved block of pages.

  for (i=0; i < PAGELIMIT*dwPageSize; i++)
    {
      __try
        {
          // Write to memory.

          lpPtr[i] = 'a';
        }

      // If there's a page fault, commit another page and try again.

      __except ( PageFaultExceptionFilter( GetExceptionCode() ) )
        {

          // This is executed only if the filter function is unsuccessful
          // in committing the next page.

          ExitProcess( GetLastError() );

        }

    }

  // Release the block of pages when you are finished using them.

  // First, decommit the committed pages.

  bSuccess = VirtualFree(
                         lpvBase,            // base address of block
                         dwPages*dwPageSize, // bytes of committed pages
                         MEM_DECOMMIT);      // decommit the pages

  // Release the entire block.

  if (bSuccess)
    {
      bSuccess = VirtualFree(
                             lpvBase,        // base address of block
                             0,              // release the entire block
                             MEM_RELEASE);   // release the pages
    }
}

#endif

