//Disable truncation warning message.
#pragma warning(disable: 4786)

//Windows includes:
#include <windows.h>
#include <comdef.h>

//C includes:
#include <iostream>
#include <string>
#include <vector>
#include <list>
#include <fstream>
#include <math.h>

//Metratech includes:
#include <expandfilelist.h>

#include "VTCommon.h"

using namespace std;

typedef vector<vector<bool> > dataset;

//Function Prototypes:

//Formats the output of collect.
void WriteDatafile(const string &arFileName, const string &arDirName,
										 list<string> &arDLst, const string &arClassName);
//Functions that help out with the decision tree generation.
void GetColumn(vector<vector<string> >& arGrid, int aCol,
							 vector<string>& arColumn);
string TagTree(int i);
void Remove(vector<string>& arvVector, int aiIndice);
void RemoveCol(dataset& arvSet, int col);
void RemoveRowCol(dataset& arvSet, int row, int col);
void Split(int iDescriptor, dataset& arvSet, vector<string>& arvClasses,
					 dataset& true_set, dataset& false_set,
					 vector<string>& true_class, vector<string>& false_class);
//Functions that calculate information theory stuff.
void ProbDist(int aSetSize, vector<float>& arvProb);
float I(vector<float>& arvProb);
float Info(int aDescriptor, dataset& arSet);
float Gain(int aDescriptor, dataset& arSet);
//ID3
string id3(dataset avSet, vector<string> avDesc, vector<string> avVer,
					 vector<string> avClass, vector<string>& decisionTree);

//WriteDataFile:
void WriteDatafile(const string &arFileName,
										 const string &arDirName,
										 list<string> &arDLst, // Descriptor list.
										 const string &arClassName)
{
	list<string> FileDList, DirDList, TempList;
	list<string>::const_iterator i, j;
	string DSet, TempStr;

	////Create an input stream.
	ifstream fin(arFileName.c_str());
	if (fin.fail()) {
		////We need to create the input file.
		ofstream fout(arFileName.c_str());
		//The first line is the class name.
		fout << arClassName << endl;

		//The second line is the set of descriptors.
		ExpandFileList(TempList, (arDirName+"*.dll").c_str());
		//Careful to set the arDLst parameter to this set also.
		for (i=TempList.begin(); i!=TempList.end(); i++)
			arDLst.push_back((*i).substr(((*i).find_last_of('\\'))+1));
		for (i=arDLst.begin(); i!=arDLst.end(); i++) {
			if (i!=arDLst.begin())
				fout << ',';
			fout << *i;
		}
		fout << endl;

		fout.close();
	} else {
		////Get the list of descriptors from the data file.
		GetFullLine(fin, TempStr); //The first line is class names.
		GetFullLine(fin, DSet); //The second is descriptors.
		if (DSet.empty()) {
			cerr << "Malformed input file.\n";
			exit(1);
		}
		ParseOnCommas<list<string> >(DSet, FileDList);
		
		////Get the list of descriptors from the directory.
		ExpandFileList(TempList, (arDirName+"*.dll").c_str());
		//Strip everything but the filename from descriptors.
		for (i=TempList.begin(); i!=TempList.end(); i++)
			DirDList.push_back((*i).substr(((*i).find_last_of('\\'))+1));
		
		////Collect new descriptors.
		TempList.clear();
		for (i=DirDList.begin(); i != DirDList.end(); i++)
		{
			for (j=FileDList.begin(); j != FileDList.end(); j++)
				if ((*j).compare(*i) == 0)
					break;
			if (j == FileDList.end())
				TempList.push_back(*i);
		}
		
		//Finds a name for a new temporary file.
		char *tfnamebuf = new char[256];
		for(int uniquenum=0; true; uniquenum++)
		{
			sprintf(tfnamebuf, "tempfile-%d", uniquenum);
			ifstream opentest(tfnamebuf);
			if (opentest.fail())
				break;
		}
		
		//Copies old file into new file, while adding new descriptors
		int newlinesread = 0;
		fin.seekg(0);
		ofstream fout(tfnamebuf);
		char readChar;
		for(fin.get(readChar); !fin.fail(); fin.get(readChar))
		{
			if (readChar == '\n') {
				newlinesread++;
				if (newlinesread==1)
					fout << ',' << arClassName;
				else if (newlinesread==2 && TempList.size() > 0)
					for (i=TempList.begin(); i != TempList.end(); i++)
						fout << ',' << *i;
				else if (newlinesread>2 && TempList.size() > 0)
					for (unsigned int k=0; k<TempList.size(); k++)
						fout << ",x";
				fout << endl;
			} else
				fout << readChar;
		}
		fout.close();
		fin.close();
		
		////Replace data file with temporary file.
		if (remove(arFileName.c_str()) != 0) {
			cerr << "Failed to update data file." << endl;
			exit(1);
		}
		if (rename(tfnamebuf, arFileName.c_str())) {
			cerr << "Failed to update data file." << endl;
			exit(1);
		}
		delete [] tfnamebuf;
		
		//This reference should be set to the list of descriptors.
		if(TempList.size() > 0)
		{
			arDLst.merge(FileDList);
			arDLst.merge(TempList);
		} else
			arDLst.merge(FileDList);
	}
} //WriteDataFile

