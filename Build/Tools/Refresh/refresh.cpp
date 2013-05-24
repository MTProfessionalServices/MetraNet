/*****************************************************************************************
*
*	Author: Kevin Fitzgerald      
*
*	Description: This file contains the source code for the refresh tool.
*
*	Copyright (c) 1998, MetraTech Corporation All rights reserved.
*****************************************************************************************/

#include "refresh.h"

using namespace std;

void usage (int argc, char *argv[])
{
    std::string progname(argv[0]);

    if (progname.find_last_of('\\') != string::npos)
        progname = progname.substr(progname.find_last_of('\\') + 1, string::npos);
    progname = progname.substr(0, progname.find_last_of('.'));

	cerr << "usage: " << progname << " [/v] [/f | /i] <Release|Debug|all> \\\n"
            "       <Source Dir> <Destination Dir> " << endl;
    cerr << "Flags:" << endl;
    cerr << "        /v      to print progress information (verbose mode)." << endl;
    cerr << "        /f      to cause writeable files (presumably compiled locally)\n"
            "                to be overwritten (force mode)." << endl;
    cerr << "        /i      to be asked whether or not to overwrite writable files\n"
            "                (interactive mode)." << endl;
    cerr << "The next parameter determines whether Release, Debug, or both\n"
            "types of files are copied. The next two parameters specify the\n"
            "source and destination directories, obviously." << endl ;
    cerr << endl;

	cerr << "Typed: " << progname << " ";

	std::ostream_iterator<char *> argv_out (cerr, " ");
	std::copy (argv + 1, argv + argc, argv_out);

	cerr << endl;
}

static void MakeLower (TCHAR *s)
{
	for (; *s != NULL; s = _tcsinc(s))
	{
		if (_istupper (*s))
			*s = _totlower (*s);
	}
}

static void MakeLower (std::string &s)
{
	for (size_t i = 0; i < s.length(); i++)
	{
		TCHAR	tmp = s[i];

		if (_istupper (tmp))
		{
			s[i] = _totlower(tmp);
		}
	}

}

//
// CheckDirectoriesExistance
//
BOOL CheckDirectoriesExistance (std::string &dir, BOOL can_be_read_only)
{
	DWORD attrib = GetFileAttributes (dir.c_str());
		
	BOOL is_read_only = (attrib & FILE_ATTRIBUTE_READONLY) != 0;

	return ((attrib != 0xFFFFFFFF) && (attrib & FILE_ATTRIBUTE_DIRECTORY));
}

//
// Name:: CheckSourcePath
// Description:: This routine check to make sure the source directory and the associated 
//    subdirs exist. Depending on the compile_type, it will check to make sure the Debug, Release
//    and Import subdirs exist with their appropriate subdirs.
//
bool CheckSourcePath (std::string &src_path, std::string &compile_type)
{
  // check for the source directory's existance ...
  if (!(CheckDirectoriesExistance (src_path, TRUE)))
  {
    return false ;
  }
  // check for the <src_path>\Include and <src_path>\Import\Include dir's existance ...
  if (!CheckDirectoriesExistance (src_path + "\\Include", TRUE))
  {
    return false ;
  }
  if (!CheckDirectoriesExistance (src_path + "\\Import\\Include", TRUE))
  {
    return false ;
  }

  // if we are getting the debug tree or all ... check for the <src_path>\Debug\Bin, 
  // <src_path>\Debug\Lib, <src_path>\Import\Debug\Bin, and <src_path>\Import\Debug\Lib
  // directories existance ...
  if ((compile_type == "debug") || (compile_type == "all"))
  {
    if (!CheckDirectoriesExistance (src_path + "\\Debug\\Bin", TRUE))
    {
      return false ;
    }
    if (!CheckDirectoriesExistance (src_path + "\\Debug\\Lib", TRUE))
    {
      return false ;
    }
    if (!CheckDirectoriesExistance (src_path + "\\Import\\Debug\\Bin", TRUE))
    {
      return false ;
    }
    if (!CheckDirectoriesExistance (src_path + "\\Import\\Debug\\Lib", TRUE))
    {
      return false ;
    }
  }
  // if we are getting the release tree or all ... check for the <src_path>\Release\Bin, 
  // <src_path>\Release\Lib, <src_path>\Import\Release\Bin, and <src_path>\Import\Release\Lib
  // directories existance ...
  if ((compile_type == "release") || (compile_type == "all"))
  {
    if (!CheckDirectoriesExistance (src_path + "\\Release\\Bin", TRUE))
    {
      return false ;
    }
    if (!CheckDirectoriesExistance (src_path + "\\Release\\Lib", TRUE))
    {
      return false ;
    }
    if (!CheckDirectoriesExistance (src_path + "\\Import\\Release\\Bin", TRUE))
    {
      return false ;
    }
    if (!CheckDirectoriesExistance (src_path + "\\Import\\Release\\Lib", TRUE))
    {
      return false ;
    }
  }
  // directories exists ... 
  cout << "Using source directory of " << src_path << endl ;

  return true ;
}

