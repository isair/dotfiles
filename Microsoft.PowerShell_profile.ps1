# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

Import-Module posh-git
Import-Module oh-my-posh
Set-Theme Darkblood

try { $null = gcm pshazz -ea stop; pshazz init 'default' } catch { }

# Aliases

function .is { Set-Location ~/Projects/isair }

function .il { Set-Location ~/Projects/ilyssa }
function .le { Set-Location ~/Projects/mojilala-mobile }
function .ot { Set-Location ~/Projects/other }

function .gs { git status }
function .ga { git add $args }
function .gap { git add --patch $args }
function .gf { git fetch $args }
function .gfap { git fetch --all --prune $args }
function .gb { git branch $args }
function .gba { git branch -a $args }
function .gch { git checkout $args }
function .grb { git rebase $args }
function .grbi { git rebase -i $args }
function .gcm { git commit $args }
function .gps { git push $args }
function .gl { git log --graph $args }
function .gla { .gl --all $args }
function .glp { git log --graph --full-history --color --pretty=format:'%x1b[31m%h%x09%x1b[32m%d%x1b[0m%x20%s' $args }
function .glpa { .glp --all $args }
function .gpl { git pull $args }
function .gplr { git pull --rebase $args }
function .gd { git diff $args }
function .gdc { git diff --cached $args }
function .gr { git remote $args }
function .grup { git remote update --prune $args }
function .gsw { git show $args }
function .grt { git revert $args }
function .gcp { git cherry-pick $args }

function .bin { bundle install --path="vendor/bundle" $args }
function .bup { bundle update $args }
function .bx { bundle exec $args }

function .changelog { git log --pretty=format:"[%an] %s%n%n%b%n-------" $args }
