pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Caelestia.Config
import Caelestia.I18n
import qs.components
import qs.components.controls
import qs.services
import qs.utils
import qs.modules.nexus.common

PageBase {
    id: root

    title: Tr.tr("Updates")

    property var updatesList: []
    property bool checking: false
    property string lastChecked: ""
    property string checkError: ""

    function checkUpdates(): void {
        root.checking = true;
        root.checkError = "";
        checkProc.running = true;
    }

    function launchSystemUpdate(): void {
        Quickshell.execDetached([
            ...GlobalConfig.general.apps.terminal,
            "sh",
            "-c",
            "caelestia update || paru -Syu; echo ''; echo 'Update process finished. Press Enter to close.'; read line"
        ]);
    }

    function updateSinglePackage(pkgName: string): void {
        Quickshell.execDetached([
            ...GlobalConfig.general.apps.terminal,
            "sh",
            "-c",
            `paru -S "${pkgName}"; echo ''; echo 'Press Enter to close.'; read line`
        ]);
    }

    Component.onCompleted: checkUpdates()

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.medium

        Process {
            id: checkProc

            command: ["sh", "-c", "paru -Qu --color never 2>/dev/null"]

            stdout: StdioCollector {
                onStreamFinished: {
                    root.checking = false;
                    const raw = text.trim();
                    if (!raw) {
                        root.updatesList = [];
                    } else {
                        const lines = raw.split("\n");
                        const parsed = [];
                        for (const line of lines) {
                            const trimmed = line.trim();
                            if (!trimmed)
                                continue;
                            const parts = trimmed.split(/\s+/);
                            if (parts.length >= 4 && parts[2] === "->") {
                                parsed.push({
                                    name: parts[0],
                                    oldVersion: parts[1],
                                    newVersion: parts[3]
                                });
                            }
                        }
                        root.updatesList = parsed;
                    }
                    root.lastChecked = Qt.formatTime(new Date(), "hh:mm AP");
                }
            }

            onExited: (code) => {
                root.checking = false;
                if (code !== 0 && code !== 1) {
                    root.checkError = Tr.tr("Failed to check for updates");
                }
            }
        }

        // ====================================================================
        // HERO STATUS CARD
        // ====================================================================
        ConnectedRect {
            Layout.fillWidth: true
            Layout.preferredWidth: root.cappedWidth
            implicitWidth: root.cappedWidth
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
                        color: root.checking ? Colours.palette.m3tertiary : (root.updatesList.length > 0 ? Colours.palette.m3primary : Colours.palette.m3secondary)

                        MaterialIcon {
                            anchors.centerIn: parent
                            text: root.checking ? "sync" : (root.updatesList.length > 0 ? "system_update" : "check_circle")
                            color: root.checking ? Colours.palette.m3onTertiary : (root.updatesList.length > 0 ? Colours.palette.m3onPrimary : Colours.palette.m3onSecondary)
                            fontStyle: Tokens.font.icon.medium
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        StyledText {
                            text: {
                                if (root.checking)
                                    return Tr.tr("Checking for updates...");
                                if (root.updatesList.length > 0)
                                    return Tr.tr("%1 updates available").arg(root.updatesList.length);
                                return Tr.tr("System is up to date");
                            }
                            font: Tokens.font.title.medium
                            elide: Text.ElideRight
                        }

                        StyledText {
                            text: {
                                if (root.checking)
                                    return Tr.tr("Scanning official repos and AUR...");
                                if (root.lastChecked)
                                    return Tr.tr("Last checked: %1").arg(root.lastChecked);
                                return Tr.tr("Checked just now");
                            }
                            color: Colours.palette.m3outline
                            font: Tokens.font.body.small
                            elide: Text.ElideRight
                        }
                    }

                    RowLayout {
                        spacing: Tokens.spacing.small

                        IconTextButton {
                            icon: "refresh"
                            text: Tr.tr("Check")
                            font: Tokens.font.body.small
                            isRound: true
                            type: IconTextButton.Tonal
                            enabled: !root.checking
                            onClicked: root.checkUpdates()
                        }

                        IconTextButton {
                            icon: "upgrade"
                            text: Tr.tr("Update All")
                            font: Tokens.font.body.small
                            isRound: true
                            type: IconTextButton.Filled
                            enabled: !root.checking && root.updatesList.length > 0
                            onClicked: root.launchSystemUpdate()
                        }
                    }
                }

                // System Quick Badges Row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.small

                    StyledRect {
                        Layout.fillWidth: true
                        implicitHeight: 44
                        radius: Tokens.rounding.medium
                        color: Colours.tPalette.m3surfaceContainer

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: Tokens.spacing.extraSmall

                            MaterialIcon {
                                text: "memory"
                                fontStyle: Tokens.font.icon.small
                                color: Colours.palette.m3primary
                            }

                            StyledText {
                                text: SysInfo.kernel ? `Kernel ${SysInfo.kernel}` : "Linux"
                                font: Tokens.font.label.small
                                color: Colours.palette.m3onSurface
                            }
                        }
                    }

                    StyledRect {
                        Layout.fillWidth: true
                        implicitHeight: 44
                        radius: Tokens.rounding.medium
                        color: Colours.tPalette.m3surfaceContainer

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: Tokens.spacing.extraSmall

                            MaterialIcon {
                                text: "inventory_2"
                                fontStyle: Tokens.font.icon.small
                                color: Colours.palette.m3secondary
                            }

                            StyledText {
                                text: SysInfo.osPrettyName || "Arch / CachyOS"
                                font: Tokens.font.label.small
                                color: Colours.palette.m3onSurface
                            }
                        }
                    }

                    StyledRect {
                        Layout.fillWidth: true
                        implicitHeight: 44
                        radius: Tokens.rounding.medium
                        color: Colours.tPalette.m3surfaceContainer

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: Tokens.spacing.extraSmall

                            MaterialIcon {
                                text: "terminal"
                                fontStyle: Tokens.font.icon.small
                                color: Colours.palette.m3tertiary
                            }

                            StyledText {
                                text: "Paru + Pacman"
                                font: Tokens.font.label.small
                                color: Colours.palette.m3onSurface
                            }
                        }
                    }
                }
            }
        }

        // ====================================================================
        // AVAILABLE UPDATES LIST
        // ====================================================================
        SectionHeader {
            text: root.updatesList.length > 0 ? Tr.tr("Available Updates (%1)").arg(root.updatesList.length) : Tr.tr("Available Updates")
        }

        // Checking State
        StyledRect {
            visible: root.checking
            Layout.fillWidth: true
            Layout.preferredWidth: root.cappedWidth
            implicitWidth: root.cappedWidth
            implicitHeight: 120
            radius: Tokens.rounding.large
            color: Colours.tPalette.m3surfaceContainer

            ColumnLayout {
                anchors.centerIn: parent
                spacing: Tokens.spacing.small

                LoadingIndicator {
                    Layout.alignment: Qt.AlignHCenter
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Tr.tr("Checking packages from Pacman and AUR...")
                    color: Colours.palette.m3outline
                    font: Tokens.font.body.medium
                }
            }
        }

        // Empty state: All Up to Date
        StyledRect {
            visible: !root.checking && root.updatesList.length === 0
            Layout.fillWidth: true
            Layout.preferredWidth: root.cappedWidth
            implicitWidth: root.cappedWidth
            implicitHeight: 140
            radius: Tokens.rounding.large
            color: Colours.tPalette.m3surfaceContainer

            ColumnLayout {
                anchors.centerIn: parent
                spacing: Tokens.spacing.extraSmall

                MaterialIcon {
                    Layout.alignment: Qt.AlignHCenter
                    text: "verified"
                    color: Colours.palette.m3primary
                    fontStyle: Tokens.font.icon.extraLarge
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Tr.tr("All software packages are up to date")
                    font: Tokens.font.body.large
                    color: Colours.palette.m3onSurface
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Tr.tr("No pending package or system upgrades found.")
                    font: Tokens.font.label.small
                    color: Colours.palette.m3outline
                }
            }
        }

        // List of pending updates
        ColumnLayout {
            visible: !root.checking && root.updatesList.length > 0
            Layout.fillWidth: true
            Layout.preferredWidth: root.cappedWidth
            implicitWidth: root.cappedWidth
            spacing: Tokens.spacing.extraSmall

            Repeater {
                model: root.updatesList

                StyledRect {
                    id: updateItem

                    required property var modelData
                    required property int index

                    Layout.fillWidth: true
                    Layout.preferredWidth: root.cappedWidth
                    implicitWidth: root.cappedWidth
                    implicitHeight: 64
                    radius: Tokens.rounding.medium
                    color: Colours.tPalette.m3surfaceContainer

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Tokens.padding.largeIncreased
                        anchors.rightMargin: Tokens.padding.largeIncreased
                        spacing: Tokens.spacing.medium

                        StyledClippingRect {
                            Layout.alignment: Qt.AlignVCenter
                            implicitWidth: 38
                            implicitHeight: 38
                            radius: Tokens.rounding.full
                            color: Colours.palette.m3secondaryContainer

                            MaterialIcon {
                                anchors.centerIn: parent
                                text: "package_2"
                                color: Colours.palette.m3onSecondaryContainer
                                fontStyle: Tokens.font.icon.medium
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 2

                            StyledText {
                                Layout.fillWidth: true
                                text: updateItem.modelData?.name ?? ""
                                font: Tokens.font.body.medium
                                color: Colours.palette.m3onSurface
                                elide: Text.ElideRight
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.extraSmall

                                StyledText {
                                    text: updateItem.modelData?.oldVersion ?? ""
                                    font: Tokens.font.label.small
                                    color: Colours.palette.m3outline
                                }

                                MaterialIcon {
                                    text: "arrow_forward"
                                    fontStyle: Tokens.font.icon.small
                                    color: Colours.palette.m3outline
                                }

                                StyledText {
                                    text: updateItem.modelData?.newVersion ?? ""
                                    font: Tokens.font.label.small
                                    color: Colours.palette.m3primary
                                }
                            }
                        }

                        IconButton {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                            icon: "download"
                            font: Tokens.font.icon.small
                            type: IconButton.Tonal
                            isRound: true
                            onClicked: root.updateSinglePackage(updateItem.modelData?.name ?? "")
                        }
                    }
                }
            }
        }

        // ====================================================================
        // MAINTENANCE & TOOLS
        // ====================================================================
        SectionHeader {
            text: Tr.tr("Maintenance & Mirrors")
        }

        RowButton {
            first: true
            icon: "speed"
            text: Tr.tr("Rate and Optimize Mirrors")
            subtext: Tr.tr("Rank Pacman mirrors by speed using cachyos-rate-mirrors")
            onClicked: Quickshell.execDetached([
                ...GlobalConfig.general.apps.terminal,
                "sh",
                "-c",
                "cachyos-rate-mirrors || rate-mirrors arch; echo ''; echo 'Mirror rating finished. Press Enter to close.'; read line"
            ])
        }

        RowButton {
            icon: "delete_sweep"
            text: Tr.tr("Clean Package Cache")
            subtext: Tr.tr("Free disk space by clearing outdated cached package files")
            onClicked: Quickshell.execDetached([
                ...GlobalConfig.general.apps.terminal,
                "sh",
                "-c",
                "paru -Sc --noconfirm; echo ''; echo 'Cache cleared. Press Enter to close.'; read line"
            ])
        }

        RowButton {
            last: true
            icon: "terminal"
            text: Tr.tr("Caelestia System & Dots Update")
            subtext: Tr.tr("Sync dotfile revisions, rebuild local packages, and update system")
            onClicked: root.launchSystemUpdate()
        }
    }
}
