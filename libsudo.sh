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

# `prog' is inspired by the default argument of the same name to Python's
# `argparse.ArgumentParser'.
sudo::get_the_prog() {
  echo "${BASH_SOURCE[-1]}"
}

sudo::die() {
  echo "$(sudo::get_the_prog): $@" >&2
  return 1
}

sudo::the_user_id_is() {
  (( $EUID == $1 ))
}

sudo::the_user_id_is_or_die() {
  sudo::the_user_id_is "$1" || sudo::die \
    'you must execute this program as the user with ID='"$1"
}

sudo::the_user_is_the_superuser() {
  sudo::the_user_id_is 0
}

sudo::the_user_is_the_superuser_or_die() {
  sudo::the_user_is_the_superuser || sudo::die \
    'you must execute this program as the superuser'
}

sudo::get_user_home() {
  # cf. <https://superuser.com/a/484330>
  getent passwd "$1" | cut --delimiter=: --fields=6
}

sudo::the_home_is_the_user_home() {
  the_user_home="$(sudo::get_user_home $EUID)"
  [[ $HOME == $the_user_home ]]
}

sudo::the_home_is_the_user_home_or_die() {
  sudo::the_home_is_the_user_home || sudo::die \
    'the home `'`
    `"$HOME"`
    `"'"' is not the user'"'"'s home `'`
    `"$the_user_home"`
    `"'"': '`
    `'this is usually because '`
    `'you are not executing this program on a login shell'
}

sudo::sudo_user() {
  [[ -n $SUDO_USER ]]
}

sudo::sudo_user_or_die() {
  sudo::sudo_user || sudo::die \
    'you must invoke sudo to execute this program'
}
