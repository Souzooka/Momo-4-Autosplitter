
// TODO: Find a solid health pointer -- if Edea bleeds before she's active, then there is a pointer, even if we have trouble finding it.
// *Do not use 0, 0, 4, 230*
// We might be able to make our own pointer using an aobscan for code that changes boss HP
// Bosses die at <= 11 HP

state("MomodoraRUtM") {

	// would you double your salary, at the risk of becoming DEAD?
	double salary : 0xDEAD;

}

startup
{
	// SETTINGS START //
	settings.Add("saveRunData", false, "Save Run Data");
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

	settings.SetToolTip("saveRunData", "REQUIRES LIVESPLIT TO BE RUN AS ADMINISTRATOR. Will create a text file containing run stats under \"Livesplit 1.6.9\\MomodoraRUtM\"");
	settings.SetToolTip("100%Check", "If checked, will only split for Queen if Choir is defeated, 17 vitality fragments were obtained, and 20 bug ivories were collected.");

	print("Hey, this compiled correctly. Way to go!");
	// SETTINGS END //

	// just a stopwatch
	// used for scanning for Lubella's HP pointer when in her boss arena
	vars.stopwatch = new Stopwatch();

	// used to check if the game is loaded every 2 seconds, stops being used after the initial scan is done.
	vars.stopwatch2 = new Stopwatch();
	vars.stopwatch2.Start();

	// AOB SCANS //
	vars.watchers = new MemoryWatcherList();
}

init
{
	vars.watchers.Clear();

	// Placeholders -- AOB scans were moved out of init to make sure that values were obtained properly. Check update!
	// these should be picked up by garbage collection when they are reassigned
	vars.difficultySelector = new MemoryWatcher<double>(IntPtr.Zero); 
	vars.lubella1HP = new MemoryWatcher<double>(IntPtr.Zero);
	vars.lubella1HPMax = new MemoryWatcher<double>(IntPtr.Zero);
	vars.levelId = new MemoryWatcher<double>(IntPtr.Zero); 
	vars.characterHP = new MemoryWatcher<double>(IntPtr.Zero); 
	vars.inGame = new MemoryWatcher<double>(IntPtr.Zero); 
	vars.cutsceneProgress = new MemoryWatcher<double>(IntPtr.Zero); 
	vars.savesCount = new MemoryWatcher<double>(IntPtr.Zero); 
	vars.edeaDefeated = new MemoryWatcher<double>(IntPtr.Zero); 
	vars.arsonistDefeated = new MemoryWatcher<double>(IntPtr.Zero); 
	vars.warpStone = new MemoryWatcher<double>(IntPtr.Zero); 
	vars.monasteryKey = new MemoryWatcher<double>(IntPtr.Zero); 
	vars.fennelDefeated = new MemoryWatcher<double>(IntPtr.Zero); 
	vars.magnoliaDefeated = new MemoryWatcher<double>(IntPtr.Zero); 
	vars.freshSpringLeaf = new MemoryWatcher<double>(IntPtr.Zero); 
	vars.cloneAngelDefeated = new MemoryWatcher<double>(IntPtr.Zero); 
	vars.choirDefeated = new MemoryWatcher<double>(IntPtr.Zero); 
	vars.ivoryBugs = new MemoryWatcher<double>(IntPtr.Zero); 
	vars.vitalityFragments = new MemoryWatcher<double>(IntPtr.Zero); 
	vars.enemiesKilled = new MemoryWatcher<double>(IntPtr.Zero); 

	vars.levelIdCodeAddr = IntPtr.Zero;

	// Statistics
	vars.hpLost = 0;


}

