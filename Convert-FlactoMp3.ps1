$flacloc = "d:\users\nick.admin\Downloads\ffmpeg-20161230-6993bb4-win64-static\bin"
#$flacloc = "$env:USERPROFILE\Downloads\ffmpeg-20161230-6993bb4-win64-static\bin"

$flacs = Get-ChildItem | Where-Object {$_.name.toupper().EndsWith(".FLAC")}

foreach ($flac in $flacs)
{

    & "$flacloc\ffmpeg.exe" -i $flac -ab 320k -map_metadata 0 -id3v2_version 3 $flac.name.Replace(".flac",".mp3")

}