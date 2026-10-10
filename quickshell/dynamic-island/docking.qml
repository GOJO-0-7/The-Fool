import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

PanelWindow {
    id: dockWindow
    
    width: Screen.width
    height: 60
    x: 0
    y: 0
    
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.NoDropShadowWindowHint
    anchors.left: parent ? parent.left : undefined
    anchors.top: parent ? parent.top : undefined
    
    property string colorBase: "#0a0e27"
    property string colorSurface: "#12141d"
    property string colorText: "#e2e8f0"
    property string colorTextMuted: "#94a3b8"
    property string colorAccent: "#06b6d4"
    
    property bool showDashboard: false
    property bool showExpanded: false
    property int currentTab: 0
    
    // Demo data - replace with actual bindings
    property string currentWeather: "24°C"
    property string currentWeatherDesc: "Partly Cloudy"
    property string currentBattery: "85%"
    property string currentWifi: "Connected"
    property string currentTime: "14:30"
    
    Rectangle {
        anchors.fill: parent
        color: dockWindow.colorBase
        opacity: 0.95
        radius: 24
        border.width: 1
        border.color: "#232736"
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 12
            
            // LEFT SECTION: Compact Status Pill
            Rectangle {
                Layout.preferredWidth: 200
                Layout.fillHeight: true
                color: dockWindow.colorSurface
                radius: 18
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8
                    
                    Text {
                        text: "󰖙"
                        font.pixelSize: 16
                        color: dockWindow.colorAccent
                    }
                    
                    Column {
                        Layout.fillWidth: true
                        spacing: 2
                        
                        Text {
                            text: dockWindow.currentWeatherDesc
                            font.pixelSize: 11
                            font.bold: true
                            color: dockWindow.colorText
                        }
                        Text {
                            text: dockWindow.currentWeather
                            font.pixelSize: 10
                            color: dockWindow.colorTextMuted
                        }
                    }
                    
                    Text {
                        text: "󰁹"
                        font.pixelSize: 14
                        color: dockWindow.colorAccent
                        Layout.leftMargin: 8
                    }
                    
                    Text {
                        text: dockWindow.currentBattery
                        font.pixelSize: 10
                        color: dockWindow.colorText
                        Layout.rightMargin: 6
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: dockWindow.showExpanded = !dockWindow.showExpanded
                }
            }
            
            Item { Layout.fillWidth: true }
            
            // RIGHT SECTION: Time & Dashboard Toggle
            Rectangle {
                Layout.preferredWidth: 180
                Layout.fillHeight: true
                color: dockWindow.colorSurface
                radius: 18
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    
                    Column {
                        Layout.fillWidth: true
                        spacing: 1
                        
                        Text {
                            text: dockWindow.currentTime
                            font.pixelSize: 14
                            font.bold: true
                            color: dockWindow.colorText
                        }
                        Text {
                            text: Qt.formatDate(new Date(), "ddd, MMM d")
                            font.pixelSize: 9
                            color: dockWindow.colorTextMuted
                        }
                    }
                    
                    Button {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        text: "󰍉"
                        font.pixelSize: 16
                        background: Rectangle {
                            color: dockWindow.showDashboard ? "#1a3a3a" : dockWindow.colorSurface
                            radius: 10
                            border.width: dockWindow.showDashboard ? 1 : 0
                            border.color: dockWindow.colorAccent
                        }
                        onClicked: dockWindow.showDashboard = !dockWindow.showDashboard
                    }
                }
            }
        }
    }
    
    // EXPANDED DASHBOARD OVERLAY
    Rectangle {
        visible: dockWindow.showDashboard
        anchors.fill: parent
        color: "transparent"
        
        MouseArea {
            anchors.fill: parent
            onClicked: dockWindow.showDashboard = false
        }
    }
    
    Rectangle {
        visible: dockWindow.showDashboard
        x: 20
        y: dockWindow.height + 10
        width: 400
        height: 600
        color: dockWindow.colorBase
        radius: 24
        border.width: 1
        border.color: "#232736"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
            
            // Dashboard Header
            Text {
                text: "Dashboard"
                font.pixelSize: 18
                font.bold: true
                color: dockWindow.colorText
            }
            
            // System Stats Grid
            GridLayout {
                columns: 2
                columnSpacing: 8
                rowSpacing: 8
                Layout.fillWidth: true
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: "#1a1d28"
                    radius: 12
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 2
                        
                        Text {
                            text: "RAM"
                            font.pixelSize: 10
                            color: dockWindow.colorTextMuted
                        }
                        Text {
                            text: "8.2 / 16 GB"
                            font.pixelSize: 13
                            font.bold: true
                            color: dockWindow.colorText
                        }
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: "#1a1d28"
                    radius: 12
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 2
                        
                        Text {
                            text: "CPU"
                            font.pixelSize: 10
                            color: dockWindow.colorTextMuted
                        }
                        Text {
                            text: "42%"
                            font.pixelSize: 13
                            font.bold: true
                            color: dockWindow.colorText
                        }
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: "#1a1d28"
                    radius: 12
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 2
                        
                        Text {
                            text: "BATTERY"
                            font.pixelSize: 10
                            color: dockWindow.colorTextMuted
                        }
                        Text {
                            text: dockWindow.currentBattery
                            font.pixelSize: 13
                            font.bold: true
                            color: dockWindow.colorText
                        }
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: "#1a1d28"
                    radius: 12
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 2
                        
                        Text {
                            text: "TEMP"
                            font.pixelSize: 10
                            color: dockWindow.colorTextMuted
                        }
                        Text {
                            text: "58°C"
                            font.pixelSize: 13
                            font.bold: true
                            color: dockWindow.colorText
                        }
                    }
                }
            }
            
            // Quick Toggle Buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    text: "Wi-Fi"
                    background: Rectangle {
                        color: "#1a1d28"
                        radius: 10
                        border.width: 1
                        border.color: "#232736"
                    }
                }
                
                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    text: "Bluetooth"
                    background: Rectangle {
                        color: "#1a1d28"
                        radius: 10
                        border.width: 1
                        border.color: "#232736"
                    }
                }
            }
            
            // Weather Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                color: "#1a1d28"
                radius: 14
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8
                    
                    RowLayout {
                        Text {
                            text: "󰖙"
                            font.pixelSize: 28
                            color: dockWindow.colorAccent
                        }
                        
                        Column {
                            Layout.fillWidth: true
                            spacing: 2
                            
                            Text {
                                text: dockWindow.currentWeatherDesc
                                font.pixelSize: 13
                                font.bold: true
                                color: dockWindow.colorText
                            }
                            Text {
                                text: dockWindow.currentWeather
                                font.pixelSize: 11
                                color: dockWindow.colorTextMuted
                            }
                        }
                    }
                    
                    RowLayout {
                        spacing: 8
                        
                        Text {
                            text: "Humidity: 65%"
                            font.pixelSize: 10
                            color: dockWindow.colorTextMuted
                        }
                        Text {
                            text: "Wind: 12 km/h"
                            font.pixelSize: 10
                            color: dockWindow.colorTextMuted
                        }
                    }
                }
            }
            
            Item { Layout.fillHeight: true }
        }
    }
}
