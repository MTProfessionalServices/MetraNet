/**************************************************************************
 * @doc TEST
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
 * Created by: Carl Shimer
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <mtcom.h>
#include <adsiutil.h>
#include <adsiuser.h>
#include <metra.h>
#include <iostream>
#include <string>

using std::string;
using std::cout;
using std::endl;

static ComInitialize GComInitialize;


const char* pVDir = "-CreateVdir";
const char* pDomainInfo = "-GetDomainInfo";
const char* DeleteVdir = "-DeleteVdir";
const char* VdirPath = "-GetVdirPath";
const char* pSetBasicAuth = "-SetBasicAuth";

int main (int argc, char ** argv)
{
	if(argc < 2) {
		cout << "Usage: " << argv[0] << " " << pVDir << " [IIS Virtual Directory Name] [Path Name] [optional [read] [write] [execute]] " << endl;
		cout << "Usage: " << argv[0] << " " << pDomainInfo << endl;
		cout << "Usage: " << argv[0] << " " << DeleteVdir << " VDir-name" << endl;
		cout << "Usage: " << argv[0] << " " << VdirPath << " Vdir-name" << endl;
		cout << "Usage: " << argv[0] << " " << pSetBasicAuth << " Vdir-name" << endl;

	}
	else {
		if(stricmp(argv[1],pVDir) == 0) {
			MTVdir aVdir;
			string aVdirStr(argv[2]);
			string aVdirPath(argv[3]);

			if(FAILED(aVdir.CreateIISVdir(aVdirStr,aVdirPath)))
				cout << "Failed to create " << aVdirStr << " virtual directory." << endl;
			else {
				cout << "Successfully created " << aVdirStr << " virtual directory." << endl;


			}
		}
		else if(stricmp(argv[1],pDomainInfo) == 0) {
				MTDomain aDomain;
				if(aDomain.Init()) {
					string aStr;
					aDomain.GetDomainName(aStr);

					cout << "Domain Name: " << aStr << endl;
					if(aDomain.IsDomain()) {
						cout << aStr << " is a NT Domain" << endl;
					}
					else {
						cout << aStr << " is not a NT domain" << endl;

					}
				}
				else {
					cout << "Failed to create ADSI domain object" << endl;

				}
		}
		else if(stricmp(argv[1],DeleteVdir) == 0) {
			MTVdir aVdir;
			if(argc < 3) {
				cout << "Not enougn arguments." << endl;
			}
			else {
				if(FAILED(aVdir.DeleteIISVdir(string(argv[2])))) {
					cout << "Failed to delete " << argv[2] << " virtual directory" << endl;
				}
				else {
					cout << "Successfully deleted virtual directory " << argv[2] << endl;
				}
			}

		}
		else if(stricmp(argv[1],VdirPath) == 0) {
			MTVdir aVdir;
			if(argc < 3) {
				cout << "Not enougn arguments." << endl;
			}
			else {
				string aPath;
				if(SUCCEEDED(aVdir.GetVdirPhysicalPath(string(argv[2]),aPath))) {
					cout << "Virtual directory path is " << aPath << endl;
				}
				else {
					cout << "Could not get virtual directory path" << endl;
				}
			}
		}
		else if(stricmp(argv[1],pSetBasicAuth) == 0) {
			MTVdir aVdir;
			if(argc < 3) {
				cout << "Not enougn arguments." << endl;
			}
			else {
				if(SUCCEEDED(aVdir.SetBasicAuth(string(argv[2])))) {
					cout << "successfully set the basic auth propertly on " << argv[2] << endl;
				}
				else {
					cout << "Failed to set the basic auth property on " << argv[2] << endl;

				}

			}
		}

	}
  return TRUE;
}



