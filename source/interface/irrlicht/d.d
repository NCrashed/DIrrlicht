/** 
* irrlicht.d -- interface of the 'Irrlicht Engine' for D programming language.
*
*  Copyright (C) 2002-2012 Nikolaus Gebhardt
*  Ported to D by Gushcha Anton (NCrashed) and Shamyan Roman (TheRedEye).
*
*  This software is provided 'as-is', without any express or implied
*  warranty.  In no event will the authors be held liable for any damages
*  arising from the use of this software.
*
*  Permission is granted to anyone to use this software for any purpose,
*  including commercial applications, and to alter it and redistribute it
*  freely, subject to the following restrictions:
*
*  1. The origin of this software must not be misrepresented; you must not
*     claim that you wrote the original software. If you use this software
*     in a product, an acknowledgment in the product documentation would be
*     appreciated but is not required.
*  2. Altered source versions must be plainly marked as such, and must not be
*     misrepresented as being the original software.
*  3. This notice may not be removed or altered from any source distribution.
*
*  Please note that the Irrlicht Engine is based in part on the work of the
*  Independent JPEG Group, the zlib and the libPng. This means that if you use
*  the Irrlicht Engine in your product, you must acknowledge somewhere in your
*  documentation that you've used the IJG code. It would also be nice to mention
*  that you use the Irrlicht Engine, the zlib and libPng. See the README files
*  in the jpeglib, the zlib and libPng for further informations.
*/
module irrlicht.d;

