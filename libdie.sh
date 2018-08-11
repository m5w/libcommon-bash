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

if [[ -z ${LIBDIE_SH+x} ]]; then
  readonly LIBDIE_SH=

  # `prog' is inspired by the keyword parameter of the same name to the
  # constructor of Python's class `argparse.ArgumentParser'.
  die::get_the_prog() {
    echo "${BASH_SOURCE[-1]}"
  }

  die::die() {
    echo "$(die::get_the_prog)"': '"$*" >&2
    return 1
  }

fi
