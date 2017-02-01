state("MomodoraRUtM", "unknownPatch")
{
	// For start
 	double difficultySelector : 0x22C17DC, 0xCB4, 0xC, 0x4, 0x41B0;

 	// Not sure if this is for every boss
 	double bossHP : 0x22FE9E4, 0x0, 0x0, 0x4, 0x230;
}

start
{
	if (old.difficultySelector > 0 && current.difficultySelector == 0) {
		return true;
	}
}

split
{
	if (old.bossHP > 0 && current.bossHP == 0) {
		return true;
	}
}