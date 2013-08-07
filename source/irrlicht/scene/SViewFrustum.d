// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.scene.SViewFrustum;

import irrlicht.video.IVideoDriver;
import irrlicht.core.plane3d;
import irrlicht.core.vector3d;
import irrlicht.core.line3d;
import irrlicht.core.aabbox3d;
import irrlicht.core.matrix4;
import std.math;

/// Defines the view frustum. That's the space visible by the camera.
/**
* The view frustum is enclosed by 6 planes. These six planes share
* eight points. A bounding box around these eight points is also stored in
* this structure.
*/
struct SViewFrustum
{
	enum VFPLANES
	{
		/// Far plane of the frustum. That is the plane farest away from the eye.
		VF_FAR_PLANE = 0,
		/// Near plane of the frustum. That is the plane nearest to the eye.
		VF_NEAR_PLANE,
		/// Left plane of the frustum.
		VF_LEFT_PLANE,
		/// Right plane of the frustum.
		VF_RIGHT_PLANE,
		/// Bottom plane of the frustum.
		VF_BOTTOM_PLANE,
		/// Top plane of the frustum.
		VF_TOP_PLANE,

		/// Amount of planes enclosing the view frustum. Should be 6.
		VF_PLANE_COUNT
	}

	/// Copy Constructor
	this()(auto ref const SViewFrustum other)
	{
		cameraPosition = other.cameraPosition;
		boundingBox = other.boundingBox;

		uint i;
		for (i=0; i<VFPLANES.VF_PLANE_COUNT; ++i)
			planes[i] = other.planes[i];

		for (i=0; i<E_TRANSFORMATION_STATE_FRUSTUM.ETS_COUNT_FRUSTUM; ++i)
			Matrices[i] = other.Matrices[i];
	}

	/// This constructor creates a view frustum based on a projection and/or view matrix.
	this()(auto ref const matrix4 mat)
	{
		setFrom ( mat );
	}

	/// This constructor creates a view frustum based on a projection and/or view matrix.
	void setFrom()(auto ref const matrix4 mat)
	{
		// left clipping plane
		planes[VFPLANES.VF_LEFT_PLANE].Normal.X = mat[3 ] + mat[0];
		planes[VFPLANES.VF_LEFT_PLANE].Normal.Y = mat[7 ] + mat[4];
		planes[VFPLANES.VF_LEFT_PLANE].Normal.Z = mat[11] + mat[8];
		planes[VFPLANES.VF_LEFT_PLANE].D =        mat[15] + mat[12];

		// right clipping plane
		planes[VFPLANES.VF_RIGHT_PLANE].Normal.X = mat[3 ] - mat[0];
		planes[VFPLANES.VF_RIGHT_PLANE].Normal.Y = mat[7 ] - mat[4];
		planes[VFPLANES.VF_RIGHT_PLANE].Normal.Z = mat[11] - mat[8];
		planes[VFPLANES.VF_RIGHT_PLANE].D =        mat[15] - mat[12];

		// top clipping plane
		planes[VFPLANES.VF_TOP_PLANE].Normal.X = mat[3 ] - mat[1];
		planes[VFPLANES.VF_TOP_PLANE].Normal.Y = mat[7 ] - mat[5];
		planes[VFPLANES.VF_TOP_PLANE].Normal.Z = mat[11] - mat[9];
		planes[VFPLANES.VF_TOP_PLANE].D =        mat[15] - mat[13];

		// bottom clipping plane
		planes[VFPLANES.VF_BOTTOM_PLANE].Normal.X = mat[3 ] + mat[1];
		planes[VFPLANES.VF_BOTTOM_PLANE].Normal.Y = mat[7 ] + mat[5];
		planes[VFPLANES.VF_BOTTOM_PLANE].Normal.Z = mat[11] + mat[9];
		planes[VFPLANES.VF_BOTTOM_PLANE].D =        mat[15] + mat[13];

		// far clipping plane
		planes[VFPLANES.VF_FAR_PLANE].Normal.X = mat[3 ] - mat[2];
		planes[VFPLANES.VF_FAR_PLANE].Normal.Y = mat[7 ] - mat[6];
		planes[VFPLANES.VF_FAR_PLANE].Normal.Z = mat[11] - mat[10];
		planes[VFPLANES.VF_FAR_PLANE].D =        mat[15] - mat[14];

		// near clipping plane
		planes[VFPLANES.VF_NEAR_PLANE].Normal.X = mat[2];
		planes[VFPLANES.VF_NEAR_PLANE].Normal.Y = mat[6];
		planes[VFPLANES.VF_NEAR_PLANE].Normal.Z = mat[10];
		planes[VFPLANES.VF_NEAR_PLANE].D =        mat[14];

		// normalize normals
		uint i;
		for ( i=0; i != VFPLANES.VF_PLANE_COUNT; ++i)
		{
			immutable float len = -1.0/sqrt(
					planes[i].Normal.getLengthSQ());
			planes[i].Normal *= len;
			planes[i].D *= len;
		}

		// make bounding box
		recalculateBoundingBox();
	}