public
{
    import irrlicht.driverChoice;
    import irrlicht.EDeviceTypes;
    import irrlicht.IEventReceiver;
    import irrlicht.ILogger;
    import irrlicht.IOSOperator;
    import irrlicht.IRandomizer;
    import irrlicht.IrrlichtDevice;
    import irrlicht.irrMath;
    import irrlicht.irrTypes;
    import irrlicht.ITimer;
    import irrlicht.Keycodes;
    import irrlicht.SIrrlichtCreationParameters;
    import irrlicht.SKeyMap;
    import irrlicht.core.aabbox3d;
    import irrlicht.core.dimension2d;
    import irrlicht.core.heapsort; // may be removed
    import irrlicht.core.irrAllocator; // may be removed
    import irrlicht.core.irrArray; // may be removed
    import irrlicht.core.line2d;
    import irrlicht.core.line3d;
    import irrlicht.core.matrix4;
    import irrlicht.core.plane3d;
    import irrlicht.core.position2d; // may be removed
    import irrlicht.core.quaternion;
    import irrlicht.core.rect;
    import irrlicht.core.triangle3d;
    import irrlicht.core.vector2d;
    import irrlicht.core.vector3d;
    import irrlicht.gui.BuildInFont;
    import irrlicht.gui.EGUIAlignment;
    import irrlicht.gui.EGUIElementTypes;
    import irrlicht.gui.EMessageBoxFlags;
    import irrlicht.gui.ICursorControl;
    import irrlicht.gui.IGUIButton;
    import irrlicht.gui.IGUICheckBox;
    import irrlicht.gui.IGUIColorSelectDialog;
    import irrlicht.gui.IGUIComboBox;
    import irrlicht.gui.IGUIContextMenu;
    import irrlicht.gui.IGUIEditBox;
    import irrlicht.gui.IGUIElement;
    import irrlicht.gui.IGUIElementFactory;
    import irrlicht.gui.IGUIEnvironment;
    import irrlicht.gui.IGUIFileOpenDialog;
    import irrlicht.gui.IGUIFont;
    import irrlicht.gui.IGUIImage;
    import irrlicht.gui.IGUIImageList;
    import irrlicht.gui.IGUIInOutFader;
    import irrlicht.gui.IGUIListBox;
    import irrlicht.gui.IGUIMeshViewer;
    import irrlicht.gui.IGUIScrollBar;
    import irrlicht.gui.IGUISkin;
    import irrlicht.gui.IGUISpinBox;
    import irrlicht.gui.IGUISpriteBank;
    import irrlicht.gui.IGUIStaticText;
    import irrlicht.gui.IGUITabControl;
    import irrlicht.gui.IGUITable;
    import irrlicht.gui.IGUIToolBar;
    import irrlicht.gui.IGUITreeView;
    import irrlicht.gui.IGUIWindow;
    import irrlicht.io.EAttributes;
    import irrlicht.io.IAttributeExchangingObject;
    import irrlicht.io.IAttributes;
    import irrlicht.io.IFileArchive;
    import irrlicht.io.IFileList;
    import irrlicht.io.IFileSystem;
    import irrlicht.io.IReadFile;
    import irrlicht.io.irrXML;
    import irrlicht.io.IWriteFile;
    import irrlicht.io.IXMLReader;
    import irrlicht.io.IXMLWriter;
    import irrlicht.io.path;
    import irrlicht.scene.quake3.IQ3Shader;
    import irrlicht.scene.C3DSMeshFileLoader;
    import irrlicht.scene.CIndexBuffer;
    import irrlicht.scene.CMeshBuffer;
    import irrlicht.scene.ECullingTypes;
    import irrlicht.scene.EDebugSceneTypes;
    import irrlicht.scene.EHardwareBufferFlags;
    import irrlicht.scene.EMeshWriterEnums;
    import irrlicht.scene.EPrimitiveTypes;
    import irrlicht.scene.ESceneNodeAnimatorTypes;
    import irrlicht.scene.ESceneNodeTypes;
    import irrlicht.scene.ETerrainElements;
    import irrlicht.scene.IAnimatedMesh;
    import irrlicht.scene.IAnimatedMeshMD2;
    import irrlicht.scene.IAnimatedMeshMD3;
    import irrlicht.scene.IAnimatedMeshSceneNode;
    import irrlicht.scene.IBillboardSceneNode;
    import irrlicht.scene.IBillboardTextSceneNode;
    import irrlicht.scene.IBoneSceneNode;
    import irrlicht.scene.ICameraSceneNode;
    import irrlicht.scene.IColladaMeshWriter;
    import irrlicht.scene.IDummyTransformationSceneNode;
    import irrlicht.scene.IDynamicMeshBuffer;
    import irrlicht.scene.IGeometryCreator;
    import irrlicht.scene.IIndexBuffer;
    import irrlicht.scene.ILightManager;
    import irrlicht.scene.ILightSceneNode;
    import irrlicht.scene.IMesh;
    import irrlicht.scene.IMeshBuffer;
    import irrlicht.scene.IMeshCache;
    import irrlicht.scene.IMeshLoader;
    import irrlicht.scene.IMeshManipulator;
    import irrlicht.scene.IMeshSceneNode;
    import irrlicht.scene.IMeshWriter;
    import irrlicht.scene.IMetaTriangleSelector;
    import irrlicht.scene.IParticleAffector;
    import irrlicht.scene.IParticleAnimatedMeshSceneNodeEmitter;
    import irrlicht.scene.IParticleAttractionAffector;
    import irrlicht.scene.IParticleBoxEmitter;
    import irrlicht.scene.IParticleCylinderEmitter;
    import irrlicht.scene.IParticleEmitter;
    import irrlicht.scene.IParticleFadeOutAffector;
    import irrlicht.scene.IParticleGravityAffector;
    import irrlicht.scene.IParticleMeshEmitter;
    import irrlicht.scene.IParticleRingEmitter;
    import irrlicht.scene.IParticleRotationAffector;
    import irrlicht.scene.IParticleSphereEmitter;
    import irrlicht.scene.IParticleSystemSceneNode;
    import irrlicht.scene.IQ3LevelMesh; // should be moved to quake3 package
    import irrlicht.scene.ISceneCollisionManager;
    import irrlicht.scene.ISceneLoader;
    import irrlicht.scene.ISceneManager;
    import irrlicht.scene.ISceneNode;
    import irrlicht.scene.ISceneNodeAnimator;
    import irrlicht.scene.ISceneNodeAnimatorCameraFPS;
    import irrlicht.scene.ISceneNodeAnimatorCameraMaya;
    import irrlicht.scene.ISceneNodeAnimatorCollisionResponse;
    import irrlicht.scene.ISceneNodeAnimatorFactory;
    import irrlicht.scene.ISceneNodeFactory;
    import irrlicht.scene.ISceneUserDataSerializer;
    import irrlicht.scene.IShadowVolumeSceneNode;
    import irrlicht.scene.ISkinnedMesh;
    import irrlicht.scene.ITerrainSceneNode;
    import irrlicht.scene.ITextSceneNode;
    import irrlicht.scene.ITriangleSelector;
    import irrlicht.scene.IVertexBuffer;
    import irrlicht.scene.IVolumeLightSceneNode;
    import irrlicht.scene.SceneParameters;
    import irrlicht.scene.SMesh;
    import irrlicht.scene.SParticle;
    import irrlicht.scene.SSharedMeshBuffer;
    import irrlicht.scene.SSkinMeshBuffer;
    import irrlicht.scene.SVertexManipulator;
    import irrlicht.scene.SViewFrustum;
    import irrlicht.video.EDriverFeatures;
    import irrlicht.video.EDriverTypes;
    import irrlicht.video.EMaterialFlags;
    import irrlicht.video.EMaterialTypes;
    import irrlicht.video.EShaderTypes;
    import irrlicht.video.IGPUProgrammingServices;
    import irrlicht.video.IImage;
    import irrlicht.video.IImageLoader;
    import irrlicht.video.IImageWriter;
    import irrlicht.video.IMaterialRenderer;
    import irrlicht.video.IMaterialRendererServices;
    import irrlicht.video.IShaderConstantSetCallBack;
    import irrlicht.video.ITexture;
    import irrlicht.video.IVideoDriver;
    import irrlicht.video.IVideoModeList;
    import irrlicht.video.S3DVertex;
    import irrlicht.video.SColor;
    import irrlicht.video.SExposedVideoData;
    import irrlicht.video.SLight;
    import irrlicht.video.SMaterial;
    import irrlicht.video.SMaterialLayer;
    import irrlicht.video.SVertexIndex;

    import irrlicht.irrlicht;
}