//GetColumns:
//Takes a 2-d vector and a column number and returns all unique values
//in the selected column as a vector.
//
//Expects:
// A reference to a 2-d vector of strings.
// An int representing which column to select.
// A reference to a vector of strings, which takes unique values of
// the selected column.
////
void GetColumn(vector<vector<string> >& arGrid, int aCol,
							 vector<string>& arColumn)
{
	for(unsigned int i=0; i<arGrid.size(); i++)
	{
		bool unique=true;
		for (unsigned int j=0; j<arColumn.size(); j++)
			if (arColumn[j]==arGrid[i][aCol])
				unique=false;
		if(unique)
			arColumn.push_back(arGrid[i][aCol]);
	}
} //GetColumn

//For the following functions dealing with information theory, there
//is an assumption that every row in the dataset corresponds to a
//single class.
//
// ProbDist, I, Info, Gain

//ProbDist: Probability a classification entry is in one of the
//classes.
void ProbDist(int aSetSize, vector<float>& arvProb)
{
	for (int i=0; i<aSetSize; i++)
		arvProb.push_back(1.0f/aSetSize);
} //ProbDist

//I: A measure of the entropy. How close to random a set is.
float I(vector<float>& arvProb)
{
	float sum = 0.0f;
	for (unsigned int i=0; i<arvProb.size(); i++)
		sum+= arvProb[i]*(logf(arvProb[i])/logf(2.0f)); //x * log of x base 2.
	
	return -1.0f * sum;
} //I

//Info: How well a descriptor describes the classes.
//
//Since we converted the dataset to only boolean values this function
//only has to consider two entropy calculations.
float Info(int aDescriptor, dataset& arSet)
{
	float sum=0.0f;
	vector<float> prob;

	//Get the information value for the descriptor when true.
	int setSize=0;
	for (unsigned int i1=0; i1<arSet.size(); i1++) {
		if (arSet[i1][aDescriptor])
			setSize++;
	}
	ProbDist(setSize, prob);
	sum+=  I(prob) * (float)setSize / (float)arSet.size();

	//Get the information value for the descriptor when false.
	setSize=0;
	prob.clear();
	for (unsigned int i2=0; i1<arSet.size(); i2++) {
		if (!arSet[i2][aDescriptor])
			setSize++;
	}
	ProbDist(setSize, prob);
	sum+= I(prob) * (float)setSize / (float)arSet.size();
	
	return sum;
} //Info

//Gain: Measures information gain.
float Gain(int aDescriptor, dataset& arSet)
{
	vector<float> prob;
	ProbDist(arSet.size(), prob);

	return I(prob) - Info(aDescriptor, arSet);
} //Gain


//TagTree: Tags an indice as a tree in the tree representation.
string TagTree(int i)
{
	char* buf = new char[256];
	sprintf(buf, "@%d", i);
	string retVal = buf;
	delete [] buf;
	
	return retVal;
} //TagTree

