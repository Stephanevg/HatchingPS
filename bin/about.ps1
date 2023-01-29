

$HTML = html {

    Include -Name headPart

    body {

        div -class 'container' -content {

            Include TopPage
    
            $AboutData = gc '../Agenda/about.json' -raw | ConvertFrom-Json

            h2 -content {
                $AboutData.title
            }
            p {
                $AboutData.content
            }
        }

    }

    Include BottomPage
}

$HTML | out-File -Filepath ..\About.html -Encoding utf8


#start ..\Html\index.html