#!/bin/bash

run_script () {
  temp_file=$(mktemp -t "XXXXXXXXXX.R")
  cat > "$temp_file"
  Rscript "$temp_file"
  if [[ $? -ne 0 ]]; then
    fail "Script $temp_file failed!"
  fi
}

setup_libs () {
  export R_LIBS=$WERCKER_CACHE_DIR/R/library
  mkdir -p "$R_LIBS"
}

cran_dependencies () {
  run_script <<END
repos <- $WERCKER_REPOS
if (is.null(repos)) {
  if (requireNamespace("BiocManager", quietly = TRUE)) {
    repos <- BiocManager::repositories()
  } else {
    repos <- c(CRAN = "http://cran.rstudio.com")
  }
}
options(repos = repos)
devtools::install_deps(dependencies = TRUE)
END

  success "CRAN dependencies installed"
}

github_dependencies () {
  # read values into array
  IFS=' ' read -a pkgs <<< "$1"

  # buildup command argument
  local -a args
  for pkg in "${pkgs[@]}"; do
    args+=("-e" "devtools::install_github(\"$pkg\")")
  done

  # run Rscript
  Rscript "${args[@]}"

  if [[ $? -ne 0 ]]; then
    fail "Github dependencies failed"
  else
    success "Github dependencies installed"
  fi
}

setup_libs

cran_dependencies

if [ ! -z "$WERCKER_GITHUB_PACKAGES" ]; then
  github_dependencies "$WERCKER_GITHUB_PACKAGES"
fi

success 'R dependencies installed'
