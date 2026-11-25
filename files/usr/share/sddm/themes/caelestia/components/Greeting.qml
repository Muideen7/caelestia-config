pragma ComponentBehavior: Bound
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

Item {
    id: root

    property bool firstInput
    property bool blurEnabled
    property real mainCardRadius
    property real blurAmount
    property int rootHeight
    property int rootWidth
    property string greetingText
    property string username
    property bool ap: false
    property string avatarShape: "circle"
    property var videoSourceItem: null

    signal unlockRequested()

    property date currentTime: new Date()
    property string osName: (config.os || "CachyOS").split(" ")[0]
    property string hostName: config.host || "localhost"

    function updateGreeting(): void {
        const h = new Date().getHours();
        if (h >= 20 || h < 4)
            greetingText = "Good night";
        else if (h >= 4 && h < 12)
            greetingText = "Good morning";
        else if (h >= 12 && h < 18)
            greetingText = "Good afternoon";
        else
            greetingText = "Good evening";
    }

    Component.onCompleted: updateGreeting()

    Timer {
        interval: 1000
        running: root.firstInput
        repeat: true
        onTriggered: {
            root.currentTime = new Date();
            if (root.currentTime.getSeconds() === 0)
                root.updateGreeting();
        }
    }

    readonly property var clockAxes: ({
            "wght": 650,
            "wdth": 90,
            "ROND": 35,
            "opsz": 144
        })

    readonly property var fontAxes: ({
            "wght": 650,
            "wdth": 110,
            "ROND": 15,
            "opsz": 48
        })

    FontLoader {
        id: googleSansFlex
        source: "../assets/google-sans-flex/GoogleSansFlex.ttf"
    }

    // Subtle top/bottom vignette so white/light clock & hint remain crisp over any wallpaper
    Rectangle {
        anchors.fill: parent
        visible: opacity > 0.01
        opacity: root.firstInput ? 1 : 0
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.38) }
            GradientStop { position: 0.35; color: Qt.rgba(0, 0, 0, 0.05) }
            GradientStop { position: 0.7; color: Qt.rgba(0, 0, 0, 0.12) }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.45) }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 320
                easing.type: Easing.InOutCubic
            }
        }
    }

    // Click anywhere on the greeter screen to reveal the login card
    MouseArea {
        anchors.fill: parent
        enabled: root.firstInput
        cursorShape: Qt.PointingHandCursor
        onClicked: root.unlockRequested()
    }

    // --- 1. Top-Center macOS / iOS Hero Date & Clock ---
    Column {
        id: heroClock

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Math.round(root.height * 0.11) + (root.firstInput ? 0 : -24)
        spacing: 2
        opacity: root.firstInput ? 1 : 0
        scale: root.firstInput ? 1.0 : 0.94

        Behavior on opacity {
            NumberAnimation {
                duration: 320
                easing.type: Easing.OutCubic
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: 360
                easing.type: Easing.OutCubic
            }
        }
        Behavior on anchors.topMargin {
            NumberAnimation {
                duration: 360
                easing.type: Easing.OutCubic
            }
        }

        Text {
            id: dateLabel
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(root.currentTime, "dddd, MMMM d")
            font.family: googleSansFlex.name
            font.pixelSize: 22
            font.weight: Font.DemiBold
            color: Qt.rgba(1, 1, 1, 0.92)
            renderType: Text.QtRendering

            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 2
                radius: 10
                samples: 17
                color: Qt.rgba(0, 0, 0, 0.55)
            }
        }

        Text {
            id: timeLabel
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.ap ? Qt.formatTime(root.currentTime, "hh:mm AP") : Qt.formatTime(root.currentTime, "HH:mm")
            font.family: googleSansFlex.name
            font.variableAxes: root.clockAxes
            font.pixelSize: 108
            color: "#ffffff"
            renderType: Text.QtRendering

            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 4
                radius: 18
                samples: 25
                color: Qt.rgba(0, 0, 0, 0.5)
            }
        }
    }

    // --- 2. Lower-Center Frosted Glass User Greeter Card ---
    Item {
        id: glassCardWrapper

        width: Math.max(430, cardContent.implicitWidth + 56)
        height: cardContent.implicitHeight + 40
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Math.round(root.height * 0.11) + (root.firstInput ? 0 : -24)
        opacity: root.firstInput ? 1 : 0
        scale: root.firstInput ? 1.0 : 0.92

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: 380
                easing.type: Easing.OutBack
            }
        }
        Behavior on anchors.bottomMargin {
            NumberAnimation {
                duration: 360
                easing.type: Easing.OutCubic
            }
        }

        // Frosted-glass blurred wallpaper backdrop
        Rectangle {
            id: cardGlassBg

            anchors.fill: parent
            radius: 32
            color: "transparent"
            clip: true
            layer.enabled: true

            AnimatedImage {
                id: backgroundBlur

                x: -(glassCardWrapper.x)
                y: -(glassCardWrapper.y)
                width: root.rootWidth
                height: root.rootHeight
                source: "../assets/background"
                fillMode: Image.PreserveAspectCrop

                ShaderEffectSource {
                    anchors.fill: parent
                    sourceItem: root.videoSourceItem
                    visible: root.videoSourceItem !== null
                }
            }

            MultiEffect {
                blurEnabled: root.blurEnabled
                source: backgroundBlur
                blur: Math.max(0.75, root.blurAmount)
                autoPaddingEnabled: false
                blurMultiplier: 1
                blurMax: 64
                anchors.fill: backgroundBlur
            }

            // Translucent M3 surface tint
            Rectangle {
                anchors.fill: parent
                color: config.background
                opacity: Math.min(0.78, Math.max(0.55, parseFloat(config.welcomeColorOpacity) || 0.7))
            }

            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: cardGlassBg.width
                    height: cardGlassBg.height
                    radius: cardGlassBg.radius
                }
            }
        }

        // Crisp frosted-glass rim highlight
        Rectangle {
            anchors.fill: parent
            radius: 32
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.24)
        }

        // Foreground layout: Avatar + Greeting + System Pills + Unlock Prompt
        RowLayout {
            id: cardContent

            anchors.centerIn: parent
            spacing: 22

            // User Avatar with primary accent ring
            Item {
                Layout.preferredWidth: 74
                Layout.preferredHeight: 74
                Layout.alignment: Qt.AlignVCenter

                Rectangle {
                    anchors.fill: parent
                    radius: root.avatarShape === "circle" ? width / 2 : 22
                    color: "transparent"
                    border.width: 2
                    border.color: config.primary
                    opacity: 0.85
                }

                Avatar {
                    anchors.centerIn: parent
                    width: 64
                    height: 64
                    avatarShape: root.avatarShape
                }
            }

            ColumnLayout {
                spacing: 6
                Layout.alignment: Qt.AlignVCenter

                // Greeting + Username
                Text {
                    id: welcomeText
                    renderType: Text.QtRendering
                    text: "<span style='color:" + config.text + ";'>" + root.greetingText + ", </span>"
                        + "<span style='color:" + config.primary + ";'>" + root.username + "</span>"
                    textFormat: Text.RichText
                    font.pointSize: 21
                    font.family: googleSansFlex.name
                    font.variableAxes: root.fontAxes
                    font.features: ({ "liga": 0 })
                }

                // System / Host / Status pills
                RowLayout {
                    spacing: 8

                    Rectangle {
                        implicitWidth: osLabel.implicitWidth + 18
                        implicitHeight: 24
                        radius: 12
                        color: config.subComponents

                        Text {
                            id: osLabel
                            anchors.centerIn: parent
                            text: root.osName
                            font.family: googleSansFlex.name
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: config.text
                            renderType: Text.NativeRendering
                        }
                    }

                    Rectangle {
                        implicitWidth: hostLabel.implicitWidth + 18
                        implicitHeight: 24
                        radius: 12
                        color: config.subComponents

                        Text {
                            id: hostLabel
                            anchors.centerIn: parent
                            text: root.hostName
                            font.family: googleSansFlex.name
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: config.text
                            opacity: 0.85
                            renderType: Text.NativeRendering
                        }
                    }

                    Rectangle {
                        implicitWidth: hintRow.implicitWidth + 18
                        implicitHeight: 24
                        radius: 12
                        color: Qt.rgba(
                            parseInt(config.primary.substring(1, 3), 16) / 255,
                            parseInt(config.primary.substring(3, 5), 16) / 255,
                            parseInt(config.primary.substring(5, 7), 16) / 255,
                            0.18
                        )

                        Row {
                            id: hintRow
                            anchors.centerIn: parent
                            spacing: 6

                            Rectangle {
                                width: 6
                                height: 6
                                radius: 3
                                anchors.verticalCenter: parent.verticalCenter
                                color: config.primary

                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite
                                    running: root.firstInput
                                    NumberAnimation { from: 1.0; to: 0.35; duration: 1100; easing.type: Easing.InOutSine }
                                    NumberAnimation { from: 0.35; to: 1.0; duration: 1100; easing.type: Easing.InOutSine }
                                }
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Click or press any key"
                                font.family: googleSansFlex.name
                                font.pixelSize: 11
                                font.weight: Font.Medium
                                color: config.primary
                                renderType: Text.NativeRendering
                            }
                        }
                    }
                }
            }
        }
    }
}
