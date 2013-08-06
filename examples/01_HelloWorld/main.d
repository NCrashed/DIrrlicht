module example01;

import irrlicht.IrrlichtDevice;
import irrlicht.video.IVideoDriver;
import irrlicht.video.EMaterialFlags;
import irrlicht.video.EDriverTypes;
import irrlicht.scene.ISceneManager;
import irrlicht.scene.IAnimatedMesh;
import irrlicht.scene.IAnimatedMeshSceneNode;
import irrlicht.gui.IGUIEnvironment;
import irrlicht.core.dimension2d;

int main()
{
	IrrlichtDevice device = 
		createDevice(E_DRIVER_TYPE.EDT_SOFTWARE, dimension2d!uint(640, 480),
			false, false, false, 0);

	if(device is null)
		return 1;

	device.setWindowCaption("Hello World! - Irrlicht Engine Demo");

	IVideoDriver driver = device.getVideoDriver();
	ISceneManager smgr = device.getSceneManager();
	IGUIEnvironment guienv = device.getGUIEnvironment();

	guienv.addStaticText("Hello World! This is the Irrlicht Software renderer!",
		rect!int(10,10,260,22), true);

	IAnimatedMesh mesh = smgr.getMesh("../../media/sydney.md2");
	if(mesh is null)
	{
		device.drop();
		return 1;
	}
	IAnimatedMeshSceneNode node = smgr.addAnimatedMeshSceneNode(mesh);

	if(node !is null)
	{
		node.setMaterialFlag(E_MATERIAL_FLAG.EMF_LIGHTING, false);
	}
}