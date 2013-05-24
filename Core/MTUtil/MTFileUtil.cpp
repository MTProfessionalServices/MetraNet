/**************************************************************************
 * @doc MTUTIL
 *
 * Copyright 1998 by MetraTech Corporation
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
 * $Header: 
 *
 * MT process access Utility function
 ***************************************************************************/

#include <stdio.h>
#include "MTUtil.h"

#define DIR_DELIM '\\'
#define DEV_DELIM ':'

#define MT_TAB							'\t'
#define MT_NEWLINE					'\n'
#define MT_CARRIAGE_RETURN	'\r'
#define MT_SPACE						' '
#define MAX_BUFFER_SIZE			4096

// Check file's existence
BOOL CheckFile(std::string aFilename)
{
	HANDLE		hFile = 0;
	WIN32_FIND_DATAA	fileData;  // for ascii version

	hFile = FindFirstFileA(aFilename.c_str(), &fileData);

	if (hFile == INVALID_HANDLE_VALUE)
	{
		FindClose(hFile);
		return FALSE;
	}

	FindClose(hFile);
	return TRUE;
}

// Parse file name to get the base file name and the directory name attached
void ParseFilename(std::string aSFilename, std::string& aFilePath, std::string& aDFilename)
{
	int index;
	int len;
	int filenameLen;

	len = aSFilename.length();
	index = aSFilename.find_last_of(DIR_DELIM, len - 1);
	if (index == string::npos)
	{
		// when there is no directory attached with file name
		aDFilename = aSFilename;
		return;
	}

	index = index + 1;
	aFilePath = aSFilename.substr(0, index);

	filenameLen = len - index;
	aDFilename = aSFilename.substr(index, filenameLen);
}

// Check the directory's existence
BOOL CheckDirectory(std::string aDirName)
{
	std::string	currentDir;
	HANDLE		hFile = 0;
	WIN32_FIND_DATAA	fileData;  // for ascii version

	currentDir = aDirName;

	RemoveDirSuffix(currentDir);

	hFile = FindFirstFileA(currentDir.c_str(), &fileData);

	if (hFile == INVALID_HANDLE_VALUE)
	{
		FindClose(hFile);
		return FALSE;
	}
	else
	{
		FindClose(hFile);
		if (!IsDirectory(currentDir))
		{
			return FALSE;
		}
	}

	return TRUE;
}

// add trailing "\" if needed
void PathNameSuffix(std::string & aPath)
{
	if (aPath.length() != 0)
	{
		if (aPath[aPath.length()-1] != '\\')
		{
			aPath = aPath + "\\";
		}
	}
}

// check if this is a file
BOOL IsFile(std::string aFilename)
{
  DWORD   dwAttrib;

	dwAttrib = GetFileAttributesA(aFilename.c_str());
	if ((dwAttrib == 0xFFFFFFFF) || (dwAttrib & FILE_ATTRIBUTE_DIRECTORY))
	{
		return FALSE;
	}

	return TRUE;
}


// check if this is a directory
BOOL IsDirectory(std::string aFilename)
{
  DWORD   dwAttrib;

	dwAttrib = GetFileAttributesA(aFilename.c_str());
	if ((dwAttrib == 0xFFFFFFFF) || !(dwAttrib & FILE_ATTRIBUTE_DIRECTORY))
	{
		return FALSE;
	}

	return TRUE;
}

void RemoveDirSuffix(std::string& aDirName)
{
	int dirNameLen;
	int index;

	dirNameLen = aDirName.length();
	index = aDirName.find_last_of(DIR_DELIM, dirNameLen-1);

	if ((index + 1) == dirNameLen)
	{
		aDirName.erase(index);
	}

}

void FormatFileName(std::string& aFileName)
{
	std::string fn;
	int	length;

	fn = aFileName;
	length = fn.length();

	//int id = fn.index("\\", 0, RWCString::exact);
	const char *id = strstr(fn.c_str(), "\\");
	if (id == NULL)
	{
		aFileName = fn[1, length-1];
	}
}

/////////////////////////////////////////////////////////////////////////////////
// scanne through a string to replace TAB with SPACE
BOOL StringFormat(std::string aInputString, std::string& aOutputString)
{
	int		len;
	int		i, j, k;
	int		offset;
	const char* inputChar;
	char	buffer[MAX_BUFFER_SIZE];

	len = aInputString.length();
	if (len == 0)
	{
		return FALSE;
	}

	offset = 0;
	k = 0;

	memset(buffer, 0, sizeof(buffer));

	inputChar = aInputString.c_str();

	while(offset < len)
	{
		for (i = offset; i < len; i++)
		{
			if (inputChar[i] != MT_TAB && 
					inputChar[i] != MT_SPACE &&
					inputChar[i] != MT_CARRIAGE_RETURN && 
					inputChar[i] != MT_NEWLINE)
			{
				break;
			}
		}

		for (j = i; j < len; j++)
		{
			if (inputChar[j] == MT_CARRIAGE_RETURN || 
					inputChar[j] == MT_NEWLINE)
			{
				break;
			}

			buffer[k++] = inputChar[j];
		}

		if (j < len)
		{
			buffer[k++] = MT_SPACE;
		}

		offset = j;
	}

	len = strlen(buffer) - 1;
	for (i = len; i >= 0; i--)
	{
		if (buffer[i] != MT_TAB && 
				buffer[i] != MT_SPACE &&
				buffer[i] != MT_CARRIAGE_RETURN && 
				buffer[i] != MT_NEWLINE)
		{
			buffer[i + 1] = '\0';
			break;
		}
	}

	aOutputString = buffer;

	return TRUE;
}