update
{
	// Save run data. REQUIRES ADMIN RIGHTS!
	if (settings["saveRunData"] && vars.levelId.Current == 232 && vars.cutsceneProgress.Old != 1000 && vars.cutsceneProgress.Current == 1000) {
		if (!System.IO.Directory.Exists("MomodoraRUtM")) {
			System.IO.Directory.CreateDirectory("MomodoraRUtM");
		}
		using (System.IO.StreamWriter sw = new System.IO.StreamWriter(@"MomodoraRUtM\MomodoraRUtM " + DateTime.Now.ToString("HH.mm.ss - MM.dd.yyyy") + ".txt")) {
			if (vars.choirDefeated.Current == 1 && vars.ivoryBugs.Current == 20 && vars.vitalityFragments.Current == 17) {
				sw.WriteLine("Is this a \"100%\" run?: True");
			}
			else {
				sw.WriteLine("Is this a \"100%\" run?: False");
			}
			sw.WriteLine("Has Choir been defeated?: " + Convert.ToBoolean(vars.choirDefeated.Current));
			sw.WriteLine("Bug ivories collected: " + vars.ivoryBugs.Current + "/20.");
			sw.WriteLine("Vitality fragments collected: " + vars.vitalityFragments.Current + "/17.");
			sw.WriteLine("\r\n_______________\r\n");
			sw.WriteLine("Total saves: "+ vars.savesCount.Current);
			sw.WriteLine("Total HP lost: " + vars.hpLost);
			sw.WriteLine("Non-boss enemies killed: " + vars.enemiesKilled.Current);
		}
	}

	// Statistics management start
	if (timer.CurrentTime.ToString() == "00:00:00 | 00:00:00") {
		// Reset variables
		vars.hpLost = 0;
	}

	// for statistics file
	if (vars.characterHP.Current < vars.characterHP.Old && vars.inGame.Current == 1) {
		vars.hpLost += (vars.characterHP.Old - vars.characterHP.Current);
	}
	// statistics end
	// save run data end

	// AOB SCANS

	// initial scan, after init is run wait 2 seconds and if the game is loaded, run initial scans for flags and other data like levelId
	// else reset timer and wait 2 more seconds
	if (vars.stopwatch2.ElapsedMilliseconds >= 2000 && (IntPtr)vars.levelIdCodeAddr == IntPtr.Zero) {

		var module = modules.First();
		var scanner = new SignatureScanner(game, module.BaseAddress, module.ModuleMemorySize);

		vars.levelIdCodeTarget = new SigScanTarget(2,
			"89 35 ?? ?? ?? ??", 	// mov [035AAF00],esi ; destination is levelId address, other code that follows is only for the purposes of finding a unique match
			"7D 0B",				// jnl 018CAB1A
			"8B 15 ?? ?? ?? ??",	// mov edx,[035AAF64]
			"8B 04 B2",				// mov eax,[edx+esi*4]
			"EB 02",				// jmp 018CAB1C
			"33 C0",				// xor eax,eax
			"50",					// push eax
			"E8 ?? ?? ?? ??"		// call 018C94F0
		);

		vars.flagsBaseAddrCodeTarget = new SigScanTarget(1,
			"A1 ?? ?? ?? ??",			// mov eax,[02400A48] (MomodoraRUtM.exe+2300A48) ; base address we're looking for for flags/character/gamestatus pointer
			"8B 40 04",					// mov eax,[eax+04]
			"C7 44 24 10 ?? ?? ?? ??",	// mov [esp+10],00000000
			"F2 ?? ?? 88 ?? ?? ?? ??",	// cvttsd2si ecx,[eax+00000660] ; what is this opcode even
			"85 C9",					// test ecx,ecx
			"7F 0C"						// jg 0013C1D2
		);

		// Find code address (+ 0x2 for levelId, first int in SigScanTarget)
		vars.levelIdCodeAddr = scanner.Scan(vars.levelIdCodeTarget);
		vars.flagsBaseAddrCodeAddr = scanner.Scan(vars.flagsBaseAddrCodeTarget);

		// Read the address for levelID from code
		vars.levelIdAddr = memory.ReadValue<int>((IntPtr)vars.levelIdCodeAddr);
		vars.flagsBaseAddr = memory.ReadValue<int>((IntPtr)vars.flagsBaseAddrCodeAddr);

		// offsets 0x4, 0x0 for character HP
		// 0x4, 0x780 for inGame
		// 0x4, 0xAB0 for cutsceneProgress
		vars.hpPointerLevel1 = memory.ReadValue<int>((IntPtr)vars.flagsBaseAddr) + 0x4;
		vars.flagsPointerLevel1 = vars.hpPointerLevel1;

		vars.characterHPAddr = memory.ReadValue<int>((IntPtr)vars.hpPointerLevel1) + 0x0;
		vars.inGameAddr = memory.ReadValue<int>((IntPtr)vars.hpPointerLevel1) + 0x780;
		vars.cutsceneProgressAddr = memory.ReadValue<int>((IntPtr)vars.hpPointerLevel1) + 0xAB0;

		// Offset 0x4 (from hpPointerLevel1), 0x60, 0x4, 0x4, 0xXXX
		// * savesCount: 0x0
		// * edeaDefeated: 0xE0
		// * arsonistDefeated: 0x9E0
		// * warpStone: 0x5C0
		// * monasteryKey: 0x260
		// * fennelDefeated: 0x3D0
		// * magnoliaDefeated: 0x660
		// * freshSpringLeaf: 0x600
		// * cloneAngelDefeated: 0x640
		// * choirDefeated: 0x6A0
		// * ivoryBugs: 0x3C0
		// * vitalityFragments: 0xAE0
		// * enemiesKilled: 0x490
		vars.flagsPointerLevel2 = memory.ReadValue<int>((IntPtr)vars.flagsPointerLevel1) + 0x60;
		vars.flagsPointerLevel3 = memory.ReadValue<int>((IntPtr)vars.flagsPointerLevel2) + 0x4;
		vars.flagsPointerLevel4 = memory.ReadValue<int>((IntPtr)vars.flagsPointerLevel3) + 0x4;

		// Flags
		vars.savesCountAddr = memory.ReadValue<int>((IntPtr)vars.flagsPointerLevel4) + 0x0;
		vars.edeaDefeatedAddr = memory.ReadValue<int>((IntPtr)vars.flagsPointerLevel4) + 0xE0;
		vars.arsonistDefeatedAddr = memory.ReadValue<int>((IntPtr)vars.flagsPointerLevel4) + 0x9E0;
		vars.warpStoneAddr = memory.ReadValue<int>((IntPtr)vars.flagsPointerLevel4) + 0x5C0;
		vars.monasteryKeyAddr = memory.ReadValue<int>((IntPtr)vars.flagsPointerLevel4) + 0x260;
		vars.fennelDefeatedAddr = memory.ReadValue<int>((IntPtr)vars.flagsPointerLevel4) + 0x3D0;
		vars.magnoliaDefeatedAddr = memory.ReadValue<int>((IntPtr)vars.flagsPointerLevel4) + 0x660;
		vars.freshSpringLeafAddr = memory.ReadValue<int>((IntPtr)vars.flagsPointerLevel4) + 0x660;
		vars.cloneAngelDefeatedAddr = memory.ReadValue<int>((IntPtr)vars.flagsPointerLevel4) + 0x640;
		vars.choirDefeatedAddr = memory.ReadValue<int>((IntPtr)vars.flagsPointerLevel4) + 0x6A0;
		vars.ivoryBugsAddr = memory.ReadValue<int>((IntPtr)vars.flagsPointerLevel4) + 0x3C0;
		vars.vitalityFragmentsAddr = memory.ReadValue<int>((IntPtr)vars.flagsPointerLevel4) + 0xAE0;
		vars.enemiesKilledAddr = memory.ReadValue<int>((IntPtr)vars.flagsPointerLevel4) + 0x490;

		// Read the value of these addresses
		vars.levelId = new MemoryWatcher<byte>((IntPtr)vars.levelIdAddr);
		vars.characterHP = new MemoryWatcher<double>((IntPtr)vars.characterHPAddr);
		vars.inGame = new MemoryWatcher<double>((IntPtr)vars.inGameAddr);
		vars.cutsceneProgress = new MemoryWatcher<double>((IntPtr)vars.cutsceneProgressAddr);
		vars.savesCount = new MemoryWatcher<double>((IntPtr)vars.savesCountAddr);
		vars.edeaDefeated = new MemoryWatcher<double>((IntPtr)vars.edeaDefeatedAddr);
		vars.arsonistDefeated = new MemoryWatcher<double>((IntPtr)vars.arsonistDefeatedAddr);
		vars.warpStone = new MemoryWatcher<double>((IntPtr)vars.warpStoneAddr);
		vars.monasteryKey = new MemoryWatcher<double>((IntPtr)vars.monasteryKeyAddr);
		vars.fennelDefeated = new MemoryWatcher<double>((IntPtr)vars.fennelDefeatedAddr);
		vars.magnoliaDefeated = new MemoryWatcher<double>((IntPtr)vars.magnoliaDefeatedAddr);
		vars.freshSpringLeaf = new MemoryWatcher<double>((IntPtr)vars.freshSpringLeafAddr);
		vars.cloneAngelDefeated = new MemoryWatcher<double>((IntPtr)vars.cloneAngelDefeatedAddr);
		vars.choirDefeated = new MemoryWatcher<double>((IntPtr)vars.choirDefeatedAddr);
		vars.ivoryBugs = new MemoryWatcher<double>((IntPtr)vars.ivoryBugsAddr);
		vars.vitalityFragments = new MemoryWatcher<double>((IntPtr)vars.vitalityFragmentsAddr);
		vars.enemiesKilled = new MemoryWatcher<double>((IntPtr)vars.enemiesKilledAddr);
		
		vars.watchers.AddRange(new MemoryWatcher[]
		{
			vars.levelId,
			vars.characterHP,
			vars.inGame,
			vars.cutsceneProgress,
			vars.savesCount,
			vars.edeaDefeated,
			vars.arsonistDefeated,
			vars.warpStone,
			vars.monasteryKey,
			vars.fennelDefeated,
			vars.magnoliaDefeated,
			vars.cloneAngelDefeated,
			vars.choirDefeated,
			vars.ivoryBugs,
			vars.vitalityFragments,
			vars.enemiesKilled,
		});

	vars.stopwatch2.Reset();
	}
	else if ((IntPtr)vars.levelIdCodeAddr == IntPtr.Zero) {
		vars.stopwatch2.Restart();
	}

	// addresses for difficultySelector change when we leave the game, so rescan for difficultySelector when entering difficulty menu
	if (vars.levelId.Current == 11 && vars.levelId.Old != 11) {

		var module = modules.First();
		var scanner = new SignatureScanner(game, module.BaseAddress, module.ModuleMemorySize);

		vars.difficultySelectorBaseAddrCodeTarget = new SigScanTarget(2,
			"8B 15 ?? ?? ?? ??",	// mov edx,[035C17DC] ; base address
			"23 C1",				// and eax,eax
			"8B 04 C2",				// mov eax,[edx+eax*8]
			"85 C0",				// test eax,eax
			"74 10",				// je 018A595C
			"8D 64 24 00",			// esp,[esp+00]
			"39 48 08",				// cmp [eax+08],ecx
			"74 0A"					// je 018A595F
		);

		vars.difficultySelectorBaseAddrCodeAddr = scanner.Scan(vars.difficultySelectorBaseAddrCodeTarget);
		vars.difficultySelectorBaseAddr = memory.ReadValue<int>((IntPtr)vars.difficultySelectorBaseAddrCodeAddr);
		vars.difficultySelectorPointerLevel1 = memory.ReadValue<int>((IntPtr)vars.difficultySelectorBaseAddr) + 0xCB4;
		vars.difficultySelectorPointerLevel2 = memory.ReadValue<int>((IntPtr)vars.difficultySelectorPointerLevel1) + 0xC;
		vars.difficultySelectorPointerLevel3 = memory.ReadValue<int>((IntPtr)vars.difficultySelectorPointerLevel2) + 0x4;
		vars.difficultySelectorAddr = memory.ReadValue<int>((IntPtr)vars.difficultySelectorPointerLevel3) + 0x41B0;

		vars.difficultySelector = new MemoryWatcher<double>((IntPtr)vars.difficultySelectorAddr);
		vars.watchers.AddRange(new MemoryWatcher[]
		{
			vars.difficultySelector
		});
	}


	// Lubella's HP pointer isn't active until she spawns, so rescan every three seconds when we're in that area
	if (vars.levelId.Current == 73 && !vars.stopwatch.IsRunning && vars.lubella1HPMax.Current == 0) {
		vars.stopwatch.Start();
	}
	if (vars.stopwatch.ElapsedMilliseconds > 3000) {
		var module = modules.First();
		var scanner = new SignatureScanner(game, module.BaseAddress, module.ModuleMemorySize);

		vars.lubella1HPBaseAddrCodeTarget = new SigScanTarget(1,
			"A1 ?? ?? ?? ??",		// mov eax,[034ED0EC] ; base address
			"8B 04 B0",				// mov eax,[eax+esi*4]
			"EB 02",				// jmp 0180A504
			"33 C0",				// xor eax,eax
			"80 78 2D 00",			// cmp byte ptr [eax+2D],00
			"75 4D",				// jne 0180A557
			"8B 0D ?? ?? ?? ??",	// ecx,[034EAF3C]
			"8B 90 ?? ?? ?? ??",	// edx,[eax+00000140]
			"83 E9 80",				// ecx,-80
			"85 D2"					// test edx,edx
		);

		vars.lubella1HPBaseAddrCodeAddr = scanner.Scan(vars.lubella1HPBaseAddrCodeTarget);
		vars.lubella1HPBaseAddr = memory.ReadValue<int>((IntPtr)vars.lubella1HPBaseAddrCodeAddr);
		vars.lubella1HPPointerLevel1 = memory.ReadValue<int>((IntPtr)vars.lubella1HPBaseAddr) + 0x8;
		vars.lubella1HPPointerLevel2 = memory.ReadValue<int>((IntPtr)vars.lubella1HPPointerLevel1) + 0x140;
		vars.lubella1HPPointerLevel3 = memory.ReadValue<int>((IntPtr)vars.lubella1HPPointerLevel2) + 0x4;

		vars.lubella1HPAddr = memory.ReadValue<int>((IntPtr)vars.lubella1HPPointerLevel3) + 0x230;
		vars.lubella1HPMaxAddr = memory.ReadValue<int>((IntPtr)vars.lubella1HPPointerLevel3) + 0x240;

		vars.lubella1HP = new MemoryWatcher<double>((IntPtr)vars.lubella1HPAddr);
		vars.lubella1HPMax = new MemoryWatcher<double>((IntPtr)vars.lubella1HPMaxAddr);
		vars.watchers.AddRange(new MemoryWatcher[]
		{
			vars.lubella1HP,
			vars.lubella1HPMax
		});

		vars.stopwatch.Reset();
	}

	

	vars.watchers.UpdateAll(game);
}

