// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.io.IFileSystem;

import irrlicht.io.IReadFile;
import irrlicht.io.IFileArchive;
import irrlicht.io.IFileList;
import irrlicht.io.IXMLReader;
import irrlicht.io.IReadFile;
import irrlicht.io.IWriteFile;
import irrlicht.io.IXMLWriter;
import irrlicht.io.IAttributes;
import irrlicht.video.IVideoDriver;
import irrlicht.io.path;


/// The FileSystem manages files and archives and provides access to them.
/** 
*It manages where files are, so that modules which use the the IO do not
*need to know where every file is located. A file could be in a .zip-Archive or
*as file on disk, using the IFileSystem makes no difference to this. 
*/
interface IFileSystem
{
	/// Opens a file for read access.
	/**
	* Params: 
	*	filename= Name of file to open.
	* Returns: Pointer to the created file interface.
	*/
	IReadFile createAndOpenFile(const Path filename);

	/// Creates an IReadFile interface for accessing memory like a file.
	/** 
	* This allows you to use a pointer to memory where an IReadFile is requested.
	* Params:
	*	memory= A pointer to the start of the file in memory
	*	len= The length of the memory in bytes
	*	fileName= The name given to this file
	*	deleteMemoryWhenDropped= True if the memory should be deleted
	*							 along with the IReadFile when it is dropped.
	* Returns: Pointer to the created file interface.
	*/
	IReadFile createMemoryReadFile(void* memory, int len, const Path fileName, bool deleteMemoryWhenDropped=false);

	/// Creates an IReadFile interface for accessing files inside files.
	/** 
	* This is useful e.g. for archives.
	* Params:
	*	fileName= The name given to this file
	*	alreadyOpenedFile= Pointer to the enclosing file
	*	pos= Start of the file inside alreadyOpenedFile
	*	areaSize: The length of the file
	* Returns: A pointer to the created file interface.
	*/
	IReadFile createLimitReadFile(const Path fileName,
			IReadFile alreadyOpenedFile, int pos, int areaSize);

	/// Creates an IWriteFile interface for accessing memory like a file.
	/** 
	* This allows you to use a pointer to memory where an IWriteFile is requested.
	*	You are responsible for allocating enough memory.
	* Params:
	*	memory= A pointer to the start of the file in memory (allocated by you)
	*	len= The length of the memory in bytes
	*	fileName= The name given to this file
	*	deleteMemoryWhenDropped= True if the memory should be deleted
	*							 along with the IWriteFile when it is dropped.
	* Returns: Pointer to the created file interface.
	*/
	IWriteFile createMemoryWriteFile(void* memory, int len, const Path fileName, bool deleteMemoryWhenDropped=false);

	/// Opens a file for write access.
	/**
	* Params: 
	*	filename= Name of file to open.
	*	append= If the file already exist, all write operations are
	*			appended to the file.
	* Returns: Pointer to the created file interface. 0 is returned, if the
	*			file could not created or opened for writing.
	*/
	IWriteFile createAndWriteFile(const Path filename, bool append=false);

	/// Adds an archive to the file system.
	/** 
	* After calling this, the Irrlicht Engine will also search and open
	* files directly from this archive. This is useful for hiding data from
	* the end user, speeding up file access and making it possible to access
	* for example Quake3 .pk3 files, which are just renamed .zip files. By
	* default Irrlicht supports ZIP, PAK, TAR, PNK, and directories as
	* archives. You can provide your own archive types by implementing
	* IArchiveLoader and passing an instance to addArchiveLoader.
	* Irrlicht supports AES-encrypted zip files, and the advanced compression
	* techniques lzma and bzip2.
	* Params:
	*	filename= Filename of the archive to add to the file system.
	*	ignoreCase= If set to true, files in the archive can be accessed without
	*				writing all letters in the right case.
	*	ignorePaths= If set to true, files in the added archive can be accessed
	*					without its complete path.
	*	archiveType= If no specific E_FILE_ARCHIVE_TYPE is selected then
	*					the type of archive will depend on the extension of the file name. If
	*					you use a different extension then you can use this parameter to force
	*					a specific type of archive.
	*	password= An optional password, which is used in case of encrypted archives.
	*	retArchive= A pointer that will be set to the archive that is added.
	* Returns: True if the archive was added successfully, false if not. 
	*/
	bool addFileArchive(const Path filename, out IFileArchive retArchive, bool ignoreCase=true,
			bool ignorePaths=true,
			E_FILE_ARCHIVE_TYPE archiveType=E_FILE_ARCHIVE_TYPE.EFAT_UNKNOWN,
			string password="");

