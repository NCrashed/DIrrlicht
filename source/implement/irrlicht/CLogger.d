// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.CLogger;

import irrlicht.ILogger;
import irrlicht.IEventReceiver;
import irrlicht.os;
import std.conv;

/// Class for logging messages, warnings and errors to stdout
class CLogger : ILogger
{
	this(IEventReceiver r)
	{
		Receiver = r;
	}

	/// Returns the current set log level.
	ELOG_LEVEL getLogLevel() const
	{
		return LogLevel;
	}

	/// Sets a new log level.	void setLogLevel(ELOG_LEVEL ll);
	void setLogLevel(ELOG_LEVEL ll)
	{
		LogLevel = ll;
	}

	/// Prints out a text into the log
	void log(string text, ELOG_LEVEL ll = ELOG_LEVEL.ELL_INFORMATION)
	{
		if (ll < LogLevel)
			return;

		if (Receiver !is null)
		{
			SEvent event;
			event.EventType = EEVENT_TYPE.EET_LOG_TEXT_EVENT;
			event.LogEvent.Text = text;
			event.LogEvent.Level = ll;
			if (Receiver.OnEvent(event))
				return;
		}

		Printer.print(text);
	}

	/// Prints out a text into the log
	void log(wstring text, ELOG_LEVEL ll = ELOG_LEVEL.ELL_INFORMATION)
	{
		if (ll < LogLevel)
			return;

		log(to!string(text), ll);
	}
	
	/// Prints out a text into the log
	void log(string text, string hint, ELOG_LEVEL ll = ELOG_LEVEL.ELL_INFORMATION)
	{
		if (ll < LogLevel)
			return;

		log(text ~ ": " ~ hint, ll);
	}

	/// Prints out a text into the log
	void log(string text, wstring hint, ELOG_LEVEL ll = ELOG_LEVEL.ELL_INFORMATION)
	{
		if (ll < LogLevel)
			return;

		log(text, to!string(hint), ll);
	}

	/// Prints out a text into the log
	void log(wstring text, wstring hint, ELOG_LEVEL ll = ELOG_LEVEL.ELL_INFORMATION)
	{
		if (ll < LogLevel)
			return;

		log(to!string(text), to!string(hint), ll);
	}

	/// Sets a new event receiver
	void setReceiver(IEventReceiver r)
	{
		Receiver = r;
	}

	private ELOG_LEVEL LogLevel = ELOG_LEVEL.ELL_INFORMATION;
	private IEventReceiver Receiver;
}