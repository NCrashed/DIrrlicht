// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.gui.IGUIMeshViewer;

import irrlicht.gui.IGUIElement;
import irrlicht.gui.EGUIElementTypes;
import irrlicht.video.SMaterial;
import irrlicht.scene.IAnimatedMesh;
import irrlicht.core.rect;

/// 3d mesh viewing GUI element.
abstract class IGUIMeshViewer : IGUIElement
{
	/// constructor
	this()(IGUIEnvironment environment, IGUIElement parent, size_t id, auto ref const rect!int rectangle)
	{
		super(EGUI_ELEMENT_TYPE.EGUIET_MESH_VIEWER, environment, parent, id, rectangle);
	}

	/// Sets the mesh to be shown
	void setMesh(IAnimatedMesh mesh);

	/// Gets the displayed mesh
	IAnimatedMesh getMesh() const;

	/// Sets the material
	void setMaterial(const SMaterial material);

	/// Gets the material
	const SMaterial getMaterial() const;
}