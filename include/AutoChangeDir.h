/**************************************************************************
 * @doc
 * 
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Carl Shimer
 * $Header$
 **************************************************************************/

#include <direct.h>

class AutoChangeDir {

public:
  AutoChangeDir(const char* pNewDir)
  {
	  _getcwd(mOldPath,MAX_PATH);
    _chdir(pNewDir);
  }
  ~AutoChangeDir()
  {
    _chdir(mOldPath);
  }


protected:
  char mOldPath[MAX_PATH];
};

  