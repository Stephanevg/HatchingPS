import-module pshtml -force

#Renme module to HatchingPS
Function New-SBSession {
    Param(
        $id,
        $title,
        $abstract,
        $presenterName,
        $twitter_url,
        $website_url,
        $recording_url
    )

    $template = @"
    [
    {
        "id":"$($Id)",
        "title":"$($title)",
        "Abstract" :"$($abstract)",
        "presentername":"$($presentername)",
        "twitter_url": "$($twitter_url)",
        "website_url":"$($website)",
        "recording_url":"$($recording_url)"
    }

]
"@

    return $template | ConvertFrom-Json
}

Function Import-SBSession {
    Param(
        $Path
    )

    $contents = get-Content -Path $Path | ConvertFrom-Json

    return $contents

}


Function Get-SBSiteConfigurationData {
    Param(
        [Parameter(Mandatory=$false)]
        [String]$SectionName,
        [System.IO.DirectoryInfo]$Path
    )
    #Imports structure from "./inputs path"
    $data = [UsergroupConfigurationgData]::New($Path.FullName)
    if($section){
        return $data.GetSection($SectionName)
    }
    return $data
}

Class UsergroupConfigurationgData {
    [System.IO.DirectoryInfo]$FolderPath
    [object] $SiteData

    UsergroupConfigurationgData([System.IO.DirectoryInfo]$Path){
        $this.FolderPath = $Path.FullName
        $AllParentConfigFiles = Get-ChildItem -Path $this.FolderPath -Filter "*.json"
        $AllFolders = Get-ChildItem -Path $this.FolderPath -Directory
        $dataobject = @{}

        foreach($file in $AllParentConfigFiles){
            
            $dataobject.$($file.BaseName) = Get-Content -Path $file.FullName | ConvertFrom-json
        }

        foreach($folder in $AllFolders){
            $folderContent = Get-ChildItem -Path $folder -filter "*.json"
            $dataobject.$($folder.BaseName) = @{}
            foreach($file in $folderContent){

                $dataobject.$($folder.BaseName).$($file.BaseName) = Get-Content -Path $file.FullName | ConvertFrom-json
            }
        }

        $this.SiteData = new-object -type psobject -Property $dataobject
    }

    [object] GetSection($SectionName){
        
        return $this.SiteData.$($sectionName)
    }
}

Function New-Menu {
    Param(
        [UsergroupConfigurationgData] $ConfigurationData
    )

    $AllLinks = $ConfigurationData.ConfigurationData.psobject.Members | ? {$_.memberType -eq 'NoteProperty'} | select-object name

    $menucontent = ul -Content {
    foreach($link in $Alllinks.name){

        li -Content {
            a -href "$($link).html" -Content {
                $($Link)
            }
        }
    }#end of ul -content

    }

    return $menucontent
}

function Write-WithLove {
    $PSHTMLlink = a {"PSHTML"} -href "https://github.com/Stephanevg/PSHTML"  
     $PSHTMLLove = h6 "Generated with &#x2764 using $($PSHTMLlink)" -Class "text-center"
     $PSHTMLLove
}

