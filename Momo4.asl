state("MomodoraRUtM", "default")
{
	string6 versionId : 0x8E9899;
}

state("MomodoraRUtM", "v1.04d")
{

	string6 versionId : 0x8E9899;
	byte levelId : "MomodoraRUtM.exe", 0x230AF00;

	// For start
 	double difficultySelector : 0x22C17DC, 0xCB4, 0xC, 0x4, 0x41B0;

 	// For reset
 	double inGame : 0x2300A48, 0x4, 0x780;
 	double characterHP : 0x2300A48, 0x4, 0x0;

 	// Edea split
/* 	double edeaHP : 0x230D0EC, 0x4, 0x140, 0x4, 0x230;
 	double edeaHPMax : 0x230D0EC, 0x4, 0x140, 0x4, 0x240;*/
 	double edeaDefeated : 0x2300A48, 0x4, 0x60, 0x4, 0x4, 0xE0;

 	// Lubella 1 split
 	double lubella1HP : 0x230D0EC, 0x8, 0x140, 0x4, 0x230;
 	double lubella1HPMax : 0x230D0EC, 0x8, 0x140, 0x4, 0x240;
 	double mokaDefeated : 0x2300A48, 0x4, 0x60, 0x4, 0x4, 0x4C0; // Boss flag

 	// Frida split
 	double fridaHP : 0x230D0EC, 0x34, 0x13C, 0x4, 0x230;
 	double fridaHPMax : 0x230D0EC, 0x34, 0x13C, 0x4, 0x240;

 	// Arsonist split
/* 	double arsonistHP : 0x22FE9E4, 0x0, 0x0, 0x4, 0x230;
 	double arsonistHPMax : 0x22FE9E4, 0x0, 0x0, 0x4, 0x240;*/
 	double arsonistDefeated : 0x2300A48, 0x4, 0x60, 0x4, 0x4, 0x9E0;

 	// Warpstone
 	double warpStone : 0x2300A48, 0x4, 0x60, 0x4, 0x4, 0x5C0;

 	// Monastery Key
 	double monasteryKey : 0x2300A48, 0x4, 0x60, 0x4, 0x4, 0x260;

 	// Fennel
 	double fennelDefeated : 0x2300A48, 0x4, 0x60, 0x4, 0x4, 0x3D0;

  	// Lupiar and Magnolia
 	double magnoliaDefeated : 0x2300A48, 0x4, 0x60, 0x4, 0x4, 0x660;

 	// Fresh Spring Leaf
 	double freshSpringLeaf : 0x2300A48, 0x4, 0x60, 0x4, 0x4, 0x600;

 	// Clone Angel
 	double cloneAngelDefeated : 0x2300A48, 0x4, 0x60, 0x4, 0x4, 0x640;

 	// Queen
 	double alternativeFacts : 0x2300A48, 0x4, 0xAB0;

 	// Universal boss HP, very fickle and changes addresses a lot. Check current == old! Also switches to 0 when boss is defeated!
 	double bossHP : 0x22FE9E4, 0x0, 0x0, 0x4, 0x230;
 	double bossHPMax : 0x22FE9E4, 0x0, 0x0, 0x4, 0x240;

 	// Player movement lock value, can prove to be useful as it is set to 1 during cutscenes.
 	double playerMovementLock : 0x230D0F8, 0x3C0, 0x8C0, 0xF8, 0x670;
}

init
{
	// Debug
	print("modules.First().ModuleMemorySize == " + "0x" + modules.First().ModuleMemorySize.ToString("X8"));
	print(current.versionId);
	version = current.versionId;

/*	if (modules.First().ModuleMemorySize == 0x25D6000) {
		version = "v1.04d";
	}*/
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
		vars.cutscenes = 0;
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
	if (old.lubella1HP > 11 && current.lubella1HPMax == 130 && current.lubella1HP <= 11) {
		print("Lubella 1 defeated!");
		vars.lubella1Defeated = true;
		return true;
	}
	// Frida
	if (old.fridaHP > 11 && current.fridaHPMax != 0 && current.fridaHP <= 11) {
		print("Frida defeated!");
		return true;
	}
		// Lubella 2
	if (old.lubella1HP > 11 && current.lubella1HPMax == 150 && current.lubella1HP <= 11) {
		print("Lubella 2 defeated!");
		return true;
	}
	// Arsonist
	if (old.arsonistDefeated == 0 && current.arsonistDefeated == 1 && old.inGame == 1) {
		print("Arsonist defeated!");
		return true;
	}
	// Fennel - SPLITS AT END OF CUTSCENE, WILL PROBABLY CHANGE LOGIC LATER
	if (old.fennelDefeated == 0 && current.fennelDefeated == 1 && old.inGame == 1) {
		print("Fennel defeated!");
		return true;
	}
	// Lupiar & Magnolia - Splits when talking to Magnolia
	if (old.magnoliaDefeated == 0 && current.magnoliaDefeated == 1 && old.inGame == 1) {
		print("Magnolia defeated!");
		return true;
	}
	// Clone Angel
	if (old.cloneAngelDefeated == 0 && current.cloneAngelDefeated == 1 && old.inGame == 1) {
		print("Clone Angel defeated!");
		return true;
	}
	// Queen
	if (current.levelId == 232 && old.alternativeFacts == 0 && current.alternativeFacts == 1000) {
		print("Queen defeated!");
		return true;
	}



	// Warpstone
	if (old.warpStone == 0 && current.warpStone == 1 && old.inGame == 1) {
		print("Warp fragment obtained!");
		return true;
	}
	// Monastery key
	if (old.monasteryKey == 0 && current.monasteryKey == 1 && old.inGame == 1) {
		print("Monastery key obtained!");
		return true;
	}
	// Fresh Spring Leaf
	if (old.freshSpringLeaf == 0 && current.freshSpringLeaf == 1 && old.inGame == 1) {
		print("Fresh Spring Leaf obtained!");
		return true;
	}
}