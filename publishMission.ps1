$missionPath = "$env:USERPROFILE\Saved Games\DCS.openbeta\Missions"
$7zipPath = "$env:ProgramFiles\7-Zip\7z.exe"

if (-not (Test-Path -Path $7zipPath -PathType Leaf)) {
    throw "7 zip file '$7zipPath' not found"
}
Set-Alias 7zip $7zipPath

$tgt = "Iran-Strike-v0.7.miz"
$src = "l10n"

#updates the .miz file with the lua files
7zip u $tgt $src

#copy the mission file to Missions folder
Copy-Item Iran-Strike-v0.7.miz $missionPath