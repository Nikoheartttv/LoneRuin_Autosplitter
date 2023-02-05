state("LoneRuin") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Lone Ruin";
	vars.Helper.LoadSceneManager = true;
	vars.Helper.AlertLoadless();

	vars.lastLevel = "Goop Temple - 6/7";

	var levels = new Dictionary<string, string>
	{
		{ "Infected Gardens - 0/8", "Infected Gardens 1" },
		{ "Infected Gardens - 1/8", "Infected Gardens 2" },
		{ "Infected Gardens - 2/8", "Infected Gardens 3" },
		{ "Infected Gardens - 3/8", "Infected Gardens 4" },
		{ "Infected Gardens - 4/8", "Infected Gardens 5" },
		{ "Infected Gardens - 5/8", "Infected Gardens 6" },
		{ "Infected Gardens - 6/8", "Infected Gardens 7" },
		{ "Infected Gardens - 7/8", "Infected Gardens 8" },
		{ "Ghoul grave - 0/8", "Ghoul Grave 1" },
		{ "Ghoul grave - 1/8", "Ghoul Grave 2" },
		{ "Ghoul grave - 2/8", "Ghoul Grave 3" },
		{ "Ghoul grave - 3/8", "Ghoul Grave 4" },
		{ "Ghoul grave - 4/8", "Ghoul Grave 5" },
		{ "Ghoul grave - 5/8", "Ghoul Grave 6" },
		{ "Ghoul grave - 6/8", "Ghoul Grave 7" },
		{ "Ghoul grave - 7/8", "Ghoul Grave 8" },
		{ "Goop Temple - 0/8", "Goop Temple 1" },
		{ "Goop Temple - 1/8", "Goop Temple 2" },
		{ "Goop Temple - 2/8", "Goop Temple 3" },
		{ "Goop Temple - 3/8", "Goop Temple 4" },
		{ "Goop Temple - 4/8", "Goop Temple 5" },
		{ "Goop Temple - 5/8", "Goop Temple 6" },
		{ "Goop Temple - 6/8", "Goop Temple 7" },
		{ "Goop Temple - 7/8", "Goop Temple 8" },
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
	if (old.Scene != current.Scene) vars.Log("Scene Change: " + current.Scene);

	// logging
	if (old.runStartTime != current.runStartTime) vars.Log("runStartTime change: " + current.runStartTime);
	if (old.Level != current.Level) vars.Log("Level change: " + current.Level);
	if (old.ControlState != current.ControlState) vars.Log("ControlState change: " + current.ControlState);
	if (current.Level == vars.lastLevel && old.ControlState != 1 && current.ControlState == 1) current.lastLevelPauses++;
	if (current.lastLevelPauses != old.lastLevelPauses) vars.Log("LastLevelPauses update: " + current.lastLevelPauses);
}

start
{
	return current.ControlState == 2 && current.Level == "Infected Gardens - 0/8";
}

onStart
{
	if (current.ControlState != 2) timer.IsGameTimePaused = true;
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
