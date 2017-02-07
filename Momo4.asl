// Hi. If you're looking at this code, you might be interested in updating it for a newer version of MomodoraRUtM. This is actually really easy! 
// Basically, all you need to do is locate four unique pointer paths (one of which even is a static pointer). Last offsets should hopefully be the same.

// The first is for the double difficultySelector. This needs to be used (rather than levelId) for accurate starting time. This double value is 1 when selecting easy, 2 for normal, 3 for hard, 4 for insane, and 0 every other time.
// Note that if the last offset changes from 0x41B0, finding out what writes to this address via CE should give you an accurate last offset.
// This is the only value we use with this pointer path.

// The second is for characterHP. This double value is 30 in the main menu, 80 on easy, 30 on normal, 15 on hard, and 1 on insane, and obviously decreases/increases according to game rules.
// characterHP's last offset should always be 0x0.
// We use this value for characterHP, inGame, and cutsceneProgress.

// The third is for levelId. This one should be easy to find. This is a byte value with a static pointer, and should be 1 on saves, 11 on difficulty selection, and 21 on the first area.

// The fourth is for various flags and statistics, and this encompasses almost the rest of the values.

// The last is the trickiest, for Lubella 1. Her flag is set after Moka is defeated, and there are no other clear indicators for her being defeated except for her HP. #thanksbombservice
// HP pointers seem to change based on boss order, so thankfully she is always fought second.
// She starts at 130 HP, and is defeated at <= 11 HP.
// Boss' HP last offset is 0x230, max HP is 0x240. Do NOT use a <base address>, 0x0, 0x0, 0x4, 0x230 pointer! This is for universal boss HP, but also appears to point at other addresses very often. Will definitely cause unintended behavior!

// If you're not me and updating this script, send a pull request to the gitHub at https://github.com/Souzooka/Momo-4-Autosplitter



state("MomodoraRUtM", "v1.04d")
{

	// General
	double cutseneProgress : 0x2300A48, 0x4, 0xAB0;
	/*string6 versionId : 0x8E9899;*/
	byte levelId : "MomodoraRUtM.exe", 0x230AF00;

	// For start
 	double difficultySelector : 0x22C17DC, 0xCB4, 0xC, 0x4, 0x41B0;

 	// For reset
 	double inGame : 0x2300A48, 0x4, 0x780;
 	double characterHP : 0x2300A48, 0x4, 0x0;

 	// Edea split
 	double edeaDefeated : 0x2300A48, 0x4, 0x60, 0x4, 0x4, 0xE0;

 	// Lubella 1 split
 	double lubella1HP : 0x230D0EC, 0x8, 0x140, 0x4, 0x230;
 	double lubella1HPMax : 0x230D0EC, 0x8, 0x140, 0x4, 0x240;

 	// Frida split
 	// see cutsceneProgress

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
 	// see cutsceneProgress

 	// Choir
 	double choirDefeated : 0x2300A48, 0x4, 0x60, 0x4, 0x4, 0x6A0;

 	// 100%
 	double ivoryBugs : 0x2300A48, 0x4, 0x60, 0x4, 0x4, 0x3C0;
 	double vitalityFragments : 0x2300A48, 0x4, 0x60, 0x4, 0x4, 0xAE0;
}

startup
{
	settings.Add("100%Check", false, "100% Run");
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

	settings.SetToolTip("100%Check", "If checked, will only split for Queen if Choir is defeated, 17 vitality fragments were obtained, and 20 bug ivories were collected.");

	print("Hey, this compiled correctly. Way to go!");

}

init
{
	// Debug
	print("modules.First().ModuleMemorySize == " + "0x" + modules.First().ModuleMemorySize.ToString("X8"));
	/*print(current.versionId);*/

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

	// various flags are set during or at the beginning of boss fights, which is why we use cutsceneProgress trickery.
	// old.inGame is to prevent splits upon loading a save.

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
	if (settings["frida"] && current.levelId == 141 && current.cutseneProgress == 0 && old.cutseneProgress == 500) {
		print("Frida defeated!");
		return true;
	}
		// Lubella 2
	if (settings["lubella2"] && current.cutseneProgress == 0 && old.cutseneProgress == 500 && current.levelId == 147) {
		print("Lubella 2 defeated!");
		return true;
	}
	// Arsonist
	if (settings["arsonist"] && current.arsonistDefeated == 1 && old.arsonistDefeated == 0 && old.inGame == 1) {
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
	if (settings["queen"] && !settings["100%Check"] && current.levelId == 232 && old.cutseneProgress != 1000 && current.cutseneProgress == 1000) {
		print("Queen defeated!");
		return true;
	}

	// Queen 100%
	if (settings["queen"] && settings["100%Check"] && current.levelId == 232 && old.cutseneProgress != 1000 && current.cutseneProgress == 1000) {
		print("Checking 100% conditions:");
		print("Has Choir been defeated?: " + Convert.ToBoolean(current.choirDefeated));
		print("Bug ivories collected: " + current.ivoryBugs + "/20.");
		print("Vitality fragments collected: " + current.vitalityFragments + "/17.");
		if (current.choirDefeated == 1 && current.ivoryBugs == 20 && current.vitalityFragments == 17) {
			return true;
		}
	}

	// Choir
	if (settings["choir"] && current.choirDefeated == 1 && old.choirDefeated == 0 && old.inGame == 1) {
		vars.choirDefeated = 1;
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