Function Set-BaseContent {
    <#
        .DESCRIPTION
        creates the site base structure and config files.

        .PARAMETER Path

        Specifiy the location to the folder where the base site shall be created
    #>
    [CmdletBinding()]
    Param(
        [System.IO.DirectoryInfo]$Path,
        [Switch]$PassThru
    )


    if($Path.Exists){

        
        $globalHash = @{}
        $GlobalHash.about = @{"Title" = "";"Content"=""}
        $globalHash.index = @{"title_tab"="ChangeME";"title_main"="ChangeME";"subtitle"="ChangeME"}
        $globalHash.team = @{"members"=@(@{"Name"="ChangeME";"Description"="ChangeME";"Twitter"="ChangeME";"github"="ChangeME";"website"="ChangeME"})} #"00001-Date-Online-Title_of_the_Talk"
        $SessionsHash =  @([ordered]@{"id"="0001";"presenter_name"="";"twitter"="";"website"="";"title"="00001-Date-Online-Title_of_the_Talk";"abstract"="Short description of the talk";"recording"="VIDEO_URL"},[ordered]@{"id"="0001";"presenter_name"="Stéphane van Gulick";"twitter"="stephanevg";"website"="www.powershelldistrict.com";"title"="00001-20230129-Online-Building static web pages in no time! (Introduction to PSHTML)";"abstract"="In this presentation Stéphane will present the fundamentals of PSHTML, and teach how one can create static html pages using powershell in no time!";"recording"="https://www.youtube.com/watch?v=X6ZtS7rWQ9M"})
        #$e = [ordered]@{"id"="0001";"presenter_name"="Stéphane van Gulick";"twitter"="stephanevg";"website"="www.powershelldistrict.com";"title"="00001-20230129-Online-Building static web pages in no time! (Introduction to PSHTML)";"abstract"="In this presentation Stéphane will present the fundamentals of PSHTML, and teach how one can create static html pages using powershell in no time!";"recording"="https://www.youtube.com/watch?v=X6ZtS7rWQ9M"}
        
        if($PassThru){
            $obj = new-object -TypeName psobject -Property $globalHash
            return $obj
        }else{
            $outputsFolder = join-Path -Path $Path.FullName -ChildPath "outputs"
            $InputsFolder = join-Path -Path $Path.FullName -ChildPath "inputs"
            $binfolder = join-Path -Path $Path.FullName -ChildPath "bin"

            #Creating inputs and outputs bin folders
            $Null = New-Item -Path $InputsFolder -ItemType Directory -Force
            $Null = New-Item -Path $outputsFolder -ItemType Directory -Force
            $Null = New-Item -Path $binfolder -ItemType Directory -Force
            $includesFolder = join-Path -Path $binfolder -ChildPath "includes"

            $Null = New-Item -Path $includesFolder -ItemType Directory -Force
            #Creating inputs json files
            foreach($key in $globalHash.keys){
                $FullPath = Join-Path  -Path $InputsFolder -ChildPath ($key + ".json")
                write-verbose "[Set-BaseContent] Exporting key $($key) to $($InputsFolder)"
                $JsonString = $globalHash[$key] | ConvertTo-Json
                Out-File -Path $FullPath -Input $JsonString -Force -Encoding utf8
            }

            #Creating Sessions folder and contents
            $globalHash.sessions = $SessionsHash
            $SessionsFolderPath = Join-Path -Path $InputsFolder -ChildPath "sessions"
            $Null = New-Item -Path $SessionsFolderPath -ItemType Directory -Force

            #Creating sessions in session folder
            foreach($session in $globalHash.sessions){

                $SessionFilePath = Join-Path -Path $SessionsFolderPath -ChildPath ($session.title + ".json")
                write-verbose "[Set-BaseContent] Exporting key $($key) to $($SessionFilePath)"
                $JsonString = $session | ConvertTo-Json
                Out-File -Path $SessionFilePath -Input $JsonString -Force -Encoding utf8
            }


            #Copying base site from the template folder
            $templatesFolder = (Get-SBData).templates
            $AllTemplateFiles = Get-ChildItem -Path $templatesFolder -Exclude "includes"
            foreach($File in $AllTemplateFiles){
                Copy-Item -Path $File.FullName -Destination $binfolder -Force
            }

            $IncludesFolder = Join-Path -Path $templatesFolder -ChildPath "includes"
            $DestinationIncludesFolder = join-Path -Path $binfolder -ChildPath "includes"

            $AllIncludesFiles = Get-ChildItem -Path $IncludesFolder
            foreach($File in $AllIncludesFiles){
                write-verbose "Copying template file $($File.FullName to $($DestinationIncludesFolder)) "
                Copy-Item -Path $File.FullName -Destination $DestinationIncludesFolder -Force
            }

        }
    }

}

Function Import-SBSite {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [System.IO.DirectoryInfo]$Path
    )

    $script:SBSite = Get-SBSiteConfigurationData -Path $Path.FullName
}