	/// transforms the frustum by the matrix
	/**
	* Params:
	* 	mat=  Matrix by which the view frustum is transformed.
	*/
	void transform()(auto ref const matrix4 mat)
	{
		for (uint i=0; i<VFPLANES.VF_PLANE_COUNT; ++i)
			mat.transformPlane(planes[i]);

		mat.transformVect(cameraPosition);
		recalculateBoundingBox();
	}

	/// returns the point which is on the far left upper corner inside the the view frustum.
	vector3df getFarLeftUp() const
	{
		vector3d!float p;
		planes[VFPLANES.VF_FAR_PLANE].getIntersectionWithPlanes(
			planes[VFPLANES.VF_TOP_PLANE],
			planes[VFPLANES.VF_LEFT_PLANE], p);

		return p;
	}

	/// returns the point which is on the far left bottom corner inside the the view frustum.
	vector3df getFarLeftDown() const
	{
		vector3df p;
		planes[VFPLANES.VF_FAR_PLANE].getIntersectionWithPlanes(
			planes[VFPLANES.VF_BOTTOM_PLANE],
			planes[VFPLANES.VF_LEFT_PLANE], p);

		return p;
	}

	/// returns the point which is on the far right top corner inside the the view frustum.
	vector3df getFarRightUp() const
	{
		vector3df p;
		planes[VFPLANES.VF_FAR_PLANE].getIntersectionWithPlanes(
			planes[VFPLANES.VF_TOP_PLANE],
			planes[VFPLANES.VF_RIGHT_PLANE], p);

		return p;
	}

	/// returns the point which is on the far right bottom corner inside the the view frustum.
	vector3df getFarRightDown() const
	{
		vector3df p;
		planes[VFPLANES.VF_FAR_PLANE].getIntersectionWithPlanes(
			planes[VFPLANES.VF_BOTTOM_PLANE],
			planes[VFPLANES.VF_RIGHT_PLANE], p);

		return p;
	}

	/// returns the point which is on the near left upper corner inside the the view frustum.
	vector3df getNearLeftUp() const
	{
		vector3df p;
		planes[VFPLANES.VF_NEAR_PLANE].getIntersectionWithPlanes(
			planes[VFPLANES.VF_TOP_PLANE],
			planes[VFPLANES.VF_LEFT_PLANE], p);

		return p;
	}

	/// returns the point which is on the near left bottom corner inside the the view frustum.
	vector3df getNearLeftDown() const
	{
		vector3df p;
		planes[VFPLANES.VF_NEAR_PLANE].getIntersectionWithPlanes(
			planes[VFPLANES.VF_BOTTOM_PLANE],
			planes[VFPLANES.VF_LEFT_PLANE], p);

		return p;
	}

	/// returns the point which is on the near right top corner inside the the view frustum.
	vector3df getNearRightUp() const
	{
		vector3df p;
		planes[VFPLANES.VF_NEAR_PLANE].getIntersectionWithPlanes(
			planes[VFPLANES.VF_TOP_PLANE],
			planes[VFPLANES.VF_RIGHT_PLANE], p);

		return p;
	}

