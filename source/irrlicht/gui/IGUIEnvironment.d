module irrlicht.gui.IGUIEnvironment;

import irrlicht.gui.IGUIElement;
import irrlicht.gui.IGUISkin;
import irrlicht.gui.IGUIImageList;
import irrlicht.gui.IGUIFont;
import irrlicht.gui.IGUISpriteBank;
import irrlicht.gui.IGUIButton;
import irrlicht.gui.IGUIWindow;
import irrlicht.gui.IGUIImage;
import irrlicht.gui.IGUICheckBox;
import irrlicht.gui.IGUIListBox;
import irrlicht.gui.EMessageBoxFlags;
import irrlicht.gui.IGUIScrollBar;
import irrlicht.gui.IGUITreeView;
import irrlicht.gui.IGUIMeshViewer;
import irrlicht.gui.IGUIFileOpenDialog;
import irrlicht.gui.IGUIColorSelectDialog;
import irrlicht.gui.IGUIStaticText;
import irrlicht.gui.IGUIEditBox;
import irrlicht.gui.IGUISpinBox;
import irrlicht.gui.IGUIInOutFader;
import irrlicht.gui.IGUITabControl;
import irrlicht.gui.IGUITab;
import irrlicht.gui.IGUIContextMenu;
import irrlicht.gui.IGUIToolBar;
import irrlicht.gui.IGUIComboBox;
import irrlicht.gui.IGUITable;
import irrlicht.gui.IGUIElementFactory;
import irrlicht.video.IVideoDriver;
import irrlicht.video.ITexture;
import irrlicht.io.IFileSystem;
import irrlicht.io.path;
import irrlicht.io.IWriteFile;
import irrlicht.io.IReadFile;
import irrlicht.io.IAttributes;
import irrlicht.io.IAttributeExchangingObject;
import irrlicht.io.IXMLWriter;
import irrlicht.IOSOperator;
import irrlicht.IEventReceiver;
import irrlicht.core.rect;

/// GUI Environment. Used as factory and manager of all other GUI elements.
/** 
*\par This element can create the following events of type EGUI_EVENT_TYPE (which are passed on to focused sub-elements):
*<li> EGET_ELEMENT_FOCUS_LOST</li>
*<li> EGET_ELEMENT_FOCUSED</li>
*<li> EGET_ELEMENT_LEFT</li>
*<li> EGET_ELEMENT_HOVERED</li>
*/
interface IGUIEnvironment
{
	//// Draws all gui elements by traversing the GUI environment starting at the root node.
	void drawAll();

	/// Sets the focus to an element.
	/** 
	*Causes a EGET_ELEMENT_FOCUS_LOST event followed by a
	*EGET_ELEMENT_FOCUSED event. If someone absorbed either of the events,
	*then the focus will not be changed.
	*Params:
	*	element= Pointer to the element which shall get the focus.
	*Returns: True on success, false on failure 
	*/
	bool setFocus(IGUIElement element);

	/// Returns the element which holds the focus.
	/** 
	*Returns: Pointer to the element with focus. 
	*/
	IGUIElement getFocus() const;

	/// Returns the element which was last under the mouse cursor
	/** 
	*NOTE: This information is updated _after_ the user-eventreceiver 
	*received it's mouse-events. To find the hovered element while catching 
	*mouse events you have to use instead:
	*IGUIEnvironment.getRootGUIElement().getElementFromPoint(mousePos);
	*Returns: Pointer to the element under the mouse. 
	*/
	IGUIElement getHovered() const;

	/// Removes the focus from an element.
	/** 
	*Causes a EGET_ELEMENT_FOCUS_LOST event. If the event is absorbed
	*then the focus will not be changed.
	*Params:
	*	element= Pointer to the element which shall lose the focus.
	*Returns: True on success, false on failure 
	*/
	bool removeFocus(IGUIElement element);

	/// Returns whether the element has focus
	/** 
	*Params:
	*	element Pointer to the element which is tested.
	*Returns: True if the element has focus, else false. 
	*/
	bool hasFocus(IGUIElement element) const;

	/// Returns the current video driver.
	/** 
	*Returns: Pointer to the video driver. 
	*/
	IVideoDriver getVideoDriver() const;

	/// Returns the file system.
	/** 
	*Returns: Pointer to the file system. 
	*/
	IFileSystem getFileSystem() const;

