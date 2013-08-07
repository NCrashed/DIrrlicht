// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.ILogger;

/// Possible log levels.
/** 
* When used has filter ELL_DEBUG means => log everything and ELL_NONE means => log (nearly) nothing.
* When used to print logging information ELL_DEBUG will have lowest priority while ELL_NONE
* messages are never filtered and always printed.
*/
enum ELOG_LEVEL
{
	/// Used for printing information helpful in debugging
	ELL_DEBUG,

	/// Useful information to print. For example hardware infos or something started/stopped.
	ELL_INFORMATION,

	/// Warnings that something isn't as expected and can cause oddities
	ELL_WARNING,

	/// Something did go wrong.
	ELL_ERROR,

	/// Logs with ELL_NONE will never be filtered.
	/// And used as filter it will remove all logging except ELL_NONE messages.
	ELL_NONE
};


/// Interface for logging messages, warnings and errors
interface ILogger
{
	/// Returns the current set log level.
	ELOG_LEVEL getLogLevel() const;

	/// Sets a new log level.
	/**
	* With this value, texts which are sent to the logger are filtered
	* out. For example setting this value to ELL_WARNING, only warnings and
	* errors are printed out. Setting it to ELL_INFORMATION, which is the
	* default setting, warnings, errors and informational texts are printed
	* out.
	* Params:
	* 	ll=  new log level filter value. 
	*/
	void setLogLevel(ELOG_LEVEL ll);

	/// Prints out a text into the log
	/**
	* Params:
	* 	text=  Text to print out.
	* 	ll=  Log level of the text. If the text is an error, set
	* it to ELL_ERROR, if it is warning set it to ELL_WARNING, and if it
	* is just an informational text, set it to ELL_INFORMATION. Texts are
	* filtered with these levels. If you want to be a text displayed,
	* independent on what level filter is set, use ELL_NONE. 
	*/
	void log(string text, ELOG_LEVEL ll=ELOG_LEVEL.ELL_INFORMATION);

	/// Prints out a text into the log
	/**
	* Params:
	* 	text=  Text to print out.
	* 	hint=  Additional info. This string is added after a " :" to the
	* string.
	* 	ll=  Log level of the text. If the text is an error, set
	* it to ELL_ERROR, if it is warning set it to ELL_WARNING, and if it
	* is just an informational text, set it to ELL_INFORMATION. Texts are
	* filtered with these levels. If you want to be a text displayed,
	* independent on what level filter is set, use ELL_NONE. 
	*/
	void log(string text, string hint, ELOG_LEVEL ll=ELOG_LEVEL.ELL_INFORMATION);
	void log(string text, wstring hint, ELOG_LEVEL ll=ELOG_LEVEL.ELL_INFORMATION);

	/// Prints out a text into the log
	/**
	* Params:
	* 	text=  Text to print out.
	* 	hint=  Additional info. This string is added after a " :" to the
	* string.
	* 	ll=  Log level of the text. If the text is an error, set
	* it to ELL_ERROR, if it is warning set it to ELL_WARNING, and if it
	* is just an informational text, set it to ELL_INFORMATION. Texts are
	* filtered with these levels. If you want to be a text displayed,
	* independent on what level filter is set, use ELL_NONE. 
	*/
	void log(wstring text, wstring hint, ELOG_LEVEL ll=ELOG_LEVEL.ELL_INFORMATION);

	/// Prints out a text into the log
	/**
	* Params:
	* 	text=  Text to print out.
	* 	ll=  Log level of the text. If the text is an error, set
	* it to ELL_ERROR, if it is warning set it to ELL_WARNING, and if it
	* is just an informational text, set it to ELL_INFORMATION. Texts are
	* filtered with these levels. If you want to be a text displayed,
	* independent on what level filter is set, use ELL_NONE. 
	*/
	void log(wstring text, ELOG_LEVEL ll=ELOG_LEVEL.ELL_INFORMATION);
}
