//VTCommon.h
#include <string>
#include <fstream>

//Helper functions that are useful throughout this project.

void GetFullLine(std::ifstream &arFileStream, std::string &arFullLine);

template<class T1> void ParseOnCommas(const std::string &arsString, T1 &arTokens)
{
	int i=0;
	while(arsString.find(',', i) != string::npos)
	{
		arTokens.push_back(arsString.substr(i, arsString.find(',', i)-i));
		i=arsString.find(',', i)+1;
	}
	arTokens.push_back(arsString.substr(i));
} //ParseOnCommas
