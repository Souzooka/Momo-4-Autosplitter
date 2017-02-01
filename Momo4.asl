state("MomodoraRUtM", "unknownPatch")
{
	// For start
 	double difficultySelector : 0x22C17DC, 0xCB4, 0xC, 0x4, 0x41B0;

 	// Not sure if this is for every boss
 	double bossHP : 0x230D0EC, 0x0, 0x4, 0x230;
}

start
{
	if (old.difficultySelector > 0 && current.difficultySelector == 0) {
		return true;
	}
}

split
{
	if (old.bossHP > 11 && current.bossHP == 11) {
		return true;
	}
}