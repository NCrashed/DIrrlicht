module irrlicht.io.IFileList;

//import irrlicht.IReferenceCounted;
import irrlicht.io.path;

/// Provides a list of files and folders.
/** 
* File lists usually contain a list of all files in a given folder,
* but can also contain a complete directory structure. 
*/
interface IFileList //: IReferenceCounted
{
	public
	{
		/// Get the number of files in the filelist.
		/** 
		* Returns:
		* Amount of files and directories in the file list. 
		*/
		uint getFileCount();

		/// Gets the name of a file in the list, based on an index.
		/** 
		* The path is not included in this name. Use getFullFileName for this.
		* Params:
		* index 	is the zero based index of the file which name should
		* be returned. The index must be less than the amount getFileCount() returns.
		* 
		* Returns: File name of the file. Returns 0, if an error occured. 
		*/
		const Path getFileName(uint index);

		/// Gets the full name of a file in the list including the path, based on an index.
		/** 
		* Params:
		* index 	is the zero based index of the file which name should
		* be returned. The index must be less than the amount getFileCount() returns.
		*
		* Returns: File name of the file. Returns 0 if an error occured. 
		*/
		const Path getFullFileName(uint index);

		/// Returns the size of a file in the file list, based on an index.
		/**
		* Params:
		* index 	is the zero based index of the file which should be returned.
		* The index must be less than the amount getFileCount() returns.
		*
		* Returns: The size of the file in bytes.
		*/
		uint getFileSize(uint index);

		/// Returns the file offset of a file in the file list, based on an index.
		/**
		* Params:
		* index 	is the zero based index of the file which should be returned.
		* The index must be less than the amount getFileCount() returns.
		*
		* Returns: The offset of the file in bytes.
		*/
		uint getFileOffset(uint index);

		/// Returns the ID of a file in the file list, based on an index.
		/** 
		* This optional ID can be used to link the file list entry to information held
		* elsewhere. For example this could be an index in an IFileArchive, linking the entry
		* to its data offset, uncompressed size and CRC.
		* Params:
		* index 	is the zero based index of the file which should be returned.
		* The index must be less than the amount getFileCount() returns.
		*
		* Returns: The ID of the file. 
		*/
		uint getID(uint index);

		/// Check if the file is a directory
		/**
		* Params:
		* index 	The zero based index which will be checked. The index
		* must be less than the amount getFileCount() returns.
		* 
		* Returns: True if the file is a directory, else false. 
		*/
		bool isDirectory(uint index);

		/// Searches for a file or folder in the list
		/** 
		* Searches for a file by name
		* Params:
		* filename 		The name of the file to search for.
		* isFolder 		True if you are searching for a directory path, false if you are searching for a file
		*
		* Returns: the index of the file in the file list, or -1 if
		* no matching name name was found. 
		*/
		int findFile(const Path filename, bool isFolder = false);

		/// Returns the base path of the file list
		const Path getPath();

		/// Add as a file or folder to the list
		/**
		* Params: 
		* fullPath 		The file name including path, from the root of the file list.
		* isDirectory 	True if this is a directory rather than a file.
		* offset 		The file offset inside an archive
		* size 			The size of the file in bytes.
		* id 			The ID of the file in the archive which owns it 
		*/
		uint addItem(const Path fullPath, uint offset, uint size, bool isDirectory, uint id = 0);
	
		/// Sorts the file list. You should call this after adding any items to the file list
		void sort();
	}
}