	/// Adds an archive to the file system.
	/** 
	* After calling this, the Irrlicht Engine will also search and open
	* files directly from this archive. This is useful for hiding data from
	* the end user, speeding up file access and making it possible to access
	* for example Quake3 .pk3 files, which are just renamed .zip files. By
	* default Irrlicht supports ZIP, PAK, TAR, PNK, and directories as
	* archives. You can provide your own archive types by implementing
	* IArchiveLoader and passing an instance to addArchiveLoader.
	* Irrlicht supports AES-encrypted zip files, and the advanced compression
	* techniques lzma and bzip2.
	* If you want to add a directory as an archive, prefix its name with a
	* slash in order to let Irrlicht recognize it as a folder mount (mypath/).
	* Using this technique one can build up a search order, because archives
	* are read first, and can be used more easily with relative filenames.
	* Params:
	*	file= Archive to add to the file system.
	*	ignoreCase= If set to true, files in the archive can be accessed without
	*				writing all letters in the right case.
	*	ignorePaths= If set to true, files in the added archive can be accessed
	*					without its complete path.
	*	archiveType= If no specific E_FILE_ARCHIVE_TYPE is selected then
	*					the type of archive will depend on the extension of the file name. If
	*					you use a different extension then you can use this parameter to force
	*					a specific type of archive.
	*	password= An optional password, which is used in case of encrypted archives.
	*	retArchive= A pointer that will be set to the archive that is added.
	* Returns: True if the archive was added successfully, false if not. 
	*/
	bool addFileArchive(IReadFile file, out IFileArchive retArchive, bool ignoreCase=true,
			bool ignorePaths=true,
			E_FILE_ARCHIVE_TYPE archiveType=E_FILE_ARCHIVE_TYPE.EFAT_UNKNOWN,
			string password="");

	/// Adds an archive to the file system.
	/**
	* Params: 
	*	archive= The archive to add to the file system.
	* Returns: True if the archive was added successfully, false if not. 
	*/
	bool addFileArchive(IFileArchive archive);

	/// Get the number of archives currently attached to the file system
	uint getFileArchiveCount() const;

	/// Removes an archive from the file system.
	/** 
	* This will close the archive and free any file handles, but will not
	* close resources which have already been loaded and are now cached, for
	* example textures and meshes.
	* Params:
	*	index= The index of the archive to remove
	* Returns: True on success, false on failure 
	*/
	bool removeFileArchive(uint index);

	/// Removes an archive from the file system.
	/** 
	* This will close the archive and free any file handles, but will not
	* close resources which have already been loaded and are now cached, for
	* example textures and meshes. Note that a relative filename might be
	* interpreted differently on each call, depending on the current working
	* directory. In case you want to remove an archive that was added using
	* a relative path name, you have to change to the same working directory
	* again. This means, that the filename given on creation is not an
	* identifier for the archive, but just a usual filename that is used for
	* locating the archive to work with.
	* Params:
	*	filename= The archive pointed to by the name will be removed
	* Returns: True on success, false on failure 
	*/
	bool removeFileArchive(const Path filename);

	/// Removes an archive from the file system.
	/** 
	* This will close the archive and free any file handles, but will not
	* close resources which have already been loaded and are now cached, for
	* example textures and meshes.
	* Params:
	*	archive= The archive to remove.
	* Returns: True on success, false on failure 
	*/
	bool removeFileArchive(const IFileArchive archive);

	/// Changes the search order of attached archives.
	/**
	* Params:
	*	sourceIndex= The index of the archive to change
	*	relative= The relative change in position, archives with a lower index are searched first 
	*/
	bool moveFileArchive(uint sourceIndex, int relative);

	/// Get the archive at a given index.
	IFileArchive getFileArchive(uint index);

	/// Adds an external archive loader to the engine.
	/** 
	* Use this function to add support for new archive types to the
	* engine, for example proprietary or encrypted file storage. 
	*/
	void addArchiveLoader(IArchiveLoader loader);

