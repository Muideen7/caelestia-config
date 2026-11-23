pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import Caelestia.I18n
import qs.components
import qs.components.controls
import qs.services
import qs.modules.nexus.common
import qs.modules.launcher.services

PageBase {
    id: root

    title: Tr.tr("Colours & Schemes")
    isSubPage: true

    ColumnLayout {
        id: contentLayout

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.medium

        Timer {
            id: reloadTimer
            interval: 350
            onTriggered: Schemes.reload()
        }

        Component.onCompleted: Schemes.reload()

        // ====================================================================
        // ACTIVE THEME & LIVE 3-COLOR PALETTE PREVIEW
        // ====================================================================
        ConnectedRect {
            Layout.fillWidth: true
            first: true
            last: true

            implicitHeight: heroLayout.implicitHeight + Tokens.padding.largeIncreased * 2

            ColumnLayout {
                id: heroLayout

                anchors.fill: parent
                anchors.margins: Tokens.padding.largeIncreased
                spacing: Tokens.spacing.medium

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.medium

                    StyledClippingRect {
                        implicitWidth: Tokens.sizes.bar.iconButtonSize
                        implicitHeight: Tokens.sizes.bar.iconButtonSize
                        radius: Tokens.rounding.full
                        color: Colours.palette.m3primary

                        MaterialIcon {
                            anchors.centerIn: parent
                            text: "palette"
                            color: Colours.palette.m3onPrimary
                            fontStyle: Tokens.font.icon.medium
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        StyledText {
                            text: {
                                const s = Schemes.currentScheme ?? "dynamic default";
                                const parts = s.split(" ");
                                const name = parts[0] ? parts[0].charAt(0).toUpperCase() + parts[0].slice(1) : "Dynamic";
                                const flavour = parts[1] ? parts[1].charAt(0).toUpperCase() + parts[1].slice(1) : "Default";
                                return `${name} • ${flavour}`;
                            }
                            font: Tokens.font.title.medium
                            elide: Text.ElideRight
                        }

                        StyledText {
                            text: {
                                const v = Schemes.currentVariant ?? "tonalspot";
                                const vName = v.charAt(0).toUpperCase() + v.slice(1);
                                const isDyn = (Schemes.currentScheme ?? "").startsWith("dynamic");
                                const origin = isDyn ? Tr.tr("Material You (Wallpaper)") : Tr.tr("Preset");
                                return `${origin}  |  Variant: ${vName}`;
                            }
                            color: Colours.palette.m3outline
                            font: Tokens.font.body.small
                            elide: Text.ElideRight
                        }
                    }

                    IconTextButton {
                        icon: Colours.light ? "dark_mode" : "light_mode"
                        text: Colours.light ? Tr.tr("Dark") : Tr.tr("Light")
                        font: Tokens.font.body.small
                        isRound: true
                        shapeMorph: true
                        type: IconTextButton.Tonal
                        onClicked: Colours.setMode(Colours.light ? "dark" : "light")
                    }
                }

                // 3-Color mapping description
                StyledText {
                    Layout.fillWidth: true
                    text: Tr.tr("Wallpaper 3-Color Harmony: Most prominent color becomes Primary (active borders & accents), 2nd becomes Secondary (icons & controls), 3rd becomes Tertiary (notifications & highlights).")
                    color: Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.label.small
                    wrapMode: Text.WordWrap
                }

                // Live Color Swatch Strip
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.small

                    Repeater {
                        model: [
                            { name: Tr.tr("Primary"), col: Colours.palette.m3primary, onCol: Colours.palette.m3onPrimary, sub: Tr.tr("Borders") },
                            { name: Tr.tr("Secondary"), col: Colours.palette.m3secondary, onCol: Colours.palette.m3onSecondary, sub: Tr.tr("Icons") },
                            { name: Tr.tr("Tertiary"), col: Colours.palette.m3tertiary, onCol: Colours.palette.m3onTertiary, sub: Tr.tr("Notifs") },
                            { name: Tr.tr("Container"), col: Colours.palette.m3primaryContainer, onCol: Colours.palette.m3onPrimaryContainer, sub: Tr.tr("Badges") },
                            { name: Tr.tr("Surface"), col: Colours.palette.m3surfaceContainerHigh, onCol: Colours.palette.m3onSurface, sub: Tr.tr("Panels") }
                        ]

                        StyledRect {
                            required property var modelData

                            Layout.fillWidth: true
                            implicitHeight: 48
                            radius: Tokens.rounding.small
                            color: modelData.col

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 0

                                StyledText {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: parent.parent.modelData.name
                                    color: parent.parent.modelData.onCol
                                    font: Tokens.font.label.medium
                                }

                                StyledText {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: parent.parent.modelData.sub
                                    color: Qt.alpha(parent.parent.modelData.onCol, 0.75)
                                    font: Tokens.font.label.small
                                }
                            }
                        }
                    }
                }
            }
        }

        // ====================================================================
        // MATERIAL 3 VARIANTS
        // ====================================================================
        SectionHeader {
            text: Tr.tr("Material 3 Variants")
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 3
            columnSpacing: Tokens.spacing.small
            rowSpacing: Tokens.spacing.small

            Repeater {
                model: M3Variants.list

                StyledRect {
                    id: variantCard

                    required property var modelData

                    readonly property string vKey: modelData?.variant ?? ""
                    readonly property bool isActive: vKey === Schemes.currentVariant

                    Layout.fillWidth: true
                    implicitHeight: 68
                    radius: Tokens.rounding.large
                    color: variantCard.isActive ? Colours.palette.m3primaryContainer : Colours.tPalette.m3surfaceContainer
                    border.width: variantCard.isActive ? 2 : 1
                    border.color: variantCard.isActive ? Colours.palette.m3primary : Colours.palette.m3outlineVariant

                    Behavior on color { CAnim {} }
                    Behavior on border.color { CAnim {} }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Tokens.padding.medium
                        spacing: Tokens.spacing.small

                        MaterialIcon {
                            text: variantCard.modelData?.icon ?? "palette"
                            color: variantCard.isActive ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSurfaceVariant
                            fontStyle: Tokens.font.icon.medium
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            StyledText {
                                text: variantCard.modelData?.name ?? ""
                                font: Tokens.font.body.small
                                color: variantCard.isActive ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSurface
                                elide: Text.ElideRight
                            }

                            StyledText {
                                text: variantCard.vKey
                                font: Tokens.font.label.small
                                color: variantCard.isActive ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3outline
                                elide: Text.ElideRight
                            }
                        }

                        Loader {
                            active: variantCard.isActive
                            visible: active
                            sourceComponent: MaterialIcon {
                                text: "check"
                                color: Colours.palette.m3primary
                                fontStyle: Tokens.font.icon.small
                            }
                        }
                    }

                    StateLayer {
                        radius: Tokens.rounding.large
                        onClicked: {
                            Quickshell.execDetached(["caelestia", "scheme", "set", "-v", variantCard.vKey]);
                            reloadTimer.restart();
                        }
                    }
                }
            }
        }

        // ====================================================================
        // CURATED COLOR SCHEMES (DYNAMIC, CATPPUCCIN, CAELESTIA)
        // ====================================================================
        SectionHeader {
            text: Tr.tr("Color Schemes")
        }

        GridLayout {
            id: schemesGrid

            Layout.fillWidth: true
            columns: 2
            columnSpacing: Tokens.spacing.small
            rowSpacing: Tokens.spacing.small

            Repeater {
                model: {
                    const all = Schemes.list ?? [];
                    // Only keep Dynamic, Catppuccin, and Caelestia (Gruvbox, Dracula, etc. excluded)
                    const allowed = ["dynamic", "catppuccin", "caelestia"];
                    return all.filter(s => allowed.includes(String(s.name ?? "").toLowerCase()));
                }

                StyledRect {
                    id: schemeCard

                    required property var modelData

                    readonly property string sName: modelData?.name ?? ""
                    readonly property string sFlavour: modelData?.flavour ?? ""
                    readonly property bool isActive: `${sName} ${sFlavour}` === Schemes.currentScheme

                    Layout.fillWidth: true
                    implicitHeight: 68
                    radius: Tokens.rounding.large
                    color: schemeCard.isActive ? Colours.palette.m3secondaryContainer : Colours.tPalette.m3surfaceContainer
                    border.width: schemeCard.isActive ? 2 : 1
                    border.color: schemeCard.isActive ? Colours.palette.m3primary : Colours.palette.m3outlineVariant

                    Behavior on color { CAnim {} }
                    Behavior on border.color { CAnim {} }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Tokens.padding.medium
                        spacing: Tokens.spacing.medium

                        // Dual-color preview swatch circle
                        StyledRect {
                            id: swatch

                            implicitWidth: 36
                            implicitHeight: 36
                            radius: Tokens.rounding.full
                            color: schemeCard.modelData?.colours?.surface ? `#${schemeCard.modelData.colours.surface}` : Colours.palette.m3surfaceContainer
                            border.width: 1
                            border.color: schemeCard.modelData?.colours?.outline ? Qt.alpha(`#${schemeCard.modelData.colours.outline}`, 0.5) : Colours.palette.m3outline

                            Item {
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.right: parent.right
                                implicitWidth: parent.implicitWidth / 2
                                clip: true

                                StyledRect {
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    anchors.right: parent.right
                                    implicitWidth: swatch.implicitWidth
                                    radius: Tokens.rounding.full
                                    color: schemeCard.modelData?.colours?.primary ? `#${schemeCard.modelData.colours.primary}` : Colours.palette.m3primary
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            StyledText {
                                text: {
                                    const n = schemeCard.sName;
                                    if (n === "dynamic") return Tr.tr("Dynamic (Wallpaper)");
                                    if (n === "catppuccin") return "Catppuccin";
                                    if (n === "caelestia") return "Caelestia";
                                    return n ? n.charAt(0).toUpperCase() + n.slice(1) : "";
                                }
                                font: Tokens.font.body.medium
                                color: schemeCard.isActive ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
                                elide: Text.ElideRight
                            }

                            StyledText {
                                text: {
                                    const f = schemeCard.sFlavour;
                                    if (f === "default") return Tr.tr("Standard");
                                    if (f === "hard") return Tr.tr("High Contrast");
                                    return f ? f.charAt(0).toUpperCase() + f.slice(1) : "";
                                }
                                font: Tokens.font.label.small
                                color: schemeCard.isActive ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3outline
                                elide: Text.ElideRight
                            }
                        }

                        Loader {
                            active: schemeCard.isActive
                            visible: active
                            sourceComponent: MaterialIcon {
                                text: "check_circle"
                                color: Colours.palette.m3primary
                                fontStyle: Tokens.font.icon.medium
                            }
                        }
                    }

                    StateLayer {
                        radius: Tokens.rounding.large
                        onClicked: {
                            Quickshell.execDetached(["caelestia", "scheme", "set", "-n", schemeCard.sName, "-f", schemeCard.sFlavour]);
                            reloadTimer.restart();
                        }
                    }
                }
            }
        }
    }
}
