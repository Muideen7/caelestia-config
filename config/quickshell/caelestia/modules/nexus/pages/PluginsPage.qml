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

    title: Tr.tr("Plugins")

    property var pluginsList: []
    property int activeCount: 0
    property string activeCategory: "All"
    property bool loading: false

    function refreshPlugins(): void {
        root.loading = true;
        listProc.running = true;
    }

    function togglePlugin(pluginId: string): void {
        toggleProc.command = ["/home/frontendgeek/.config/caelestia/plugins-helper.py", "toggle", pluginId];
        toggleProc.running = true;
    }

    Component.onCompleted: refreshPlugins()

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.medium

        Process {
            id: listProc

            command: ["/home/frontendgeek/.config/caelestia/plugins-helper.py", "list"]

            stdout: StdioCollector {
                onStreamFinished: {
                    root.loading = false;
                    try {
                        const data = JSON.parse(text);
                        root.pluginsList = data;
                        let count = 0;
                        for (const item of data) {
                            if (item.enabled)
                                count++;
                        }
                        root.activeCount = count;
                    } catch (e) {
                        console.warn("Failed to parse plugins list:", e);
                    }
                }
            }

            onExited: (code) => {
                root.loading = false;
            }
        }

        Process {
            id: toggleProc

            onExited: (code) => {
                root.refreshPlugins();
            }
        }

        // ====================================================================
        // HERO CARD
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
                            text: "extension"
                            color: Colours.palette.m3onPrimary
                            fontStyle: Tokens.font.icon.medium
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        StyledText {
                            text: Tr.tr("Installed Plugins & Extensions")
                            font: Tokens.font.title.medium
                            elide: Text.ElideRight
                        }

                        StyledText {
                            text: {
                                const total = root.pluginsList.length;
                                const disabled = total - root.activeCount;
                                return Tr.tr("%1 active  •  %2 disabled").arg(root.activeCount).arg(disabled);
                            }
                            color: Colours.palette.m3outline
                            font: Tokens.font.body.small
                            elide: Text.ElideRight
                        }
                    }

                    RowLayout {
                        spacing: Tokens.spacing.small

                        IconTextButton {
                            icon: "folder_open"
                            text: Tr.tr("Folder")
                            font: Tokens.font.body.small
                            isRound: true
                            type: IconTextButton.Tonal
                            onClicked: Quickshell.execDetached(["xdg-open", `${Paths.home}/.config/caelestia/plugins`])
                        }

                        IconTextButton {
                            icon: "refresh"
                            text: Tr.tr("Reload")
                            font: Tokens.font.body.small
                            isRound: true
                            type: IconTextButton.Tonal
                            onClicked: {
                                Quickshell.execDetached(["systemctl", "--user", "restart", "elephant.service", "walker.service"]);
                                root.refreshPlugins();
                            }
                        }
                    }
                }

                // Category Filter Pills
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.extraSmall

                    Repeater {
                        model: ["All", "Core", "Productivity", "Utilities", "Security", "Media", "System"]

                        StyledRect {
                            id: catPill

                            required property string modelData
                            readonly property bool isSelected: root.activeCategory === modelData

                            implicitHeight: 32
                            implicitWidth: pillText.implicitWidth + Tokens.padding.medium * 2
                            radius: Tokens.rounding.full
                            color: isSelected ? Colours.palette.m3primary : Colours.tPalette.m3surfaceContainer

                            Behavior on color { CAnim {} }

                            StyledText {
                                id: pillText
                                anchors.centerIn: parent
                                text: catPill.modelData
                                font: Tokens.font.label.medium
                                color: catPill.isSelected ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
                            }

                            StateLayer {
                                radius: Tokens.rounding.full
                                onClicked: root.activeCategory = catPill.modelData
                            }
                        }
                    }
                }
            }
        }

        // ====================================================================
        // PLUGINS LIST
        // ====================================================================
        SectionHeader {
            text: root.activeCategory === "All" ? Tr.tr("Launcher & System Plugins (%1)").arg(root.pluginsList.length) : Tr.tr("%1 Plugins").arg(root.activeCategory)
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.extraSmall

            Repeater {
                model: {
                    const list = root.pluginsList ?? [];
                    if (root.activeCategory === "All")
                        return list;
                    return list.filter(p => p.category === root.activeCategory);
                }

                StyledRect {
                    id: pluginCard

                    required property var modelData
                    required property int index

                    readonly property bool isEnabled: modelData?.enabled ?? false

                    Layout.fillWidth: true
                    implicitHeight: 68
                    radius: Tokens.rounding.medium
                    color: Colours.tPalette.m3surfaceContainer

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Tokens.padding.largeIncreased
                        anchors.rightMargin: Tokens.padding.largeIncreased
                        spacing: Tokens.spacing.medium

                        StyledClippingRect {
                            implicitWidth: 38
                            implicitHeight: 38
                            radius: Tokens.rounding.full
                            color: pluginCard.isEnabled ? Colours.palette.m3primaryContainer : Colours.palette.m3surfaceContainerHighest

                            MaterialIcon {
                                anchors.centerIn: parent
                                text: pluginCard.modelData?.icon ?? "extension"
                                color: pluginCard.isEnabled ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3outline
                                fontStyle: Tokens.font.icon.medium
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            RowLayout {
                                spacing: Tokens.spacing.small

                                StyledText {
                                    text: pluginCard.modelData?.name ?? ""
                                    font: Tokens.font.body.medium
                                    color: Colours.palette.m3onSurface
                                    elide: Text.ElideRight
                                }

                                StyledRect {
                                    implicitHeight: 20
                                    implicitWidth: catLabel.implicitWidth + Tokens.padding.small * 2
                                    radius: Tokens.rounding.small
                                    color: Colours.palette.m3surfaceContainerHigh

                                    StyledText {
                                        id: catLabel
                                        anchors.centerIn: parent
                                        text: pluginCard.modelData?.category ?? "General"
                                        font: Tokens.font.label.small
                                        color: Colours.palette.m3outline
                                    }
                                }
                            }

                            StyledText {
                                text: pluginCard.modelData?.description ?? ""
                                font: Tokens.font.label.small
                                color: Colours.palette.m3outline
                                elide: Text.ElideRight
                            }
                        }

                        StyledSwitch {
                            checked: pluginCard.isEnabled
                            onToggled: {
                                const pid = pluginCard.modelData?.id;
                                if (pid)
                                    root.togglePlugin(pid);
                            }
                        }
                    }
                }
            }
        }

        // ====================================================================
        // CUSTOM EXTENSIONS & SCRIPTS
        // ====================================================================
        SectionHeader {
            text: Tr.tr("Custom Plugins & Scripts")
        }

        ConnectedRect {
            Layout.fillWidth: true
            first: true
            last: true
            implicitHeight: customLayout.implicitHeight + Tokens.padding.largeIncreased * 2

            ColumnLayout {
                id: customLayout

                anchors.fill: parent
                anchors.margins: Tokens.padding.largeIncreased
                spacing: Tokens.spacing.small

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.medium

                    MaterialIcon {
                        text: "code"
                        color: Colours.palette.m3primary
                        fontStyle: Tokens.font.icon.medium
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        StyledText {
                            text: Tr.tr("Custom Shell & Launcher Addons")
                            font: Tokens.font.body.medium
                            color: Colours.palette.m3onSurface
                        }

                        StyledText {
                            text: Tr.tr("Place your custom QML components, shell plugins, or Elephant scripts in ~/.config/caelestia/plugins/.")
                            font: Tokens.font.label.small
                            color: Colours.palette.m3outline
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: Tokens.spacing.small

                    IconTextButton {
                        icon: "folder_open"
                        text: Tr.tr("Open Plugins Directory")
                        font: Tokens.font.body.small
                        isRound: true
                        type: IconTextButton.Tonal
                        onClicked: Quickshell.execDetached(["xdg-open", `${Paths.home}/.config/caelestia/plugins`])
                    }
                }
            }
        }
    }
}