	/// Gets the number of archive loaders currently added
	uint getArchiveLoaderCount() const;

	/// Retrieve the given archive loader
	/** 
	* Params:
	*	index= The index of the loader to retrieve. This parameter is an 0-based
	*			array index.
	* Returns: A pointer to the specified loader, 0 if the index is incorrect. 
	*/
	IArchiveLoader getArchiveLoader(uint index) const;

	/// Adds a zip archive to the file system.
	/** 
	* Deprecated: This function is provided for compatibility
	*				with older versions of Irrlicht and may be removed in Irrlicht 1.9,
	*				you should use addFileArchive instead.
	* After calling this, the Irrlicht Engine will search and open files directly from this archive too.
	* This is useful for hiding data from the end user, speeding up file access and making it possible to
	* access for example Quake3 .pk3 files, which are no different than .zip files.
	* Params:
	*	filename= Filename of the zip archive to add to the file system.
	*	ignoreCase= If set to true, files in the archive can be accessed without
	*				writing all letters in the right case.
	*	ignorePaths= If set to true, files in the added archive can be accessed
	*					without its complete path.
	* Returns: True if the archive was added successfully, false if not. 
	*/
	deprecated final bool addZipFileArchive(string filename, bool ignoreCase=true, bool ignorePaths=true)
	{
		static IFileArchive arch;
		return addFileArchive(filename, arch, ignoreCase, ignorePaths, E_FILE_ARCHIVE_TYPE.EFAT_ZIP);
	}

	/// Adds an unzipped archive (or basedirectory with subdirectories..) to the file system.
	/** 
	* Deprecated: This function is provided for compatibility
	*				with older versions of Irrlicht and may be removed in Irrlicht 1.9,
	*				you should use addFileArchive instead.
	*				Useful for handling data which will be in a zip file
	* Params:
	*	filename= Filename of the unzipped zip archive base directory to add to the file system.
	*	ignoreCase= If set to true, files in the archive can be accessed without
	*				writing all letters in the right case.
	*	ignorePaths= If set to true, files in the added archive can be accessed
	*					without its complete path.
	* Returns: True if the archive was added successful, false if not. 
	*/
	deprecated final bool addFolderFileArchive(string filename, bool ignoreCase=true, bool ignorePaths=true)
	{
		static IFileArchive arch;
		return addFileArchive(filename, arch, ignoreCase, ignorePaths, E_FILE_ARCHIVE_TYPE.EFAT_FOLDER);
	}

	/// Adds a pak archive to the file system.
	/** 
	* Deprecated: This function is provided for compatibility
	*				with older versions of Irrlicht and may be removed in Irrlicht 1.9,
	*				you should use addFileArchive instead.
	* After calling this, the Irrlicht Engine will search and open files directly from this archive too.
	* This is useful for hiding data from the end user, speeding up file access and making it possible to
	* access for example Quake2/KingPin/Hexen2 .pak files
	*
	* Params:
	*	filename = 		Filename of the pak archive to add to the file system.
	*	ignoreCase = 	If set to true, files in the archive can be accessed without
	*					writing all letters in the right case.
	*	ignorePaths = 	If set to true, files in the added archive can be accessed
	*					without its complete path.(should not use with Quake2 paks
	* Returns: True if the archive was added successful, false if not. 
	*/
	deprecated final bool addPakFileArchive(string filename, bool ignoreCase=true, bool ignorePaths=true)
	{
		static IFileArchive arch;
		return addFileArchive(filename, arch, ignoreCase, ignorePaths, E_FILE_ARCHIVE_TYPE.EFAT_PAK);
	}

	/// Get the current working directory.
	/** 
	* Returns: Current working directory as a string. 
	*/
	const Path getWorkingDirectory();

	/// Changes the current working directory.
	/** 
	* Params:
	*	newDirectory =	A string specifying the new working directory.
	* The string is operating system dependent. Under Windows it has
	* the form "<drive>:\<directory>\<sudirectory>\<..>". An example would be: "C:\Windows\"
	* Returns: True if successful, otherwise false. 
	*/
	bool changeWorkingDirectoryTo(const Path newDirectory);

	/// Converts a relative path to an absolute (unique) path, resolving symbolic links if required
	/**
	* Params:
	*	filename= Possibly relative file or directory name to query.
	* Results: Absolute filename which points to the same file. 
	*/
	Path getAbsolutePath(const Path filename) const;