	/// returns a pointer to the OS operator
	/** 
	*Returns: Pointer to the OS operator. 
	*/
	IOSOperator getOSOperator() const;

	/// Removes all elements from the environment.
	void clear();

	/// Posts an input event to the environment.
	/** 
	*Usually you do not have to
	*use this method, it is used by the engine internally.
	*Params:
	*	event= The event to post.
	*Returns: True if succeeded, else false. 
	*/
	bool postEventFromUser(const SEvent event);

	/// This sets a new event receiver for gui events.
	/** 
	*Usually you do not have to
	*use this method, it is used by the engine internally.
	*Params: 
	*	evr= Pointer to the new receiver. 
	*/
	void setUserEventReceiver(IEventReceiver evr);

	/// Returns pointer to the current gui skin.
	/** 
	*Returns: Pointer to the GUI skin. 
	*/
	IGUISkin getSkin() const;

	/// Sets a new GUI Skin
	/** 
	*You can use this to change the appearance of the whole GUI
	*Environment. You can set one of the built-in skins or implement your
	*own class derived from IGUISkin and enable it using this method.
	*To set for example the built-in Windows classic skin, use the following
	*code:
	*Examples:
	*------
	*IGUISkin newskin = environment.createSkin(gui::EGST_WINDOWS_CLASSIC);
	*environment->setSkin(newskin);
	*newskin->drop();
	*------
	*Params:
	*	skin= New skin to use.
	*/
	void setSkin(IGUISkin skin);

	/// Creates a new GUI Skin based on a template.
	/** 
	*Use setSkin() to set the created skin.
	*Params:
	*	type= The type of the new skin.
	*Returns: Pointer to the created skin.
	*If you no longer need it, you should call IGUISkin::drop().
	*See_Also:
	*	IReferenceCounted.drop() for more information. 
	*/
	IGUISkin createSkin(EGUI_SKIN_TYPE type);

	/// Creates the image list from the given texture.
	/**
	*Params: 
	*	texture= Texture to split into images
	*	imageSize= Dimension of each image
	*	useAlphaChannel= Flag whether alpha channel of the texture should be honored.
	*Returns: Pointer to the font. Returns 0 if the font could not be loaded.
	*This pointer should not be dropped. 
	*See_Also:
	*	IReferenceCounted::drop() for more information. 
	*/
	IGUIImageList createImageList( ITexture texture,
					dimension2d!int imageSize,
					bool useAlphaChannel );

	/// Returns pointer to the font with the specified filename.
	/** 
	*Loads the font if it was not loaded before.
	*Params:
	*	filename= Filename of the Font.
	*Returns: Pointer to the font. Returns 0 if the font could not be loaded.
	*This pointer should not be dropped. See IReferenceCounted::drop() for
	*more information. 
	*/
	IGUIFont getFont(const Path filename);

	/// Adds an externally loaded font to the font list.
	/** 
	*This method allows to attach an already loaded font to the list of
	*existing fonts. The font is grabbed if non-null and adding was successful.
	*Params:
	*	name= Name the font should be stored as.
	*	font= Pointer to font to add.
	*Returns: Pointer to the font stored. This can differ from given parameter if the name previously existed. 
	*/
	IGUIFont addFont(const Path name, IGUIFont font);

	/// remove loaded font
	void removeFont(IGUIFont font);

	/// Returns the default built-in font.
	/** 
	*Returns: Pointer to the default built-in font.
	*This pointer should not be dropped. See IReferenceCounted::drop() for
	*more information. 
	*/
	IGUIFont getBuiltInFont() const;

	/// Returns pointer to the sprite bank with the specified file name.
	/** 
	*Loads the bank if it was not loaded before.
	*Params:
	*	filename= Filename of the sprite bank's origin.
	*Returns: Pointer to the sprite bank. Returns 0 if it could not be loaded.
	*This pointer should not be dropped. 
	*See_Also: 
	*	IReferenceCounted::drop() for more information. 
	*/
	IGUISpriteBank getSpriteBank(const Path filename);

	/// Adds an empty sprite bank to the manager
	/**
	*Params: 
	*	name= Name of the new sprite bank.
	*Returns: Pointer to the sprite bank.
	*This pointer should not be dropped. 
	*See_Also: 
	*	IReferenceCounted::drop() for more information. 
	*/
	IGUISpriteBank addEmptySpriteBank(const Path name);

