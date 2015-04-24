setup_libs () {
  export R_LIBS=$WERCKER_CACHE_DIR/R/library
  mkdir -p $R_LIBS
}

cran_dependencies () {
  Rscript -e 'install.packages("devtools")'\
          -e 'devtools::install_deps(dependencies = TRUE)'
  if [[ $? -ne 0 ]]; then
    fail "CRAN dependencies failed"
  else
    success "CRAN dependencies installed"
  fi
}

github_dependencies () {
  commands=$(for pkg in $@; do
    echo -n " -e 'devtools::install_github(\"$pkg\")'"
  done)
  Rscript $commands
  if [[ $? -ne 0 ]]; then
    fail "Github dependencies failed"
  else
    success "Github dependencies installed"
  fi
}

setup_libs

cran_dependencies

if [ ! -z "$WERCKER_R_DEPENDENCIES_GITHUB_PACKAGES" ]; then
  github_dependencies "$WERCKER_R_DEPENDENCIES_GITHUB_PACKAGES"
fi

success 'R dependencies installed'
