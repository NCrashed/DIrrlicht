#!/usr/bin/rdmd
module compile;

import dmake;

import std.stdio;
import std.process;
import std.file;

//======================================================================
//							Compilation setup
//======================================================================
int main(string[] args)
{
	// Клиент
	addCompTarget("dirrlicht", "../bin", "Dirrlicht", BUILD.LIB);
	addSource("../source");

	//addCustomFlags("-v");
	checkProgram("dmd", "Cannot find dmd to compile project! You can get it from http://dlang.org/download.html");
	return proceedCmd(args);
}