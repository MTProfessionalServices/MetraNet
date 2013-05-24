// VersionTool.h : Declaration of the CVersionTool

#ifndef __VERSIONTOOL_H_
#define __VERSIONTOOL_H_

#include "resource.h"       // main symbols

#include <vector>
#include <string>
#include <fstream>
#include <ConfigDir.h>

#include "VTCommon.h"

using namespace std;

/////////////////////////////////////////////////////////////////////////////
// CVersionTool
class ATL_NO_VTABLE CVersionTool : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CVersionTool, &CLSID_VersionTool>,
	public ISupportErrorInfo,
	public IDispatchImpl<IVersionTool, &IID_IVersionTool, &LIBID_VERSIONREPORTINGLib>
{

private:
	vector<vector<string> > mDecisionTree;
	string mDLLDirectory;
	int mRootNode;
public:
	CVersionTool()
	{

		std::string dlldir, configfile;
		GetMTInstallDir(dlldir);
		GetMTConfigDir(configfile);
		dlldir+="\\RMP\\Shared\\";
		mDLLDirectory = dlldir.c_str();

		configfile += "\\VersionReporting\\dtree.dat";
		
		//Set the location of the decision tree data file for now.
		//Read and Parse the decision tree.
		ifstream fin(configfile.c_str());
		string root;
		if(!fin.fail()) {
			string sDataStr;
			GetFullLine(fin, root);
			
			while (!fin.eof()) {
				vector<string> vDataRow;
				GetFullLine(fin, sDataStr);

				//This is a hack. This is only a hack. eof() is not properly
				//detected, getting and putting back a char, seems to set things
				//right.
				char hack;
				fin.get(hack);
				fin.putback(hack);
				
				ParseOnCommas<vector<string> >(sDataStr, vDataRow);
				mDecisionTree.push_back(vDataRow);
			}
		}
		fin.close();
		
		//Get the root node.
		mRootNode = atoi(root.substr(1, string::npos).c_str());
	}

DECLARE_REGISTRY_RESOURCEID(IDR_VERSIONTOOL)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CVersionTool)
	COM_INTERFACE_ENTRY(IVersionTool)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IVersionTool
public:
	STDMETHOD(GetVersion)(BSTR*);
};

#endif //__VERSIONTOOL_H_
