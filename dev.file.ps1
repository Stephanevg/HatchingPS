ipmo "C:\Users\Stephane\Code\HatchingPS\SiteBirth\SiteBirth.psm1" -Force
$Path = "C:\Users\Stephane\Code\HatchingPS\woop\"
Import-SBSite -Path $Path

New-SbSite -Path $Path -force #Creates base site with basic scaffolding
#$Site = Get-SBSite #grabs existing site.
#$Site.SiteData | fl


Get-SBData # is an Internal function. Must be made private