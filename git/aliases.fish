function g
  if [ (count $argv) -eq 0 ]
    git status -sb
  else
    git $argv
  end
end

function gl
  git log --pretty=oneline --decorate --abbrev-commit
end