Function Get-SBSite {
    [CmdletBinding()]
    Param(

    )

    Return $script:SBSite 
}

Function New-SBSite {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [System.IO.DirectoryInfo]$Path,
        [Switch]$Force
    )

    if($Path.Exists){
        if(!$force){

            Throw "The Site already exists at $($Path). This might overwrite everything in this repository. If you are sure you want to do this, use -Force"
        }
    }

    Set-BaseContent -Path $Path.FullName
    import-SBSite -Path $Path.FullName
    Get-SBSite
    
}

Function Get-SBData {
    [CmdletBinding()]
    Param(

    )

    return $script:sbdata
}

#Starts new here!!!

<#
    Folder structure is as follows:
    SiteName
        SiteConfigs
            SupportsSubFolder/config.json
            AllConfigFiles.json
            index.json
            team.json
            about.json
        SiteInputs
          index.ps1
          about.ps1
          team.ps1  
        sitepages
            team.html
            about.html
        index.html #Index.html needs to be at the root of the folder structure, as Github pages doesn't support index.html files in subfolders (yet?)

            

#>

Class Site {
    [System.IO.DirectoryInfo]$Path
    [object[]]$SiteConfigs #Contains config.json files with site speicifics 
    [Object[]]$SiteInputs # Contains the PSHTML code to generate the html files
    [Object[]]$SitePages #Array of generated HTML files (based on the pshtml files + config)

    Site([System.IO.DirectoryInfo]$Path){
        $this.Path = $Path
        $this.LoadSitePages()
    }

    hidden LoadSitePages(){
        $PagesPath = Join-Path -Path $this.Path.FullName -ChildPath "SitePages"
        $AllPages = Get-ChildItem -Path $PagesPath

        foreach($Page in $AllPages){
            write-verbose "$($Page)"
            $this.SitePages += [SitePageFile]::New($Page.FullName)
        }
    }
    
}


Class SitePageFile {
    [String]$name
    [System.IO.FileInfo]$Path
    [bool]$hasconfigfile
    [SitePageConfig]$config

    SitePageFile([System.IO.FileInfo]$Path){
        if($Path.Exists){
            $this.Path = $Path
        }

        $configfileName = "$($this.name)" + ".json"
        $conf = Get-ChildItem -Path "../SiteInputs" -Filter $configfileName
        if($conf){
            $this.hasconfigfile = $true
            $this.configfile = [SitePageConfig]::new($conf.FullName)
        }

    }

    [bool] HasConfigFile($Name){
        return $true
        #Should get from configfile
    }
}

Class SitePageConfig {
    [System.IO.FileInfo]$Path
    [bool]$Present
    [object]$ConfigData


    SitePageConfig([System.IO.FileInfo]$Path){
        $this.Path = $Path
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
}

$VerbosePreference = "Continue"
$Site = [Site]::New("C:\Users\Stephane\Code\HatchingPS\Woop\")

$PageFile = [SitePageFile]::New("C:\Users\Stephane\Code\HatchingPS\Woop\SiteInputs\about.ps1")
$p = [SitePageConfig]::New("C:\Users\Stephane\Code\MTG-Strasbourg\website\Inputs\about.json")

$hash = @{}
$TemplatesPath = [system.io.directoryinfo](join-Path -Path $PSScriptRoot -ChildPath "templates")
$hash.templates = $TemplatesPath
$Hash.Site = $null

$script:sbdata = new-object -TypeName psobject -Property $hash

#Set-BaseContent -Path "C:\Users\Stephane\Code\MTG-Strasbourg\website\OutTest" -Verbose

#$data = Get-SBSiteConfigurationData  # "C:\Users\Stephane\Code\MTG-Strasbourg\website\Inputs"

#New-MeetupSession -id "1"
#Import-MeetupSession -Path "C:\Users\Stephane\Code\MTG-Strasbourg\website\Inputs\sessions\0001-20160920-Online-Analyse_Syntaxique_de_donnees.json"