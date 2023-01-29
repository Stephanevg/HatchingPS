
import-module pshtml -force
Function New-BootStrapModal {
    [Cmdletbinding()]
    Param(

    [String]$Id
    )

    div -Class "modal fade" -id $Id -Attributes @{tabindex="-1";} -Content {

    }
}

<#
<!-- Button trigger modal -->
<button type="button" class="btn btn-primary" data-toggle="modal" data-target="#exampleModal">
  Launch demo modal
</button>

<!-- Modal -->
<div class="modal fade" id="exampleModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="exampleModalLabel">Modal title</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        ...
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
        <button type="button" class="btn btn-primary">Save changes</button>
      </div>
    </div>
  </div>
</div>

#>

$HTML = html {
   
    Include -Name headPart

    body {

        div -Class "container" -Content {
     
            include -Name TopPage

            h3 -Content {
                "Events"
            }
            
            $AllAgendaFiles = gci ../Agenda/ -file | ? {$_.Name -notlike "*about.json" -and $_.Name -notlike "*Team.json"}



            $AllObjects = @()

            Foreach($AgendaFile in $AllAgendaFiles){
                $Hash = @{}
                
                $Naming = $AgendaFile.BaseName.Split("-")
                $Hash.BaseName = $AgendaFile.BaseName
                $Hash.Date = $Naming[1]
                $Hash.Type = $Naming[2]
                $Hash.Title = $Naming[3].Replace("_"," ")
                $Hash.DetailsUrl = $($AgendaFile.Name.Replace(".json",".html"))
                $Hash.DetailsFilePath = $($AgendaFile.Name.Replace(".json",".html"))
                $Link = $null
                $Link = a -href $Hash.DetailsUrl -Content {
                    button -Content {
                        "Details"
                    } -Class "btn btn-outline-primary"
                } -Target _self 

                $Hash.Link = $Link
                $jsondata = gc $AgendaFile.FullName -raw | convertfrom-json
                $Hash.TalkDetails_raw = $jsondata
                
                foreach($talk in $hash.TalkDetails_raw){
                    if($talk.Twitter -ne "" -and $talk.Twitter -ne $null){
                        $twitterLink = $null
                        $TwitterLink = a -href $talk.Twitter  -Content {
                            button -Content {
                                "Twitter"
                            } -Class "btn btn-outline-primary"
                        } -Target _blank 

                        $Talk.Twitter = $twitterLink
                    }else{
                        $twitterLink = $null
                        $TwitterLink = button -Content {
                                "N/A"
                            } -Class "btn btn-outline-primary"
                       

                        $Talk.Twitter = $twitterLink
                    }

                    if($talk.Website -ne "" -and $talk.Website -ne $null){
                        $Websitelink = $null
                        $Websitelink = a -href $Talk.website  -Content {
                            button -Content {
                                "website"
                            } -Class "btn btn-outline-primary"
                        } -Target _blank 

                        $Talk.Website = $Websitelink
                    }else{
                        $Websitelink = $null
                        $Websitelink = button -Content {
                                "N/A"
                            } -Class "btn btn-outline-primary"
                        

                        $Talk.Website = $Websitelink
                    }

                    if($talk.Recording -ne "" -and $talk.Recording -ne $null){
                        $RecordingLink = $null
                        $RecordingLink = a -href $talk.recording  -Content {
                            button -Content {
                                "Recording"
                            } -Class "btn btn-outline-primary"
                        } -Target _blank 

                        $Talk.Recording = $RecordingLink

                        
                        
                        $Hash.Video = $RecordingLink


                    }else{
                        $RecordingLink = $null
                        $RecordingLink =  button -Content {
                                "N/A"
                            } -Class "btn btn-outline-primary"
                       

                        $Talk.Recording = $RecordingLink
                        $Hash.Video = $RecordingLink
                    }
                    

                }

                
                $AllObjects += New-Object -TypeName psobject -Property $Hash
                
                

                $jsondata = $null
                $Link = $null
                $RecordingLink = $null
            }

            ConvertTo-PSHTMLTable -Object $AllObjects -Properties Date,Type,Title,Link,Video -TableClass "table" -TheadClass "thead-dark"

            #Create details page
            foreach($meetup in $AllObjects){

                $DetailPage = html {
                    include headpart
                    body {
                        div -Class "container" {

                            include -Name TopPage

                            if($meetup.Type -eq 'Lightning'){
    
                                h3 -Content {
                                    "{0} - {1}" -f $meetup.Date,$meetup.Type,$meetup.Title
                                }
    
                                ConvertTo-PSHTMLTable -Object $meetup.TalkDetails_raw -Properties Id,Title,Abstract,PresenterName,Twitter,Website,Recording -TableClass "table" -TheadClass "thead-dark"
                            }else{
                                h3 -Content {
                                    "{0} - {1}" -f $meetup.Date,$meetup.Type,$meetup.Title
                                }
                                ConvertTo-PSHTMLTable -Object $meetup.TalkDetails_raw -Properties Id,Title,Abstract,PresenterName,Twitter,Website,Recording -TableClass "table" -TheadClass "thead-dark"
                            }
                        }
                    }
                    include BottomPage
                }
                $Current = Get-Location
                $Detailsfolder = $Current.Path.Replace('Bin','Agenda')
                $FilePath = Join-Path "..\" -ChildPath $meetup.DetailsFilePath
                $DetailPage | out-File -Filepath plop.html -Encoding utf8
            }


        }#End container 

    }
       
        
    
    
    Include -Name BottomPage
}

#Out-PSHTMLDocument -OutPath 'Index.html' -HTMLDocument $HTML -Show
$HTML | out-File -Filepath ..\index.html -Encoding utf8
invoke-item ..\index.html