// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.IOSOperator;

/// The Operating system operator provides operation system specific methods and informations.
interface IOSOperator
{
	/// Get the current operation system version as string.
	const string getOperatingSystemVersion() const;

	/// Get the current operation system version as string.
	/**
	* Deprecated:  Use getOperatingSystemVersion instead. This method will be removed in Irrlicht 1.9. 
	*/
	deprecated final wstring getOperationSystemVersion() const
	{
		import std.conv;
		return to!wstring(getOperatingSystemVersion());
	}

	/// Copies text to the clipboard
	void copyToClipboard(string text) const;

	/// Get text from the clipboard
	/**
	* Returns: Returns empty string if no string is in there. 
	*/
	string getTextFromClipboard() const;

	/// Get the processor speed in megahertz
	/**
	* Params:
	* 	MHz=  The integer variable to store the speed in.
	* Returns: True if successful, false if not 
	*/
	bool getProcessorSpeedMHz(out size_t MHz) const;

	/// Get the total and available system RAM
	/**
	* Params:
	* 	Total=  will contain the total system memory
	* 	Avail=  will contain the available memory
	* Returns: True if successful, false if not 
	*/
	bool getSystemMemory(out size_t Total, out size_t Avail) const;
}
