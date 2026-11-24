-- Localized strings: English keys with overrides per client locale; loads first in the TOC

local _, ns = ...

-- English defaults: any key without an override shows as itself
ns.L = setmetatable({}, { __index = function(_, key) return key end })

-- German overrides; component keys are the T("...") strings in the component files
if GetLocale() == "deDE" then
  local L = ns.L
  -- component strings
  L["on"] = "an"
  L["off"] = "aus"
  L["Per character"] = "Pro Charakter"
  L["Save the settings below for this character only instead of the whole account"] =
    "Die Einstellungen unten nur für diesen Charakter statt für den ganzen Account speichern"
  L["usage"] = "Verwendung"
  L["commands"] = "Befehle"
  L["show this help"] = "diese Hilfe anzeigen"
  L["unknown command"] = "unbekannter Befehl"
  L["unknown option"] = "unbekannte Option"
  L["see"] = "siehe"
  L["missing"] = "fehlt"
  L["must be a number"] = "muss eine Zahl sein"
  L["must be one of"] = "muss eins sein von"
  L["too many arguments"] = "zu viele Argumente"
  L["from"] = "von"
  L["to"] = "bis"
  L["or"] = "oder"
  -- addon strings
  L["Next screenshot mode step"] = "Nächste Screenshot-Modus-Stufe"
  L["UI, names, and nameplates hidden"] = "UI, Namen und Namensplaketten ausgeblendet"
  L["player names shown"] = "Spielernamen eingeblendet"
  L["original state restored"] = "Ursprünglicher Zustand wiederhergestellt"
  L["not available in combat"] = "im Kampf nicht verfügbar"
  L["names and nameplates restored from the last session"] =
    "Namen und Namensplaketten aus der letzten Sitzung wiederhergestellt"
  L["step"] = "Stufe"
  L["per character"] = "pro Charakter"
  L["next step with "] = "nächste Stufe mit "
  L["show the current step and settings"] = "aktuelle Stufe und Einstellungen anzeigen"
  L["use settings for this character only, or the account's"] =
    "Einstellungen nur für diesen Charakter oder für den Account verwenden"
  L["open the settings page"] = "Einstellungsseite öffnen"
  L["Hide own name in step 2"] = "Eigenen Namen in Stufe 2 ausblenden"
  L["Step 2 shows only other players' names, not your own"] =
    "Stufe 2 zeigt nur die Namen anderer Spieler, nicht den eigenen"
  L["hide your own name in step 2, or show it"] = "eigenen Namen in Stufe 2 ausblenden oder anzeigen"
  L["reset the active profile's settings to defaults"] =
    "Einstellungen des aktiven Profils auf Standard zurücksetzen"
  L["settings reset to defaults"] = "Einstellungen auf Standard zurückgesetzt"
  L["show what the addon does in chat, until /reload"] =
    "im Chat zeigen, was das Addon tut, bis /reload"
end
