// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.SKeyMap;

import irrlicht.Keycodes;

/// enumeration for key actions. Used for example in the FPS Camera.
enum EKEY_ACTION : uint
{
	EKA_MOVE_FORWARD = 0,
	EKA_MOVE_BACKWARD,
	EKA_STRAFE_LEFT,
	EKA_STRAFE_RIGHT,
	EKA_JUMP_UP,
	EKA_CROUCH,
	EKA_COUNT,
}

/// Struct storing which key belongs to which action.
struct SKeyMap
{
	this(EKEY_ACTION action, EKEY_CODE keyCode)
	{
		Action = action;
		KeyCode = keyCode;
	} 

	int opCmp()(auto ref const SKeyMap other)
	{
		if(Action < other.Action || (Action == other.Action && KeyCode < other.KeyCode))
			return -1;
		else if(Action > other.Action || (Action == other.Action && KeyCode > other.KeyCode))
			return 1;
		else 
			return 0;
	}

	EKEY_ACTION Action;
	EKEY_CODE KeyCode;
}