//Remove: Removes an element at index i.
void Remove(vector<string>& arvVector, int aiIndice)
{
	vector<string>::iterator i=arvVector.begin();
	i+=aiIndice;
	arvVector.erase(i);
} //Remove

//RemoveCol: Removes a column from the data set.
void RemoveCol(dataset& arvSet, int col)
{
	vector<bool>::iterator i;
	for (unsigned int j=0; j<arvSet.size(); j++) {
		i=arvSet[j].begin();
		i+=col;
		arvSet[j].erase(i);
	}
} //RemoveCol

//RemoveRowCol: Removes a row and a column from the data set.
void RemoveRowCol(dataset& arvSet, int row, int col)
{
	dataset::iterator i;
	i=arvSet.begin();
	i+=row;
	arvSet.erase(i);
	RemoveCol(arvSet, col);
} //RemoveRowCol

//Splits the data set avSet, into a set where descriptor[i] is true
//and a set where descriptor[i] is false.
void Split(int iDescriptor, dataset& arvSet, vector<string>& arvClasses,
					 dataset& true_set, dataset& false_set, vector<string>& true_class,
					 vector<string>& false_class)
{
	for (unsigned int i=0; i<arvSet.size(); i++)
		if (arvSet[i][iDescriptor]) {
			true_set.push_back(arvSet[i]);
			true_class.push_back(arvClasses[i]);
		} else {
			false_set.push_back(arvSet[i]);
			false_class.push_back(arvClasses[i]);
		}
	RemoveCol(true_set, iDescriptor);
	RemoveCol(false_set, iDescriptor);
} //Split

//id3: The ID3 decision tree generating algorithm.
//
//The tree is represented as a vector of strings. Each string
//corresponds to a node in the tree. A terminal is listed as a name,
//while a link to an internal node is an index to that node tagged by
//an '@'. The left branch is always the branch labeled true, and the
//right branch is always the branch labeled false. An entry in the
//vector always has this form:
//Descriptor,Version Number,[Terminal, Left Branch],[Terminal, Right Branch]
//i.e.
//foo.dll,1.0.1,@1,MT_V1.2
//bar.dll,1.2.0,MT_V1.3,MT_V1.4
//
string id3(dataset avSet, vector<string> avDesc, vector<string> avVer,
					 vector<string> avClass, vector<string>& decisionTree)
{
	////Degenerate case: There are no more classes left to classify.
	//This should never happen in our space of potential training sets.
	if (avSet.size() == 0) {
		return string("failure");
	}
	
	////Check each descriptor if one perfectly predicts a class.
	for (unsigned int i=0; i<avSet[0].size(); i++) {
		unsigned int count=0;
		//Count the true values of the descriptor[i].
		for (unsigned int k=0; k<avSet.size(); k++)
			if (avSet[k][i])
				count++;
    ////Degenerate Case: Only one value is true for a descriptor.
		if (count==1) {
			//Construct an entry in decisionTree.
			string treenode = avDesc[i] + ',' + avVer[i] + ',';
			unsigned int k;
			for (k=0; k<avSet.size() && !avSet[k][i]; k++);
			if (avSet.size()==2) {
				if (k==1)
					treenode+= avClass[1] + ',' + avClass[0] + '\n';
				else
					treenode+= avClass[0] + ',' + avClass[1] + '\n';
			} else {
				treenode += avClass[k] + ',';
				RemoveRowCol(avSet, k, i);
				Remove(avDesc, i);
				Remove(avVer, i);
				Remove(avClass, k);
				treenode += id3(avSet, avDesc, avVer, avClass, decisionTree) + '\n';
			}
			decisionTree.push_back(treenode);
			
			//Since we pushed on to the end of the vector, the index of that
			//element is size-1.
			return TagTree(decisionTree.size()-1);
		}
		////Degenerate Case: Only one value is false for a descriptor.
		else if (count==avSet.size()-1) {
			//Construct an entry in decisionTree.
			string treenode = avDesc[i] + ',' + avVer[i] + ',';
			unsigned int k;
			for (k=0; k<avSet.size() && avSet[k][i]; k++);
			if (avSet.size()==2) {
				if (k==0)
					treenode+= avClass[1] + ',' + avClass[0] + '\n';
				else
					treenode+= avClass[0] + ',' + avClass[1] + '\n';
			} else {
				string temp = avClass[k];
				RemoveRowCol(avSet, k, i);
				Remove(avDesc, i);
				Remove(avVer, i);
				Remove(avClass, k);
				treenode += id3(avSet, avDesc, avVer, avClass, decisionTree) + ',';
				treenode += temp + '\n';
			}
			decisionTree.push_back(treenode);
			
			//Since we pushed on to the end of the vector, the index of that
			//element is size-1.
			return TagTree(decisionTree.size()-1);
		}
	}

	////The Inductive Case:
	//Find the Descriptor with the largest Gain.
	float maxval=0.0f;
	int maxindice=0;
	for (unsigned int k=0; k<avSet[0].size(); k++) {
		float fgain = Gain(k, avSet);
		if (fgain > maxval) {
			maxval=fgain;
			maxindice=k;
		}
	}

	//Make a decision on that node, splitting subtrees.
	string treenode;
	dataset t_set, f_set;
	vector<string> t_class, f_class;
	Split(maxindice, avSet, avClass, t_set, f_set, t_class, f_class);
	treenode = avDesc[maxindice] + ',' + avVer[maxindice] + ',';
	Remove(avDesc, maxindice);
	Remove(avVer, maxindice);
	treenode += id3(t_set, avDesc, avVer, t_class, decisionTree) + ',';
	treenode += id3(f_set, avDesc, avVer, f_class, decisionTree) + '\n';
	decisionTree.push_back(treenode);

	//Since we pushed on to the end of the vector, the index of that
	//element is size-1.
	return TagTree(decisionTree.size()-1);	
} //id3