start
{
	// If we were in the difficulty menu and then left it
	// it's impossible to go back to title from difficulty menu
	if (vars.difficultySelector.Old > 0 && vars.difficultySelector.Current == 0) {
		// get rid of the memory watcher for difficultySelector to prevent false starts when the pointer is changed in game
		// we scan for a new pointer when we enter the difficulty menu
		vars.difficultySelector = new MemoryWatcher<double>(IntPtr.Zero);
		print("start returned true!");
		return true;
	}
}

reset
{
	// inGame could be set to 0 when respawning after a death
	// to prevent this tripping we check that characterHP is 30
	// under normal circumstances, when dead characterHP is 0
	// characterHP is set to 30 when returning to the title menu
	// if this *still* causes trouble we should rewrite it to check levelId
	if (vars.levelId.Current == 1 && vars.levelId.Old != 1) {
		print("reset returned true!");
		return true;
	}
}

split
{


	// various flags are set during or at the beginning of boss fights, which is why we use cutsceneProgress trickery.
	// vars.inGame.Old is to prevent splits upon loading a save.

	// Edea
	if (settings["edea"] && vars.edeaDefeated.Old == 0 && vars.edeaDefeated.Current == 1 && vars.inGame.Old == 1) {
		print("Edea defeated!");
		return true;
	}
	// Lubella 1
	if (settings["lubella1"] && vars.lubella1HP.Current <= 11 && vars.lubella1HP.Old > 11 && vars.lubella1HPMax.Current == 130) {
		print("Lubella 1 defeated!");
		vars.lubella1Defeated = true;
		return true;
	}

	// Frida
	if (settings["frida"] && vars.levelId.Current == 141 && vars.cutsceneProgress.Current == 0 && vars.cutsceneProgress.Old == 500) {
		print("Frida defeated!");
		return true;
	}
	// Lubella 2
	if (settings["lubella2"] && vars.cutsceneProgress.Current == 0 && vars.cutsceneProgress.Old == 500 && vars.levelId.Current == 147) {
		print("Lubella 2 defeated!");
		return true;
	}
	// Arsonist
	if (settings["arsonist"] && vars.arsonistDefeated.Old == 0 && vars.arsonistDefeated.Current == 1 && vars.inGame.Old == 1) {
		print("Arsonist defeated!");
		return true;
	}
	// Fennel - SPLITS AT END OF CUTSCENE, WILL PROBABLY CHANGE LOGIC LATER
	if (settings["fennel"] && vars.fennelDefeated.Old == 0 && vars.fennelDefeated.Current == 1 && vars.inGame.Old == 1) {
		print("Fennel defeated!");
		return true;
	}
	// Lupiar & Magnolia - Splits when talking to Magnolia
	if (settings["magnolia"] && vars.magnoliaDefeated.Old == 0 && vars.magnoliaDefeated.Current == 1 && vars.inGame.Old == 1) {
		print("Magnolia defeated!");
		return true;
	}
	// Clone Angel
	if (settings["cloneAngel"] && vars.cloneAngelDefeated.Old == 0 && vars.cloneAngelDefeated.Current == 1 && vars.inGame.Old == 1) {
		print("Clone Angel defeated!");
		return true;
	}
	// Queen
	if (settings["queen"] && !settings["100%Check"] && vars.levelId.Current == 232 && vars.cutsceneProgress.Old != 1000 && vars.cutsceneProgress.Current == 1000) {
		print("Queen defeated!");
		return true;
	}

	// Queen 100%
	if (settings["queen"] && settings["100%Check"] && vars.levelId.Current == 232 && vars.cutsceneProgress.Old != 1000 && vars.cutsceneProgress.Current == 1000) {
		print("Checking 100% conditions:");
		print("Has Choir been defeated?: " + Convert.ToBoolean(vars.choirDefeated.Current));
		print("Bug ivories collected: " + vars.ivoryBugs.Current + "/20.");
		print("Vitality fragments collected: " + vars.vitalityFragments.Current + "/17.");
		if (vars.choirDefeated.Current == 1 && vars.ivoryBugs.Current == 20 && vars.vitalityFragments.Current == 17) {
			return true;
		}
	}

	// Choir
	if (settings["choir"] && vars.choirDefeated.Old == 0 && vars.choirDefeated.Current == 1 && vars.inGame.Old == 1) {
		print("Choir defeated!");
		return true;
	}

	// Warpstone
	if (settings["warpFragment"] && vars.warpStone.Old == 0 && vars.warpStone.Current == 1 && vars.inGame.Old == 1) {
		print("Warp fragment obtained!");
		return true;
	}
	// Monastery key
	if (settings["monasteryKey"] && vars.monasteryKey.Old == 0 && vars.monasteryKey.Current == 1 && vars.inGame.Old == 1) {
		print("Monastery key obtained!");
		return true;
	}
	// Fresh Spring Leaf
	if (settings["freshSpringLeaf"] && vars.freshSpringLeaf.Old == 0 && vars.freshSpringLeaf.Current == 1 && vars.inGame.Old == 1) {
		print("Fresh Spring Leaf obtained!");
		return true;
	}
}