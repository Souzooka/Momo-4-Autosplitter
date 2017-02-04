state("MomodoraRUtM", "default")
{
	string6 versionId : 0x8E9899;
}

state("MomodoraRUtM", "v1.04d")
{

	string6 versionId : 0x8E9899;

	// For start
 	double difficultySelector : 0x22C17DC, 0xCB4, 0xC, 0x4, 0x41B0;

 	// For reset
 	double inGame : 0x230DB60, 0x4, 0x54, 0x780;
 	double characterHP : 0x230DB60, 0x78, 0x414, 0x0;

 	// Edea split
/* 	double edeaHP : 0x230D0EC, 0x4, 0x140, 0x4, 0x230;
 	double edeaHPMax : 0x230D0EC, 0x4, 0x140, 0x4, 0x240;*/
 	double edeaDefeated : 0x230D0F8, 0x3B8, 0x80, 0x814, 0xE0;

 	// Lubella 1 split
 	double lubella1HP : 0x230D0EC, 0x8, 0x140, 0x4, 0x230;
 	double lubella1HPMax : 0x230D0EC, 0x8, 0x140, 0x4, 0x240;
 	double mokaDefeated : 0x230D270, 0x880, 0x108, 0x4C0; // Boss flag

 	// Frida split
 	double fridaHP : 0x230D0EC, 0x34, 0x13C, 0x4, 0x230;
 	double fridaHPMax : 0x230D0EC, 0x34, 0x13C, 0x4, 0x240;

 	// Arsonist split
/* 	double arsonistHP : 0x22FE9E4, 0x0, 0x0, 0x4, 0x230;
 	double arsonistHPMax : 0x22FE9E4, 0x0, 0x0, 0x4, 0x240;*/
 	double arsonistDefeated : 0x230D0F8, 0x3B8, 0x80, 0x814, 0x9E0;

 	// Warpstone -- may not split, and may require a manual split currently!
 	double warpStone : 0x230D0F8, 0x3B8, 0x80, 0x814, 0x5C0;

 	// Universal boss HP, very fickle and changes addresses a lot. Check current == old!
 	double bossHP : 0x22FE9E4, 0x0, 0x0, 0x4, 0x230;
 	double bossHPMax : 0x22FE9E4, 0x0, 0x0, 0x4, 0x240;
}

init
{
	// Debug
	print("modules.First().ModuleMemorySize == " + "0x" + modules.First().ModuleMemorySize.ToString("X8"));

	// There is a flag for Lubella 1's fight, but it's set to true after Moka is defeated, so the split requires a bit of special handling
	vars.lubella1Defeated = false;

	if (modules.First().ModuleMemorySize == 0x25D6000) {
		version = "v1.04d";
	}
}

update
{

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
		vars.lubella1Defeated = false;
		return true;
	}
}

split
{

	// We need HPMax checks to prevent splits upon death/leaving game.
	// old.inGame is used to prevent splits from loading a save -- not necessary, but a just-in-case thing.

	// Edea
	if (old.edeaDefeated == 0 && current.edeaDefeated == 1 && old.inGame == 1) {
		print("Edea defeated!");
		return true;
	}
	// Lubella 1
	if (old.lubella1HP > 11 && current.lubella1HPMax != 0 && current.lubella1HP <= 11 && !vars.lubella1Defeated) {
		print("Lubella 1 defeated!");
		vars.lubella1Defeated = true;
		return true;
	}
	// Frida
	if (old.fridaHP > 11 && current.fridaHPMax != 0 && current.fridaHP <= 11) {
		print("Frida defeated!");
		return true;
	}
	// Arsonist
	if (old.arsonistDefeated == 0 && current.arsonistDefeated == 1 && old.inGame == 1) {
		print("Arsonist defeated!");
		return true;
	}
	// Warpstone
	if (old.warpStone == 0 && current.warpStone == 1 && old.inGame == 1) {
		print("Warp fragment obtained!");
		return true;
	}
}