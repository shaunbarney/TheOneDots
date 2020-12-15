function cd {
    builtin cd "$@"
    if [ -f "Pipfile" ] ; then
        pipenv shell
    fi
  }
