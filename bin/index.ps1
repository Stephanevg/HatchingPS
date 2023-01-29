#Load ConfigData
$PageNAme = ([system.io.Fileinfo]$MyInvocation.MyCommand.Name).BaseName
$AllConfigData = Get-UserGroupConfigurationData
$ConfigData = $AllConfigData.GetConfigData($PageName)
$HTML = html {
    head {
        

        $tab_logo = "../assets/img/mtg-strasbourg-bretzel_400x400.jpg"
        Meta -name viewport -content_tag "width=device-width, initial-scale=1.0"
        #Write-PSHTMLAsset -Type Script -Name BootStrap
        #Write-PSHTMLAsset -Type Style -Name BootStrap
        link -rel 'icon' -href $tab_logo -type 'image/x-icon'
        Link -href "Style/style.css" -rel stylesheet
        Link -href "Assets/BootStrap/bootstrap.min.css" -rel stylesheet
        Script -src "Assets/BootStrap/bootstrap.min.js"
        link -href "https://fonts.googleapis.com/css?family=Quicksand&display=swap" -rel "stylesheet"
        
        #script -src "styles/chartjs/Chart.bundle.min.js" -type "text/javascript"
        Title -Content $configdata.title_tab
    }
    body {

        div -Class "container" -Content {
                Get-menu
            
        div -class 'jumbotron container-fluid' -content {
            h1 -class 'display-4 title_main' -content $configdata.title_main  -Style "color:#d5caf7;"
            hr -Class "my-4"
            
            img -src "C:\Users\Stephane\Code\MTG-Strasbourg\website\assets\img\mtg-strasbourg-bretzel_400x400.jpg" -alt "Powershell Logo" -height "250" -width "250" -Class "img-responsive"
            
            p -Class "lead title_sub" -Content $configdata.subtitle -Style "color:#d5caf7;"

        } -Style "background-image:url(C:/Users/Stephane/Code/MTG-Strasbourg/website/assets/img/background.jpg);background-size: cover;"
        #h6 -Class "text-center" -Content {"Switzerland &#x2764 Powershell"}
        

            div -id "listmembers" -class "container-fluid" -Content {
                h3 "Was ist eine Powershell Usergroup"
                
                p "Eine Powershell Usergroup ist eine Gruppe aus IT-Pros die ein grosses Interesse an Powershell haben, taeglich mit Powershell arbeiten oder sich fuer Powershell interessieren und gerne ihr Wissen ausbauen/teilen moechten."

                p {
                    "Falls du interessiert daran bist Teilzunehmen Fuelle das Formular unten kurz aus um dein Interesse zu zeigen:"
                }
                a -href "https://bit.ly/31jdJFC" -content {
                    button -Content {
                        "Zum Formular"
                    } -Class "btn btn-outline-primary"
                } -Target _blank    
            }
            
            div -id "removeuser" -class "container-fluid" -Content {

                h3 {
                    "Was macht die Schweizer Powershell Usergroup"
                }

                p "Die Schweizer Powershell Usergruppe trifft sich einmal monatlich online! In so einem online meetup finden Lightning Demons (15-20 Minuetige Praesentationen) statt und sie ermoeglichen den Austausch mit anderen IT-Pros ueber Powershell."

                p "Die Events finden jeweils am ersten Dienstag im Monat um 17:00 statt und sie dauern etwa eine Stunde. HIer die naechsten Events:"


            }

            Div -id "somediv" -class "Container-Fluid" -Content {
                h2 "Upcoming Events"

                $Link = a -href "https://chpsug.com/meetup" -Content {
                    button -Content {
                        "Online Meetup"
                    } -Class "btn btn-outline-primary"
                } -Target _blank 

                $EventArr = @()

                $EventHash1 = @{
                    Wo = "Online"
                    wann = "Dienstag 5. November 2019"
                    Uhrzeit = "17:00"
                    LinkToJoin = $Link
                    Number = 1
                }
                $EventObj1 =  new-Object psobject -property $EventHash1
                $EventArr += $EventObj1

                $EventHash2 = @{
                    Wo = "Online"
                    wann = "Dienstag 3. Dezember 2019"
                    Uhrzeit = "17:00"
                    LinkToJoin = $Link
                    Number = 2
                }
                $EventObj2 =  new-Object psobject -property $EventHash2
                $EventArr += $EventObj2

                $EventHash3 = @{
                    Wo = "Online"
                    wann = "Dienstag 7. Januar 2020"
                    Uhrzeit = "17:00"
                    LinkToJoin = $Link
                    Number = 3
                }
                $EventObj3 =  new-Object psobject -property $EventHash3
                $EventArr += $EventObj3

                ConvertTo-PSHTMLTable -Object ($EventArr | sort number) -Properties Wo,Wann,Uhrzeit,LinkToJoin -TableClass "table" -TheadClass "thead-dark"
            }
        
            } 

        }
       
        
    
    
    footer -Content {
        $PSHTMLLove
    }
}

$HTML | out-File -Filepath "$($PageName).html" -Encoding utf8


#start ..\Html\index.html