	/// returns the point which is on the near right bottom corner inside the the view frustum.
	vector3df getNearRightDown() const
	{
		vector3df p;
		planes[VFPLANES.VF_NEAR_PLANE].getIntersectionWithPlanes(
			planes[VFPLANES.VF_BOTTOM_PLANE],
			planes[VFPLANES.VF_RIGHT_PLANE], p);

		return p;		
	}

	/// returns a bounding box enclosing the whole view frustum
	auto ref const aabbox3d!float getBoundingBox() const
	{
		return boundingBox;
	}

	/// recalculates the bounding box member based on the planes
	void recalculateBoundingBox()
	{
		boundingBox.reset ( cameraPosition );

		boundingBox.addInternalPoint(getFarLeftUp());
		boundingBox.addInternalPoint(getFarRightUp());
		boundingBox.addInternalPoint(getFarLeftDown());
		boundingBox.addInternalPoint(getFarRightDown());
	}

	/// get the given state's matrix based on frustum E_TRANSFORMATION_STATE
	ref matrix4 getTransform()(E_TRANSFORMATION_STATE state)
	{
		uint index = 0;
		switch ( state )
		{
			case E_TRANSFORMATION_STATE_FRUSTUM.ETS_PROJECTION:
				index = E_TRANSFORMATION_STATE_FRUSTUM.ETS_PROJECTION; break;
			case E_TRANSFORMATION_STATE_FRUSTUM.ETS_VIEW:
				index = E_TRANSFORMATION_STATE_FRUSTUM.ETS_VIEW; break;
			default:
				break;
		}
		return Matrices [ index ];
	}

	/// get the given state's matrix based on frustum E_TRANSFORMATION_STATE
	auto ref const matrix4 getTransform()(E_TRANSFORMATION_STATE state) const
	{
		uint index = 0;
		switch ( state )
		{
			case E_TRANSFORMATION_STATE_FRUSTUM.ETS_PROJECTION:
				index = E_TRANSFORMATION_STATE_FRUSTUM.ETS_PROJECTION; break;
			case E_TRANSFORMATION_STATE_FRUSTUM.ETS_VIEW:
				index = E_TRANSFORMATION_STATE_FRUSTUM.ETS_VIEW; break;
			default:
				break;
		}
		return Matrices [ index ];
	}

	/// clips a line to the view frustum.
	/**
	* Returns: True if the line was clipped, false if not 
	*/
	bool clipLine(ref line3d!float line) const
	{
		bool wasClipped = false;
		for (uint i=0; i < VFPLANES.VF_PLANE_COUNT; ++i)
		{
			if (planes[i].classifyPointRelation(line.start) == EIntersectionRelation3D.ISREL3D_FRONT)
			{
				line.start = line.start.getInterpolated(line.end,
						planes[i].getKnownIntersectionWithLine(line.start, line.end));
				wasClipped = true;
			}
			if (planes[i].classifyPointRelation(line.end) == EIntersectionRelation3D.ISREL3D_FRONT)
			{
				line.end = line.start.getInterpolated(line.end,
						planes[i].getKnownIntersectionWithLine(line.start, line.end));
				wasClipped = true;
			}
		}
		return wasClipped;
	}

	/// the position of the camera
	vector3df cameraPosition;

	/// all planes enclosing the view frustum.
	plane3d!float planes[VFPLANES.VF_PLANE_COUNT];

	/// bounding box around the view frustum
	aabbox3d!float boundingBox;

	/// Hold a copy of important transform matrices
	private enum E_TRANSFORMATION_STATE_FRUSTUM
	{
		ETS_VIEW = 0,
		ETS_PROJECTION = 1,
		ETS_COUNT_FRUSTUM
	}

	/// Hold a copy of important transform matrices
	private matrix4 Matrices[E_TRANSFORMATION_STATE_FRUSTUM.ETS_COUNT_FRUSTUM];
}