	/// Get the directory a file is located in.
	/** 
	* Params:
	*	filename= The file to get the directory from.
	* Returns: String containing the directory of the file. 
	*/
	Path getFileDir(const Path filename) const;

	/// Get the base part of a filename, i.e. the name without the directory part.
	/** 
	* If no directory is prefixed, the full name is returned.
	* Params:
	*	filename= The file to get the basename from
	*	keepExtension= True if filename with extension is returned otherwise everything
	*					after the final '.' is removed as well. 
	*/
	Path getFileBasename(const Path filename, bool keepExtension=true) const;

	/// flatten a path and file name for example: "/you/me/../." becomes "/you"
	Path flattenFilename(Path directory, const Path root="/");

	/// Get the relative filename, relative to the given directory
	Path getRelativeFilename(const Path filename, const Path directory) const;

	/// Creates a list of files and directories in the current working directory and returns it.
	/** 
	* Returns: a Pointer to the created IFileList is returned. 
	*/
	IFileList createFileList();

	/// Creates an empty filelist
	/** 
	* Returns: a Pointer to the created IFileList is returned. 
	*/
	IFileList createEmptyFileList(const Path path, bool ignoreCase, bool ignorePaths);

	/// Set the active type of file system.
	EFileSystemType setFileListSystem(EFileSystemType listType);

	/// Determines if a file exists and could be opened.
	/**
	* Params:
	*	filename= is the string identifying the file which should be tested for existence.
	* Returns: True if file exists, and false if it does not exist or an error occured. 
	*/
	bool existFile(const Path filename) const;

	/// Creates a XML Reader from a file which returns all parsed strings as wide characters (wchar_t*).
	/** 
	* Use createXMLReaderUTF8() if you prefer char* instead of wchar_t*. See IIrrXMLReader for
	* more information on how to use the parser.
	* Returns: 0, if file could not be opened, otherwise a pointer to the created
	* IXMLReader is returned.  
	*/
	IXMLReader createXMLReader(const Path filename);

	/// Creates a XML Reader from a file which returns all parsed strings as wide characters (wchar_t*).
	/** 
	* Use createXMLReaderUTF8() if you prefer char* instead of wchar_t*. See IIrrXMLReader for
	* more information on how to use the parser.
	* Returns: 0, if file could not be opened, otherwise a pointer to the created
	*			IXMLReader is returned. 
	*/
	IXMLReader createXMLReader(IReadFile file);

	/// Creates a XML Reader from a file which returns all parsed strings as ASCII/UTF-8 characters (char*).
	/** 
	* Use createXMLReader() if you prefer wchar_t* instead of char*. See IIrrXMLReader for
	* more information on how to use the parser.
	* Returns: 0, if file could not be opened, otherwise a pointer to the created
	*			IXMLReader is returned.  
	*/
	IXMLReaderUTF8 createXMLReaderUTF8(const Path filename);

	/// Creates a XML Reader from a file which returns all parsed strings as ASCII/UTF-8 characters (char*).
	/** 
	* Use createXMLReader() if you prefer wchar_t* instead of char*. See IIrrXMLReader for
	* more information on how to use the parser.
	* Returns: 0, if file could not be opened, otherwise a pointer to the created
	* IXMLReader is returned. 
	*/
	IXMLReaderUTF8 createXMLReaderUTF8(IReadFile file);

	/// Creates a XML Writer from a file.
	/** 
	* Returns: 0, if file could not be opened, otherwise a pointer to the created
	*			IXMLWriter is returned. 
	*/
	IXMLWriter createXMLWriter(const Path filename);

	/// Creates a XML Writer from a file.
	/** 
	* Returns: 0, if file could not be opened, otherwise a pointer to the created
	*			IXMLWriter is returned.  
	*/
	IXMLWriter createXMLWriter(IWriteFile file);

	// Creates a new empty collection of attributes, usable for serialization and more.
	/** 
	* Params:
	*	driver= Video driver to be used to load textures when specified as attribute values.
	*			Can be null to prevent automatic texture loading by attributes.
	* Returns: Pointer to the created object. 
	*/
	IAttributes createEmptyAttributes(IVideoDriver driver=null);
}