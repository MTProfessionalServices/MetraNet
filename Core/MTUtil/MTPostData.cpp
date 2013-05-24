/**************************************************************************
 * @doc MTUTIL
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
 * Created by: Chen He
 *
 * $Header$
 *
 * MT data posting Utility function
 ***************************************************************************/

#include <io.h>
#include <fcntl.h>
#include "MTUtil.h"
#include "win32net.h"
#include <string>
using std::string;

HRESULT MTPostData(string aHostName, string aRelativePath,
								string aFilename, 
								string aUsername, string aPassword,
								BOOL aSecure)
{
	Win32NetStream netstream;
	if (!netstream.Init())
	{
		const ErrorObject * err = netstream.GetLastError();
		return err->GetCode();
	}

	// compose file part of URL
	string url("/admin/nph-uploadconfig.exe?relativepath=");

	// TODO: do we have to escape the characters in the path?
	url += aRelativePath;

	char buffer[4096];

	int	fh;
	long length;

	// Get file size
	if ((fh = _open(aFilename.c_str(), _O_RDONLY | _O_BINARY)) == -1)
	{
		return E_FAIL;
	}

	length = _filelength(fh);

	char header[256];
	wsprintfA(header, "Content-Type: x-metratech/binary-file\n"
						"Content-Length: %d\n", length);

	// open the connection
 	NetStreamConnection * conn = NULL;
	if (aSecure)
	{
		conn = netstream.OpenSslHttpConnection("POST", aHostName.c_str(), url.c_str(),
																					 FALSE, aUsername.c_str(), aPassword.c_str(), header);
	}
	else
	{
		conn = netstream.OpenHttpConnection("POST", aHostName.c_str(), url.c_str(),
																				FALSE, aUsername.c_str(), aPassword.c_str(), header);
	}

	if (!conn)
	{
		_close(fh);
		const ErrorObject * err = netstream.GetLastError();
		return HRESULT_FROM_WIN32(err->GetCode());
	}

	BOOL done = FALSE;
	int nread;
	while(!_eof( fh ))
	{
    nread = _read(fh, buffer, sizeof(buffer));
		if (nread == 0)
		{
			break;
		}
		else
		{
			if (nread < 0)
			{
				_close(fh);
				return E_FAIL;
			}

			if (!conn->SendBytes(buffer, nread))
			{
				const ErrorObject * err = conn->GetLastError();
				HRESULT code = HRESULT_FROM_WIN32(err->GetCode());
				delete conn;
				_close(fh);
				return code;
			}

			if (nread < sizeof(buffer))
			{
				break;
			}
	
		}  // if (nread < 0) else

	}  // while(!done)

	_close(fh);
	
	if (!conn->EndRequest())
	{
		const ErrorObject * err = conn->GetLastError();
		return err->GetCode();
	}

	HttpResponse response = conn->GetResponse();
	if (response != 200)
	{
		delete conn;
		return E_FAIL;
	}

	// read an ignore the response from the server
	nread = 0;
	do
	{
		if (!conn->ReceiveBytes(buffer, sizeof(buffer), &nread))
		{
			const ErrorObject * err = conn->GetLastError();
			HRESULT code = HRESULT_FROM_WIN32(err->GetCode());
			delete conn;
			return code;
		}
    if (nread < sizeof(buffer))
      break;
	} while (nread > 0);

	delete conn;

	return S_OK;
}