//
// Name:: CheckDestinationPath
// Description:: This routine check to make sure the destination directory exists and is writable.
//
bool CheckDestinationPath (std::string &dest_path)
{
  // check for the destination directory's existance ...
  if (!CheckDirectoriesExistance (dest_path, TRUE))
  {
    return false ;
  }
  // directory exists ... 
  cout << "Using destination directory of " << dest_path << endl ;

  return true ;
}

#define NOFORCE  0
#define FORCE    1
#define ASKFORCE 2
//
// determine if file should be overwritten or not
//
//
BOOL CheckForce(BYTE &force_mode, const std::string &fileInQuest)
{
    BOOL retVal = FALSE;

    switch (force_mode)
    {
    case NOFORCE:
        retVal = FALSE;
        break;
       
    case FORCE:
        retVal = TRUE;
        break;

    case ASKFORCE:
        cout << endl << "\"" << fileInQuest.c_str() << "\" is writable... replace?" << endl;

        BOOL ok=FALSE;
        char answer;

        while (!ok)
        {
            cout << "[y/n/Y/N]:" << flush;
            cin >> answer;
            cin.ignore(500, '\n');
            switch (answer)
            {
            case 'Y':
                force_mode = FORCE;
            case 'y':
                retVal = TRUE;
                ok = TRUE;
                break;

            case 'N':
                force_mode = NOFORCE;
            case 'n':
                retVal = FALSE;
                ok = TRUE;
                break;

            default:
                cerr << "Invalid response enter:" << endl;
                cerr << "   y - yes" << endl;
                cerr << "   n - no"  << endl;
                cerr << "   Y - yes to all" << endl;
                cerr << "   N - no to all" << endl;
                break;
            }
        }
    }

    return retVal;
}


