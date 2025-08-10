#!/usr/bin/env bash

if [ ${UID} -eq 0 ]; then
  DEST_DIR="/usr/share/icons"
else
  DEST_DIR="${HOME}/.local/share/icons"
fi

readonly SRC_DIR=$(cd $(dirname $0) && pwd)

readonly COLOR_VARIANTS=("standard" "catppuccin_mocha_sky" "catppuccin_mocha_blue" "catppuccin_mocha_lavender")
readonly BRIGHT_VARIANTS=("" "light" "dark")

if command -v lsb_release &> /dev/null; then
  Distributor_ID=$(lsb_release -i)
  if [[ "${Distributor_ID}" == "Distributor ID:	elementary" || "${Distributor_ID}" == "Distributor ID:	Elementary" ]]; then
    ICON_VERSION="elementary"
  else
    ICON_VERSION="normal"
  fi
  # echo -e "Install $ICON_VERSION version! ..."
else
  ICON_VERSION="normal"
fi

export c_default="\033[0m"
export c_blue="\033[1;34m"
export c_magenta="\033[1;35m"
export c_cyan="\033[1;36m"
export c_green="\033[1;32m"
export c_red="\033[1;31m"
export c_yellow="\033[1;33m"

prompt() {
  case "${1}" in
    "-s")
      echo -e "  ${c_green}${2}${c_default}" ;;    # print success message
    "-e")
      echo -e "  ${c_red}${2}${c_default}" ;;      # print error message
    "-w")
      echo -e "  ${c_yellow}${2}${c_default}" ;;   # print warning message
    "-i")
      echo -e "  ${c_cyan}${2}${c_default}" ;;     # print info message
  esac
}

usage() {
cat << EOF
Usage: $0 [OPTION] | [COLOR VARIANTS]...

OPTIONS:
  -a                       Install all color folder versions
  -c                       Install plasma colorscheme folder version
  -d DIR                   Specify theme destination directory (Default: $HOME/.local/share/icons)
  -n NAME                  Specify theme name (Default: Tela)
  -r, -u                   Remove/uninstall icon themes (Default: all)
  -h                       Show this help

COLOR VARIANTS:
  standard                 Standard color folder version
  catppuccin_mocha_sky     Catppuccin latte/mocha sky default color folder version
  catppuccin_mocha_blue    Catppuccin latte/mocha blue default color folder version
  catppuccin_mocha_lavender Catppuccin latte/mocha lavender default color folder version

  By default, only the standard one is selected.
EOF
}

