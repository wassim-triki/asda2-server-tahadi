# we want to copy ../Run/Releasex86 and ../Run/Content into ../dist/a-folder-we-generate and zip that folder


# TODO: invoke MSBuild
# Check if MSBuild is in path



# path of roject root
$root= Split-Path -Parent  $PSScriptRoot 

# path of Run folder content and release
$content = "$root\Run\Content" 
$release = "$root\Run\ReleaseX86" 
# path of dist folder
$dist = "$root\dist" 

# TODO: check name and concidering veriosning
$package = "$dist\Asda2-Server-Windows-x86"




if(Test-Path $package){
  Remove-Item -Path $package -Force -Recurse
}
# Create the destination folder
New-Item -Path $package -ItemType Directory

# Copy over only the needed Content and Realse files and folders
$excludedReleaseFiles = "*.pdb", "RealmServerConfig.xml", "RealmServerConfig.xml.bak"
$excludedReleaseFolders = "logs"

robocopy $release "$package\ReleaseX86" /E /XF $excludedReleaseFiles /XD $excludedReleaseFolders
robocopy $content "$package\Content" /E

# Zip up the package
Compress-Archive -Path $package -DestinationPath $package -Force
