//@ pragma UseQApplication
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

ShellRoot {
    id: root

    property int cpuUsage: 0
    property string memUsed: "0.0"
    property int wifiSignal: 0
    property int audioVolume: 100
    property bool audioMuted: false
    property bool showDate: false
    property string netKind: "disconnected"
    property string netLabel: ""
    property bool showSsid: false

    // Omarchy Wifi icon function (stepped 5-tier Nerd Font icons)
    function wifiIconFor(kind, strength) {
        if (kind === "ethernet") return "󰈀";
        if (kind === "disconnected" || strength <= 0) return "󰤮";
        let icons = ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"];
        let index = Math.max(0, Math.min(4, Math.ceil(strength / 20) - 1));
        return icons[index];
    }

    // Omarchy Clock format ring & smart precision
    property var clockFormats: [
        "hh:mm:ss",
        "dddd, hh:mm",
        "ddd d MMM - hh:mm",
        "dddd, dd de MMMM de yyyy",
        "yyyy-MM-dd hh:mm"
    ]
    property int clockFormatIndex: 0

    function cycleClockFormat() {
        root.clockFormatIndex = (root.clockFormatIndex + 1) % root.clockFormats.length;
    }

    Timer {
        id: closeCalTimer
        interval: 300
        repeat: false
        onTriggered: calPopup.visible = false
    }

    property int viewYear: clock.date.getFullYear()
    property int viewMonth: clock.date.getMonth()

    function getDaysModel(year, month) {
        let days = [];
        let firstDayIndex = new Date(year, month, 1).getDay();
        let daysInMonth = new Date(year, month + 1, 0).getDate();
        let prevDaysCount = new Date(year, month, 0).getDate();

        let now = clock.date;
        let todayD = now.getDate();
        let todayM = now.getMonth();
        let todayY = now.getFullYear();

        for (let i = firstDayIndex - 1; i >= 0; i--) {
            days.push({ day: prevDaysCount - i, inMonth: false, isToday: false });
        }
        for (let d = 1; d <= daysInMonth; d++) {
            let isToday = (d === todayD && month === todayM && year === todayY);
            days.push({ day: d, inMonth: true, isToday: isToday });
        }
        let totalCells = days.length <= 35 ? 35 : 42;
        let nextD = 1;
        while (days.length < totalCells) {
            days.push({ day: nextD++, inMonth: false, isToday: false });
        }
        return days;
    }

    // Helpers to dispatch commands safely using Hyprland's Lua dispatcher
    function execApp(cmd) {
        Hyprland.dispatch("hl.dsp.exec_cmd('" + cmd + "')");
    }

    function switchWorkspace(id) {
        Hyprland.dispatch("hl.dsp.focus({ workspace = '" + id + "' })");
    }

    Timer {
        id: syncTimer
        interval: 150
        repeat: false
        onTriggered: if (!statsProc.running) statsProc.running = true
    }

    function toggleMute() {
        root.audioMuted = !root.audioMuted;
        execApp("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle");
        syncTimer.restart();
    }

    function changeVolume(delta) {
        let step = delta > 0 ? 5 : -5;
        root.audioVolume = Math.max(0, Math.min(150, root.audioVolume + step));
        if (delta > 0) {
            execApp("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+");
        } else {
            execApp("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-");
        }
        syncTimer.restart();
    }

    SystemClock {
        id: clock
        precision: root.clockFormats[root.clockFormatIndex].indexOf("ss") !== -1
            ? SystemClock.Seconds
            : SystemClock.Minutes
    }

    Process {
        id: statsProc
        command: [
            "bash", "-c",
            "mem=$(awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {printf \"%.1f\", (t-a)/1048576}' /proc/meminfo); " +
            "cpu=$(awk '/^cpu / {u=$2+$4; t=$2+$4+$5; if(NR==1){u1=u; t1=t} else {print int((u-u1)*100/(t-t1))}}' <(head -n1 /proc/stat; sleep 0.1; head -n1 /proc/stat)); " +
            "wifi=$(awk 'NR==3 {sub(/\\./,\"\",$3); print int($3*100/70)}' /proc/net/wireless 2>/dev/null); " +
            "net_info=$(nmcli -t -f TYPE,STATE,CONNECTION dev 2>/dev/null | awk -F: '$2==\"connected\"{print $1\"\\t\"$3; exit}'); " +
            "net_kind=$(echo \"$net_info\" | cut -f1); " +
            "net_label=$(echo \"$net_info\" | cut -f2); " +
            "vol_raw=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null); " +
            "vol=$(echo \"$vol_raw\" | awk '{print int($2*100)}'); " +
            "muted=$(echo \"$vol_raw\" | grep -q \"MUTED\" && echo \"true\" || echo \"false\"); " +
            "echo \"{\\\"cpu\\\":${cpu:-0},\\\"mem\\\":\\\"${mem:-0.0}\\\",\\\"wifi\\\":${wifi:-0},\\\"net_kind\\\":\\\"${net_kind:-disconnected}\\\",\\\"net_label\\\":\\\"${net_label}\\\",\\\"vol\\\":${vol:-0},\\\"muted\\\":${muted}}\""
        ]
        stdout: SplitParser {
            onRead: data => {
                try {
                    let d = JSON.parse(data);
                    if (d.cpu !== undefined) root.cpuUsage = d.cpu;
                    if (d.mem !== undefined) root.memUsed = d.mem;
                    if (d.wifi !== undefined) root.wifiSignal = d.wifi;
                    if (d.net_kind !== undefined) root.netKind = d.net_kind;
                    if (d.net_label !== undefined) root.netLabel = d.net_label;
                    if (d.vol !== undefined) root.audioVolume = d.vol;
                    if (d.muted !== undefined) root.audioMuted = d.muted;
                } catch(e) {}
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!statsProc.running) statsProc.running = true;
        }
    }

    PanelWindow {
        id: bar
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "quickshell"

        anchors {
            top: true
            left: true
            right: true
        }

        margins {
            top: 12
            left: 12
            right: 12
        }

        implicitHeight: 32
        color: "transparent"

        // DBus Menu Opener and Styled Pill Popup
        QsMenuOpener {
            id: menuOpener
        }

        PopupWindow {
            id: menuPopup
            anchor.window: bar
            anchor.edges: Edges.Bottom | Edges.Right
            anchor.gravity: Edges.Bottom | Edges.Left
            anchor.margins.top: 8
            anchor.margins.right: 12
            visible: false
            implicitWidth: Math.max(180, menuCol.implicitWidth + 24)
            implicitHeight: menuCol.implicitHeight + 16
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                radius: 12
                color: "#e61e1e2e"
                border.color: "#33cba6f7"
                border.width: 1

                ColumnLayout {
                    id: menuCol
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 3

                    Repeater {
                        model: menuOpener.children
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: modelData.isSeparator ? 5 : 28
                            radius: 8
                            color: modelData.isSeparator ? "transparent" : (entryHover.containsMouse ? "#313244" : "transparent")

                            Rectangle {
                                visible: Boolean(modelData.isSeparator)
                                anchors.centerIn: parent
                                width: parent.width - 8
                                height: 1
                                color: "#45475a"
                            }

                            RowLayout {
                                visible: !modelData.isSeparator
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 8

                                IconImage {
                                    visible: Boolean(modelData.icon && modelData.icon !== "")
                                    implicitWidth: 14
                                    implicitHeight: 14
                                    source: modelData.icon ? modelData.icon : ""
                                }

                                Text {
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    text: modelData.text ? modelData.text.replace(/&/g, "") : ""
                                    color: entryHover.containsMouse ? "#cba6f7" : "#cdd6f4"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                }

                                Text {
                                    visible: Boolean(modelData.checked)
                                    text: "✓"
                                    color: "#a6e3a1"
                                    font.pixelSize: 11
                                }
                            }

                            MouseArea {
                                id: entryHover
                                anchors.fill: parent
                                hoverEnabled: !modelData.isSeparator
                                cursorShape: modelData.isSeparator ? Qt.ArrowCursor : Qt.PointingHandCursor
                                onClicked: {
                                    if (!modelData.isSeparator) {
                                        modelData.trigger();
                                        menuPopup.visible = false;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        PopupWindow {
            id: calPopup
            anchor.window: bar
            anchor.item: clockPill
            anchor.edges: Edges.Bottom
            anchor.gravity: Edges.Bottom
            anchor.margins.top: 8
            visible: false
            implicitWidth: 280
            implicitHeight: 310
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                radius: 14
                color: "#e61e1e2e"
                border.color: "#33cba6f7"
                border.width: 1

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: closeCalTimer.stop()
                    onExited: closeCalTimer.restart()
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    // Header: month navigation
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            implicitWidth: 24
                            implicitHeight: 24
                            radius: 6
                            color: prevHover.containsMouse ? "#313244" : "transparent"
                            Text {
                                anchors.centerIn: parent
                                text: ""
                                color: "#cba6f7"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                            }
                            MouseArea {
                                id: prevHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.viewMonth === 0) {
                                        root.viewMonth = 11;
                                        root.viewYear -= 1;
                                    } else {
                                        root.viewMonth -= 1;
                                    }
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            text: new Date(root.viewYear, root.viewMonth, 1).toLocaleDateString(Qt.locale(), "MMMM yyyy").toUpperCase()
                            color: "#cba6f7"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            font.bold: true

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.viewYear = clock.date.getFullYear();
                                    root.viewMonth = clock.date.getMonth();
                                }
                            }
                        }

                        Rectangle {
                            implicitWidth: 24
                            implicitHeight: 24
                            radius: 6
                            color: nextHover.containsMouse ? "#313244" : "transparent"
                            Text {
                                anchors.centerIn: parent
                                text: ""
                                color: "#cba6f7"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                            }
                            MouseArea {
                                id: nextHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.viewMonth === 11) {
                                        root.viewMonth = 0;
                                        root.viewYear += 1;
                                    } else {
                                        root.viewMonth += 1;
                                    }
                                }
                            }
                        }
                    }

                    // Weekdays row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Repeater {
                            model: ["D", "S", "T", "Q", "Q", "S", "S"]
                            delegate: Text {
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                                text: modelData
                                color: "#f9e2af"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }
                    }

                    // Days grid
                    GridLayout {
                        id: daysGrid
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        columns: 7
                        rowSpacing: 4
                        columnSpacing: 2

                        Repeater {
                            model: root.getDaysModel(root.viewYear, root.viewMonth)
                            delegate: Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 6
                                color: modelData.isToday ? "#cba6f7" : (dayHover.containsMouse ? "#313244" : "transparent")

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.day
                                    color: modelData.isToday ? "#11111b" : (modelData.inMonth ? "#cdd6f4" : "#585b70")
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                    font.bold: modelData.isToday
                                }

                                MouseArea {
                                    id: dayHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                }
                            }
                        }
                    }

                    // Footer date
                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: Qt.formatDateTime(clock.date, "dddd, dd de MMMM de yyyy")
                        color: "#a6adc8"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                    }
                }
            }
        }

        Item {
            anchors.fill: parent

            // ==========================================
            // LEFT: Workspaces (1 - 10)
            // ==========================================
            Rectangle {
                id: wsPill
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                width: wsRow.implicitWidth + 16
                radius: 12
                color: "#a81e1e2e"
                border.color: "#33cba6f7"
                border.width: 1

                RowLayout {
                    id: wsRow
                    anchors.centerIn: parent
                    spacing: 4

                    Repeater {
                        model: 10
                        delegate: Rectangle {
                            id: wsBtn
                            property int wsId: index + 1
                            property bool isActive: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId

                            implicitWidth: isActive ? 26 : 20
                            implicitHeight: 20
                            radius: 6
                            color: isActive ? "#cba6f7" : (wsMouse.containsMouse ? "#45475a" : "transparent")
                            border.color: isActive ? "#cba6f7" : (wsMouse.containsMouse ? "#45475a" : "transparent")
                            border.width: 1

                            Behavior on implicitWidth {
                                NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                            }
                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: wsBtn.wsId
                                color: wsBtn.isActive ? "#11111b" : "#cdd6f4"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                font.bold: wsBtn.isActive
                            }

                            MouseArea {
                                id: wsMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    menuPopup.visible = false;
                                    root.switchWorkspace(wsBtn.wsId);
                                }
                            }
                        }
                    }
                }
            }

            // ==========================================
            // CENTER: Clock
            // ==========================================
            Rectangle {
                id: clockPill
                anchors.centerIn: parent
                height: parent.height
                width: clockText.implicitWidth + 24
                radius: 12
                color: "#a81e1e2e"
                border.color: "#33cba6f7"
                border.width: 1

                Text {
                    id: clockText
                    anchors.centerIn: parent
                    text: Qt.formatDateTime(clock.date, root.clockFormats[root.clockFormatIndex])
                    color: "#f5c2e7"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor
                    onEntered: {
                        root.viewYear = clock.date.getFullYear();
                        root.viewMonth = clock.date.getMonth();
                        closeCalTimer.stop();
                        calPopup.visible = true;
                    }
                    onExited: closeCalTimer.restart()
                    onClicked: mouse => {
                        menuPopup.visible = false;
                        root.cycleClockFormat();
                    }
                }
            }

            // ==========================================
            // RIGHT: Audio, CPU, Mem, Wifi, System Tray
            // ==========================================
            RowLayout {
                anchors {
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                }
                spacing: 6

                // 1. Audio (Synced via wpctl)
                Rectangle {
                    implicitHeight: parent.height
                    implicitWidth: audioLayout.implicitWidth + 18
                    radius: 12
                    color: "#a81e1e2e"
                    border.color: "#33cba6f7"
                    border.width: 1

                    RowLayout {
                        id: audioLayout
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: root.audioMuted ? "󰝟" : (root.audioVolume > 50 ? "" : (root.audioVolume > 0 ? "" : ""))
                            color: root.audioMuted ? "#f38ba8" : "#89b4fa"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13
                        }

                        Text {
                            text: root.audioMuted ? "MUTE" : (root.audioVolume + "%")
                            color: "#cdd6f4"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: mouse => {
                            menuPopup.visible = false;
                            if (mouse.button === Qt.RightButton) {
                                root.execApp("pavucontrol");
                            } else {
                                root.toggleMute();
                            }
                        }
                        onWheel: wheel => {
                            root.changeVolume(wheel.angleDelta.y);
                        }
                    }
                }

                // 2. CPU
                Rectangle {
                    implicitHeight: parent.height
                    implicitWidth: cpuText.implicitWidth + 18
                    radius: 12
                    color: "#a81e1e2e"
                    border.color: "#33cba6f7"
                    border.width: 1

                    Text {
                        id: cpuText
                        anchors.centerIn: parent
                        text: "cpu: " + root.cpuUsage + "%"
                        color: "#cdd6f4"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            menuPopup.visible = false;
                            root.execApp("alacritty -e btop");
                        }
                    }
                }

                // 3. Memory
                Rectangle {
                    implicitHeight: parent.height
                    implicitWidth: memText.implicitWidth + 18
                    radius: 12
                    color: "#a81e1e2e"
                    border.color: "#33cba6f7"
                    border.width: 1

                    Text {
                        id: memText
                        anchors.centerIn: parent
                        text: "mem: " + root.memUsed + "G"
                        color: "#cdd6f4"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            menuPopup.visible = false;
                            root.execApp("alacritty -e btop");
                        }
                    }
                }

                // 4. Wifi / Network (Omarchy Style)
                Rectangle {
                    implicitHeight: parent.height
                    implicitWidth: netLayout.implicitWidth + 18
                    radius: 12
                    color: "#a81e1e2e"
                    border.color: "#33cba6f7"
                    border.width: 1

                    RowLayout {
                        id: netLayout
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: root.wifiIconFor(root.netKind, root.wifiSignal)
                            color: root.netKind === "disconnected" ? "#f38ba8" : (root.wifiSignal < 30 && root.netKind === "wifi" ? "#f9e2af" : "#a6e3a1")
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13
                        }

                        Text {
                            text: {
                                if (root.netKind === "disconnected") return "Offline";
                                if (root.netKind === "ethernet") return "Ethernet";
                                if (root.showSsid && root.netLabel !== "") return root.netLabel;
                                return root.wifiSignal > 0 ? (root.wifiSignal + "%") : (root.netLabel !== "" ? root.netLabel : "Connected");
                            }
                            color: "#cdd6f4"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mouse => {
                            menuPopup.visible = false;
                            if (mouse.button === Qt.RightButton) {
                                root.showSsid = !root.showSsid;
                            } else {
                                root.execApp("alacritty -e nmtui");
                            }
                        }
                    }
                }

                // 5. System Tray
                Rectangle {
                    visible: SystemTray.items.values && SystemTray.items.values.length > 0
                    implicitHeight: parent.height
                    implicitWidth: trayRow.implicitWidth + 16
                    radius: 12
                    color: "#a81e1e2e"
                    border.color: "#33cba6f7"
                    border.width: 1

                    RowLayout {
                        id: trayRow
                        anchors.centerIn: parent
                        spacing: 8

                        Repeater {
                            model: SystemTray.items.values
                            delegate: Item {
                                id: trayItem
                                implicitWidth: 18
                                implicitHeight: 18

                                IconImage {
                                    anchors.centerIn: parent
                                    implicitWidth: 16
                                    implicitHeight: 16
                                    source: modelData.icon
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: mouse => {
                                        if (mouse.button === Qt.RightButton && modelData.hasMenu) {
                                            if (menuOpener.menu === modelData.menu && menuPopup.visible) {
                                                menuPopup.visible = false;
                                            } else {
                                                menuPopup.anchor.item = trayItem;
                                                menuOpener.menu = modelData.menu;
                                                menuPopup.visible = true;
                                            }
                                        } else {
                                            menuPopup.visible = false;
                                            modelData.activate();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
