#include "StdAfx.h"
#include "VTCommon.h"

void GetFullLine(std::ifstream &arFileStream, std::string &arFullLine)
{
	arFullLine = "";
	char *buf = new char[1024];
	do {
		arFileStream.clear();
		arFileStream.getline(buf, 1024, '\n');
		arFullLine.append(buf);
	} while (arFileStream.fail());

	delete [] buf;
} //GetFullLine
