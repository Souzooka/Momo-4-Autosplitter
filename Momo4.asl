state("MomodoraRUtM", "unknownPatch")
{
	// For start
 	double difficultySelector : 0x22C17DC, 0xCB4, 0xC, 0x4, 0x41B0;

 	// Edea split
 	double edeaHP : 0x230D0EC, 0x0, 0x4, 0x230;
 	double edeaHPMax : 0x230D0EC, 0x0, 0x4, 0x240;

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


split
{
	// Edea
	if (old.edeaHP > 11 && current.edeaHPMax == 80 && current.edeaHP <= 11) {
		return true;
	}
	// Lubella
	if (old.lubellaHP > 11 && current.lubellaHPMax == 130 && current.lubellaHP <= 11) {
		return true;
	}
}