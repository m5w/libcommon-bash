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

if [[ -z ${LIBLOCK_SH+x} ]]; then
  readonly LIBLOCK_SH=

  source libdie.sh

  lock::free_lock() {
    rm --force --recursive -- "$1"
  }

  lock::make_lock() {
    mkdir "$1" &>/dev/null || die::die \
        'could not make lock `'`
       `"$1"`
       `\'' but must: '`
       `'perhaps you are executing another process of this program' \
      || return 1

    trap 'lock::free_lock "'"${1@Q}"'"' EXIT
  }

fi
