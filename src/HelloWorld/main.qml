import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.2
import com.example.plugin.maintenance 1.0       //[1]

ApplicationWindow {
  visible: true
  width: 640
  height: 480
  title: qsTr("Hello World")

  //メンテナンス機能                                  [2]
  Maintenance {
    id: mainte
    //アップデート確認の自動実行中かフラグ
    property bool automatically: false
    //メンテツールのファイル名
    toolName: "maintenancetool.exe"

    //実行状態が変化した                             [3]
    onStateChanged: {
      if(state == Maintenance.FINISH){
        //アップデート確認が終了
        if(hasUpdate){
          //アップデートが見つかった
          console.debug("detail:" + updateDetail)
          updateDetailDlg.xml = updateDetail
          updateDetailDlg.show()
        }else if(!automatically){
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
      mainte.automatically = true
      mainte.checkUpdate()
    }
  }

  //メニュー
  menuBar: MenuBar {
    Menu {
      title: qsTr("File")
      MenuItem {
        text: qsTr("Check update")
        onTriggered: {
          //手動実行として確認開始                     [5]
          mainte.automatically = false
          mainte.checkUpdate()
        }
      }
      MenuItem {
        text: qsTr("Exit")
        onTriggered: Qt.quit()
      }
    }
  }

  Text {
    text: qsTr("Hello World")
    anchors.centerIn: parent
  }

  //アップデート確認ダイアログ                             [6]
  UpdateDetailDialog {
    id: updateDetailDlg
    onAccepted: {
      mainte.startMaintenanceTool()   //メンテツール起動
      Qt.quit()
    }
    onCanceled: { console.debug("No thank you") }
  }
  //見つからなかった時の案内                              [7]
  MessageDialog {
    id: notFoundDlg
    title: qsTr("Notification")
    text: qsTr("Not found update.")
    standardButtons: StandardButton.Ok
  }
}
