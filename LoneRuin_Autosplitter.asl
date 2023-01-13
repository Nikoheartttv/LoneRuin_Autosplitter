state("LoneRuin") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Lone Ruin";
	vars.Helper.LoadSceneManager = true;
	vars.Helper.AlertLoadless();

	vars.lastLevel = "Goop Temple - 6/7";

	var levels = new Dictionary<string, string>()
	{
		{ "Infected Gardens - 0/7", "Infected Gardens 1" },
		{ "Infected Gardens - 1/7", "Infected Gardens 2" },
		{ "Infected Gardens - 2/7", "Infected Gardens 3" },
		{ "Infected Gardens - 3/7", "Infected Gardens 4" },
		{ "Infected Gardens - 4/7", "Infected Gardens 5" },
		{ "Infected Gardens - 5/7", "Infected Gardens 6" },
		{ "Infected Gardens - 6/7", "Infected Gardens 7" },
		{ "Ghoul grave - 0/7", "Ghoul Grave 1" },
		{ "Ghoul grave - 1/7", "Ghoul Grave 2" },
		{ "Ghoul grave - 2/7", "Ghoul Grave 3" },
		{ "Ghoul grave - 3/7", "Ghoul Grave 4" },
		{ "Ghoul grave - 4/7", "Ghoul Grave 5" },
		{ "Ghoul grave - 5/7", "Ghoul Grave 6" },
		{ "Ghoul grave - 6/7", "Ghoul Grave 7" },
		{ "Goop Temple - 0/7", "Goop Temple 1" },
		{ "Goop Temple - 1/7", "Goop Temple 2" },
		{ "Goop Temple - 2/7", "Goop Temple 3" },
		{ "Goop Temple - 3/7", "Goop Temple 4" },
		{ "Goop Temple - 4/7", "Goop Temple 5" },
		{ "Goop Temple - 5/7", "Goop Temple 6" },
		{ "Goop Temple - 6/7", "Goop Temple 7" },
	};

	settings.Add("levels", true, "Split on end of level");
	foreach (var level in levels.Keys)
	{
		settings.Add(level, true, levels[level], "levels");
	}
}

init
{
	vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
	{
		var gm = mono["GameManager", 1];
		var rm = mono["RunManager", 1];
		var lvl = mono["Level"];
		var p = mono["Player"];

		vars.Helper["IGPause"] = gm.Make<int>("_instance", "pausers", 0xc);
		vars.Helper["runStartTime"] = rm.Make<float>("_instance", "runStartTime");
		vars.Helper["currentSeed"] = rm.Make<int>("_instance", "CurrentSeed");
		vars.Helper["Level"] = rm.MakeString("_instance", "CurrentLevel", lvl["Name"]);
		vars.Helper["ControlState"] = rm.Make<int>("_instance", "Player", p["State"]);

		return true;
	});

	current.lastLevelPauses = 0;
}

update
{
	current.Scene = vars.Helper.Scenes.Active.Name;
	if (old.Scene != current.Scene) print("Scene Change: " + current.Scene);

	// logging
	if (old.runStartTime != current.runStartTime) vars.Log("runStartTime change: " + current.runStartTime.ToString());
	if (old.Level != current.Level) vars.Log("Level change: " + current.Level.ToString());
	if (old.ControlState != current.ControlState) vars.Log("ControlState change: " + current.ControlState.ToString());
	if (current.Level == vars.lastLevel && old.ControlState != 1 && current.ControlState == 1) current.lastLevelPauses++;
	if (current.lastLevelPauses != old.lastLevelPauses) vars.Log("LastLevelPauses update: " + current.lastLevelPauses.ToString());
}

start
{
	return old.ControlState == 1 && current.ControlState == 2 && current.Level == "Infected Gardens - 0/7";
}

onStart
{
	if (current.ControlState == 1) timer.IsGameTimePaused = true;
	current.lastLevelPauses = 0;
}

split
{
	if (current.Level == vars.lastLevel && old.ControlState != 1 && current.ControlState == 1 && current.lastLevelPauses > 1) return true;
	return settings[old.Level] && old.Level != current.Level;
}

reset
{
	return old.runStartTime > 0 && current.runStartTime == 0;
}

isLoading
{
	return current.ControlState == 1;
}

exit
{
	vars.Helper.Dispose();
}

shutdown
{
	vars.Helper.Dispose();
}
