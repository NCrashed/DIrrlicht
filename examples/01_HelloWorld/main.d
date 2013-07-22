import irrlicht.core;
import irrlicht.scene;
import irrlicht.video;
import irrlicht.io;
import irrlicht.gui;

int main()
{
	IrrlichtDevice device = 
		createDevice(Renderer.EDT_SOFTWARE, dimension2d!uint(640, 480),
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

	if(node)
	{
		node.setMaterialFlag(MaterialFlag.EMF_LIGHTING, false);
	}
}