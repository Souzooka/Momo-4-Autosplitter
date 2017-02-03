state("MomodoraRUtM", "v1.04d")
{
	// For start
 	double difficultySelector : 0x22C17DC, 0xCB4, 0xC, 0x4, 0x41B0;

 	// For reset
 	double inGame : 0x230DB60, 0x78, 0x414, 0x5C0;
 	double characterHP : 0x230DB60, 0x78, 0x414, 0x0;

 	// Edea split
 	double edeaHP : 0x230D0EC, 0x4, 0x140, 0x4, 0x230;
 	double edeaHPMax : 0x230D0EC, 0x4, 0x140, 0x4, 0x240;

 	// Lubella split
 	double lubellaHP : 0x230D0EC, 0x8, 0x140, 0x4, 0x230;
 	double lubellaHPMax : 0x230D0EC, 0x8, 0x140, 0x4, 0x240;

 	// Frida split
 	double fridaHP : 0x230D0EC, 0x34, 0x13C, 0x4, 0x230;
 	double fridaHPMax : 0x230D0EC, 0x34, 0x13C, 0x4, 0x240;

 	// Warpstone
 	double warpStone : 0x230DB28, 0x2C, 0xE44, 0x4, 0x5C0;
}

init
{
	// Debug
	print("modules.First().ModuleMemorySize == " + "0x" + modules.First().ModuleMemorySize.ToString("X8"));

	if (modules.First().ModuleMemorySize == 0x25D6000) {
		version = "v1.04d";
	}
}

start
{
	if (old.difficultySelector > 0 && current.difficultySelector == 0) {
		print("start returned true!");
		return true;
	}
}

reset
{
	if (current.inGame == 0 && old.inGame == 1 && current.characterHP == 30) {
		print("reset returned true!");
		return true;
	}
}

split
{

	// We need HPMax checks to prevent splits upon death/leaving game.

	// Edea
	if (old.edeaHP > 11 && current.edeaHPMax != 0 && current.edeaHP <= 11) {
		print("Edea defeated!");
		return true;
	}
	// Lubella, NOTE: Phase 1 is 130 max HP and phase 2 is 150 max HP, use this for settings!
	if (old.lubellaHP > 11 && current.lubellaHPMax != 0 && current.lubellaHP <= 11) {
		print("Lubella defeated!");
		return true;
	}
	// Frida
	if (old.fridaHP > 11 && current.fridaHPMax != 0 && current.fridaHP <= 11) {
		print("Frida defeated!");
		return true;
	}
	// Warpstone
	if (old.warpStone == 0 && current.warpStone == 1) {
		print("Warp fragment obtained!");
		return true;
	}
}