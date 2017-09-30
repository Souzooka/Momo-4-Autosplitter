// Bosses die at <= 11 HP

state("MomodoraRUtM", "v1.05b Steam") 
{
	// For tracking if we leave to the main menu
	byte LevelId : 0x230F1A0;

	// For start
	double DifficultySelector : 0x22C5A7C, 0xCB4, 0xC, 0x4, 0x41B0;

	// Pointer for various flags
	int FlagsPtr : 0x230C440, 0x0, 0x4, 0x60, 0x4, 0x4;
	double InGame : 0x230C440, 0x0, 0x4, 0x780;

	// Various boss flags not covered by FlagsPtr
	// Note: When updating, *actual health values* for these bosses can be found at these paths, except with a last offset of 0x230
	double Lubella : 0x231138C, 0x8, 0x140, 0x4, 0xCA0;
	double Frida : 0x231138C, 0x34, 0x13C, 0x4, 0x1210;
}

startup
{
	// SETTINGS START //
	settings.Add("100%Check", false, "100% Run");
	settings.Add("splits", true, "All Splits");

	settings.Add("edea", true, "Edea", "splits");
	settings.Add("lubella1", true, "Lubella 1", "splits");
	settings.Add("gardenKey", false, "Garden Key", "splits");
	settings.Add("frida", true, "Frida", "splits");
	settings.Add("fastChargeFragment", false, "Fast Charge Fragment", "splits");
	settings.Add("lubella2", true, "Lubella 2", "splits");
	settings.Add("soldier", true, "Soldier", "splits");
	settings.Add("warpFragment", true, "Warp Fragment", "splits");
	settings.Add("arsonist", true, "Arsonist", "splits");
	settings.Add("dashFragment", false, "Dash Fragment", "splits");
	settings.Add("monasteryKey", true, "Monastery Key", "splits");
	settings.Add("fennel", true, "Fennel", "splits");
	settings.Add("superChargeFragment", false, "Super Charge Fragment", "splits");
	settings.Add("sealedWind", false, "Sealed Wind", "splits");
	settings.Add("magnolia", true, "Lupiar and Magnolia", "splits");
	settings.Add("heavyArrows", false, "Heavy Arrows", "splits");
	settings.Add("freshSpringLeaf", true, "Fresh Spring Leaf", "splits");
	settings.Add("cloneAngel", true, "Clone Angel", "splits");
	settings.Add("queen", true, "Queen", "splits");
	settings.Add("choir", false, "Choir", "splits");
	settings.SetToolTip("100%Check", "If checked, will only split for Queen if Choir is defeated, 17 vitality fragments were obtained, and 20 bug ivories were collected.");
	// SETTINGS END //
}

init
{
	// HashSet to hold splits already hit
	// In case of dying after triggering a split, triggering it again can cause a false double split without this
	vars.Splits = new HashSet<string>();

	// Last offsets of FlagsPtr to read
	Dictionary<string, int> flagOffsets = new Dictionary<string, int>
	{
		{"edea",                0xE0},
		{"gardenKey",           0x700},
		{"fastChargeFragment",  0x5B0},
		{"soldier",             0x4D0},
		{"warpFragment",        0x5C0},
		{"arsonist",            0x9E0},
		{"dashFragment",        0x5D0},
		{"monasteryKey",        0x260},
		{"fennel",              0x3D0},
		{"superChargeFragment", 0x5A0},
		{"sealedWind",          0xA90},
		{"magnolia",            0x660},
		{"heavyArrows",         0x670},
		{"freshSpringLeaf",     0x600},
		{"cloneAngel",          0x640},
		{"choir",               0x6A0},
		{"ivoryBugs",           0x3C0},
		{"vitalityFragments",   0xAE0},
	};

	// Dictionary which holds MemoryWatchers that correspond to each flag
	vars.Flags = flagOffsets.Keys
	  .ToDictionary(key => key, key => new MemoryWatcher<double>((IntPtr)current.FlagsPtr + flagOffsets[key]));

	// Function that'll return if 100% conditions are met
	vars.Is100Run = (Func<bool>)(() =>
	{
		return vars.Flags["choir"].Current && 
			   vars.Flags["vitalityFragments"].Current == 17 && 
			   vars.Flags["bugIvories"].Current == 20;
	});
}

update
{
	// Clear any hit splits if timer stops
	if (timer.CurrentPhase == TimerPhase.NotRunning)
	{
		vars.Splits.Clear();
	}

	// Update all MemoryWatchers in vars.Flags
	new List<MemoryWatcher<double>>(vars.Flags.Values).ForEach((Action<MemoryWatcher<double>>)(mw => mw.Update(game)));
}

start
{
	return (old.DifficultySelector > 0 && current.DifficultySelector == 0);
}

reset
{
	return (current.LevelId == 1 && old.LevelId != 1);
}

split
{
	// Only split if we're in-game
	if (current.InGame == 1)
	{
		// Split if a flag has changed
		// Note: Some values count things, like enemies defeated. These will fail silently.
		foreach (string key in vars.Flags.Keys)
		{
			if (vars.Flags[key].Old != vars.Flags[key].Current)
			{
				vars.Splits.Add(key);
				return settings[key];
			}
		}

		// Lubella 1
		if (current.Lubella > 0 && old.Lubella == 0 && current.LevelId == 73)
		{
			vars.Splits.Add("lubella1");
			return settings["lubella1"];
		}

		// Lubella 2
		if (current.Lubella > 0 && old.Lubella == 0 && current.LevelId == 147)
		{
			vars.Splits.Add("lubella2");
			return settings["lubella2"];
		}

		// Frida
		if (current.Frida == 7 && old.Frida != 7)
		{
			vars.Splits.Add("frida");
			return settings["frida"];
		}

		// Queen
		if (true /* TODO */)
		{
			// 100% check if applicable
			if (settings["100%Check"] && !vars.Is100Run())
			{
				return false;
			}
		}
	}
}