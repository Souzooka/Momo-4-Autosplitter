state("MomodoraRUtM", "v1.04d")
{

	string6 versionId : 0x8E9899;
	byte levelId : "MomodoraRUtM.exe", 0x230AF00;

	// 0 == we're not in a boss, 1 == we're in a boss cutscene, 2 == we're in a boss fight!
	double bossFightStatus: 0x2300A48, 0x4, 0x1190;

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
/* 	double mokaDefeated : 0x2300A48, 0x4, 0x60, 0x4, 0x4, 0x4C0;*/

 	// Frida split
 	double fridaHP : 0x230D0EC, 0x34, 0x13C, 0x4, 0x230;
 	double fridaHPMax : 0x230D0EC, 0x34, 0x13C, 0x4, 0x240;

 	// Arsonist split
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
 	double cutseneProgress : 0x2300A48, 0x4, 0xAB0;

 	// Choir
 	double choirDefeated : 0x2300A48, 0x4, 0x60, 0x4, 0x4, 0x6A0;

 	// Universal boss HP, very fickle and changes addresses a lot. Check current == old! Also switches to 0 when boss is defeated!
/* 	double bossHP : 0x22FE9E4, 0x0, 0x0, 0x4, 0x230;
 	double bossHPMax : 0x22FE9E4, 0x0, 0x0, 0x4, 0x240;*/

 	// Player movement lock value, can prove to be useful as it is set to 1 during cutscenes.
/*	double playerMovementLock : 0x230D0F8, 0x3C0, 0x8C0, 0xF8, 0x670;*/
}

startup
{
	settings.Add("splits", true, "All Splits");

	settings.Add("edea", true, "Edea", "splits");
	settings.Add("lubella1", true, "Lubella 1", "splits");
	settings.Add("frida", true, "Frida", "splits");
	settings.Add("lubella2", true, "Lubella 2", "splits");
	settings.Add("warpFragment", true, "Warp Fragment", "splits");
	settings.Add("arsonist", true, "Arsonist", "splits");
	settings.Add("monasteryKey", true, "Monastery Key", "splits");
	settings.Add("fennel", true, "Fennel", "splits");
	settings.Add("magnolia", true, "Lupiar and Magnolia", "splits");
	settings.Add("freshSpringLeaf", true, "Fresh Spring Leaf", "splits");
	settings.Add("cloneAngel", true, "Clone Angel", "splits");
	settings.Add("queen", true, "Queen", "splits");
	settings.Add("choir", false, "Choir", "splits");

	print("Hey, this compiled correctly. Way to go!");

}

init
{
	// Debug
	print("modules.First().ModuleMemorySize == " + "0x" + modules.First().ModuleMemorySize.ToString("X8"));
	print(current.versionId);

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
		vars.cutscenes = 0;
		return true;
	}
}

split
{

	// We need HPMax checks to prevent splits upon death/leaving game.
	// old.inGame is used to prevent splits from loading a save -- not necessary, but a just-in-case thing.

	// Edea
	if (settings["edea"] && old.edeaDefeated == 0 && current.edeaDefeated == 1 && old.inGame == 1) {
		print("Edea defeated!");
		return true;
	}
	// Lubella 1
	if (settings["lubella1"] && old.lubella1HP > 11 && current.lubella1HPMax == 130 && current.lubella1HP <= 11) {
		print("Lubella 1 defeated!");
		vars.lubella1Defeated = true;
		return true;
	}
	// Frida
	if (settings["frida"] && old.fridaHP > 11 && current.fridaHPMax != 0 && current.fridaHP <= 11 && current.levelId != 97) {
		print("Frida defeated!");
		return true;
	}
		// Lubella 2
	if (settings["lubella2"] && old.lubella1HP > 11 && current.lubella1HPMax == 150 && current.lubella1HP <= 11) {
		print("Lubella 2 defeated!");
		return true;
	}
	// Arsonist
	if (settings["arsonist"] && current.cutseneProgress == 0 && old.cutseneProgress == 500 && current.levelId == 147) {
		print("Arsonist defeated!");
		return true;
	}
	// Fennel - SPLITS AT END OF CUTSCENE, WILL PROBABLY CHANGE LOGIC LATER
	if (settings["fennel"] && old.fennelDefeated == 0 && current.fennelDefeated == 1 && old.inGame == 1) {
		print("Fennel defeated!");
		return true;
	}
	// Lupiar & Magnolia - Splits when talking to Magnolia
	if (settings["magnolia"] && old.magnoliaDefeated == 0 && current.magnoliaDefeated == 1 && old.inGame == 1) {
		print("Magnolia defeated!");
		return true;
	}
	// Clone Angel
	if (settings["cloneAngel"] && old.cloneAngelDefeated == 0 && current.cloneAngelDefeated == 1 && old.inGame == 1) {
		print("Clone Angel defeated!");
		return true;
	}
	// Queen
	if (settings["queen"] && current.levelId == 232 && old.cutseneProgress == 0 && current.cutseneProgress == 1000) {
		print("Queen defeated!");
		return true;
	}

	// Choir
		if (settings["choir"] && current.choirDefeated == 1 && old.choirDefeated == 0 && old.inGame == 1) {
		print("Choir defeated!");
		return true;
	}

	// Warpstone
	if (settings["warpFragment"] && old.warpStone == 0 && current.warpStone == 1 && old.inGame == 1) {
		print("Warp fragment obtained!");
		return true;
	}
	// Monastery key
	if (settings["monasteryKey"] && old.monasteryKey == 0 && current.monasteryKey == 1 && old.inGame == 1) {
		print("Monastery key obtained!");
		return true;
	}
	// Fresh Spring Leaf
	if (settings["freshSpringLeaf"] && old.freshSpringLeaf == 0 && current.freshSpringLeaf == 1 && old.inGame == 1) {
		print("Fresh Spring Leaf obtained!");
		return true;
	}
}