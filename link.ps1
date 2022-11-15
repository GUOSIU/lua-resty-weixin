
$path = "./nginx/app/demo/api/wx"
$link = "./nginx/resty/weixin"

if (Test-Path $path) {
    Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
}
New-Item -Path $path -ItemType Junction -Value $link | Out-Null
