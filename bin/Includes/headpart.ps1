head {
        
        
    Meta -name viewport -content_tag "width=device-width, initial-scale=1.0"
    #Write-PSHTMLAsset -Type Script -Name BootStrap
    #Write-PSHTMLAsset -Type Style -Name BootStrap
    link -rel 'icon' -href 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fen.wikipedia.org%2Fwiki%2FFlag_of_France&psig=AOvVaw3WtiVAY-KsCSiz0caWJCiQ&ust=1572940287502000&source=images&cd=vfe&ved=0CAIQjRxqFwoTCIiImtGJ0OUCFQAAAAAdAAAAABAD' -type 'image/x-icon'
    Link -href "Style/style.css" -rel stylesheet
    Link -href "Assets/BootStrap/bootstrap.min.css" -rel stylesheet
    Script -src "Assets/BootStrap/bootstrap.min.js"
    link -href "https://fonts.googleapis.com/css?family=Quicksand&display=swap" -rel "stylesheet"
    
    #script -src "styles/chartjs/Chart.bundle.min.js" -type "text/javascript"
    Title "FRPSUG"

}