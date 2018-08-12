#!/bin/bash

# Copyright (C) 2018 Matthew Marting
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

if [[ -z ${LIBVERSION_SH+x} ]]; then
  readonly LIBVERSION_SH=

  source liblock.sh
  source libsudo.sh

  readonly BASENAME_DELIMITER='.'
  readonly REGEXESCAPED_BASENAME_DELIMITER='\.'
  readonly LOCK_PATH_EXT='lock'
  readonly PATH_VERSION_REGEX='[1-9][0-9]*'

  # 1=BASENAME_VERSION_HEAD
  version::path_basename_version_head() {
    echo "$1$BASENAME_DELIMITER"
  }

  # 1=PATH_DIRNAME
  # 2=BASENAME_VERSION_HEAD
  version::path_version_head() {
    echo "$1"'/'"$(version::path_basename_version_head "$2")"
  }

  # 1=BASENAME_VERSION_HEAD
  version::path_basename_version_head_regex() {
    echo "$1$REGEXESCAPED_BASENAME_DELIMITER"
  }

  # 1=PATH_DIRNAME
  # 2=BASENAME_VERSION_HEAD
  version::path_version_head_regex() {
    echo "$1"'/'"$(version::path_basename_version_head_regex "$2")"
  }

  # 1=BASENAME_VERSION_HEAD
  # 2=PATH_EXT
  version::path_basename() {
    echo "$1$BASENAME_DELIMITER$2"
  }

  # 1=PATH_DIRNAME
  # 2=PATH_BASENAME
  version::path() {
    echo "$1"'/'"$2"
  }

  # 1=PATH_BASENAME
  version::lock_path_basename() {
    echo "$BASENAME_DELIMITER$1$BASENAME_DELIMITER$LOCK_PATH_EXT"
  }

  # 1=PATH_DIRNAME
  # 2=PATH_BASENAME
  version::lock_path() {
    version::path "$1" "$(version::lock_path_basename "$2")"
  }

  # 1=PATH_EXT
  version::path_version_tail() {
    echo "$BASENAME_DELIMITER$1"
  }

  # 1=PATH_EXT
  version::path_version_tail_regex() {
    echo "$REGEXESCAPED_BASENAME_DELIMITER$1"
  }

  # 1=PATH_DIRNAME
  # 2=BASENAME_VERSION_HEAD
  # 3=PATH_EXT
  version::path_regex() {
    echo "$(version::path_version_head_regex "$1" "$2")"`
     `"$PATH_VERSION_REGEX"`
     `"$(version::path_version_tail_regex "$3")"
  }

  # 1=PATH_VERSION_HEAD
  # 2=PATH_VERSION_TAIL
  version::get_path() {
    echo "$1$3$2"
  }

  # 1=PATH_VERSION_HEAD
  # 2=PATH_VERSION_TAIL
  version::get_version() {
    # If BASH functions could have named parameters, then `$3` would be
    # `$path`, and I would overwrite `$path` with its own value with the
    # version head removed.  However, one cannot overwrite `$1`, so I assign
    # `$path` first here.
    local -r path="${3#$1}"

    echo "${path%$2}"
  }

  # 1=PATH_DIRNAME
  # 2=PATH_VERSION_HEAD
  # 3=PATH_VERSION_TAIL
  # 4=PATH_REGEX
  version::get_the_versions() {
    while IFS= read -d $'\0' -r path; do
      version::get_version "$2" "$3" "$path"
    done < <(find "$1" -maxdepth 1 -regex "$4" -print0)
  }

  # 1=PATH_DIRNAME
  # 2=PATH_VERSION_HEAD
  # 3=PATH_VERSION_TAIL
  # 4=PATH_REGEX
  version::get_the_versions_descending() {
    version::get_the_versions "$1" "$2" "$3" "$4" \
      | sort --numeric-sort --reverse
  }

  # 1=PATH_DIRNAME
  # 2=PATH_VERSION_HEAD
  # 3=PATH_VERSION_TAIL
  # 4=PATH_REGEX
  version::get_the_version() {
    version::get_the_versions_descending "$1" "$2" "$3" "$4" | head --lines=1
  }

  # 1=PATH_DIRNAME
  # 2=PATH_VERSION_HEAD
  # 3=PATH_VERSION_TAIL
  # 4=PATH_REGEX
  version::get_the_next_version() {
    local the_version

    the_version="$(version::get_the_version "$1" "$2" "$3" "$4")" || return 1

    readonly the_version
    echo "$(( the_version + 1 ))"
  }

  # 1=PATH_DIRNAME
  # 2=PATH_VERSION_HEAD
  # 3=PATH_VERSION_TAIL
  # 4=PATH_REGEX
  version::get_the_next_path() {
    local the_next_version
    
    the_next_version="$(version::get_the_next_version "$1" "$2" "$3" "$4")" \
      || return 1

    readonly the_next_version
    version::get_path "$2" "$3" "$the_next_version"
  }

  # PATH_DIRNAME
  # PATH_VERSION_HEAD
  # PATH_BASENAME
  # PATH
  # PATH_VERSION_TAIL
  # PATH_REGEX
  version::make_the_next() {
    sudo::the_home_is_the_user_home_or_die || return 1

    install --directory -- "$1" || return 1

    local -r lock_path="$(version::lock_path "$1" "$3")"

    lock::make_lock "$lock_path" || return 1

    if [[ -e "$4" ]]; then
      local path

      path="$(version::get_the_next_path "$1" "$2" "$5" "$6")" || return 1

      readonly path
    else
      local -r path="$4"
    fi

    touch -- "$path" || return 1
    lock::free_lock "$lock_path"
    echo "$path"
  }

fi
