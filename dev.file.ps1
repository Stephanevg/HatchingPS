#ipmo "C:\Users\Stephane\Code\HatchingPS\SiteBirth\SiteBirth.psm1" -Force
$Path = "C:\Users\Stephane\Code\HatchingPS\woop\"
#Import-SBSite -Path $Path


Class Site {
    [System.IO.DirectoryInfo]$SitePath
    [System.IO.DirectoryInfo]$SiteConfigsPath
    [System.IO.DirectoryInfo]$SiteInputsPath
    [System.IO.DirectoryInfo]$SitePagesPath
    [object[]]$SiteConfigs = @() #Contains config.json files with site speicifics 
    [Object[]]$SiteInputs = @() # Contains the PSHTML code to generate the html files
    [Object[]]$SitePages = @() #Array of generated HTML files (based on the pshtml files + config)

    Site([System.IO.DirectoryInfo]$Path){
        $this.SitePath = $Path
        $this.SiteConfigsPath = join-Path -Path $this.SitePath.FullName -ChildPath "SiteConfigs"
        $this.SiteInputsPath = join-Path -Path $this.SitePath.FullName -ChildPath "SiteInputs"
        $this.SitePagesPath = join-Path -Path $this.SitePath.FullName -ChildPath "SitePages"
        $this.LoadSiteConfigs()
        $this.LoadSiteInputs()
        $this.LoadSitePages()
    }

    [System.IO.DirectoryInfo] GetSiteInputsPath(){
        Return $this.SiteInputsPath
    }

    [System.IO.DirectoryInfo] GetSiteConfigsPath(){
        Return $this.SiteConfigsPath
    }

    [System.IO.DirectoryInfo] GetSitePagesPath(){
        Return $this.SitePagesPath
    }

    [void] LoadSiteInputs(){
        $InputsPath = $This.GetSiteInputsPath()
        $items = Get-ChildItem -Path $InputsPath.FullName

        foreach($item in $items){
            write-verbose "$($Item)"
            $sif = [SiteInputFile]::New($item.FullName)
            
            $RelPath = [System.Io.Path]::GetRelativePath($this.SiteInputsPath.FullName,$item.FullName)
            $sif.SetRelativePath($RelPath)
            $this.SiteInputs += $sif
        }
    }

    [void] hidden  LoadSitePages(){
        $pp = $this.GetSitePagesPath()
        $AllPages = Get-ChildItem -Path $pp.FullName

        foreach($Page in $AllPages){
            write-verbose "[SitePage]$($Page)"
            $sp = [SitePageFile]::New($Page.FullName)
            $RelPath = [System.Io.Path]::GetRelativePath($this.SitePagesPath.FullName,$Page.FullName)
            $sp.SetRelativePath($RelPath)
            $this.SitePages += $sp
        }
    }

    [void] hidden  LoadSiteConfigs(){
        $ConfigPath = $this.GetSiteConfigsPath()
        $AllConfigs = Get-ChildItem -Path $ConfigPath.FullName -Recurse -File

        foreach($ConfigFile in $AllConfigs){
            write-verbose "$($ConfigFile)"
            $spcf = [SitePageConfigFile]::New($ConfigFile.FullName)
            $RelPath = [System.Io.Path]::GetRelativePath($this.SiteConfigsPath.FullName,$ConfigFile.FullName)
            $spcf.SetRelativePath($RelPath)
            $this.SiteConfigs += $spcf
        }
    }

    [SitePageConfigFile] GetSiteConfigFile([String]$Name){

        Return $this.SiteConfigs | ? {$_.Name -eq $Name} #Need to test this. Arriving in Bern
        
    }

    
    
}


Class SitePageFile {
    [String]$name
    [System.IO.FileInfo]$Path
    [Object]$PageContent
    [bool]$ConfigFilePresent
    [SitePageConfigFile]$config
    [string]$RelativePath

    SitePageFile([System.IO.FileInfo]$Path){
        if($Path.Exists){
            $this.Path = $Path
            $this.name = $this.Path.BaseName
            $this.PageContent = Get-Content $this.Path -Encoding utf8
        }
        #$pd = $this.Path.Directory
        
        <#
        $pd = ([System.IO.DirectoryInfo] $this.path.FullName).Parent.parent #Going back to root of site
        
        $SiteConfigsFolder = Join-Path -Path $pd.FullName -ChildPath "SiteConfigs"
        $configfileName = "$($this.name)" + ".json"
        $conf = Get-ChildItem -Path $SiteConfigsFolder -Filter $configfileName
        if($conf){
            $this.ConfigFilePresent = $true
            $this.config = [SitePageConfig]::new($conf.FullName)
        }
        #>

    }

    [bool] HasConfigFile(){
        return $This.ConfigFilePresent
        
    }

    [object]GetConfigData(){
        if($this.HasConfigFile()){
            return $this.config.ConfigData
        }else{
            return $null
        }
    }

    [void]SetConfigFile([SitePageConfigFile]$SitePageConfig){
        $this.ConfigFilePresent = $SitePageConfig.Present
        $this.config = $SitePageConfig
    }

    [void]SetRelativePath([String]$RelPath){
        $this.RelativePath = $RelPath
    }

}

