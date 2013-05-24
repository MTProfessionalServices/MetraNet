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
 * Modification History:
 *
 * $Header$
 *
 * MT time conversion Utility function
 ***************************************************************************/

#include <metra.h>
#include "MTUtil.h"

#include <ctype.h>
#include <time.h>

// Convert time from string format to long value in second.
long MTConvertTime(const string& arTime)
{
	string at;
	at.reserve(arTime.size());

	// TODO: optimize this loop..
	string::const_iterator it = arTime.begin();
  while (it != arTime.end())
	{
		at += tolower(*it);

		it++;
  }

	string	col(":");
	string	am("am");
	string	pm("pm");
	string::size_type idB = 0, idE = 0, len;
	string	str;
	const char	*p;
	int			hour = 0, min = 0, sec = 0;
	long result;

	if ((idE = at.find(col, idB)) != string::npos)
	{
		len = idE - idB;
		str.assign(at.c_str() + idB, len);
		p = str.c_str();
		if (!isdigit(*p))
		{
			return -1;
		}
		hour = atol(p);

		idB = idE + 1;
		if ((idE = at.find(col, idB)) != string::npos)
		{
			len = idE - idB;
			str.assign(at.c_str() + idB, len);
			p = str.c_str();
			if (!isdigit(*p))
			{
				return -1;
			}
			min = atol(p);

			// get second
			idB = idE + 1;
			if ((idE = at.find(am, idB)) != string::npos||
				(idE = at.find(pm, idB)) != string::npos)
			{
				len = idE - idB;
				str.assign(at.c_str() + idB, len);
				p = str.c_str();
				if (!isdigit(*p))
				{
					return -1;
				}
				sec = atol(p);
			}

		}
		else if ((idE = at.find(am, idB)) != string::npos ||
				 (idE = at.find(pm, idB)) != string::npos)
		{
			len = idE - idB;
			str.assign(at.c_str() + idB, len);
			p = str.c_str();
			if (!isdigit(*p))
			{
				return -1;
			}
			min = atol(p);
		}
	}
	else if ((idE = at.find(am, idB)) != string::npos ||
			 (idE = at.find(pm, idB)) != string::npos)
	{
		// if only hour number presented
		len = idE - idB;
		str.assign(at.c_str() + idB, len);
		p = str.c_str();
		if (!isdigit(*p))
		{
			return -1;
		}
		hour = atol(p);
	}
	else
	{
		p = at.c_str();
		if (!isdigit(*p))
		{
			return -1;
		}
		hour = atol(p);
	}

	if ((idE = at.find(pm, idB)) != string::npos)
	{
		hour = hour + 12;
	}

	result = hour * 3600 + min * 60 + sec;

	return result;
}


void MTFormatTime(long aTimeOfDay, string & arFormatted)
{
	// hh:mm:ss (24 hour)

	int hours = aTimeOfDay / (60 * 60);
	//int mins = (aTimeOfDay - (hours * 60 * 60)) / 60;
	int mins = (aTimeOfDay / 60) % 60;
	int secs = aTimeOfDay % 60;

	ASSERT(hours < 24);
	char buffer[256];
	sprintf(buffer, "%02d:%02d:%02d", hours, mins, secs);
	arFormatted = buffer;
}

