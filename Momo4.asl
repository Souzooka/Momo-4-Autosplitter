state("MomodoraRUtM", "unknownPatch")
{
 	double difficultySelector : 0x23081A0, 0x10, 0x4, 0x41B0;
}

start
{
	if (old.difficultySelector > 0 && current.difficultySelector == 0) {
		return true;
	}
}