bool CopyThis (const std::string &src_dir, const std::string &destination,
				const std::string &filename, BYTE &force_mode, bool verbose_mode)
{
  const std::string	filepath (src_dir + "\\" + filename);
  const std::string dest_path (destination + "\\" + filename);
  
  DWORD file_attributes = GetFileAttributes (filepath.c_str());
  
  if (file_attributes != 0xFFFFFFFF && (file_attributes & FILE_ATTRIBUTE_DIRECTORY) == 0)
  {
    // Check for pre-existing file.  Only copy over if
    // 1) Destination is readonly (means not made locally) and not in force mode
    // 2) And you can set the parameter to read-write
    //
    // Remember to set the copied file to Read-Only as an indication next time
    //
    const DWORD dest_attributes = GetFileAttributes (dest_path.c_str());
    
    const BOOL dest_file_exists = (dest_attributes != 0xFFFFFFFF);
    
    // Check for identical files
    //
    BOOL files_the_same = FALSE;
    if (dest_file_exists)
    {
      HANDLE	file1_h = CreateFile (filepath.c_str(), 0, FILE_SHARE_READ,
        NULL, OPEN_EXISTING, 0, NULL);
      
      HANDLE	file2_h = CreateFile (dest_path.c_str(), 0, FILE_SHARE_READ,
        NULL, OPEN_EXISTING, 0, NULL);  
      
      if (file1_h != INVALID_HANDLE_VALUE && file2_h != INVALID_HANDLE_VALUE)
      {
        BY_HANDLE_FILE_INFORMATION	file1_info, file2_info;
        BOOL got_file1_info =
          GetFileInformationByHandle (file1_h, &file1_info);
        BOOL got_file2_info =
          GetFileInformationByHandle (file2_h, &file2_info);
        
        if (got_file1_info && got_file2_info)
        {
          WORD file1_date;        // Compare times in DOS format/granularity
          WORD file1_time;        //   so compares between FAT/NTFS files work,
          WORD file2_date;        //   even if the FAT filesystem is Win95.
          WORD file2_time;
          FileTimeToDosDateTime(&file1_info.ftLastWriteTime, &file1_date, &file1_time);
          FileTimeToDosDateTime(&file2_info.ftLastWriteTime, &file2_date, &file2_time);
          
          int time_match = (file1_date == file2_date) && (abs(file1_time - file2_time) <= 2);
          if (time_match &&
            (file1_info.nFileSizeHigh == file2_info.nFileSizeHigh) &&
            (file1_info.nFileSizeLow == file2_info.nFileSizeLow))
          {
            files_the_same = TRUE;
          }
        }
      }
      
      CloseHandle (file1_h);
      CloseHandle (file2_h);
      
      
      if (files_the_same)
      {
        if (verbose_mode)
        {
          cout << "Skipping identical file " << dest_path.c_str() << endl;
        }
        return true;	// success of a kind
      }
      
      if ((dest_attributes & FILE_ATTRIBUTE_READONLY) == 0 && !CheckForce(force_mode, dest_path))
      {
        cout << "Skipping writable file " << dest_path.c_str() << endl;
        return false;
      }
      
      if (dest_file_exists && !SetFileAttributes (dest_path.c_str(), FILE_ATTRIBUTE_NORMAL))
      {
        cerr << "Error: CANNOT CHANGE ATTRIBUTES ON FILE" << dest_path.c_str() << endl;
        return false;
      }
    }
    
    // We've decided to copy the file.
    
    BOOL copied = CopyFile (filepath.c_str(), dest_path.c_str(), FALSE);
    const DWORD copy_error = GetLastError();
    
    if (!copied && copy_error == ERROR_PATH_NOT_FOUND)
    {
      // Build a path
      //
      const bool made_dir = (CreateDirectory (destination.c_str(), NULL) != FALSE);
      const DWORD made_dir_error = GetLastError();
      
      if (made_dir)
      {
        cout << "Created destination path: " << destination.c_str() << endl;
        
        copied = CopyFile (filepath.c_str(), dest_path.c_str(), FALSE);
      }
      else
      {
        cerr << "Error: FAILED creating destination path: " << destination.c_str() << endl;
      }
    }
    
    if (copied)
    {
      if (verbose_mode)
      {
        if (dest_file_exists)
        {
          cout << "Replaced " << filename.c_str() << endl;
        }
        else
        {
          cout << "Copied   " << filename.c_str() << endl;
        }
      }
      
      const bool reset = 
        (SetFileAttributes (dest_path.c_str(), FILE_ATTRIBUTE_ARCHIVE|FILE_ATTRIBUTE_READONLY)
        != FALSE);
      
      
      if (!reset)
      {
        cerr << "Error: FAILED to set " << filename.c_str() << " to Read-Only" << endl;
      }
      
      return reset;
    }
    else
    {
      cerr << "Error: FAILED to Copy " << filename.c_str() << endl;
      const BOOL reset = SetFileAttributes (dest_path.c_str(), dest_attributes);
      
      
      if (!reset)
      {
        cerr << "Error: FAILED to set " << filename.c_str() << " to Read-Only" << endl;
      }
    }
    }
    
    else
    {
      cerr << "Error: CAN'T LOCATE file to copy " << filepath.c_str() << endl;
    }
    
    // Fall through means failure
    //
    return FALSE;
}

DWORD CreatePath(std::string& path)
{
  if (GetFileAttributes (path.c_str()) != 0xFFFFFFFF)
    return NO_ERROR;
  
  // A null path is invalid.
  if (path.length() == 0)
    return ERROR_INVALID_PARAMETER;
  
/*  // Check and adjust start of search for UNCs.
  int pos = 0;
  if (path.length() >= 2 && path[0] == '\\' && path[1] == '\\')
  {
    pos = path.find_first_of("\\", 2);
    if (pos == string::npos)
      return ERROR_INVALID_PARAMETER;          // Invalid UNC.
  }*/
  
  // Walk the path, making directories as needed.
  int pos=0;
  while ((pos = path.find_first_of("\\", pos + 1)) != string::npos)
  {
    std::string dir(path.substr(0, pos));
    
    if (GetFileAttributes (dir.c_str()) == 0xFFFFFFFF)
    {
      if (CreateDirectory (dir.c_str(), NULL))
        cout << "Created " << dir << endl;
      else
      {
        DWORD retval = GetLastError();
        cerr << "Error: FAILED to create " << dir << endl;
        return retval;
      }
    }
  }
  
  return NO_ERROR;
}

