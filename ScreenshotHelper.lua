-- Clean screenshot: hide UI, unit names, and nameplates, capture, then restore everything

local _, ns = ...

-- key binding label in Options > Keybindings > AddOns
BINDING_NAME_SCREENSHOTHELPER_SHOT = "Take clean screenshot"

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

-- seconds between hiding and capturing, so the hidden state is rendered
local CAPTURE_DELAY = 0.1
-- seconds until restoring anyway when no screenshot event arrives
local RESTORE_TIMEOUT = 5

-- original CVar values changed for the running shot
local saved = {}
-- whether the UI was visible before the shot
local uiWasShown = false
-- whether a shot is running
local busy = false
-- fallback timer for restoring
local fallback

-- bring back the UI and the original CVar values; only called out of combat
local function Restore()
  for name, value in pairs(saved) do
    SetCVar(name, value)
    saved[name] = nil
  end
  if uiWasShown then
    SetUIVisibility(true)
  end
  busy = false
end

-- restore now, or right after combat when it started during the shot
local function Finish()
  if not busy then
    return
  end
  if fallback then
    fallback:Cancel()
    fallback = nil
  end
  if InCombatLockdown() then
    ns.Warn("combat started: UI and names return after combat")
  end
  ns.AfterCombat(Restore)
end

-- turn off every known name and nameplate CVar, remembering its value
local function HideNames()
  for _, name in ipairs(NAME_CVARS) do
    local value = GetCVar(name)
    if value ~= nil and value ~= "0" then
      saved[name] = value
      SetCVar(name, "0")
    end
  end
end

-- hide everything, capture after a short delay, restore on the screenshot event
local function Shot()
  if busy then
    return
  elseif InCombatLockdown() then
    return ns.Error("not available in combat")
  end
  busy = true
  uiWasShown = UIParent:IsShown()
  if not ns.Get("showNames") then
    HideNames()
  end
  if uiWasShown then
    SetUIVisibility(false)
  end
  C_Timer.After(CAPTURE_DELAY, Screenshot)
  fallback = C_Timer.NewTimer(RESTORE_TIMEOUT, Finish)
end

-- current settings
local function Status()
  ns.Status("show names", ns.OnOff(ns.Get("showNames")))
  ns.Status("per character", ns.OnOff(ns.char.perCharacter))
  ns.Detail(ns.Color("muted", "take a screenshot with ") .. ns.Color("command", ns.slash))
end

-- switch names in screenshots and report the new state
local function ShowNames(enabled)
  ns.Set("showNames", enabled)
  Status()
end

-- switch per-character settings and report the new state
local function PerCharacter(enabled)
  ns.Set("perCharacter", enabled)
  Status()
end

-- event handlers by event name
local events = {}

-- screenshot saved: restore
function events.SCREENSHOT_SUCCEEDED()
  Finish()
end

-- screenshot failed: restore and report
function events.SCREENSHOT_FAILED()
  if busy then
    ns.Error("screenshot failed")
  end
  Finish()
end

-- one frame dispatching all events above
local frame = CreateFrame("Frame")
for event in pairs(events) do
  frame:RegisterEvent(event)
end
frame:SetScript("OnEvent", function(_, event, ...)
  events[event](...)
end)

-- saved state; settings page once loaded
ns.Store("ScreenshotHelperDB", { showNames = false }, function()
  ns.Settings()
  ns.Checkbox("showNames", "Show names and nameplates",
    "Keep unit names and nameplates visible in the screenshot")
end)

-- chat commands
ns.Command({ name = "status", help = "show the current settings", run = Status })
ns.Command({
  name = "names",
  help = "keep names and nameplates in the screenshot, or hide them",
  args = { { name = "state", choices = { "on", "off" } } },
  run = function(args) ShowNames(args.state == "on") end,
})
ns.Command({
  name = "character",
  help = "use settings for this character only, or the account's",
  args = { { name = "state", choices = { "on", "off" } } },
  run = function(args) PerCharacter(args.state == "on") end,
})
ns.Command({ name = "config", help = "open the settings page", run = ns.OpenSettings })
ns.Slash({ "/ssh", "/screenshothelper" }, Shot)
