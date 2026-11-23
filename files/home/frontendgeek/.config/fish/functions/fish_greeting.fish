function fish_greeting
    # Ensure Caelestia dynamic color sequences are applied
    cat ~/.local/state/caelestia/sequences.txt 2> /dev/null

    set -l c1 "\e[38;5;16m"  # Primary dynamic color
    set -l c2 "\e[38;5;17m"  # Secondary dynamic color
    set -l c3 "\e[38;5;18m"  # Tertiary dynamic color
    set -l rst "\e[0m"
    set -l bold "\e[1m"

    # 1. CachyOS ASCII Logo (matching dynamic theme)
    if test -n "$LINES"; and test $LINES -lt 38
        # Compact ASCII logo for smaller terminal heights
        echo -e "                 "$bold$c1"..........."$rst
        echo -e "                "$bold$c1"/,,,,...../"$rst
        echo -e "               "$bold$c1"/,,,..,,../   "$c2"()"$rst
        echo -e "              "$bold$c1"/,,,,../"$rst
        echo -e "             "$bold$c1"/,,,.../     "$c2"/'\\"$rst
        echo -e "            "$bold$c1"/,...../      "$c2"\\,/"$rst
        echo -e "            "$bold$c1"\\,,,,,,\\\\             "$c3"_"$rst
        echo -e "             "$bold$c1"\\,,....\\\\           "$c3"/ \\"$rst
        echo -e "              "$bold$c1"\\...,..\\\\          "$c3"\\_/"$rst
        echo -e "               "$bold$c1"\\..,,,,,,,,,,,,/"$rst
        echo -e "                "$bold$c1"\\,,........,,/"$rst
    else
        # Full iconic CachyOS fish logo
        echo -e "          "$bold$c1".-------------------------:"$rst
        echo -e "         "$bold$c1".+========================="$c2"."$rst
        echo -e "        "$bold$c1":++===++==================-       "$c2":++-"$rst
        echo -e "       "$bold$c1":*++====+++++=============-        "$c2".==:"$rst
        echo -e "      "$bold$c1"-*+++=====+***++==========:"$rst
        echo -e "     "$bold$c1"=*++++========------------:"$rst
        echo -e "    "$bold$c1"=*+++++=====-                     "$c3"..."$rst
        echo -e "  "$bold$c1".+*+++++=-===:                    "$c2".=+++=:"$rst
        echo -e " "$bold$c1":++++=====-==:                     "$c2"-*****+"$rst
        echo -e $bold$c1":++========-=.                      "$c2".=+**+."$rst
        echo -e $bold$c1".+==========-.                          "$c3"."$rst
        echo -e $bold$c1":+++++++====-                                "$c3".--==-"$rst
        echo -e " "$bold$c1":++==========.                             "$c2":+++++++:"$rst
        echo -e "  "$bold$c1".-===========.                            "$c2"=*****+*+"$rst
        echo -e "   "$bold$c1".-===========:                           "$c2".+*****+:"$rst
        echo -e "     "$bold$c1"-=======++++:::::::::::::::::::::::::-:  "$c3".---:"$rst
        echo -e "      "$bold$c1":======++++====+++******************=."$rst
        echo -e "       "$bold$c1":=====+++==========++++++++++++++*-"$rst
        echo -e "        "$bold$c1".====++==============++++++++++*-"$rst
        echo -e "         "$bold$c1".===+==================+++++++:"$rst
        echo -e "          "$bold$c1".-=======================+++:"$rst
        echo -e "            "$bold$c1".........................."$rst
    end

    echo

    # 2. Caelestia title with dynamic horizontal gradient
    echo -e "   "$bold$c1"______ ___    ______ "$c2"__    ______ _____ "$c3"______ ____ ___   "$rst
    echo -e "  "$bold$c1"/ ____//   |  / ____/ "$c2"/ /   / ____// ___/ "$c3"/_  __//  _//   |  "$rst
    echo -e " "$bold$c1"/ /    / /| | / __/    "$c2"/ /   / __/   \\__ \\  "$c3"/ /   / / / /| |  "$rst
    echo -e $bold$c1"/ /___ / ___ |/ /___   "$c2"/ /___/ /___  ___/ / "$c3"/ /  _/ / / ___ |  "$rst
    echo -e $bold$c1"\\____//_/  |_/_____/  "$c2"/_____/_____/ /____/  "$c3"/_/  /___//_/  |_|  "$rst

    echo

    # 3. System info table
    command -v fastfetch &> /dev/null && fastfetch --key-padding-left 10
end