DWORD CopyDirectory (std::string src_dir, std::string dest_dir, DWORD &nTotalFiles, 
                     DWORD &nTotalCopied, const bool verbose_mode, BYTE  &force_mode)
{
  // local variables ...
  _TCHAR DirPath[MAX_PATH] ;
  WIN32_FIND_DATA nFindData ;
  BOOL bRetCode=TRUE ;
  bool bCopiedFile=TRUE ;
  HANDLE hFile=INVALID_HANDLE_VALUE;
  DWORD nError=NO_ERROR ;

  // start walking the source directory tree and copy each file to the destination
  // directory ...
  _tcscpy (DirPath, src_dir.c_str()) ;
  _tcscat (DirPath, "\\*.*") ;
  hFile = FindFirstFile (DirPath, &nFindData) ;
  while (hFile != INVALID_HANDLE_VALUE)
  {
    // if the file we found was not "." or ".." ... copy it ...
    if (nFindData.cFileName[0] != '.')
    {
      // increment the number of total files ...
      nTotalFiles++ ;

      // copy the file from the source to the destination ...
      std::string	filename (nFindData.cFileName);
      bCopiedFile = CopyThis (src_dir, dest_dir, filename, force_mode, verbose_mode) ;
      if (bCopiedFile)
      {
        nTotalCopied++ ;
      }
    }
    bRetCode = FindNextFile (hFile, &nFindData) ;
    // if there was an error ... close the handle and exit while ...
    if (bRetCode == 0)
    {
      FindClose (hFile) ;
      hFile = INVALID_HANDLE_VALUE ;
    }
  }
  nError = GetLastError() ;
  if (nError == ERROR_NO_MORE_FILES)
  {
    nError = NO_ERROR ;
  }
  return nError ;
}

DWORD CopyFilesFromSrcToDest (const bool verbose_mode,
                              BYTE  &force_mode,
                              const std::string &compile_type, 
                              const std::string &src_dir, 
                              const std::string &dest_dir)
{
  // create the destination directories ... if needed ...
	DWORD nError = CreatePath(dest_dir + "\\Include");
		
	if ((nError == NO_ERROR) && (compile_type == "all" || compile_type == "debug"))
	{ 
		nError = CreatePath(dest_dir + "\\Debug\\Bin\\");

		if (nError == NO_ERROR)
		{
			nError = CreatePath(dest_dir + "\\Debug\\Lib\\");
		}
    if (nError == NO_ERROR)
		{
			nError = CreatePath(dest_dir + "\\Import\\Include\\");
		}
    if (nError == NO_ERROR)
		{
			nError = CreatePath(dest_dir + "\\Import\\Debug\\Bin\\");
		}
    if (nError == NO_ERROR)
		{
			nError = CreatePath(dest_dir + "\\Import\\Debug\\Lib\\");
		}
	}

	if ((nError == NO_ERROR) && (compile_type == "all" || compile_type == "release"))
	{ 
		nError = CreatePath(dest_dir + "\\Release\\Bin\\");

		if (nError == NO_ERROR)
		{
			nError = CreatePath(dest_dir + "\\Release\\Lib\\");
		}
    if (nError == NO_ERROR)
		{
			nError = CreatePath(dest_dir + "\\Import\\Include\\");
		}
    if (nError == NO_ERROR)
		{
			nError = CreatePath(dest_dir + "\\Import\\Release\\Bin\\");
		}
    if (nError == NO_ERROR)
		{
			nError = CreatePath(dest_dir + "\\Import\\Release\\Lib\\");
		}
	}

	if (nError != NO_ERROR)
	{
		return nError;
	}

  // copy the appropriate source directories to the destination directories ...
	//
  DWORD nTotalFiles=0 ;
	DWORD nTotalCopied=0 ;
  nError = CopyDirectory (src_dir + "\\Include", dest_dir + "\\Include", nTotalFiles, 
    nTotalCopied, verbose_mode, force_mode) ;
  if (nError == NO_ERROR)
  {
    nError = CopyDirectory (src_dir + "\\Import\\Include", dest_dir + "\\Import\\Include", nTotalFiles, 
      nTotalCopied, verbose_mode, force_mode) ;
  }
  
  if ((nError == NO_ERROR) && (compile_type == "all" || compile_type == "debug"))
  {
    nError = CopyDirectory (src_dir + "\\Debug\\Bin", dest_dir + "\\Debug\\Bin", nTotalFiles, 
      nTotalCopied, verbose_mode, force_mode) ;
    if (nError == NO_ERROR)
    {
      nError = CopyDirectory (src_dir + "\\Debug\\Lib", dest_dir + "\\Debug\\Lib", nTotalFiles, 
        nTotalCopied, verbose_mode, force_mode) ;
    }
    if (nError == NO_ERROR)
    {
      nError = CopyDirectory (src_dir + "\\Import\\Debug\\Bin", dest_dir + "\\Import\\Debug\\Bin", 
        nTotalFiles, nTotalCopied, verbose_mode, force_mode) ;
    }
    if (nError == NO_ERROR)
    {
      nError = CopyDirectory (src_dir + "\\Import\\Debug\\Lib", dest_dir + "\\Import\\Debug\\Lib",
        nTotalFiles, nTotalCopied, verbose_mode, force_mode) ;
    }
  }
  if ((nError == NO_ERROR) && (compile_type == "all" || compile_type == "release"))
  {
    nError = CopyDirectory (src_dir + "\\Release\\Bin", dest_dir + "\\Release\\Bin", nTotalFiles, 
      nTotalCopied, verbose_mode, force_mode) ;
    if (nError == NO_ERROR)
    {
      nError = CopyDirectory (src_dir + "\\Release\\Lib", dest_dir + "\\Release\\Lib", nTotalFiles, 
        nTotalCopied, verbose_mode, force_mode) ;
    }
    if (nError == NO_ERROR)
    {
      nError = CopyDirectory (src_dir + "\\Import\\Release\\Bin", dest_dir + "\\Import\\Release\\Bin", 
        nTotalFiles, nTotalCopied, verbose_mode, force_mode) ;
    }
    if (nError == NO_ERROR)
    {
      nError = CopyDirectory (src_dir + "\\Import\\Release\\Lib", dest_dir + "\\Import\\Release\\Lib",
        nTotalFiles, nTotalCopied, verbose_mode, force_mode) ;
    }
  }

  if (nError != NO_ERROR)
  {
    return nError ;
  }

	cout << endl << "***** Copied/Identical: " << nTotalCopied << "  NOT Copied: " << 
    (nTotalFiles - nTotalCopied) << " *****" << endl;

	return ERROR_SUCCESS;
}



