pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Config
import Caelestia.I18n
import qs.components
import qs.components.filedialog
import qs.components.images
import qs.services
import qs.utils

Item {
    id: root

    clip: true

    property string source: Wallpapers.current
    property CachingImage current
    property bool completed: false

    function updateWallpaper(path: string): void {
        if (!path) {
            current = null;
            return;
        }

        // On initial startup/boot, display the wallpaper immediately with full opacity
        // and standard scale to eliminate any black screen flash or input delay.
        const isInitial = !completed || current === null;
        if (isInitial) {
            completed = true;
        }

        current = imgComp.createObject(this, {
            path: path,
            initial: isInitial
        });
    }

    onSourceChanged: updateWallpaper(source)

    Component.onCompleted: {
        if (source && current === null) {
            updateWallpaper(source);
        }
    }

    Loader {
        asynchronous: true
        anchors.fill: parent

        active: root.completed && !root.source

        sourceComponent: StyledRect {
            color: Colours.palette.m3surfaceContainer

            Row {
                anchors.centerIn: parent
                spacing: Tokens.spacing.largeIncreased

                MaterialIcon {
                    text: "sentiment_stressed"
                    color: Colours.palette.m3onSurfaceVariant
                    fontStyle: Tokens.font.icon.builders.extraLarge.scale(5).build()
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Tokens.spacing.small

                    StyledText {
                        text: Tr.tr("Wallpaper missing?")
                        color: Colours.palette.m3onSurfaceVariant
                        font: Tokens.font.body.builders.large.size(28 * 2).weight(Font.Bold).build()
                    }

                    StyledRect {
                        implicitWidth: selectWallText.implicitWidth + Tokens.padding.extraLargeIncreased
                        implicitHeight: selectWallText.implicitHeight + Tokens.padding.small

                        radius: Tokens.rounding.full
                        color: Colours.palette.m3primary

                        FileDialog {
                            id: dialog

                            title: Tr.tr("Select a wallpaper")
                            filterLabel: Tr.tr("Image files")
                            filters: Images.validImageExtensions
                            onAccepted: path => Wallpapers.setWallpaper(path)
                        }

                        StateLayer {
                            radius: parent.radius
                            color: Colours.palette.m3onPrimary
                            onClicked: dialog.open()
                        }

                        StyledText {
                            id: selectWallText

                            anchors.centerIn: parent

                            text: Tr.tr("Set it now!")
                            color: Colours.palette.m3onPrimary
                            font: Tokens.font.body.large
                        }
                    }
                }
            }
        }
    }

    Component {
        id: imgComp

        CachingImage {
            id: img

            property bool initial: false
            readonly property bool isCurrent: root.current === img
            property bool isReady: status === Image.Ready
            property bool exiting: false

            anchors.fill: parent
            transformOrigin: Item.Center

            opacity: initial ? 1 : 0
            scale: initial ? 1.0 : 1.05

            function startEnter(): void {
                if (initial)
                    return;
                enterAnim.start();
            }

            function startExit(): void {
                if (exiting)
                    return;
                exiting = true;
                if (enterAnim.running)
                    enterAnim.stop();
                exitAnim.start();
            }

            onStatusChanged: {
                if (status === Image.Ready) {
                    isReady = true;
                    startEnter();
                }
            }

            Component.onCompleted: {
                if (status === Image.Ready) {
                    isReady = true;
                    startEnter();
                }
            }

            Connections {
                target: root
                function onCurrentChanged(): void {
                    if (!img.isCurrent && root.current && root.current.isReady) {
                        img.startExit();
                    }
                }
            }

            Timer {
                interval: 50
                repeat: true
                running: !img.isCurrent && !img.exiting && root.current && root.current.isReady
                onTriggered: {
                    stop();
                    img.startExit();
                }
            }

            Timer {
                interval: 3000
                running: !img.isCurrent
                onTriggered: img.destroy()
            }

            ParallelAnimation {
                id: enterAnim

                NumberAnimation {
                    target: img
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: Tokens.anim.durations.large
                    easing: Tokens.anim.emphasized
                }

                NumberAnimation {
                    target: img
                    property: "scale"
                    from: 1.05
                    to: 1.0
                    duration: Tokens.anim.durations.large
                    easing: Tokens.anim.emphasized
                }
            }

            ParallelAnimation {
                id: exitAnim

                NumberAnimation {
                    target: img
                    property: "opacity"
                    to: 0
                    duration: Tokens.anim.durations.large
                    easing: Tokens.anim.standard
                }

                NumberAnimation {
                    target: img
                    property: "scale"
                    to: 0.98
                    duration: Tokens.anim.durations.large
                    easing: Tokens.anim.standard
                }

                onFinished: img.destroy()
            }
        }
    }
}
