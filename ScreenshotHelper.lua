-- Screenshot mode in three steps: hide UI, names, and nameplates; show player names;
-- restore the original state

local ADDON, ns = ...

-- key binding action from Bindings.xml
local BINDING = "SCREENSHOTHELPER_SHOT"
-- key binding label in Options > Keybindings > AddOns and on the settings page
BINDING_NAME_SCREENSHOTHELPER_SHOT = "Next screenshot mode step"

-- CVars that show unit names and nameplates; missing ones are skipped per client
local NAME_CVARS = {
  "UnitNameOwn", "UnitNameNPC", "UnitNameHostleNPC", "UnitNameInteractiveNPC",
  "UnitNameFriendlySpecialNPCName", "UnitNameNonCombatCreatureName",
  "UnitNameFriendlyPlayerName", "UnitNameFriendlyPetName", "UnitNameFriendlyGuardianName",
  "UnitNameFriendlyTotemName", "UnitNameFriendlyMinionName",
  "UnitNameEnemyPlayerName", "UnitNameEnemyPetName", "UnitNameEnemyGuardianName",
  "UnitNameEnemyTotemName", "UnitNameEnemyMinionName",
  "nameplateShowAll", "nameplateShowEnemies", "nameplateShowFriends",
  "nameplateShowFriendlyPlayers", "nameplateShowFriendlyNpcs", "nameplateShowFriendlyNPCs",
}

-- CVars that show player names, own name included; turned on in step 2
local PLAYER_NAME_CVARS = { "UnitNameOwn", "UnitNameFriendlyPlayerName", "UnitNameEnemyPlayerName" }

-- current step: 0 normal, 1 all hidden, 2 player names shown
local step = 0
-- whether the UI was visible before step 1
local uiWasShown = false

-- step 1: remember the original state, then hide UI, names, and nameplates
local function HideAll()
  local saved = ns.db.savedCVars
  for _, name in ipairs(NAME_CVARS) do
    local value = GetCVar(name)
    if value ~= nil then
      saved[name] = value
      SetCVar(name, "0")
    end
  end
  uiWasShown = UIParent:IsShown()
  if uiWasShown then
    SetUIVisibility(false)
  end
end

-- step 2: show player names again
local function ShowPlayerNames()
  for _, name in ipairs(PLAYER_NAME_CVARS) do
    if ns.db.savedCVars[name] ~= nil then
      SetCVar(name, "1")
    end
  end
end

-- original CVar values back; also after a reload or logout during the steps
local function RestoreNames()
  local saved = ns.db.savedCVars
  for name, value in pairs(saved) do
    SetCVar(name, value)
    saved[name] = nil
  end
end

-- step 3: original state back
local function RestoreAll()
  RestoreNames()
  if uiWasShown then
    SetUIVisibility(true)
  end
end

-- work and chat line per step
local STEPS = {
  { run = HideAll, text = "UI, names, and nameplates hidden" },
  { run = ShowPlayerNames, text = "player names shown" },
  { run = RestoreAll, text = "original state restored" },
}

-- advance to the next step; CVars cannot change in combat
local function Next()
  if InCombatLockdown() then
    return ns.Error("not available in combat")
  end
  step = step % #STEPS + 1
  STEPS[step].run()
  ns.Print(ns.Color("value", "step " .. step .. "/" .. #STEPS) .. ": " .. STEPS[step].text)
  if step == #STEPS then
    step = 0
  end
end

-- current state and settings
local function Status()
  ns.Status("step", step .. "/" .. #STEPS)
  ns.Status("per character", ns.OnOff(ns.char.perCharacter))
  ns.Detail(ns.Color("muted", "next step with ") .. ns.Color("command", ns.slash))
end

-- switch per-character settings and report the new state
local function PerCharacter(enabled)
  ns.Set("perCharacter", enabled)
  Status()
end

-- key binding row on the settings page; same binding as in Options > Keybindings
local function AddKeybinding()
  local title = C_AddOns.GetAddOnMetadata(ADDON, "Title") or ADDON
  local category = Settings.GetCategory(title)
  local layout = category and SettingsPanel:GetLayout(category)
  local index = C_KeyBindings.GetBindingIndex(BINDING)
  if layout and index then
    layout:AddInitializer(CreateKeybindingEntryInitializer(index, true))
  end
end

-- event handlers by event name
local events = {}

-- bindings are known now: add the key binding row; undo steps left open by a reload
function events.PLAYER_LOGIN()
  AddKeybinding()
  if next(ns.db.savedCVars) then
    RestoreNames()
    ns.Print("names and nameplates restored from the last session")
  end
end

-- one frame dispatching all events above
local frame = CreateFrame("Frame")
for event in pairs(events) do
  frame:RegisterEvent(event)
end
frame:SetScript("OnEvent", function(_, event, ...)
  events[event](...)
end)

-- saved state: original CVar values while steps are open; settings page once loaded
ns.Store("ScreenshotHelperDB", { savedCVars = {} }, function()
  ns.Settings()
end)

-- chat commands
ns.Command({ name = "status", help = "show the current step and settings", run = Status })
ns.Command({
  name = "character",
  help = "use settings for this character only, or the account's",
  args = { { name = "state", choices = { "on", "off" } } },
  run = function(args) PerCharacter(args.state == "on") end,
})
ns.Command({ name = "config", help = "open the settings page", run = ns.OpenSettings })
ns.Slash({ "/ssh", "/screenshothelper" }, Next)
