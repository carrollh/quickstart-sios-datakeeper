[CmdletBinding()]
param()

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName="*"
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
        },
        @{
            NodeName = 'localhost'
        }
    )
}

Configuration WSFCFileServer {

    Import-Module -Name xSmbShare 
    Import-Module -Name PSDscResources
    
    Import-DscResource -ModuleName xSmbShare
    Import-DscResource -ModuleName PSDscResources

    Node 'localhost' {

        WindowsFeature FileServices {
            Ensure = 'Present'
            Name   = 'File-Services'
        }

        File WitnessFolder {
            Ensure          = 'Present'
            Type            = 'Directory'
            DestinationPath = 'C:\witness'
        }

        File ReplicaFolder {
            Ensure          = 'Present'
            Type            = 'Directory'
            DestinationPath = 'C:\replica'
        }

        xSmbShare WitnessShare {
            Ensure     = 'Present'
            Name       = 'witness'
            Path       = 'C:\witness'
            FullAccess = 'Everyone'
            DependsOn  = '[File]WitnessFolder'
        }

        xSmbShare ReplicaShare {
            Ensure     = 'Present'
            Name       = 'replica'
            Path       = 'C:\replica'
            FullAccess = 'Everyone'
            DependsOn  = '[File]ReplicaFolder'
        }
    }
}

WSFCFileServer -OutputPath 'C:\AWSQuickstart\WSFCFileServer' -ConfigurationData $ConfigurationData

Start-DscConfiguration 'C:\AWSQuickstart\WSFCFileServer' -Wait -Verbose -Force