Class SiteInputFile {
    [String]$name
    [System.IO.FileInfo]$Path
    [Object]$PageContent
    [bool]$ConfigFilePresent
    [SitePageConfigFile]$config
    [String]$RelativePath

    SiteInputFile([System.IO.FileInfo]$Path){
        if($Path.Exists){
            $this.Path = $Path
            $this.name = $this.Path.BaseName
            $this.PageContent = Get-Content $this.Path -Encoding utf8
        }
        #$pd = $this.Path.Directory
        
        <#
        $pd = ([System.IO.DirectoryInfo] $this.path.FullName).Parent.parent #Going back to root of site
        
        $SiteConfigsFolder = Join-Path -Path $pd.FullName -ChildPath "SiteConfigs"
        $configfileName = "$($this.name)" + ".json"
        $conf = Get-ChildItem -Path $SiteConfigsFolder -Filter $configfileName
        if($conf){
            $this.ConfigFilePresent = $true
            $this.config = [SitePageConfig]::new($conf.FullName)
        }
        #>

    }

    [bool] HasConfigFile(){
        return $This.ConfigFilePresent
        
    }

    [object]GetConfigData(){
        if($this.HasConfigFile()){
            return $this.config.ConfigData
        }else{
            return $null
        }
    }

    [void]SetConfigFile([SitePageConfigFile]$SitePageConfig){
        $this.ConfigFilePresent = $SitePageConfig.Present
        $this.config = $SitePageConfig
    }

    [void]SetRelativePath([String]$RelPath){
        $this.RelativePath = $RelPath
    }
}

Class SitePageConfigFile {
    [string]$name
    [System.IO.FileInfo]$Path
    [bool]$Present
    [object]$ConfigData
    [String]$RelativePath
    [bool]$SiteInputFilePresent

    SitePageConfigFile([System.IO.FileInfo]$Path){
        $this.Path = $Path
        $this.name = $this.Path.BaseName
        $this.Fetch()
        
    }

    Fetch(){
        $this.Path.Refresh() #Refreshes to the latest state
        if($this.Path.Exists){
            $this.Present = $True
            $this.ConfigData = Get-content -Path $this.path.FullName | ConvertFrom-Json
        }else{
            $this.Present = $false
        }

    }

    [object]GetConfigData(){
        return $this.ConfigData
    }

    [String]ToString(){
        Return $this.Path.Name
    }

    [void]SetRelativePath([String]$RelPath){
        $this.RelativePath = $RelPath
    }
}

Class SitePageConfigFileCollection {
    [System.Collections.Generic.List[SitePageConfigFile]] $SecurityDocuments = [System.Collections.Generic.List[SitePageConfigFile]]::new()


}

$VerbosePreference = "Continue"
$Site = [Site]::New("C:\Users\Stephane\Code\HatchingPS\Woop\")
$site.GetSiteConfigFile("team")

[System.Io.Path]::GetRelativePath($Site.SiteConfigsPath.FullName,$site.SiteConfigs[-1].Path.FullName)

$SitePage = [SitePageFile]::New("C:\Users\Stephane\Code\HatchingPS\Woop\SiteInputs\about.ps1")
$SiteConfig = [SitePageConfigFile]::New("C:\Users\Stephane\Code\MTG-Strasbourg\website\Inputs\about.json")

#Creation base site

New-SbSite -Path $Path -force #Creates base site with basic scaffolding

#grabs existing site.
$Site = Get-SBSite 

<#
PS C:\Users\Stephane\Code\HatchingPS> Get-SBSite | fl

FolderPath : C:\Users\Stephane\Code\HatchingPS\woop\
SiteData   : @{inputs=System.Collections.Hashtable; outputs=System.Collections.Hashtable; bin=System.Collections.Hashtable}
#>

#$Site.SiteData | fl

<#
PS C:\Users\Stephane\Code\HatchingPS> Get-SBSiteConfigurationData -Path ./woop/

FolderPath                              SiteData
----------                              --------
C:\Users\Stephane\Code\HatchingPS\woop\ @{inputs=System.Collections.Hashtable; outputs=System.Collections.Hashtable; bin=System.Collections.Hashtable}

#>



Get-SBSiteConfigurationData -Path ./woop/

Function Get-HTSite {

}