	/// Returns the root gui element.
	/** 
	*This is the first gui element, the (direct or indirect) parent of all
	*other gui elements. It is a valid IGUIElement, with dimensions the same
	*size as the screen. 
	*Returns: Pointer to the root element of the GUI. The returned pointer
	*			should not be dropped. 
	*See_Also:
	*	IReferenceCounted.drop() for more information. 
	*/
	IGUIElement getRootGUIElement();

	/// Adds a button element.
	/**
	*Params: 
	*	rectangle= Rectangle specifying the borders of the button.
	*	parent= Parent gui element of the button.
	*	id= Id with which the gui element can be identified.
	*	text= Text displayed on the button.
	*	tooltiptext= Text displayed in the tooltip.
	*Returns: Pointer to the created button. Returns 0 if an error occurred.
	*			This pointer should not be dropped. 
	*See_Also: 
	*	IReferenceCounted.drop() for more information. 
	*/
	IGUIButton addButton(const ref rect!int rectangle,
		IGUIElement parent=null, int id=-1, string text="", string tooltiptext ="");

	/// Adds an empty window element.
	/**
	*Params: 
	*	rectangle= Rectangle specifying the borders of the window.
	*	modal= Defines if the dialog is modal. This means, that all other
	*			gui elements which were created before the window cannot be used until
	*			it is removed.
	*	text= Text displayed as the window title.
	*	parent= Parent gui element of the window.
	*	id= Id with which the gui element can be identified.
	*Returns: Pointer to the created window. Returns 0 if an error occurred.
	*			This pointer should not be dropped. 
	*See_Also:
	*	IReferenceCounted.drop() for more information. 
	*/
	IGUIWindow addWindow(const ref rect!int rectangle, bool modal = false,
		const string text="", IGUIElement parent=null, int id=-1);

	/// Adds a modal screen.
	/**
	*This control stops its parent's members from being able to receive
	*input until its last child is removed, it then deletes itself.
	*Params:
	*	parent= Parent gui element of the modal.
	*Returns: Pointer to the created modal. Returns 0 if an error occurred.
	*			This pointer should not be dropped. 
	*See_Also:
	*	IReferenceCounted.drop() for more information. 
	*/
	IGUIElement addModalScreen(IGUIElement parent);

	/// Adds a message box.
	/**
	*Params: 
	*	caption= Text to be displayed the title of the message box.
	*	text= Text to be displayed in the body of the message box.
	*	modal= Defines if the dialog is modal. This means, that all other
	*			gui elements which were created before the message box cannot be used
	*			until this messagebox is removed.
	*	flags= Flags specifying the layout of the message box. For example
	*			to create a message box with an OK and a CANCEL button on it, set this
	*			to (EMBF_OK | EMBF_CANCEL).
	*	parent= Parent gui element of the message box.
	*	id= Id with which the gui element can be identified.
	*	image= Optional texture which will be displayed beside the text as an image
	*Returns: Pointer to the created message box. Returns 0 if an error
	*			occurred. This pointer should not be dropped. 
	*See_Also:
	*	IReferenceCounted::drop() for more information. 
	*/
	IGUIWindow addMessageBox(const string caption, const string text="",
		bool modal = true, int flags = EMBF_OK, IGUIElement parent = null, int id = -1, ITexture image = null);

	/// Adds a scrollbar.
	/** 
	*Params:
	*	horizontal= Specifies if the scroll bar is drawn horizontal
	*				or vertical.
	*	rectangle= Rectangle specifying the borders of the scrollbar.
	*	parent= Parent gui element of the scroll bar.
	*	id= Id to identify the gui element.
	*Return: Pointer to the created scrollbar. Returns 0 if an error
	*			occurred. This pointer should not be dropped. 
	*See_Also:
	*	IReferenceCounted.drop() for more information. 
	*/
	IGUIScrollBar addScrollBar(bool horizontal, const ref rect!int rectangle,
		IGUIElement parent = null, int id = -1);

