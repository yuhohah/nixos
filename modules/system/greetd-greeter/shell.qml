import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Greetd

ShellRoot {
  id: root

  property string password: ""
  property var pendingPassword: null
  property bool authenticating: false
  property bool awaitingPrompt: false
  property string errorText: ""
  property int errorSeq: 0
  property var activeScreen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
  property string batteryText: "AC"
  property string uptimeText: "0m"

  readonly property var ptDays: [
    "domingo",
    "segunda-feira",
    "terça-feira",
    "quarta-feira",
    "quinta-feira",
    "sexta-feira",
    "sábado"
  ]

  readonly property var ptMonths: [
    "janeiro",
    "fevereiro",
    "março",
    "abril",
    "maio",
    "junho",
    "julho",
    "agosto",
    "setembro",
    "outubro",
    "novembro",
    "dezembro"
  ]

  function pad2(n) {
    return n < 10 ? "0" + n : String(n)
  }

  function formatTime(d) {
    return pad2(d.getHours()) + ":" + pad2(d.getMinutes()) + ":" + pad2(d.getSeconds())
  }

  function formatDate(d) {
    return ptDays[d.getDay()] + ", " + pad2(d.getDate()) + " de " + ptMonths[d.getMonth()]
  }

  function formatUptime(raw) {
    const secs = Math.floor(parseFloat(String(raw || "0").split(/\s+/)[0]) || 0)
    const days = Math.floor(secs / 86400)
    const hours = Math.floor((secs % 86400) / 3600)
    const mins = Math.floor((secs % 3600) / 60)
    const parts = []
    if (days > 0) parts.push(days + (days === 1 ? " day" : " days"))
    if (hours > 0) parts.push(hours + (hours === 1 ? " hour" : " hours"))
    if (mins > 0 || parts.length === 0) parts.push(mins + (mins === 1 ? " minute" : " minutes"))
    return parts.join(", ")
  }

  function submitPassword() {
    if (root.authenticating || root.password.length === 0)
      return
    if (!Greetd.available)
      return

    root.errorText = ""
    root.authenticating = true

    if (Greetd.state === GreetdState.Authenticating && root.awaitingPrompt) {
      root.awaitingPrompt = false
      const pw = root.password
      root.password = ""
      Greetd.respond(pw)
      return
    }

    root.pendingPassword = root.password
    root.password = ""
    if (Greetd.state !== GreetdState.Inactive)
      Greetd.cancelSession()
    Greetd.createSession(GreeterConfig.user)
  }

  function clearInput() {
    if (root.authenticating)
      return
    root.password = ""
    root.errorText = ""
  }

  Connections {
    target: Quickshell

    function onScreensChanged() {
      if (Quickshell.screens.length === 0) {
        root.activeScreen = null
        return
      }
      for (let i = 0; i < Quickshell.screens.length; i++) {
        if (Quickshell.screens[i] === root.activeScreen)
          return
      }
      root.activeScreen = Quickshell.screens[0]
    }
  }

  Connections {
    target: Greetd

    function onAuthMessage(message, error, responseRequired, echoResponse) {
      if (responseRequired) {
        if (root.pendingPassword !== null) {
          const pw = root.pendingPassword
          root.pendingPassword = null
          Greetd.respond(pw)
        } else {
          root.authenticating = false
          root.awaitingPrompt = true
          if (message && message.trim().length > 0)
            root.errorText = message.trim()
        }
      } else {
        if (error && message && message.trim().length > 0)
          root.errorText = message.trim()
        Greetd.respond("")
      }
    }

    function onReadyToLaunch() {
      root.pendingPassword = null
      Greetd.launch(GreeterConfig.sessionCommand, [], true)
    }

    function onLaunched() {
      Qt.quit()
    }

    function onAuthFailure(message) {
      root.authenticating = false
      root.awaitingPrompt = false
      root.pendingPassword = null
      root.password = ""
      root.errorText = (message && message.trim().length > 0) ? message.trim() : "Senha incorreta"
      root.errorSeq += 1
    }

    function onError(err) {
      root.authenticating = false
      root.awaitingPrompt = false
      root.pendingPassword = null
      root.password = ""
      root.errorText = (err && err.trim().length > 0) ? err.trim() : "Erro de autenticação"
      root.errorSeq += 1
      if (Greetd.state !== GreetdState.Inactive)
        Greetd.cancelSession()
    }
  }

  SystemClock {
    id: sysClock
    precision: SystemClock.Seconds
  }

  FileView {
    id: uptimeFile
    path: "/proc/uptime"
    watchChanges: false
    printErrors: false
    onLoaded: root.uptimeText = root.formatUptime(text())
  }

  Timer {
    interval: 60000
    running: true
    repeat: true
    onTriggered: uptimeFile.reload()
  }

  Process {
    id: batteryProc
    command: ["sh", "-c", "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1"]
    stdout: StdioCollector {
      onStreamFinished: {
        const cap = String(text || "").trim()
        root.batteryText = cap.length > 0 ? (cap + "%") : "AC"
      }
    }
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      if (!batteryProc.running)
        batteryProc.running = true
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: win
      required property var modelData
      readonly property bool isActiveScreen: root.activeScreen === null || root.activeScreen === modelData

      screen: modelData
      color: "#1e1e2e"
      exclusionMode: ExclusionMode.Ignore

      anchors {
        top: true
        bottom: true
        left: true
        right: true
      }

      WlrLayershell.namespace: "quickshell-greeter"
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: isActiveScreen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand

      onIsActiveScreenChanged: {
        if (isActiveScreen)
          passwordInput.forceActiveFocus()
      }

      onVisibleChanged: {
        if (visible && isActiveScreen)
          passwordInput.forceActiveFocus()
      }

      Timer {
        interval: 100
        running: true
        repeat: false
        onTriggered: {
          if (win.isActiveScreen)
            passwordInput.forceActiveFocus()
        }
      }

      // Wallpaper com blur e tonalidade equivalentes ao hyprlock.nix
      Image {
        id: bgImage
        anchors.fill: parent
        source: GreeterConfig.backgroundPath
        fillMode: Image.PreserveAspectCrop
        smooth: true
        asynchronous: false
        visible: false
      }

      MultiEffect {
        anchors.fill: parent
        source: bgImage
        blurEnabled: true
        blur: 0.45
        blurMax: 32
        autoPaddingEnabled: false
        brightness: -0.18
        contrast: -0.10
        saturation: 0.17
      }

      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
          if (root.activeScreen !== win.modelData)
            root.activeScreen = win.modelData
          passwordInput.forceActiveFocus()
        }
        onPressed: {
          root.activeScreen = win.modelData
          passwordInput.forceActiveFocus()
        }
      }

      // Relógio (position = 0, 200 no hyprlock)
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -200
        text: root.formatTime(sysClock.date)
        color: "#cba6f7"
        font.family: "JetBrainsMono Nerd Font Mono"
        font.pixelSize: 70
      }

      // Data (position = 0, 100 no hyprlock)
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -100
        text: root.formatDate(sysClock.date)
        color: "#a6adc8"
        font.family: "JetBrainsMono Nerd Font Mono"
        font.pixelSize: 20
      }

      // Foto de perfil circular (position = 0, 10; size = 95 no hyprlock)
      Item {
        id: avatarContainer
        width: 95
        height: 95
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -10

        Image {
          id: avatarImage
          anchors.fill: parent
          anchors.margins: 2
          source: GreeterConfig.avatarPath
          fillMode: Image.PreserveAspectCrop
          autoTransform: true
          smooth: true
          asynchronous: false
          layer.enabled: true
          visible: false
        }

        Item {
          id: avatarMask
          anchors.fill: avatarImage
          layer.enabled: true
          visible: false

          Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "#ffffff"
          }
        }

        MultiEffect {
          anchors.fill: avatarImage
          source: avatarImage
          maskEnabled: true
          maskSource: avatarMask
          maskThresholdMin: 0.5
          maskSpreadAtMin: 1.0
        }

        Rectangle {
          anchors.fill: parent
          radius: width / 2
          color: "transparent"
          border.width: 2
          border.color: "#bfcdd6f4"
        }
      }

      // Username (position = 0, -60 no hyprlock)
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 60
        text: GreeterConfig.user
        color: "#cba6f7"
        font.family: "JetBrainsMono Nerd Font Mono"
        font.pixelSize: 18
      }

      // Campo de senha (position = 0, -130; size = 300x50 no hyprlock)
      Item {
        id: inputWrapper
        width: 300
        height: 50
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 130

        property real shakeOffset: 0
        transform: Translate { x: inputWrapper.shakeOffset }

        SequentialAnimation {
          id: shakeAnim
          NumberAnimation { target: inputWrapper; property: "shakeOffset"; to: -10; duration: 45 }
          NumberAnimation { target: inputWrapper; property: "shakeOffset"; to: 10; duration: 45 }
          NumberAnimation { target: inputWrapper; property: "shakeOffset"; to: -6; duration: 40 }
          NumberAnimation { target: inputWrapper; property: "shakeOffset"; to: 6; duration: 40 }
          NumberAnimation { target: inputWrapper; property: "shakeOffset"; to: 0; duration: 35 }
        }

        Connections {
          target: root
          function onErrorSeqChanged() {
            shakeAnim.restart()
          }
        }

        Rectangle {
          id: inputBox
          anchors.fill: parent
          radius: height / 2
          color: "#1e1e2e"
          border.width: 3
          border.color: root.errorText.length > 0
            ? "#f38ba8"
            : (root.authenticating ? "#f9e2af" : "#cba6f7")

          Behavior on border.color {
            ColorAnimation { duration: 150 }
          }

          layer.enabled: true
          layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.55
            shadowOpacity: 0.55
            shadowColor: "#11111b"
            shadowVerticalOffset: 3
          }
        }

        // Placeholder centralizado ("Senha...")
        Text {
          anchors.centerIn: parent
          text: root.authenticating ? "Verificando..." : "Senha..."
          color: root.authenticating ? "#f9e2af" : "#a6adc8"
          font.family: "JetBrainsMono Nerd Font Mono"
          font.pixelSize: 16
          visible: root.password.length === 0
        }

        // Input real ativo na tela focada
        TextInput {
          id: passwordInput
          anchors.fill: parent
          anchors.leftMargin: 20
          anchors.rightMargin: 20
          visible: win.isActiveScreen
          enabled: win.isActiveScreen && !root.authenticating
          focus: win.isActiveScreen
          echoMode: TextInput.Password
          passwordCharacter: "•"
          color: "#cdd6f4"
          selectionColor: "#cba6f7"
          selectedTextColor: "#11111b"
          cursorVisible: false
          horizontalAlignment: TextInput.AlignHCenter
          verticalAlignment: TextInput.AlignVCenter
          font.family: "JetBrainsMono Nerd Font Mono"
          font.pixelSize: 18

          Component.onCompleted: {
            if (win.isActiveScreen)
              forceActiveFocus()
          }

          onTextEdited: {
            root.password = text
            if (root.errorText.length > 0)
              root.errorText = ""
          }

          Connections {
            target: root
            function onPasswordChanged() {
              if (passwordInput.text !== root.password)
                passwordInput.text = root.password
            }
          }

          Keys.onReturnPressed: root.submitPassword()
          Keys.onEnterPressed: root.submitPassword()
          Keys.onEscapePressed: root.clearInput()
        }

        // Espelho visual dos pontos nas demais telas (multi-monitor sincronizado)
        Text {
          anchors.centerIn: parent
          visible: !win.isActiveScreen && root.password.length > 0
          text: "•".repeat(root.password.length)
          color: "#cdd6f4"
          font.family: "JetBrainsMono Nerd Font Mono"
          font.pixelSize: 18
        }
      }

      // Mensagem discreta de erro abaixo do campo de senha
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 178
        text: root.errorText
        color: "#f38ba8"
        font.family: "JetBrainsMono Nerd Font Mono"
        font.pixelSize: 13
        visible: root.errorText.length > 0
      }

      // Bateria (canto inferior esquerdo, igual ao hyprlock)
      Text {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 30
        anchors.bottomMargin: 30
        text: (root.batteryText === "AC" ? "󰚥 " : "󰁹 ") + root.batteryText
        color: "#cba6f7"
        font.family: "JetBrainsMono Nerd Font Mono"
        font.pixelSize: 16
      }

      // Uptime (canto inferior direito, igual ao hyprlock)
      Text {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 30
        anchors.bottomMargin: 30
        text: "󰅐 " + root.uptimeText
        color: "#fab387"
        font.family: "JetBrainsMono Nerd Font Mono"
        font.pixelSize: 16
      }
    }
  }
}