int main (int argc, char *argv[])
{
  bool	verbose_mode = false;
  BYTE    force_mode = NOFORCE;
  int		arg_offset = 0;
  
  // Translate all arguments to lower case for comparisons
  //
  for (int i = 1; i < argc; i++)
  {
    MakeLower (argv[i]);
  }
  
  // Make sure they entered any arguments at all
  if (argc < 2)
  {
    cerr << "Error: Illegal parameters\n";
    usage (argc, argv);
    return -1;
  }
  
  // check optional arguments
  std::string argn;
  BOOL fspec = FALSE;
  BOOL ispec = FALSE;
  for (int x=1; x < argc; x++)
  {
    argn = std::string(argv[x]);
    
    if ((argn == "/v") || (argn == "-v"))
    {
		    verbose_mode = TRUE;
        arg_offset++;
    }
    else if ((argn == "/f") || (argn == "-f"))
    {
      force_mode = FORCE;
      arg_offset++;
      fspec = TRUE;
    }
    else if ((argn == "/i") || (argn == "-i"))
    {
      force_mode = ASKFORCE;
      arg_offset++;
      ispec = TRUE;
    }
  }
  
  if (ispec && fspec)
  {
    cerr << "Error: Use of mutually exclusive paramters /f and /i" << endl;
    return -1;
  }
  
  // Check argument count (sans /v)
  //
  if ((argc - arg_offset) < 4)
  {
    usage (argc, argv);
    return -1;
  }
  
  // Get handy handles to the arg list
  //
  const char	*const raw_compile_type = argv[arg_offset + 1];
  const char	*const raw_src_dir      = argv[arg_offset + 2];
  const char	*const raw_dest_dir     = argv[arg_offset + 3];
  
  std::string	compile_type (raw_compile_type);
  std::string	src_dir      (raw_src_dir);
  std::string	dest_dir     (raw_dest_dir);
  BOOL bRetCode=TRUE ;
  
  cout << endl << "Refresh of " << dest_dir.c_str() << endl;
  
  // check to make sure that the source directory exists and has the appropriate subdirs ...
  bRetCode = CheckSourcePath(src_dir, compile_type) ;
  if (bRetCode == FALSE)
  {
    return ERROR_PATH_NOT_FOUND;
  }
  // check to make sure that the destination directory exists ...
  bRetCode = CheckDestinationPath(dest_dir) ;
  if (bRetCode == FALSE)
  {
    return ERROR_PATH_NOT_FOUND;
  }
  
	DWORD result = CopyFilesFromSrcToDest (verbose_mode, force_mode, compile_type, 
    src_dir, dest_dir);

	return result;
}