//
//main: 
//
int main(int argv, char *argc[])
{
	////Check command-line parameters.
	if (argv <= 1) {
		cerr << "You must specify whether you want to use the collector"
				 << "or classifier.\n";
		cout << "Usage:\nVTUpdate [-classify -collect] ...\n";
		return 1;
	} else if (strcmp(argc[1], "-classify")==0) {
		if (argv != 4) {
			cerr << "Incorrect amount of arguments.\n";
			cout << "Usage:\nVersionClassifier"
					 << " input-file output-file\n";
			return 1;
		}
	
		//Collect the string data set from the input file.
		ifstream inputDataFile(argc[2]);
		if (inputDataFile.fail())
			cerr << "Input file does not exist.\n";
		string sDataStr;
		vector<vector<string> > vStringData;
		vector<string> vDesNames;
		vector<string> vClassNames;
		GetFullLine(inputDataFile, sDataStr);
		ParseOnCommas<vector<string> >(sDataStr, vClassNames);
		GetFullLine(inputDataFile, sDataStr);
		ParseOnCommas<vector<string> >(sDataStr, vDesNames);
		while (!inputDataFile.eof()) {
			vector<string> vDataRow;
			GetFullLine(inputDataFile, sDataStr);

			//This is a hack. This is only a hack. eof() is not properly
			//detected, getting and putting back a char, seems to set things
			//right.
			char hack;
			inputDataFile.get(hack);
			inputDataFile.putback(hack);
			
			ParseOnCommas<vector<string> >(sDataStr, vDataRow);
			vStringData.push_back(vDataRow);
		}
		
		//The data set has to be in columns where each row is a boolean
		//value, so we need to expand descriptors to be "name==*.dll &&
		//version==*.*.*.*" and the data rows to be boolean values that are
		//the evaluation of that expression.
		vector<string> vFullDesNames;
		vector<string> vFullDesVersions;
		dataset vBoolData;
		//Initializes the 2d vector.
		for (unsigned int init=0; init<vStringData.size(); init++)
		{
			vector<bool> vtemp;
			vBoolData.push_back(vtemp);
		}
		
		for (unsigned int i=0; i<(vStringData[0]).size(); i++)
		{
			vector<string> column;
			GetColumn(vStringData, i, column);
			for (unsigned int j=0; j<column.size(); j++)
			{
				//Add the descriptor name to the expanded name row.
				vFullDesNames.push_back(vDesNames[i]);
				//Add the version value to the version row.
				vFullDesVersions.push_back(column[j]);
				//Add the boolean information to the boolean data set.
				for (unsigned int k=0; k<vStringData.size(); k++)
					vBoolData[k].push_back(column[j]==vStringData[k][i]);
			}			
		}
		
		ofstream fout(argc[3], ios_base::out);
		//The data should be in a form usable by the decision tree algorithm.
		vector<string> dt;
		fout << id3(vBoolData, vFullDesNames, vFullDesVersions,
								vClassNames, dt) << endl;
		
		for (unsigned int c=0; c<dt.size(); c++)
			fout << dt[c];
		fout << endl;

	} else if (strcmp(argc[1], "-collect")==0) {
		////Check command-line parameters.
		if (argv != 5) {
			cerr << "Incorrect amount of arguments.\n";
			cout << "Usage:\nVTUpdate -collect"
					 << " directory-to-collect collection-file new-class\n";
			exit(1);
		}	
		
		////Format dir_name to have a terminating '\' if necessary.
		string dir_name(argc[2]);
		if (dir_name.at(dir_name.length() - 1) != '\\')
			dir_name += '\\';
		
		////Update the data file with the new class and descriptor data.
		string inputDataFile(argc[3]);
		list<string> descriptorList;
		string class_name(argc[4]);
		WriteDatafile(inputDataFile, dir_name, descriptorList, class_name);
		
		////Get the version information from the descriptors.
		ofstream fout(inputDataFile.c_str(), ios_base::out | ios_base::app);
		list<string>::const_iterator i;
		for (i = descriptorList.begin(); i != descriptorList.end(); i++)
		{
			
			//Comma delimit when necessary.
			if (i != descriptorList.begin())
				fout << ',';
			
			// Concatenate the descriptor with the command-line directory
			// path parameter.
			string filename = dir_name + *i;
			
			//If file doesn't exists, output 'x' to the file and continue.
			ifstream fexists(filename.c_str());
			if (fexists.fail()) {
				fout << 'x';
				continue;
			}
			
			// Get size for the file version info buffer.
			DWORD dwUseless;
			int len = GetFileVersionInfoSize(_bstr_t(filename.c_str()), &dwUseless);
			if (len == 0) {
				fout << 'x';
				continue; //Some DLL's may not have version information.
			}
			// Get File Version Info.
			BYTE *lpVerInfo = new BYTE[len];
			if (!GetFileVersionInfo(_bstr_t(filename.c_str()),
															dwUseless, len, lpVerInfo))
			{
				cerr << "Error reading file version info.\n";
				exit(1);
			}
			// Get FIXED_FILE_VER structure.
			LPVOID lpvi;
			UINT iLen;
			if (!VerQueryValue(lpVerInfo, "\\", &lpvi, &iLen))
			{
				cerr << "Error reading file version info.\n";
				exit(1);
			}
			VS_FIXEDFILEINFO ffo = *(VS_FIXEDFILEINFO*)lpvi;
			// Create a string from the file version info.
			char *tmpbuf = new char[256];
			sprintf(tmpbuf, "%d.%d.%d.%d",
							HIWORD(ffo.dwFileVersionMS),
							LOWORD(ffo.dwFileVersionMS),
							HIWORD(ffo.dwFileVersionLS),
							LOWORD(ffo.dwFileVersionLS));
			
			//Output it to the data file.
			fout << tmpbuf;
			
			// Free any memory used.
			delete [] tmpbuf;
			delete lpVerInfo;
		}
		fout << '\n';
		fout.close();
		
	} else {
		cerr << "You must specify whether you want to use the collector"
				 << "or classifier.\n";
		cout << "Usage:\nVTUpdate [-classify -collect] ...\n";
		return 1;
	}
	
	return 0;
} //main
