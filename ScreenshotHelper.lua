-- Screenshot mode in three steps: hide UI, names, and nameplates; show player names;
-- restore the original state

local _, ns = ...
local L = ns.L

-- key binding action from Bindings.xml
local BINDING = "SCREENSHOTHELPER_SHOT"
-- key binding label in the addon's section of Options > Keybindings and on the settings page
BINDING_NAME_SCREENSHOTHELPER_SHOT = L["Next screenshot mode step"]

-- CVars that show unit names and nameplates; missing ones are skipped per client
local NAME_CVARS = {
  "UnitNameOwn", "UnitNameNPC", "UnitNameHostleNPC", "UnitNameInteractiveNPC",
  "UnitNameFriendlySpecialNPCName", "UnitNameNonCombatCreatureName",
  "UnitNameFriendlyPlayerName", "UnitNameFriendlyPetName", "UnitNameFriendlyGuardianName",
  "UnitNameFriendlyTotemName", "UnitNameFriendlyMinionName",
  "UnitNameEnemyPlayerName", "UnitNameEnemyPetName", "UnitNameEnemyGuardianName",
  "UnitNameEnemyTotemName", "UnitNameEnemyMinionName",
  "nameplateShowAll", "nameplateShowEnemies", "nameplateShowFriends",
  "nameplateShowFriendlyPlayers", "nameplateShowFriendlyNPCs",
}

-- CVars that show player names; turned on in step 2, own name unless hidden by setting
local PLAYER_NAME_CVARS = { "UnitNameOwn", "UnitNameFriendlyPlayerName", "UnitNameEnemyPlayerName" }

-- current step: 0 normal, 1 all hidden, 2 player names shown
local step = 0
-- whether the UI was visible before step 1
local uiWasShown = false

-- step 1: remember the original state, then hide UI, names, and nameplates
local function HideAll()
  local saved = ns.db.savedCVars
  for _, name in ipairs(NAME_CVARS) do
    local value = C_CVar.GetCVar(name)
    if value ~= nil then
      saved[name] = value
      C_CVar.SetCVar(name, "0")
      ns.Debug(name .. " " .. value .. " -> 0")
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
    local skip = name == "UnitNameOwn" and ns.Get("hideOwnName")
    if ns.db.savedCVars[name] ~= nil and not skip then
      C_CVar.SetCVar(name, "1")
      ns.Debug(name .. " -> 1")
    end
  end
end

-- original CVar values back; also after a reload or logout during the steps
local function RestoreNames()
  local saved = ns.db.savedCVars
  for name, value in pairs(saved) do
    C_CVar.SetCVar(name, value)
    ns.Debug(name .. " -> " .. value)
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
  { run = HideAll, text = L["UI, names, and nameplates hidden"] },
  { run = ShowPlayerNames, text = L["player names shown"] },
  { run = RestoreAll, text = L["original state restored"] },
}

-- advance to the next step; CVars cannot change in combat
local function Next()
  if InCombatLockdown() then
    return ns.Error(L["not available in combat"])
  end
  step = step % #STEPS + 1
  STEPS[step].run()
  ns.Print(ns.Color("value", L["step"] .. " " .. step .. "/" .. #STEPS) .. ": " .. STEPS[step].text)
  if step == #STEPS then
    step = 0
  end
end

-- current state and settings
local function Status()
  ns.Status(L["step"], step .. "/" .. #STEPS)
  ns.Status(L["Hide own name in step 2"], ns.OnOff(ns.Get("hideOwnName")))
  ns.Status(L["per character"], ns.OnOff(ns.char.perCharacter))
  ns.Detail(ns.Color("muted", L["next step with "]) .. ns.Color("command", ns.slash))
end

-- switch hiding the own name and report the new state
local function HideOwnName(enabled)
  ns.Set("hideOwnName", enabled)
  Status()
end

-- switch per-character settings and report the new state
local function PerCharacter(enabled)
  ns.Set("perCharacter", enabled)
  Status()
end

-- event handlers by event name
local events = {}

-- names back from the last session; stable function so AfterCombat queues it once
local function RestoreSession()
  RestoreNames()
  ns.Print(L["names and nameplates restored from the last session"])
end

-- bindings are known now: add the key binding row; undo steps left open by a reload
function events.PLAYER_LOGIN()
  ns.Keybinding(BINDING, L["Next screenshot mode step"])
  if next(ns.db.savedCVars) then
    ns.Debug("CVars left from the last session")
    -- nameplate CVars are blocked in combat after a reload
    ns.AfterCombat(RestoreSession)
  end
end

-- one frame dispatching all events above
local frame = CreateFrame("Frame")
for event in pairs(events) do
  -- skip events this client does not know
  if C_EventUtils.IsEventValid(event) then frame:RegisterEvent(event) end
end
frame:SetScript("OnEvent", function(_, event, ...)
  events[event](...)
end)

-- saved state: original CVar values while steps are open; settings page once loaded
ns.Store("ScreenshotHelperDB", { savedCVars = {}, hideOwnName = false }, function()
  ns.Settings()
  ns.Checkbox("hideOwnName", L["Hide own name in step 2"],
    L["Step 2 shows only other players' names, not your own"])
end)

-- chat commands
ns.Command({ name = "status", help = L["show the current step and settings"], run = Status })
ns.Command({
  name = "hideown",
  help = L["hide your own name in step 2, or show it"],
  args = { { name = "state", choices = { "on", "off" } } },
  run = function(args) HideOwnName(args.state == "on") end,
})
ns.Command({
  name = "character",
  help = L["use settings for this character only, or the account's"],
  args = { { name = "state", choices = { "on", "off" } } },
  run = function(args) PerCharacter(args.state == "on") end,
})
ns.Command({
  name = "reset",
  help = L["reset the active profile's settings to defaults"],
  run = function()
    ns.ResetSettings()
    ns.Success(L["settings reset to defaults"])
    Status()
  end,
})
ns.Command({
  name = "debug",
  help = L["show what the addon does in chat, until /reload"],
  args = { { name = "state", choices = { "on", "off" } } },
  run = function(args)
    ns.debug = args.state == "on"
    ns.Status(L["debug"], ns.OnOff(ns.debug))
  end,
})
ns.Command({ name = "config", help = L["open the settings page"], run = ns.OpenSettings })
ns.Slash({ "/ssh", "/screenshothelper" }, Next)
