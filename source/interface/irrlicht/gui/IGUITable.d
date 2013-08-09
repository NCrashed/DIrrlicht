// Copyright (C) 2003-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.gui.IGUITable;

import irrlicht.gui.IGUIElement;
import irrlicht.gui.EGUIElementTypes;
import irrlicht.gui.IGUISkin;
import irrlicht.video.SColor;
import irrlicht.core.rect;

/// modes for ordering used when a column header is clicked
enum EGUI_COLUMN_ORDERING
{
	/// Do not use ordering
	EGCO_NONE,

	/// Send a EGET_TABLE_HEADER_CHANGED message when a column header is clicked.
	EGCO_CUSTOM,

	/// Sort it ascending by it's ascii value like: a,b,c,...
	EGCO_ASCENDING,

	/// Sort it descending by it's ascii value like: z,x,y,...
	EGCO_DESCENDING,

	/// Sort it ascending on first click, descending on next, etc
	EGCO_FLIP_ASCENDING_DESCENDING,

	/// Not used as mode, only to get maximum value for this enum
	EGCO_COUNT
}

/// Names for EGUI_COLUMN_ORDERING types
immutable(string[]) GUIColumnOrderingNames =
[
	"none",
	"custom",
	"ascend",
	"descend",
	"ascend_descend",
];

enum EGUI_ORDERING_MODE
{
	/// No element ordering
	EGOM_NONE,

	/// Elements are ordered from the smallest to the largest.
	EGOM_ASCENDING,

	/// Elements are ordered from the largest to the smallest.
	EGOM_DESCENDING,

	/// this value is not used, it only specifies the amount of default ordering types
	/// available.
	EGOM_COUNT
}

immutable(string[]) GUIOrderingModeNames =
[
	"none",
	"ascending",
	"descending",
];

enum EGUI_TABLE_DRAW_FLAGS
{
	EGTDF_ROWS = 1,
	EGTDF_COLUMNS = 2,
	EGTDF_ACTIVE_ROW = 4,
	EGTDF_COUNT
}

/// Default list box GUI element.
/**
* \par This element can create the following events of type EGUI_EVENT_TYPE:
* \li EGET_TABLE_CHANGED
* \li EGET_TABLE_SELECTED_AGAIN
* \li EGET_TABLE_HEADER_CHANGED
*/
abstract class IGUITable : IGUIElement
{
	/// constructor
	this()(IGUIEnvironment environment, IGUIElement parent, size_t id, auto ref const rect!int rectangle)
	{
		super(EGUI_ELEMENT_TYPE.EGUIET_TABLE, environment, parent, id, rectangle);
	}

	/// Adds a column
	/**
	* If columnIndex is outside the current range, do push new colum at the end 
	*/
	void addColumn(wstring caption, ptrdiff_t columnIndex=-1);

	/// remove a column from the table
	void removeColumn(size_t columnIndex);

	/// Returns the number of columns in the table control
	size_t getColumnCount() const;

	/// Makes a column active. This will trigger an ordering process.
	/**
	* Params:
	* 	idx=  The id of the column to make active.
	* 	doOrder=  Do also the ordering which depending on mode for active column
	* Returns: True if successful. 
	*/
	bool setActiveColumn(size_t idx, bool doOrder=false);

	/// Returns which header is currently active
	ptrdiff_t getActiveColumn() const;

	/// Returns the ordering used by the currently active column
	EGUI_ORDERING_MODE getActiveColumnOrdering() const;

	/// Set the width of a column
	void setColumnWidth(size_t columnIndex, uint width);

	/// Get the width of a column
	uint getColumnWidth(size_t columnIndex) const;

	/// columns can be resized by drag 'n drop
	void setResizableColumns(bool resizable);

	/// can columns be resized by dran 'n drop?
	bool hasResizableColumns() const;

	/// This tells the table control which ordering mode should be used when a column header is clicked.
	/**
	* Params:
	* 	columnIndex=  The index of the column header.
	* 	mode=  One of the modes defined in EGUI_COLUMN_ORDERING 
	*/
	void setColumnOrdering(size_t columnIndex, EGUI_COLUMN_ORDERING mode);

	/// Returns which row is currently selected
	ptrdiff_t getSelected() const;

	/// set wich row is currently selected
	void setSelected( ptrdiff_t index );

	/// Get amount of rows in the tabcontrol
	size_t getRowCount() const;

	/// adds a row to the table
	/**
	* Params:
	* 	rowIndex=  Zero based index of rows. The row will be
	* inserted at this position, if a row already exist there, it
	* will be placed after it. If the row is larger than the actual
	* number of row by more than one, it won't be created.  Note that
	* if you create a row that's not at the end, there might be
	* performance issues.
	* Returns: index of inserted row. 
	*/
	size_t addRow(size_t rowIndex);

	/// Remove a row from the table
	void removeRow(size_t rowIndex);

	/// clears the table rows, but keeps the columns intact
	void clearRows();

	/// Swap two row positions.
	void swapRows(size_t rowIndexA, size_t rowIndexB);

	/// This tells the table to start ordering all the rows.
	/**
	* You need to explicitly tell the table to re order the rows
	* when a new row is added or the cells data is changed. This
	* makes the system more flexible and doesn't make you pay the
	* cost of ordering when adding a lot of rows.
	* Params:
	* 	columnIndex=  When set to -1 the active column is used.
	* 	mode=  Ordering mode of the rows. 
	*/
	void orderRows(ptrdiff_t columnIndex=-1, EGUI_ORDERING_MODE mode=EGUI_ORDERING_MODE.EGOM_NONE);

	/// Set the text of a cell
	void setCellText(size_t rowIndex, size_t columnIndex, wstring text);

	/// Set the text of a cell, and set a color of this cell.
	void setCellText(size_t rowIndex, size_t columnIndex, wstring text, SColor color);

	/// Set the data of a cell
	void setCellData(size_t rowIndex, size_t columnIndex, void* data);

	/// Set the color of a cell text
	void setCellColor(size_t rowIndex, size_t columnIndex, SColor color);

	/// Get the text of a cell
	wstring getCellText(size_t rowIndex, size_t columnIndex ) const;

	/// Get the data of a cell
	void* getCellData(size_t rowIndex, size_t columnIndex ) const;

	/// clears the table, deletes all items in the table
	void clear();

	/// Set flags, as defined in EGUI_TABLE_DRAW_FLAGS, which influence the layout
	void setDrawFlags(int flags);

	/// Get the flags, as defined in EGUI_TABLE_DRAW_FLAGS, which influence the layout
	int getDrawFlags() const;
}