install_theme() {
  local -r theme_back_color_light='#ccd0da'
  local -r theme_back_color_dark='#cdd6f4'
  case "$1" in
    standard)
      local -r theme_color_light='#5294e2'
      local -r theme_color_dark='#5294e2'
      theme_back_color_light='#ffffff'
      theme_back_color_dark='#ffffff'
      ;;
    catppuccin_mocha_sky)
      local -r theme_color_light='#04a5e5'
      local -r theme_color_dark='#89dceb'
      ;;
    catppuccin_mocha_blue)
      local -r theme_color_light='#1e66f5'
      local -r theme_color_dark='#89b4fa'
      ;;
    catppuccin_mocha_lavender)
      local -r theme_color_light='#7287fd'
      local -r theme_color_dark='#b4befe'
      ;;
  esac

  # Appends a dash if the variables are not empty
  if [[ "$1" != "standard" ]]; then
    local -r colorprefix="-$1"
  fi

  local -r brightprefix="${2:+-$2}"

  local -r THEME_NAME="${NAME}${colorprefix}${brightprefix}"
  local -r THEME_DIR="${DEST_DIR}/${THEME_NAME}"

  if [[ -d "${THEME_DIR}" ]]; then
    rm -rf "${THEME_DIR}"
  fi

  prompt -i "Installing '${THEME_NAME}'..."

  install -d "${THEME_DIR}"

  install -m644 "${SRC_DIR}/src/index.theme"                                     "${THEME_DIR}"

  # Update the name in index.theme
  sed -i "s/%NAME%/${THEME_NAME//-/ }/g"                                         "${THEME_DIR}/index.theme"

  if [[ -z "${brightprefix}" ]]; then
    cp -r "${SRC_DIR}"/src/{16,22,24,32,scalable,symbolic}                       "${THEME_DIR}"

    if [[ "$1" != "standard" ]]; then
      sed -i "s/#5294e2/${theme_color_light}/g" "${THEME_DIR}/scalable/apps/"*.svg "${THEME_DIR}/scalable/places/"default-*.svg "${THEME_DIR}/16/places/"folder*.svg
      sed -i "/\ColorScheme-Highlight/s/currentColor/${theme_color_light}/" "${THEME_DIR}/scalable/places/"default-*.svg "${THEME_DIR}/16/places/"folder*.svg
      sed -i "/\ColorScheme-Background/s/currentColor/${theme_back_color_light}/" "${THEME_DIR}/scalable/places/"default-*.svg

      sed -i "s/#5294e2/${theme_color_light}/g" "${THEME_DIR}/scalable/devices/"*.svg "${THEME_DIR}/32/devices/"*.svg
    fi

    cp -r "${SRC_DIR}"/links/{16,22,24,32,scalable,symbolic}                     "${THEME_DIR}"

    if [[ "${ICON_VERSION}" == 'elementary' || "$DESKTOP_SESSION" == 'xfce' ]]; then
      cp -r "${SRC_DIR}/elementary/"*                                            "${THEME_DIR}"
    fi
  fi

  if [[ "${brightprefix}" == '-light' ]]; then
    local -r STD_THEME_DIR="${THEME_DIR%-light}"

    install -d "${THEME_DIR}"/{16,22,24}

    cp -r "${SRC_DIR}"/src/16/panel                                              "${THEME_DIR}/16"
    cp -r "${SRC_DIR}"/src/22/panel                                              "${THEME_DIR}/22"
    cp -r "${SRC_DIR}"/src/24/panel                                              "${THEME_DIR}/24"

    # Change icon color for dark theme
    if [[ "$1" != "standard" ]]; then
      sed -i "s/#dfdfdf/#4c4f69/g" "${THEME_DIR}"/{16,22,24}/panel/*.svg
    else
      sed -i "s/#dfdfdf/#505050/g" "${THEME_DIR}"/{16,22,24}/panel/*.svg
    fi

    cp -r "${SRC_DIR}"/links/16/panel                                            "${THEME_DIR}/16"
    cp -r "${SRC_DIR}"/links/22/panel                                            "${THEME_DIR}/22"
    cp -r "${SRC_DIR}"/links/24/panel                                            "${THEME_DIR}/24"

    # Link the common icons
    ln -sr "${STD_THEME_DIR}/scalable"                                           "${THEME_DIR}/scalable"
    ln -sr "${STD_THEME_DIR}/32"                                                 "${THEME_DIR}/32"
    ln -sr "${STD_THEME_DIR}/16/actions"                                         "${THEME_DIR}/16/actions"
    ln -sr "${STD_THEME_DIR}/16/apps"                                            "${THEME_DIR}/16/apps"
    ln -sr "${STD_THEME_DIR}/16/devices"                                         "${THEME_DIR}/16/devices"
    ln -sr "${STD_THEME_DIR}/16/places"                                          "${THEME_DIR}/16/places"
    ln -sr "${STD_THEME_DIR}/16/status"                                          "${THEME_DIR}/16/status"
    ln -sr "${STD_THEME_DIR}/22/actions"                                         "${THEME_DIR}/22/actions"
    ln -sr "${STD_THEME_DIR}/22/categories"                                      "${THEME_DIR}/22/categories"
    ln -sr "${STD_THEME_DIR}/22/devices"                                         "${THEME_DIR}/22/devices"
    ln -sr "${STD_THEME_DIR}/22/emblems"                                         "${THEME_DIR}/22/emblems"
    ln -sr "${STD_THEME_DIR}/22/places"                                          "${THEME_DIR}/22/places"
    ln -sr "${STD_THEME_DIR}/24/actions"                                         "${THEME_DIR}/24/actions"
    ln -sr "${STD_THEME_DIR}/24/animations"                                      "${THEME_DIR}/24/animations"
    ln -sr "${STD_THEME_DIR}/24/devices"                                         "${THEME_DIR}/24/devices"
    ln -sr "${STD_THEME_DIR}/24/places"                                          "${THEME_DIR}/24/places"
    ln -sr "${STD_THEME_DIR}/symbolic"                                           "${THEME_DIR}/symbolic"
  fi

  if [[ "${brightprefix}" == '-dark' ]]; then
    cp -r "${SRC_DIR}"/src/{16,22,24,32,scalable,symbolic}                       "${THEME_DIR}"

    if [[ "$1" != "standard" ]]; then
      sed -i "s/#5294e2/${theme_color_dark}/g" "${THEME_DIR}/scalable/apps/"*.svg "${THEME_DIR}/scalable/places/"default-*.svg "${THEME_DIR}/16/places/"folder*.svg
      sed -i "/\ColorScheme-Highlight/s/currentColor/${theme_color_dark}/" "${THEME_DIR}/scalable/places/"default-*.svg "${THEME_DIR}/16/places/"folder*.svg
      sed -i "/\ColorScheme-Background/s/currentColor/${theme_back_color_dark}/" "${THEME_DIR}/scalable/places/"default-*.svg

      sed -i "s/#5294e2/${theme_color_dark}/g" "${THEME_DIR}/scalable/devices/"*.svg "${THEME_DIR}/32/devices/"*.svg
    fi

    # Change icon color for dark theme
    if [[ "$1" != "standard" ]]; then
      sed -i "s/#565656/#cdd6f4/g" "${THEME_DIR}"/{16,22,24}/actions/*.svg
      sed -i "s/#727272/#cdd6f4/g" "${THEME_DIR}"/{16,22,24}/{places,devices}/*.svg
      sed -i "s/#565656/#cdd6f4/g" "${THEME_DIR}"/symbolic/{actions,apps,categories,devices,emblems,emotes,mimetypes,places,status}/*.svg
    else
      sed -i "s/#565656/#aaaaaa/g" "${THEME_DIR}"/{16,22,24}/actions/*.svg
      sed -i "s/#727272/#aaaaaa/g" "${THEME_DIR}"/{16,22,24}/{places,devices}/*.svg
      sed -i "s/#565656/#aaaaaa/g" "${THEME_DIR}"/symbolic/{actions,apps,categories,devices,emblems,emotes,mimetypes,places,status}/*.svg
    fi

    if [[ "$1" != "standard" ]]; then
      sed -i "s/#5294e2/${theme_color_dark}/g" "${THEME_DIR}/16/places/"folder*.svg
    fi

    cp -r "${SRC_DIR}"/links/{16,22,24,32,scalable,symbolic}                     "${THEME_DIR}"

    if [[ "${ICON_VERSION}" == 'elementary' || "$DESKTOP_SESSION" == 'xfce' ]]; then
      cp -r "${SRC_DIR}/elementary/"*                                            "${THEME_DIR}"
    fi
  fi

  ln -sr "${THEME_DIR}/16"                                                       "${THEME_DIR}/16@2x"
  ln -sr "${THEME_DIR}/22"                                                       "${THEME_DIR}/22@2x"
  ln -sr "${THEME_DIR}/24"                                                       "${THEME_DIR}/24@2x"
  ln -sr "${THEME_DIR}/32"                                                       "${THEME_DIR}/32@2x"
  ln -sr "${THEME_DIR}/scalable"                                                 "${THEME_DIR}/scalable@2x"

  gtk-update-icon-cache "${THEME_DIR}"
}

uninstall_theme() {
  # Appends a dash if the variables are not empty
  if [[ "$1" != "standard" ]]; then
    local -r colorprefix="-$1"
  fi

  local -r brightprefix="${2:+-$2}"

  local -r THEME_NAME="${NAME}${colorprefix}${brightprefix}"
  local -r THEME_DIR="${DEST_DIR}/${THEME_NAME}"

  if [[ -d "${THEME_DIR}" ]]; then
    rm -rf "${THEME_DIR}"
    prompt -i "Uninstalling '${THEME_DIR}'..."
  fi
}

while [ $# -gt 0 ]; do
  if [[ "$1" = "-a" ]]; then
    colors=("${COLOR_VARIANTS[@]}")
  elif [[ "$1" = "-c" ]]; then
    colorscheme="true"
    prompt -s "Folder color will follow the colorscheme on KDE plasma ..."
  elif [[ "$1" = "-d" ]]; then
    DEST_DIR="$2"
    shift
  elif [[ "$1" = "-n" ]]; then
    NAME="$2"
    shift
  elif [[ "$1" = "-u" || "$1" = "-r" ]]; then
    uninstall="true"
  elif [[ "$1" = "-h" ]]; then
    usage
    exit 0
  # If the argument is a color variant, append it to the colors to be installed
  elif [[ " ${COLOR_VARIANTS[*]} " = *" $1 "* ]] && \
       [[ "${colors[*]}" != *$1* ]]; then
    colors+=("$1")
  else
    prompt -e "ERROR: Unrecognized installation option '$1'."
    prompt -w "Try '$0 -h' for more information."
    exit 1
  fi

  shift
done

# Default name is 'Tela'
: "${NAME:=Tela}"

if [[ ${uninstall} == 'true' ]]; then
  for color in "${COLOR_VARIANTS[@]}"; do
    for bright in "${BRIGHT_VARIANTS[@]}"; do
      uninstall_theme "${color}" "${bright}"
    done
  done
else
  # By default, only the standard color variant is selected
  for color in "${colors[@]:-standard}"; do
    for bright in "${BRIGHT_VARIANTS[@]}"; do
      install_theme "${color}" "${bright}"
    done
  done
fi