	/// Adds an image element.
	/** 
	*Params:
	*	image= Image to be displayed.
	*	pos= Position of the image. The width and height of the image is
	*			taken from the image.
	*	useAlphaChannel= Sets if the image should use the alpha channel
	*						of the texture to draw itself.
	*	parent= Parent gui element of the image.
	*	id= Id to identify the gui element.
	*	text= Title text of the image.
	*Returns: Pointer to the created image element. Returns 0 if an error
	*occurred. This pointer should not be dropped. 
	*See_Also:
	*	IReferenceCounted.drop() for more information. 
	*/
	IGUIImage addImage(ITexture image, position2d!int pos,
		bool useAlphaChannel = true, IGUIElement parent = null, int id = -1, const string text="");

	/// Adds an image element.
	/** 
	*Use IGUIImage.setImage later to set the image to be displayed.
	*Params:
	*	rectangle= Rectangle specifying the borders of the image.
	*	parent= Parent gui element of the image.
	*	id= Id to identify the gui element.
	*	text= Title text of the image.
	*	useAlphaChannel= Sets if the image should use the alpha channel
	*						of the texture to draw itself.
	*Returna: Pointer to the created image element. Returns 0 if an error
	*			occurred. This pointer should not be dropped. 
	*See_Also:
	*	IReferenceCounted.drop() for more information. 
	*/
	IGUIImage addImage(const  ref rect!int rectangle,
		IGUIElement parent = null, int id = -1, const string text="", bool useAlphaChannel = true);

	/// Adds a checkbox element.
	/**
	*Params: 
	*	checked= Define the initial state of the check box.
	*	rectangle= Rectangle specifying the borders of the check box.
	*	parent= Parent gui element of the check box.
	*	id= Id to identify the gui element.
	*	text= Title text of the check box.
	*Returns: Pointer to the created check box. Returns 0 if an error
	*			occurred. This pointer should not be dropped. 
	*See_Also:
	*	IReferenceCounted.drop() for more information. 
	*/
	IGUICheckBox addCheckBox(bool checked, const ref rect!int rectangle,
		IGUIElement parent = null, int id = -1, const string text = "");

	/// Adds a list box element.
	/** 
	*Params:
	*	rectangle= Rectangle specifying the borders of the list box.
	*	parent= Parent gui element of the list box.
	*	id= Id to identify the gui element.
	*	drawBackground= Flag whether the background should be drawn.
	*Returns: Pointer to the created list box. Returns 0 if an error occurred.
	*This pointer should not be dropped. 
	*See_Also:
	*	IReferenceCounted.drop() for more information. 
	*/
	IGUIListBox addListBox(const ref rect!int rectangle,
		IGUIElement parent = null, int id = -1, bool drawBackground = false);

	/// Adds a tree view element.
	/**
	*Params: 
	*	rectangle= Position and dimension of list box.
	*	parent= Parent gui element of the list box.
	*	id= Id to identify the gui element.
	*	drawBackground= Flag whether the background should be drawn.
	*	scrollBarVertical= Flag whether a vertical scrollbar should be used
	*	scrollBarHorizontal= Flag whether a horizontal scrollbar should be used
	*Returns: Pointer to the created list box. Returns 0 if an error occurred.
	*This pointer should not be dropped. 
	*See_Also:
	*	IReferenceCounted.drop() for more information. 
	*/
	IGUITreeView addTreeView(const ref rect!int rectangle,
		IGUIElement parent = null, int id = -1, bool drawBackground = false,
		bool scrollBarVertical = true, bool scrollBarHorizontal = false);

	/// Adds a mesh viewer. Not 100% implemented yet.
	/** 
	*Params:
	*	rectangle= Rectangle specifying the borders of the mesh viewer.
	*	parent= Parent gui element of the mesh viewer.
	*	id= Id to identify the gui element.
	*	text= Title text of the mesh viewer.
	*Returns: Pointer to the created mesh viewer. Returns 0 if an error
	*occurred. This pointer should not be dropped. 
	*See_Also:
	*	IReferenceCounted.drop() for more information. 
	*/
	IGUIMeshViewer addMeshViewer(const ref rect!int rectangle,
			IGUIElement parent = null, int id = -1, const string text = "");

