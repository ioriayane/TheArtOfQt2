import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Dialogs 1.2
import com.example.plugin.maintenancetool 1.0       //[1]

ApplicationWindow {
  visible: true
  width: 640
  height: 480
  title: qsTr("Hello World")

  //メンテナンス機能                                  [2]
  MaintenanceTool {
    id: maintenancetool
    //アップデート確認の自動実行中かフラグ
    property bool automatic: false

    //実行状態が変化した                             [3]
    onStateChanged: {
      if(state === MaintenanceTool.NotRunning){
        //アップデート確認が終了
        if(hasUpdate){
          //アップデートが見つかった
          console.debug("detail:" + updateDetails)
          updateDetailDlg.xml = updateDetails
          updateDetailDlg.open()
        }else if(!automatic){
          //見つかってなくて自動実行じゃないとき
          notFoundDlg.open()
        }
      }
    }
  }

  //アップデート確認の自動実行用のタイマー                   [4]
  Timer {
    interval: 2000
    repeat: false
    running: true
    onTriggered: {
      //自動実行として確認開始
      maintenancetool.automatic = true
      maintenancetool.checkUpdate()
    }
  }

  //メニュー
  menuBar: MenuBar {
    Menu {
      title: qsTr("&File")
      MenuItem {
        text: qsTr("&Check update")
        onTriggered: {
          //手動実行として確認開始                     [5]
          maintenancetool.automatic = false
          maintenancetool.checkUpdate()
        }
      }
      MenuItem {
        text: qsTr("&Exit")
        onTriggered: Qt.quit()
      }
    }
  }

  Text {
    text: qsTr("Hello World")
    anchors.centerIn: parent
  }

  //アップデート確認ダイアログ                             [6]
  UpdateDetailsDialog {
    id: updateDetailDlg
    onAccepted: {
      maintenancetool.startMaintenanceTool()   //メンテツール起動
      if(Qt.platform.os == "windows"){
        Qt.quit()
      }
    }
    onNo: { console.debug("No thank you") }
  }
  //見つからなかった時の案内
  MessageDialog {
    id: notFoundDlg
    title: qsTr("Notification")
    text: qsTr("Not found update.")
    standardButtons: StandardButton.Ok
  }
}
