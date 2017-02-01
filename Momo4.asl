state("MomodoraRUtM", "unknownPatch")
{
 	double difficultySelector : 0x22C17DC, 0xCB4, 0xC, 0x4, 0x41B0;
}

start
{
	if (old.difficultySelector > 0 && current.difficultySelector == 0) {
		return true;
	}
}