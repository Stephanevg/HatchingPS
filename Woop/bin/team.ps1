



$HTML = html {

    Include -Name headPart

    body {

        div -class 'container' -content {

            Include TopPage
    
            $TeamData = gc '../Agenda/Team.json' -raw | ConvertFrom-Json
            h2 -content {
                $TeamData.Title
            }

            

            Foreach ($member in $TeamData.Members){

                div {
                    "Image place holder"
                }

                ul {
                    li {
                        a -href "$($member.Twitter)" -Content {

                            $member.Twitter
                        }

                    }
                    li {
                        a -href "$($member.website)" -Content {

                            $member.website
                        }

                    }
                    li {
                        a -href "$($member.Github)" -Content {

                            $member.Github
                        }

                    }

                }#End UL

                p {
                    $member.Description
                }

                
            }
           
            
        }

    }

    Include BottomPage
}
$HTML | out-File -Filepath ..\Team.html -Encoding utf8


#start ..\Html\index.html