	/// Adds a file open dialog.
	/**
	*Params: 
	*	title= Text to be displayed as the title of the dialog.
	*	modal= Defines if the dialog is modal. This means, that all other
	*			gui elements which were created before the message box cannot be used
	*			until this messagebox is removed.
	*	parent= Parent gui element of the dialog.
	*	id= Id to identify the gui element.
	*	restoreCWD= If set to true, the current workingn directory will be
	*				restored after the dialog is closed in some way. Otherwise the working
	*				directory will be the one that the file dialog was last showing.
	*	startDir= Optional path for which the file dialog will be opened.
	*Returns: Pointer to the created file open dialog. Returns 0 if an error
	*occurred. This pointer should not be dropped. 
	*See_Also:
	*	IReferenceCounted.drop() for more information. 
	*/
	IGUIFileOpenDialog addFileOpenDialog(const string title = "",
		bool modal = true, IGUIElement parent = null, int id = -1,
		bool restoreCWD = false, Path startDir = "");

	/// Adds a color select dialog.
	/**
	*Params: 
	*	title= The title of the dialog.
	*	modal= Defines if the dialog is modal. This means, that all other
	*			gui elements which were created before the dialog cannot be used
	*			until it is removed.
	*	parent= The parent of the dialog.
	*	id= The ID of the dialog.
	*Returns: Pointer to the created file open dialog. Returns 0 if an error
	*occurred. This pointer should not be dropped. 
	*See_Also:
	*	IReferenceCounted.drop() for more information. 
	*/
	IGUIColorSelectDialog addColorSelectDialog(const string title = "",
		bool modal = true, IGUIElement parent = null, int id = -1);

	/// Adds a static text.
	/**
	*Params: 
	*	text= Text to be displayed. Can be altered after creation by SetText().
	*	rectangle= Rectangle specifying the borders of the static text
	*	border= Set to true if the static text should have a 3d border.
	*	wordWrap= Enable if the text should wrap into multiple lines.
	*	parent= Parent item of the element, e.g. a window.
	*	id= The ID of the element.
	*	fillBackground= Enable if the background shall be filled.
	*					Defaults to false.
	*Returns: Pointer to the created static text. Returns 0 if an error
	*occurred. This pointer should not be dropped. 
	*See_Also:
	*	IReferenceCounted.drop() for more information. 
	*/
	IGUIStaticText addStaticText(const string text, const ref rect!int rectangle,
		bool border = false, bool wordWrap = true, IGUIElement parent = null, int id = -1,
		bool fillBackground = false);

	/// Adds an edit box.
	/** 
	*Supports unicode input from every keyboard around the world,
	*scrolling, copying and pasting (exchanging data with the clipboard
	*directly), maximum character amount, marking, and all shortcuts like
	*ctrl+X, ctrl+V, ctrl+C, shift+Left, shift+Right, Home, End, and so on.
	*Params:
	*	text= Text to be displayed. Can be altered after creation
	*			by setText().
	*	rectangle= Rectangle specifying the borders of the edit box.
	*	border= Set to true if the edit box should have a 3d border.
	*	parent= Parent item of the element, e.g. a window.
	*			Set it to 0 to place the edit box directly in the environment.
	*	id= The ID of the element.
	*Returns: Pointer to the created edit box. Returns null if an error occurred.
	*This pointer should not be dropped. 
	*See_Also: 
	*	IReferenceCounted.drop() for more information. 
	*/
	IGUIEditBox addEditBox(const string text, const ref rect!int rectangle,
		bool border = true, IGUIElement parent = null, int id = -1);

	/// Adds a spin box.
	/** 
	*An edit box with up and down buttons
	*Params:
	*	text= Text to be displayed. Can be altered after creation by setText().
	*	rectangle= Rectangle specifying the borders of the spin box.
	*	border= Set to true if the spin box should have a 3d border.
	*	parent= Parent item of the element, e.g. a window.
	*			Set it to null to place the spin box directly in the environment.
	*	id= The ID of the element.
	*Returns: Pointer to the created spin box. Returns 0 if an error occurred.
	*This pointer should not be dropped. 
	*See_Also:
	*	IReferenceCounted::drop() for more information. 
	*/
	IGUISpinBox addSpinBox(const string text, const ref rect!int rectangle,
		bool border = true, IGUIElement parent = null, int id = -1);

