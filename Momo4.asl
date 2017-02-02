state("MomodoraRUtM", "unknownPatch")
{
	// For start
 	double difficultySelector : 0x22C17DC, 0xCB4, 0xC, 0x4, 0x41B0;

 	// For reset
 	double inGame : 0x230DB60, 0x78, 0x414, 0x5C0;

 	// Edea split
 	double edeaHP : 0x230D0EC, 0x4, 0x140, 0x4, 0x230;
 	double edeaHPMax : 0x230D0EC, 0x4, 0x140, 0x4, 0x240;

 	// Lubella split
 	double lubellaHP : 0x230D0EC, 0x8, 0x140, 0x4, 0x230;
 	double lubellaHPMax : 0x230D0EC, 0x8, 0x140, 0x4, 0x240;
}

start
{
	if (old.difficultySelector > 0 && current.difficultySelector == 0) {
		return true;
	}
}

reset
{
	if (current.inGame == 0 && old.inGame == 1) {
		return true;
	}
}


split
{

	// We need HPMax checks to prevent splits upon death/leaving game.

	// Edea
	if (old.edeaHP > 11 && current.edeaHPMax != 0 && current.edeaHP <= 11) {
		return true;
	}
	// Lubella
	if (old.lubellaHP > 11 && current.lubellaHPMax != 0 && current.lubellaHP <= 11) {
		return true;
	}
}