	/// Adds an element for fading in or out.
	/**
	*Params:
	*	rectangle= Rectangle specifying the borders of the fader.
	*				If the pointer is NULL, the whole screen is used.
	*	parent= Parent item of the element, e.g. a window.
	*	id= An identifier for the fader.
	*Returns: Pointer to the created in-out-fader. Returns 0 if an error
	*occurred. This pointer should not be dropped. 
	*See_Also:
	*	IReferenceCounted.drop() for more information. 
	*/
	IGUIInOutFader addInOutFader(const ref rect!int rectangle = null, IGUIElement parent = null, int id = -1);

	/// Adds a tab control to the environment.
	/** 
	*Params:
	*	rectangle= Rectangle specifying the borders of the tab control.
	*	parent= Parent item of the element, e.g. a window.
	*			Set it to 0 to place the tab control directly in the environment.
	*			fillbackground Specifies if the background of the tab control
	*			should be drawn.
	*	border= Specifies if a flat 3d border should be drawn. This is
	*			usually not necessary unless you place the control directly into
	*			the environment without a window as parent.
	*	id= An identifier for the tab control.
	*Returns: Pointer to the created tab control element. Returns 0 if an
	*error occurred. This pointer should not be dropped. 
	*See_Also:
	*	IReferenceCounted.drop() for more information. 
	*/
	IGUITabControl addTabControl(const ref rect!int rectangle,
		IGUIElement parent = null, bool fillbackground = false,
		bool border = true, int id = -1);

	/// Adds tab to the environment.
	/** 
	*You can use this element to group other elements. This is not used
	*for creating tabs on tab controls, please use IGUITabControl::addTab()
	*for this instead.
	*Params:
	*	rectangle= Rectangle specifying the borders of the tab.
	*	parent= Parent item of the element, e.g. a window.
	*			Set it to null to place the tab directly in the environment.
	*	id= An identifier for the tab.
	*Returns: Pointer to the created tab. Returns 0 if an
	*			error occurred. This pointer should not be dropped. 
	*See_Also:
	*	IReferenceCounted.drop() for more information. 
	*/
	IGUITab addTab(const ref rect!int rectangle,
		IGUIElement parent = null, int id = -1);

	/// Adds a context menu to the environment.
	/** 
	*Params:
	*	rectangle= Rectangle specifying the borders of the menu.
	*				Note that the menu is resizing itself based on what items you add.
	*	parent= Parent item of the element, e.g. a window.
	*			Set it to null to place the menu directly in the environment.
	*	id= An identifier for the menu.
	*Returns: Pointer to the created context menu. Returns 0 if an
	*error occurred. This pointer should not be dropped. 
	*See_Also:
	*	IReferenceCounted.drop() for more information. 
	*/
	IGUIContextMenu* addContextMenu(const ref rect!int rectangle,
		IGUIElement parent = null, int id = -1);

	/// Adds a menu to the environment.
	/** 
	*This is like the menu you can find on top of most windows in modern
	*graphical user interfaces.
	*Params:
	*	parent= Parent item of the element, e.g. a window.
	*			Set it to 0 to place the menu directly in the environment.
	*	id= An identifier for the menu.
	*Returns: Pointer to the created menu. Returns 0 if an
	*			error occurred. This pointer should not be dropped. 
	*See_Also:
	*	IReferenceCounted.drop() for more information. 
	*/
	IGUIContextMenu addMenu(IGUIElement parent = null, int id = -1);

	/// Adds a toolbar to the environment.
	/** 
	*It is like a menu that is always placed on top of its parent, and
	*contains buttons.
	*Params:
	*	parent= Parent item of the element, e.g. a window.
	*			Set it to 0 to place the tool bar directly in the environment.
	*	id= An identifier for the tool bar.
	*Returns: Pointer to the created tool bar. Returns 0 if an
	*	error occurred. This pointer should not be dropped. 
	*See_Also:
	*	IReferenceCounted.drop() for more information. 
	*/
	IGUIToolBar addToolBar(IGUIElement parent = null, int id = -1);

	/// Adds a combo box to the environment.
	/** 
	*Params:
	*	rectangle= Rectangle specifying the borders of the combo box.
	*	parent= Parent item of the element, e.g. a window.
	*			Set it to 0 to place the combo box directly in the environment.
	*	id= An identifier for the combo box.
	*Returns: Pointer to the created combo box. Returns 0 if an
	*			error occurred. This pointer should not be dropped. 
	*See_Also:
	*	IReferenceCounted.drop() for more information. 
	*/
	IGUIComboBox addComboBox(const ref rect!int rectangle,
		IGUIElement parent = null, int id = -1);

	/// Adds a table to the environment
	/** 
	*Params:
	*	rectangle= Rectangle specifying the borders of the table.
	*	parent= Parent item of the element, e.g. a window. Set it to 0
	*			to place the element directly in the environment.
	*	id= An identifier for the table.
	*		drawBackground Flag whether the background should be drawn.
	*Returns: Pointer to the created table. Returns 0 if an error occurred.
	*			This pointer should not be dropped. 
	*See_Also: 
	*	IReferenceCounted.drop() for more information. 
	*/
	IGUITable addTable(const ref rect!int rectangle,
		IGUIElement parent = null, int id = -1, bool drawBackground = false);

	/// Get the default element factory which can create all built-in elements
	/**
	*Returns: Pointer to the factory.
	*This pointer should not be dropped. 
	*See_Also:
	*	IReferenceCounted.drop() for more information. 
	*/
	IGUIElementFactory getDefaultGUIElementFactory() const;

	/// Adds an element factory to the gui environment.
	/**
	*Use this to extend the gui environment with new element types which
	*it should be able to create automatically, for example when loading
	*data from xml files.
	*Params:
	*	factoryToAdd= Pointer to new factory. 
	*/
	void registerGUIElementFactory(IGUIElementFactory factoryToAdd);

	/// Get amount of registered gui element factories.
	/** 
	*Returns: Amount of registered gui element factories. 
	*/
	uint getRegisteredGUIElementFactoryCount();

	/// Get a gui element factory by index
	/** 
	*Params:
	*	index= Index of the factory.
	*Returns: Factory at given index, or null if no such factory exists. 
	*/
	IGUIElementFactory getGUIElementFactory(uint index) const;

	/// Adds a GUI element by its name
	/**
	*Each factory is checked if it can create an element of the given
	*name. The first match will be created.
	*Params:
	*	elementName= Name of the element to be created.
	*	parent= Parent of the new element, if not 0.
	*Returns:
	*	New GUI element, or 0 if no such element exists. 
	*/
	IGUIElement addGUIElement(const string elementName, IGUIElement parent= null);

	/// Saves the current gui into a file.
	/** 
	*Params:
	*	filename= Name of the file.
	*	start= The GUIElement to start with. Root if 0.
	*Returns: True if saving succeeded, else false. 
	*/
	bool saveGUI(const Path filename, IGUIElement start = null);

	/// Saves the current gui into a file.
	/** 
	*Params:
	*	file= The file to write to.
	*	start= The GUIElement to start with. Root if 0.
	*Returns: True if saving succeeded, else false. 
	*/
	bool saveGUI(IWriteFile file, IGUIElement start = null);

	/// Loads the gui. Note that the current gui is not cleared before.
	/** 
	*When a parent is set the elements will be added below the parent, the parent itself does not deserialize.
	*When the file contains skin-settings from the gui-environment those are always serialized into the 
	*guienvironment independent	of the parent setting.
	*Params:
	*	filename= Name of the file.
	*	parent= Parent for the loaded GUI, root if 0.
	*Returns: True if loading succeeded, else false. */
	bool loadGUI(const Path filename, IGUIElement parent = null);

	/// Loads the gui. Note that the current gui is not cleared before.
	/** 
	*When a parent is set the elements will be added below the parent, the parent itself does not deserialize.
	*When the file contains skin-settings from the gui-environment those are always serialized into the 
	*guienvironment independent	of the parent setting.
	*Params:
	*	file= The file to load from.
	*	parent= Parent for the loaded GUI, root if 0.
	*Returns: True if loading succeeded, else false. 
	*/
	bool loadGUI(IReadFile file, IGUIElement parent = null);

	/// Writes attributes of the gui environment
	void serializeAttributes(out IAttributes outAttr, SAttributeReadWriteOptions options = null) const;

	/// Reads attributes of the gui environment
	void deserializeAttributes(IAttributes inAttr, SAttributeReadWriteOptions options = null);

	/// writes an element
	void writeGUIElement(out IXMLWriter writer, IGUIElement node);

	/// reads an element
	void readGUIElement(IXMLReader reader, out IGUIElement node);
}